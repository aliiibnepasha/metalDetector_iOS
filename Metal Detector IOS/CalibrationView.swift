//
//  CalibrationView.swift
//  Metal Detector IOS
//
//  Created by Lowbyte Studio on 27/11/2025.
//

import SwiftUI

struct CalibrationView: View {
    var onBackTap: () -> Void
    @State private var calibrationValue: Double = 0.0 // Current calibration value (0-100)
    @State private var needleRotation: Double = -90.0 // Needle rotation angle (starting from left)
    
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
                    
                    Text("Calibration view")
                        .font(.system(size: 23, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Sound Button
                    Button(action: {
                        // Handle sound action
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
                        // Handle vibration action
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
                .padding(.bottom, 16)
                
                Spacer()
                
                // Calibration Meter Container
                ZStack {
                    // Meter Background with tick marks (from assets)
                    Image("Calibration Meter Background") // User will provide this asset name
                        .resizable()
                        .scaledToFit()
                        .frame(width: 310, height: 310)
                    
                    // Rotatable Needle (from assets)
                    Image("Calibration Meter Needle") // User will provide this asset name
                        .resizable()
                        .scaledToFit()
                        .frame(width: 110, height: 90) // Based on image dimensions
                        .rotationEffect(.degrees(needleRotation), anchor: UnitPoint(x: 0.4, y: 0.6))
                    // Needle rotates around bottom center point to indicate values on meter
                }
                .frame(width: 310, height: 310)
                
                Spacer()
                
                // Detection Status Text
                VStack(spacing: 12) {
                    Text("No Gold detected,")
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                    
                    Text("Please check thoroughly")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.top, 16)
                
                Spacer()
                
                Spacer()
                    .frame(height: 40)
            }
        }
        .onAppear {
            // Update needle rotation based on calibration value
            updateNeedleRotation()
        }
        .onChange(of: calibrationValue) { _ in
            // Update needle rotation when calibration value changes
            updateNeedleRotation()
        }
    }
    
    // Update needle rotation based on calibration value (0-100 maps to -90 to 90 degrees)
    private func updateNeedleRotation() {
        // Map calibration value (0-100) to rotation angle
        // For semi-circular meter: -90 (left/min) to 90 (right/max)
        let normalizedValue = min(100, max(0, calibrationValue))
        needleRotation = -90 + (normalizedValue / 100.0) * 180.0
    }
}

#Preview {
    CalibrationView(onBackTap: {})
}

