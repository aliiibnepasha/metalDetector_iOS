//
//  SettingsView.swift
//  Metal Detector IOS
//
//  Created by Lowbyte Studio on 27/11/2025.
//

import SwiftUI
import SafariServices

struct SettingsView: View {
    @State private var rotationAngle: Double = 0
    @State private var showPrivacyPolicy = false
    @State private var showTermsOfUse = false
    @State private var showShareSheet = false
    @State private var showRatingPopup = false
    @StateObject private var localizationManager = LocalizationManager.shared
    @StateObject private var iapManager = IAPManager.shared
    @State private var isRestoring = false
    @State private var showRestoreAlert = false
    @State private var restoreMessage = ""
    var onBackTap: () -> Void
    var onGetPremiumTap: (() -> Void)? = nil
    var onLanguageTap: (() -> Void)? = nil
    
    private let privacyPolicyURL = URL(string: "https://theswiftvision.com/privacy-policy.html")!
    private let termsOfUseURL = URL(string: "https://theswiftvision.com/terms-of-service.html")!
    
    private let shareText = "Check out Metal Detector App! 🔍"
    private let shareURL = URL(string: "https://apps.apple.com/app/id")! // Add your App Store URL here
    private let appStoreURL = URL(string: "https://apps.apple.com/app/id")! // Add your App Store URL here
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.07, green: 0.07, blue: 0.07) // #111112
                .ignoresSafeArea()
                .onAppear {
                    // Log settings opened event
                    FirebaseManager.logEvent("settings_opened")
                }
            
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
                        
                        Text(LocalizedString.setting.localized)
                            .font(.custom("Zodiak", size: 24))
                            .foregroundColor(.white)
                            .id(localizationManager.currentLanguage) // Force refresh on language change
                        
                        Spacer()
                    }
                    .padding(.leading, 8)
                    .padding(.trailing, 24)
                    .padding(.top, 30)
                    .padding(.bottom, 24)
                    
                    // Premium Card
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(red: 0.17, green: 0.17, blue: 0.17)) // #2b2b2b
                            .frame(height: 168)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(LocalizedString.metalDetector.localized)
                                    .font(.custom("Manrope_Bold", size: 18))
                                    .foregroundColor(.white)
                                
                                Text(LocalizedString.detectHiddenTreasuresFaster.localized)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                                    .lineLimit(3)
                                
                                // Get Premium Button
                                Button(action: {
                                    FirebaseManager.logEvent("settings_get_premium_tapped")
                                    onGetPremiumTap?()
                                }) {
                                    ZStack {
                                        // Background from assets
                                        Image("Get Premium Button Background")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 130, height: 44)
                                            .clipShape(RoundedRectangle(cornerRadius: 18.76))
                                        
                                        HStack(spacing: 4) {
                                            Image("VIP Icon")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 18, height: 18)
                                            
                                            Text(LocalizedString.getPremium.localized)
                                                .font(.custom("Manrope_Bold", size: 12.94))
                                                .foregroundColor(.black)
                                                
                                                .tracking(-0.78)
                                        }
                                    }
                                    .frame(width: 130, height: 44)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 24)
                            
                            Spacer()
                            
                            // Premium Image with rotation animation
                            Image("Premium Image")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 160, height: 160)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .rotationEffect(.degrees(rotationAngle))
                                .padding(.trailing, 20)
                                .onAppear {
                                    withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                                        rotationAngle = 360
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                    
                    // Settings List Card
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(red: 0.17, green: 0.17, blue: 0.17)) // #2b2b2b
                            .frame(height: 320)
                        
                        VStack(spacing: 0) {
                            // Language
                            SettingsRow(
                                iconName: "Language Icon",
                                title: LocalizedString.language.localized,
                                rightText: LocalizedString.defaultLabel.localized,
                                onTap: {
                                    FirebaseManager.logEvent("settings_language_tapped")
                                    onLanguageTap?()
                                }
                            )
                            
                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.horizontal, 20)
                            
                            // Share
                            SettingsRow(
                                iconName: "Share Icon",
                                title: LocalizedString.share.localized,
                                onTap: {
                                    FirebaseManager.logEvent("settings_share_tapped")
                                    showShareSheet = true
                                }
                            )
                            
                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.horizontal, 20)
                            
                            // Rate
                            SettingsRow(
                                iconName: "Rate Icon",
                                title: LocalizedString.rate.localized,
                                onTap: {
                                    FirebaseManager.logEvent("settings_rate_tapped")
                                    showRatingPopup = true
                                }
                            )
                            
                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.horizontal, 20)
                            
                            // Privacy Policy
                            SettingsRow(
                                iconName: "Privacy Icon",
                                title: LocalizedString.privacyPolicy.localized,
                                onTap: {
                                    FirebaseManager.logEvent("settings_privacy_policy_tapped")
                                    showPrivacyPolicy = true
                                }
                            )
                            
                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.horizontal, 20)
                            
                            // Terms of Use
                            SettingsRow(
                                iconName: "Terms Icon",
                                title: LocalizedString.termsOfUse.localized,
                                onTap: {
                                    FirebaseManager.logEvent("settings_terms_of_use_tapped")
                                    showTermsOfUse = true
                                }
                            )
                            
                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.horizontal, 20)
                            
                            // Restore Purchases
                            SettingsRow(
                                iconName: "arrow.clockwise",
                                title: LocalizedString.restore.localized,
                                isSystemIcon: true,
                                isLoading: isRestoring,
                                onTap: {
                                    handleRestore()
                                }
                            )
                        }
                        .padding(.vertical, 24)
                    }
                    .padding(.horizontal, 24)
                
                Spacer() // Push content to top
            }
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            SafariView(url: privacyPolicyURL)
        }
        .sheet(isPresented: $showTermsOfUse) {
            SafariView(url: termsOfUseURL)
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [shareText, shareURL])
        }
        .overlay {
            if showRatingPopup {
                RatingPopupView(
                    onRateUs: {
                        // Open App Store for rating
                        if UIApplication.shared.canOpenURL(appStoreURL) {
                            UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
                        }
                        showRatingPopup = false
                    },
                    onNotNow: {
                        showRatingPopup = false
                    },
                    onClose: {
                        showRatingPopup = false
                    }
                )
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.0).combined(with: .opacity),
                    removal: .scale(scale: 0.0).combined(with: .opacity)
                ))
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showRatingPopup)
            }
        }
        .alert("Restore Purchases", isPresented: $showRestoreAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(restoreMessage)
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
                    }
                } else {
                    restoreMessage = LocalizedString.noPurchasesFound.localized
                }
                
                showRestoreAlert = true
            }
        }
    }
}

