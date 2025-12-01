//
//  MetalDetectorManager.swift
//  Metal Detector IOS
//
//  Created by Lowbyte Studio on 27/11/2025.
//

import Foundation
import CoreMotion
import AVFoundation
import UIKit
import Combine

enum DetectionMode: String {
    case metalDetector = "Metal Detector"
    case studFinder = "Stud Finder"
    case handheldScanner = "Handheld Scanner"
    
    var threshold: Double {
        switch self {
        case .metalDetector:
            return 60.0 // µT
        case .studFinder:
            return 55.0 // µT
        case .handheldScanner:
            return 10.0 // ∆ > 10 µT (difference threshold)
        }
    }
}

class MetalDetectorManager: ObservableObject {
    static let shared = MetalDetectorManager()
    
    // Motion Manager for magnetometer
    private let motionManager = CMMotionManager()
    
    // Audio player for detection sound
    private var audioPlayer: AVAudioPlayer?
    
    // Published properties for UI updates
    @Published var magneticFieldStrength: Double = 0.0 // in microTesla (µT)
    @Published var isDetecting: Bool = false
    @Published var detectionLevel: Double = 0.0 // 0-100
    @Published var currentMode: DetectionMode = .metalDetector // Default mode
    
    // Detection thresholds
    private var baseMagneticField: Double = 0.0 // Will be calibrated on first reading
    private var isCalibrated: Bool = false
    private let calibrationSamples: Int = 60 // Number of samples to average for baseline (1 second at 60fps)
    private var calibrationReadings: [Double] = []
    
    // Settings
    @Published var soundEnabled: Bool = true
    @Published var vibrationEnabled: Bool = true
    @Published var sensitivity: Double = 30.0 // 0-100 (lower = less sensitive, need to be closer)
    
    // Cooldown timers for feedback
    private var lastVibrationTime: Date = Date.distantPast
    private var lastSoundTime: Date = Date.distantPast
    private let vibrationCooldown: TimeInterval = 0.5 // 500ms cooldown between vibrations
    private let soundCooldown: TimeInterval = 0.8 // 800ms cooldown between sounds
    
    private init() {
        setupAudioPlayer()
        requestPermissions()
    }
    
    // MARK: - Audio Setup
    private func setupAudioPlayer() {
        guard let soundURL = Bundle.main.url(forResource: "metal_detection_sound", withExtension: "mp3") else {
            print("⚠️ Sound file not found. Please add 'metal_detection_sound.mp3' to your project.")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
            audioPlayer?.numberOfLoops = 0
        } catch {
            print("❌ Error setting up audio player: \(error)")
        }
    }
    
    // MARK: - Permissions
    private func requestPermissions() {
        // Request motion permissions if needed
        // Note: iOS doesn't require explicit permission for magnetometer
    }
    
    // MARK: - Start Detection
    func startDetection() {
        guard motionManager.isMagnetometerAvailable else {
            print("❌ Magnetometer not available on this device")
            return
        }
        
        guard !isDetecting else { return }
        
        isDetecting = true
        isCalibrated = false
        calibrationReadings = []
        baseMagneticField = 0.0
        
        // Configure update interval (60 updates per second for smooth UI)
        motionManager.magnetometerUpdateInterval = 1.0 / 60.0
        
        // Start magnetometer updates
        motionManager.startMagnetometerUpdates(to: .main) { [weak self] (magnetometerData, error) in
            guard let self = self,
                  let magneticField = magnetometerData?.magneticField else {
                return
            }
            
            // Calculate total magnetic field strength
            // ✅ FIX: iPhone magnetometer already returns values in microTesla (µT), NO CONVERSION NEEDED
            let totalField = sqrt(
                pow(magneticField.x, 2) +
                pow(magneticField.y, 2) +
                pow(magneticField.z, 2)
            ) // Already in µT - NO * 1000 multiplication!
            
            // Calibrate baseline first
            if !self.isCalibrated {
                self.calibrationReadings.append(totalField)
                if self.calibrationReadings.count >= self.calibrationSamples {
                    // Calculate average baseline
                    self.baseMagneticField = self.calibrationReadings.reduce(0, +) / Double(self.calibrationReadings.count)
                    self.isCalibrated = true
                    print("✅ Calibrated baseline: \(self.baseMagneticField) µT (Mode: \(self.currentMode.rawValue))")
                }
            }
            
            // Update published property (triggers UI updates)
            DispatchQueue.main.async {
                self.magneticFieldStrength = totalField
                if self.isCalibrated {
                    self.updateDetectionLevel(totalField)
                    self.checkForMetalDetection(totalField)
                }
            }
        }
    }
    
    // MARK: - Stop Detection
    func stopDetection() {
        motionManager.stopMagnetometerUpdates()
        isDetecting = false
        magneticFieldStrength = 0.0
        detectionLevel = 0.0
    }
    
