/**
 * BiometricAuthorizationManager.kt
 *
 * Core manager for biometric authentication operations in the Flutter plugin.
 * This class handles biometric availability checks, enrollment status, and authentication processes.
 * It supports both standard system UI and custom bottom sheet UI for biometric authentication.
 */
@file:Suppress("DEPRECATION")

package com.maojiu.biometric_authorization

import android.annotation.SuppressLint
import android.content.Context
import androidx.biometric.BiometricManager
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import androidx.core.content.ContextCompat
import androidx.biometric.BiometricPrompt
import androidx.core.hardware.fingerprint.FingerprintManagerCompat
import androidx.fragment.app.FragmentActivity
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import android.util.Log
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import androidx.fragment.app.DialogFragment
import java.util.concurrent.atomic.AtomicBoolean

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
 * Constants for fingerprint error codes from FingerprintManager
 * These are not available in FingerprintManagerCompat but are needed for error handling
 */
object FingerprintConstants {
    const val FINGERPRINT_ERROR_CANCELED = 5
    const val FINGERPRINT_ERROR_USER_CANCELED = 10
    const val FINGERPRINT_ERROR_LOCKOUT = 7
    const val FINGERPRINT_ERROR_LOCKOUT_PERMANENT = 9
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
@Suppress("DEPRECATION")
class BiometricAuthorizationManager(
    private val context: Context,
    private val activity: FragmentActivity
) {
    /**
     * use biometricManager to used new UI for biometric authentication
     * use fingerprintManager to used deprecated UI for fingerprint authentication 
     */
    private val biometricManager = BiometricManager.from(context)
    @SuppressLint("RestrictedApi")
    private val fingerprintManager = FingerprintManagerCompat.from(context)

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
        val useDialogUI = args["useDialogUI"] as? Boolean ?: false
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
                            // Set up biometric authentication with dialog UI
                            if (useDialogUI) {
                                startFingerprintAuth(result, title, cancelText)
                            } else {
                                startBiometricAuth()
                            }
                        } catch (e: Exception) {
                            result.error("BIOMETRIC_ERROR", e.message, null)
                        }
                    }.show(activity.supportFragmentManager, "biometric_auth_bottom_sheet")
                } catch (e: Exception) {
                    result.error("BIOMETRIC_ERROR", "Failed to start biometric authentication: ${e.message}", null)
                }
            } else {
                try {
                    // Set up biometric authentication with dialog UI
                    if (useDialogUI) {
                        startFingerprintAuth(result, title, cancelText)
                        return
                    }

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
     * Starts the fingerprint authentication process used with the deprecated UI.
     *
     * This method is used when the useDeprecatedUI parameter is set to true.
     *
     * Android 10 and above only support fingerprint authentication.
     * 
     * @param result The result callback to send the authentication result back to Flutter
     */
    @SuppressLint("RestrictedApi", "MissingPermission")
    private fun startFingerprintAuth(result: Result, title: String, cancelText: String) {
        // Flag to ensure result is called only once
        val resultSent = AtomicBoolean(false)

        // Wrapper for result callback to prevent multiple calls
        val safeResult = object {
            fun success(value: Any?) {
                if (resultSent.compareAndSet(false, true)) {
                    activity.runOnUiThread {
                        try { result.success(value) } catch (e: Exception) { Log.w("BiometricAuth", "Result success error: ${e.message}") }
                    }
                }
            }
            fun error(code: String, message: String?, details: Any?) {
                if (resultSent.compareAndSet(false, true)) {
                    activity.runOnUiThread {
                        try { result.error(code, message, details) } catch (e: Exception) { Log.w("BiometricAuth", "Result error error: ${e.message}") }
                    }
                }
            }
        }

        // Check if the device supports fingerprint authentication
        if (!fingerprintManager.isHardwareDetected) {
            Log.d("BiometricAuth", "Device does not support fingerprint authentication")
            safeResult.error(
                "FINGERPRINT_UNAVAILABLE",
                "Device does not support fingerprint authentication",
                null
            )
            return
        }

        // Check if there are any enrolled fingerprints
        if (!fingerprintManager.hasEnrolledFingerprints()) {
            Log.d("BiometricAuth", "No fingerprints are enrolled on this device")
            safeResult.error(
                "FINGERPRINT_NOT_ENROLLED",
                "No fingerprints are enrolled on this device",
                null
            )
            return
        }

        // Create a crypto object as an authentication token
        val cryptoObject = createCryptoObject()
        if (cryptoObject == null) {
            Log.d("BiometricAuth", "Failed to create CryptoObject")
            safeResult.error(
                "FINGERPRINT_CRYPTO_ERROR",
                "Failed to create cryptographic object for fingerprint authentication",
                null
            )
            return
        }

        // Create a cancellation signal for the authentication
        val cancellationSignal = androidx.core.os.CancellationSignal()

        // Create authentication callback
        val callback = object : FingerprintManagerCompat.AuthenticationCallback() {
            override fun onAuthenticationSucceeded(authResult: FingerprintManagerCompat.AuthenticationResult) {
                // Authentication succeeded
                Log.d("BiometricAuth", "Fingerprint authentication succeeded")
                // Dismiss the dialog if it's still showing
                activity.supportFragmentManager.findFragmentByTag("FingerprintDialogFragment")?.let {
                    (it as? DialogFragment)?.dismissAllowingStateLoss()
                }
                safeResult.success(true)
            }

            override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                // Authentication error
                Log.d("BiometricAuth", "Fingerprint authentication error: $errString ($errorCode)")
                // Dismiss the dialog if it's still showing
                activity.supportFragmentManager.findFragmentByTag("FingerprintDialogFragment")?.let {
                    (it as? DialogFragment)?.dismissAllowingStateLoss()
                }
                when (errorCode) {
                    FingerprintConstants.FINGERPRINT_ERROR_CANCELED,
                    FingerprintConstants.FINGERPRINT_ERROR_USER_CANCELED -> {
                        // User canceled authentication via system prompt or custom dialog cancel
                        safeResult.success(false)
                    }
                    FingerprintConstants.FINGERPRINT_ERROR_LOCKOUT,
                    FingerprintConstants.FINGERPRINT_ERROR_LOCKOUT_PERMANENT -> {
                        // Device is locked out
                        safeResult.success(false) // Reporting false, could be a specific error too
                    }
                    else -> {
                        // Other errors
                        safeResult.error(
                            "FINGERPRINT_ERROR",
                            errString.toString(),
                            errorCode // Include error code in details
                        )
                    }
                }
            }

            override fun onAuthenticationFailed() {
                // Authentication failed but can be retried
                Log.d("BiometricAuth", "Fingerprint authentication failed but can be retried")
            }
        }

        /**
         * Start fingerprint authentication
         *
         * Parameters:
         * @param crypto: the crypto object
         * @param flags: optional flags, usually 0  
         * @param cancel: a cancellation signal object to cancel the authentication
         * @param callback: the callback that receives authentication results
         * @param handler: handler for delivering messages, or null for default handler
         */
        fingerprintManager.authenticate(
            cryptoObject,
            0,
            cancellationSignal,
            callback,
            null
        )

        // --- Display the Custom Dialog --- 
        val fragmentManager = activity.supportFragmentManager
        // Ensure previous dialog is dismissed if any (e.g., rapid calls)
        fragmentManager.findFragmentByTag("FingerprintDialogFragment")?.let {
            (it as? DialogFragment)?.dismissAllowingStateLoss()
        }
        val dialogFragment = FingerprintDialogFragment.newInstance(title, cancelText) {
            // onCancel lambda from custom dialog
            Log.d("BiometricAuth", "Custom dialog cancelled by user.")
            if (!cancellationSignal.isCanceled) {
                 // IMPORTANT: Calling cancel here will trigger the onAuthenticationError callback
                 // with FINGERPRINT_ERROR_CANCELED. The callback will handle sending the result.
                cancellationSignal.cancel()
            }
        }
        // Show the dialog. It will appear over the activity while the fingerprint manager attempts auth.
        dialogFragment.show(fragmentManager, "FingerprintDialogFragment")
    }

    /**
     * Creates a cryptographic object for fingerprint authentication
     * 
     * @return Crypto object, or null if creation fails
     */
    @SuppressLint("RestrictedApi")
    private fun createCryptoObject(): FingerprintManagerCompat.CryptoObject? {
        // Early return for devices below Marshmallow
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            Log.e("BiometricAuth", "Fingerprint authentication requires Android 6.0 or above")
            return null
        }
        
        try {
            // Create and get Android KeyStore instance
            val keyStore = KeyStore.getInstance("AndroidKeyStore")
            keyStore.load(null)
            
            // Key alias
            val keyName = "com.maojiu.biometric_authorization.key"
            
            // Check if the key already exists, create it if not
            if (!keyStore.containsAlias(keyName)) {
                val keyGenerator = KeyGenerator.getInstance(
                    KeyProperties.KEY_ALGORITHM_AES, 
                    "AndroidKeyStore"
                )
                
                val builder = KeyGenParameterSpec.Builder(
                    keyName,
                    KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
                )
                    .setBlockModes(KeyProperties.BLOCK_MODE_CBC)
                    .setUserAuthenticationRequired(true)
                    .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_PKCS7)
                
                // Set authentication validity period if API level supports it
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    builder.setInvalidatedByBiometricEnrollment(true)
                }
                
                keyGenerator.init(builder.build())
                keyGenerator.generateKey()
            }
            
            // Get the key and initialize Cipher
            val key = keyStore.getKey(keyName, null) as SecretKey
            val cipher = Cipher.getInstance(
                KeyProperties.KEY_ALGORITHM_AES + "/" +
                KeyProperties.BLOCK_MODE_CBC + "/" +
                KeyProperties.ENCRYPTION_PADDING_PKCS7
            )
            
            // Initialize the Cipher for encryption mode
            cipher.init(Cipher.ENCRYPT_MODE, key)
            
            // Create and return CryptoObject
            return FingerprintManagerCompat.CryptoObject(cipher)
        } catch (e: Exception) {
            // Log the error but don't throw an exception, return null to indicate crypto object creation failed
            Log.e("BiometricAuth", "Failed to create CryptoObject: ${e.message}", e)
            return null
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