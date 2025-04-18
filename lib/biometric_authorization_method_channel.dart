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

    // 将字符串列表转换为BiometricType枚举列表
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

  /// Authenticate with biometric.
  ///
  /// [biometricType] is the type of biometric to authenticate with.
  /// [reason] is the reason for the authentication.
  /// [title] is the title of the authentication dialog.
  /// [confirmText] is the text of the confirm button in the authentication dialog.
  /// [useCustomUI] if true, will use the custom SwiftUI view for authentication on iOS.
  @override
  Future<bool> authenticate({
    required BiometricType biometricType,
    String reason = "Authenticate",
    String? title,
    String? confirmText,
    bool useCustomUI = false,
  }) async {
    final result = await methodChannel.invokeMethod<bool>('authenticate', {
      'biometricType': biometricType.name,
      'reason': reason,
      'title': title,
      'confirmText': confirmText,
      'useCustomUI': useCustomUI,
    });
    return result ?? false;
  }
}
