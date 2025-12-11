//
//  AdConfig.swift
//  Metal Detector IOS
//
//  Created by Lowbyte Studio on 27/11/2025.
//

import Foundation

struct AdConfig {
    // Google AdMob Real App ID
    static let adAppId = "ca-app-pub-9844943887550892~6872640469"
    
    // Banner Ad IDs
    static var bannerSplash: String {
        #if DEBUG
        return "ca-app-pub-3940256099942544/2934735716" // Test banner
        #else
        return "ca-app-pub-9844943887550892/5632437338"
        #endif
    }
    static var bannerHome: String {
        #if DEBUG
        return "ca-app-pub-3940256099942544/2934735716" // Test banner
        #else
        return "ca-app-pub-9844943887550892/3871072600"
        #endif
    }
    static var bannerOnboarding: String {
        #if DEBUG
        return "ca-app-pub-3940256099942544/2934735716" // Test banner
        #else
        return "ca-app-pub-9844943887550892/1244909266"
        #endif
    }
    
    // Interstitial Ad IDs
    static var interstitialSplash: String {
        #if DEBUG
        return "ca-app-pub-3940256099942544/1033173712" // Test interstitial
        #else
        return "ca-app-pub-9844943887550892/4319355669"
        #endif
    }
    static var interstitial: String {
        #if DEBUG
        return "ca-app-pub-3940256099942544/4411468910" // Test interstitial
        #else
        return "ca-app-pub-9844943887550892/5559558792"
        #endif
    }
    
    // Native Ad IDs
    static var nativeAd: String {
        #if DEBUG
        return "ca-app-pub-3940256099942544/3986624511" // Test native
        #else
        return "ca-app-pub-9844943887550892/4992582581"
        #endif
    }
    static var nativeOnboarding: String {
        #if DEBUG
        return "ca-app-pub-3940256099942544/3986624511" // Test native
        #else
        return "ca-app-pub-9844943887550892/4992582581"
        #endif
    }
    static var nativeLanguage: String {
        #if DEBUG
        return "ca-app-pub-3940256099942544/3986624511" // Test native
        #else
        return "ca-app-pub-9844943887550892/3679500913"
        #endif
    }
    static var nativeHome: String {
        #if DEBUG
        return "ca-app-pub-3940256099942544/3986624511" // Test native
        #else
        return "ca-app-pub-9844943887550892/7618745928"
        #endif
    }
    static var nativeModelView: String {
        #if DEBUG
        return "ca-app-pub-3940256099942544/3986624511" // Test native
        #else
        return "ca-app-pub-9844943887550892/4992582581"
        #endif
    }
    
    // App Open Ad ID
    static let appOpen = "ca-app-pub-9844943887550892/5412945488"
    
    // Rewarded Ad ID (keeping test ID for now as not provided)
    static let rewarded = "ca-app-pub-3940256099942544/1712485313" // Test Rewarded ID
}


