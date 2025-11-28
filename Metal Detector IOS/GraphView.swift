//
//  GraphView.swift
//  Metal Detector IOS
//
//  Created by Lowbyte Studio on 27/11/2025.
//

import SwiftUI

struct GraphView: View {
    var onBackTap: () -> Void
    @State private var graphData: [Double] = [5, 12, 8, 25, 18, 35, 28, 45, 38, 30, 42, 48]
    @State private var cursorPosition: Double = 60.0 // X position of cursor (0-100)
    
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
                    
                    Text("Graph view")
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
                    Text("No Gold detected,")
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                    
                    Text("Please check thoroughly")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.top, 36)
                
                Spacer()
                
                Spacer()
                    .frame(height: 40)
            }
        }
    }
}

struct GraphContainer: View {
    let data: [Double]
    @Binding var cursorPosition: Double
    
    // Computed properties for cursor
    private var selectedValue: Double {
        let index = (cursorPosition / 100.0) * Double(data.count - 1)
        let lowerIndex = Int(index)
        let upperIndex = min(lowerIndex + 1, data.count - 1)
        let fraction = index - Double(lowerIndex)
        
        if lowerIndex == upperIndex {
            return data[lowerIndex]
        }
        
        return data[lowerIndex] * (1 - fraction) + data[upperIndex] * fraction
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

