//
//  DetectorView.swift
//  Metal Detector IOS
//
//  Created by Lowbyte Studio on 27/11/2025.
//

import SwiftUI
import Lottie

struct DetectorView: View {
    let detectorTitle: String
    var onBackTap: () -> Void
    @StateObject private var detectorManager = MetalDetectorManager.shared
    var onMeterViewTap: (() -> Void)? = nil
    var onGraphViewTap: (() -> Void)? = nil
    var onDigitalViewTap: (() -> Void)? = nil
    var onSensorViewTap: (() -> Void)? = nil
    var onCalibrationViewTap: (() -> Void)? = nil
    var onMagneticViewTap: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            ScrollView {
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
                        
                        Text(detectorTitle)
                            .font(.system(size: 24, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 32)
                    
                    // Grid of View Cards
                    VStack(spacing: 12) {
                        // Row 1
                        HStack(spacing: 12) {
                            // Meter View
                            ViewCard(
                                backgroundImageName: "Meter View Background",
                                title: "Meter view",
                                lottieName: "meter",
                                onTap: {
                                    onMeterViewTap?()
                                }
                            )
                            
                            // Graph View
                            ViewCard(
                                backgroundImageName: "Graph View Background",
                                title: "Graph view",
                                lottieName: "Graph Lottie Animation",
                                onTap: {
                                    onGraphViewTap?()
                                }
                            )
                        }
                        
                        // Row 2
                        HStack(spacing: 12) {
                            // Digital View
                            ViewCard(
                                backgroundImageName: "Digital View Background",
                                title: "Digital view",
                                lottieName: "Animated compass",
                                onTap: {
                                    onDigitalViewTap?()
                                }
                            )
                            
                            // Sensor View
                            ViewCard(
                                backgroundImageName: "Sensor View Background",
                                title: "Sensor view",
                                lottieName: "sensor",
                                onTap: {
                                    onSensorViewTap?()
                                }
                            )
                        }
                        
                        // Row 3
                        HStack(spacing: 12) {
                            // Calibration View
                            ViewCard(
                                backgroundImageName: "Calibration View Background",
                                title: "Calibration view",
                                lottieName: "Weighing Scale",
                                onTap: {
                                    onCalibrationViewTap?()
                                }
                            )
                            
                            // Magnetic View
                            ViewCard(
                                backgroundImageName: "Magnetic View Background",
                                title: "Magnetic view",
                                lottieName: "Magnet",
                                onTap: {
                                    onMagneticViewTap?()
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .onAppear {
            // Set detection mode based on detector title
            detectorManager.setMode(for: detectorTitle)
        }
        // Don't auto-start detection here - let individual views handle it
    }
}

struct ViewCard: View {
    let backgroundImageName: String
    let title: String
    let lottieName: String
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
            onTap?()
        }) {
            ZStack {
                // Background Image from assets
                Image(backgroundImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 184, height: 198)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 40)
                    
                    // Lottie Animation
                    if !lottieName.isEmpty {
                        LottieView(animation: .named(lottieName))
                            .playing(loopMode: .loop)
                            .frame(width: 92, height: 92)
                            .background(Color.clear)
                    } else {
                        // Placeholder
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: 92, height: 92)
                    }
                    
                    Spacer()
                    
                    // Title Text
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .tracking(-0.48)
                        .padding(.bottom, 16)
                }
                .frame(width: 184, height: 198)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    DetectorView(detectorTitle: "Gold detector", onBackTap: {})
}

