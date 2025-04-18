import Foundation
import LocalAuthentication
import SwiftUI
import Flutter

/**
 * Represents the supported biometric authentication types.
 * Maps to the corresponding types defined in the Dart code.
 */
enum BiometricType: String {
    case face = "face"          // Face ID on supported devices
    case fingerprint = "fingerprint"  // Touch ID on supported devices
    case none = "none"          // Fallback when no biometric is available
}

/**
 * Main class that handles biometric authentication functionality.
 * Provides methods to check availability, enrollment, and perform authentication.
 */
class BiometricAuthorization {
    
    /**
     * Creates and configures a new LAContext instance.
     * 
     * @return A configured LAContext instance ready for biometric operations.
     */
    private static func createContext() -> LAContext {
        let context = LAContext()
        return context
    }
    
    /**
     * Checks if biometric authentication is available on the device.
     * This checks if the hardware supports biometrics (Face ID or Touch ID).
     * 
     * @return Boolean indicating if biometric authentication is available.
     */
    static func isBiometricAvailable() -> Bool {
        let context = createContext()
        var error:  NSError?
        let available = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        return available
    }
    
    /**
     * Checks if biometric authentication is enrolled on the device.
     * This verifies if the user has registered their biometrics (face or fingerprint).
     * 
     * @return Boolean indicating if biometrics are enrolled.
     */
    static func isBiometricEnrolled() -> Bool {
        let context = createContext()
        var error: NSError?
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        if let err = error as? LAError {
            return err.code != .biometryNotEnrolled
        }
        return true
    }
    
    /**
     * Determines which biometric types are available on the device.
     * 
     * @return Array of strings representing available biometric types.
     *         Returns ["none"] if no biometrics are available.
     */
    static func getAvailableBiometricTypes() -> [String] {
        let context = createContext()
        var error: NSError?
        var biometricTypes: [String] = []
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            switch context.biometryType {
            case .faceID:
                biometricTypes.append(BiometricType.face.rawValue)
            case .touchID:
                biometricTypes.append(BiometricType.fingerprint.rawValue)
            default:
                break
            }
        }
        
