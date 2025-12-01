//
//  HomeView.swift
//  Metal Detector IOS
//
//  Created by Lowbyte Studio on 27/11/2025.
//

import SwiftUI

struct HomeView: View {
    var onSettingsTap: () -> Void
    var onDetectorTap: (String) -> Void
    var onProTap: (() -> Void)? = nil
    @StateObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        ZStack {
            // Backgrouπnd
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text(LocalizedString.metalDetector.localized)
                        .font(.custom("Zodiak", size: 24))
                        .foregroundColor(.white)
                        .padding(.leading, 16)
                        .id(localizationManager.currentLanguage) // Force refresh on language change
                    
                    Spacer()
                    
                    // Pro Button (Crown)
                    Button(action: {
                        onProTap?()
                    }) {
                        ZStack {
                            Image("Pro Button Background")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                            
                            Image("Pro Icon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                        }
                    }
                    .padding(.trailing, 8)
                    
                    // Settings Button
                    Button(action: {
                        onSettingsTap()
                    }) {
                        ZStack {
                            Image("Setting Button Background")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                            
                            Image("Setting Icon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                        }
                    }
                    .padding(.trailing, 16)
                }
                .padding(.top, 28)
                
                // Main Content - Feature Cards
                ScrollView {
                    VStack(spacing: 12) {
                        // Gold Detector Card
                        FeatureCard(
                            backgroundImageName: "Gold Detector",
                            title: LocalizedString.goldDetector.localized,
                            onTap: {
                                onDetectorTap("Gold Detector")
                            }
                        )
                        
                        // Metal Detector Card
                        FeatureCard(
                            backgroundImageName: "Metal Detector",
                            title: LocalizedString.metalDetector.localized,
                            onTap: {
                                onDetectorTap("Metal Detector")
                            }
                        )
                        
                        // Stud Finder Card
                        FeatureCard(
                            backgroundImageName: "Stud Finder",
                            title: LocalizedString.studFinder.localized,
                            onTap: {
                                onDetectorTap("Stud Finder")
                            }
                        )
                        
                        // Handled Detector Card
                        FeatureCard(
                            backgroundImageName: "Handled Detector",
                            title: LocalizedString.handledDetector.localized,
                            onTap: {
                                onDetectorTap("Handled Detector")
                            }
                        )
                        
                        // Digital Compass Card
                        FeatureCard(
                            backgroundImageName: "Digital Compass",
                            title: LocalizedString.digitalCompass.localized,
                            onTap: {
                                onDetectorTap("Digital Compass")
                            }
                        )
                        
                        // Bubble Level Card
                        FeatureCard(
                            backgroundImageName: "Bubble level",
                            title: LocalizedString.bubbleLevel.localized,
                            onTap: {
                                onDetectorTap("Bubble level")
                            }
                        )
                    }
                    .padding(.top, 24)
                    .padding(.horizontal, 16)
                }
            }
        }
    }
}

struct FeatureCard: View {
    let backgroundImageName: String
    let title: String
    var onTap: (() -> Void)?
    
    var body: some View {
        Button(action: {
            onTap?()
        }) {
            ZStack {
                // Background Image
                Image(backgroundImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 124)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
                HStack(spacing: 0) {
                    // Left padding to avoid icon area (icon width 111 + padding 6 + spacing)
                    Spacer()
                        .frame(width: 130)
                    
                    // Text Overlay (center positioned, but with proper left padding)
                    Text(title)
                        .font(.custom("Manrope_Bold", size: 20))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                    
                    // Arrow Overlay (right side, 10px from edge)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .padding(.trailing, 10)
                }
            }
            .frame(height: 124)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HomeView(onSettingsTap: {}, onDetectorTap: { _ in })
}


