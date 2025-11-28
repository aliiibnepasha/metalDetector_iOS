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
                    
                    Text("Meter view")
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Sound Button
                    Button(action: {
                        soundEnabled.toggle()
                        detectorManager.setSoundEnabled(soundEnabled)
                    }) {
                        ZStack {
                            Image("Pro Button Background")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                            
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
                            Image("Pro Button Background")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                            
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
                ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
                    // Meter Image (Min to Max scale)
                    Image("Meter") // User will provide this asset name
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 350)
                    
                    // Needle Image - Fixed pivot point (circle), only tip rotates
                    // Position needle so pivot (circle) stays fixed at meter's bottom center
                    Image("Meter Needle") // User will provide this asset name
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        // Rotate around the fixed anchor point - this keeps pivot stationary
                        // Anchor (0.3, 0.3) = pivot circle location in needle image
                        .rotationEffect(
                            .degrees(detectorManager.getMeterNeedleRotation()),
                            anchor: UnitPoint(x: 0.3, y: 0.3)
                        )
                        .animation(.easeOut(duration: 0.2), value: detectorManager.getMeterNeedleRotation())
                        // Position anchor point at bottom center of meter
                        // Anchor at (0.3, 0.3) in 100x100 image = 30px from top-left
                        // Image center = (50, 50), anchor offset = (30-50, 30-50) = (-20, -20)
                        // With bottom alignment, offset to align anchor at bottom center
                        .offset(y: -20) // Move up to align anchor point (circle pivot) at bottom center
                    // Note: Starting rotation is -170 degrees (MIN position, left side)
                    // Needle tip starts at MIN segment end when detection level = 0
                    // Range: -170 (MIN) to 90 (MAX) degrees (260 degrees total range)
                    // The circular pivot point (anchor 0.3, 0.3) stays FIXED at meter's bottom center
                    // Only the narrow needle tip rotates around this fixed pivot point
                }
                .frame(maxWidth: .infinity)
                .frame(height: 350)
                .padding(.horizontal, 30)
                .padding(.top, 40)
                
                // Detection Status Text
                VStack(spacing: 12) {
                    Text("No Gold detected,")
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                    
                    Text("Please check thoroughly")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
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

