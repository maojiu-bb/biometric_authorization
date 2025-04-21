/**
 * BiometricAuthBottomSheet.kt
 * This file implements a custom bottom sheet dialog for biometric authentication using Jetpack Compose.
 * It provides a user-friendly UI for biometric authentication with support for both light and dark themes.
 */
package com.maojiu.biometric_authorization

import android.app.Dialog
import android.os.Bundle
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.filled.Face
import androidx.compose.material3.Button
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.fragment.app.DialogFragment
import androidx.lifecycle.setViewTreeLifecycleOwner
import com.google.android.material.bottomsheet.BottomSheetDialog

/**
 * A bottom sheet dialog fragment that displays a biometric authentication UI.
 *
 * This class creates a custom bottom sheet dialog with Jetpack Compose UI that
 * shows a face icon animation and a confirmation button for biometric authentication.
 *
 * @param title The title text to display in the bottom sheet
 * @param confirmText The text for the confirmation button
 * @param onConfirmClick Callback function that is triggered when the user clicks the confirm button
 */
class BiometricAuthBottomSheet(
    private val title: String,
    private val confirmText: String,
    private val onConfirmClick: () -> Unit
) : DialogFragment() {
    /**
     * Creates and configures the bottom sheet dialog.
     *
     * This method initializes the dialog with a Compose UI that automatically adapts
     * to the system's theme (light or dark mode).
     *
     * @param savedInstanceState The saved instance state bundle
     * @return A configured BottomSheetDialog instance
     */
    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
        return BottomSheetDialog(requireContext()).apply {
            setContentView(ComposeView(requireContext()).apply {
                setViewTreeLifecycleOwner(this@BiometricAuthBottomSheet)

                // Set up the Compose content with theme support
                setContent {
                    // Detect if system is in dark mode
                    val isDarkTheme = isSystemInDarkTheme()
                    // Apply the appropriate Material theme based on system settings
                    MaterialTheme(
                        colorScheme = if (isDarkTheme) darkColorScheme() else lightColorScheme()
                    ) {
                        BiometricAuthContent(
                            title = title,
                            confirmText = confirmText,
                            onConfirmClick = {
                                onConfirmClick()
                                dismiss()
                            }
                        )
                    }
                }
            })
        }
    }
}

/**
 * Composable function that defines the content of the biometric authentication bottom sheet.
 *
 * This composable creates a UI with a title, an animated face icon, and a confirmation button.
 * The face icon pulses with a scale animation to draw user attention.
 *
 * @param title The title text to display
 * @param confirmText The text for the confirmation button
 * @param onConfirmClick Callback function that is triggered when the confirm button is clicked
 */
@Composable
fun BiometricAuthContent(
    title: String,
    confirmText: String,
    onConfirmClick: () -> Unit
) {
    // Create an infinite transition for the pulsing animation of the face icon
    val infiniteTransition = rememberInfiniteTransition(label = "infiniteTransition")
    val scale by infiniteTransition.animateFloat(
        initialValue = 1.0f,
        targetValue = 1.1f,
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 1200, easing = LinearEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "iconScale"
    )

    // Main container box with background color that adapts to the theme
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .background(MaterialTheme.colorScheme.background)
    ) {
        // Content column with centered alignment
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 24.dp, vertical = 12.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Drag handle at the top of the bottom sheet
            Box(
                modifier = Modifier
                    .width(50.dp)
                    .height(5.dp)
                    .clip(
                        RoundedCornerShape(
                            topStart = 8.dp,
                            topEnd = 8.dp,
                            bottomStart = 8.dp,
                            bottomEnd = 8.dp
                        )
                    )
                    .background(
                        MaterialTheme.colorScheme.onBackground.copy(alpha = 0.2f)
                    )
            )

            Spacer(modifier = Modifier.height(10.dp))

            // Title text with theme-appropriate color
            Text(
                text = title,
                style = MaterialTheme.typography.headlineSmall.copy(
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.onBackground
                ),
                textAlign = TextAlign.Center
            )

            Spacer(modifier = Modifier.height(16.dp))

            // Face icon with pulsing animation
            Box(
                contentAlignment = Alignment.Center
            ) {
                // Face icon that scales up and down
                Icon(
                    imageVector = Icons.Default.Face,
                    contentDescription = "Biometric Icon",
                    modifier = Modifier
                        .size(62.dp)
                        .graphicsLayer(
                            scaleX = scale,
                            scaleY = scale
                        ),
                    tint = MaterialTheme.colorScheme.primary
                )

                // Circular background for the face icon
                Box(
                    modifier = Modifier
                        .size(100.dp)
                        .background(
                            color = MaterialTheme.colorScheme.primary.copy(alpha = 0.1f),
                            shape = CircleShape
                        )
                )
            }

            Spacer(modifier = Modifier.height(24.dp))

            // Confirm button that spans the full width
            Button(
                onClick = onConfirmClick,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(50.dp)
            ) {
                // Button content with text and arrow icon
                Row(
                    horizontalArrangement = Arrangement.Center,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    // Button text with appropriate contrast color
                    Text(confirmText, style = MaterialTheme.typography.bodyLarge.copy(
                        color = MaterialTheme.colorScheme.onPrimary
                    ))
                    // Arrow icon that indicates action
                    Icon(
                        imageVector = Icons.AutoMirrored.Filled.ArrowForward,
                        contentDescription = "Confirm Icon",
                        tint = MaterialTheme.colorScheme.onPrimary,
                        modifier = Modifier
                            .padding(start = 8.dp)
                            .size(22.dp)
                    )
                }
            }

            Spacer(modifier = Modifier.height(12.dp))
        }
    }
}