//
//  BannerAdView.swift
//  Metal Detector IOS
//
//  Created by Lowbyte Studio on 27/11/2025.
//

import SwiftUI
import GoogleMobileAds
import UIKit

struct BannerAdView: UIViewRepresentable {
    let adUnitID: String
    @Binding var isLoading: Bool
    private let retryDelay: TimeInterval = 5.0
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isLoading: $isLoading, retryDelay: retryDelay, adUnitID: adUnitID)
    }
    
    func makeUIView(context: Context) -> BannerView {
        let bannerView = BannerView(adSize: AdSizeBanner)
        bannerView.adUnitID = adUnitID
        bannerView.delegate = context.coordinator
        
        // Don't load ads if user is premium
        let iapManager = IAPManager.shared
        if iapManager.isPremium {
            DispatchQueue.main.async {
                isLoading = false
            }
            bannerView.isHidden = true
            return bannerView
        }
        
        // Get root view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            bannerView.rootViewController = rootViewController
        }
        
        // Mark as loading
        DispatchQueue.main.async {
            isLoading = true
        }
        
        // Log ad requested event
        if adUnitID == AdConfig.bannerSplash {
            FirebaseManager.logAdEvent("splash", placement: "splash", adType: "banner", status: "requested")
        }
        
        // Load ad
        let request = Request()
        bannerView.load(request)
        
        return bannerView
    }
    
    func updateUIView(_ uiView: BannerView, context: Context) {
        // Update if needed - reload if adUnitID changes
        if uiView.adUnitID != adUnitID {
            uiView.adUnitID = adUnitID
            let request = Request()
            DispatchQueue.main.async {
                isLoading = true
            }
            uiView.load(request)
        }
    }
    
    class Coordinator: NSObject, BannerViewDelegate {
        @Binding var isLoading: Bool
        private let retryDelay: TimeInterval
        private let adUnitID: String
        private var didRetry = false
        
        init(isLoading: Binding<Bool>, retryDelay: TimeInterval, adUnitID: String) {
            _isLoading = isLoading
            self.retryDelay = retryDelay
            self.adUnitID = adUnitID
        }
        
        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            DispatchQueue.main.async {
                self.isLoading = false
                // Log ad loaded event
                if bannerView.adUnitID == AdConfig.bannerSplash {
                    FirebaseManager.logAdEvent("splash", placement: "splash", adType: "banner", status: "loaded")
                }
            }
        }
        
        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            DispatchQueue.main.async {
                self.isLoading = false
                // Log ad failed event
                if bannerView.adUnitID == AdConfig.bannerSplash {
                    FirebaseManager.logAdEvent("splash", placement: "splash", adType: "banner", status: "failed")
                }
            }
            
            // Lightweight single retry after a short delay to improve show rate without spamming requests
            if !didRetry {
                didRetry = true
                DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) { [weak self, weak bannerView] in
                    guard let self = self, let bannerView = bannerView else { return }
                    DispatchQueue.main.async {
                        self.isLoading = true
                    }
                    let request = Request()
                    bannerView.load(request)
                }
            }
        }
    }
}

