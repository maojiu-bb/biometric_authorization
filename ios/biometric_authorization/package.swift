// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "BiometricAuthorizationPlugin", // Package name, usually related to the plugin name
    platforms: [
        .iOS(.v11) // Specify the minimum supported iOS version
    ],
    products: [
        // Defines the library product that can be used by other packages or apps
        .library(
            name: "BiometricAuthorizationPlugin",
            targets: ["BiometricAuthorizationPlugin"]) // The target the library product depends on
    ],
    dependencies: [

    ],
    targets: [
        // Defines the main target containing the plugin's Swift code
        .target(
            name: "BiometricAuthorizationPlugin",
            dependencies: [

            ],
            path: ".",
            sources: ["Classes"] 
        )
    ]
)
