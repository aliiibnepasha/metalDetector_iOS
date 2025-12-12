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
    @Published var isHomeBannerReady = false
    @Published var isHomeBannerLoading = false
    @Published var isSplashBannerReady = false
    @Published var isSplashBannerLoading = false
    
    private var splashInterstitialWrapper: InterstitialAdWrapper?
    private var generalInterstitialWrapper: InterstitialAdWrapper?
    
    var homeBannerView: BannerView?
    var splashBannerView: BannerView?
    
    private var iapManager = IAPManager.shared
    
    // MARK: - Backoff / cooldown (general)
    private var generalRetryCount = 0
    private var generalNextAllowedLoad: Date = .distantPast
    // After any failure, wait a full 60s before the next request to protect match rate
    private let generalBaseCooldown: TimeInterval = 60
    private let generalMaxCooldown: TimeInterval = 60
    private var scheduledGeneralRetry: DispatchWorkItem?

    // MARK: - Backoff / cooldown (splash)
    private var splashRetryCount = 0
    private var splashNextAllowedLoad: Date = .distantPast
    // Splash retry also fixed at 60s after failure
    private let splashBaseCooldown: TimeInterval = 60
    private let splashMaxCooldown: TimeInterval = 60
    private var scheduledSplashRetry: DispatchWorkItem?

    // MARK: - Banner backoff
    private var homeBannerRetryCount = 0
    private var homeBannerNextAllowedLoad: Date = .distantPast
    private let homeBannerBaseCooldown: TimeInterval = 60
    private let homeBannerMaxCooldown: TimeInterval = 60
    private var scheduledHomeBannerRetry: DispatchWorkItem?

    private var splashBannerRetryCount = 0
    private var splashBannerNextAllowedLoad: Date = .distantPast
    private let splashBannerBaseCooldown: TimeInterval = 60
    private let splashBannerMaxCooldown: TimeInterval = 60
    private var scheduledSplashBannerRetry: DispatchWorkItem?

    // MARK: - Foreground gating
    private var hasSeenFirstForeground = false
    private var lastForegroundShow: Date = .distantPast
    private let foregroundMinInterval: TimeInterval = 120 // 2 minutes

    // MARK: - Click based cadence (your required logic)
    private var interstitialClickCount: Int = 0
    private var pendingCadenceShow: Bool = false
    private var pendingCadenceCapping: Bool = false
    
    // Reset click cadence
    fileprivate func resetInterstitialCadence() {
        interstitialClickCount = 0
        pendingCadenceShow = false
        pendingCadenceCapping = false
    }
    
    // MARK: - View ad tracking
    private var viewsThatShowedAd: Set<String> = []
    
    private var isPremium: Bool {
        return iapManager.isPremium
    }

    func shouldShowAdForView(_ viewIdentifier: String) -> Bool {
        if isPremium { return false }
        if viewsThatShowedAd.contains(viewIdentifier) { return false }
        return true
    }
    
    func resetAdTracking() {
        viewsThatShowedAd.removeAll()
    }
}

//////////////////////////////////////////////////////////
// MARK: - Splash Interstitial Loader
//////////////////////////////////////////////////////////

extension AdManager {

    func loadSplashInterstitial() {
        guard !isPremium else {
            print("Premium user: splash interstitial skipped")
            return
        }
        
        if splashInterstitialWrapper != nil, isInterstitialReady { return }
        if isLoadingInterstitial { return }
        
        let now = Date()
        if now < splashNextAllowedLoad {
            let wait = Int(splashNextAllowedLoad.timeIntervalSince(now))
            print("⏳ Splash cooldown: \(wait)s")
            return
        }
        
        isLoadingInterstitial = true
        isInterstitialReady = false
        
        FirebaseManager.logAdEvent("splash", placement: "splash", adType: "fullscreen", status: "requested")
        
        splashInterstitialWrapper = InterstitialAdWrapper(adUnitID: AdConfig.interstitialSplash) { [weak self] loaded in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.isLoadingInterstitial = false
                self.isInterstitialReady = loaded
                
                if loaded {
                    print("✅ Splash interstitial loaded")
                    FirebaseManager.logAdEvent("splash", placement: "splash", adType: "fullscreen", status: "loaded")
                    self.splashRetryCount = 0
                    self.splashNextAllowedLoad = Date()
                } else {
                    print("❌ Splash interstitial failed")
                    FirebaseManager.logAdEvent("splash", placement: "splash", adType: "fullscreen", status: "failed")
                    self.scheduleSplashRetry()
                }
            }
        }
        
