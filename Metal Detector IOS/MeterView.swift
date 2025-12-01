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
                
                // Meter Container
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
                .padding(.top, 40)
                
                // Detection Status Text
                VStack(spacing: 12) {
                    Text(detectorManager.getDetectionMessageKey().localized)
                        .font(.custom("Zodiak", size: 24))
                        .foregroundColor(.white)
                        .id(localizationManager.currentLanguage + "_" + String(detectorManager.isMetalDetected))
                    
                    if !detectorManager.isMetalDetected {
                        Text(LocalizedString.pleaseCheckThoroughly.localized)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .id(localizationManager.currentLanguage)
                    }
                }
                .padding(.top, 32)
                .opacity(detectorManager.detectionLevel > 10 ? 1.0 : 0.7)
                
                Spacer()
                
                // Total Detection Card
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
                    .padding(.top, 24)
                
                // Axis Detection Cards (These would need individual axis data from manager)
                // For now showing total field strength variations
                HStack(spacing: 12) {
                    AxisCard(title: "X-axis", value: String(format: "%.0f", detectorManager.magneticFieldStrength * 0.4))
                    AxisCard(title: "Y-axis", value: String(format: "%.0f", detectorManager.magneticFieldStrength * 0.5))
                    AxisCard(title: "Z-axis", value: String(format: "%.0f", detectorManager.magneticFieldStrength * 0.6))
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            // Start detection when view appears
            detectorManager.startDetection()
            // Sync with detectorManager
            soundEnabled = detectorManager.soundEnabled
            vibrationEnabled = detectorManager.vibrationEnabled
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

