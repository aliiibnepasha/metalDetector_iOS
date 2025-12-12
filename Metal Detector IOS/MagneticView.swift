//
//  MagneticView.swift
//  Metal Detector IOS
//
//  Created by Lowbyte Studio on 27/11/2025.
//

import SwiftUI

struct MagneticView: View {
    var onBackTap: () -> Void
    @StateObject private var detectorManager = MetalDetectorManager.shared
    @StateObject private var localizationManager = LocalizationManager.shared
    @StateObject private var adManager = AdManager.shared
    @StateObject private var iapManager = IAPManager.shared
    @State private var soundEnabled = true
    @State private var vibrationEnabled = true
    @State private var isBottomAdLoading = true
    
    // Computed properties for capsule fill levels
    private var firstCapsuleFill: Double {
        // First capsule fills with green (0-33% detection)
        min(100, max(0, (detectorManager.detectionLevel / 33.0) * 100))
    }
    
    private var secondCapsuleFill: Double {
        // Second capsule fills with orange (33-66% detection)
        if detectorManager.detectionLevel < 33 {
            return 0
        } else if detectorManager.detectionLevel >= 66 {
            return 100
        } else {
            return ((detectorManager.detectionLevel - 33) / 33.0) * 100
        }
    }
    
    private var thirdCapsuleFill: Double {
        // Third capsule fills with red (66-100% detection)
        if detectorManager.detectionLevel < 66 {
            return 0
        } else {
            return ((detectorManager.detectionLevel - 66) / 34.0) * 100
        }
    }
    
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
                        adManager.handleClickTriggeredInterstitial(context: "magnetic_back") {
                            // Log backpress event
                            let detectorPrefix = getDetectorPrefix()
                            if !detectorPrefix.isEmpty {
                                FirebaseManager.logEvent("\(detectorPrefix)_magnetic_view_ui_backpress")
                            }
                            onBackTap()
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }
                    
                    Text(LocalizedString.magneticView.localized)
                        .font(.custom("Zodiak", size: 24))
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
                            let eventName = soundEnabled ? "\(detectorPrefix)_magnetic_view_sound" : "\(detectorPrefix)_magnetic_view_silent"
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
                            let eventName = vibrationEnabled ? "\(detectorPrefix)_magnetic_view_vibrate_on" : "\(detectorPrefix)_magnetic_view_vibrate_off"
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
                .padding(.bottom, 4)
                
                // Main Content Card
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 43/255, green: 43/255, blue: 43/255))
                    .frame(width: 380, height: 222)
                    .padding(.top, 4)
                    .overlay(
                        VStack(spacing: 24) {
                            // Magnetic Value Display
                            VStack(spacing: 12) {
                                HStack(alignment: .firstTextBaseline, spacing: 4) {
                                    Text("\(Int(detectorManager.magneticFieldStrength))")
                                        .font(.system(size: 54, weight: .bold, design: .serif))
                                        .foregroundColor(.white)
                                    
                                    Text("µT")
                                        .font(.system(size: 24, weight: .medium))
                                        .foregroundColor(.white)
                                }
                                
                                Text("µT: MicroTesla")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            
                            // Detection Status Text
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
                        }
                        .padding(.vertical, 32)
                    )
                    .padding(.horizontal, 16)
                
                // Capsule Indicators
                HStack(spacing: 12) {
                    // First Capsule (Green) - Wider capsule
                    ZStack(alignment: .leading) {
                        // Background capsule
                        Capsule()
                            .fill(Color(red: 43/255, green: 43/255, blue: 43/255))
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                            )
                            .frame(width: 240, height: 40)
                        
                        // Green fill
                        if firstCapsuleFill > 0 {
                            Capsule()
                                .fill(Color(red: 22/255, green: 255/255, blue: 57/255))
                                .frame(
                                    width: CGFloat(firstCapsuleFill / 100.0) * 240,
                                    height: 40
                                )
                                .animation(.easeInOut(duration: 0.3), value: firstCapsuleFill)
                        }
                    }
                    
                    // Second Capsule (Orange) - Separate capsule
                    CapsuleIndicator(
                        fillPercentage: secondCapsuleFill,
                        fillColor: Color(red: 255/255, green: 165/255, blue: 0/255), // Orange
                        isFirst: false
                    )
                    
                    // Third Capsule (Red) - Separate capsule
                    CapsuleIndicator(
                        fillPercentage: thirdCapsuleFill,
                        fillColor: Color(red: 255/255, green: 68/255, blue: 68/255), // Red
                        isFirst: false
                    )
                }
                .padding(.horizontal, 16)
                .padding(.top, 22)
                
                // Action Buttons
                HStack(spacing: 16) {
                    // Start Detection Button (Green)
                    Button(action: {
                        detectorManager.startDetection()
                    }) {
                        Text(LocalizedString.startDetection.localized)
                            .font(.custom("Manrope_Bold", size: 18))
                            .id(localizationManager.currentLanguage)
                            .foregroundColor(.black)
                            .tracking(-0.54)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(red: 131/255, green: 255/255, blue: 135/255))
                            .clipShape(RoundedRectangle(cornerRadius: 40))
                    }
                    
                    // Stop Detection Button (Red)
                    Button(action: {
                        detectorManager.stopDetection()
                    }) {
                        Text(LocalizedString.stopDetection.localized)
                            .font(.custom("Manrope_Bold", size: 18))
                            .id(localizationManager.currentLanguage)
                            .foregroundColor(.black)
                            .tracking(-0.54)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(red: 255/255, green: 136/255, blue: 136/255))
                            .clipShape(RoundedRectangle(cornerRadius: 40))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 26)
                
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
            detectorManager.setCurrentView("magnetic_view")
            // Sync with detectorManager
            soundEnabled = detectorManager.soundEnabled
            vibrationEnabled = detectorManager.vibrationEnabled
            
            // Pre-load interstitial ad for future use
            adManager.loadGeneralInterstitial()
            
            // Sync with detectorManager
            soundEnabled = detectorManager.soundEnabled
            vibrationEnabled = detectorManager.vibrationEnabled
        }
        .onDisappear {
            // Stop detection when user navigates away from this view
            detectorManager.stopDetection()
        }
        // Note: MagneticView has its own Start/Stop buttons, so no auto-start here
        // Detection starts/stops manually via buttons
        .onDisappear {
            // Log phone backpress event (system back gesture)
            let detectorPrefix = getDetectorPrefix()
            if !detectorPrefix.isEmpty {
                FirebaseManager.logEvent("\(detectorPrefix)_magnetic_view_phone_backpress")
            }
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

struct CapsuleIndicator: View {
    let fillPercentage: Double
    let fillColor: Color
    let isFirst: Bool
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Background capsule (dark gray with border)
            Capsule()
                .fill(Color(red: 43/255, green: 43/255, blue: 43/255))
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
                .frame(width: 58, height: 40)
            
            // Fill capsule (colored based on detection level)
            if fillPercentage > 0 {
                Capsule()
                    .fill(fillColor)
                    .frame(
                        width: CGFloat(fillPercentage / 100.0) * 58,
                        height: 40
                    )
                    .animation(.easeInOut(duration: 0.3), value: fillPercentage)
            }
        }
    }
}

#Preview {
    MagneticView(onBackTap: {})
}

