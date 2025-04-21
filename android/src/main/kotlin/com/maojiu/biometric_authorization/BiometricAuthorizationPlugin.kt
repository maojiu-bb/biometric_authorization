/**
 * BiometricAuthorizationPlugin.kt
 *
 * Main entry point for the Flutter plugin that provides biometric authentication capabilities.
 * This plugin serves as a bridge between Flutter code and native Android biometric APIs.
 * It implements necessary Flutter plugin interfaces and handles method calls from the Flutter side.
 */
package com.maojiu.biometric_authorization

import android.app.Activity
import android.content.Context
import androidx.fragment.app.FragmentActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * Main plugin class that implements Flutter plugin interfaces.
 *
 * This class handles the plugin lifecycle and method calls from Flutter,
 * and delegates the actual biometric operations to the BiometricAuthorizationManager.
 * It implements:
 * - FlutterPlugin: For plugin registration and lifecycle management
 * - MethodCallHandler: For handling method calls from Flutter
 * - ActivityAware: For accessing the current activity which is required for UI operations
 */
class BiometricAuthorizationPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
  /**
   * The MethodChannel that will be used to communicate with the Flutter side
   */
  private lateinit var channel: MethodChannel
  
  /**
   * Application context provided by the Flutter engine
   */
  private lateinit var context: Context
  
  /**
   * Current activity, needed for UI operations like showing biometric prompts
   */
  private var activity: FragmentActivity? = null

  /**
   * Called when the plugin is attached to the Flutter engine.
   * 
   * Sets up the MethodChannel and initializes the context.
   *
   * @param flutterPluginBinding Provides access to the Flutter engine's resources
   */
  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "biometric_authorization")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  /**
   * Called when the plugin is attached to an activity.
   * 
   * Stores the current activity for later use.
   *
   * @param binding Provides access to the current activity
   */
  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity as? FragmentActivity
  }

  /**
   * Called when the plugin is detached from the activity for configuration changes.
   * 
   * Clears the stored activity reference.
   */
  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  /**
   * Called when the plugin is reattached to the activity after configuration changes.
   * 
   * Updates the stored activity reference.
   *
   * @param binding Provides access to the current activity
   */
  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity as? FragmentActivity
  }

  /**
   * Called when the plugin is detached from the activity.
   * 
   * Clears the stored activity reference.
   */
  override fun onDetachedFromActivity() {
    activity = null
  }

  /**
   * Handles method calls from the Flutter side.
   * 
   * This method routes incoming calls to appropriate methods in the BiometricAuthorizationManager.
   * It first checks if the activity is available before proceeding with the method call.
   *
   * @param call The method call from Flutter containing the method name and arguments
   * @param result The result callback to send the result back to Flutter
   */
  override fun onMethodCall(call: MethodCall, result: Result) {
    val currentActivity = activity
    if (currentActivity == null) {
      result.error("ACTIVITY_NOT_AVAILABLE", "Activity is not available", null)
      return
    }

    // Create a manager instance to handle the biometric operations
    val biometricAuthorizationManager = BiometricAuthorizationManager(context, currentActivity)

    // Route the method call to the appropriate handler
    when (call.method) {
      "getPlatformVersion" -> {
        // Return the Android version
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }
      "isBiometricAvailable" -> {
        // Check if biometric authentication is available on the device
        result.success(biometricAuthorizationManager.isBiometricAvailable())
      }
      "isBiometricEnrolled" -> {
        // Check if biometric credentials are enrolled on the device
        result.success(biometricAuthorizationManager.isBiometricEnrolled())
      }
      "getAvailableBiometricTypes" -> {
        // Get the list of available biometric types on the device
        result.success(biometricAuthorizationManager.getAvailableBiometricTypes())
      }
      "authenticate" -> {
        // Initiate the biometric authentication process
        biometricAuthorizationManager.authenticate(call, result)
      }
      else -> {
        // Method not implemented
        result.notImplemented()
      }
    }
  }

  /**
   * Called when the plugin is detached from the Flutter engine.
   * 
   * Cleans up resources by removing the method call handler.
   *
   * @param binding The binding that was providing access to the Flutter engine's resources
   */
  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}