import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'biometric_authorization_method_channel.dart';
import 'biometric_type.dart';

abstract class BiometricAuthorizationPlatform extends PlatformInterface {
  /// Constructs a BiometricAuthorizationPlatform.
  BiometricAuthorizationPlatform() : super(token: _token);

  static final Object _token = Object();

  static BiometricAuthorizationPlatform _instance =
      MethodChannelBiometricAuthorization();

  /// The default instance of [BiometricAuthorizationPlatform] to use.
  ///
  /// Defaults to [MethodChannelBiometricAuthorization].
  static BiometricAuthorizationPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BiometricAuthorizationPlatform] when
  /// they register themselves.
  static set instance(BiometricAuthorizationPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /// Check if biometric is available on the device.
  Future<bool> isBiometricAvailable() async {
    throw UnimplementedError(
      'isBiometricAvailable() has not been implemented.',
    );
  }

  /// Check if biometric is enrolled on the device.
  Future<bool> isBiometricEnrolled() async {
    throw UnimplementedError('isBiometricEnrolled() has not been implemented.');
  }

  /// Get available biometric types on the device.
  Future<List<BiometricType>> getAvailableBiometricTypes() async {
    throw UnimplementedError(
      'getAvailableBiometricTypes() has not been implemented.',
    );
  }

  /// Authenticate with biometric.
  Future<bool> authenticate({
    BiometricType biometricType = BiometricType.none,
    String reason = "Authenticate",
    String? title,
    String? confirmText,
    bool useCustomUI = false,
    bool useDialogUI = false,
    String? cancelText,
  }) async {
    throw UnimplementedError('authenticate() has not been implemented.');
  }
}
