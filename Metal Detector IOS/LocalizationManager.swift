//
//  LocalizationManager.swift
//  Metal Detector IOS
//
//  Created by Lowbyte Studio on 27/11/2025.
//

import Foundation
import Combine

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: String = "en" // Default to English
    
    private var bundle: Bundle = Bundle.main
    
    private init() {
        // Load saved language preference
        if let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") {
            setLanguage(savedLanguage)
        } else {
            // Use device language or default to English
            currentLanguage = Bundle.main.preferredLocalizations.first ?? "en"
            setLanguage(currentLanguage)
        }
    }
    
    // MARK: - Set Language
    func setLanguage(_ languageCode: String) {
        currentLanguage = languageCode
        UserDefaults.standard.set(languageCode, forKey: "selectedLanguage")
        UserDefaults.standard.synchronize()
        
        // Find the bundle for the language
        if let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            self.bundle = bundle
        } else {
            // Fallback to main bundle
            self.bundle = Bundle.main
        }
        
        // Post notification for views to update
        NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: nil)
    }
    
    // MARK: - Get Localized String
    func localizedString(_ key: String, comment: String = "") -> String {
        // Get localized string from current bundle
        var localizedValue = NSLocalizedString(key, bundle: bundle, comment: comment)
        
        // If translation is missing (returns the key itself), try English fallback
        if localizedValue == key && bundle != Bundle.main {
            // Try to get from main bundle (English)
            if let englishPath = Bundle.main.path(forResource: "en", ofType: "lproj"),
               let englishBundle = Bundle(path: englishPath) {
                localizedValue = NSLocalizedString(key, bundle: englishBundle, comment: comment)
            } else {
                // Fallback to main bundle
                localizedValue = NSLocalizedString(key, bundle: Bundle.main, comment: comment)
            }
        }
        
        // If still returns key, replace underscores with spaces and fix common issues
        if localizedValue == key {
            localizedValue = key.replacingOccurrences(of: "_", with: " ")
                .replacingOccurrences(of: "24 7", with: "24/7") // Fix "24 7" to "24/7"
                .replacingOccurrences(of: "whats", with: "what's") // Fix "whats" to "what's"
            
            // Capitalize properly - first letter uppercase, rest lowercase for each word
            let words = localizedValue.components(separatedBy: " ")
            localizedValue = words.map { word in
                guard !word.isEmpty else { return word }
                return word.prefix(1).uppercased() + word.dropFirst().lowercased()
            }.joined(separator: " ")
        }
        
        return localizedValue
    }
    
    // MARK: - Language Code Mapping
    // Map language names from LanguageView to language codes
    func languageCode(for languageName: String) -> String {
        switch languageName.lowercased() {
        case "english": return "en"
        case "francias": return "fr"
        case "polski": return "pl"
        case "vietnamese": return "vi"
        case "china": return "zh-Hans" // Simplified Chinese
        case "hongkong": return "zh-Hant" // Traditional Chinese
        case "indonesia": return "id"
        case "deutsh": return "de"
        case "espanol": return "es"
        case "italiano": return "it"
        case "portugues": return "pt"
        case "turkce": return "tr"
        case "japan": return "ja"
        case "korean": return "ko"
        case "thailand": return "th"
        case "arabic": return "ar"
        case "hindi": return "hi"
        case "philipino": return "fil"
        case "malay": return "ms"
        default: return "en"
        }
    }
    
    func languageName(for code: String) -> String {
        switch code {
        case "en": return "english"
        case "fr": return "francias"
        case "pl": return "polski"
        case "vi": return "vietnamese"
        case "zh-Hans": return "China"
        case "zh-Hant": return "Hongkong"
        case "id": return "indonesia"
        case "de": return "Deutsh"
        case "es": return "espanol"
        case "it": return "italiano"
        case "pt": return "portugues"
        case "tr": return "turkce"
        case "ja": return "japan"
        case "ko": return "korean"
        case "th": return "thailand"
        case "ar": return "Arabic"
        case "hi": return "Hindi"
        case "fil": return "Philipino"
        case "ms": return "malay"
        default: return "english"
        }
    }
}

// MARK: - Localized String Helper
extension String {
    var localized: String {
        return LocalizationManager.shared.localizedString(self)
    }
}

// MARK: - Predefined Localized Keys
struct LocalizedString {
    // Home Screen
    static let metalDetector = "metal_detector"
    static let goldDetector = "gold_detector"
    static let studFinder = "stud_finder"
    static let handledDetector = "handled_detector"
    static let digitalCompass = "digital_compass"
    static let bubbleLevel = "bubble_level"
    
    // Settings
    static let setting = "setting"
    static let language = "language"
    static let share = "share"
    static let rate = "rate"
    static let privacyPolicy = "privacy_policy"
    static let termsOfUse = "terms_of_use"
    static let defaultLabel = "default"
    
    // Language Screen
    static let selectYourLanguage = "select_your_language"
    static let done = "done"
    
    // Detector Views
    static let meterView = "meter_view"
    static let graphView = "graph_view"
    static let digitalView = "digital_view"
    static let sensorView = "sensor_view"
    static let calibrationView = "calibration_view"
    static let magneticView = "magnetic_view"
    static let handledDetectorView = "handled_detector"
    static let compassDetectorView = "compass_detector"
    static let bubbleLevelView = "bubble_level"
    
    // Common
    static let noGoldDetected = "no_gold_detected"
    static let pleaseCheckThoroughly = "please_check_thoroughly"
    static let startDetection = "start_detection"
    static let stopDetection = "stop_detection"
    
    // Paywall
    static let premium = "premium"
    static let goPremium = "go_premium"
    static let getPremium = "get_premium"
    static let continueFree = "continue_free"
    static let orContinueForFree = "or_continue_for_free"
    static let goPremiumFor6DollarsMonth = "go_premium_for_6_dollars_month"
    static let whatsIncluded = "whats_included"
    static let removeAds = "remove_ads"
    static let unlimitedScanning = "unlimited_scanning"
    static let ultraAccurateDetection = "ultra_accurate_detection"
    static let goldPreciousMetalScanner = "gold_precious_metal_scanner"
    static let helpSupport24_7 = "24_7_help_support"
    static let detectHiddenTreasuresFaster = "detect_hidden_treasures_faster"
    
    // Intro
    static let next = "next"
    static let skip = "skip"
    static let getStarted = "get_started"
    static let metalDetectorGoldFinder = "metal_detector_gold_finder"
    static let detectMetalAccessoriesGold = "detect_metal_accessories_gold"
    static let goldMetalSensitivityGauge = "gold_metal_sensitivity_gauge"
    static let monitorLiveSensorCurves = "monitor_live_sensor_curves"
    static let theSmartWayToFindNorth = "the_smart_way_to_find_north"
    static let guidedByPrecision = "guided_by_precision"
    
    // Splash Screen
    static let metalDetectorPro = "metal_detector_pro"
    static let loading = "loading"
}