        splashInterstitialWrapper?.load()
    }
}


//////////////////////////////////////////////////////////
// MARK: - Show Splash Interstitial
//////////////////////////////////////////////////////////

extension AdManager {
    
    func showSplashInterstitial(completion: @escaping () -> Void) {
        guard !isPremium else { completion(); return }
        
        guard let wrapper = splashInterstitialWrapper, isInterstitialReady else {
            print("⚠️ Splash not ready")
            completion()
            return
        }
        
        guard let rootVC = getRootViewController() else {
            completion()
            return
        }
        
        wrapper.onAdClosed = { [weak self] in
            DispatchQueue.main.async {
                self?.isInterstitialReady = false
                self?.splashInterstitialWrapper = nil
                completion()
            }
        }
        
        wrapper.onAdFailedToShow = { [weak self] error in
            DispatchQueue.main.async {
                self?.isInterstitialReady = false
                self?.splashInterstitialWrapper = nil
                completion()
            }
        }
        
        wrapper.show(from: rootVC)
    }
}


//////////////////////////////////////////////////////////
// MARK: - General Interstitial Loader
//////////////////////////////////////////////////////////

extension AdManager {

    func loadGeneralInterstitial() {
        guard !isPremium else { return }
        
        if generalInterstitialWrapper != nil, isInterstitialReady { return }
        if isLoadingInterstitial { return }
        
        let now = Date()
        if now < generalNextAllowedLoad { return }
        
        isLoadingInterstitial = true
        isInterstitialReady = false
        
        FirebaseManager.logAdEvent("general", placement: "general", adType: "fullscreen", status: "requested")
        
        generalInterstitialWrapper = InterstitialAdWrapper(adUnitID: AdConfig.interstitial) { [weak self] loaded in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.isLoadingInterstitial = false
                self.isInterstitialReady = loaded
                
                if loaded {
                    print("✅ General interstitial loaded")
                    self.generalRetryCount = 0
                    self.generalNextAllowedLoad = Date()
                } else {
                    print("❌ General interstitial failed")
                    self.scheduleGeneralRetry()
                }
            }
        }
        
        generalInterstitialWrapper?.load()
    }
}


//////////////////////////////////////////////////////////
// MARK: - Show General Interstitial
//////////////////////////////////////////////////////////

extension AdManager {
    
    func showGeneralInterstitial(forView viewIdentifier: String? = nil,
                                 completion: @escaping () -> Void) {
        
        guard !isPremium else { completion(); return }
        guard let wrapper = generalInterstitialWrapper, isInterstitialReady else {
            completion()
            return
        }
        
        guard let rootVC = getRootViewController() else {
            completion()
            return
        }
        
        wrapper.onAdClosed = { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.pendingCadenceShow = false
                self.pendingCadenceCapping = false
                
                self.isInterstitialReady = false
                self.generalInterstitialWrapper = nil
                completion()
                // Reload after handing navigation to avoid visible flash
                self.loadGeneralInterstitial()
            }
        }
        
        wrapper.onAdFailedToShow = { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                // Roll back the click consumption so cadence stays aligned
                if self.pendingCadenceShow, self.pendingCadenceCapping {
                    self.interstitialClickCount = max(self.interstitialClickCount - 1, 0)
                }
                
                self.pendingCadenceShow = false
                self.pendingCadenceCapping = false
                self.isInterstitialReady = false
                self.generalInterstitialWrapper = nil
                self.loadGeneralInterstitial()
                completion()
            }
        }
        
        wrapper.show(from: rootVC)
    }
}


//////////////////////////////////////////////////////////
// MARK: - Foreground Interstitial
//////////////////////////////////////////////////////////

extension AdManager {

    func maybeShowForegroundInterstitial() {
        guard !isPremium else { return }
        
        if !hasSeenFirstForeground {
            hasSeenFirstForeground = true
            return
        }
        
        let now = Date()
        if now.timeIntervalSince(lastForegroundShow) < foregroundMinInterval { return }
        
        if isInterstitialReady {
            showGeneralInterstitial { }
            lastForegroundShow = now
        } else {
            loadGeneralInterstitial()
        }
    }
}


//////////////////////////////////////////////////////////
// MARK: - FIXED CLICK-BASED CADENCE LOGIC
//////////////////////////////////////////////////////////

