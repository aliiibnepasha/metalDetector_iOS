//
//  FirebaseManager.swift
//  Metal Detector IOS
//
//  Created by Lowbyte Studio on 27/11/2025.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseAnalytics
import Combine

class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    private init() {
        // Initialize Firebase if not already initialized
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        // Start listening to auth state changes
        setupAuthStateListener()
        
        // Try to sign in anonymously if not already signed in
        checkAndSignInAnonymously()
    }
    
    // MARK: - Firebase Configuration
    private func setupAuthStateListener() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            DispatchQueue.main.async {
                self?.currentUser = user
                self?.isAuthenticated = user != nil
                
                if let user = user {
                    print("✅ Firebase: User authenticated - \(user.isAnonymous ? "Anonymous" : "Regular") User ID: \(user.uid)")
                } else {
                    print("⚠️ Firebase: No user authenticated")
                }
            }
        }
    }
    
    // MARK: - Anonymous Authentication
    func checkAndSignInAnonymously() {
        // If already authenticated, don't sign in again
        if Auth.auth().currentUser != nil {
            isAuthenticated = true
            currentUser = Auth.auth().currentUser
            print("✅ Firebase: User already authenticated")
            return
        }
        
        // Sign in anonymously
        signInAnonymously()
    }
    
    func signInAnonymously() {
        isLoading = true
        errorMessage = nil
        
        Auth.auth().signInAnonymously { [weak self] (authResult, error) in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    print("❌ Firebase: Anonymous sign in failed - \(error.localizedDescription)")
                    return
                }
                
                if let user = authResult?.user {
                    self?.isAuthenticated = true
                    self?.currentUser = user
                    print("✅ Firebase: Anonymous sign in successful - User ID: \(user.uid)")
                }
            }
        }
    }
    
    // MARK: - Sign Out (if needed in future)
    func signOut() {
        do {
            try Auth.auth().signOut()
            isAuthenticated = false
            currentUser = nil
            print("✅ Firebase: User signed out")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Firebase: Sign out failed - \(error.localizedDescription)")
        }
    }
    
    // MARK: - Get User ID
    func getUserId() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    // MARK: - Firebase Analytics Events
    /// Log a custom event to Firebase Analytics
    /// - Parameters:
    ///   - eventName: Name of the event (as per Google Sheet)
    ///   - parameters: Optional parameters dictionary
    static func logEvent(_ eventName: String, parameters: [String: Any]? = nil) {
        if let params = parameters {
            Analytics.logEvent(eventName, parameters: params)
            print("📊 Analytics Event: \(eventName) with params: \(params)")
        } else {
            Analytics.logEvent(eventName, parameters: nil)
            print("📊 Analytics Event: \(eventName)")
        }
    }
    
    /// Log event with ad placement and status
    /// - Parameters:
    ///   - eventName: Base event name
    ///   - placement: Ad placement name
    ///   - adType: Type of ad (native, banner, fullscreen, etc.)
    ///   - status: Status (loaded, failed, requested, shown, etc.)
    static func logAdEvent(_ eventName: String, placement: String, adType: String, status: String) {
        let parameters: [String: Any] = [
            "placement": placement,
            "adType": adType,
            "status": status
        ]
        logEvent("\(eventName)_\(placement)_\(adType)_\(status)", parameters: parameters)
    }
    
    // MARK: - Cleanup
    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
}







