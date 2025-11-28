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
}

struct RootView: View {
    @State private var navigationPath = NavigationPath()
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            NavigationStack(path: $navigationPath) {
                IntroOnboardingView(
                    onGetStarted: {
                        navigationPath.append(IntroRoute.home)
                    }
                )
                .navigationDestination(for: IntroRoute.self) { route in
                    switch route {
                    case .home:
                        HomeView(
                            onSettingsTap: {
                                navigationPath.append(IntroRoute.settings)
                            },
                            onDetectorTap: { title in
                                navigationPath.append(IntroRoute.detector(title))
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
                                }
                            )
                            .navigationBarBackButtonHidden(true)
                            .navigationBarHidden(true)
                        }
                    case .settings:
                        SettingsView(
                            onBackTap: {
                                navigationPath.removeLast()
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

