//
//  RootView.swift
//  Metal Detector IOS
//
//  Created by Lowbyte Studio on 27/11/2025.
//

import SwiftUI

enum IntroRoute: Hashable {
    case intro1
    case intro2
    case intro3
    case home
    case settings
}

struct RootView: View {
    @State private var navigationPath = NavigationPath()
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            NavigationStack(path: $navigationPath) {
                Intro1View(
                    onNext: {
                        navigationPath.append(IntroRoute.intro2)
                    },
                    onSkip: {
                        navigationPath.append(IntroRoute.intro2)
                    }
                )
                .navigationDestination(for: IntroRoute.self) { route in
                    switch route {
                    case .intro2:
                        Intro2View(
                            onNext: {
                                navigationPath.append(IntroRoute.intro3)
                            },
                            onSkip: {
                                navigationPath.append(IntroRoute.intro3)
                            }
                        )
                        .navigationBarBackButtonHidden(true)
                        .navigationBarHidden(true)
                    case .intro3:
                        Intro3View(
                            onGetStarted: {
                                navigationPath.append(IntroRoute.home)
                            },
                            onSkip: {
                                navigationPath.append(IntroRoute.home)
                            }
                        )
                        .navigationBarBackButtonHidden(true)
                        .navigationBarHidden(true)
                    case .home:
                        HomeView(
                            onSettingsTap: {
                                navigationPath.append(IntroRoute.settings)
                            }
                        )
                        .navigationBarBackButtonHidden(true)
                        .navigationBarHidden(true)
                    case .settings:
                        SettingsView(
                            onBackTap: {
                                navigationPath.removeLast()
                            }
                        )
                        .navigationBarBackButtonHidden(true)
                        .navigationBarHidden(true)
                    case .intro1:
                        EmptyView()
                    }
                }
                .navigationBarBackButtonHidden(true)
                .navigationBarHidden(true)
            }
            
            if showSplash {
                SplashScreenView(onComplete: {
                    withAnimation {
                        showSplash = false
                    }
                })
                .transition(.opacity)
            }
        }
    }
}

