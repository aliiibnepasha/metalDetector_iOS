//
//  DetectorView.swift
//  Metal Detector IOS
//
//  Created by Lowbyte Studio on 27/11/2025.
//

import SwiftUI
import Lottie

struct DetectorView: View {
    let detectorTitle: String
    var onBackTap: () -> Void
    @StateObject private var detectorManager = MetalDetectorManager.shared
    @StateObject private var localizationManager = LocalizationManager.shared
    @StateObject private var adManager = AdManager.shared
    @StateObject private var iapManager = IAPManager.shared
    var onMeterViewTap: (() -> Void)? = nil
    var onGraphViewTap: (() -> Void)? = nil
    var onDigitalViewTap: (() -> Void)? = nil
    var onSensorViewTap: (() -> Void)? = nil
    var onCalibrationViewTap: (() -> Void)? = nil
    var onMagneticViewTap: (() -> Void)? = nil
    @State private var isBottomAdLoading = true
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header - Fixed at top (not scrollable)
                HStack(spacing: 6) {
                    // Back Button
                    Button(action: {
                        onBackTap()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }
                    
                    Text(detectorTitle)
                        .font(.custom("Zodiak", size: 24))
                        .foregroundColor(.white)
                        .id(localizationManager.currentLanguage)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 12)
                .background(Color.black) // Ensure background matches
                
                // Scrollable Content
                ScrollView {
                    VStack(spacing: 0) {
                        // Grid of View Cards
                        VStack(spacing: 12) {
                            // Row 1
                            HStack(spacing: 12) {
                                // Meter View
                                ViewCard(
                                    backgroundImageName: "Meter View Background",
                                    title: LocalizedString.meterView.localized,
                                    lottieName: "meter",
                                    onTap: {
                                        handleViewTap {
                                            onMeterViewTap?()
                                        }
                                    }
                                )
                                
                                // Graph View
                                ViewCard(
                                    backgroundImageName: "Graph View Background",
                                    title: LocalizedString.graphView.localized,
                                    lottieName: "Graph Lottie Animation",
                                    onTap: {
                                        handleViewTap {
                                            onGraphViewTap?()
                                        }
                                    }
                                )
                            }
                            
                            // Row 2
                            HStack(spacing: 12) {
                                // Digital View
                                ViewCard(
                                    backgroundImageName: "Digital View Background",
                                    title: LocalizedString.digitalView.localized,
                                    lottieName: "Animated compass",
                                    onTap: {
                                        handleViewTap {
                                            onDigitalViewTap?()
                                        }
                                    }
                                )
                                
                                // Sensor View
                                ViewCard(
                                    backgroundImageName: "Sensor View Background",
                                    title: LocalizedString.sensorView.localized,
                                    lottieName: "sensor",
                                    onTap: {
                                        handleViewTap {
                                            onSensorViewTap?()
                                        }
                                    }
                                )
                            }
                            
                            // Row 3
                            HStack(spacing: 12) {
                                // Calibration View
                                ViewCard(
                                    backgroundImageName: "Calibration View Background",
                                    title: LocalizedString.calibrationView.localized,
                                    lottieName: "Weighing Scale",
                                    onTap: {
                                        handleViewTap {
                                            onCalibrationViewTap?()
                                        }
                                    }
                                )
                                
                                // Magnetic View
                                ViewCard(
                                    backgroundImageName: "Magnetic View Background",
                                    title: LocalizedString.magneticView.localized,
                                    lottieName: "Magnet",
                                    onTap: {
                                        handleViewTap {
                                            onMagneticViewTap?()
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                        .padding(.bottom, 24)
                    }
                }
                
                // Bottom Native Ad (Fixed at bottom, doesn't scroll) - Only show if not premium
                if !iapManager.isPremium {
                    ZStack {
                        // Shimmer effect while ad is loading
                        if isBottomAdLoading {
                            AdShimmerView()
                                .frame(height: 100)
                                .padding(.horizontal, 16)
                        }
                        
                        // Actual native ad
                        NativeAdView(adUnitID: AdConfig.nativeModelView, isLoading: $isBottomAdLoading)
                            .frame(height: 100)
                            .padding(.horizontal, 16)
                            .opacity(isBottomAdLoading ? 0 : 1)
                    }
                    .padding(.bottom, 8)
                    .background(Color.black) // Ensure background matches
                }
            }
        }
        .onAppear {
            // Log detector opened event (for main detector views)
            let eventName = getDetectorEventName(for: detectorTitle)
            if !eventName.isEmpty {
                FirebaseManager.logEvent(eventName)
            }
            
            // Set detection mode based on detector title
            detectorManager.setMode(for: detectorTitle)
            // Pre-load interstitial ad for future use
            adManager.loadGeneralInterstitial()
            
        }
        // Don't auto-start detection here - let individual views handle it
    }
    
    // MARK: - Helper Methods
    private func handleViewTap(_ completion: @escaping () -> Void) {
        AdManager.shared.handleClickTriggeredInterstitial(context: "detector_grid") {
            completion()
        }
    }
    
    private func getDetectorEventName(for title: String) -> String {
        switch title.lowercased() {
        case "gold detector":
            return "gold_detector_opened"
        case "metal detector":
            return "metal_detector_opened"
        case "stud finder":
            return "stud_finder_opened"
        default:
            return ""
        }
    }
}

struct ViewCard: View {
    let backgroundImageName: String
    let title: String
    let lottieName: String
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
            onTap?()
        }) {
            ZStack {
                // Background Image from assets
                Image(backgroundImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 184, height: 198)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 40)
                    
                    // Lottie Animation
                    if !lottieName.isEmpty {
                        LottieView(animation: .named(lottieName))
                            .playing(loopMode: .loop)
                            .frame(width: 92, height: 92)
                            .background(Color.clear)
                    } else {
                        // Placeholder
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: 92, height: 92)
                    }
                    
                    Spacer()
                        .frame(maxHeight: .infinity)
                    
                    // Title Text (moved up by reducing bottom spacer)
                    Text(title)
                        .font(.custom("Manrope_Bold", size: 20))
                        .foregroundColor(.white)
                        .tracking(-0.48)
                        .padding(.top, -8)
                        .padding(.bottom, 16)
                        .id(LocalizationManager.shared.currentLanguage)
                }
                .frame(width: 184, height: 198)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    DetectorView(detectorTitle: "Gold detector", onBackTap: {})
}

