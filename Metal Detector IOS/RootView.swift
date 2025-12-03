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
    case detector(String) // Store detector title
    case meterView
    case graphView
    case digitalView
    case sensorView
    case calibrationView
    case magneticView
    case paywall
    case language
}

struct RootView: View {
    @State private var navigationPath = NavigationPath()
    @State private var showSplash = true
    @State private var showInterstitial = false
    @ObservedObject private var adManager = AdManager.shared
    @AppStorage("hasSelectedLanguage") private var hasSelectedLanguage = false
    @AppStorage("hasSeenIntro") private var hasSeenIntro = false
    
    var body: some View {
        ZStack {
            NavigationStack(path: $navigationPath) {
                // Default view - IntroOnboardingView or Home based on flow
                Group {
                    if hasSeenIntro {
                        // User has seen intro, go to home
                        HomeView(
                            onSettingsTap: {
                                navigationPath.append(IntroRoute.settings)
                            },
                            onDetectorTap: { title in
                                navigationPath.append(IntroRoute.detector(title))
                            },
                            onProTap: {
                                navigationPath.append(IntroRoute.paywall)
                            }
                        )
                        .navigationBarBackButtonHidden(true)
                        .navigationBarHidden(true)
                    } else {
                        // Show intro screens (will be shown after language selection)
                        IntroOnboardingView(
                            onGetStarted: {
                                hasSeenIntro = true
                                var newPath = NavigationPath()
                                newPath.append(IntroRoute.home)
                                navigationPath = newPath
                            }
                        )
                        .opacity(hasSelectedLanguage ? 1 : 0) // Hide until language selected
                    }
                }
                .navigationDestination(for: IntroRoute.self) { route in
                    switch route {
                    case .home:
                        HomeView(
                            onSettingsTap: {
                                navigationPath.append(IntroRoute.settings)
                            },
                            onDetectorTap: { title in
                                navigationPath.append(IntroRoute.detector(title))
                            },
                            onProTap: {
                                navigationPath.append(IntroRoute.paywall)
                            }
                        )
                        .navigationBarBackButtonHidden(true)
                        .navigationBarHidden(true)
                    case .detector(let title):
                        if title == "Handled Detector" {
                            HandledDetectorView(
                                onBackTap: {
                                    navigationPath.removeLast()
                                }
                            )
                            .navigationBarBackButtonHidden(true)
                            .navigationBarHidden(true)
                        } else if title == "Digital Compass" {
                            CompassDetectorView(
                                onBackTap: {
                                    navigationPath.removeLast()
                                }
                            )
                            .navigationBarBackButtonHidden(true)
                            .navigationBarHidden(true)
                        } else if title == "Bubble level" {
                            BubbleLevelView(
                                onBackTap: {
                                    navigationPath.removeLast()
                                }
                            )
                            .navigationBarBackButtonHidden(true)
                            .navigationBarHidden(true)
                        } else {
                            DetectorView(
                                detectorTitle: title,
                                onBackTap: {
                                    navigationPath.removeLast()
                                },
                                onMeterViewTap: {
                                    navigationPath.append(IntroRoute.meterView)
                                },
                                onGraphViewTap: {
                                    navigationPath.append(IntroRoute.graphView)
                                },
                                onDigitalViewTap: {
                                    navigationPath.append(IntroRoute.digitalView)
                                },
                                onSensorViewTap: {
                                    navigationPath.append(IntroRoute.sensorView)
                                },
                                onCalibrationViewTap: {
                                    navigationPath.append(IntroRoute.calibrationView)
                                },
                                onMagneticViewTap: {
                                    navigationPath.append(IntroRoute.magneticView)
                                }
                            )
                            .navigationBarBackButtonHidden(true)
                            .navigationBarHidden(true)
                        }
                    case .settings:
                        SettingsView(
                            onBackTap: {
                                navigationPath.removeLast()
                            },
                            onGetPremiumTap: {
                                navigationPath.append(IntroRoute.paywall)
                            },
                            onLanguageTap: {
                                navigationPath.append(IntroRoute.language)
                            }
                        )
                        .navigationBarBackButtonHidden(true)
                        .navigationBarHidden(true)
                    case .language:
                        LanguageView(
                            onBackTap: {
                                // Don't allow back from language screen on first launch
                                if hasSelectedLanguage {
                                    // User already selected language before (came from Settings)
                                    // Simply go back to previous screen (Settings)
                                    navigationPath.removeLast()
                                }
                                // If first time (hasSelectedLanguage == false), don't allow back
                            },
                            onDone: {
                                if hasSelectedLanguage {
                                    // User already selected language (came from Settings)
                                    // Simply go back to Settings
                                    navigationPath.removeLast()
                                } else {
                                    // First time language selection
                                    hasSelectedLanguage = true
                                    // After language selection, navigate to intro screens
                                    // Clear navigation path to show intro screens as default view
                                    var newPath = NavigationPath()
                                    navigationPath = newPath
                                    // Intro screens will be shown as default view
                                }
                            }
                        )
                        .navigationBarBackButtonHidden(true)
                        .navigationBarHidden(true)
                    case .intro1, .intro2, .intro3:
                        EmptyView()
                    case .meterView:
                        MeterView(
                            onBackTap: {
                                navigationPath.removeLast()
                            }
                        )
                        .navigationBarBackButtonHidden(true)
                        .navigationBarHidden(true)
                    case .graphView:
                        GraphView(
                            onBackTap: {
                                navigationPath.removeLast()
                            }
                        )
                        .navigationBarBackButtonHidden(true)
                        .navigationBarHidden(true)
                    case .digitalView:
                        DigitalView(
                            onBackTap: {
                                navigationPath.removeLast()
                            }
                        )
                        .navigationBarBackButtonHidden(true)
                        .navigationBarHidden(true)
                    case .sensorView:
                        SensorView(
                            onBackTap: {
                                navigationPath.removeLast()
                            }
                        )
                        .navigationBarBackButtonHidden(true)
                        .navigationBarHidden(true)
                    case .calibrationView:
                        CalibrationView(
                            onBackTap: {
                                navigationPath.removeLast()
                            }
                        )
                        .navigationBarBackButtonHidden(true)
                        .navigationBarHidden(true)
                    case .magneticView:
                        MagneticView(
                            onBackTap: {
                                navigationPath.removeLast()
                            }
                        )
                        .navigationBarBackButtonHidden(true)
                        .navigationBarHidden(true)
                    case .paywall:
                        PaywallView(
                            onClose: {
                                navigationPath.removeLast()
                            },
                            onGoPremium: {
                                // Handle go premium action (e.g., purchase flow)
                                navigationPath.removeLast()
                            },
                            onContinueFree: {
                                navigationPath.removeLast()
                            }
                        )
                        .navigationBarBackButtonHidden(true)
                        .navigationBarHidden(true)
                    }
                }
                .navigationBarBackButtonHidden(true)
                .navigationBarHidden(true)
            }
            
            if showSplash {
                SplashScreenView(onComplete: {
                    withAnimation {
                        showSplash = false
                        // After splash, show interstitial ad if ready
                        showInterstitialAd {
                            // After ad (or if ad not ready), navigate to language screen if not selected
                            if !hasSelectedLanguage {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    navigationPath.append(IntroRoute.language)
                                }
                            }
                        }
                    }
                })
                .transition(.opacity)
            }
        }
        .onAppear {
            // Pre-load interstitial ad when app starts
            adManager.loadSplashInterstitial()
        }
    }
    
    // MARK: - Show Interstitial Ad
    private func showInterstitialAd(completion: @escaping () -> Void) {
        adManager.showSplashInterstitial {
            // Ad dismissed or failed, proceed with navigation
            completion()
        }
    }
}

