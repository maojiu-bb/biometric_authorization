import SwiftUI
import LocalAuthentication

/**
 * A SwiftUI view that provides a custom UI for biometric authentication.
 * This view displays a stylish interface with an animated biometric icon,
 * title, and authentication button.
 *
 * The view adapts to different screen sizes through responsive design.
 * Compatible with iOS 13.0 and later.
 */
@available(iOS 13.0, *)
struct BiometricAuthView: View {
    // Animation state variables
    @State private var isAnimating = false
    @State private var isAuthenticating = false
    
    // Environment access to dismiss the view
    @Environment(\.presentationMode) var presentationMode
    
    // View configuration properties
    var title: String
    var reason: String
    var buttonText: String
    var biometricType: String
    var onAuthenticate: (Bool) -> Void
    
    var body: some View {
        // GeometryReader allows the view to adapt to different screen sizes
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let iconSize = min(width, height) * 0.35
            let fontSize = min(width, height) * 0.15
            
            VStack(spacing: height * 0.03) {
                // Title text
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                Spacer()
                    .frame(height: height * 0.02)
                
                // Animated biometric icon
                ZStack {
                    // Background circle
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: iconSize, height: iconSize)
                    
                    // Biometric icon (Face ID or Touch ID)
                    Image(systemName: getSystemImageName())
                        .font(.system(size: fontSize))
                        .foregroundColor(.blue)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .onAppear {
                            // Create a continuous pulse animation
                            withAnimation(
                                Animation.easeInOut(duration: 1.0)
                                    .repeatForever(autoreverses: true)
                            ) {
                                isAnimating = true
                            }
                        }
                }
                
                Spacer()
                    .frame(height: height * 0.03)
                
                // Authentication button
                Button {
                    authorizationWithBiometric()
                } label: {
                    HStack {
                        Text(buttonText)
                            .font(.system(size: fontSize * 0.5))
                            .fontWeight(.semibold)
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: fontSize * 0.5))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(EdgeInsets(
                        top: height * 0.05,
                        leading: width * 0.05,
                        bottom: height * 0.05,
                        trailing: width * 0.05
                    ))
                    .background(
                        ZStack {
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.blue,
                                    Color.blue.opacity(0.8)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        }
                    )
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 3)
                }
                .padding(.horizontal, width * 0.05)
                .disabled(isAuthenticating)
            }
            .padding(width * 0.05)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.top, height * 0.03)
        }
        .onDisappear {
            isAnimating = false
        }
    }
    
    /**
     * Determines the system icon name based on the biometric type.
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
                Task {
                    isAuthenticating = false
                    if success {
                        // Authentication successful
                        onAuthenticate(true)
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        // Authentication failed
                        onAuthenticate(false)
                    }
                }
            }
        } else {
            // Device cannot use biometric authentication
            isAuthenticating = false
            onAuthenticate(false)
        }
    }
}
