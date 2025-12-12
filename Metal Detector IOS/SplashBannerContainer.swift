//
//  SplashBannerContainer.swift
//  Metal Detector IOS
//
//  Shows cached/preloaded splash banner from AdManager.
//

import SwiftUI
import GoogleMobileAds

struct SplashBannerContainer: UIViewRepresentable {
    @ObservedObject private var adManager = AdManager.shared
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        uiView.subviews.forEach { $0.removeFromSuperview() }
        
        if adManager.isSplashBannerReady, let banner = adManager.splashBannerView {
            banner.translatesAutoresizingMaskIntoConstraints = false
            uiView.addSubview(banner)
            NSLayoutConstraint.activate([
                banner.topAnchor.constraint(equalTo: uiView.topAnchor),
                banner.leadingAnchor.constraint(equalTo: uiView.leadingAnchor),
                banner.trailingAnchor.constraint(equalTo: uiView.trailingAnchor),
                banner.bottomAnchor.constraint(equalTo: uiView.bottomAnchor),
                banner.heightAnchor.constraint(equalToConstant: 50)
            ])
        }
    }
}


