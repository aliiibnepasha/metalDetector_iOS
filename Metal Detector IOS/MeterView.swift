//
//  MeterView.swift
//  Metal Detector IOS
//
//  Created by Lowbyte Studio on 27/11/2025.
//

import SwiftUI

struct MeterView: View {
    var onBackTap: () -> Void
    @State private var needleRotation: Double = -90 // Start at MIN position (left side)
    
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
                
                // Meter Container
                ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
                    // Meter Image (Min to Max scale)
                    Image("Meter") // User will provide this asset name
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 350)
                    
                    // Needle Image (will be rotated later based on detection)
                    // Needle is smaller - roughly 2/3 of meter radius
                    // Circular pivot point should be exactly at bottom center of meter
                    Image("Meter Needle") // User will provide this asset name
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(needleRotation), anchor: UnitPoint(x: 0.13, y: 0.11))
                    // Note: Needle rotation starts at -90 degrees (MIN position, left side)
                    // Later rotation will be updated based on detection logic
                    // Range: -90 (MIN) to 90 (MAX) degrees
                    // The circular pivot point at bottom center stays fixed, only needle tip rotates
                    // ZStack bottom alignment ensures pivot point aligns with meter's bottom center
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
                                Text("41")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("µT")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }
                    )
                    .padding(.top, 24)
                
                // Axis Detection Cards
                HStack(spacing: 12) {
                    // X-axis Card
                    AxisCard(title: "X-axis", value: "18")
                    
                    // Y-axis Card
                    AxisCard(title: "Y-axis", value: "28")
                    
                    // Z-axis Card
                    AxisCard(title: "Z-axis", value: "38")
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
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

