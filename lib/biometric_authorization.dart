import 'biometric_authorization_platform_interface.dart';
import 'biometric_type.dart';

class BiometricAuthorization {
  Future<String?> getPlatformVersion() {
    return BiometricAuthorizationPlatform.instance.getPlatformVersion();
  }

  /// Check if biometric is available on the device.
  Future<bool> isBiometricAvailable() {
    return BiometricAuthorizationPlatform.instance.isBiometricAvailable();
  }

  /// Check if biometric is enrolled on the device.
  Future<bool> isBiometricEnrolled() {
    return BiometricAuthorizationPlatform.instance.isBiometricEnrolled();
  }

  /// Get available biometric types on the device.
  Future<List<BiometricType>> getAvailableBiometricTypes() {
    return BiometricAuthorizationPlatform.instance.getAvailableBiometricTypes();
  }

  /// Initiates biometric authentication using the device's biometric sensors.
  ///
  /// This method triggers the biometric authentication flow, which can use fingerprint,
  /// face recognition, or other biometric methods available on the device.
  ///
  /// Parameters:
  /// - [biometricType]: Specifies the type of biometric authentication to use.
  ///   Required on iOS, optional on Android (Android will automatically use available methods).
  ///   Defaults to [BiometricType.none].
  /// - [reason]: The reason for requesting authentication, displayed to the user.
  ///   Defaults to "Authenticate".
  /// - [title]: The title of the authentication dialog. If null, a default title will be used.
  /// - [confirmText]: The text for the confirmation button in the authentication dialog.
  ///   If null, a default text will be used.
  /// - [useCustomUI]: Whether to use a custom UI for authentication (true) or the system default UI (false).
  ///   Defaults to false.
  /// - [cancelText]: The text for the cancel button in the authentication dialog.
  ///   Only used on Android. If null, a default text ("Cancel") will be used.
  ///
  /// Returns a [Future<bool>] that completes with:
  /// - true: If authentication was successful
  /// - false: If authentication failed or was canceled by the user
  Future<bool> authenticate({
    BiometricType biometricType = BiometricType.none,
    String reason = "Authenticate",
    String? title,
    String? confirmText,
    bool useCustomUI = false,
    bool useDialogUI = false,
    String? cancelText,
  }) {
    return BiometricAuthorizationPlatform.instance.authenticate(
      biometricType: biometricType,
      reason: reason,
      title: title,
      confirmText: confirmText,
      useCustomUI: useCustomUI,
      useDialogUI: useDialogUI,
      cancelText: cancelText,
    );
  }
}
