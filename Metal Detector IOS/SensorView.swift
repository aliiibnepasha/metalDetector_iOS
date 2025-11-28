//
//  SensorView.swift
//  Metal Detector IOS
//
//  Created by Lowbyte Studio on 27/11/2025.
//

import SwiftUI

struct SensorView: View {
    var onBackTap: () -> Void
    @State private var percentage: Double = 74.0 // Current percentage (0-100)
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
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
                    
                    Text("Sensor view")
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                    
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
                .padding(.bottom, 16)
                
                Spacer()
                
                // Circular Progress Indicator
                CircularProgressView(percentage: percentage)
                    .frame(width: 310, height: 310)
                
                Spacer()
                
                // Detection Status Text
                VStack(spacing: 12) {
                    Text("No Gold detected,")
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                    
                    Text("Please check thoroughly")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.top, 16)
                
                Spacer()
                
                Spacer()
                    .frame(height: 40)
            }
        }
    }
}

struct CircularProgressView: View {
    let percentage: Double
    private let lineWidth: CGFloat = 20
    private let radius: CGFloat = 145
    
    // Convert percentage to angle (0-360 degrees)
    // Starting from top, going clockwise
    private var progressAngle: Double {
        (percentage / 100.0) * 360.0
    }
    
    // Calculate indicator position (circle center + offset based on angle)
    private var indicatorAngle: Double {
        // Start from top (-90 degrees) and go clockwise
        let startAngle: Double = -90
        return startAngle + progressAngle
    }
    
    private var indicatorX: CGFloat {
        let angleInRadians = indicatorAngle * .pi / 180
        return radius * cos(angleInRadians)
    }
    
    private var indicatorY: CGFloat {
        let angleInRadians = indicatorAngle * .pi / 180
        return radius * sin(angleInRadians)
    }
    
    var body: some View {
        ZStack {
            // Background Circle (unfilled portion)
            Circle()
                .trim(from: 0, to: 1)
                .stroke(
                    Color(red: 43/255, green: 43/255, blue: 43/255),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: radius * 2, height: radius * 2)
            
            // Progress Circle (filled portion with yellow gradient)
            Circle()
                .trim(from: 0, to: percentage / 100.0)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color(red: 1.0, green: 0.85, blue: 0.0),
                            Color(red: 0.99, green: 0.78, blue: 0.23)
                        ]),
                        center: .center,
                        angle: .degrees(0)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: radius * 2, height: radius * 2)
                .rotationEffect(.degrees(-90)) // Start from top
            
            // Yellow Indicator Dot (moves around the circle)
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 1.0, green: 0.85, blue: 0.0),
                            Color(red: 0.99, green: 0.78, blue: 0.23)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 38.75, height: 38.75)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
                .offset(x: indicatorX, y: indicatorY)
            
            // Percentage Text in Center
            Text("\(Int(percentage))%")
                .font(.system(size: 64, weight: .bold, design: .serif))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    SensorView(onBackTap: {})
}

