import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../common/utils/responsive.dart';
import '../../../models/core/drive_file_model.dart';

Future<void> openDriveFilePreviewScreen(
  BuildContext context, {
  required DriveFileModel file,
  required bool isDark,
}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => DriveFilePreviewScreen(file: file, isDark: isDark),
    ),
  );
}

class DriveFilePreviewScreen extends StatefulWidget {
  final DriveFileModel file;
  final bool isDark;

  const DriveFilePreviewScreen({
    super.key,
    required this.file,
    required this.isDark,
  });

  @override
  State<DriveFilePreviewScreen> createState() => _DriveFilePreviewScreenState();
}

class _DriveFilePreviewScreenState extends State<DriveFilePreviewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (!mounted) {
              return;
            }

            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (_) {
            if (!mounted) {
              return;
            }

            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.file.iframeUrl));
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      backgroundColor: widget.isDark ? const Color(0xFF0F172A) : Colors.white,
      appBar: AppBar(
        backgroundColor: widget.isDark ? const Color(0xFF0F172A) : Colors.white,
        foregroundColor: widget.isDark ? Colors.white : const Color(0xFF1E293B),
        elevation: 0,
        title: Text(
          widget.file.fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: responsive.fontSize16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _openExternal(widget.file.webViewLink),
            icon: const Icon(Icons.open_in_new_rounded),
            tooltip: 'Open in Drive',
          ),
          IconButton(
            onPressed: widget.file.downloadUrl.isEmpty
                ? null
                : () => _openExternal(widget.file.downloadUrl),
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Download',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                responsive.p16,
                responsive.p8,
                responsive.p16,
                responsive.p12,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Use the in-app preview to scroll the file, or open it in Drive for the original viewer.',
                  style: TextStyle(
                    fontSize: responsive.fontSize12,
                    color: widget.isDark
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _hasError
                        ? _buildErrorState(context)
                        : WebViewWidget(controller: _controller),
                  ),
                  if (_isLoading && !_hasError)
                    const Positioned.fill(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final responsive = context.responsive;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(responsive.p20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: const Color(0xFFEF4444),
              size: responsive.fontSize40,
            ),
            SizedBox(height: responsive.p10),
            Text(
              'Preview unavailable',
              style: TextStyle(
                fontSize: responsive.fontSize16,
                fontWeight: FontWeight.w700,
                color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: responsive.p8),
            TextButton.icon(
              onPressed: () => _openExternal(widget.file.webViewLink),
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('Open in Drive'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openExternal(String value) async {
    final uri = Uri.tryParse(value);
    if (uri == null) {
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
