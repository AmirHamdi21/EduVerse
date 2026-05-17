import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../models/instructor/instructor_course_model.dart';
import '../../../utils/navigation/safe_back.dart';
import '../../../widgets/instructor/course_management/course_management_colors.dart';

class MaterialPreviewScreen extends StatelessWidget {
  const MaterialPreviewScreen({super.key, required this.material});

  final MaterialModel material;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final type = material.type.toLowerCase().trim();
    final sourceUrl = material.fileUrl.trim();
    final previewUrl = _buildPreviewUrl(sourceUrl);
    final downloadUrl = _buildDownloadUrl(sourceUrl);

    debugPrint(
      '[MaterialPreview] type="${material.type}" '
      'fileUrl="${material.fileUrl}" '
      'previewUrl="$previewUrl" '
      'downloadUrl="$downloadUrl"',
    );

    return Scaffold(
      backgroundColor: CMColors.bg(isDark),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => safeBack(context, '/instructor/dashboard'),
          icon: Icon(iosBackIcon(context)),
        ),
        title: Text(
          material.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: CMColors.cardColor(isDark),
        surfaceTintColor: CMColors.cardColor(isDark),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: _HeaderCard(
              title: material.title,
              fileType: type,
              fileSize: material.fileSize,
              isDark: isDark,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _PreviewBody(
                fileType: type,
                previewUrl: previewUrl,
                downloadUrl: downloadUrl,
                isDark: isDark,
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
                  onPressed: sourceUrl.isEmpty
                      ? null
                      : () => _openExternal(sourceUrl),
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Open in Browser'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CMColors.primary,
                    side: const BorderSide(color: CMColors.primary),
                    minimumSize: const Size.fromHeight(46),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: downloadUrl.isEmpty
                      ? null
                      : () => _openExternal(downloadUrl),
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Download'),
                  style: FilledButton.styleFrom(
                    backgroundColor: CMColors.primary,
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

  static String _buildDownloadUrl(String sourceUrl) {
    if (sourceUrl.isEmpty) {
      return '';
    }

    final parsed = Uri.tryParse(sourceUrl);
    if (parsed == null) {
      return sourceUrl;
    }

    final path = parsed.path;
    if (parsed.host.contains('drive.google.com') && path.contains('/file/d/')) {
      final id = _extractDriveId(path);
      if (id != null && id.isNotEmpty) {
        return 'https://drive.google.com/uc?id=$id&export=download';
      }
    }

    return sourceUrl;
  }

  static String _buildPreviewUrl(String sourceUrl) {
    if (sourceUrl.isEmpty) {
      return '';
    }

    final parsed = Uri.tryParse(sourceUrl);
    if (parsed == null) {
      return sourceUrl;
    }

    final path = parsed.path;
    if (parsed.host.contains('drive.google.com') && path.contains('/file/d/')) {
      final id = _extractDriveId(path);
      if (id != null && id.isNotEmpty) {
        return 'https://drive.google.com/file/d/$id/preview';
      }
    }

    return sourceUrl;
  }

  static String? _extractDriveId(String path) {
    final marker = '/file/d/';
    final start = path.indexOf(marker);
    if (start < 0) {
      return null;
    }

    final tail = path.substring(start + marker.length);
    final end = tail.indexOf('/');
    if (end < 0) {
      return tail;
    }

    return tail.substring(0, end);
  }

  static Future<void> _openExternal(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.title,
    required this.fileType,
    required this.fileSize,
    required this.isDark,
  });

  final String title;
  final String fileType;
  final String fileSize;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final badgeColor = _typeColor(fileType);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CMColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CMColors.borderColor(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_typeIcon(fileType), color: badgeColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: CMColors.text(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        fileType.toUpperCase(),
                        style: TextStyle(
                          color: badgeColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    if (fileSize.trim().isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        fileSize,
                        style: TextStyle(
                          color: CMColors.textMutedColor(isDark),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static IconData _typeIcon(String type) {
    switch (type) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'ppt':
      case 'pptx':
      case 'slide':
        return Icons.slideshow_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return Icons.image_rounded;
      case 'video':
        return Icons.play_circle_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  static Color _typeColor(String type) {
    switch (type) {
      case 'pdf':
        return CMColors.error;
      case 'ppt':
      case 'pptx':
      case 'slide':
        return CMColors.orange;
      case 'doc':
      case 'docx':
        return CMColors.accent;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return CMColors.teal;
      case 'video':
        return CMColors.primary;
      default:
        return CMColors.success;
    }
  }
}

class _PreviewBody extends StatelessWidget {
  const _PreviewBody({
    required this.fileType,
    required this.previewUrl,
    required this.downloadUrl,
    required this.isDark,
  });

  final String fileType;
  final String previewUrl;
  final String downloadUrl;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final imageTypes = <String>{'jpg', 'jpeg', 'png', 'gif', 'webp', 'image'};
    final documentTypes = <String>{
      'pdf',
      'ppt',
      'pptx',
      'doc',
      'docx',
      'lecture',
      'reading',
      'slide',
      'document',
    };

    if (previewUrl.isEmpty) {
      return _PreviewFallback(downloadUrl: downloadUrl, isDark: isDark);
    }

    if (imageTypes.contains(fileType)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          color: CMColors.cardColor(isDark),
          child: Image.network(
            previewUrl,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                _PreviewFallback(downloadUrl: downloadUrl, isDark: isDark),
          ),
        ),
      );
    }

    if (documentTypes.contains(fileType)) {
      return _DocumentPreview(
        previewUrl: previewUrl,
        downloadUrl: downloadUrl,
        isDark: isDark,
      );
    }

    return _DocumentPreview(
      previewUrl: previewUrl,
      downloadUrl: downloadUrl,
      isDark: isDark,
    );
  }
}

class _DocumentPreview extends StatefulWidget {
  const _DocumentPreview({
    required this.previewUrl,
    required this.downloadUrl,
    required this.isDark,
  });

  final String previewUrl;
  final String downloadUrl;
  final bool isDark;

  @override
  State<_DocumentPreview> createState() => _DocumentPreviewState();
}

class _DocumentPreviewState extends State<_DocumentPreview> {
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _PreviewFallback(
        downloadUrl: widget.downloadUrl,
        isDark: widget.isDark,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: CMColors.cardColor(widget.isDark),
          border: Border.all(color: CMColors.borderColor(widget.isDark)),
        ),
        child: WebViewWidget(
          controller: WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setNavigationDelegate(
              NavigationDelegate(
                onWebResourceError: (_) {
                  if (mounted) {
                    setState(() => _hasError = true);
                  }
                },
              ),
            )
            ..loadRequest(Uri.parse(widget.previewUrl)),
        ),
      ),
    );
  }
}

class _PreviewFallback extends StatelessWidget {
  const _PreviewFallback({required this.downloadUrl, required this.isDark});

  final String downloadUrl;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CMColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CMColors.borderColor(isDark)),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.download_for_offline_outlined,
                size: 36,
                color: CMColors.textSub(isDark),
              ),
              const SizedBox(height: 10),
              Text(
                'Preview is not available for this file type.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CMColors.text(isDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Use Download to open the file externally.',
                textAlign: TextAlign.center,
                style: TextStyle(color: CMColors.textSub(isDark)),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: downloadUrl.isEmpty
                    ? null
                    : () => MaterialPreviewScreen._openExternal(downloadUrl),
                icon: const Icon(Icons.download_rounded),
                label: const Text('Download File'),
                style: FilledButton.styleFrom(
                  backgroundColor: CMColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
