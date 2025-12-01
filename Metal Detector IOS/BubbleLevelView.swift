//
//  BubbleLevelView.swift
//  Metal Detector IOS
//
//  Created by Lowbyte Studio on 27/11/2025.
//

import SwiftUI
import CoreMotion
import Combine

struct BubbleLevelView: View {
    var onBackTap: () -> Void
    @StateObject private var localizationManager = LocalizationManager.shared
    @StateObject private var motionManager = MotionManager()
    
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
                    
                    Text(LocalizedString.bubbleLevelView.localized)
                        .font(.custom("Zodiak", size: 20))
                        .foregroundColor(.white)
                        .id(localizationManager.currentLanguage)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
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
                
                Spacer()
                
                // Level Indicators Container
                ZStack {
                    // Horizontal Bar Level (Top)
                    HStack {
                        VStack {
                            // Horizontal Level Bar
                            ZStack {
                                // Green gradient background from assets
                                Image("Bubble Level Horizontal")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 297, height: 74)
                                
                                // Bubble - moves based on X axis (roll)
                                Circle()
                                    .fill(Color.white.opacity(0.3))
                                    .stroke(Color.black.opacity(0.6), lineWidth: 0.681)
                                    .frame(width: 32, height: 32)
                                    .offset(x: motionManager.bubbleHorizontalOffset, y: 0)
                            }
                            .frame(width: 297, height: 74)
                            
                            Spacer()
                        }
                        
                        Spacer()
                    }
                    .padding(.leading, 16)
                    .padding(.top, 80)
                    
                    // Circular Level (Center-Left)
                    HStack {
                        ZStack {
                            // Circular background from assets
                            Image("Bubble Level Circular")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 259, height: 259)
                            
                            // Bubble - moves based on pitch and roll
                            Circle()
                                .fill(Color.white.opacity(0.3))
                                .stroke(Color.black.opacity(0.6), lineWidth: 0.674)
                                .frame(width: 32, height: 32)
                                .offset(x: motionManager.bubbleCircularOffsetX, y: motionManager.bubbleCircularOffsetY)
                        }
                        .padding(.leading, 16)
                        
                        Spacer()
                    }
                    
                    // Vertical Bar Level (Right)
                    HStack {
                        Spacer()
                        
                        VStack {
                            // Vertical Level Bar
                            ZStack {
                                // Green gradient background from assets
                                Image("Bubble Level Vertical")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 74, height: 294)
                                
                                // Bubble - moves based on Y axis (pitch)
                                Circle()
                                    .fill(Color.white.opacity(0.3))
                                    .stroke(Color.black.opacity(0.6), lineWidth: 0.674)
                                    .frame(width: 32, height: 32)
                                    .offset(x: 0, y: motionManager.bubbleVerticalOffset)
                            }
                            .frame(width: 74, height: 294)
                            
                            Spacer()
                        }
                        .padding(.trailing, 16)
                        .padding(.top, 120)
                    }
                }
                
                Spacer()
                
                // Information Cards
                HStack(spacing: 12) {
                    // Card 1 - X axis
                    InfoCard(value: String(format: "%.1f°X", motionManager.angleX))
                    
                    // Card 2 - Y axis
                    InfoCard(value: String(format: "%.0f°Y", motionManager.angleY))
                    
                    // Card 3 - Z axis
                    InfoCard(value: String(format: "%.0f°Z", motionManager.angleZ))
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            motionManager.startMotionUpdates()
        }
        .onDisappear {
            motionManager.stopMotionUpdates()
        }
    }
}


class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    @Published var angleX: Double = 33.3
    @Published var angleY: Double = 260
    @Published var angleZ: Double = 300
    
    // Bubble offsets
    @Published var bubbleHorizontalOffset: CGFloat = 0  // X axis (roll)
    @Published var bubbleVerticalOffset: CGFloat = 0    // Y axis (pitch)
    @Published var bubbleCircularOffsetX: CGFloat = 0   // Circular X
    @Published var bubbleCircularOffsetY: CGFloat = 0   // Circular Y
    
    // Maximum offsets (half the range where bubble can move)
    private let maxHorizontalOffset: CGFloat = 110
    private let maxVerticalOffset: CGFloat = 120
    private let maxCircularOffset: CGFloat = 100
    
    func startMotionUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (motion, error) in
                guard let self = self, let motion = motion else { return }
                
                // Get attitude angles
                let attitude = motion.attitude
                
                // Convert to degrees
                let roll = attitude.roll * 180.0 / .pi  // X axis
                let pitch = attitude.pitch * 180.0 / .pi  // Y axis
                let yaw = attitude.yaw * 180.0 / .pi  // Z axis
                
                // Update angles
                DispatchQueue.main.async {
                    self.angleX = roll
                    self.angleY = pitch
                    self.angleZ = yaw
                    
                    // Update bubble positions
                    // Clamp values to reasonable range (-30 to 30 degrees for bubble movement)
                    let clampedRoll = max(-30, min(30, roll))
                    let clampedPitch = max(-30, min(30, pitch))
                    
                    // Map angles to bubble offsets
                    self.bubbleHorizontalOffset = CGFloat(clampedRoll / 30.0) * self.maxHorizontalOffset
                    self.bubbleVerticalOffset = CGFloat(clampedPitch / 30.0) * self.maxVerticalOffset
                    
                    // Circular bubble uses both roll and pitch
                    self.bubbleCircularOffsetX = CGFloat(clampedRoll / 30.0) * self.maxCircularOffset
                    self.bubbleCircularOffsetY = CGFloat(clampedPitch / 30.0) * self.maxCircularOffset
                }
            }
        }
    }
    
    func stopMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
}

#Preview {
    BubbleLevelView(onBackTap: {})
}
