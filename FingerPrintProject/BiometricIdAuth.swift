//
//  ViewController.swift
//  FingerPrintProject
//
//  Created by Mahendra Naidu on 01/04/25.
//

import Foundation
import LocalAuthentication

// Class responsible for handling biometric authentication (Face ID / Touch ID)
class BiometricIDAuth {
    
    private let context = LAContext()
    private let policy: LAPolicy
    private let localizedReason: String
    
    private var error: NSError?
    
    // MARK: - Initializer
    
    /// Initializes the biometric authentication handler with default values
    init(policy: LAPolicy = .deviceOwnerAuthenticationWithBiometrics,
         localizedReason: String = "Verify your Identity",
         localizedFallbackTitle: String = "Enter App Password",
         localizedCancelTitle: String = "Use MPIN") {
        self.policy = policy
        self.localizedReason = localizedReason
        context.localizedFallbackTitle = localizedFallbackTitle
        context.localizedCancelTitle = localizedCancelTitle
    }
    
    // MARK: - Private Helper Functions
    
    /// Converts system `LABiometryType` to custom `BiometricType`
    private func biometricType(for type: LABiometryType) -> BiometricType {
        switch type {
        case .none:
            return .none
        case .touchID:
            return .touchID
        case .faceID:
            return .faceID
        @unknown default:
            return .unknown
        }
    }
    
    /// Maps `NSError` from LocalAuthentication to a custom `BiometricError`
    private func biometricError(from nsError: NSError) -> BiometricError {
        let error: BiometricError
        
        switch nsError {
        case LAError.authenticationFailed:
            error = .authenticationFailed
        case LAError.userCancel:
            error = .userCancel
        case LAError.userFallback:
            error = .userFallback
        case LAError.biometryNotAvailable:
            error = .biometryNotAvailable
        case LAError.biometryNotEnrolled:
            error = .biometryNotEnrolled
        case LAError.biometryLockout:
            error = .biometryLockout
        default:
            error = .unknown
        }
        
        return error
    }
    
    // MARK: - Public Authentication Checks
    
    /// Checks if biometric authentication can be evaluated (available and configured)
    /// - Parameter completion: Returns a Bool, the biometric type, and an optional error
    func canEvaluate(completion: (Bool, BiometricType, BiometricError?) -> Void) {
        let context = LAContext()
        let policy = LAPolicy.deviceOwnerAuthenticationWithBiometrics
        var error: NSError?
        
        // Evaluate if biometrics can be used
        guard context.canEvaluatePolicy(policy, error: &error) else {
            let type = biometricType(for: context.biometryType)
            
            // No error but evaluation failed
            guard let error = error else {
                return completion(false, type, nil)
            }
            
            // Convert NSError to BiometricError
            return completion(false, type, biometricError(from: error))
        }
        
        // Success: biometrics available
        completion(true, biometricType(for: context.biometryType), nil)
    }
    
    /// Evaluates biometric authentication and calls completion with result
    /// - Parameter completion: Returns a success Bool and optional error
    func evaluate(completion: @escaping (Bool, BiometricError?) -> Void) {
        let context = LAContext()
        let policy = LAPolicy.deviceOwnerAuthenticationWithBiometrics
        let localizedReason = "Authenticate to access your account"
        
        // Begin biometric authentication
        context.evaluatePolicy(policy, localizedReason: localizedReason) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    // Successful authentication
                    completion(true, nil)
                } else {
                    // Failed authentication
                    guard let error = error else {
                        return completion(false, nil)
                    }
                    completion(false, self?.biometricError(from: error as NSError))
                }
            }
        }
    }
}

// MARK: - Biometric Type Enum

/// Enum to define the type of biometric authentication available
enum BiometricType {
    case none
    case touchID
    case faceID
    case unknown
}

// MARK: - Biometric Error Enum

/// Custom error enum with user-friendly descriptions for biometric failures
enum BiometricError: LocalizedError {
    case authenticationFailed
    case userCancel
    case userFallback
    case biometryNotAvailable
    case biometryNotEnrolled
    case biometryLockout
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .authenticationFailed:
            return "There was a problem verifying your identity."
        case .userCancel:
            return "You cancelled the authentication."
        case .userFallback:
            return "You chose to use a password instead."
        case .biometryNotAvailable:
            return "Face ID or Touch ID is not available on this device."
        case .biometryNotEnrolled:
            return "Face ID or Touch ID is not set up."
        case .biometryLockout:
            return "Face ID or Touch ID is locked due to too many failed attempts."
        case .unknown:
            return "Face ID or Touch ID may not be configured."
        }
    }
}
