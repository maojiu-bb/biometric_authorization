import Foundation
import LocalAuthentication
import SwiftUI
import FlutterMacOS

/**
 * Represents the supported biometric authentication types on macOS.
 * Maps to the corresponding types defined in the Dart code.
 */
enum BiometricType: String {
    case face = "face"          // Face ID (not supported on current macOS hardware)
    case fingerprint = "fingerprint"  // Touch ID on supported Mac models
    case none = "none"          // Fallback when no biometric is available
}

/**
 * Main class that handles biometric authentication functionality for macOS.
 * Provides methods to check availability, enrollment, and perform authentication.
 * Supports Touch ID on compatible Mac hardware.
 */
class BiometricAuthorization {
    
    // Store the authentication window to manage its lifecycle
    private static var authWindow: NSWindow?
    
    // Store the window delegate to maintain a strong reference
    private static var windowDelegate: WindowDelegate?
    
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
     * Checks if biometric authentication is available on the macOS device.
     * This checks if the hardware supports biometrics (Touch ID).
     * 
     * @return Boolean indicating if biometric authentication is available.
     */
    static func isBiometricAvailable() -> Bool {
        let context = createContext()
        var error: NSError?
        let available = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        return available
    }
    
    /**
     * Checks if biometric authentication is enrolled on the macOS device.
     * This verifies if the user has registered their biometrics (fingerprint).
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
     * Determines which biometric types are available on the macOS device.
     * Currently only Touch ID is supported on Mac hardware.
     * 
     * @return Array of strings representing available biometric types.
     *         Returns ["fingerprint"] if Touch ID is available, ["none"] otherwise.
     */
    static func getAvailableBiometricTypes() -> [String] {
        let context = createContext()
        var error: NSError?
        var biometricTypes: [String] = []
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            switch context.biometryType {
            case .touchID:
                biometricTypes.append(BiometricType.fingerprint.rawValue)
            case .faceID:
                // Face ID is not currently supported on macOS hardware
                // But we include it for future compatibility
                biometricTypes.append(BiometricType.face.rawValue)
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
        
        if #available(macOS 10.15, *) {
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
        } else {
            // For macOS versions below 10.15, only use standard authentication
            authenticateStandard(
                context: context,
                policy: policy,
                reason: reason,
                result: result
            )
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
    @available(macOS 10.15, *)
    private static func showCustomUI(
        biometricType: String,
        title: String?,
        confirmText: String?,
        context: LAContext,
        policy: LAPolicy,
        reason: String,
        result: @escaping FlutterResult
    ) {
        DispatchQueue.main.async {
            presentBiometricWindow(
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
     * Presents the custom biometric authentication window using SwiftUI.
     * Creates a modal window with custom styling for macOS.
     * 
     * @param context The LAContext instance for biometric operations.
     * @param policy The authentication policy to use.
     * @param reason The reason for authentication to display to user.
     * @param title Optional title for the authentication dialog.
     * @param confirmText Optional text for the confirm button.
     * @param biometricType The type of biometric to authenticate with.
     * @param result The Flutter result callback.
     */
    @available(macOS 10.15, *)
    private static func presentBiometricWindow(
        context: LAContext,
        policy: LAPolicy,
        reason: String,
        title: String?,
        confirmText: String?,
        biometricType: String,
        result: @escaping FlutterResult
    ) {
        // Close any existing authentication window first
        closeAuthWindow()
        
        // Create the SwiftUI view for biometric authentication
        let contentView = BiometricAuthView(
            title: title ?? getBiometricTitle(type: biometricType),
            reason: reason,
            buttonText: confirmText ?? "Authenticate",
            biometricType: biometricType,
            onAuthenticate: { success in
                result(success)
                // Close the window after authentication
                closeAuthWindow()
            }
        )
        
        // Create a hosting controller for the SwiftUI view
        let hostingController = NSHostingController(rootView: contentView)
        
        // Create and configure the modal window
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "Biometric Authentication"
        window.contentViewController = hostingController
        window.isReleasedWhenClosed = false
        window.level = .floating
        window.center()
        
        // Store the window reference
        authWindow = window
        
        // Create and store the window delegate with a strong reference
        let delegate = WindowDelegate(onClose: {
            result(false)
            closeAuthWindow()
        })
        windowDelegate = delegate
        window.delegate = delegate
        
        // Show the window as a floating panel
        window.makeKeyAndOrderFront(nil)
        
        // Bring to front and focus
        NSApp.activate(ignoringOtherApps: true)
    }
    
    /**
     * Closes the authentication window if it exists.
     */
    private static func closeAuthWindow() {
        if let window = authWindow {
            window.delegate = nil
            window.close()
            authWindow = nil
        }
        windowDelegate = nil
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
     * Uses the built-in macOS authentication dialog.
     * 
     * @param context The LAContext instance for biometric operations.
     * @param policy The authentication policy to use.
     * @param reason The reason for authentication to display to user.
     * @param result The Flutter result callback.
     */
    private static func authenticateStandard(
        context: LAContext,
        policy: LAPolicy,
        reason: String,
        result: @escaping FlutterResult
    ) {
        context.evaluatePolicy(policy, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                if success {
                    result(true)
                } else {
                    result(false)
                }
            }
        }
    }
}

/**
 * Window delegate to handle window events.
 */
@available(macOS 10.15, *)
private class WindowDelegate: NSObject, NSWindowDelegate {
    private let onClose: () -> Void
    
    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
        super.init()
    }
    
    func windowWillClose(_ notification: Notification) {
        onClose()
    }
} 