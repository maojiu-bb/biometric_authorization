package com.maojiu.biometric_authorization

import android.content.DialogInterface
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.compose.material3.MaterialTheme // Using Material 3 Theme directly
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.platform.ViewCompositionStrategy
import androidx.fragment.app.DialogFragment

/**
 * A DialogFragment that hosts the [FingerprintDialog] Composable.
 * This fragment is responsible for displaying the fingerprint authentication dialog
 * and handling user interactions like cancellation or dismissal.
 */
class FingerprintDialogFragment : DialogFragment() {

    /** 
     * A lambda function to be executed when the dialog is cancelled or dismissed.
     * This is typically used to trigger the cancellation of the underlying fingerprint authentication process.
     */
    var onCancelAction: (() -> Unit)? = null

    companion object {
        private const val ARG_TITLE = "title"
        private const val ARG_CANCEL_TEXT = "cancel_text"

        /**
         * Factory method to create a new instance of [FingerprintDialogFragment].
         *
         * @param title The title string to be displayed in the dialog.
         * @param cancelText The text string for the cancel button.
         * @param onCancel A lambda function that will be invoked when the dialog is cancelled or dismissed.
         * @return A new instance of [FingerprintDialogFragment] with the provided arguments.
         */
        fun newInstance(title: String, cancelText: String, onCancel: () -> Unit): FingerprintDialogFragment {
            val fragment = FingerprintDialogFragment()
            fragment.arguments = Bundle().apply {
                putString(ARG_TITLE, title)
                putString(ARG_CANCEL_TEXT, cancelText)
            }
            // Store the lambda directly. While DialogFragments can be recreated by the system
            // (making direct lambda storage potentially fragile if the state needs to survive recreation),
            // for this specific use case where the dialog is shown and interacts immediately
            // with an ongoing process, this approach is often sufficient.
            // More robust alternatives for complex state include using the Fragment Result API or a shared ViewModel.
            fragment.onCancelAction = onCancel
            return fragment
        }
    }

    /**
     * Creates and returns the view hierarchy associated with the fragment.
     * Inflates the layout using [ComposeView] to host the Jetpack Compose UI.
     *
     * @param inflater The LayoutInflater object that can be used to inflate any views in the fragment.
     * @param container If non-null, this is the parent view that the fragment's UI should be attached to.
     * @param savedInstanceState If non-null, this fragment is being re-constructed from a previous saved state as given here.
     * @return Returns the View for the fragment's UI, or null.
     */
    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        // Retrieve arguments passed via newInstance
        val title = arguments?.getString(ARG_TITLE) ?: "Fingerprint Authentication"
        val cancelText = arguments?.getString(ARG_CANCEL_TEXT) ?: "Cancel"

        return ComposeView(requireContext()).apply {
            // Set the strategy for managing the Compose Composition lifecycle.
            // DisposeOnViewTreeLifecycleDestroyed ensures the Composition is disposed when the Fragment's view lifecycle is destroyed,
            // preventing potential memory leaks.
            setViewCompositionStrategy(ViewCompositionStrategy.DisposeOnViewTreeLifecycleDestroyed)
            setContent {
                // Apply Material 3 Theme. Ensure the application's theme is correctly set up for Material 3.
                MaterialTheme {
                    // Embed the FingerprintDialog Composable within the ComposeView
                    FingerprintDialog(
                        title = title,
                        cancelText = cancelText,
                        onDismissRequest = {
                            // This lambda is invoked when the dialog is dismissed by interactions outside its bounds
                            // (e.g., tapping the scrim or pressing the back button).
                            onCancelAction?.invoke() // Trigger cancel action on dismiss
                            dismiss() // Dismiss the DialogFragment itself
                        },
                        onCancel = {
                            // This lambda is invoked when the user clicks the explicit 'Cancel' button within the dialog.
                            onCancelAction?.invoke() // Trigger cancel action on cancel click
                            dismiss() // Dismiss the DialogFragment itself
                        }
                    )
                }
            }
        }
    }

    /**
     * Called when the fragment's activity has been created and this fragment's view hierarchy instantiated.
     * Can be used to do final initialization once these pieces are in place.
     */
    override fun onStart() {
        super.onStart()
        // Optional: Set the dialog window background to transparent.
        // This is useful if the FingerprintDialog Composable defines its own background/shape (e.g., rounded corners within a Surface).
        // If not set, the DialogFragment might have its own default background that could interfere with the Composable's visuals.
        dialog?.window?.setBackgroundDrawableResource(android.R.color.transparent)
    }

    /**
     * This method will be called when the dialog is cancelled, either by pressing the back button,
     * tapping outside the dialog (if cancellable is true), or explicitly calling cancel().
     *
     * @param dialog The dialog that was canceled will be passed into the method.
     */
    override fun onCancel(dialog: DialogInterface) {
        super.onCancel(dialog)
        // Ensure the cancel action is invoked when the dialog is cancelled through standard mechanisms.
        // This acts as a fallback for the onDismissRequest lambda.
        onCancelAction?.invoke()
    }
} 