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

    @Environment(\.dismiss) private var dismiss

    // Safely pop one element from the navigation path if possible
    private func popOrStay() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        } else {
            // Already at root; nothing to pop
        }
    }
    
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
                        Group {
                            if title == "Handled Detector" {
                                HandledDetectorView(
                                    onBackTap: {
                                        popOrStay()
                                    }
                                )
                                .navigationBarBackButtonHidden(true)
                                .navigationBarHidden(true)
                                .onAppear {
                                    FirebaseManager.logEvent("handled_detector_opened")
                                }
                            } else if title == "Digital Compass" {
                                CompassDetectorView(
                                    onBackTap: {
                                        popOrStay()
                                    }
                                )
                                .navigationBarBackButtonHidden(true)
                                .navigationBarHidden(true)
                                .onAppear {
                                    FirebaseManager.logEvent("digital_compass_opened")
                                }
                            } else if title == "Bubble level" {
                                BubbleLevelView(
                                    onBackTap: {
                                        popOrStay()
                                    }
                                )
                                .navigationBarBackButtonHidden(true)
                                .navigationBarHidden(true)
                                .onAppear {
                                    FirebaseManager.logEvent("bubble_level_opened")
                                }
                            } else {
                                DetectorView(
                                    detectorTitle: title,
                                    onBackTap: {
                                        popOrStay()
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
                                .onAppear {
                                    // Log detector opened events based on title
                                    if title == "Gold Detector" {
                                        FirebaseManager.logEvent("gold_detector_opened")
                                    } else if title == "Metal Detector" {
                                        FirebaseManager.logEvent("metal_detector_opened")
                                    } else if title == "Stud Finder" {
                                        FirebaseManager.logEvent("stud_finder_opened")
                                    }
                                }
                            }
                        }
                    case .settings:
                        SettingsView(
                            onBackTap: {
                                popOrStay()
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
                                    popOrStay()
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
                                popOrStay()
                            }
                        )
                        .navigationBarBackButtonHidden(true)
                        .navigationBarHidden(true)
                    case .graphView:
                        GraphView(
                            onBackTap: {
                                popOrStay()
                            }
                        )
                        .navigationBarBackButtonHidden(true)
                        .navigationBarHidden(true)
                    case .digitalView:
                        DigitalView(
                            onBackTap: {
                                popOrStay()
                            }
                        )
                        .navigationBarBackButtonHidden(true)
                        .navigationBarHidden(true)
                    case .sensorView:
                        SensorView(
                            onBackTap: {
                                popOrStay()
                            }
                        )
                        .navigationBarBackButtonHidden(true)
                        .navigationBarHidden(true)
                    case .calibrationView:
                        CalibrationView(
                            onBackTap: {
                                popOrStay()
                            }
                        )
                        .navigationBarBackButtonHidden(true)
                        .navigationBarHidden(true)
                    case .magneticView:
                        MagneticView(
                            onBackTap: {
                                popOrStay()
                            }
                        )
                        .navigationBarBackButtonHidden(true)
                        .navigationBarHidden(true)
                    case .paywall:
                        PaywallView(
                            onClose: {
                                popOrStay()
                            },
                            onGoPremium: {
                                // Handle go premium action (e.g., purchase flow)
                                popOrStay()
                            },
                            onContinueFree: {
                                popOrStay()
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
                                // Log splash to language transition
                                FirebaseManager.logEvent("splash_to_language")
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

