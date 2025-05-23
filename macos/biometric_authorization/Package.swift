// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "biometric_authorization",
    platforms: [
        .macOS(.v10_15)  // Minimum macOS version supporting SwiftUI and required biometric features
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "biometric_authorization",
            targets: ["biometric_authorization"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // No external dependencies are required for this package as it uses system frameworks
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        .target(
            name: "biometric_authorization",
            dependencies: [],
            path: "../Classes",
            exclude: [
                // Exclude any files that should not be included in the package
            ],
            sources: [
                "BiometricAuthorization.swift",
                "BiometricAuthorizationPlugin.swift", 
                "BiometricAuthView.swift"
            ],
            linkerSettings: [
                // Link against required system frameworks
                .linkedFramework("LocalAuthentication"),
                .linkedFramework("SwiftUI"),
                .linkedFramework("FlutterMacOS")
            ]
        ),
        .testTarget(
            name: "biometric_authorizationTests",
            dependencies: ["biometric_authorization"],
            path: "Tests"
        ),
    ]
)
