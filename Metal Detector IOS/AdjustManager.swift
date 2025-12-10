//
//  AdjustManager.swift
//  Metal Detector IOS
//
//  Lightweight wrapper around Adjust SDK. Safe to include even when the
//  Adjust SDK package is not yet added because everything is guarded with
//  `canImport(Adjust)`.
//

import Foundation

#if canImport(Adjust)
import Adjust
#endif

final class AdjustManager {
    static let shared = AdjustManager()
    private init() {}

    /// Initialize Adjust. Replace `YOUR_ADJUST_APP_TOKEN` once you have it.
    /// Call this once on app launch.
    func start() {
        #if canImport(Adjust)
        // TODO: Replace with the real app token when available.
        let appToken = "YOUR_ADJUST_APP_TOKEN"
        // Use `.production` when you are ready for release builds.
        let environment = ADJEnvironmentSandbox

        guard let config = ADJConfig(appToken: appToken, environment: environment) else {
            print("⚠️ Adjust: Failed to create config")
            return
        }

        // Optional: enable logs during integration
        config.logLevel = ADJLogLevelInfo

        Adjust.appDidLaunch(config)
        print("✅ Adjust: Initialized (env: \(environment))")
        #else
        print("ℹ️ Adjust: SDK not added yet. Add via SPM/Pods, then set the app token.")
        #endif
    }

    /// Track a generic event by token (token is created in the Adjust dashboard).
    func trackEvent(token: String) {
        #if canImport(Adjust)
        let event = ADJEvent(eventToken: token)
        Adjust.trackEvent(event)
        #endif
    }

    /// Track a revenue event (e.g., IAP or subscription) when you have the token.
    func trackRevenue(token: String, amount: Double, currency: String) {
        #if canImport(Adjust)
        let event = ADJEvent(eventToken: token)
        event?.setRevenue(amount, currency: currency)
        Adjust.trackEvent(event)
        #endif
    }

    /// Track ad revenue if you later integrate mediated networks.
    func trackAdRevenue(source: String, revenue: Double, currency: String) {
        #if canImport(Adjust)
        let adRevenue = ADJAdRevenue(source: source)
        adRevenue?.setRevenue(revenue, currency: currency)
        Adjust.trackAdRevenue(adRevenue)
        #endif
    }
}

