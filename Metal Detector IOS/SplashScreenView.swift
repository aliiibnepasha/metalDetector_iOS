//
//  SplashScreenView.swift
//  Metal Detector IOS
//
//  Created by Lowbyte Studio on 27/11/2025.
//

import SwiftUI
import Lottie

struct SplashScreenView: View {
    @State private var progress: CGFloat = 0.0
    @State private var isAdLoading: Bool = true
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @ObservedObject private var adManager = AdManager.shared
    var onComplete: () -> Void
    
    var body: some View {
        ZStack {
            // Black background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Title and Loading Section
                VStack(spacing: 24) {
                    // Lottie Animation
                    LottieView(animation: .named("Digital meter Graph"))
                        .playing(loopMode: .loop)
                        .frame(width: 300, height: 300)
                    
                    // App Title
                    Text(LocalizedString.metalDetector.localized)
                        .font(.system(size: 32, weight: .semibold, design: .default))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .id(localizationManager.currentLanguage)
                    
                    // Loading Section
                    VStack(spacing: 12) {
                        // Loading Bar
                        ZStack(alignment: .leading) {
                            // Background track
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color(red: 0.11, green: 0.11, blue: 0.11))
                                .frame(width: 366, height: 12)
                            
                            // Progress bar with yellow gradient
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 1.0, green: 0.85, blue: 0.0),
                                            Color(red: 1.0, green: 0.7, blue: 0.2)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: 366 * progress, height: 8)
                                .padding(.leading, 2)
                                .padding(.vertical, 2)
                        }
                        
                        // Loading text
                        Text(LocalizedString.loading.localized)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .id(localizationManager.currentLanguage + "_splash_loading")
                    }
                }
                .padding(.bottom, 120)
                
                Spacer()
                
                // Banner Ad at bottom with shimmer effect while loading
                ZStack {
                    // Shimmer effect while ad is loading
                    if isAdLoading {
                        AdShimmerView()
                            .frame(height: 50)
                            .padding(.bottom, 20)
                    }
                    
                    // Actual banner ad
                    BannerAdView(adUnitID: AdConfig.bannerSplash, isLoading: $isAdLoading)
                        .frame(height: 50)
                        .padding(.bottom, 20)
                        .opacity(isAdLoading ? 0 : 1)
                }
            }
        }
        .onAppear {
            // Start loading interstitial ad in background
            adManager.loadSplashInterstitial()
            // Start loading animation
            startLoading()
        }
    }
    
    private func startLoading() {
        // Reset progress to 0%
        progress = 0.0
        
        // Smooth animation from 0% to 100% - increased duration for ad loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.linear(duration: 4.5)) { // Increased from 3.0 to 4.5 seconds
                progress = 1.0
            }
            
            // Navigate to intro1 after loading completes - give more time for ads to load
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.6) { // Increased from 3.1 to 4.6 seconds
                onComplete()
            }
        }
    }
}

#Preview {
    SplashScreenView(onComplete: {})
}

