//
//  PaywallView.swift
//  Metal Detector IOS
//
//  Created by Lowbyte Studio on 27/11/2025.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @StateObject private var iapManager = IAPManager.shared
    var onClose: () -> Void
    var onGoPremium: () -> Void
    var onContinueFree: () -> Void
    @State private var rotationAngle: Double = 0
    @State private var animationTimer: Timer?
    @State private var isPurchasing = false
    @State private var isRestoring = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showRestoreAlert = false
    @State private var restoreMessage = ""
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 18/255, green: 18/255, blue: 18/255)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Section with Close Button
                HStack {
                    Spacer()
                    
                    // Close Button
                    Button(action: {
                        onClose()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                    }
                    .padding(.trailing, 15)
                    .padding(.top, 20)
                }
                
                Spacer()
                    .frame(height: 4)
                
                // Title Section with Surrounding Icons
                ZStack {
                    // Title Text
                    VStack(spacing: 0) {
                        Text(LocalizedString.metalDetector.localized)
                            .font(.custom("Zodiak", size: 25))
                            .foregroundColor(.white)
                            .tracking(-1.5)
                            .id(localizationManager.currentLanguage)
                        
                        // Premium Badge
                        Text(LocalizedString.premium.localized)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.white)
                            .id(localizationManager.currentLanguage)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color(red: 32/255, green: 32/255, blue: 32/255))
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .padding(.top, 12)
                    }
                    .offset(y: 20)
                    
                    // Icon 1 - Top Left (Metal Links) - Rotating around center
                    RotatingIcon(
                        iconName: "Paywall Icon 1",
                        radius: 140,
                        angle: 150,
                        baseRotation: $rotationAngle,
                        borderColor: Color(red: 167/255, green: 167/255, blue: 167/255).opacity(0.1),
                        borderWidth: 0.748
                    )
                    
                    // Icon 2 - Top Center (Gold Coin) - Rotating around center
                    RotatingIcon(
                        iconName: "Paywall Icon 2",
                        radius: 140,
                        angle: 90,
                        baseRotation: $rotationAngle,
                        borderColor: Color(red: 255/255, green: 224/255, blue: 102/255).opacity(0.1),
                        borderWidth: 0.847
                    )
                    
                    // Icon 3 - Top Right (Screw/Bolt) - Rotating around center
                    RotatingIcon(
                        iconName: "Paywall Icon 3",
                        radius: 140,
                        angle: 30,
                        baseRotation: $rotationAngle,
                        borderColor: Color(red: 167/255, green: 167/255, blue: 167/255).opacity(0.1),
                        borderWidth: 1
                    )
                    
                    // Icon 4 - Mid Left (Metal Detector Wand) - Rotating around center
                    RotatingIcon(
                        iconName: "Paywall Icon 4",
                        radius: 140,
                        angle: 210,
                        baseRotation: $rotationAngle,
                        borderColor: Color(red: 167/255, green: 167/255, blue: 167/255).opacity(0.1),
                        borderWidth: 0.802
                    )
                    
                    // Icon 5 - Mid Right (Compass) - Rotating around center
                    RotatingIcon(
                        iconName: "Paywall Icon 5",
                        radius: 140,
                        angle: 330,
                        baseRotation: $rotationAngle,
                        borderColor: Color(red: 167/255, green: 167/255, blue: 167/255).opacity(0.1),
                        borderWidth: 0.802
                    )
                    
                    // Icon 6 - Bottom Center (Spirit Level) - Rotating around center
                    RotatingIcon(
                        iconName: "Paywall Icon 6",
                        radius: 140,
                        angle: 270,
                        baseRotation: $rotationAngle,
                        borderColor: Color(red: 255/255, green: 224/255, blue: 102/255).opacity(0.1),
                        borderWidth: 1
                    )
                }
                .frame(height: 300)
                .onDisappear {
                    // Clean up timer when view disappears
                    animationTimer?.invalidate()
                }
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LanguageChanged"))) { _ in
                    // Force view refresh when language changes
                }
                
                // What's Included Section
                VStack(alignment: .leading, spacing: 24) {
                    // Section Title
                    HStack {
                        Text(LocalizedString.whatsIncluded.localized)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .id(localizationManager.currentLanguage)
                        
                        Spacer()
                        
                        // Dotted line
                        HStack(spacing: 4) {
                            ForEach(0..<20) { _ in
                                Circle()
                                    .fill(Color.white.opacity(0.12))
                                    .frame(width: 2, height: 2)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Features List
                    VStack(alignment: .leading, spacing: 16) {
                        FeatureRow(localizedKey: LocalizedString.removeAds)
                        FeatureRow(localizedKey: LocalizedString.unlimitedScanning)
                        FeatureRow(localizedKey: LocalizedString.ultraAccurateDetection)
                        FeatureRow(localizedKey: LocalizedString.goldPreciousMetalScanner)
                        FeatureRow(localizedKey: LocalizedString.helpSupport24_7)
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.top, 26)
                
                Spacer()
                
                // Go Premium Button Section
                VStack(spacing: 12) {
                    // Go Premium Button (background from assets) with real price
                    Button(action: {
                        handlePurchase()
                    }) {
                        ZStack {
                            // Button background from assets
                            Image("Go Premium Button Background")
                                .resizable()
                                .scaledToFill()
                                .frame(height: 56)
                                .clipShape(RoundedRectangle(cornerRadius: 58.76))
                            
                            // Show real price or loading state or subscription status
                            if iapManager.isPremium {
                                // User already subscribed
                                Text("You already subscribed")
                                    .font(.custom("Manrope_Bold", size: 16))
                                    .foregroundColor(Color(red: 21/255, green: 21/255, blue: 21/255))
                                    .id(localizationManager.currentLanguage + "_subscribed")
                            } else if isPurchasing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 21/255, green: 21/255, blue: 21/255)))
                            } else if let product = iapManager.monthlyProduct {
                                // Show "Get premium for" + real price from StoreKit
                                Text("\(LocalizedString.getPremium.localized) for \(product.displayPrice)/\(LocalizedString.month.localized)")
                                    .font(.custom("Manrope_Bold", size: 16))
                                    .foregroundColor(Color(red: 21/255, green: 21/255, blue: 21/255))
                                    .id(localizationManager.currentLanguage + "_premium_price")
                            } else {
                                // Fallback if product not loaded
                                Text(LocalizedString.goPremiumFor6DollarsMonth.localized)
                                    .font(.custom("Manrope_Bold", size: 16))
                                    .id(localizationManager.currentLanguage)
                                    .foregroundColor(Color(red: 21/255, green: 21/255, blue: 21/255))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                    }
                    .disabled(iapManager.isPremium || isPurchasing || iapManager.isLoading)
                    
                    // Continue for free
                    Button(action: {
                        onContinueFree()
                    }) {
                        Text(LocalizedString.orContinueForFree.localized)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .id(localizationManager.currentLanguage)
                    }
                    
                    // Restore Purchases Button
                    Button(action: {
                        handleRestore()
                    }) {
                        HStack(spacing: 8) {
                            if isRestoring {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white.opacity(0.6)))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            
                            Text(isRestoring ? LocalizedString.restoring.localized : LocalizedString.restorePurchases.localized)
                                .font(.system(size: 14, weight: .medium))
                                .id(localizationManager.currentLanguage + (isRestoring ? "_restoring" : "_restore"))
                        }
                        .foregroundColor(.white.opacity(0.6))
                    }
                    .disabled(isRestoring)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            // Start loading animation
            startRotationAnimation()
            
            // Check subscription status
            Task {
                await iapManager.updatePurchasedProducts()
            }
            
            // Load products when view appears
            if iapManager.products.isEmpty {
                Task {
                    await iapManager.loadProducts()
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .alert("Restore Purchases", isPresented: $showRestoreAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(restoreMessage)
        }
    }
    
    private func startRotationAnimation() {
        // Reset to 0 first
        rotationAngle = 0
        
        // Stop any existing timer
        animationTimer?.invalidate()
        
        // Use a timer to continuously update rotation angle (60 FPS)
        animationTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { _ in
            DispatchQueue.main.async {
                self.rotationAngle += 0.2 // 360 degrees / (30 seconds * 60 FPS) ≈ 0.2 per frame
                if self.rotationAngle >= 360 {
                    self.rotationAngle = 0 // Reset to keep it continuous
                }
            }
        }
    }
    
    // MARK: - Handle Purchase
    private func handlePurchase() {
        guard let product = iapManager.monthlyProduct else {
            errorMessage = "Product not available. Please try again."
            showError = true
            return
        }
        
        isPurchasing = true
        
        Task {
            do {
                let success = try await iapManager.purchase(product)
                await MainActor.run {
                    isPurchasing = false
                    if success {
                        onGoPremium()
                    }
                }
            } catch {
                await MainActor.run {
                    isPurchasing = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
    
    // MARK: - Handle Restore
    private func handleRestore() {
        guard !isRestoring else { return }
        
        isRestoring = true
        
        Task {
            let wasPremium = iapManager.isPremium
            await iapManager.restorePurchases()
            
            await MainActor.run {
                isRestoring = false
                
                // Check if there was an error
                if let errorMsg = iapManager.errorMessage {
                    restoreMessage = errorMsg
                    iapManager.errorMessage = nil // Clear error after showing
                } else if iapManager.isPremium {
                    if wasPremium {
                        restoreMessage = LocalizedString.purchasesRestored.localized
                    } else {
                        restoreMessage = LocalizedString.purchasesRestored.localized
                        // If user successfully restored and wasn't premium before, trigger premium callback
                        onGoPremium()
                    }
                } else {
                    restoreMessage = LocalizedString.noPurchasesFound.localized
                }
                
                showRestoreAlert = true
            }
        }
    }
}

struct FeatureRow: View {
    let localizedKey: String
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        HStack(spacing: 12) {
            // Checkmark Icon
            Image("Checklist Icon") // User will provide asset name
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
            
            Text(localizedKey.localized)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .id(localizationManager.currentLanguage + "_" + localizedKey)
        }
    }
}

struct RotatingIcon: View {
    let iconName: String
    let radius: CGFloat
    let angle: Double // Starting angle in degrees (0 = right, 90 = top, etc.)
    @Binding var baseRotation: Double // Current rotation angle (must be Binding)
    let borderColor: Color
    let borderWidth: CGFloat
    
    // Calculate position based on angle and radius
    private var xOffset: CGFloat {
        let totalAngle = angle + baseRotation
        let angleInRadians = totalAngle * .pi / 180
        return radius * cos(angleInRadians)
    }
    
    private var yOffset: CGFloat {
        let totalAngle = angle + baseRotation
        let angleInRadians = totalAngle * .pi / 180
        // Negate Y because in SwiftUI, Y increases downward
        return -radius * sin(angleInRadians)
    }
    
    var body: some View {
        Image(iconName)
            .resizable()
            .scaledToFit()
            .frame(width: 76, height: 76)
            .overlay(
                Circle()
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .offset(x: xOffset, y: yOffset)
    }
}

#Preview {
    PaywallView(
        onClose: {},
        onGoPremium: {},
        onContinueFree: {}
    )
}

