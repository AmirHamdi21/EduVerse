import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// T016/T017: Utility for launching URLs with resilient error handling.
///
/// Wraps `url_launcher` with try/catch and shows a user-friendly Snackbar
/// on failure, per spec FR-003 and Constitution Principle IV.
class UrlLauncherHelper {
  /// Attempts to launch the given [url] string.
  ///
  /// On failure, shows a [SnackBar] via the nearest [ScaffoldMessenger]
  /// with the error description.
  static Future<void> openUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      _showError(context, 'Invalid URL: $url');
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        if (context.mounted) {
          _showError(context, 'Could not open: $url');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Failed to open link. Please try again.');
      }
    }
  }

  /// Shows a styled error Snackbar.
  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 13)),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red.shade700,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
