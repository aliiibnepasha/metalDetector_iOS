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
    @State private var isPurchasing = false
    @State private var isRestoring = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showRestoreAlert = false
    @State private var restoreMessage = ""
    
    var body: some View {
        ZStack {
            // Background - Black
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Background Image - Half Screen Only
                ZStack {
                    Image("paywall_bg")
                        .resizable()
                        .scaledToFill()
                        .frame(height: UIScreen.main.bounds.height * 0.5)
                        .clipped()
                        .overlay(
                            // Black gradient from top and bottom (darker at edges for perfect blend)
                            ZStack {
                                // Top gradient (darker for perfect blend with black background)
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: Color.black.opacity(0.9), location: 0.0),
                                        .init(color: Color.black.opacity(0.7), location: 0.15),
                                        .init(color: Color.black.opacity(0.4), location: 0.3),
                                        .init(color: Color.black.opacity(0.0), location: 0.5)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                
                                // Bottom gradient (darker for perfect blend with background)
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: Color.black.opacity(0.0), location: 0.5),
                                        .init(color: Color.black.opacity(0.3), location: 0.7),
                                        .init(color: Color.black.opacity(0.7), location: 0.85),
                                        .init(color: Color.black.opacity(0.95), location: 1.0)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            }
                        )
                    
                    // Close Button - Overlay on image (moved down)
                    VStack {
                        Spacer()
                            .frame(height: 50) // Add space from top
                        
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                onClose()
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.white)
                            }
                            .padding(.trailing, 19)
                        }
                        
                        Spacer()
                    }
                }
                .frame(height: UIScreen.main.bounds.height * 0.5)
                
                // What's Included Section - positioned lower in darker area
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
                .padding(.top, 40)
                
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
                        // Log continue for free event
                        FirebaseManager.logEvent("paywall_continue_free")
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
            // Log paywall opened event
            FirebaseManager.logEvent("paywall_opened")
            
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
    
    // MARK: - Handle Purchase
    private func handlePurchase() {
        guard let product = iapManager.monthlyProduct else {
            errorMessage = "Product not available. Please try again."
            showError = true
            return
        }
        
        // Log purchase initiated event
        FirebaseManager.logEvent("paywall_purchase_initiated", parameters: ["product_id": product.id, "price": product.displayPrice])
        
        isPurchasing = true
        
        Task {
            do {
                let success = try await iapManager.purchase(product)
                await MainActor.run {
                    isPurchasing = false
                    if success {
                        // Log purchase success event
                        FirebaseManager.logEvent("paywall_purchase_success", parameters: ["product_id": product.id, "price": product.displayPrice])
                        onGoPremium()
                    } else {
                        // Log purchase cancelled event
                        FirebaseManager.logEvent("paywall_purchase_cancelled")
                    }
                }
            } catch {
                await MainActor.run {
                    isPurchasing = false
                    // Log purchase failed event
                    FirebaseManager.logEvent("paywall_purchase_failed", parameters: ["error": error.localizedDescription])
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
    
    // MARK: - Handle Restore
    private func handleRestore() {
        guard !isRestoring else { return }
        
        // Log restore initiated event
        FirebaseManager.logEvent("paywall_restore_initiated")
        
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
                    // Log restore success event
                    FirebaseManager.logEvent("paywall_restore_success")
                    if wasPremium {
                        restoreMessage = LocalizedString.purchasesRestored.localized
                    } else {
                        restoreMessage = LocalizedString.purchasesRestored.localized
                        // If user successfully restored and wasn't premium before, trigger premium callback
                        onGoPremium()
                    }
                } else {
                    // Log restore no purchases found event
                    FirebaseManager.logEvent("paywall_restore_no_purchases")
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

#Preview {
    PaywallView(
        onClose: {},
        onGoPremium: {},
        onContinueFree: {}
    )
}

