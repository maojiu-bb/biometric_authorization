#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint biometric_authorization.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'biometric_authorization'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin for biometric authentication on macOS with Touch ID support.'
  s.description      = <<-DESC
A Flutter plugin that provides biometric authentication functionality for macOS applications.
Supports Touch ID authentication with both system and custom UI options.
Features include availability checking, enrollment status, and secure authentication flows.
                       DESC
  s.homepage         = 'https://github.com/your-repo/biometric_authorization'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }

  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'

  # If your plugin requires a privacy manifest, for example if it collects user
  # data, update the PrivacyInfo.xcprivacy file to describe your plugin's
  # privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'biometric_authorization_privacy' => ['Resources/PrivacyInfo.xcprivacy']}

  s.dependency 'FlutterMacOS'

  # Minimum macOS version required for LocalAuthentication and SwiftUI support
  s.platform = :osx, '10.15'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
  
  # Specify required frameworks
  s.frameworks = 'LocalAuthentication', 'SwiftUI'
end
