//
//  ViewController.swift
//  FingerPrintProject
//
//  Created by Mahendra Naidu on 01/04/25.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet var verficationBtn: UIButton!
    
    // MARK: - Properties
    private let biometricIDAuth = BiometricIDAuth() // Handles Face ID / Touch ID logic
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Trigger Face ID/Touch ID authentication on load (optional)
        faceAuthentication()
    }

    // MARK: - Face/Touch ID Authentication
    func faceAuthentication(showpopUp: Bool = true) {
        biometricIDAuth.canEvaluate { (canEvaluate, _, canEvaluateError) in
            guard canEvaluate else {
                // If biometric auth can't be used, show an alert with option to open Settings
                DispatchQueue.main.async {
                    let message = canEvaluateError?.localizedDescription ?? "Biometric authentication is not available or not configured."
                    
                    let alert = UIAlertController(title: "Biometric Unavailable", message: message, preferredStyle: .alert)
                    
                    // Action to open the device's Settings app
                    alert.addAction(UIAlertAction(title: "Go to Settings", style: .default, handler: { _ in
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString),
                           UIApplication.shared.canOpenURL(settingsURL) {
                            UIApplication.shared.open(settingsURL)
                        }
                    }))
                    
                    // Cancel action
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    
                    self.present(alert, animated: true)
                }
                return
            }

            // Perform biometric authentication
            biometricIDAuth.evaluate { (success, error) in
                DispatchQueue.main.async {
                    if success {
                        // Show success alert
                        let alert = UIAlertController(title: "Success", message: "Authentication successful!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true)
                    } else {
                        // Show error alert if authentication fails
                        let message = error?.localizedDescription ?? "Authentication failed."
                        let alert = UIAlertController(title: "Authentication Failed", message: message, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true)
                    }
                }
            }
        }
    }

    // MARK: - Actions
    @IBAction func verficationtapped(sender: UIButton) {
        // Trigger biometric auth when button is tapped
        faceAuthentication()
    }
}
