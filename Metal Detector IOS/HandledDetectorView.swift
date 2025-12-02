//
//  HandledDetectorView.swift
//  Metal Detector IOS
//
//  Created by Lowbyte Studio on 27/11/2025.
//

import SwiftUI

struct HandledDetectorView: View {
    var onBackTap: () -> Void
    @StateObject private var detectorManager = MetalDetectorManager.shared
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var soundEnabled = true
    @State private var vibrationEnabled = true
    @State private var shakeOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    // Back Button
                    Button(action: {
                        onBackTap()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }
                    
                    Text(LocalizedString.handledDetectorView.localized)
                        .font(.custom("Zodiak", size: 20))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .id(localizationManager.currentLanguage)
                        .minimumScaleFactor(0.8)
                    
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
                
                // Device Container with Image
                ZStack {
                    // Container Background
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(red: 43/255, green: 43/255, blue: 43/255))
                        .frame(width: 380, height: 222)
                    
                    // Device Image with Shake Animation
                    Image("Handle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 201)
                        .rotationEffect(.degrees(19.507))
                        .offset(x: shakeOffset, y: shakeOffset * 0.3)
                        .rotationEffect(.degrees(shakeOffset * 0.2))
                        .animation(
                            detectorManager.isMetalDetected
                                ? Animation.easeInOut(duration: 0.08).repeatForever(autoreverses: true)
                                : .default,
                            value: shakeOffset
                        )
                }
                .padding(.top, 32)
                
                // Status Text
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
                .padding(.top, 24)
                
                Spacer()
                
                Spacer()
                    .frame(height: 40)
            }
        }
        .onAppear {
            // Sync with detectorManager
            soundEnabled = detectorManager.soundEnabled
            vibrationEnabled = detectorManager.vibrationEnabled
            // Set mode for Handled Detector
            detectorManager.setMode(for: "Handled Detector")
            // Start detection
            detectorManager.startDetection()
        }
        .onDisappear {
            // Stop detection when view disappears
            detectorManager.stopDetection()
            shakeOffset = 0
        }
        .onChange(of: detectorManager.isMetalDetected) { isDetected in
            if isDetected {
                // Start shake animation
                withAnimation(.easeInOut(duration: 0.08).repeatForever(autoreverses: true)) {
                    shakeOffset = 5
                }
            } else {
                withAnimation {
                    shakeOffset = 0
                }
            }
        }
    }
}

// Shake Effect Modifier
struct ShakeEffect: GeometryEffect {
    var shakes: Int
    var animatableData: CGFloat {
        get { CGFloat(shakes) }
        set { shakes = Int(newValue) }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let xOffset = sin(CGFloat(shakes) * .pi * 2) * 5
        let yOffset = cos(CGFloat(shakes) * .pi * 2) * 5
        let angle = sin(CGFloat(shakes) * .pi * 4) * 3 * .pi / 180
        return ProjectionTransform(CGAffineTransform(translationX: xOffset, y: yOffset).rotated(by: angle))
    }
}

#Preview {
    HandledDetectorView(onBackTap: {})
}

