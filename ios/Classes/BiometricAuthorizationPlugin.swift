import Flutter
import UIKit

/**
 * Flutter plugin that provides biometric authentication functionality for iOS.
 * This plugin serves as the bridge between Flutter and native iOS authentication APIs.
 *
 * It implements the FlutterPlugin protocol to handle method calls from Flutter
 * and delegates the actual biometric operations to the BiometricAuthorization class.
 */
public class BiometricAuthorizationPlugin: NSObject, FlutterPlugin {
    /**
     * Registers this plugin with the Flutter engine.
     * Sets up the method channel and plugin instance.
     *
     * @param registrar The Flutter plugin registrar to register with.
     */
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "biometric_authorization", binaryMessenger: registrar.messenger())
        let instance = BiometricAuthorizationPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    /**
     * Handles method calls from Flutter.
     * Routes each method to the appropriate BiometricAuthorization function.
     *
     * @param call The method call from Flutter with method name and arguments.
     * @param result The result callback to send the response back to Flutter.
     */
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            // Returns the iOS version for plugin verification
            result("iOS " + UIDevice.current.systemVersion)
            
        case "isBiometricAvailable":
            // Checks if the device has biometric hardware
            result(BiometricAuthorization.isBiometricAvailable())
            
        case "isBiometricEnrolled":
            // Checks if biometrics are enrolled on the device
            result(BiometricAuthorization.isBiometricEnrolled())
            
        case "getAvailableBiometricTypes":
            // Gets a list of available biometric types on the device
            result(BiometricAuthorization.getAvailableBiometricTypes())
            
        case "authenticate":
            // Performs biometric authentication with parameters from Flutter
            BiometricAuthorization.authenticate(call: call, result: result)
            
        default:
            // Returns not implemented for unknown methods
            result(FlutterMethodNotImplemented)
        }
    }
}
