//
//  DigitalView.swift
//  Metal Detector IOS
//
//  Created by Lowbyte Studio on 27/11/2025.
//

import SwiftUI

struct DigitalView: View {
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
                        // Log backpress event
                        let detectorPrefix = getDetectorPrefix()
                        if !detectorPrefix.isEmpty {
                            FirebaseManager.logEvent("\(detectorPrefix)_digital_view_ui_backpress")
                        }
                        onBackTap()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }
                    
                    Text(LocalizedString.digitalView.localized)
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
                            let eventName = soundEnabled ? "\(detectorPrefix)_digital_view_sound" : "\(detectorPrefix)_digital_view_silent"
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
                            let eventName = vibrationEnabled ? "\(detectorPrefix)_digital_view_vibrate_on" : "\(detectorPrefix)_digital_view_vibrate_off"
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
                
                // Digital Meter Container
                ZStack {
                    // Large circular gauge with hexagon pattern and numbers
                    Image("Digital Meter Background") // User will provide this asset name
                        .resizable()
                        .scaledToFit()
                        .frame(width: 290, height: 290)
                    
                    // Top rotatable needle (smaller circle with triangle pointer at TOP of meter)
                    // This rotates to indicate values on the main gauge below
                    GeometryReader { geometry in
                        Image("Digital Meter Needle") // User will provide this asset name
                            .resizable()
                            .scaledToFit()
                            .frame(width: 130, height: 130)
                            // Rotate needle: starting at 0 position (5 o'clock / right side of meter)
                            // Pivot point fixed at center of the circle in needle image so only needle rotates, not the circle
                            .rotationEffect(
                                .degrees(detectorManager.getDigitalMeterNeedleRotation() - 150), // -150 to align needle tip with 0 position (5 o'clock), then rotate 0-330 degrees clockwise
                                anchor: UnitPoint(x: 0.49, y: 0.56) // Fixed pivot at center of circle in needle image
                            )
                            // Position needle so pivot point (center of circle) aligns with meter center
                            // Anchor (0.5, 0.7) in 130x130 image = (65, 91) from top-left
                            // To fix anchor at meter center (145, 145), position center at: (145-0, 145-6) = (145, 139)
                            .position(
                                x: geometry.size.width / 2, // Center X
                                y: geometry.size.height / 2 - 6 // Center Y - offset to align pivot (adjust if needed)
                            )
                            .animation(.easeOut(duration: 0.2), value: detectorManager.detectionLevel)
                    }
                    .frame(width: 290, height: 290)
                    
                    // Center value display (separate, inside the main gauge center)
                    ZStack {
                        // Black center circle
                        Circle()
                            .fill(Color.black)
                            .frame(width: 90, height: 90)
                            .overlay(
                                Circle()
                                    .stroke(Color(red: 0.99, green: 0.78, blue: 0.23), lineWidth: 2)
                            )
                        
                        // Value text (percentage based on detection level 0% to 100%)
                        Text("\(Int(detectorManager.detectionLevel))%")
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                            .animation(.easeOut(duration: 0.2), value: detectorManager.detectionLevel)
                    }
                    // Center circle stays at the center of the main gauge
                }
                .frame(width: 290, height: 290)
                
                // Detection Status Text (moved up closer to meter)
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
            detectorManager.setCurrentView("digital_view")
            detectorManager.startDetection()
            // Sync with detectorManager
            soundEnabled = detectorManager.soundEnabled
            vibrationEnabled = detectorManager.vibrationEnabled
            
            // Pre-load interstitial ad for future use
            adManager.loadGeneralInterstitial()
            
            // Show ad when digital view appears (only first time, not on back navigation)
            // Small delay to ensure view is fully loaded
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if adManager.isInterstitialReady {
                    adManager.showGeneralInterstitial(forView: "DigitalView") {
                        // Ad closed, continue with digital view
                        print("✅ DigitalView: Ad dismissed, digital view ready")
                    }
                }
            }
        }
        .onDisappear {
            // Log phone backpress event (system back gesture)
            let detectorPrefix = getDetectorPrefix()
            if !detectorPrefix.isEmpty {
                FirebaseManager.logEvent("\(detectorPrefix)_digital_view_phone_backpress")
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
    DigitalView(onBackTap: {})
}

