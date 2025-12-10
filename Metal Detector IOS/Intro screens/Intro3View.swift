//
//  Intro3View.swift
//  Metal Detector IOS
//
//  Created by Lowbyte Studio on 27/11/2025.
//

import SwiftUI

struct Intro3View: View {
    var onGetStarted: () -> Void
    var onSkip: () -> Void
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        ZStack {
            // Black background
            Color.black
                .ignoresSafeArea()
            
            // Phone Image (positioned at top)
            VStack(alignment: .center) {
                Image("415845897_8f37c68b-d006-49d8-9c53-8e9483be02fe 1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 690)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.top, 20)
            
            // Gradient Overlay at bottom
            VStack {
                Spacer()
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color.black.opacity(0), location: 0),
                        .init(color: Color.black.opacity(0.86), location: 0.51),
                        .init(color: Color.black, location: 1)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 296)
            }
            
            // Content Section (bottom)
            VStack {
                Spacer()
                
                VStack(spacing: 24) {
                    // Title and Description
                    VStack(spacing: 14.76) {
                        Text(LocalizedString.theSmartWayToFindNorth.localized)
                            .font(.custom("Zodiak", size: 38))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .id(localizationManager.currentLanguage)
                            
                        
                        Text(LocalizedString.guidedByPrecision.localized)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .frame(width: 241)
                            .id(localizationManager.currentLanguage)
                    }
                    
                    // Pagination Dots (third one is active)
                    HStack(spacing: 9.76) {
                        Circle()
                            .fill(Color(red: 0.17, green: 0.17, blue: 0.17))
                            .frame(width: 10, height: 10)
                        
                        Circle()
                            .fill(Color(red: 0.17, green: 0.17, blue: 0.17))
                            .frame(width: 10, height: 10)
                        
                        Circle()
                            .fill(Color(red: 0.9, green: 0.7, blue: 0.13))
                            .frame(width: 10, height: 10)
                    }
                    
                    // Get Started Button
                    Button(action: {
                        onGetStarted()
                    }) {
                        ZStack {
                            // Button background from assets (same as paywall)
                            Image("Go Premium Button Background")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 275, height: 44)
                                .clipShape(RoundedRectangle(cornerRadius: 18.76))
                            
                            // Button text
                            Text(LocalizedString.getStarted.localized)
                                .font(.custom("Manrope_Bold", size: 16))
                                .foregroundColor(.black)
                                .tracking(-0.8)
                                .id(localizationManager.currentLanguage)
                        }
                    }
                }
                .padding(.bottom, 40)
                .padding(.horizontal, 36)
            }
            
            // Skip Button (top right)
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        onSkip()
                    }) {
                        Text(LocalizedString.skip.localized)
                            .font(.custom("Manrope_Bold", size: 14))
                            .foregroundColor(.white.opacity(0.6))
                            .textCase(.lowercase)
                            .id(localizationManager.currentLanguage)
                    }
                    .padding(.trailing, 34)
                    .padding(.top, 10)
                }
                Spacer()
            }
        }
    }
}

#Preview {
    Intro3View(onGetStarted: {}, onSkip: {})
}

