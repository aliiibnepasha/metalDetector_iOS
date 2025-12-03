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
    @Published var isMetalDetected: Bool = false // True when metal is actually detected
    
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
    
    // ✅ FIX 3: Magnetometer freeze detection variables
    private var lastField: Double = 0.0
    private var lastUpdateTime: Date = Date()
    
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
            
            // ✅ FIX 3: Magnetometer freeze detection
            // Check if sensor is stuck/frozen (same reading for too long)
            let currentTime = Date()
            var shouldProcess = true
            
            if abs(self.lastField - totalField) < 0.01 {
                if currentTime.timeIntervalSince(self.lastUpdateTime) > 0.8 {
                    // Sensor appears frozen, restart detection completely
                    self.motionManager.stopMagnetometerUpdates()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                        guard let self = self else { return }
                        print("🔄 Magnetometer refreshed (freeze detected)")
                        // Restart detection
                        self.isDetecting = false
                        self.startDetection()
                    }
                    shouldProcess = false // Skip processing this update
                }
            } else {
                self.lastUpdateTime = currentTime
            }
            self.lastField = totalField
            
            // Skip processing if freeze was detected
            guard shouldProcess else { return }
            
            // Calibrate baseline first
            if !self.isCalibrated {
                self.calibrationReadings.append(totalField)
                if self.calibrationReadings.count >= self.calibrationSamples {
                    // Calculate average baseline
                    self.baseMagneticField = self.calibrationReadings.reduce(0, +) / Double(self.calibrationReadings.count)
                    self.isCalibrated = true
                    print("✅ Calibrated baseline: \(self.baseMagneticField) µT (Mode: \(self.currentMode.rawValue))")
                }
            } else {
                // ✅ FIX 1: Baseline auto-adjust (slow exponential smoothing)
                // BUT: Only adjust baseline when metal is NOT detected
                // When metal is detected, keep baseline fixed to maintain continuous detection
                if !self.isMetalDetected {
                    // Only adjust baseline when no metal is detected (prevents baseline drift during detection)
                    let alpha = 0.015 // Very slow smoothing factor (even slower)
                    self.baseMagneticField = (alpha * totalField) + ((1 - alpha) * self.baseMagneticField)
                }
                // When metal is detected, baseline stays fixed so detection remains continuous
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
        isMetalDetected = false
        
        // Reset freeze detection variables
        lastField = 0.0
        lastUpdateTime = Date()
        
        // ✅ FIX 4: Stop sound when detection stops
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
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
        
        // Trigger detection if significant change detected AND detection level is meaningful
        // OR if already detected and difference is still above minimum threshold (maintain continuous detection)
        let minimumDetectionThreshold = adjustedThreshold * 0.5 // 50% of threshold to maintain detection
        let shouldDetect = (difference > adjustedThreshold && detectionLevel > triggerLevel) || 
                          (self.isMetalDetected && difference > minimumDetectionThreshold && detectionLevel > 10)
        
        if shouldDetect {
            DispatchQueue.main.async {
                self.isMetalDetected = true
            }
            
            let now = Date()
            
            // Play sound if enabled and cooldown passed (only play new sound, not continuously)
            if soundEnabled && now.timeIntervalSince(lastSoundTime) > soundCooldown {
                playDetectionSound()
                lastSoundTime = now
            }
            
            // Vibrate if enabled and cooldown passed
            if vibrationEnabled && now.timeIntervalSince(lastVibrationTime) > vibrationCooldown {
                triggerVibration()
                lastVibrationTime = now
            }
        } else {
            // ✅ FIX 2: Detection reset - only when difference is significantly low
            // Reset detection when difference is below 40% of threshold (strict reset)
            // This ensures detection continues as long as metal is near
            let resetThreshold = adjustedThreshold * 0.4 // Strict reset threshold
            if difference < resetThreshold && self.detectionLevel < 10 {
                // Only reset if both difference AND detection level are very low
                DispatchQueue.main.async {
                    self.isMetalDetected = false
                    
                    // ✅ FIX 4: Sound ko stop karo jab metal door ho
                    if let player = self.audioPlayer, player.isPlaying {
                        player.stop()
                        player.currentTime = 0
                    }
                }
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
    @Published var currentDetectorTitle: String = "Gold Detector" // Store current detector title for messages
    
    func setMode(_ mode: DetectionMode) {
        currentMode = mode
        // Reset calibration when mode changes
        isCalibrated = false
        calibrationReadings = []
        baseMagneticField = 0.0
        print("📱 Detection mode set to: \(mode.rawValue) - Threshold: \(mode.threshold) µT")
    }
    
    func setMode(for detectorTitle: String) {
        currentDetectorTitle = detectorTitle // Store detector title
        switch detectorTitle {
        case "Metal Detector":
            setMode(.metalDetector)
        case "Stud Finder":
            setMode(.studFinder)
        case "Handled Detector", "Handheld Scanner":
            setMode(.handheldScanner)
        default:
            // Default to Metal Detector for other detectors (Gold Detector, etc.)
            setMode(.metalDetector)
        }
    }
    
    // MARK: - Helper Methods for Views
    func getMeterNeedleRotation() -> Double {
        // Convert detection level (0-100) to meter needle rotation for Meter View
        // Starting position: -170 degrees (MIN position)
        // Ending position: 15 degrees (MAX position - minimal rotation to stay well within meter)
        // Range: -170 (MIN) to 15 (MAX) degrees = 185 degrees total
        let clamped = max(0, min(detectionLevel, 100))
        let angle = -170 + (clamped / 100.0) * 185.0
        return max(-170, min(angle, 15)) // Clamp between MIN and MAX - minimal rotation
    }
    
    func getDigitalMeterNeedleRotation() -> Double {
        // Convert detection level (0-100) to meter needle rotation for Digital View
        // Starting position: 0 degrees (0 mark on meter - 5 o'clock position)
        // Ending position: 330 degrees (330 mark on meter - full clockwise rotation)
        // Range: 0 to 330 degrees = 330 degrees total (matches meter scale 0-330)
        let clamped = max(0, min(detectionLevel, 100))
        let angle = (clamped / 100.0) * 330.0 // Rotate from 0 to 330 degrees based on detection level
        return max(0, min(angle, 330)) // Clamp between 0 and 330 degrees
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
    
    // MARK: - Get Detection Message Key
    func getDetectionMessageKey() -> String {
        // Check detector title to determine message type
        if currentDetectorTitle == "Gold Detector" {
            // Gold Detector messages
            if isMetalDetected {
                return LocalizedString.goldDetectedNearby
            } else {
                return LocalizedString.noGoldDetected
            }
        } else if currentDetectorTitle == "Metal Detector" {
            // Metal Detector messages
            if isMetalDetected {
                return LocalizedString.metalDetected
            } else {
                return LocalizedString.noMetalDetected
            }
        } else if currentDetectorTitle == "Stud Finder" {
            // Stud Finder messages
            if isMetalDetected {
                return LocalizedString.studDetected
            } else {
                return LocalizedString.noStudDetected
            }
        } else if currentDetectorTitle == "Handled Detector" {
            // Handled Detector messages
            if isMetalDetected {
                return LocalizedString.handleDetected
            } else {
                return LocalizedString.noHandleDetected
            }
        } else {
            // Default for Handheld Scanner and others
            if isMetalDetected {
                return LocalizedString.metalDetected
            } else {
                return LocalizedString.noMetalDetected
            }
        }
    }
    
    // MARK: - Get Subtitle Message Key (for detected state)
    func getSubtitleMessageKey() -> String {
        if isMetalDetected {
            // Show specific "keep scanning" message based on detector type
            switch currentDetectorTitle {
            case "Gold Detector":
                return LocalizedString.goldObjectNearbyKeepScanning
            case "Metal Detector":
                return LocalizedString.metalObjectNearbyKeepScanning
            case "Stud Finder":
                return LocalizedString.studObjectNearbyKeepScanning
            case "Handled Detector":
                return LocalizedString.handleObjectNearbyKeepScanning
            default:
                return LocalizedString.metalObjectNearbyKeepScanning
            }
        } else {
            // Show "Please check thoroughly" when not detected
            return LocalizedString.pleaseCheckThoroughly
        }
    }
}
