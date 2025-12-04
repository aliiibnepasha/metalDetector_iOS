//
//  AdShimmerView.swift
//  Metal Detector IOS
//
//  Created by Lowbyte Studio on 27/11/2025.
//

import SwiftUI

struct AdShimmerView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Background rectangle
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 0.2, green: 0.2, blue: 0.2))
                .frame(height: 50)
            
            // Shimmer effect
            GeometryReader { geometry in
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.clear,
                        Color.white.opacity(0.3),
                        Color.clear
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: geometry.size.width * 0.6)
                .offset(x: isAnimating ? geometry.size.width : -geometry.size.width * 0.6)
                .animation(
                    Animation.linear(duration: 1.5)
                        .repeatForever(autoreverses: false),
                    value: isAnimating
                )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}



