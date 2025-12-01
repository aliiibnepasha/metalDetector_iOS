//
//  GraphView.swift
//  Metal Detector IOS
//
//  Created by Lowbyte Studio on 27/11/2025.
//

import SwiftUI

struct GraphView: View {
    var onBackTap: () -> Void
    @StateObject private var detectorManager = MetalDetectorManager.shared
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var graphData: [Double] = []
    @State private var maxDataPoints = 50 // Keep last 50 readings
    @State private var cursorPosition: Double = 100.0 // X position of cursor (0-100)
    @State private var soundEnabled = true
    @State private var vibrationEnabled = true
    
    // Computed properties for cursor value and label
    private var selectedValue: Double {
        let index = (cursorPosition / 100.0) * Double(graphData.count - 1)
        let lowerIndex = Int(index)
        let upperIndex = min(lowerIndex + 1, graphData.count - 1)
        let fraction = index - Double(lowerIndex)
        
        if lowerIndex == upperIndex {
            return graphData[lowerIndex]
        }
        
        // Linear interpolation
        return graphData[lowerIndex] * (1 - fraction) + graphData[upperIndex] * fraction
    }
    
    private var selectedLabel: String {
        // Format label based on selected value
        return String(format: "Day %.0f-%.1fk", cursorPosition, selectedValue / 10.0)
    }
    
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
                    
                    Text(LocalizedString.graphView.localized)
                        .font(.custom("Zodiak", size: 24))
                        .foregroundColor(.white)
                        .id(localizationManager.currentLanguage)
                    
                    Spacer()
                    
                    // Sound Button
                    Button(action: {
                        soundEnabled.toggle()
                        detectorManager.setSoundEnabled(soundEnabled)
                    }) {
                        ZStack {
                            // Conditional background: Yellow asset when ON, Gray when OFF
                            if soundEnabled {
                                Image("Pro Button Background")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 40, height: 40)
                                    .clipShape(RoundedRectangle(cornerRadius: 30))
                            } else {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 40, height: 40)
                            }
                            
                            Image("Sound Icon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                        }
                    }
                    .padding(.trailing, 8)
                    
                    // Vibration Button
                    Button(action: {
                        vibrationEnabled.toggle()
                        detectorManager.setVibrationEnabled(vibrationEnabled)
                    }) {
                        ZStack {
                            // Conditional background: Yellow asset when ON, Gray when OFF
                            if vibrationEnabled {
                                Image("Pro Button Background")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 40, height: 40)
                                    .clipShape(RoundedRectangle(cornerRadius: 30))
                            } else {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 40, height: 40)
                            }
                            
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
                .padding(.bottom, 8)
                
                // Graph Container
                GraphContainer(
                    data: graphData,
                    cursorPosition: $cursorPosition
                )
                .frame(width: 380, height: 325)
                .padding(.top, 0)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let containerWidth: CGFloat = 380
                            let paddingLeft: CGFloat = 46
                            let graphWidth: CGFloat = 290
                            let xPosition = value.location.x - paddingLeft
                            let clampedX = max(0, min(graphWidth, xPosition))
                            cursorPosition = Double(clampedX / graphWidth * 100.0)
                        }
                )
                
                // Detection Status Text (moved closer to graph)
                VStack(spacing: 12) {
                    Text(detectorManager.getDetectionMessageKey().localized)
                        .font(.custom("Zodiak", size: 24))
                        .foregroundColor(.white)
                        .id(localizationManager.currentLanguage + "_" + String(detectorManager.isMetalDetected))
                    
                    if !detectorManager.isMetalDetected {
                        Text(LocalizedString.pleaseCheckThoroughly.localized)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .id(localizationManager.currentLanguage)
                    }
                }
                .padding(.top, 36)
                
                Spacer()
                
                Spacer()
                    .frame(height: 40)
            }
        }
        .onAppear {
            detectorManager.startDetection()
            // Initialize with empty array - will fill with real data
            graphData = []
            // Sync with detectorManager
            soundEnabled = detectorManager.soundEnabled
            vibrationEnabled = detectorManager.vibrationEnabled
        }
        .onDisappear {
            detectorManager.stopDetection()
        }
        .onReceive(detectorManager.$magneticFieldStrength) { newValue in
            // Update graph data with new reading
            if !newValue.isNaN && !newValue.isInfinite {
                graphData.append(newValue)
                if graphData.count > maxDataPoints {
                    graphData.removeFirst()
                }
                // Move cursor to latest point
                cursorPosition = 100.0
            }
        }
    }
}

struct GraphContainer: View {
    let data: [Double]
    @Binding var cursorPosition: Double
    
    // Computed properties for cursor
    private var selectedValue: Double {
        // Safety check - return 0 if data is empty
        guard !data.isEmpty else { return 0 }
        
        let index = (cursorPosition / 100.0) * Double(data.count - 1)
        let lowerIndex = Int(index)
        let clampedLowerIndex = max(0, min(lowerIndex, data.count - 1))
        let upperIndex = min(clampedLowerIndex + 1, data.count - 1)
        let fraction = index - Double(clampedLowerIndex)
        
        if clampedLowerIndex == upperIndex {
            return data[clampedLowerIndex]
        }
        
        return data[clampedLowerIndex] * (1 - fraction) + data[upperIndex] * fraction
    }
    
