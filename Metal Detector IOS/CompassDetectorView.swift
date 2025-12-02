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
                    Image("Compass Needle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 364, height: 230)
                        .rotationEffect(.degrees(-locationManager.smoothHeading))
                        .animation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0.3), value: locationManager.smoothHeading)
                }
                .padding(.top, 32)
                
                Spacer()
                
                // Information Cards with real values
                HStack(spacing: 12) {
                    // Card 1 - East Direction (Bearing to East)
                    InfoCard(value: String(format: "%.1f°E", locationManager.eastBearing))
                    
                    // Card 2 - North Direction (Bearing to North)
                    InfoCard(value: String(format: "%.0f°N", locationManager.northBearing))
                    
                    // Card 3 - Magnetic Heading
                    InfoCard(value: String(format: "%.0f°M", locationManager.heading))
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            locationManager.requestLocationPermission()
            locationManager.startHeadingUpdates()
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
            // East is 90 degrees from North
            // North is 0/360 degrees
            let currentHeading = newHeadingValue
            
            // East bearing: 90° - current heading (normalized to 0-360)
            self.eastBearing = (90.0 - currentHeading + 360).truncatingRemainder(dividingBy: 360)
            // If > 180, show as negative (shorter direction)
            if self.eastBearing > 180 {
                self.eastBearing = self.eastBearing - 360
            }
            
            // North bearing: 0° - current heading (normalized to 0-360)
            // This is essentially the heading itself, but shown as deviation from North
            self.northBearing = (0.0 - currentHeading + 360).truncatingRemainder(dividingBy: 360)
            // If > 180, show as negative (shorter direction)
            if self.northBearing > 180 {
                self.northBearing = self.northBearing - 360
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

