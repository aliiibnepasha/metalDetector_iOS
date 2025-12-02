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
    @State private var maxDataPoints = 100 // Keep last 100 readings for smoother graph
    @State private var cursorPosition: Double = 100.0 // X position of cursor (0-100)
    @State private var soundEnabled = true
    @State private var vibrationEnabled = true
    @State private var updateTimer: Timer?
    
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
                    
                    Text(detectorManager.getSubtitleMessageKey().localized)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .id(localizationManager.currentLanguage + "_subtitle_" + String(detectorManager.isMetalDetected))
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
            
            // Start timer to continuously update graph with frequency-based data
            updateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                let currentLevel = detectorManager.detectionLevel
                if !currentLevel.isNaN && !currentLevel.isInfinite {
                    // Add natural frequency variations to create realistic graph waves
                    // When detection is high, ensure graph reaches maximum height (50 on Y-axis)
                    // Scale variations based on detection level - higher detection = larger variations
                    let variationScale = max(1.0, currentLevel / 20.0) // Scale variations with detection
                    let baseVariation = sin(Date().timeIntervalSince1970 * 10) * 3 * variationScale // Frequency wave
                    let randomVariation = Double.random(in: -1.5...1.5) * variationScale // Small random noise
                    // Amplify detection level to use full graph range (0-50 on Y-axis)
                    // When detection happens, ensure graph reaches maximum height (50)
                    // Increase amplification so even moderate detection (20-30%) reaches top (50)
                    let amplificationFactor: Double = 3.5  // Increased from 2.5 to reach 50 more easily
                    let amplifiedLevel = currentLevel > 0 ? min(100, currentLevel * amplificationFactor) : currentLevel
                    let graphValue = max(0, min(100, amplifiedLevel + baseVariation + randomVariation))
                    
                    DispatchQueue.main.async {
                        graphData.append(graphValue)
                        if graphData.count > maxDataPoints {
                            graphData.removeFirst()
                        }
                        // Keep cursor at latest point
                        cursorPosition = 100.0
                    }
                }
            }
        }
        .onDisappear {
            detectorManager.stopDetection()
            // Stop timer when view disappears
            updateTimer?.invalidate()
            updateTimer = nil
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
    private let bottomPadding: CGFloat = 20  // Space above X-axis labels (matches GraphGrid)
    
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
                
                // Y-axis Labels - align perfectly with grid lines
                let usableTop = paddingTop
                let usableBottom = paddingTop + graphHeight - bottomPadding
                let usableHeight = usableBottom - usableTop
                
                ForEach(Array([50, 40, 30, 20, 10, 0].enumerated()), id: \.element) { index, value in
                    // Calculate Y position matching grid line exactly
                    // index 0 (value 50) at top, index 5 (value 0) at bottom
                    let lineY = usableTop + (CGFloat(5 - index) / 5.0) * usableHeight
                    
                    Text("\(value)")
                        .font(.system(size: 9.157, weight: .semibold))
                        .foregroundColor(Color(red: 124/255, green: 124/255, blue: 124/255))
                        .tracking(0.8699)
                        .offset(y: lineY - 4.5) // Center text on grid line (half font height ~9px)
                        .padding(.leading, 23.29)
                }
                
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
    // Graph area constants - should match GraphContainer
    private let graphWidth: CGFloat = 290
    private let graphHeight: CGFloat = 164
    private let paddingLeft: CGFloat = 46
    private let paddingTop: CGFloat = 68
    private let bottomPadding: CGFloat = 20  // Reduced padding for better alignment
    
    var body: some View {
        ZStack {
            // Horizontal grid lines - properly aligned with Y-axis labels
            // Graph area starts at paddingTop (68) and has graphHeight (164)
            // Space from top to useable area
            let usableTop = paddingTop
            let usableBottom = paddingTop + graphHeight - bottomPadding
            let usableHeight = usableBottom - usableTop
            
            ForEach(0..<6) { index in
                // Y-axis values: 0, 10, 20, 30, 40, 50
                // Map index 0 (value 50) to top, index 5 (value 0) to bottom
                let lineY = usableTop + (CGFloat(5 - index) / 5.0) * usableHeight
                
                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(height: 1)
                    .offset(y: lineY)
                    .padding(.horizontal, paddingLeft)
            }
            
            // Vertical grid lines - aligned with X-axis values (0, 20, 40, 60, 80, 100)
            ForEach(0..<6) { index in
                let lineX = paddingLeft + (CGFloat(index) / 5.0) * graphWidth
                
                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 1)
                    .offset(x: lineX)
                    .frame(height: graphHeight)
                    .offset(y: paddingTop)
            }
        }
    }
}

struct GraphLine: Shape {
    let data: [Double]
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        guard !data.isEmpty else { return path }
        
        // Scale based on Y-axis labels (0-50) to match graph grid
        let maxValue: Double = 50  // Y-axis shows 0-50
        let minValue: Double = 0
        
        // Use smooth curves for better graph appearance
        let stepX = data.count > 1 ? rect.width / CGFloat(data.count - 1) : 0
        
