//
//  CalibrationView.swift
//  Metal Detector IOS
//
//  Created by Lowbyte Studio on 27/11/2025.
//

import SwiftUI

struct CalibrationView: View {
    var onBackTap: () -> Void
    @StateObject private var detectorManager = MetalDetectorManager.shared
    @StateObject private var localizationManager = LocalizationManager.shared
    @StateObject private var adManager = AdManager.shared
    @StateObject private var iapManager = IAPManager.shared
    @State private var soundEnabled = true
    @State private var vibrationEnabled = true
    @State private var isBottomAdLoading = true
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack(spacing: 6) {
                    // Back Button
                    Button(action: {
                        adManager.handleClickTriggeredInterstitial(context: "calibration_back") {
                            // Log backpress event
                            let detectorPrefix = getDetectorPrefix()
                            if !detectorPrefix.isEmpty {
                                FirebaseManager.logEvent("\(detectorPrefix)_callibration_view_ui_backpress")
                            }
                            onBackTap()
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }
                    
                    Text(LocalizedString.calibrationView.localized)
                        .font(.custom("Zodiak", size: 20))
                        .foregroundColor(.white)
                        .id(localizationManager.currentLanguage)
                    
                    Spacer()
                    
                    // Sound Button
                    Button(action: {
                        soundEnabled.toggle()
                        detectorManager.setSoundEnabled(soundEnabled)
                        // Log sound event
                        let detectorPrefix = getDetectorPrefix()
                        if !detectorPrefix.isEmpty {
                            let eventName = soundEnabled ? "\(detectorPrefix)_callibration_view_sound" : "\(detectorPrefix)_callibration_view_silent"
                            FirebaseManager.logEvent(eventName)
                        }
                    }) {
                        ZStack {
                            // Conditional background: Yellow asset when ON, Gray when OFF
                            if soundEnabled {
                                Image("Pro Button Background")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 40, height: 40)
                                    .clipShape(RoundedRectangle(cornerRadius: 30))
                            } else {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 40, height: 40)
                            }
                            
                            Image("Sound Icon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                        }
                    }
                    .padding(.trailing, 8)
                    
                    // Vibration Button
                    Button(action: {
                        vibrationEnabled.toggle()
                        detectorManager.setVibrationEnabled(vibrationEnabled)
                        // Log vibrate event
                        let detectorPrefix = getDetectorPrefix()
                        if !detectorPrefix.isEmpty {
                            let eventName = vibrationEnabled ? "\(detectorPrefix)_callibration_view_vibrate_on" : "\(detectorPrefix)_callibration_view_vibrate_off"
                            FirebaseManager.logEvent(eventName)
                        }
                    }) {
                        ZStack {
                            // Conditional background: Yellow asset when ON, Gray when OFF
                            if vibrationEnabled {
                                Image("Pro Button Background")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 40, height: 40)
                                    .clipShape(RoundedRectangle(cornerRadius: 30))
                            } else {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 40, height: 40)
                            }
                            
                            Image("Vibration Icon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                        }
                    }
                    .padding(.trailing, 16)
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                Spacer()
                
                // Calibration Meter Container
                GeometryReader { geometry in
                    ZStack {
                        // Meter Background with tick marks (from assets)
                        Image("Calibration Meter Background") // User will provide this asset name
                            .resizable()
                            .scaledToFit()
                            .frame(width: 310, height: 310)
                        
                        // Needle - Black circle pivot ABSOLUTELY FIXED at meter center
                        Image("Calibration Meter Needle") // User will provide this asset name
                            .resizable()
                            .scaledToFit()
                            .frame(width: 110, height: 90)
                            // Rotate around anchor point (black circle pivot in needle image)
                            .rotationEffect(
                                .degrees(detectorManager.getCalibrationNeedleRotation()),
                                anchor: UnitPoint(x: 0.45, y: 0.6) // Black circle pivot location - EXACT POSITION
                            )
                            .animation(.easeOut(duration: 0.2), value: detectorManager.detectionLevel)
                            // Position the anchor point at EXACT meter center (155, 155)
                            // Anchor (0.45, 0.6) in 110x90 image = (49.5, 54) from top-left
                            // Image center = (55, 45), so anchor is 5.5px left and 9px down from center
                            // To fix anchor at (155, 155), position center at: (155-5.5, 155-9) = (149.5, 146)
                            .position(
                                x: geometry.size.width / 2 - 5.5, // Center X - offset to align pivot
                                y: geometry.size.height / 2 + 9 // Center Y + offset to align pivot
                            )
                        // BLACK CIRCLE PIVOT: Absolutely fixed at (155, 155) - meter center
                        // NARROW TIP: Rotates around fixed black circle pivot
                        // Range: -170 (MIN) to 90 (MAX) degrees = 260 degrees total (full meter)
                    }
                }
                .frame(width: 310, height: 310)
                
                // Detection Status Text (moved up closer to calibration meter)
                VStack(spacing: 12) {
                    Text(detectorManager.getDetectionMessageKey().localized)
                        .font(.custom("Zodiak", size: 24))
                        .foregroundColor(.white)
                        .id(localizationManager.currentLanguage + "_" + String(detectorManager.isMetalDetected))
                    
                    Text(detectorManager.getSubtitleMessageKey().localized)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .id(localizationManager.currentLanguage + "_subtitle_" + String(detectorManager.isMetalDetected))
                }
                .padding(.top, 24) // Reduced gap between meter and text
                
                Spacer()
            }
            
            // Bottom Native Ad (Fixed at bottom, doesn't scroll) - Only show if not premium
            if !iapManager.isPremium {
                VStack {
                    Spacer()
                    
                    ZStack {
                        // Shimmer effect while ad is loading
                        if isBottomAdLoading {
                            AdShimmerView()
                                .frame(height: 100)
                                .padding(.horizontal, 16)
                        }
                        
                        // Actual native ad
                        NativeAdView(adUnitID: AdConfig.nativeModelView, isLoading: $isBottomAdLoading)
                            .frame(height: 100)
                            .padding(.horizontal, 16)
                            .opacity(isBottomAdLoading ? 0 : 1)
                    }
                    .padding(.bottom, 8)
                    .background(Color.black) // Ensure background matches
                }
            }
        }
        .onAppear {
            // Set current view for event logging
            detectorManager.setCurrentView("callibration_view")
            detectorManager.startDetection()
            // Sync with detectorManager
            soundEnabled = detectorManager.soundEnabled
            vibrationEnabled = detectorManager.vibrationEnabled
            
            // Pre-load interstitial ad for future use
            adManager.loadGeneralInterstitial()
            
            detectorManager.startDetection()
            // Sync with detectorManager
            soundEnabled = detectorManager.soundEnabled
            vibrationEnabled = detectorManager.vibrationEnabled
        }
        .onDisappear {
            // Log phone backpress event (system back gesture)
            let detectorPrefix = getDetectorPrefix()
            if !detectorPrefix.isEmpty {
                FirebaseManager.logEvent("\(detectorPrefix)_callibration_view_phone_backpress")
            }
            detectorManager.stopDetection()
        }
    }
    
    // MARK: - Helper Methods
    private func getDetectorPrefix() -> String {
        switch detectorManager.currentDetectorTitle.lowercased() {
        case "gold detector":
            return "gold"
        case "metal detector":
            return "metal"
        case "stud finder":
            return "stud"
        default:
            return ""
        }
    }
}

#Preview {
    CalibrationView(onBackTap: {})
}

