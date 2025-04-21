/**
 * BiometricAuthorizationManager.kt
 *
 * Core manager for biometric authentication operations in the Flutter plugin.
 * This class handles biometric availability checks, enrollment status, and authentication processes.
 * It supports both standard system UI and custom bottom sheet UI for biometric authentication.
 */
package com.maojiu.biometric_authorization

import android.content.Context
import androidx.biometric.BiometricManager
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import androidx.core.content.ContextCompat
import androidx.biometric.BiometricPrompt
import androidx.fragment.app.FragmentActivity

/**
 * Enum class representing the supported biometric authentication types.
 *
 * @property rawValue String value representation of the biometric type
 */
enum class BiometricType(val rawValue: String) {
    face("face"),
    fingerprint("fingerprint"),
    none("none")
}

/**
 * Manager class that handles all biometric authentication operations.
 *
 * This class provides methods to check biometric availability, enrollment status,
 * and handles the authentication flow using either the system UI or a custom UI.
 *
 * @param context The application context
 * @param activity The current activity, needed for UI operations
 */
class BiometricAuthorizationManager(
    private val context: Context,
    private val activity: FragmentActivity
) {
    private val biometricManager = BiometricManager.from(context)
    private val packageManager: PackageManager = context.packageManager

    private lateinit var biometricPrompt: BiometricPrompt
    private lateinit var promptInfo: BiometricPrompt.PromptInfo

    /**
     * Checks if biometric authentication is available on the device.
     *
     * This method verifies that the device has the necessary hardware and
     * system support for strong biometric authentication.
     *
     * @return true if biometric authentication is available, false otherwise
     */
    fun isBiometricAvailable(): Boolean {
        val canAuthenticateResult = biometricManager.canAuthenticate(
            BiometricManager.Authenticators.BIOMETRIC_STRONG
        )
        return canAuthenticateResult == BiometricManager.BIOMETRIC_SUCCESS
    }

    /**
     * Checks if biometric credentials are enrolled on the device.
     *
     * This verifies that the user has set up at least one biometric credential
     * (fingerprint, face, etc.) that can be used for authentication.
     *
     * @return true if biometric credentials are enrolled, false otherwise
     */
    fun isBiometricEnrolled(): Boolean {
        val canAuthenticateResult = biometricManager.canAuthenticate(
            BiometricManager.Authenticators.BIOMETRIC_STRONG
        )
        return canAuthenticateResult == BiometricManager.BIOMETRIC_SUCCESS
    }

    /**
     * Gets a list of available biometric authentication types on the device.
     *
     * This method checks which biometric features are supported by the device hardware.
     * If no biometric features are available, it returns a list containing only "none".
     *
     * @return List of string values representing available biometric types
     */
    fun getAvailableBiometricTypes(): List<String> {
        val availableTypes = mutableListOf<String>()

        // Check for fingerprint hardware support
        if (packageManager.hasSystemFeature(PackageManager.FEATURE_FINGERPRINT)) {
            availableTypes.add(BiometricType.fingerprint.rawValue)
        }

        // Check for face authentication hardware support (Android 10+)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            if (packageManager.hasSystemFeature(PackageManager.FEATURE_FACE)) {
                availableTypes.add(BiometricType.face.rawValue)
            }
        }

        // If no biometric types are available, add "none"
        if (availableTypes.isEmpty()) {
            availableTypes.add(BiometricType.none.rawValue)
        }

        return availableTypes
    }

    /**
     * Initiates the biometric authentication process based on Flutter method call parameters.
     *
     * This method handles the authentication flow using either the standard system UI
     * or a custom bottom sheet UI based on the useCustomUI parameter.
     *
     * @param call The method call from Flutter containing authentication parameters
     * @param result The result callback to send the authentication result back to Flutter
     */
    fun authenticate(call: MethodCall, result: Result) {
        val args = call.arguments as? Map<*, *>
        if (args == null) {
            result.error("INVALID_ARGS", "Arguments cannot be null", null)
            return
        }
        val reason = args["reason"] as? String ?: "Authenticate required"
        val title = args["title"] as? String ?: "Biometric Authentication"
        val confirmText = args["confirmText"] as? String ?: "Authenticate"
        val useCustomUI = args["useCustomUI"] as? Boolean ?: false
        val cancelText = args["cancelText"] as? String ?: "Cancel"

        try {
            // Check if biometric authentication is available
            if (!isBiometricAvailable()) {
                result.error(
                    "BIOMETRIC_UNAVAILABLE",
                    "Biometric authentication is not available on this device.",
                    null
                )
                return
            }
            // Check if biometric credentials are enrolled
            if (!isBiometricEnrolled()) {
                result.error(
                    "BIOMETRIC_NOT_ENROLLED",
                    "No biometric features are enrolled on this device.",
                    null
                )
                return
            }

            if (useCustomUI) {
                try {
                    // Set up biometric authentication with custom UI
                    setupBiometricAuth(title, reason, cancelText, activity) { success ->
                        try {
                            result.success(success)
                        } catch (e: Exception) {
                            // Ignore exceptions during result callback
                        }
                    }
                    // Show custom bottom sheet UI
                    BiometricAuthBottomSheet(title, confirmText) {
                        try {
                            biometricPrompt.authenticate(promptInfo)
                        } catch (e: Exception) {
                            result.error("BIOMETRIC_ERROR", e.message, null)
                        }
                    }.show(activity.supportFragmentManager, "biometric_auth_bottom_sheet")
                } catch (e: Exception) {
                    result.error("BIOMETRIC_ERROR", "Failed to start biometric authentication: ${e.message}", null)
                }
            } else {
                try {
                    // Set up biometric authentication with standard system UI
                    setupBiometricAuth(title, reason, cancelText, activity) { success ->
                        try {
                            result.success(success)
                        } catch (e: Exception) {
                            // Ignore exceptions during result callback
                        }
                    }
                    // Start authentication with standard UI
                    startBiometricAuth()
                } catch (e: Exception) {
                    result.error("BIOMETRIC_ERROR", "Failed to start biometric authentication: ${e.message}", null)
                }
            }
        } catch (e: Exception) {
            result.error("UNEXPECTED_ERROR", "Error during biometric authentication: ${e.message}", null)
        }
    }

    /**
     * Starts the biometric authentication process using the configured prompt.
     *
     * This method triggers the system biometric authentication dialog.
     */
    private fun startBiometricAuth() {
        biometricPrompt.authenticate(promptInfo)
    }

    /**
     * Sets up the biometric authentication components.
     *
     * This method configures the BiometricPrompt with appropriate callbacks and 
     * builds the prompt information with the specified parameters.
     *
     * @param title The title to display in the authentication dialog
     * @param reason The description/reason for requesting authentication
     * @param cancelText The text for the cancel button
     * @param activity The activity context for the authentication UI
     * @param onResult Callback function that receives the authentication result (true for success, false for failure)
     */
    private fun setupBiometricAuth(
        title: String,
        reason: String,
        cancelText: String,
        activity: FragmentActivity,
        onResult: (Boolean) -> Unit
    ) {
        val executor = ContextCompat.getMainExecutor(activity)
        biometricPrompt = BiometricPrompt(activity, executor,
            object : BiometricPrompt.AuthenticationCallback() {
                /**
                 * Called when authentication is successful.
                 */
                override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
                    onResult.invoke(true)
                }

                /**
                 * Called when authentication fails but can be retried.
                 * This doesn't count as a final failure, so we don't invoke the result callback
                 * to allow the user to retry.
                 */
                override fun onAuthenticationFailed() {
                    // Authentication failed but can be retried
                    // Don't call onResult here to allow the user to continue trying
                }

                /**
                 * Called when an authentication error occurs.
                 *
                 * Handles different error codes and determines appropriate responses:
                 * - User cancellation: Returns false without an exception
                 * - Device lockout: Returns false without an exception
                 * - Other errors: Returns false without an exception
                 *
                 * @param errorCode The error code from BiometricPrompt
                 * @param errString The error message
                 */
                override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                    // Handle different types of errors
                    when (errorCode) {
                        BiometricPrompt.ERROR_CANCELED,
                        BiometricPrompt.ERROR_USER_CANCELED,
                        BiometricPrompt.ERROR_NEGATIVE_BUTTON -> {
                            // User canceled authentication, return false without raising an exception
                            onResult.invoke(false)
                        }
                        BiometricPrompt.ERROR_LOCKOUT,
                        BiometricPrompt.ERROR_LOCKOUT_PERMANENT -> {
                            // Device is locked out, return false without raising an exception
                            onResult.invoke(false)
                        }
                        else -> {
                            // Other errors, return false without raising an exception
                            onResult.invoke(false)
                        }
                    }
                }
            })

        // Build the prompt information with the specified parameters
        promptInfo = BiometricPrompt.PromptInfo.Builder()
            .setTitle(title)
            .setSubtitle(reason)
            .setNegativeButtonText(cancelText)
            .setAllowedAuthenticators(
                BiometricManager.Authenticators.BIOMETRIC_STRONG
            )
            .build()
    }
}