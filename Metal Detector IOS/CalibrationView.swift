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
    @State private var soundEnabled = true
    @State private var vibrationEnabled = true
    
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
                    
                    Text(LocalizedString.calibrationView.localized)
                        .font(.custom("Zodiak", size: 20))
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
                
                Spacer()
                
                // Detection Status Text
                VStack(spacing: 12) {
                    Text(LocalizedString.noGoldDetected.localized)
                        .font(.custom("Zodiak", size: 24))
                        .foregroundColor(.white)
                        .id(localizationManager.currentLanguage)
                    
                    Text(LocalizedString.pleaseCheckThoroughly.localized)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .id(localizationManager.currentLanguage)
                }
                .padding(.top, 16)
                
                Spacer()
                
                Spacer()
                    .frame(height: 40)
            }
        }
        .onAppear {
            detectorManager.startDetection()
            // Sync with detectorManager
            soundEnabled = detectorManager.soundEnabled
            vibrationEnabled = detectorManager.vibrationEnabled
        }
        .onDisappear {
            detectorManager.stopDetection()
        }
    }
}

#Preview {
    CalibrationView(onBackTap: {})
}

