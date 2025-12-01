//
//  Metal_Detector_IOSApp.swift
//  Metal Detector IOS
//
//  Created by Lowbyte Studio on 27/11/2025.
//

import SwiftUI
import FirebaseCore

@main
struct Metal_Detector_IOSApp: App {
    @StateObject private var firebaseManager = FirebaseManager.shared
    
    init() {
        // Firebase will be configured in FirebaseManager
        // But we ensure it's configured here too
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        // Start anonymous authentication
        FirebaseManager.shared.checkAndSignInAnonymously()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(firebaseManager)
                .onAppear {
                    // Ensure anonymous login happens on app launch
                    FirebaseManager.shared.checkAndSignInAnonymously()
                }
        }
    }
}