    private var selectedLabel: String {
        return String(format: "Day %.0f-%.1fk", cursorPosition, selectedValue / 10.0)
    }
    
    private let graphWidth: CGFloat = 290
    private let graphHeight: CGFloat = 164
    private let paddingLeft: CGFloat = 46
    private let paddingTop: CGFloat = 68
    private let paddingBottom: CGFloat = 78
    private let paddingRight: CGFloat = 44
    
    var body: some View {
        ZStack {
            // Container Background
            RoundedRectangle(cornerRadius: 13.735)
                .fill(Color(red: 43/255, green: 43/255, blue: 43/255))
                .overlay(
                    RoundedRectangle(cornerRadius: 13.735)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            
            ZStack(alignment: .topLeading) {
                // Grid Lines
                GraphGrid()
                
                // Y-axis Labels
                VStack(alignment: .leading, spacing: 22.892) {
                    ForEach([50, 40, 30, 20, 10, 0], id: \.self) { value in
                        Text("\(value)")
                            .font(.system(size: 9.157, weight: .semibold))
                            .foregroundColor(Color(red: 124/255, green: 124/255, blue: 124/255))
                            .tracking(0.8699)
                    }
                }
                .padding(.leading, 23.29)
                .padding(.top, 38.67)
                
                // X-axis Labels
                HStack(spacing: 44) {
                    ForEach([0, 20, 40, 60, 80, 100], id: \.self) { value in
                        Text("\(value)")
                            .font(.system(size: 9.157, weight: .semibold))
                            .foregroundColor(Color(red: 124/255, green: 124/255, blue: 124/255))
                            .tracking(0.8699)
                    }
                }
                .padding(.leading, 46.93)
                .padding(.top, 246.66)
                
                // Graph Area
                ZStack {
                    // Graph Line
                    GraphLine(data: data)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.85, blue: 0.0),
                                    Color(red: 0.99, green: 0.78, blue: 0.23)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
                        )
                        .frame(width: graphWidth, height: graphHeight)
                        .padding(.leading, paddingLeft)
                        .padding(.top, paddingTop)
                    
                    // Cursor Line and Indicator
                    GraphCursor(
                        cursorPosition: cursorPosition,
                        selectedValue: selectedValue,
                        data: data,
                        graphWidth: graphWidth,
                        graphHeight: graphHeight
                    )
                    .padding(.leading, paddingLeft)
                    .padding(.top, paddingTop)
                    
                    // Label above cursor
                    if cursorPosition >= 0 && cursorPosition <= 100 {
                        Text(selectedLabel)
                            .font(.system(size: 11.446, weight: .semibold))
                            .foregroundColor(.white)
                            .tracking(1.0873)
                            .offset(
                                x: paddingLeft + (CGFloat(cursorPosition) / 100.0 * graphWidth) - 190,
                                y: paddingTop - 30
                            )
                    }
                }
            }
        }
    }
}

struct GraphGrid: View {
    var body: some View {
        ZStack {
            // Horizontal grid lines
            ForEach(0..<6) { index in
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 1)
                    .offset(y: 38.67 + CGFloat(index) * 22.892)
                    .padding(.horizontal, 46)
            }
            
            // Vertical grid lines
            ForEach(0..<6) { index in
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 1)
                    .offset(x: 46.93 + CGFloat(index) * 44)
                    .padding(.vertical, 38.67)
            }
        }
    }
}

struct GraphLine: Shape {
    let data: [Double]
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        guard data.count > 1 else { return path }
        
        let maxValue: Double = 50
        let stepX = rect.width / CGFloat(data.count - 1)
        
        // Start point
        let firstY = rect.height - (CGFloat(data[0] / maxValue) * rect.height)
        path.move(to: CGPoint(x: 0, y: firstY))
        
        // Draw line through all points
        for index in 1..<data.count {
            let x = CGFloat(index) * stepX
            let y = rect.height - (CGFloat(data[index] / maxValue) * rect.height)
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        return path
    }
}

struct GraphCursor: View {
    let cursorPosition: Double
    let selectedValue: Double
    let data: [Double]
    let graphWidth: CGFloat
    let graphHeight: CGFloat
    
    // Calculate the actual Y position on the graph line
    private var lineYPosition: CGFloat {
        let maxValue: Double = 50
        let yValue = CGFloat(selectedValue / maxValue) * graphHeight
        // Ensure Y stays within graph bounds
        return max(0, min(graphHeight, graphHeight - yValue))
    }
    
    var body: some View {
        GeometryReader { geometry in
            let xPosition = CGFloat(cursorPosition / 100.0) * graphWidth
            // Ensure X stays within graph bounds
            let clampedX = max(0, min(graphWidth, xPosition))
            
            ZStack {
                // Vertical cursor line (only within graph bounds)
                Rectangle()
                    .fill(Color(red: 124/255, green: 124/255, blue: 124/255).opacity(0.5))
                    .frame(width: 1, height: graphHeight)
                    .offset(x: clampedX)
                
                // Circle indicator at intersection with graph line
                // Ensure circle stays within graph bounds
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
                    .frame(width: 19.199, height: 19.199)
                    .overlay(
                        Circle()
                            .fill(Color.white)
                            .frame(width: 8, height: 8)
                    )
                    .offset(
                        x: clampedX - 9.6,
                        y: lineYPosition - 9.6
                    )
            }
        }
    }
}

#Preview {
    GraphView(onBackTap: {})
}

