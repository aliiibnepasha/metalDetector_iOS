//
//  Metal_Detector_IOSApp.swift
//  Metal Detector IOS
//
//  Created by Lowbyte Studio on 27/11/2025.
//

import SwiftUI
import FirebaseCore
import FirebaseAnalytics
import GoogleMobileAds
import AppTrackingTransparency
#if canImport(Adjust)
import Adjust
#endif

@main
struct Metal_Detector_IOSApp: App {
    @StateObject private var firebaseManager = FirebaseManager.shared
    
    init() {
        // Firebase will be configured in FirebaseManager
        // But we ensure it's configured here too
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        Analytics.setAnalyticsCollectionEnabled(true)
        // Initialize Google Mobile Ads SDK
        // SDK auto-initializes from Info.plist GADApplicationIdentifier
        // But we can explicitly start it for better control
        #if DEBUG
        print("🧪 AdMob: Using test ad IDs (Debug mode)")
        #endif
        
        // SDK auto-initializes, but we can configure test devices if needed
        // The SDK will automatically use test ads in debug mode
        
        // Start anonymous authentication
        FirebaseManager.shared.checkAndSignInAnonymously()

        // Initialize Adjust (safe even if SDK is not yet added; guarded by canImport)
        AdjustManager.shared.start()
        
        // Log first_open event (only once per app install)
        let hasLoggedFirstOpen = UserDefaults.standard.bool(forKey: "has_logged_first_open")
        if !hasLoggedFirstOpen {
            FirebaseManager.logEvent("first_open")
            UserDefaults.standard.set(true, forKey: "has_logged_first_open")
        }

        // Preload home banner early to reduce first paint latency
        AdManager.shared.preloadHomeBanner()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(firebaseManager)
                .onAppear {
                    // Ensure anonymous login happens on app launch
                    FirebaseManager.shared.checkAndSignInAnonymously()
                    
                    // Request App Tracking Transparency permission
                    // Delay to show after UI is ready
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        ATTManager.shared.requestTrackingPermission { status in
                            print("📊 ATT Status: \(status.rawValue)")
                        }
                    }
                }
        }
    }
}