extension AdManager {
    
    /// Correct pattern: 1st, 4th, 7th, 10th click → SHOW ad
    func handleClickTriggeredInterstitial(context: String? = nil,
                                          isCapping: Bool = true,
                                          completion: @escaping () -> Void) {
        
        guard !isPremium else {
            completion()
            return
        }
        
        if isCapping {
            interstitialClickCount += 1
        }
        
        print("🎯 Click \(interstitialClickCount) pendingShow=\(pendingCadenceShow)")
        
        // REQUIRED LOGIC:
        // 1st → ad
        // next 2 skip
        // 4th → ad
        let shouldShow = isCapping ? (interstitialClickCount % 3 == 1) : true
        
        // Ad ready → show
        if shouldShow, isInterstitialReady, generalInterstitialWrapper != nil {
            pendingCadenceShow = true
            pendingCadenceCapping = isCapping
            // Navigate first, then show ad so dismiss reveals the destination screen (no flash back)
            DispatchQueue.main.async {
                completion()
                self.showGeneralInterstitial(forView: context, completion: { })
            }
            return
        }
        
        // Show turn but ad not ready → roll back count so next click still shows
        if shouldShow {
            if isCapping {
                interstitialClickCount = max(interstitialClickCount - 1, 0)
                print("⏪ Rolled back click to \(interstitialClickCount) (ad not ready)")
            }
            pendingCadenceShow = false
            pendingCadenceCapping = false
            loadGeneralInterstitial()
            completion()
            return
        }
        
        // Not show turn → keep loading for future
        if !isInterstitialReady && !isLoadingInterstitial {
            loadGeneralInterstitial()
        }
        
        completion()
    }
}

// MARK: - Banner Preload Functions
extension AdManager {

    func preloadHomeBanner() {
        guard !isPremium else { return }
        
        if isHomeBannerLoading { return }
        if isHomeBannerReady { return }
        
        let now = Date()
        if now < homeBannerNextAllowedLoad { return }
        
        isHomeBannerLoading = true
        isHomeBannerReady = false
        
        print("📡 Loading home banner...")
        
        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = AdConfig.bannerHome
        banner.delegate = self
        
        if let rootViewController = getRootViewController() {
            banner.rootViewController = rootViewController
        }
        
        banner.load(Request())
        homeBannerView = banner
    }
    
    
    func preloadSplashBanner() {
        guard !isPremium else { return }
        
        if isSplashBannerLoading { return }
        if isSplashBannerReady { return }
        
        let now = Date()
        if now < splashBannerNextAllowedLoad { return }
        
        isSplashBannerLoading = true
        isSplashBannerReady = false
        
        print("📡 Loading splash banner...")
        
        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = AdConfig.bannerSplash
        banner.delegate = self
        
        if let rootViewController = getRootViewController() {
            banner.rootViewController = rootViewController
        }
        
        banner.load(Request())
        splashBannerView = banner
    }
}

//////////////////////////////////////////////////////////
// MARK: - BannerView Delegate
//////////////////////////////////////////////////////////

extension AdManager: BannerViewDelegate {

    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        DispatchQueue.main.async {
            if bannerView == self.homeBannerView {
                self.isHomeBannerReady = true
                self.isHomeBannerLoading = false
                self.homeBannerRetryCount = 0
                self.homeBannerNextAllowedLoad = Date()
                print("Home banner loaded")
            }
            
            if bannerView == self.splashBannerView {
                self.isSplashBannerReady = true
                self.isSplashBannerLoading = false
                self.splashBannerRetryCount = 0
                self.splashBannerNextAllowedLoad = Date()
                print("Splash banner loaded")
            }
        }
    }
    
    
    func bannerView(_ bannerView: BannerView,
                    didFailToReceiveAdWithError error: Error) {
        
        DispatchQueue.main.async {
            if bannerView == self.homeBannerView {
                self.isHomeBannerReady = false
                self.isHomeBannerLoading = false
                self.scheduleHomeBannerRetry()
            }
            
            if bannerView == self.splashBannerView {
                self.isSplashBannerReady = false
                self.isSplashBannerLoading = false
                self.scheduleSplashBannerRetry()
            }
        }
    }
}


//////////////////////////////////////////////////////////
// MARK: - Banner Retry Logic
//////////////////////////////////////////////////////////

extension AdManager {
    
