package com.maojiu.biometric_authorization

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Fingerprint
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Dialog

/**
 * A Composable function that displays a custom dialog for fingerprint authentication.
 * This dialog shows a fingerprint icon, a title, and a cancel button.
 * It adapts its color scheme based on the system's dark theme setting.
 *
 * @param title The main text displayed in the dialog, usually indicating the purpose (e.g., "Fingerprint Authentication").
 * @param cancelText The text displayed on the cancel button.
 * @param onDismissRequest A lambda function invoked when the user attempts to dismiss the dialog
 *                         by interacting outside the dialog bounds or pressing the back button.
 *                         This is mandatory for the [Dialog] composable.
 * @param onCancel A lambda function invoked when the user explicitly clicks the cancel button within the dialog.
 */
@Composable
fun FingerprintDialog(
    title: String,
    cancelText: String,
    onDismissRequest: () -> Unit = {},
    onCancel: () -> Unit = {}
) {
    // Apply Material 3 theme, automatically selecting light or dark color scheme
    // based on the system settings.
    MaterialTheme(
        colorScheme = if (isSystemInDarkTheme()) darkColorScheme() else lightColorScheme()
    ) {
        // The Dialog composable provides the basic dialog window structure.
        Dialog(onDismissRequest = onDismissRequest) {
            // Surface provides a background, shape, and elevation for the dialog content.
            Surface(
                shape = MaterialTheme.shapes.medium, // Use medium rounded corners defined in the theme.
                color = MaterialTheme.colorScheme.surface, // Use the theme's surface color for the background.
                modifier = Modifier.padding(16.dp) // Apply padding around the Surface within the Dialog window.
            ) {
                // Column arranges its children vertically.
                Column(
                    modifier = Modifier
                        .padding(horizontal = 16.dp) // Inner padding for the content inside the Surface.
                        .fillMaxWidth(), // Make the column take the full width available within the padding.
                    horizontalAlignment = Alignment.CenterHorizontally, // Center children horizontally.
                    verticalArrangement = Arrangement.Center // Center children vertically within the column (less relevant here due to specific Spacers).
                ) {
                    // Vertical space before the icon.
                    Spacer(modifier = Modifier.height(24.dp))
                    // Display the fingerprint icon.
                    Icon(
                        imageVector = Icons.Filled.Fingerprint, // Use the standard fingerprint icon.
                        contentDescription = "Fingerprint Icon", // Accessibility description.
                        tint = MaterialTheme.colorScheme.primary, // Tint the icon with the theme's primary color.
                        modifier = Modifier.size(64.dp) // Set the size of the icon.
                    )
                    // Vertical space between the icon and the title.
                    Spacer(modifier = Modifier.height(24.dp))
                    // Display the dialog title.
                    Text(
                        text = title,
                        style = MaterialTheme.typography.titleMedium // Use the medium title text style from the theme.
                    )
                    // Vertical space between the title and the divider.
                    Spacer(modifier = Modifier.height(10.dp))
                    // A thin horizontal line separator.
                    HorizontalDivider()
                    // The cancel button.
                    TextButton(
                        onClick = onCancel, // Invoke the onCancel lambda when clicked.
                        modifier = Modifier
                            .fillMaxWidth() // Make the button span the full width.
                            .padding(top = 8.dp) // Add padding above the button.
                    ) {
                        // The text displayed within the cancel button.
                        Text(
                            text = cancelText,
                            color = MaterialTheme.colorScheme.primary // Use the primary color for the button text for emphasis.
                        )
                    }
                    // Vertical space after the cancel button.
                    Spacer(modifier = Modifier.height(8.dp))
                }
            }
        }
    }
}