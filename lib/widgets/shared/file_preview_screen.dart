import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// File preview screen using WebView for Google Drive files.
/// Supports previewing PDFs, documents, images, and other file types.
class FilePreviewScreen extends StatefulWidget {
  final String fileName;
  final String previewUrl;
  final String downloadUrl;

  const FilePreviewScreen({
    super.key,
    required this.fileName,
    required this.previewUrl,
    required this.downloadUrl,
  });

  @override
  State<FilePreviewScreen> createState() => _FilePreviewScreenState();
}

class _FilePreviewScreenState extends State<FilePreviewScreen> {
  late WebViewController _webViewController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
              _errorMessage = null;
            });
          },
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (error) {
            setState(() {
              _isLoading = false;
              _errorMessage = error.description;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.previewUrl));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      appBar: AppBar(
        title: Text(
          widget.fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: isDark ? Colors.grey[850] : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          if (_isLoading)
            Container(
              color: isDark ? Colors.grey[900] : Colors.white,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading preview...',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_errorMessage != null)
            Container(
              color: isDark ? Colors.grey[900] : Colors.white,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 64,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load preview',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage ?? 'Unknown error',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.previewUrl.isEmpty
                      ? null
                      : () => _openInBrowser(widget.previewUrl),
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Open in Browser'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                    side: BorderSide(color: Theme.of(context).primaryColor),
                    minimumSize: const Size.fromHeight(46),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: widget.downloadUrl.isEmpty
                      ? null
                      : () => _downloadFile(widget.downloadUrl),
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Download'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(46),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openInBrowser(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open URL'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _downloadFile(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not download file'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