// MARK: - Safari View Wrapper
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // No updates needed
    }
}

// MARK: - Share Sheet Wrapper
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        
        // For iPad support - prevent crash on iPad
        if let popover = controller.popoverPresentationController {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            let window = windowScene?.windows.first
            popover.sourceView = window
            popover.sourceRect = CGRect(
                x: UIScreen.main.bounds.width / 2,
                y: UIScreen.main.bounds.height / 2,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
}

// MARK: - Rating Popup View
struct RatingPopupView: View {
    @State private var selectedRating: Int = 0
    @State private var appearScale: CGFloat = 0.0
    @StateObject private var localizationManager = LocalizationManager.shared
    let onRateUs: () -> Void
    let onNotNow: () -> Void
    let onClose: () -> Void
    
    var body: some View {
        ZStack {
            // Backdrop with subtle blur only (no white/grey tint)
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .blur(radius: 2)
                .onTapGesture {
                    onClose()
                }
            
            // Popup Card
            VStack(spacing: 0) {
                // Close Button (Top Right)
                HStack {
                    Spacer()
                    Button(action: {
                        onClose()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 16)
                }
                
                Spacer()
                    .frame(height: 24)
                
                // Large Golden Star Icon
                ZStack {
                    // Glowing circle background
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.85, blue: 0.0).opacity(0.3),
                                    Color(red: 1.0, green: 0.85, blue: 0.0).opacity(0.1)
                                ]),
                                center: .center,
                                startRadius: 20,
                                endRadius: 50
                            )
                        )
                        .frame(width: 100, height: 100)
                        .blur(radius: 10)
                    
                    Circle()
                        .fill(Color(red: 1.0, green: 0.85, blue: 0.0).opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "star.fill")
                        .font(.system(size: 48, weight: .medium))
                        .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.0))
                }
                .padding(.bottom, 24)
                
                // Question Text
                Text(LocalizedString.howDoYouFeelAboutApp.localized)
                    .font(.custom("Zodiak", size: 18))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                    .id(localizationManager.currentLanguage)
                
                // Stars Rating
                HStack(spacing: 16) {
                    ForEach(1...5, id: \.self) { index in
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                selectedRating = index
                            }
                        }) {
                            Image(systemName: index <= selectedRating ? "star.fill" : "star")
                                .font(.system(size: 32))
                                .foregroundColor(
                                    index <= selectedRating 
                                    ? Color(red: 1.0, green: 0.85, blue: 0.0) 
                                    : Color.white.opacity(0.3)
                                )
                                .scaleEffect(index <= selectedRating ? 1.1 : 1.0)
                                .animation(.spring(response: 0.2), value: selectedRating)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                
                // Buttons
                VStack(spacing: 16) {
                    // Rate Us Button
                    Button(action: {
                        onRateUs()
                    }) {
                        ZStack {
                            // Button background from assets (same as Go Premium button)
                            Image("Go Premium Button Background")
                                .resizable()
                                .scaledToFill()
                                .frame(height: 56)
                                .clipShape(RoundedRectangle(cornerRadius: 58.76))
                            
                            Text(LocalizedString.rateUs.localized)
                                .font(.custom("Manrope_Bold", size: 16))
                                .foregroundColor(Color(red: 21/255, green: 21/255, blue: 21/255))
                                .id(localizationManager.currentLanguage)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                    }
                    
                    // Not Now Button
                    Button(action: {
                        onNotNow()
                    }) {
                        Text(LocalizedString.notNow.localized)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                            .id(localizationManager.currentLanguage)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.17, green: 0.17, blue: 0.17)) // #2b2b2b
            )
            .frame(width: 320)
            .scaleEffect(appearScale)
            .opacity(appearScale > 0 ? 1 : 0)
            .padding(.horizontal, 40) // Increased left/right padding for more space
            .onAppear {
                // Animate from 0% to 100% scale
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    appearScale = 1.0
                }
            }
        }
    }
}

struct SettingsRow: View {
    let iconName: String
    let title: String
    var rightText: String? = nil
    var isSystemIcon: Bool = false
    var isLoading: Bool = false
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
            onTap?()
        }) {
            HStack {
                if isSystemIcon {
                    Image(systemName: iconName)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24)
                } else {
                    Image(iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else if let rightText = rightText {
                    Text(rightText)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isLoading)
    }
}

#Preview {
    SettingsView(onBackTap: {})
}