    // MARK: - Update Detection Level (0-100)
    private func updateDetectionLevel(_ fieldStrength: Double) {
        guard isCalibrated else {
            detectionLevel = 0.0
            return
        }
        
        // Calculate difference from baseline
        let difference = abs(fieldStrength - baseMagneticField)
        
        // ✅ FIX: Ignore small random noise (minimum 3 µT difference required)
        if difference < 3 {
            detectionLevel = 0.0
            return
        }
        
        // Get mode-specific threshold
        let modeThreshold = currentMode.threshold
        
        // Adjust threshold based on sensitivity
        let adjustedThreshold: Double
        if currentMode == .handheldScanner {
            // Handheld Scanner uses fixed threshold (∆ > 10 µT)
            adjustedThreshold = modeThreshold
        } else {
            // Metal Detector and Stud Finder adjust based on sensitivity
            // Lower sensitivity = higher threshold (less sensitive)
            // Higher sensitivity = lower threshold (more sensitive)
            adjustedThreshold = modeThreshold * (1.0 - (sensitivity / 100.0) * 0.5)
        }
        
        if difference > adjustedThreshold {
            // Calculate detection level (0-100)
            // Detection level based on how much stronger than threshold
            let excess = difference - adjustedThreshold
            let maxDetection = adjustedThreshold * 2 // Maximum detection range (2x threshold)
            detectionLevel = min(100.0, (excess / maxDetection) * 100.0)
        } else {
            detectionLevel = 0.0
        }
    }
    
    // MARK: - Check for Metal and Trigger Feedback
    private func checkForMetalDetection(_ fieldStrength: Double) {
        guard isCalibrated else { return }
        
        // Calculate difference from baseline
        let difference = abs(fieldStrength - baseMagneticField)
        
        // ✅ FIX: Ignore small random noise (minimum 3 µT difference required)
        guard difference >= 3 else { return }
        
        // Get mode-specific threshold
        let modeThreshold = currentMode.threshold
        
        // Adjust threshold based on sensitivity
        let adjustedThreshold: Double
        let triggerLevel: Double
        
        if currentMode == .handheldScanner {
            // Handheld Scanner: ∆ > 10 µT (fixed threshold, more sensitive)
            adjustedThreshold = modeThreshold
            triggerLevel = 20.0 // Lower trigger level for handheld scanner
        } else {
            // Metal Detector (60µT) and Stud Finder (55µT): adjust based on sensitivity
            adjustedThreshold = modeThreshold * (1.0 - (sensitivity / 100.0) * 0.5)
            triggerLevel = 35.0 // Higher trigger level for metal/stud detection
        }
        
        // Only trigger if significant change detected AND detection level is meaningful
        if difference > adjustedThreshold && detectionLevel > triggerLevel {
            // Metal detected! (only when metal is actually close)
            let now = Date()
            
            // Play sound if enabled and cooldown passed
            if soundEnabled && now.timeIntervalSince(lastSoundTime) > soundCooldown {
                playDetectionSound()
                lastSoundTime = now
            }
            
            // Vibrate if enabled and cooldown passed
            if vibrationEnabled && now.timeIntervalSince(lastVibrationTime) > vibrationCooldown {
                triggerVibration()
                lastVibrationTime = now
            }
        }
    }
    
    // MARK: - Sound Playback
    private func playDetectionSound() {
        guard let player = audioPlayer else { return }
        
        // Play sound (don't interrupt if already playing for continuous detection)
        if !player.isPlaying {
            player.play()
        }
    }
    
    // MARK: - Vibration
    private func triggerVibration() {
        // Use impact feedback generator for vibration
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    // MARK: - Settings
    func setSoundEnabled(_ enabled: Bool) {
        soundEnabled = enabled
    }
    
    func setVibrationEnabled(_ enabled: Bool) {
        vibrationEnabled = enabled
    }
    
    func setSensitivity(_ value: Double) {
        sensitivity = max(0, min(100, value))
    }
    
    // MARK: - Mode Management
    func setMode(_ mode: DetectionMode) {
        currentMode = mode
        // Reset calibration when mode changes
        isCalibrated = false
        calibrationReadings = []
        baseMagneticField = 0.0
        print("📱 Detection mode set to: \(mode.rawValue) - Threshold: \(mode.threshold) µT")
    }
    
    func setMode(for detectorTitle: String) {
        switch detectorTitle {
        case "Metal Detector":
            setMode(.metalDetector)
        case "Stud Finder":
            setMode(.studFinder)
        case "Handled Detector", "Handheld Scanner":
            setMode(.handheldScanner)
        default:
            // Default to Metal Detector for other detectors
            setMode(.metalDetector)
        }
    }
    
    // MARK: - Helper Methods for Views
    func getMeterNeedleRotation() -> Double {
        // Convert detection level (0-100) to meter needle rotation
        // Starting position: -170 degrees (MIN position)
        // Ending position: 15 degrees (MAX position - minimal rotation to stay well within meter)
        // Range: -170 (MIN) to 15 (MAX) degrees = 185 degrees total
        let clamped = max(0, min(detectionLevel, 100))
        let angle = -170 + (clamped / 100.0) * 185.0
        return max(-170, min(angle, 15)) // Clamp between MIN and MAX - minimal rotation
    }


    
    func getCalibrationNeedleRotation() -> Double {
        // Convert detection level (0-100) to calibration needle rotation
        // Starting position: -170 degrees (MIN position)
        // Ending position: 90 degrees (MAX position - full meter range)
        // Range: -170 (MIN) to 90 (MAX) degrees = 260 degrees total (full meter)
        let clamped = max(0, min(detectionLevel, 100))
        let angle = -170 + (clamped / 100.0) * 260.0
        return max(-170, min(angle, 90)) // Full range rotation for calibration meter
    }
    
    func getGraphDataPoint() -> Double {
        // Return current magnetic field strength for graph
        return magneticFieldStrength
    }
}
