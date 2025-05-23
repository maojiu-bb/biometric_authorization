import SwiftUI
import LocalAuthentication

/**
 * A SwiftUI view that provides a custom UI for biometric authentication on macOS.
 * This view displays a stylish interface with an animated biometric icon,
 * title, and authentication button designed specifically for macOS.
 *
 * The view adapts to macOS design guidelines and provides a native look and feel.
 * Compatible with macOS 10.15 and later.
 */
@available(macOS 10.15, *)
struct BiometricAuthView: View {
    // Animation state variables
    @State private var isAnimating = false
    @State private var isAuthenticating = false
    @State private var pulseScale: CGFloat = 1.0
    
    // View configuration properties
    var title: String
    var reason: String
    var buttonText: String
    var biometricType: String
    var onAuthenticate: (Bool) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Header section with title
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold, design: .default))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text(reason)
                    .font(.system(size: 14, weight: .regular, design: .default))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(.top, 20)
            
            Spacer()
            
            // Animated biometric icon section
            VStack(spacing: 16) {
                ZStack {
                    // Outer pulse ring
                    Circle()
                        .stroke(Color.accentColor.opacity(0.3), lineWidth: 2)
                        .frame(width: 120, height: 120)
                        .scaleEffect(pulseScale)
                        .animation(
                            Animation.easeInOut(duration: 2.0)
                                .repeatForever(autoreverses: true),
                            value: pulseScale
                        )
                    
                    // Inner background circle
                    Circle()
                        .fill(Color.accentColor.opacity(0.1))
                        .frame(width: 100, height: 100)
                    
                    // Biometric icon - using conditional compilation for different macOS versions
                    biometricIconView()
                        .font(.system(size: 40, weight: .regular, design: .default))
                        .foregroundColor(.accentColor)
                        .scaleEffect(isAnimating ? 1.05 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                }
                .onAppear {
                    isAnimating = true
                    pulseScale = 1.1
                }
                
                // Instruction text
                Text(getInstructionText())
                    .font(.system(size: 12, weight: .regular, design: .default))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Authentication button section with improved spacing
            VStack(spacing: 16) {
                // Add top spacing before the button
                Spacer()
                    .frame(height: 8)
                
                Button(action: {
                    authorizationWithBiometric()
                }) {
                    HStack(spacing: 8) {

                        Text(isAuthenticating ? "Authenticating..." : buttonText)
                            .font(.system(size: 14, weight: .medium, design: .default))

                        if isAuthenticating {
                            // Use a custom loading indicator for macOS 10.15 compatibility
                            loadingIndicator()
                        } else {
                            // Use conditional compilation for arrow icon
                            arrowIconView()
                                .font(.system(size: 14, weight: .medium, design: .default))
                        }
                        
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.accentColor)
                    )
                    .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(isAuthenticating)
                .onHover { hovering in
                    if !isAuthenticating {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            // Add subtle hover effect
                        }
                    }
                }
                
                // Add spacing between authenticate and cancel button
                Spacer()
                    .frame(height: 8)
                
                // Cancel button
                Button("Cancel") {
                    onAuthenticate(false)
                    closeWindow()
                }
                .buttonStyle(PlainButtonStyle())
                .font(.system(size: 12, weight: .regular, design: .default))
                .foregroundColor(.secondary)
                
                // Add bottom spacing after the cancel button
                Spacer()
                    .frame(height: 12)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .frame(width: 400, height: 300)
        .background(Color(NSColor.windowBackgroundColor))
        .onDisappear {
            isAnimating = false
            pulseScale = 1.0
        }
    }
    
    /**
     * Creates a biometric icon view that's compatible with different macOS versions.
     * Uses SF Symbols on macOS 11+ and fallback text/symbols on 10.15.
     */
    @ViewBuilder
    private func biometricIconView() -> some View {
        if #available(macOS 11.0, *) {
            Image(systemName: getSystemImageName())
        } else {
            // Fallback for macOS 10.15
            Text(getBiometricSymbol())
                .font(.system(size: 40, weight: .light, design: .default))
        }
    }
    
    /**
     * Creates an arrow icon view that's compatible with different macOS versions.
     */
    @ViewBuilder
    private func arrowIconView() -> some View {
        if #available(macOS 11.0, *) {
            Image(systemName: "arrow.right")
        } else {
            // Fallback arrow for macOS 10.15
            Text("→")
                .font(.system(size: 14, weight: .medium, design: .default))
        }
    }
    
    /**
     * Creates a loading indicator that's compatible with macOS 10.15.
     * Uses ProgressView on macOS 11+ and a custom spinning indicator on 10.15.
     */
    @ViewBuilder
    private func loadingIndicator() -> some View {
        if #available(macOS 11.0, *) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(0.8)
        } else {
            // Custom loading indicator for macOS 10.15
            Text("●")
                .foregroundColor(.white)
                .font(.system(size: 8, weight: .bold))
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .animation(
                    Animation.linear(duration: 1.0).repeatForever(autoreverses: false),
                    value: isAnimating
                )
        }
    }
    
    /**
     * Returns fallback biometric symbols for macOS 10.15.
     * Uses Unicode symbols instead of SF Symbols.
     */
    private func getBiometricSymbol() -> String {
        switch biometricType {
        case "face":
            return "👤"  // Face symbol
        case "fingerprint":
            return "👆"  // Finger symbol
        default:
            return "🔒"  // Lock symbol
        }
    }
    
    /**
     * Determines the system icon name based on the biometric type.
     * Uses SF Symbols that are appropriate for macOS 11+.
     *
     * @return The SF Symbol name for the appropriate biometric type.
     */
    func getSystemImageName() -> String {
        switch biometricType {
        case "face":
            return "faceid"
        case "fingerprint":
            return "touchid"
        default:
            return "person.circle"
        }
    }
    
    /**
     * Returns instructional text based on the biometric type.
     * Provides user-friendly guidance for the authentication process.
     *
     * @return Instruction text for the user.
     */
    func getInstructionText() -> String {
        switch biometricType {
        case "face":
            return "Look at the camera to authenticate"
        case "fingerprint":
            return "Place your finger on the Touch ID sensor"
        default:
            return "Follow the on-screen instructions"
        }
    }
    
    /**
     * Initiates the biometric authentication process when the button is tapped.
     * Uses LocalAuthentication framework to authenticate with the device biometrics.
     * The result is communicated back via the onAuthenticate callback.
     */
    func authorizationWithBiometric() {
        isAuthenticating = true
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            ) { success, error in
                DispatchQueue.main.async {
                    isAuthenticating = false
                    if success {
                        // Authentication successful
                        onAuthenticate(true)
                        closeWindow()
                    } else {
                        // Authentication failed - show error or retry
                        handleAuthenticationError(error)
                    }
                }
            }
        } else {
            // Device cannot use biometric authentication
            DispatchQueue.main.async {
                isAuthenticating = false
                onAuthenticate(false)
                closeWindow()
            }
        }
    }
    
    /**
     * Handles authentication errors by providing user feedback.
     * Different error types may require different handling approaches.
     *
     * @param error The authentication error, if any.
     */
    private func handleAuthenticationError(_ error: Error?) {
        if let laError = error as? LAError {
            switch laError.code {
            case .userCancel, .appCancel, .systemCancel:
                // User cancelled authentication
                onAuthenticate(false)
                closeWindow()
            case .userFallback:
                // User chose to use password instead
                onAuthenticate(false)
                closeWindow()
            default:
                // Other errors - could show retry option
                onAuthenticate(false)
                closeWindow()
            }
        } else {
            // Unknown error
            onAuthenticate(false)
            closeWindow()
        }
    }
    
    /**
     * Closes the authentication window.
     * Finds and closes the biometric authentication window.
     */
    private func closeWindow() {
        // Try to find the window by title first
        if let window = NSApplication.shared.windows.first(where: { $0.title == "Biometric Authentication" }) {
            window.close()
        }
        
        // Also try to close the key window if it's our authentication window
        if let keyWindow = NSApplication.shared.keyWindow,
           keyWindow.title == "Biometric Authentication" {
            keyWindow.close()
        }
    }
} 