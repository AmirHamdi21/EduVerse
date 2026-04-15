import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../models/materials/course_material_model.dart';
import '../../../widgets/ta/shared/ta_colors.dart';

/// Material preview screen for CourseMaterialModel.
/// Handles videos, PDFs, documents, and links with proper preview URLs.
class CourseMaterialPreviewScreen extends StatefulWidget {
  final CourseMaterialModel material;

  const CourseMaterialPreviewScreen({super.key, required this.material});

  @override
  State<CourseMaterialPreviewScreen> createState() => _CourseMaterialPreviewScreenState();
}

class _CourseMaterialPreviewScreenState extends State<CourseMaterialPreviewScreen> {
  late WebViewController _webViewController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    final previewUrl = _getPreviewUrl();
    
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
      );

    if (previewUrl.isNotEmpty) {
      _webViewController.loadRequest(Uri.parse(previewUrl));
    }
  }

  String _getPreviewUrl() {
    // For videos - check if it's a YouTube video
    if (widget.material.materialType.toLowerCase() == 'video') {
      final videoId = widget.material.youtubeVideoId;
      if (videoId != null && videoId.isNotEmpty) {
        return 'https://www.youtube.com/embed/$videoId';
      }
    }

    // For Drive files - use iframe URL
    final driveUrl = widget.material.drivePreviewUrl;
    if (driveUrl != null && driveUrl.isNotEmpty) {
      return driveUrl;
    }

    // Fallback to external URL
    return widget.material.externalUrl ?? widget.material.url ?? '';
  }

  String? _getDownloadUrl() {
    final file = widget.material.file;
    if (file != null) {
      return file.downloadUrl;
    }
    return widget.material.externalUrl ?? widget.material.url;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final previewUrl = _getPreviewUrl();
    final hasPreviewUrl = previewUrl.isNotEmpty;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      appBar: AppBar(
        title: Text(
          widget.material.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: isDark ? Colors.grey[850] : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: Column(
        children: [
          // Material info card
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TAColors.cardColor(isDark),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: TAColors.borderColor(isDark),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _getMaterialColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getMaterialIcon(),
                      color: _getMaterialColor(),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.material.title,
                          style: TextStyle(
                            color: TAColors.textPrimaryColor(isDark),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.material.description != null && 
                            widget.material.description!.isNotEmpty)
                          Text(
                            widget.material.description!,
                            style: TextStyle(
                              color: TAColors.textSecondaryColor(isDark),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Preview area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: hasPreviewUrl
                  ? Stack(
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
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getMaterialIcon(),
                            size: 80,
                            color: TAColors.textTertiaryColor(isDark),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No preview available',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: TAColors.textSecondaryColor(isDark),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Download the file to view it',
                            style: TextStyle(
                              fontSize: 14,
                              color: TAColors.textTertiaryColor(isDark),
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
                  onPressed: hasPreviewUrl
                      ? () => _openInBrowser(previewUrl)
                      : null,
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Open in Browser'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: TAColors.primary,
                    side: BorderSide(color: TAColors.primary),
                    minimumSize: const Size.fromHeight(46),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _downloadFile(),
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Download'),
                  style: FilledButton.styleFrom(
                    backgroundColor: TAColors.primary,
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

  IconData _getMaterialIcon() {
    switch (widget.material.materialType.toLowerCase()) {
      case 'video':
        return Icons.play_circle_outline;
      case 'lecture':
        return Icons.school_outlined;
      case 'slide':
        return Icons.slideshow_outlined;
      case 'document':
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'reading':
        return Icons.menu_book_outlined;
      case 'link':
        return Icons.link_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  Color _getMaterialColor() {
    switch (widget.material.materialType.toLowerCase()) {
      case 'video':
        return Colors.red;
      case 'lecture':
        return Colors.blue;
      case 'slide':
        return Colors.orange;
      case 'document':
      case 'pdf':
        return Colors.red;
      case 'reading':
        return Colors.green;
      case 'link':
        return Colors.purple;
      default:
        return TAColors.info;
    }
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

  Future<void> _downloadFile() async {
    final url = _getDownloadUrl();
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No download URL available'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

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
