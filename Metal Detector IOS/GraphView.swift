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
    @StateObject private var adManager = AdManager.shared
    @StateObject private var iapManager = IAPManager.shared
    @State private var graphData: [Double] = []
    @State private var maxDataPoints = 100 // Keep last 100 readings for smoother graph
    @State private var soundEnabled = true
    @State private var vibrationEnabled = true
    @State private var updateTimer: Timer?
    @State private var isBottomAdLoading = true
    
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
                        // Log backpress event
                        let detectorPrefix = getDetectorPrefix()
                        if !detectorPrefix.isEmpty {
                            FirebaseManager.logEvent("\(detectorPrefix)_graph_view_ui_backpress")
                        }
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
                        // Log sound event
                        let detectorPrefix = getDetectorPrefix()
                        if !detectorPrefix.isEmpty {
                            let eventName = soundEnabled ? "\(detectorPrefix)_graph_view_sound" : "\(detectorPrefix)_graph_view_silent"
                            FirebaseManager.logEvent(eventName)
                        }
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
                        // Log vibrate event
                        let detectorPrefix = getDetectorPrefix()
                        if !detectorPrefix.isEmpty {
                            let eventName = vibrationEnabled ? "\(detectorPrefix)_graph_view_vibrate_on" : "\(detectorPrefix)_graph_view_vibrate_off"
                            FirebaseManager.logEvent(eventName)
                        }
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
                GraphContainer(data: graphData)
                .frame(width: 380, height: 325)
                .padding(.top, 0)
                
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
            // Set current view for event logging
            detectorManager.setCurrentView("graph_view")
            detectorManager.startDetection()
            // Initialize with empty array - will fill with real data
            graphData = []
            // Sync with detectorManager
            soundEnabled = detectorManager.soundEnabled
            vibrationEnabled = detectorManager.vibrationEnabled
            
            // Pre-load interstitial ad for future use
            adManager.loadGeneralInterstitial()
            
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
                    // Map detection level to graph range (0-50) - matching Android approach
                    // Android maps sensor values (40-330 µT) to (0-50)
                    // We'll map detection level (0-100%) to (0-50) with proper scaling
                    let amplificationFactor: Double = 2.0  // Scale to use full range
                    let amplifiedLevel = currentLevel > 0 ? min(100, currentLevel * amplificationFactor) : currentLevel
                    // Add natural frequency variations for realistic graph
                    let graphValue = max(0, min(100, amplifiedLevel + baseVariation + randomVariation))
                    
                    DispatchQueue.main.async {
                        graphData.append(graphValue)
                        if graphData.count > maxDataPoints {
                            graphData.removeFirst()
                        }
                    }
                }
            }
        }
        .onDisappear {
            // Log phone backpress event (system back gesture)
            let detectorPrefix = getDetectorPrefix()
            if !detectorPrefix.isEmpty {
                FirebaseManager.logEvent("\(detectorPrefix)_graph_view_phone_backpress")
            }
            detectorManager.stopDetection()
            // Stop timer when view disappears
            updateTimer?.invalidate()
            updateTimer = nil
        }
    }
    
    // MARK: - Helper Methods
    private func getDetectorPrefix() -> String {
        switch detectorManager.currentDetectorTitle.lowercased() {
        case "gold detector":
            return "gold"
        case "metal detector":
            return "metal"
        case "stud finder":
            return "stud"
        default:
            return ""
        }
    }
}

struct GraphContainer: View {
    let data: [Double]
    
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
                // Grid Lines (drawn first, behind everything)
                GraphGrid()
                
                // Y-axis Labels - same as X-axis: 0, 20, 40, 60, 80, 100
                // Aligned from bottom like X-axis
                // Graph area: paddingTop (68) to paddingTop + graphHeight (232)
                // Total height: 164 pixels, divided into 5 intervals for 6 labels
                let graphBottom = paddingTop + graphHeight // 232
                let graphTop = paddingTop // 68
                let graphHeight = 164.0
                let labelSpacing = graphHeight / 5.0 // 32.8 pixels spacing
                
                ForEach(Array([0, 20, 40, 60, 80, 100].enumerated()), id: \.element) { index, value in
                    // Calculate Y position: 0 at bottom, 100 at top
                    // Bottom label (0) at graphBottom, top label (100) at graphTop
                    let labelY = graphBottom - (CGFloat(index) * labelSpacing)
                    Text("\(value)")
                        .font(.system(size: 9.157, weight: .semibold))
                        .foregroundColor(.white) // White labels matching Android
                        .tracking(0.8699)
                        .offset(y: labelY - 4.5) // Center text on label position (half font height)
                        .padding(.leading, 23.29)
                }
                
                // X-axis Labels - (0, 20, 40, 60, 80, 100)
                HStack(spacing: 44) {
                    ForEach([0, 20, 40, 60, 80, 100], id: \.self) { value in
                        Text("\(value)")
                            .font(.system(size: 9.157, weight: .semibold))
                            .foregroundColor(.white) // White labels matching Android
                            .tracking(0.8699)
                    }
                }
                .padding(.leading, 46.93)
                .padding(.top, 246.66)
                
