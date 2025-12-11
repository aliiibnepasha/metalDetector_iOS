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
    
    // Backoff / cooldown for general interstitials to protect match rate
    private var generalRetryCount = 0
    private var generalNextAllowedLoad: Date = .distantPast
    private let generalBaseCooldown: TimeInterval = 5       // seconds
    private let generalMaxCooldown: TimeInterval = 60       // seconds
    private var scheduledGeneralRetry: DispatchWorkItem?

    // Backoff / cooldown for splash interstitials
    private var splashRetryCount = 0
    private var splashNextAllowedLoad: Date = .distantPast
    private let splashBaseCooldown: TimeInterval = 5
    private let splashMaxCooldown: TimeInterval = 60
    private var scheduledSplashRetry: DispatchWorkItem?
    
    // Backoff for home banner
    private var homeBannerRetryCount = 0
    private var homeBannerNextAllowedLoad: Date = .distantPast
    private let homeBannerBaseCooldown: TimeInterval = 5
    private let homeBannerMaxCooldown: TimeInterval = 60
    private var scheduledHomeBannerRetry: DispatchWorkItem?

    // Backoff for splash banner
    private var splashBannerRetryCount = 0
    private var splashBannerNextAllowedLoad: Date = .distantPast
    private let splashBannerBaseCooldown: TimeInterval = 5
    private let splashBannerMaxCooldown: TimeInterval = 60
    private var scheduledSplashBannerRetry: DispatchWorkItem?

    // Foreground interstitial gating
    private var hasSeenFirstForeground = false
    private var lastForegroundShow: Date = .distantPast
    private let foregroundMinInterval: TimeInterval = 120 // seconds between foreground shows

    // Click-based interstitial cadence (skip 2, show on 3rd)
    private var interstitialClickCount: Int = 0
    private var pendingCadenceShow: Bool = false
    private var pendingCadenceCapping: Bool = false
    // Reset click cadence (e.g., when returning to home)
    func resetInterstitialCadence() {
        interstitialClickCount = 0
        pendingCadenceShow = false
        pendingCadenceCapping = false
    }
    
    // Track which views have already shown an ad in this session
    private var viewsThatShowedAd: Set<String> = []
    
    override init() {
        super.init()
    }
    
    // MARK: - Check if User is Premium
    private var isPremium: Bool {
        return iapManager.isPremium
    }
    
    // MARK: - Track Ad Display
    func shouldShowAdForView(_ viewIdentifier: String) -> Bool {
        // Don't show ad if already shown for this view, or if user is premium
        if isPremium || viewsThatShowedAd.contains(viewIdentifier) {
            return false
        }
        return true
    }
    
    // Reset tracking (retained for future use; currently we allow repeat shows per view)
    func resetAdTracking() {
        viewsThatShowedAd.removeAll()
    }
    
    // MARK: - Load Splash Interstitial Ad
    func loadSplashInterstitial() {
        // Don't load ads if user is premium
        guard !isPremium else {
            print("✅ AdManager: User is premium, skipping splash interstitial")
            return
        }
        
        // If already loaded, skip
        if splashInterstitialWrapper != nil, isInterstitialReady {
            print("✅ AdManager: Splash interstitial already loaded")
            return
        }

        // If currently loading, skip
        if isLoadingInterstitial {
            print("ℹ️ AdManager: Splash interstitial load already in progress")
            return
        }

        // Respect cooldown/backoff to protect match rate
        let now = Date()
        if now < splashNextAllowedLoad {
            let wait = splashNextAllowedLoad.timeIntervalSince(now)
            print("⏳ AdManager: In cooldown (\(Int(wait))s) before requesting splash interstitial")
            return
        }
        
        isLoadingInterstitial = true
        isInterstitialReady = false
        
        // Log ad requested event
        FirebaseManager.logAdEvent("splash", placement: "splash", adType: "fullscreen", status: "requested")
        
        splashInterstitialWrapper = InterstitialAdWrapper(adUnitID: AdConfig.interstitialSplash) { [weak self] loaded in
            DispatchQueue.main.async {
                self?.isInterstitialReady = loaded
                self?.isLoadingInterstitial = false
                if loaded {
                    print("✅ AdManager: Splash interstitial loaded successfully")
                    FirebaseManager.logAdEvent("splash", placement: "splash", adType: "fullscreen", status: "loaded")
                    self?.splashRetryCount = 0
                    self?.splashNextAllowedLoad = Date()
                } else {
                    print("❌ AdManager: Splash interstitial failed to load")
                    FirebaseManager.logAdEvent("splash", placement: "splash", adType: "fullscreen", status: "failed")
                    self?.scheduleSplashRetry()
                }
            }
        }
        
        splashInterstitialWrapper?.load()
    }
    
    // MARK: - Preload Home Banner (single cached banner)
    func preloadHomeBanner() {
        // Don't load ads if user is premium
        guard !isPremium else {
            print("✅ AdManager: User is premium, skipping home banner")
            return
        }
        
        // If already loaded, skip
        if isHomeBannerReady {
            print("✅ AdManager: Home banner already loaded")
            return
        }
        
        // If currently loading, skip
        if isHomeBannerLoading {
            print("ℹ️ AdManager: Home banner load already in progress")
            return
        }
        
        // Respect cooldown/backoff
        let now = Date()
        if now < homeBannerNextAllowedLoad {
            let wait = homeBannerNextAllowedLoad.timeIntervalSince(now)
            print("⏳ AdManager: In cooldown (\(Int(wait))s) before requesting home banner")
            return
        }
        
        isHomeBannerLoading = true
        isHomeBannerReady = false
        
        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = AdConfig.bannerHome
        banner.delegate = self
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            banner.rootViewController = rootViewController
        }
        
        FirebaseManager.logAdEvent("home", placement: "home", adType: "banner", status: "requested")
        
        let request = Request()
        banner.load(request)
        
        self.homeBannerView = banner
    }

    // MARK: - Preload Splash Banner (single cached banner)
    func preloadSplashBanner() {
        // Don't load ads if user is premium
        guard !isPremium else {
            print("✅ AdManager: User is premium, skipping splash banner")
            return
        }
        
        // If already loaded, skip
        if isSplashBannerReady {
            print("✅ AdManager: Splash banner already loaded")
            return
        }
        
        // If currently loading, skip
        if isSplashBannerLoading {
            print("ℹ️ AdManager: Splash banner load already in progress")
            return
        }
        
        // Respect cooldown/backoff
        let now = Date()
        if now < splashBannerNextAllowedLoad {
            let wait = splashBannerNextAllowedLoad.timeIntervalSince(now)
            print("⏳ AdManager: In cooldown (\(Int(wait))s) before requesting splash banner")
            return
        }
        
        isSplashBannerLoading = true
        isSplashBannerReady = false
        
        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = AdConfig.bannerSplash
        banner.delegate = self
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            banner.rootViewController = rootViewController
        }
        
        FirebaseManager.logAdEvent("splash", placement: "splash", adType: "banner", status: "requested")
        
        let request = Request()
        banner.load(request)
        
        self.splashBannerView = banner
    }
    
    // MARK: - Show Splash Interstitial Ad
    func showSplashInterstitial(completion: @escaping () -> Void) {
        // Don't show ads if user is premium
        guard !isPremium else {
            print("✅ AdManager: User is premium, skipping splash interstitial")
            completion()
            return
        }
        
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
    
    // MARK: - Load General Interstitial Ad (for detector taps)
    func loadGeneralInterstitial() {
        // Don't load ads if user is premium
        guard !isPremium else {
            print("✅ AdManager: User is premium, skipping general interstitial")
            return
        }
        
        // If ad is already loaded, skip
        if generalInterstitialWrapper != nil, isInterstitialReady {
            print("✅ AdManager: General interstitial already loaded")
            return
        }
        
        // If currently loading, skip
        if isLoadingInterstitial {
            print("ℹ️ AdManager: General interstitial load already in progress")
            return
        }
        
        // Respect cooldown/backoff to protect match rate
        let now = Date()
        if now < generalNextAllowedLoad {
            let wait = generalNextAllowedLoad.timeIntervalSince(now)
            print("⏳ AdManager: In cooldown (\(Int(wait))s) before requesting general interstitial")
            return
        }
        
        isLoadingInterstitial = true
        isInterstitialReady = false
        
        // Log ad requested event
        FirebaseManager.logAdEvent("general", placement: "general", adType: "fullscreen", status: "requested")
        
        generalInterstitialWrapper = InterstitialAdWrapper(adUnitID: AdConfig.interstitial) { [weak self] loaded in
            DispatchQueue.main.async {
                self?.isInterstitialReady = loaded
                self?.isLoadingInterstitial = false
                
                if loaded {
                    print("✅ AdManager: General interstitial loaded successfully")
                    FirebaseManager.logAdEvent("general", placement: "general", adType: "fullscreen", status: "loaded")
                    self?.generalRetryCount = 0
                    self?.generalNextAllowedLoad = Date() // immediately eligible to show
                } else {
                    print("❌ AdManager: General interstitial failed to load")
                    FirebaseManager.logAdEvent("general", placement: "general", adType: "fullscreen", status: "failed")
                    self?.scheduleGeneralRetry()
                }
            }
        }
        
        generalInterstitialWrapper?.load()
    }
    
    // MARK: - Show General Interstitial Ad
    func showGeneralInterstitial(forView viewIdentifier: String? = nil, completion: @escaping () -> Void) {
        // Don't show ads if user is premium
        guard !isPremium else {
            print("✅ AdManager: User is premium, skipping general interstitial")
            completion()
            return
        }
        
        guard let adWrapper = generalInterstitialWrapper, isInterstitialReady else {
            print("⚠️ AdManager: General interstitial not ready, skipping ad")
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
                if let self = self, self.pendingCadenceShow, self.pendingCadenceCapping {
                    self.interstitialClickCount = 0 // restart cadence after a successful show
                }
                self?.isInterstitialReady = false
                self?.generalInterstitialWrapper = nil
                self?.pendingCadenceShow = false
                self?.pendingCadenceCapping = false
                // Reload next ad for future use
                self?.loadGeneralInterstitial()
                completion()
            }
        }
        
        adWrapper.onAdFailedToShow = { [weak self] error in
            DispatchQueue.main.async {
                print("❌ AdManager: Failed to show interstitial: \(error?.localizedDescription ?? "Unknown error")")
                if let self = self, self.pendingCadenceShow, self.pendingCadenceCapping {
                    self.interstitialClickCount = max(0, self.interstitialClickCount - 1)
                }
                self?.pendingCadenceShow = false
                self?.pendingCadenceCapping = false
                self?.isInterstitialReady = false
                self?.generalInterstitialWrapper = nil
                // Reload next ad for future use
                self?.loadGeneralInterstitial()
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
    
    // MARK: - Backoff helpers
    private func scheduleGeneralRetry() {
        generalRetryCount += 1
        let delay = min(generalMaxCooldown, generalBaseCooldown * pow(2.0, Double(generalRetryCount - 1)))
        generalNextAllowedLoad = Date().addingTimeInterval(delay)
        
        scheduledGeneralRetry?.cancel()
        let work = DispatchWorkItem { [weak self] in
            self?.loadGeneralInterstitial()
        }
        scheduledGeneralRetry = work
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: work)
        print("🔁 AdManager: Scheduled general interstitial retry in \(Int(delay))s (retry \(generalRetryCount))")
    }

    private func scheduleSplashRetry() {
        splashRetryCount += 1
        let delay = min(splashMaxCooldown, splashBaseCooldown * pow(2.0, Double(splashRetryCount - 1)))
        splashNextAllowedLoad = Date().addingTimeInterval(delay)

        scheduledSplashRetry?.cancel()
        let work = DispatchWorkItem { [weak self] in
            self?.loadSplashInterstitial()
        }
        scheduledSplashRetry = work
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: work)
        print("🔁 AdManager: Scheduled splash interstitial retry in \(Int(delay))s (retry \(splashRetryCount))")
    }
}

