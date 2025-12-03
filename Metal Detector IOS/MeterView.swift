//
//  MeterView.swift
//  Metal Detector IOS
//
//  Created by Lowbyte Studio on 27/11/2025.
//

import SwiftUI

struct MeterView: View {
    var onBackTap: () -> Void
    @StateObject private var detectorManager = MetalDetectorManager.shared
    @StateObject private var localizationManager = LocalizationManager.shared
    @StateObject private var adManager = AdManager.shared
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
                        onBackTap()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }
                    
                    Text(LocalizedString.meterView.localized)
                        .font(.custom("Zodiak", size: 24))
                        .foregroundColor(.white)
                        .id(localizationManager.currentLanguage)
                    
                    Spacer()
                    
                    // Sound Button
                    Button(action: {
                        soundEnabled.toggle()
                        detectorManager.setSoundEnabled(soundEnabled)
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
                
                // Meter Container (moved up)
                GeometryReader { geometry in
                    ZStack {
                        // Meter Image (Min to Max scale)
                        Image("Meter") // User will provide this asset name
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .frame(height: 350)
                            // Overlay needle directly on meter at exact pivot position
                            .overlay(
                                Image("Meter Needle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .rotationEffect(
                                        .degrees(detectorManager.getMeterNeedleRotation()),
                                        anchor: UnitPoint(x: 0.26, y: 0.47)   // EXACT PIVOT
                                    )
                                    .offset(x: 11, y: -38)  // adjust left-right as needed
                                    .animation(.easeOut(duration: 0.2), value: detectorManager.getMeterNeedleRotation()),
                                alignment: .bottom
                            )



                        // CIRCLE PIVOT: Fixed at meter bottom center (X: center, Y: bottom)
                        // NARROW TIP: Rotates around fixed circle pivot
                        // Range: -170 (MIN) to 90 (MAX) degrees (260 degrees total)
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(height: 350)
                .padding(.horizontal, 30)
                .padding(.top, 10) // Further reduced to move meter up more
                
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
                .padding(.top, -19) // Even more reduced to move closer to meter
                .opacity(detectorManager.detectionLevel > 10 ? 1.0 : 0.7)
                
                // Total Detection Card (moved up)
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 43/255, green: 43/255, blue: 43/255))
                    .frame(width: 380, height: 80)
                    .overlay(
                        VStack(spacing: 4) {
                            Text("Total detection")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                            
                            HStack(spacing: 2) {
                                Text(String(format: "%.0f", detectorManager.magneticFieldStrength))
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("µT")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }
                    )
                    .padding(.top, 4) // Even more reduced to move closer to detection text
                
                // Axis Detection Cards (moved up closer to Total Detection Card)
                HStack(spacing: 12) {
                    AxisCard(title: "X-axis", value: String(format: "%.0f", detectorManager.magneticFieldStrength * 0.4))
                    AxisCard(title: "Y-axis", value: String(format: "%.0f", detectorManager.magneticFieldStrength * 0.5))
                    AxisCard(title: "Z-axis", value: String(format: "%.0f", detectorManager.magneticFieldStrength * 0.6))
                }
                .padding(.horizontal, 16)
                .padding(.top, 8) // Reduced from 12 to move closer to Total Detection Card
                .padding(.bottom, 24)
                
                Spacer() // Keep spacer at bottom for ad spacing
            }
            
            // Bottom Native Ad (Fixed at bottom, doesn't scroll)
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
        .onAppear {
            // Start detection when view appears
            detectorManager.startDetection()
            // Sync with detectorManager
            soundEnabled = detectorManager.soundEnabled
            vibrationEnabled = detectorManager.vibrationEnabled
            
            // Pre-load interstitial ad for future use
            adManager.loadGeneralInterstitial()
            
            // Show ad when meter view appears
            // Small delay to ensure view is fully loaded
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if adManager.isInterstitialReady {
                    adManager.showGeneralInterstitial {
                        // Ad closed, continue with meter view
                        print("✅ MeterView: Ad dismissed, meter view ready")
                    }
                }
            }
        }
        .onDisappear {
            // Stop detection when leaving view
            detectorManager.stopDetection()
        }
    }
}

struct AxisCard: View {
    let title: String
    let value: String
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color(red: 43/255, green: 43/255, blue: 43/255))
            .frame(width: 118.567, height: 80)
            .overlay(
                VStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text(value)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
            )
    }
}

#Preview {
    MeterView(onBackTap: {})
}

