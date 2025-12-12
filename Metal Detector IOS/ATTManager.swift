//
//  ATTManager.swift
//  Metal Detector IOS
//
//  Created by Lowbyte Studio on 27/11/2025.
//

import Foundation
import AppTrackingTransparency
import AdSupport
import UIKit

class ATTManager {
    static let shared = ATTManager()
    
    private init() {}
    
    // MARK: - Request Tracking Authorization
    func requestTrackingPermission(completion: ((ATTrackingManager.AuthorizationStatus) -> Void)? = nil) {
        // Only request on iOS 14.5+
        guard #available(iOS 14.5, *) else {
            print("⚠️ ATTManager: iOS version < 14.5, tracking authorization not required")
            completion?(.authorized) // Older iOS versions are considered authorized
            return
        }
        
        // Check current status
        let currentStatus = ATTrackingManager.trackingAuthorizationStatus
        
        switch currentStatus {
        case .notDetermined:
            // Request permission
            ATTrackingManager.requestTrackingAuthorization { status in
                DispatchQueue.main.async {
                    self.handleTrackingStatus(status)
                    completion?(status)
                }
            }
        case .authorized:
            print("✅ ATTManager: Tracking already authorized")
            completion?(.authorized)
        case .denied:
            print("⚠️ ATTManager: Tracking denied by user")
            completion?(.denied)
        case .restricted:
            print("⚠️ ATTManager: Tracking restricted by system")
            completion?(.restricted)
        @unknown default:
            print("⚠️ ATTManager: Unknown tracking status")
            completion?(currentStatus)
        }
    }
    
    // MARK: - Get Current Status
    func getTrackingStatus() -> ATTrackingManager.AuthorizationStatus {
        guard #available(iOS 14.5, *) else {
            return .authorized // Older iOS versions
        }
        return ATTrackingManager.trackingAuthorizationStatus
    }
    
    // MARK: - Check if Tracking is Authorized
    var isTrackingAuthorized: Bool {
        guard #available(iOS 14.5, *) else {
            return true // Older iOS versions
        }
        return ATTrackingManager.trackingAuthorizationStatus == .authorized
    }
    
    // MARK: - Get Advertising ID
    var advertisingID: String {
        // Only available if tracking is authorized
        guard isTrackingAuthorized else {
            return ""
        }
        
        let idfa = ASIdentifierManager.shared().advertisingIdentifier
        return idfa.uuidString
    }
    
    // MARK: - Handle Tracking Status
    private func handleTrackingStatus(_ status: ATTrackingManager.AuthorizationStatus) {
        switch status {
        case .authorized:
            print("✅ ATTManager: User authorized tracking")
            let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            print("📱 IDFA: \(idfa)")
            
            // You can send IDFA to your analytics/ad networks here
            // Google Mobile Ads SDK automatically uses IDFA when authorized
            
        case .denied:
            print("⚠️ ATTManager: User denied tracking")
            // Ads will still work, but with limited personalization
            
        case .restricted:
            print("⚠️ ATTManager: Tracking restricted (parental controls, etc.)")
            
        case .notDetermined:
            print("⚠️ ATTManager: Tracking status not determined")
            
        @unknown default:
            print("⚠️ ATTManager: Unknown tracking status")
        }
    }
}









