//
//  CompassDetectorView.swift
//  Metal Detector IOS
//
//  Created by Lowbyte Studio on 27/11/2025.
//

import SwiftUI
import CoreLocation
import Combine

struct CompassDetectorView: View {
    var onBackTap: () -> Void
    @StateObject private var locationManager = LocationManager()
    @StateObject private var localizationManager = LocalizationManager.shared
    @StateObject private var adManager = AdManager.shared
    @StateObject private var iapManager = IAPManager.shared
    @State private var isBottomAdLoading = true
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    // Back Button
                    Button(action: {
                        onBackTap()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }
                    
                    Text(LocalizedString.compassDetectorView.localized)
                        .font(.custom("Zodiak", size: 20))
                        .foregroundColor(.white)
                        .id(localizationManager.currentLanguage)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    Spacer()
                    
                    // Sound Button
                    Button(action: {
                        // Handle sound action
                    }) {
                        ZStack {
                            Image("Pro Button Background")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                            
                            Image("Sound Icon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                        }
                    }
                    .padding(.trailing, 8)
                    
                    // Vibration Button
                    Button(action: {
                        // Handle vibration action
                    }) {
                        ZStack {
                            Image("Pro Button Background")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                            
                            Image("Vibration Icon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                        }
                    }
                    .padding(.trailing, 16)
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                
                Spacer()
                
                // Compass Container
                ZStack {
                    // Compass Background Image
                    Image("Compass")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 314, height: 368)
                    
                    // Compass Needle - Rotates based on heading with smooth animation
                    // Added offset to align needle's starting position with North
                    Image("Compass Needle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 364, height: 230)
                        .rotationEffect(.degrees(-locationManager.smoothHeading - 20.0)) // Offset: -20 degrees to align needle with N
                        .animation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0.3), value: locationManager.smoothHeading)
                }
                .padding(.top, 32)
                
                Spacer()
                
                // Information Cards with real values
                HStack(spacing: 12) {
                    // Card 1 - Direction where red needle is pointing (N, S, E, W, NE, SE, SW, NW)
                    InfoCard(value: locationManager.directionString)
                    
                    // Card 2 - Degrees only (no letter suffix)
                    InfoCard(value: String(format: "%.0f°", locationManager.northBearing))
                    
                    // Card 3 - Magnetic Heading
                    InfoCard(value: String(format: "%.0f°M", locationManager.heading))
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 120) // Increased padding to account for ad height (100px) + spacing
            }
            
            // Bottom Native Ad (Fixed at bottom, doesn't scroll) - Only show if not premium
            if !iapManager.isPremium {
                VStack {
                    Spacer()
                    
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
            locationManager.requestLocationPermission()
            locationManager.startHeadingUpdates()
            
            // Pre-load interstitial ad for future use
            adManager.loadGeneralInterstitial()
            
            // Show ad when compass detector view appears (only first time, not on back navigation)
            // Small delay to ensure view is fully loaded
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if adManager.isInterstitialReady {
                    adManager.showGeneralInterstitial(forView: "CompassDetectorView") {
                        // Ad closed, continue with compass detector view
                        print("✅ CompassDetectorView: Ad dismissed, compass detector view ready")
                    }
                }
            }
        }
        .onDisappear {
            locationManager.stopHeadingUpdates()
        }
    }
}

struct InfoCard: View {
    let value: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 43/255, green: 43/255, blue: 43/255))
                .frame(width: 118, height: 70)
            
            Text(value)
                .font(.system(size: 20.64, weight: .medium))
                .foregroundColor(.white)
        }
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var heading: Double = 0
    @Published var smoothHeading: Double = 0  // Smooth interpolated heading for animation
    
    // Published values for info cards
    @Published var eastBearing: Double = 0.0   // Bearing to East (90 degrees from North)
    @Published var northBearing: Double = 0.0  // Bearing to North (0 degrees)
    
    // Computed property to get direction string based on where red needle is pointing on the compass dial
    var directionString: String {
        // The compass needle always points to magnetic North
        // When device faces North (heading = 0), red needle points to N (top of dial)
        // When device faces East (heading = 90), red needle points to W (left of dial)
        // So: direction on dial = (360 - heading) % 360
        
        // Use smoothHeading for smooth direction changes
        let normalizedHeading = (smoothHeading + 360).truncatingRemainder(dividingBy: 360)
        
        // The direction where the red needle points on the compass dial
        // Needle rotation: -smoothHeading - 20.0
        // When heading = 0, rotation = -20, needle should point to N
        // So we need to account for this offset
        let dialAngle = (360.0 - normalizedHeading + 20.0).truncatingRemainder(dividingBy: 360.0)
        
        // Convert angle to direction string
        // 0° = N, 45° = NE, 90° = E, 135° = SE, 180° = S, 225° = SW, 270° = W, 315° = NW
        if dialAngle >= 337.5 || dialAngle < 22.5 {
            return "N"
        } else if dialAngle >= 22.5 && dialAngle < 67.5 {
            return "NE"
        } else if dialAngle >= 67.5 && dialAngle < 112.5 {
            return "E"
        } else if dialAngle >= 112.5 && dialAngle < 157.5 {
            return "SE"
        } else if dialAngle >= 157.5 && dialAngle < 202.5 {
            return "S"
        } else if dialAngle >= 202.5 && dialAngle < 247.5 {
            return "SW"
        } else if dialAngle >= 247.5 && dialAngle < 292.5 {
            return "W"
        } else { // dialAngle >= 292.5 && dialAngle < 337.5
            return "NW"
        }
    }
    
    // Smoothing factor for heading interpolation
    private let smoothingFactor: Double = 0.15
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // Higher update frequency for smoother movement
        locationManager.headingFilter = 1.0  // Update every 1 degree change
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startHeadingUpdates() {
        if CLLocationManager.headingAvailable() {
            locationManager.startUpdatingHeading()
        }
    }
    
    func stopHeadingUpdates() {
        locationManager.stopUpdatingHeading()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let newHeadingValue = newHeading.magneticHeading
        
        DispatchQueue.main.async {
            self.heading = newHeadingValue
            
            // Calculate bearings to cardinal directions
            // When heading = 0 (pointing North), all values should align correctly
            let currentHeading = newHeadingValue
            
            // North bearing: When red needle points to N, value should be 0
            // Needle image has initial offset of 20 degrees, so we adjust the calculation
            // Additional adjustments to ensure N shows 0 when needle points to N
            // If heading is 0 (North), northBearing should show 0 when needle points to N
            // Adjusted heading accounts for needle's initial offset
            let adjustedHeading = currentHeading + 20.0 - 15.0 + 0.0  // Total offset: +5 degrees
            let normalizedHeading = adjustedHeading >= 0 ? adjustedHeading : adjustedHeading + 360.0
            
            if normalizedHeading <= 180 {
                self.northBearing = normalizedHeading
            } else if normalizedHeading <= 360 {
                self.northBearing = normalizedHeading - 360
            } else {
                self.northBearing = normalizedHeading - 360
            }
            
            // East bearing: Deviation from East (90 degrees)
            // If heading is 0 (North), eastBearing = -90 (or 270)
            // If heading is 90 (East), eastBearing = 0
            // If heading is 180 (South), eastBearing = 90
            // If heading is 270 (West), eastBearing = 180 (or -180)
            let eastDeviation = currentHeading - 90.0
            if eastDeviation > 180 {
                self.eastBearing = eastDeviation - 360
            } else if eastDeviation < -180 {
                self.eastBearing = eastDeviation + 360
            } else {
                self.eastBearing = eastDeviation
            }
            
            // Smooth interpolation with angle wrapping handling
            // Handle the wrap-around case (e.g., 359° to 1° should go the shorter path)
            let currentSmoothHeading = self.smoothHeading
            var targetHeading = newHeadingValue
            
            // Calculate the shortest path between two angles
            var difference = targetHeading - currentSmoothHeading
            
            // Normalize to -180 to 180 range
            while difference > 180 {
                difference -= 360
            }
            while difference < -180 {
                difference += 360
            }
            
            // Apply smooth interpolation
            let newSmoothHeading = currentSmoothHeading + (difference * self.smoothingFactor)
            
            // Normalize to 0-360 range
            self.smoothHeading = (newSmoothHeading + 360).truncatingRemainder(dividingBy: 360)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
    }
}

#Preview {
    CompassDetectorView(onBackTap: {})
}

