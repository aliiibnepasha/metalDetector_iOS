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
                    
                    Text("Compass Detector")
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundColor(.white)
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
                    
                    // Compass Needle - Rotates based on heading
                    Image("Compass Needle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 364, height: 230)
                        .rotationEffect(.degrees(-locationManager.heading))
                }
                .padding(.top, 32)
                
                Spacer()
                
                // Information Cards
                HStack(spacing: 12) {
                    // Card 1
                    InfoCard(value: "33.3E")
                    
                    // Card 2
                    InfoCard(value: "260N")
                    
                    // Card 3
                    InfoCard(value: "300M")
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
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
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
        // Use magnetic heading for compass
        heading = newHeading.magneticHeading
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
    }
}

#Preview {
    CompassDetectorView(onBackTap: {})
}