    private func scheduleHomeBannerRetry() {
        homeBannerRetryCount += 1
        
        // Fixed 60s delay between requests after any failure
        let delay = min(homeBannerMaxCooldown, homeBannerBaseCooldown)
        
        homeBannerNextAllowedLoad = Date().addingTimeInterval(delay)
        
        scheduledHomeBannerRetry?.cancel()
        
        let work = DispatchWorkItem { [weak self] in
            self?.preloadHomeBanner()
        }
        
        scheduledHomeBannerRetry = work
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: work)
        print("Retrying home banner in \(Int(delay))s")
    }
    
    
    private func scheduleSplashBannerRetry() {
        splashBannerRetryCount += 1
        
        // Fixed 60s delay between requests after any failure
        let delay = min(splashBannerMaxCooldown, splashBannerBaseCooldown)
        
        splashBannerNextAllowedLoad = Date().addingTimeInterval(delay)
        
        scheduledSplashBannerRetry?.cancel()
        
        let work = DispatchWorkItem { [weak self] in
            self?.preloadSplashBanner()
        }
        
        scheduledSplashBannerRetry = work
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: work)
        print("Retrying splash banner in \(Int(delay))s")
    }
}


//////////////////////////////////////////////////////////
// MARK: - Retry Logic (Splash & General)
//////////////////////////////////////////////////////////

extension AdManager {

    func scheduleGeneralRetry() {
        generalRetryCount += 1
        
        // Fixed 60s delay between requests after any failure
        let delay = min(generalMaxCooldown, generalBaseCooldown)
        
        generalNextAllowedLoad = Date().addingTimeInterval(delay)
        
        scheduledGeneralRetry?.cancel()
        
        let work = DispatchWorkItem { [weak self] in
            self?.loadGeneralInterstitial()
        }
        
        scheduledGeneralRetry = work
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: work)
        print("General retry in \(Int(delay))s")
    }
    
    
    func scheduleSplashRetry() {
        splashRetryCount += 1
        
        // Fixed 60s delay between requests after any failure
        let delay = min(splashMaxCooldown, splashBaseCooldown)
        
        splashNextAllowedLoad = Date().addingTimeInterval(delay)
        
        scheduledSplashRetry?.cancel()
        
        let work = DispatchWorkItem { [weak self] in
            self?.loadSplashInterstitial()
        }
        
        scheduledSplashRetry = work
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: work)
        print("Splash retry in \(Int(delay))s")
    }
}


//////////////////////////////////////////////////////////
// MARK: - Root VC Helper
//////////////////////////////////////////////////////////

extension AdManager {
    
    func getRootViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first,
              let rootVC = window.rootViewController else { return nil }
        
        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }
        return topVC
    }
}


//////////////////////////////////////////////////////////
// MARK: - Interstitial Ad Wrapper
//////////////////////////////////////////////////////////

class InterstitialAdWrapper: NSObject {
    
    private var interstitialAd: InterstitialAd?
    private let adUnitID: String
    private let onLoadCallback: (Bool) -> Void

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
                print("❌ Failed to load: \(error.localizedDescription)")
                self.onLoadCallback(false)
                return
            }
            
            guard let ad = ad else {
                print("❌ Loaded ad nil")
                self.onLoadCallback(false)
                return
            }
            
            self.interstitialAd = ad
            ad.fullScreenContentDelegate = self
            
            print("Interstitial loaded")
            self.onLoadCallback(true)
        }
    }
    
    
    func show(from rootVC: UIViewController) {
        guard let ad = interstitialAd else {
            print("❌ Interstitial nil")
            onAdFailedToShow?(NSError(domain: "AdError",
                                      code: -1,
                                      userInfo: [NSLocalizedDescriptionKey: "Interstitial nil"]))
            return
        }
        
        ad.present(from: rootVC)
    }
}


//////////////////////////////////////////////////////////
// MARK: - FullScreenContentDelegate
//////////////////////////////////////////////////////////

extension InterstitialAdWrapper: FullScreenContentDelegate {
    
    func ad(_ ad: FullScreenPresentingAd,
            didFailToPresentFullScreenContentWithError error: Error) {
        
        print("❌ Present error: \(error.localizedDescription)")
        onAdFailedToShow?(error)
        interstitialAd = nil
    }
    
    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("Ad will present")
    }
    
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("Ad dismissed")
        onAdClosed?()
        interstitialAd = nil
    }
}