        // Normalize Y values to graph height (0 at bottom, maxValue at top)
        // Convert detection level (0-100) to graph scale (0-50) - use FULL range
        // Add offset to ensure line stays above bottom numbers (X-axis labels)
        func normalizeY(_ value: Double) -> CGFloat {
            // Scale detection level (0-100) to graph Y-axis (0-50) - ensure full range usage
            // When value = 0, scaledValue = 0 (bottom)
            // When value = 100, scaledValue = 50 (top of graph)
            let scaledValue = (value / 100.0) * maxValue
            let normalized = (scaledValue - minValue) / (maxValue - minValue)
            
            // Calculate Y position - align with grid lines
            // Bottom (0) should be at usableBottom, top (50) should be at usableTop
            let bottomPadding: CGFloat = 20  // Space above X-axis labels
            let usableTop: CGFloat = 0
            let usableBottom = rect.height - bottomPadding
            let usableHeight = usableBottom - usableTop
            
            // Map normalized value (0-1) to usable height
            // normalized 0 (bottom) = usableBottom, normalized 1 (top) = usableTop
            let yPosition = usableBottom - (CGFloat(normalized) * usableHeight)
            
            // Ensure Y stays within usable bounds
            return max(usableTop, min(usableBottom, yPosition))
        }
        
        // Start point
        if !data.isEmpty {
            let firstY = normalizeY(data[0])
            path.move(to: CGPoint(x: 0, y: firstY))
        }
        
        // Draw smooth line through all points
        if data.count > 1 {
            for index in 1..<data.count {
                let x = CGFloat(index) * stepX
                let y = normalizeY(data[index])
                path.addLine(to: CGPoint(x: x, y: y))
            }
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
        let maxValue: Double = 50  // Y-axis shows 0-50
        let minValue: Double = 0
        
        // Convert detection level (0-100) to graph scale (0-50)
        // Apply amplification to match graph line scaling
        let amplificationFactor: Double = 3.5
        let amplifiedValue = selectedValue > 0 ? min(100, selectedValue * amplificationFactor) : selectedValue
        let scaledValue = (amplifiedValue / 100.0) * maxValue
        let normalized = (scaledValue - minValue) / (maxValue - minValue)
        
        // Align with grid lines - same calculation as graph line
        let bottomPadding: CGFloat = 20  // Space above X-axis labels
        let usableTop: CGFloat = 0
        let usableBottom = graphHeight - bottomPadding
        let usableHeight = usableBottom - usableTop
        let yPosition = usableBottom - (CGFloat(normalized) * usableHeight)
        return max(usableTop, min(usableBottom, yPosition))
    }
    
    // Get the actual data point Y position for cursor alignment
    private func getYPositionForDataPoint(_ dataIndex: Int) -> CGFloat {
        guard dataIndex >= 0 && dataIndex < data.count else { return 0 }
        
        let maxValue: Double = 50  // Y-axis shows 0-50
        let value = data[dataIndex]
        let scaledValue = (value / 100.0) * maxValue
        let normalized = scaledValue / maxValue
        let yValue = CGFloat(normalized) * graphHeight
        return max(0, min(graphHeight, graphHeight - yValue))
    }
    
    var body: some View {
        GeometryReader { geometry in
            let xPosition = CGFloat(cursorPosition / 100.0) * graphWidth
            // Ensure X stays within graph bounds
            let clampedX = max(0, min(graphWidth, xPosition))
            
            // Calculate actual Y position on the graph line at this X position
            let actualYPosition = calculateYAtX(clampedX)
            
            ZStack {
                // Vertical cursor line (only within graph bounds)
                Rectangle()
                    .fill(Color(red: 124/255, green: 124/255, blue: 124/255).opacity(0.5))
                    .frame(width: 1, height: graphHeight)
                    .offset(x: clampedX)
                
                // Circle indicator at intersection with graph line
                // Ensure circle stays within graph bounds and aligns with actual line position
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
                        y: actualYPosition - 9.6
                    )
            }
        }
    }
    
    // Calculate the actual Y position on the graph line at a given X coordinate
    private func calculateYAtX(_ xPosition: CGFloat) -> CGFloat {
        let bottomPadding: CGFloat = 20  // Space above X-axis labels
        
        guard !data.isEmpty else { 
            return graphHeight - bottomPadding
        }
        
        let maxValue: Double = 50  // Y-axis shows 0-50
        let stepX = data.count > 1 ? graphWidth / CGFloat(data.count - 1) : 0
        let usableTop: CGFloat = 0
        let usableBottom = graphHeight - bottomPadding
        let usableHeight = usableBottom - usableTop
        
        if stepX == 0 || data.count == 1 {
            // Single point or no points
            let value = data[0]
            let scaledValue = (value / 100.0) * maxValue
            let normalized = scaledValue / maxValue
            let yPosition = usableBottom - (CGFloat(normalized) * usableHeight)
            return max(usableTop, min(usableBottom, yPosition))
        }
        
        // Find which two data points surround this X position
        let dataIndex = xPosition / stepX
        let lowerIndex = Int(dataIndex)
        let upperIndex = min(lowerIndex + 1, data.count - 1)
        let clampedLowerIndex = max(0, min(lowerIndex, data.count - 1))
        
        let value: Double
        if clampedLowerIndex == upperIndex {
            value = data[clampedLowerIndex]
        } else {
            // Linear interpolation between two points
            let fraction = dataIndex - Double(clampedLowerIndex)
            let lowerValue = data[clampedLowerIndex]
            let upperValue = data[upperIndex]
            value = lowerValue * (1 - fraction) + upperValue * fraction
        }
        
        let scaledValue = (value / 100.0) * maxValue
        let normalized = scaledValue / maxValue
        let yPosition = usableBottom - (CGFloat(normalized) * usableHeight)
        return max(usableTop, min(usableBottom, yPosition))
    }
}

#Preview {
    GraphView(onBackTap: {})
}

