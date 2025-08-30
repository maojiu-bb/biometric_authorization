# Changelog

## 1.1.1

- Lowered the minimum Flutter version to 3.10.0 and Dart version to 3.0.0

## 1.1.0 - macOS Support

**NEW PLATFORM: macOS Touch ID Authentication**

### ✨ New Features

- **macOS Platform Support**: Complete Touch ID authentication support for macOS 10.15+
- **Custom SwiftUI Interface**: Beautiful native macOS authentication UI with animations and system theme adaptation
- **System UI Integration**: Support for both system default and custom UI modes on macOS
- **Cross-Platform API**: Unified API interface across Android, iOS, and macOS platforms

### 🎨 macOS Custom UI Features

- Responsive design adapting to different window sizes and system themes
- Smooth pulse animations and hover effects for enhanced user experience
- Version compatibility: SF Symbols on macOS 11+ with Unicode fallbacks for macOS 10.15
- Native macOS design patterns and interaction behaviors
- Floating window authentication with proper focus management

### 🔧 Technical Improvements

- **Backward Compatibility**: Support for macOS 10.15+ with appropriate UI fallbacks
- **Window Management**: Robust window lifecycle management preventing crashes
- **Memory Safety**: Proper delegate reference handling eliminating weak reference warnings
- **Error Handling**: Comprehensive error handling for various authentication scenarios

### 📱 Platform Support Matrix

- **Android**: API 21+ (Fingerprint, Face recognition)
- **iOS**: iOS 11.0+ (Face ID, Touch ID)
- **macOS**: macOS 10.15+ (Touch ID) - **NEW!**

### 📚 Documentation

- Updated README with comprehensive macOS setup instructions
- Added macOS-specific usage examples and best practices
- Included platform differences and hardware requirements documentation

## 1.0.0

- Stable release incorporating features and fixes from previous versions.
- Finalized API for biometric availability checks, enrollment status, and authentication.
- Includes support for system default UI, custom bottom sheet UI (Android), and dialog-based authentication (Android).
- Supports Fingerprint on Android, and Face ID/Touch ID on iOS.
- Added Swift Package Manager support for iOS.
- Improved error handling and feedback mechanisms, including specific lockout errors.
- General stability improvements and bug fixes.

## 0.1.4

-

## 0.1.3

- Change Swift package file

## 0.1.2

- Added Swift package file

## 0.1.1

- Added dialog authentication mode for Android

## 0.1.0 - Initial Release

- Implemented biometric authentication for Android and iOS platforms
- Added support for fingerprint recognition on Android
- Added support for Face ID and Touch ID on iOS
- Implemented methods to check biometric availability on the device
- Added functionality to verify if biometric credentials are enrolled
- Developed method to retrieve available biometric types on the device
- Created both system default UI and custom UI options for authentication
- Added custom bottom sheet UI for Android
- Implemented proper error handling and user cancellation detection
- Included comprehensive documentation and usage examples