                // Graph Area - Golden Yellow Line
                ZStack {
                    // Graph Line - Golden Yellow (matching Android: 0xFFFFD700)
                    if !data.isEmpty {
                        GraphLine(data: data)
                            .stroke(
                                Color(red: 1.0, green: 0.843, blue: 0.0), // Golden Yellow #FFD700
                                style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                            )
                            .frame(width: graphWidth, height: graphHeight)
                            .padding(.leading, paddingLeft)
                            .padding(.top, paddingTop)
                    }
                    
                    // Latest Point - Vertical Line and Circular Marker (matching Android)
                    if !data.isEmpty {
                        let latestValue = data.last!
                        let graphBottom = paddingTop + graphHeight // 232
                        let graphTop = paddingTop // 68
                        let usableHeight = graphHeight // 164
                        
                        // Calculate latest point position - value is already 0-100, map to graph height
                        let normalized = latestValue / 100.0 // 0-1 range
                        let markerY = graphBottom - (CGFloat(normalized) * usableHeight)
                        let markerX = paddingLeft + graphWidth // Latest point at right edge
                        
                        // Vertical white line from marker to top
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 2, height: graphTop - 10) // Line from top to just above marker
                            .offset(x: markerX, y: (graphTop - 10) / 2)
                        
                        // Circular marker - Yellow outer with white center
                        ZStack {
                            // Outer yellow circle
                            Circle()
                                .fill(Color(red: 1.0, green: 0.843, blue: 0.0))
                                .frame(width: 18, height: 18)
                            
                            // Inner white circle
                            Circle()
                                .fill(Color.white)
                                .frame(width: 10, height: 10)
                        }
                        .offset(x: markerX - 9, y: markerY - 9)
                        
                        // Label above - "Day X-Yk" format (matching Android)
                        let dayNumber = data.count
                        let valueK = latestValue / 10.0
                        Text(String(format: "Day %d-%.1fk", dayNumber, valueK))
                            .font(.system(size: 11.446, weight: .semibold))
                            .foregroundColor(.white)
                            .tracking(1.0873)
                            .offset(
                                x: markerX - 40,
                                y: graphTop - 25
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
    
    var body: some View {
        ZStack {
            // Horizontal grid lines - aligned with Y-axis labels (0, 20, 40, 60, 80, 100)
            // Move all lines up by adjusting the bottom position
            let graphBottom = paddingTop + graphHeight // 232
            let graphTop = paddingTop // 68
            let graphHeightValue = 164.0
            let labelSpacing = graphHeightValue / 5.0 // 32.8 pixels spacing
            let upShift: CGFloat = 82 // Move horizontal lines up by 82 pixels
            let verticalUpShift: CGFloat = 4 // Move vertical lines down (less up shift = more down)
            
            ForEach(0..<6) { index in
                // Calculate grid line Y position to perfectly align with labels
                // Index 0 = label 0 (bottom), Index 5 = label 100 (top)
                // Shift all lines up
                let lineY = (graphBottom - (CGFloat(index) * labelSpacing)) - upShift
                
                Rectangle()
                    .fill(Color.white.opacity(0.5)) // Matching Android: gray with 0.5 alpha
                    .frame(height: 1)
                    .offset(y: lineY)
                    .padding(.horizontal, paddingLeft)
            }
            
            // Vertical grid lines - Only keep the rightmost line (at 100 position)
            // Remove first 2 lines, keep only the last one
            let lineX = paddingLeft + graphWidth // Rightmost position (100)
            
            Rectangle()
                .fill(Color.white.opacity(0.5)) // Matching Android: gray with 0.5 alpha
                .frame(width: 1, height: graphHeight)
                .offset(x: lineX, y: paddingTop - verticalUpShift)
            
            // X-axis line at bottom (horizontal line) - matching Android
            Rectangle()
                .fill(Color.white)
                .frame(height: 2)
                .offset(y: paddingTop + graphHeight)
                .padding(.horizontal, paddingLeft)
        }
    }
}

struct GraphLine: Shape {
    let data: [Double]
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        guard !data.isEmpty else { return path }
        
        // Scale based on Y-axis labels (0-100) to match graph grid
        let maxValue: Double = 100  // Y-axis shows 0-100 (same as X-axis)
        let minValue: Double = 0
        
        // Use smooth curves for better graph appearance
        let stepX = data.count > 1 ? rect.width / CGFloat(data.count - 1) : 0
        
        // Normalize Y values to graph height (0 at bottom, maxValue at top)
        // Convert detection level (0-100) to graph scale (0-50) - use FULL range
        // Add offset to ensure line stays above bottom numbers (X-axis labels)
        func normalizeY(_ value: Double) -> CGFloat {
            // Scale detection level (0-100) to graph Y-axis (0-100) - ensure full range usage
            // When value = 0, scaledValue = 0 (bottom)
            // When value = 100, scaledValue = 100 (top of graph)
            let scaledValue = value // Already in 0-100 range, no scaling needed
            let normalized = (scaledValue - minValue) / (maxValue - minValue)
            
            // Calculate Y position - align with grid lines perfectly
            // Y-axis labels: 0, 20, 40, 60, 80, 100 with spacing of graphHeight/5
            let graphBottom = rect.height - 20 // Leave bottom padding for X-axis labels
            let graphTop: CGFloat = 0
            let usableHeight = graphBottom - graphTop
            let downShift: CGFloat = 20 // Shift line down slightly
            
            // Map normalized value (0-1) to label-aligned positions
            // normalized 0 (bottom, value 0) = graphBottom, normalized 1 (top, value 100) = graphTop
            // Add downShift to move line down
            let yPosition = graphBottom - (CGFloat(normalized) * usableHeight) + downShift
            
            // Ensure Y stays within bounds
            return max(graphTop, min(graphBottom + downShift, yPosition))
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


#Preview {
    GraphView(onBackTap: {})
}

