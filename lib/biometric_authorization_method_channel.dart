import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'biometric_authorization_platform_interface.dart';
import 'biometric_type.dart';

/// An implementation of [BiometricAuthorizationPlatform] that uses method channels.
class MethodChannelBiometricAuthorization
    extends BiometricAuthorizationPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('biometric_authorization');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  /// Check if biometric is available on the device.
  @override
  Future<bool> isBiometricAvailable() async {
    final result = await methodChannel.invokeMethod<bool>(
      'isBiometricAvailable',
    );
    return result ?? false;
  }

  /// Check if biometric is enrolled on the device.
  @override
  Future<bool> isBiometricEnrolled() async {
    final result = await methodChannel.invokeMethod<bool>(
      'isBiometricEnrolled',
    );
    return result ?? false;
  }

  /// Get available biometric types on the device.
  ///
  /// Returns a list of biometric types that are available on the device.
  @override
  Future<List<BiometricType>> getAvailableBiometricTypes() async {
    final result = await methodChannel.invokeMethod<List<dynamic>>(
      'getAvailableBiometricTypes',
    );

    if (result == null) {
      return [];
    }

    // Convert the string list to a BiometricType enum list
    return result.map<BiometricType>((item) {
      final String type = item.toString();
      switch (type) {
        case 'face':
          return BiometricType.face;
        case 'fingerprint':
          return BiometricType.fingerprint;
        case 'none':
        default:
          return BiometricType.none;
      }
    }).toList();
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
  /// - [useDialogUI]: Whether to use the Dialog UI for authentication (true) or the new UI (false) in Android.
  ///   Defaults to false.
  /// - [cancelText]: The text for the cancel button in the authentication dialog.
  ///   Only used on Android. If null, a default text ("Cancel") will be used.
  ///
  /// Returns a [Future<bool>] that completes with:
  /// - true: If authentication was successful
  /// - false: If authentication failed or was canceled by the user
  @override
  Future<bool> authenticate({
    BiometricType biometricType = BiometricType.none,
    String reason = "Authenticate",
    String? title,
    String? confirmText,
    bool useCustomUI = false,
    bool useDialogUI = false,
    String? cancelText,
  }) async {
    final Map<String, dynamic> arguments = {
      'biometricType': biometricType.name,
      'reason': reason,
      'title': title,
      'confirmText': confirmText,
      'useCustomUI': useCustomUI,
      'useDialogUI': useDialogUI,
      'cancelText': cancelText,
    };

    final result = await methodChannel.invokeMethod<bool>(
      'authenticate',
      arguments,
    );
    return result ?? false;
  }
}
