//
//  IntroOnboardingView.swift
//  Metal Detector IOS
//
//  Created by Lowbyte Studio on 27/11/2025.
//

import SwiftUI

struct IntroOnboardingView: View {
    @State private var currentPage = 0
    var onGetStarted: () -> Void
    
    let introPages = [
        IntroPage(
            imageName: "Phone_Air 1",
            title: "Metal Detector & Gold Finder",
            description: "Detector Metal Accessories & gold materials easily.",
            descriptionWidth: 233
        ),
        IntroPage(
            imageName: "Phone_Air (1) 1",
            title: "Gold & Metal Sensitivity Gauge",
            description: "Monitor live sensor curves and uncover hidden materials.",
            descriptionWidth: 253
        ),
        IntroPage(
            imageName: "415845897_8f37c68b-d006-49d8-9c53-8e9483be02fe 1",
            title: "The Smart Way to Find North",
            description: "Guided by precision magnetic sensors in your pocket.",
            descriptionWidth: 241
        )
    ]
    
    var body: some View {
        ZStack {
            // Black background
            Color.black
                .ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                ForEach(0..<introPages.count, id: \.self) { index in
                    IntroPageView(page: introPages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.smooth(duration: 0.4), value: currentPage)
            
            // Fixed Bottom Content (Button and Dots)
            VStack {
                Spacer()
                
                VStack(spacing: 24) {
                    // Pagination Dots
                    HStack(spacing: 9.76) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(index == currentPage ? Color(red: 0.9, green: 0.7, blue: 0.13) : Color(red: 0.17, green: 0.17, blue: 0.17))
                                .frame(width: 10, height: 10)
                                .animation(.smooth(duration: 0.3), value: currentPage)
                        }
                    }
                    
                    // Action Button (stays in same place, text changes)
                    Button(action: {
                        if currentPage < introPages.count - 1 {
                            withAnimation(.smooth(duration: 0.4)) {
                                currentPage += 1
                            }
                        } else {
                            onGetStarted()
                        }
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
                            
                            // Button text (changes based on page)
                            Text(currentPage < introPages.count - 1 ? "Next" : "Get Started")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                                .tracking(-0.8)
                                .animation(.none, value: currentPage)
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
                        onGetStarted()
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

struct IntroPage {
    let imageName: String
    let title: String
    let description: String
    let descriptionWidth: CGFloat
}

struct IntroPageView: View {
    let page: IntroPage
    
    var body: some View {
        ZStack {
            // Phone Image (positioned at top)
            VStack(alignment: .center) {
                Image(page.imageName)
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
            
            // Content Section (bottom) - Title and Description only
            VStack {
                Spacer()
                
                VStack(spacing: 14.76) {
                    Text(page.title)
                        .font(.system(size: 38, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text(page.description)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .frame(width: page.descriptionWidth)
                }
                .padding(.bottom, 120)
                .padding(.horizontal, 36)
            }
        }
    }
}

#Preview {
    IntroOnboardingView(onGetStarted: {})
}

