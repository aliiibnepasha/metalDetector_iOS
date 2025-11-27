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
                    Text("Metal Detector Pro")
                        .font(.system(size: 32, weight: .semibold, design: .default))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
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
                        Text("Loading...")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
                .padding(.bottom, 120)
            }
        }
        .onAppear {
            // Start loading animation
            startLoading()
        }
    }
    
    private func startLoading() {
        // Reset progress to 0%
        progress = 0.0
        
        // Smooth animation from 0% to 100%
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.linear(duration: 3.0)) {
                progress = 1.0
            }
            
            // Navigate to intro1 after loading completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.1) {
                onComplete()
            }
        }
    }
}

#Preview {
    SplashScreenView(onComplete: {})
}

