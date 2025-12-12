//
//  HomeBannerContainer.swift
//  Metal Detector IOS
//
//  Shows cached/preloaded home banner from AdManager.
//

import SwiftUI
import GoogleMobileAds

struct HomeBannerContainer: UIViewRepresentable {
    @ObservedObject private var adManager = AdManager.shared
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Remove old subviews
        uiView.subviews.forEach { $0.removeFromSuperview() }
        
        if adManager.isHomeBannerReady, let banner = adManager.homeBannerView {
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



