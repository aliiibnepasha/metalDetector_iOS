//
//  DigitalView.swift
//  Metal Detector IOS
//
//  Created by Lowbyte Studio on 27/11/2025.
//

import SwiftUI

struct DigitalView: View {
    var onBackTap: () -> Void
    @State private var meterValue: Double = 95.4 // Current meter reading (will be updated from sensor)
    @State private var needleRotation: Double = 90.0 // Needle rotation angle (0-360 degrees)
    
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
                    
                    Text("Digital view")
                        .font(.system(size: 24, weight: .bold, design: .serif))
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
                        .rotationEffect(.degrees(needleRotation), anchor: .bottom)
                        .offset(x: 16, y: -15) // Position at top of the meter circle, slightly to the right
                    
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
                        Text(String(format: "%.1f", meterValue))
                            .font(.system(size: 36, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                    }
                    // Center circle stays at the center of the main gauge
                }
                .frame(width: 290, height: 290)
                
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
            // Update needle rotation based on meter value
            updateNeedleRotation()
        }
        .onChange(of: meterValue) { _ in
            // Update needle rotation when meter value changes
            updateNeedleRotation()
        }
    }
    
    // Update needle rotation based on meter value (0-100 maps to 0-360 degrees)
    private func updateNeedleRotation() {
        // Map meter value (0-100) to rotation angle (0-360 degrees)
        // Adjust this mapping based on your sensor range
        let normalizedValue = min(100, max(0, meterValue))
        needleRotation = (normalizedValue / 100.0) * 360.0
    }
}

#Preview {
    DigitalView(onBackTap: {})
}

