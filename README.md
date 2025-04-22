# Biometric Authorization

A Flutter plugin that provides easy-to-use biometric authentication for both Android and iOS platforms. This plugin allows your app to securely authenticate users using biometric features such as fingerprint, face recognition, and other available biometric methods.

![Platform Support](https://img.shields.io/badge/platform-android%20%7C%20ios-green.svg)
[![Pub Version](https://img.shields.io/pub/v/biometric_authorization.svg)](https://pub.dev/packages/biometric_authorization)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Features

- Check if biometric authentication is available on the device
- Verify if biometric credentials are enrolled
- Get a list of available biometric types (fingerprint, face recognition.)
- Authenticate users with biometric verification
- Support for both default system UI and custom UI for authentication
- Platform-specific implementations for Android and iOS

## Screenshots

### iOS Authentication

|                                                           Touch ID - System UI                                                           |                                                           Touch ID - Custom UI                                                            |                                                           Face ID - Custom UI                                                           |
| :--------------------------------------------------------------------------------------------------------------------------------------: | :---------------------------------------------------------------------------------------------------------------------------------------: | :-------------------------------------------------------------------------------------------------------------------------------------: |
| ![iOS Touch ID System UI](https://github.com/maojiu-bb/biometric_authorization/blob/main/screenshots/ios-touch-default-pop.png?raw=true) | ![iOS Touch ID Custom UI](https://github.com/maojiu-bb/biometric_authorization/blob/main/screenshots/ios-touch-custom-sheet.png?raw=true) | ![iOS Face ID Custom UI](https://github.com/maojiu-bb/biometric_authorization/blob/main/screenshots/ios-face-custom-sheet.png?raw=true) |

### Android Authentication

|                                                              Default UI                                                              |                                                             Custom UI (Sheet)                                                              |                                                              Custom UI (Dialog)                                                              |
| :----------------------------------------------------------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------------------------------------------------------: | :------------------------------------------------------------------------------------------------------------------------------------------: |
| ![Android Default UI](https://github.com/maojiu-bb/biometric_authorization/blob/main/screenshots/android-default-sheet.png?raw=true) | ![Android Custom UI (Sheet)](https://github.com/maojiu-bb/biometric_authorization/blob/main/screenshots/android-custom-sheet.png?raw=true) | ![Android Custom UI (Dialog)](https://github.com/maojiu-bb/biometric_authorization/blob/main/screenshots/android-custom-dialog.png?raw=true) |

## Platform Support

|            Android            |        iOS        |
| :---------------------------: | :---------------: |
| Fingerprint, Face recognition | Face ID, Touch ID |
|            API 21+            |     iOS 11.0+     |

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  biometric_authorization: ^0.1.0
```

Then run:

```bash
flutter pub get
```

### Android Setup

1. Add the following permission to your `AndroidManifest.xml` file:

```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
```

2. **Important**: You must use `FlutterFragmentActivity` instead of `FlutterActivity` in your Android project. In your `MainActivity.kt` file:

```kotlin
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity: FlutterFragmentActivity() {
    // ...
}
```

### iOS Setup

Add the following to your `Info.plist` file:

```xml
<key>NSFaceIDUsageDescription</key>
<string>Your app needs to authenticate using your biometric data for secure access</string>
```

## Usage

Import the package:

```dart
import 'package:biometric_authorization/biometric_authorization.dart';
import 'package:biometric_authorization/biometric_type.dart';
```

### Check Biometric Availability

```dart
final biometricAuth = BiometricAuthorization();

// Check if biometric authentication is available
bool isAvailable = await biometricAuth.isBiometricAvailable();

// Check if biometric credentials are enrolled
bool isEnrolled = await biometricAuth.isBiometricEnrolled();

// Get available biometric types
List<BiometricType> types = await biometricAuth.getAvailableBiometricTypes();
```

### Authenticate with Biometrics

#### Using Default System UI

```dart
try {
  bool authenticated = await biometricAuth.authenticate(
    reason: 'Please authenticate to access your account',
    title: 'Biometric Authentication',
    confirmText: 'Verify',
  );

  if (authenticated) {
    // User authenticated successfully
    print('Authentication successful');
  } else {
    // Authentication failed or was cancelled
    print('Authentication failed');
  }
} catch (e) {
  print('Error during authentication: $e');
}
```

#### Using Custom UI

```dart
bool authenticated = await biometricAuth.authenticate(
  reason: 'Please authenticate to access your account',
  title: 'Biometric Authentication',
  confirmText: 'Verify',
  useCustomUI: true,
);
```

#### Using Dialog UI (Available in Android)

```dart
bool authenticated = await biometricAuth.authenticate(
  reason: 'Please authenticate to access your account',
  title: 'Biometric Authentication',
  confirmText: 'Verify',
  useDialog: true
);
```

### Platform-Specific Parameters

The `authenticate` method has some parameters that behave differently depending on the platform:

- **biometricType**: This parameter is **required on iOS** to specify which biometric method to use (face or fingerprint). On Android, it's optional as Android will automatically use available methods.

  ```dart
  // Example for iOS - must specify biometricType
  await biometricAuth.authenticate(
    biometricType: BiometricType.face, // Use Face ID
    reason: 'Authenticate to continue',
  );
  ```

- **cancelText**: This parameter is only effective on **Android**. It specifies the text for the cancel button in the authentication dialog. On iOS, this parameter is ignored.

  ```dart
  // Example for Android - can specify cancelText
  await biometricAuth.authenticate(
    reason: 'Authenticate to continue',
    cancelText: 'Not now',
  );
  ```

## API Reference

### BiometricAuthorization

Main class providing biometric authentication functionality.

#### Methods

- `Future<bool> isBiometricAvailable()` - Checks if biometric authentication is available on the device.
- `Future<bool> isBiometricEnrolled()` - Checks if biometric credentials are enrolled on the device.
- `Future<List<BiometricType>> getAvailableBiometricTypes()` - Gets available biometric types on the device.
- `Future<bool> authenticate({...})` - Authenticates the user with biometrics.

### BiometricType

Enum representing different biometric authentication types:

- `BiometricType.face` - Face recognition (Face ID on iOS, face authentication on Android)
- `BiometricType.fingerprint` - Fingerprint recognition (Touch ID on iOS, fingerprint on Android)
- `BiometricType.none` - No biometric type available

## Platform-Specific Features

### Android

- Support for both fingerprint and face recognition
- Custom UI option with bottom sheet design
- Support for predictive back gesture navigation on Android 13+
- Handles biometric lockout scenarios gracefully
- Requires `FlutterFragmentActivity` instead of `FlutterActivity`
- The `cancelText` parameter can be used to customize the cancel button text

### iOS

- Native support for Face ID and Touch ID
- Seamless integration with Apple's security framework
- Proper handling of authentication cancelation and errors
- The `biometricType` parameter is required to specify which biometric method to use

## Example

A full example app is available in the [example](https://github.com/your-username/biometric_authorization/tree/main/example) directory.

## Contributing

Contributions are welcome! If you find a bug or want a feature, please open an issue or submit a PR.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
