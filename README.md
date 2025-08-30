# Biometric Authorization

A Flutter plugin that provides easy-to-use biometric authentication for Android, iOS, and macOS platforms. This plugin allows your app to securely authenticate users using biometric features such as fingerprint, face recognition, and other available biometric methods.

![Platform Support](https://img.shields.io/badge/platform-android%20%7C%20ios%20%7C%20macos-green.svg)
[![Pub Version](https://img.shields.io/pub/v/biometric_authorization.svg)](https://pub.dev/packages/biometric_authorization)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Features

- Check if biometric authentication is available on the device
- Verify if biometric credentials are enrolled
- Get a list of available biometric types (fingerprint, face recognition)
- Authenticate users with biometric verification
- Support for both default system UI and custom UI for authentication
- Cross-platform implementations for Android, iOS, and macOS
- Native macOS Touch ID integration with SwiftUI custom UI

## Screenshots

### iOS Authentication

|                                                           Touch ID - System UI                                                           |                                                           Touch ID - Custom UI                                                            |                                                           Face ID - Custom UI                                                           |
| :--------------------------------------------------------------------------------------------------------------------------------------: | :---------------------------------------------------------------------------------------------------------------------------------------: | :-------------------------------------------------------------------------------------------------------------------------------------: |
| ![iOS Touch ID System UI](https://github.com/maojiu-bb/biometric_authorization/blob/main/screenshots/ios-touch-default-pop.png?raw=true) | ![iOS Touch ID Custom UI](https://github.com/maojiu-bb/biometric_authorization/blob/main/screenshots/ios-touch-custom-sheet.png?raw=true) | ![iOS Face ID Custom UI](https://github.com/maojiu-bb/biometric_authorization/blob/main/screenshots/ios-face-custom-sheet.png?raw=true) |

### Android Authentication

|                                                              Default UI                                                              |                                                             Custom UI (Sheet)                                                              |                                                              Custom UI (Dialog)                                                              |
| :----------------------------------------------------------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------------------------------------------------------: | :------------------------------------------------------------------------------------------------------------------------------------------: |
| ![Android Default UI](https://github.com/maojiu-bb/biometric_authorization/blob/main/screenshots/android-default-sheet.png?raw=true) | ![Android Custom UI (Sheet)](https://github.com/maojiu-bb/biometric_authorization/blob/main/screenshots/android-custom-sheet.png?raw=true) | ![Android Custom UI (Dialog)](https://github.com/maojiu-bb/biometric_authorization/blob/main/screenshots/android-custom-dialog.png?raw=true) |

### macOS Authentication

|                                                              Touch ID - System UI                                                               |                                                              Touch ID - Custom UI                                                              |
| :---------------------------------------------------------------------------------------------------------------------------------------------: | :--------------------------------------------------------------------------------------------------------------------------------------------: |
| ![macOS Touch ID System UI](https://github.com/maojiu-bb/biometric_authorization/blob/main/screenshots/macos-touch-default-dialog.png?raw=true) | ![macOS Touch ID Custom UI](https://github.com/maojiu-bb/biometric_authorization/blob/main/screenshots/macos-touch-custom-dialog.png?raw=true) |

## Platform Support

|            Android            |        iOS        |    macOS     |
| :---------------------------: | :---------------: | :----------: |
| Fingerprint, Face recognition | Face ID, Touch ID |   Touch ID   |
|            API 21+            |     iOS 11.0+     | macOS 10.15+ |

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  biometric_authorization: ^1.1.1
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

### macOS Setup

1. **Minimum Version**: Ensure your macOS deployment target is at least **macOS 10.15** (Catalina) in your `macos/Runner.xcodeproj` project settings.

2. **Entitlements**: No special entitlements are required for Touch ID authentication. The LocalAuthentication framework handles permissions automatically. Your existing entitlements files should work as-is:

   ```xml
   <!-- macos/Runner/DebugProfile.entitlements -->
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
       <key>com.apple.security.app-sandbox</key>
       <true/>
       <key>com.apple.security.cs.allow-jit</key>
       <true/>
       <key>com.apple.security.network.server</key>
       <true/>
   </dict>
   </plist>
   ```

3. **Hardware Requirements**: Touch ID functionality requires a Mac with Touch ID sensor (MacBook Pro with Touch Bar, MacBook Air 2018+, iMac Pro, Mac Studio, etc.).

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

#### Using Dialog UI (Available on Android)

```dart
bool authenticated = await biometricAuth.authenticate(
  reason: 'Please authenticate to access your account',
  title: 'Biometric Authentication',
  confirmText: 'Verify',
  useDialog: true,
);
```

### Platform-Specific Parameters

The `authenticate` method has some parameters that behave differently depending on the platform:

- **biometricType**: This parameter is **required on iOS and macOS** to specify which biometric method to use (face or fingerprint). On Android, it's optional as Android will automatically use available methods.

  ```dart
  // Example for iOS/macOS - must specify biometricType
  await biometricAuth.authenticate(
    biometricType: BiometricType.fingerprint, // Use Touch ID on macOS
    reason: 'Authenticate to continue',
  );
  ```

- **cancelText**: This parameter is only effective on **Android**. It specifies the text for the cancel button in the authentication dialog. On iOS and macOS, this parameter is ignored.

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
- `BiometricType.fingerprint` - Fingerprint recognition (Touch ID on iOS/macOS, fingerprint on Android)
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
- Custom UI with SwiftUI integration for iOS 13+

### macOS

- Native Touch ID support for compatible Mac hardware
- Beautiful SwiftUI-based custom authentication interface
- Automatic adaptation to system light/dark mode
- Floating window authentication UI with proper focus management
- Backward compatibility with macOS 10.15+ (with appropriate fallbacks for UI elements)
- The `biometricType` parameter is required (use `BiometricType.fingerprint` for Touch ID)
- Hardware dependency: Requires Mac with Touch ID sensor

#### macOS Custom UI Features

- **Responsive Design**: Adapts to different window sizes and system themes
- **Animated Elements**: Smooth pulse animations and hover effects
- **Version Compatibility**: Uses SF Symbols on macOS 11+ and Unicode fallbacks on macOS 10.15
- **Native Feel**: Follows macOS design guidelines and interaction patterns

## Example

A full example app is available in the [example](https://github.com/your-username/biometric_authorization/tree/main/example) directory.

## Contributing

Contributions are welcome! If you find a bug or want a feature, please open an issue or submit a PR.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
