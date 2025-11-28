//
//  SettingsView.swift
//  Metal Detector IOS
//
//  Created by Lowbyte Studio on 27/11/2025.
//

import SwiftUI

struct SettingsView: View {
    @State private var rotationAngle: Double = 0
    var onBackTap: () -> Void
    var onGetPremiumTap: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.07, green: 0.07, blue: 0.07) // #111112
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
                        
                        Text("Setting")
                            .font(.system(size: 24, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 30)
                    .padding(.bottom, 24)
                    
                    // Premium Card
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(red: 0.17, green: 0.17, blue: 0.17)) // #2b2b2b
                            .frame(height: 168)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Metal Detector")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("Detect hidden treasures faster with Premium mode")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                                    .lineLimit(3)
                                
                                // Get Premium Button
                                Button(action: {
                                    onGetPremiumTap?()
                                }) {
                                    ZStack {
                                        // Background from assets
                                        Image("Get Premium Button Background")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 130, height: 44)
                                            .clipShape(RoundedRectangle(cornerRadius: 18.76))
                                        
                                        HStack(spacing: 4) {
                                            Image("VIP Icon")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 18, height: 18)
                                            
                                            Text("Get Premium")
                                                .font(.system(size: 12.94, weight: .semibold))
                                                .foregroundColor(.black)
                                                
                                                .tracking(-0.78)
                                        }
                                    }
                                    .frame(width: 130, height: 44)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 24)
                            
                            Spacer()
                            
                            // Premium Image with rotation animation
                            Image("Premium Image")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 160, height: 160)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .rotationEffect(.degrees(rotationAngle))
                                .padding(.trailing, 20)
                                .onAppear {
                                    withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                                        rotationAngle = 360
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                    
                    // Settings List Card
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(red: 0.17, green: 0.17, blue: 0.17)) // #2b2b2b
                            .frame(height: 264)
                        
                        VStack(spacing: 0) {
                            // Language
                            SettingsRow(
                                iconName: "Language Icon",
                                title: "Language",
                                rightText: "Default"
                            )
                            
                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.horizontal, 20)
                            
                            // Share
                            SettingsRow(
                                iconName: "Share Icon",
                                title: "Share"
                            )
                            
                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.horizontal, 20)
                            
                            // Rate
                            SettingsRow(
                                iconName: "Rate Icon",
                                title: "Rate"
                            )
                            
                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.horizontal, 20)
                            
                            // Privacy Policy
                            SettingsRow(
                                iconName: "Privacy Icon",
                                title: "Privacy policy"
                            )
                            
                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.horizontal, 20)
                            
                            // Terms of Use
                            SettingsRow(
                                iconName: "Terms Icon",
                                title: "Terms of use"
                            )
                        }
                        .padding(.vertical, 24)
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
    }
}

struct SettingsRow: View {
    let iconName: String
    let title: String
    var rightText: String? = nil
    
    var body: some View {
        Button(action: {
            // Handle row tap
        }) {
            HStack {
                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                if let rightText = rightText {
                    Text(rightText)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SettingsView(onBackTap: {})
}

