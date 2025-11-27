//
//  Intro1View.swift
//  Metal Detector IOS
//
//  Created by Lowbyte Studio on 27/11/2025.
//

import SwiftUI

struct Intro1View: View {
    var onNext: () -> Void
    var onSkip: () -> Void
    
    var body: some View {
        ZStack {
            // Black background
            Color.black
                .ignoresSafeArea()
            
            // Phone Image (positioned at top)
            VStack(alignment: .center) {
                Image("Phone_Air 1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 412, height: 700)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.top, -30)
            
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
                        Text("Metal Detector & Gold Finder")
                            .font(.system(size: 38, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                           
                        
                        Text("Detector Metal Accessories & gold materials easily.")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .frame(width: 233)
                    }
                    
                    // Pagination Dots
                    HStack(spacing: 9.76) {
                        Circle()
                            .fill(Color(red: 0.9, green: 0.7, blue: 0.13))
                            .frame(width: 10, height: 10)
                        
                        Circle()
                            .fill(Color(red: 0.17, green: 0.17, blue: 0.17))
                            .frame(width: 10, height: 10)
                        
                        Circle()
                            .fill(Color(red: 0.17, green: 0.17, blue: 0.17))
                            .frame(width: 10, height: 10)
                    }
                    
                    // Next Button
                    Button(action: {
                        onNext()
                    }) {
                        ZStack {
                            // Outer border
                            RoundedRectangle(cornerRadius: 18.76)
                                .stroke(Color(red: 0.9, green: 0.63, blue: 0.13), lineWidth: 0.065)
                                .frame(width: 275, height: 44)
                            
                            // Inner border
                            RoundedRectangle(cornerRadius: 18.76)
                                .stroke(Color(red: 0.95, green: 0.84, blue: 0.42).opacity(0.59), lineWidth: 0.97)
                                .frame(width: 271, height: 40)
                            
                            // Gradient fill
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.85, blue: 0.0),
                                    Color(red: 0.99, green: 0.78, blue: 0.23)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 18.76))
                            .frame(width: 271, height: 40)
                            
                            // Button text
                            Text("Next")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                                .tracking(-0.8)
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
                        Text("skip")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                            .textCase(.lowercase)
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
    Intro1View(onNext: {}, onSkip: {})
}

