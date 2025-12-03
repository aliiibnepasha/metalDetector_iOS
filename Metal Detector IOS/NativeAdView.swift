//
//  NativeAdView.swift
//  Metal Detector IOS
//
//  Created by Lowbyte Studio on 27/11/2025.
//

import SwiftUI
import GoogleMobileAds
import UIKit

struct NativeAdView: UIViewRepresentable {
    let adUnitID: String
    @Binding var isLoading: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isLoading: $isLoading, adUnitID: adUnitID)
    }
    
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .clear
        context.coordinator.containerView = containerView
        context.coordinator.loadAd()
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update if needed
    }
    
    class Coordinator: NSObject, AdLoaderDelegate, NativeAdLoaderDelegate, NativeAdDelegate {
        @Binding var isLoading: Bool
        let adUnitID: String
        var containerView: UIView?
        var adLoader: AdLoader?
        var nativeAd: NativeAd? {
            didSet {
                // Retain the native ad
                if nativeAd != nil {
                    print("✅ NativeAdView: Native ad retained")
                }
            }
        }
        private var isLoadingInProgress = false
        
        init(isLoading: Binding<Bool>, adUnitID: String) {
            _isLoading = isLoading
            self.adUnitID = adUnitID
            super.init()
        }
        
        func loadAd() {
            // Prevent multiple simultaneous loads
            guard !isLoadingInProgress else {
                print("⚠️ NativeAdView: Ad load already in progress, skipping")
                return
            }
            
            // If ad already loaded, don't reload
            if nativeAd != nil {
                print("✅ NativeAdView: Ad already loaded, skipping")
                return
            }
            
            isLoadingInProgress = true
            DispatchQueue.main.async {
                self.isLoading = true
            }
            
            // Ensure Google Mobile Ads SDK is initialized
            // Small delay to ensure SDK is ready (SDK auto-initializes from Info.plist)
            let delay: TimeInterval = 0.5
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                guard let rootViewController = self.getRootViewController() else {
                    print("❌ NativeAdView: Could not get root view controller")
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.isLoadingInProgress = false
                    }
                    return
                }
                
                print("📱 NativeAdView: Loading ad with ID: \(self.adUnitID)")
                
                let loader = AdLoader(adUnitID: self.adUnitID, rootViewController: rootViewController, adTypes: [.native], options: [])
                loader.delegate = self
                self.adLoader = loader
                
                // Create ad request
                // Test ads are automatically used in debug mode
                let request = Request()
                loader.load(request)
            }
        }
        
        // MARK: - NativeAdLoaderDelegate
        func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
            print("✅ NativeAdView: Ad received from server")
            isLoadingInProgress = false
            self.nativeAd = nativeAd
            nativeAd.delegate = self
            
            DispatchQueue.main.async {
                self.setupNativeAdView(nativeAd: nativeAd)
                self.isLoading = false
                print("✅ NativeAdView: Loaded and displayed successfully")
            }
        }
        
        // MARK: - AdLoaderDelegate (error handling)
        func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
            let errorDescription = error.localizedDescription
            print("❌ NativeAdView: Failed to load ad")
            print("   Error: \(errorDescription)")
            print("   Ad Unit ID: \(self.adUnitID)")
            
            // Extract error details
            let nsError = error as NSError
            print("   Error Domain: \(nsError.domain)")
            print("   Error Code: \(nsError.code)")
            if let userInfo = nsError.userInfo as? [String: Any] {
                print("   User Info: \(userInfo)")
            }
            
            isLoadingInProgress = false
            DispatchQueue.main.async {
                self.isLoading = false
                // Retry after 3 seconds if failed (but only once to avoid infinite loop)
                if self.adLoader != nil && self.nativeAd == nil { // Only retry if loader still exists and no ad loaded
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                        guard let self = self, self.adLoader != nil, self.nativeAd == nil else { return }
                        print("🔄 NativeAdView: Retrying ad load...")
                        self.loadAd()
                    }
                }
            }
        }
        
        private func setupNativeAdView(nativeAd: NativeAd) {
            guard let container = containerView else {
                print("⚠️ NativeAdView: Container view is nil, cannot setup ad")
                return
            }
            
            // Ensure we're on main thread
            assert(Thread.isMainThread, "setupNativeAdView must be called on main thread")
            
            // Remove existing views
            container.subviews.forEach { $0.removeFromSuperview() }
            
            print("📱 NativeAdView: Setting up native ad UI...")
            
            let adView = UIView()
            adView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
            adView.layer.cornerRadius = 12
            adView.clipsToBounds = true
            
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 12
            stackView.alignment = .center
            stackView.distribution = .fill
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            // Ad icon
            if let icon = nativeAd.icon, let iconImage = icon.image {
                let iconImageView = UIImageView(image: iconImage)
                iconImageView.contentMode = .scaleAspectFit
                iconImageView.clipsToBounds = true
                iconImageView.layer.cornerRadius = 4
                iconImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
                iconImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
                stackView.addArrangedSubview(iconImageView)
            }
            
            // Ad content (headline + body)
            let contentStack = UIStackView()
            contentStack.axis = .vertical
            contentStack.spacing = 4
            contentStack.alignment = .leading
            contentStack.distribution = .fill
            contentStack.setContentHuggingPriority(.defaultLow, for: .horizontal)
            
            // Headline
            let headlineLabel = UILabel()
            headlineLabel.font = UIFont.boldSystemFont(ofSize: 16)
            headlineLabel.textColor = .white
            headlineLabel.text = nativeAd.headline
            headlineLabel.numberOfLines = 1
            contentStack.addArrangedSubview(headlineLabel)
            
            // Body
            let bodyLabel = UILabel()
            bodyLabel.font = UIFont.systemFont(ofSize: 14)
            bodyLabel.textColor = .lightGray
            bodyLabel.text = nativeAd.body
            bodyLabel.numberOfLines = 2
            contentStack.addArrangedSubview(bodyLabel)
            
            stackView.addArrangedSubview(contentStack)
            
            // Call to action button
            let button = UIButton(type: .system)
            button.setTitle(nativeAd.callToAction, for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0) // Golden yellow
            button.layer.cornerRadius = 6
            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 36).isActive = true
            button.widthAnchor.constraint(greaterThanOrEqualToConstant: 80).isActive = true
            stackView.addArrangedSubview(button)
            
            adView.addSubview(stackView)
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: adView.topAnchor, constant: 12),
                stackView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 12),
                stackView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -12),
                stackView.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -12)
            ])
            
            container.addSubview(adView)
            adView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                adView.topAnchor.constraint(equalTo: container.topAnchor),
                adView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                adView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                adView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
            
            // Register native ad view for clicks
            var clickableAssetViews: [GADNativeAssetIdentifier: UIView] = [:]
            var nonclickableAssetViews: [GADNativeAssetIdentifier: UIView] = [:]
            
            clickableAssetViews[.callToActionAsset] = button // Call to action
            clickableAssetViews[.headlineAsset] = headlineLabel // Headline
            clickableAssetViews[.bodyAsset] = bodyLabel // Body
            
            // Optional: Add icon to clickable if needed
            if let iconView = stackView.arrangedSubviews.first as? UIImageView {
                nonclickableAssetViews[.iconAsset] = iconView
            }
            
            nativeAd.register(adView, clickableAssetViews: clickableAssetViews, nonclickableAssetViews: nonclickableAssetViews)
            
            print("✅ NativeAdView: Ad registered and ready for interaction")
        }
        
        private func getRootViewController() -> UIViewController? {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first,
                  let rootViewController = window.rootViewController else {
                return nil
            }
            
            var topController = rootViewController
            while let presented = topController.presentedViewController {
                topController = presented
            }
            
            return topController
        }
        
        // MARK: - NativeAdDelegate
        func nativeAdDidRecordClick(_ nativeAd: NativeAd) {
            print("✅ NativeAdView: Ad clicked")
        }
        
        func nativeAdDidRecordImpression(_ nativeAd: NativeAd) {
            print("✅ NativeAdView: Ad impression recorded")
        }
    }
}
