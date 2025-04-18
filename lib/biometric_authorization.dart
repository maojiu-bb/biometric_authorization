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

  /// Authenticate with biometric.
  ///
  /// [biometricType] is the type of biometric to authenticate with.
  /// [reason] is the reason for the authentication.
  /// [title] is the title of the authentication dialog.
  /// [confirmText] is the text of the confirm button in the authentication dialog.
  /// [useCustomUI] if true, will use the custom SwiftUI view for authentication on iOS.
  Future<bool> authenticate({
    required BiometricType biometricType,
    String reason = "Authenticate",
    String? title,
    String? confirmText,
    bool useCustomUI = false,
  }) {
    return BiometricAuthorizationPlatform.instance.authenticate(
      biometricType: biometricType,
      reason: reason,
      title: title,
      confirmText: confirmText,
      useCustomUI: useCustomUI,
    );
  }
}
