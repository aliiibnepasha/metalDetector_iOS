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
                    
                    Text(LocalizedString.digitalView.localized)
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
                    Image("Digital Meter Needle") // User will provide this asset name
                        .resizable()
                        .scaledToFit()
                        .frame(width: 130, height:130)
                        .rotationEffect(.degrees(detectorManager.getMeterNeedleRotation() + 90), anchor: .bottom)
                        .offset(x: 1, y: -12) // Position at top of the meter circle, slightly to the right
                        .animation(.easeOut(duration: 0.2), value: detectorManager.detectionLevel)
                    
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
                        
                        // Value text (percentage/reading)
                        Text(String(format: "%.1f", detectorManager.magneticFieldStrength))
                            .font(.system(size: 36, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                    }
                    // Center circle stays at the center of the main gauge
                }
                .frame(width: 290, height: 290)
                
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
    DigitalView(onBackTap: {})
}

