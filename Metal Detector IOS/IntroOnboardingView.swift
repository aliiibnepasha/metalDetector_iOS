//
//  IntroOnboardingView.swift
//  Metal Detector IOS
//
//  Created by Lowbyte Studio on 27/11/2025.
//

import SwiftUI

struct IntroOnboardingView: View {
    @State private var currentPage = 0
    @ObservedObject private var localizationManager = LocalizationManager.shared
    var onGetStarted: () -> Void
    
    var introPages: [IntroPage] {
        [
            IntroPage(
                imageName: "Phone_Air 1",
                title: LocalizedString.metalDetectorGoldFinder.localized,
                description: LocalizedString.detectMetalAccessoriesGold.localized,
                descriptionWidth: 233
            ),
            IntroPage(
                imageName: "Phone_Air (1) 1",
                title: LocalizedString.goldMetalSensitivityGauge.localized,
                description: LocalizedString.monitorLiveSensorCurves.localized,
                descriptionWidth: 253
            ),
            IntroPage(
                imageName: "415845897_8f37c68b-d006-49d8-9c53-8e9483be02fe 1",
                title: LocalizedString.theSmartWayToFindNorth.localized,
                description: LocalizedString.guidedByPrecision.localized,
                descriptionWidth: 241
            )
        ]
    }
    
    var body: some View {
        ZStack {
            // Black background
            Color.black
                .ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                ForEach(0..<introPages.count, id: \.self) { index in
                    IntroPageView(pageIndex: index)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.smooth(duration: 0.4), value: currentPage)
            
            // Fixed Bottom Content (Button and Dots)
            VStack {
                Spacer()
                    .frame(minHeight: 20)
                
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
                    .padding(.top, 32)
                    
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
                            // Button background from assets (same as paywall)
                            Image("Go Premium Button Background")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 275, height: 44)
                                .clipShape(RoundedRectangle(cornerRadius: 18.76))
                            
                            // Button text (changes based on page)
                            Text(currentPage < introPages.count - 1 ? LocalizedString.next.localized : LocalizedString.getStarted.localized)
                                .font(.custom("Manrope_Bold", size: 16))
                                .foregroundColor(.black)
                                .tracking(-0.8)
                                .animation(.none, value: currentPage)
                                .id(localizationManager.currentLanguage)
                        }
                    }
                }
                .padding(.bottom, 40)
                .padding(.horizontal, 36)
            }
        }
        .overlay(
            // Skip Button (top right) - Hide on last page (Intro 3)
            Group {
                if currentPage < introPages.count - 1 {
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                onGetStarted()
                            }) {
                                Text(LocalizedString.skip.localized)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.6))
                                    .textCase(.lowercase)
                                    .id(localizationManager.currentLanguage)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                            }
                            .padding(.trailing, 34)
                            .padding(.top, 10)
                        }
                        Spacer()
                    }
                }
            },
            alignment: .topTrailing
        )
    }
}

struct IntroPage {
    var imageName: String
    var title: String
    var description: String
    var descriptionWidth: CGFloat
}

struct IntroPageView: View {
    let pageIndex: Int
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    private var pageData: IntroPage {
        let pages = [
            IntroPage(
                imageName: "Phone_Air 1",
                title: LocalizedString.metalDetectorGoldFinder.localized,
                description: LocalizedString.detectMetalAccessoriesGold.localized,
                descriptionWidth: 233
            ),
            IntroPage(
                imageName: "Phone_Air (1) 1",
                title: LocalizedString.goldMetalSensitivityGauge.localized,
                description: LocalizedString.monitorLiveSensorCurves.localized,
                descriptionWidth: 253
            ),
            IntroPage(
                imageName: "415845897_8f37c68b-d006-49d8-9c53-8e9483be02fe 1",
                title: LocalizedString.theSmartWayToFindNorth.localized,
                description: LocalizedString.guidedByPrecision.localized,
                descriptionWidth: 241
            )
        ]
        return pages[min(pageIndex, pages.count - 1)]
    }
    
    var body: some View {
        ZStack {
            // Phone Image (positioned at top)
            VStack(alignment: .center) {
                Image(pageData.imageName)
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
                    // Title - Direct localized strings based on page index
                    if pageIndex == 0 {
                        Text(LocalizedString.metalDetectorGoldFinder.localized)
                            .font(.custom("Zodiak", size: 32))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .id("title_\(localizationManager.currentLanguage)_\(pageIndex)")
                    } else if pageIndex == 1 {
                        Text(LocalizedString.goldMetalSensitivityGauge.localized)
                            .font(.custom("Zodiak", size: 32))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .id("title_\(localizationManager.currentLanguage)_\(pageIndex)")
                    } else {
                        Text(LocalizedString.theSmartWayToFindNorth.localized)
                            .font(.custom("Zodiak", size: 32))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .id("title_\(localizationManager.currentLanguage)_\(pageIndex)")
                    }
                    
                    // Description - Direct localized strings based on page index
                    if pageIndex == 0 {
                        Text(LocalizedString.detectMetalAccessoriesGold.localized)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .frame(width: 233)
                            .id("description_\(localizationManager.currentLanguage)_\(pageIndex)")
                    } else if pageIndex == 1 {
                        Text(LocalizedString.monitorLiveSensorCurves.localized)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .frame(width: 253)
                            .id("description_\(localizationManager.currentLanguage)_\(pageIndex)")
                    } else {
                        Text(LocalizedString.guidedByPrecision.localized)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .frame(width: 241)
                            .id("description_\(localizationManager.currentLanguage)_\(pageIndex)")
                    }
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

