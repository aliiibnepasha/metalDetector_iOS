//
//  AdManager.swift
//  Metal Detector IOS
//
//  Created by Lowbyte Studio on 27/11/2025.
//

import Foundation
import GoogleMobileAds
import UIKit
import Combine

class AdManager: NSObject, ObservableObject {
    static let shared = AdManager()
    
    @Published var isInterstitialReady = false
    @Published var isLoadingInterstitial = false
    
    private var splashInterstitialWrapper: InterstitialAdWrapper?
    
    override init() {
        super.init()
    }
    
    // MARK: - Load Splash Interstitial Ad
    func loadSplashInterstitial() {
        guard splashInterstitialWrapper == nil || !isInterstitialReady else {
            print("✅ AdManager: Splash interstitial already loaded")
            return
        }
        
        isLoadingInterstitial = true
        isInterstitialReady = false
        
        splashInterstitialWrapper = InterstitialAdWrapper(adUnitID: AdConfig.interstitialSplash) { [weak self] loaded in
            DispatchQueue.main.async {
                self?.isInterstitialReady = loaded
                self?.isLoadingInterstitial = false
                print(loaded ? "✅ AdManager: Splash interstitial loaded successfully" : "❌ AdManager: Splash interstitial failed to load")
            }
        }
        
        splashInterstitialWrapper?.load()
    }
    
    // MARK: - Show Splash Interstitial Ad
    func showSplashInterstitial(completion: @escaping () -> Void) {
        guard let adWrapper = splashInterstitialWrapper, isInterstitialReady else {
            print("⚠️ AdManager: Splash interstitial not ready, skipping ad")
            completion()
            return
        }
        
        guard let rootViewController = getRootViewController() else {
            print("❌ AdManager: Could not get root view controller")
            completion()
            return
        }
        
        // Set completion handler
        adWrapper.onAdClosed = { [weak self] in
            DispatchQueue.main.async {
                self?.isInterstitialReady = false
                self?.splashInterstitialWrapper = nil
                completion()
            }
        }
        
        adWrapper.onAdFailedToShow = { [weak self] error in
            DispatchQueue.main.async {
                print("❌ AdManager: Failed to show interstitial: \(error?.localizedDescription ?? "Unknown error")")
                self?.isInterstitialReady = false
                self?.splashInterstitialWrapper = nil
                completion()
            }
        }
        
        adWrapper.show(from: rootViewController)
    }
    
    // MARK: - Helper Methods
    private func getRootViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            return nil
        }
        
        // Get the topmost view controller
        var topController = rootViewController
        while let presented = topController.presentedViewController {
            topController = presented
        }
        
        return topController
    }
}

// MARK: - Interstitial Ad Wrapper
class InterstitialAdWrapper: NSObject {
    private var interstitialAd: InterstitialAd?
    private let adUnitID: String
    private var onLoadCallback: ((Bool) -> Void)?
    
    var onAdClosed: (() -> Void)?
    var onAdFailedToShow: ((Error?) -> Void)?
    
    init(adUnitID: String, onLoad: @escaping (Bool) -> Void) {
        self.adUnitID = adUnitID
        self.onLoadCallback = onLoad
        super.init()
    }
    
    func load() {
        let request = Request()
        InterstitialAd.load(with: adUnitID, request: request) { [weak self] ad, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ InterstitialAdWrapper: Failed to load: \(error.localizedDescription)")
                self.onLoadCallback?(false)
                return
            }
            
            guard let ad = ad else {
                print("❌ InterstitialAdWrapper: Ad is nil")
                self.onLoadCallback?(false)
                return
            }
            
            ad.fullScreenContentDelegate = self
            self.interstitialAd = ad
            self.onLoadCallback?(true)
            print("✅ InterstitialAdWrapper: Loaded successfully")
        }
    }
    
    func show(from rootViewController: UIViewController) {
        guard let ad = interstitialAd else {
            print("❌ InterstitialAdWrapper: Cannot show, ad is nil")
            onAdFailedToShow?(NSError(domain: "AdManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ad is nil"]))
            return
        }
        
        ad.present(from: rootViewController)
    }
}

// MARK: - FullScreenContentDelegate
extension InterstitialAdWrapper: FullScreenContentDelegate {
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("❌ InterstitialAdWrapper: Failed to present: \(error.localizedDescription)")
        onAdFailedToShow?(error)
        interstitialAd = nil
    }
    
    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("✅ InterstitialAdWrapper: Will present")
    }
    
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("✅ InterstitialAdWrapper: Did dismiss")
        onAdClosed?()
        interstitialAd = nil
    }
}