        return biometricTypes.isEmpty ? [BiometricType.none.rawValue] : biometricTypes
    }
    
    /**
     * Main authentication method called from Flutter through the method channel.
     * Determines whether to use standard system authentication or custom UI.
     * 
     * @param call The Flutter method call containing authentication parameters.
     * @param result The Flutter result callback to return the authentication outcome.
     */
    static func authenticate(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let context = createContext()
        
        // Extract parameters from the method call
        guard let args = call.arguments as? [String: Any],
              let biometricType = args["biometricType"] as? String,
              let reason = args["reason"] as? String
        else {
            result(false)
            return
        }
        let title = args["title"] as? String
        let confirmText = args["confirmText"] as? String
        let useCustomUI = args["useCustomUI"] as? Bool ?? false
        
        let policy = LAPolicy.deviceOwnerAuthenticationWithBiometrics
        
        if #available(iOS 13.0, *) {
            if useCustomUI &&
                (biometricType == BiometricType.face.rawValue ||
                biometricType == BiometricType.fingerprint.rawValue) {
                // Use custom SwiftUI-based authentication UI
                showCustomUI(
                    biometricType: biometricType,
                    title: title,
                    confirmText: confirmText,
                    context: context,
                    policy: policy,
                    reason: reason,
                    result: result
                )
            } else {
                // Use standard system authentication dialog
                authenticateStandard(
                    context: context,
                    policy: policy,
                    reason: reason,
                    result: result
                )
            }
        }
    }
    
    /**
     * Initiates the custom UI authentication flow.
     * This is a wrapper method that calls the async presentation method.
     * 
     * @param biometricType The type of biometric to authenticate with.
     * @param title Optional title for the authentication dialog.
     * @param confirmText Optional text for the confirm button.
     * @param context The LAContext instance for biometric operations.
     * @param policy The authentication policy to use.
     * @param reason The reason for authentication to display to user.
     * @param result The Flutter result callback.
     */
    @available(iOS 13.0, *)
    private static func showCustomUI(
        biometricType: String,
        title: String?,
        confirmText: String?,
        context: LAContext,
        policy: LAPolicy,
        reason: String,
        result: @escaping FlutterResult
    ) {
        Task {
            await presentBiometricSheet(
                context: context,
                policy: policy,
                reason: reason,
                title: title,
                confirmText: confirmText,
                biometricType: biometricType,
                result: result
            )
        }
    }
    
    /**
     * Presents the custom biometric authentication sheet using SwiftUI.
     * Handles different iOS versions with appropriate UI adaptations.
     * 
     * @param context The LAContext instance for biometric operations.
     * @param policy The authentication policy to use.
     * @param reason The reason for authentication to display to user.
     * @param title Optional title for the authentication dialog.
     * @param confirmText Optional text for the confirm button.
     * @param biometricType The type of biometric to authenticate with.
     * @param result The Flutter result callback.
     */
    @available(iOS 13.0, *)
    @MainActor
    private static func presentBiometricSheet(
        context: LAContext,
        policy: LAPolicy,
        reason: String,
        title: String?,
        confirmText: String?,
        biometricType: String,
        result: @escaping FlutterResult
    ) {
        // Get the key window and root view controller
        guard let keyWindow = getKeyWindow(),
              let rootViewController = keyWindow.rootViewController else {
            authenticateStandard(
                context: context,
                policy: policy,
                reason: reason,
                result: result
            )
            return
        }
        
        // Create the SwiftUI view for biometric authentication
        let contentView = BiometricAuthView(
            title: title ?? getBiometricTitle(type: biometricType),
            reason: reason,
            buttonText: confirmText ?? "Authenticate",
            biometricType: biometricType,
            onAuthenticate: result
        )
        
        let hostingController = UIHostingController(rootView: contentView)
        
        if #available(iOS 15.0, *) {
            // iOS 15+ uses the new sheet presentation API
            hostingController.modalPresentationStyle = .pageSheet
            
            if let sheet = hostingController.sheetPresentationController {
                if #available(iOS 16.0, *) {
                    // iOS 16+ supports custom height using fraction
                    sheet.detents = [
                        .custom { context in
                            context.maximumDetentValue * 0.35
                        }
                    ]
                } else {
                    // iOS 15 only supports predefined detents
                    sheet.detents = [.medium()]
                    hostingController.view.heightAnchor.constraint(
                        equalToConstant: UIScreen.main.bounds.height * 0.35
                    ).isActive = true
                }
                
                sheet.preferredCornerRadius = 25
                sheet.prefersGrabberVisible = true
            }
        } else {
            // iOS 13-14 uses the older form sheet presentation
            hostingController.modalPresentationStyle = .formSheet
            hostingController.preferredContentSize = CGSize(
                width: UIScreen.main.bounds.width,
                height: UIScreen.main.bounds.height * 0.35
            )
            hostingController.view.backgroundColor = .systemBackground
            hostingController.view.layer.cornerRadius = 20
            hostingController.view.clipsToBounds = true
        }
        
        // Present the authentication sheet
        rootViewController.present(hostingController, animated: true)
    }
    
    /**
     * Helper method to get the key window in iOS 13+.
     * 
     * @return The key UIWindow instance or nil if not found.
     */
    @available(iOS 13.0, *)
    @MainActor
    private static func getKeyWindow() -> UIWindow? {
        return UIApplication
            .shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
    
    /**
     * Returns the appropriate title for the authentication dialog based on biometric type.
     * 
     * @param type The biometric type string.
     * @return A user-friendly title for the authentication dialog.
     */
    private static func getBiometricTitle(type: String) -> String {
        switch type {
        case BiometricType.face.rawValue:
            return "Face ID Authentication"
        case BiometricType.fingerprint.rawValue:
            return "Touch ID Authentication"
        default:
            return "Biometric Authentication"
        }
    }
    
    /**
     * Performs standard system biometric authentication without custom UI.
     * 
     * @param context The LAContext instance for biometric operations.
     * @param policy The authentication policy to use.
     * @param reason The reason for authentication to display to user.
     * @param result The Flutter result callback.
     */
    @available(iOS 13.0, *)
    private static func authenticateStandard(
        context: LAContext,
        policy: LAPolicy,
        reason: String,
        result: @escaping FlutterResult
    ) {
        context.evaluatePolicy(policy, localizedReason: reason) { success, error in
            Task {
                if success {
                    result(true)
                } else {
                    result(false)
                }
            }
        }
    }
}