// MARK: - BannerViewDelegate for home banner caching
extension AdManager: BannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        if bannerView == homeBannerView {
            DispatchQueue.main.async {
                self.isHomeBannerReady = true
                self.isHomeBannerLoading = false
                self.homeBannerRetryCount = 0
                self.homeBannerNextAllowedLoad = Date()
                FirebaseManager.logAdEvent("home", placement: "home", adType: "banner", status: "loaded")
                print("✅ AdManager: Home banner loaded")
            }
        }
        
        if bannerView == splashBannerView {
            DispatchQueue.main.async {
                self.isSplashBannerReady = true
                self.isSplashBannerLoading = false
                self.splashBannerRetryCount = 0
                self.splashBannerNextAllowedLoad = Date()
                FirebaseManager.logAdEvent("splash", placement: "splash", adType: "banner", status: "loaded")
                print("✅ AdManager: Splash banner loaded")
            }
        }
    }
    
    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        if bannerView == homeBannerView {
            DispatchQueue.main.async {
                self.isHomeBannerReady = false
                self.isHomeBannerLoading = false
                FirebaseManager.logAdEvent("home", placement: "home", adType: "banner", status: "failed")
                self.scheduleHomeBannerRetry()
                print("❌ AdManager: Home banner failed: \(error.localizedDescription)")
            }
        }
        
        if bannerView == splashBannerView {
            DispatchQueue.main.async {
                self.isSplashBannerReady = false
                self.isSplashBannerLoading = false
                FirebaseManager.logAdEvent("splash", placement: "splash", adType: "banner", status: "failed")
                self.scheduleSplashBannerRetry()
                print("❌ AdManager: Splash banner failed: \(error.localizedDescription)")
            }
        }
    }
    
    private func scheduleHomeBannerRetry() {
        homeBannerRetryCount += 1
        let delay = min(homeBannerMaxCooldown, homeBannerBaseCooldown * pow(2.0, Double(homeBannerRetryCount - 1)))
        homeBannerNextAllowedLoad = Date().addingTimeInterval(delay)
        
        scheduledHomeBannerRetry?.cancel()
        let work = DispatchWorkItem { [weak self] in
            self?.preloadHomeBanner()
        }
        scheduledHomeBannerRetry = work
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: work)
        print("🔁 AdManager: Scheduled home banner retry in \(Int(delay))s (retry \(homeBannerRetryCount))")
    }

    private func scheduleSplashBannerRetry() {
        splashBannerRetryCount += 1
        let delay = min(splashBannerMaxCooldown, splashBannerBaseCooldown * pow(2.0, Double(splashBannerRetryCount - 1)))
        splashBannerNextAllowedLoad = Date().addingTimeInterval(delay)

        scheduledSplashBannerRetry?.cancel()
        let work = DispatchWorkItem { [weak self] in
            self?.preloadSplashBanner()
        }
        scheduledSplashBannerRetry = work
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: work)
        print("🔁 AdManager: Scheduled splash banner retry in \(Int(delay))s (retry \(splashBannerRetryCount))")
    }

    // MARK: - Foreground interstitial (on resume)
    func maybeShowForegroundInterstitial() {
        guard !isPremium else { return }
        
        // Skip first activation after app launch
        if !hasSeenFirstForeground {
            hasSeenFirstForeground = true
            return
        }
        
        let now = Date()
        if now.timeIntervalSince(lastForegroundShow) < foregroundMinInterval {
            print("⏳ AdManager: Foreground interstitial gated by interval")
            return
        }
        
        // If ready, show; else trigger a load
        if isInterstitialReady {
            showGeneralInterstitial(forView: nil) { }
            lastForegroundShow = now
        } else {
            loadGeneralInterstitial()
        }
    }

    // MARK: - Click-based interstitial cadence (mirror Android: show on 1,4,7...; splash can bypass)
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

        // Skip 2 clicks, show on the 3rd (pattern: 3,6,9...) after app enters flow
        let shouldShow = isCapping ? (interstitialClickCount > 0 && interstitialClickCount % 3 == 0) : true

        // If it's a show turn and ad is ready, show now
        if shouldShow, isInterstitialReady, generalInterstitialWrapper != nil {
            pendingCadenceShow = true
            pendingCadenceCapping = isCapping
            showGeneralInterstitial(forView: context, completion: completion)
            return
        }

        // If it's a show turn but not ready, roll back the count and trigger a load so the next click still tries to show
        if shouldShow {
            if isCapping { interstitialClickCount -= 1 }
            loadGeneralInterstitial()
            completion()
            return
        }

        // Not a show turn: ensure a load is in-flight for future shows
        if !isInterstitialReady && !isLoadingInterstitial {
            loadGeneralInterstitial()
        }
        completion()
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
