import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../features/courses/bloc/material_viewer/material_viewer_bloc.dart';
import '../../../features/courses/bloc/material_viewer/material_viewer_event.dart';
import '../../../features/courses/bloc/material_viewer/material_viewer_state.dart';
import '../../../models/materials/course_material_model.dart';

class DocumentPreviewWidget extends StatefulWidget {
  final dynamic courseId;
  final CourseMaterialModel material;
  final bool enableWebView;

  const DocumentPreviewWidget({
    super.key,
    required this.courseId,
    required this.material,
    this.enableWebView = true,
  });

  @override
  State<DocumentPreviewWidget> createState() => _DocumentPreviewWidgetState();
}

class _DocumentPreviewWidgetState extends State<DocumentPreviewWidget> {
  WebViewController? _webController;
  bool _isLoadingPreview = false;
  bool _accessDenied = false;

  String? get _previewUrl {
    final direct = widget.material.drivePreviewUrl;
    if (direct != null && direct.trim().isNotEmpty) {
      return direct;
    }

    final driveId = widget.material.file?.driveId;
    if (driveId == null || driveId.trim().isEmpty) {
      return null;
    }

    return 'https://drive.google.com/file/d/$driveId/preview';
  }

  @override
  void initState() {
    super.initState();
    _configureWebView();
  }

  @override
  void didUpdateWidget(covariant DocumentPreviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.material.materialId != widget.material.materialId ||
        oldWidget.enableWebView != widget.enableWebView) {
      _accessDenied = false;
      _configureWebView();
    }
  }

  void _configureWebView() {
    final previewUrl = _previewUrl;
    if (!widget.enableWebView || previewUrl == null || previewUrl.isEmpty) {
      _webController = null;
      return;
    }

    final uri = Uri.tryParse(previewUrl);
    if (uri == null) {
      _webController = null;
      return;
    }

    _isLoadingPreview = true;
    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() => _isLoadingPreview = true);
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() => _isLoadingPreview = false);
          },
          onWebResourceError: (error) {
            final lower = error.description.toLowerCase();
            if (lower.contains('403') ||
                lower.contains('denied') ||
                lower.contains('forbidden')) {
              if (!mounted) return;
              setState(() {
                _accessDenied = true;
                _isLoadingPreview = false;
              });
            }
          },
        ),
      )
      ..loadRequest(uri);
  }

  Future<void> _startDownload() async {
    final validationError = _validateDownload(widget.material);
    if (validationError != null) {
      _showSnack(validationError);
      return;
    }

    final granted = await _ensureStoragePermission();
    if (!granted) {
      _showSnack('Storage permission is required to download files.');
      return;
    }

    if (!mounted) return;
    context.read<MaterialViewerBloc>().add(
      DownloadMaterial(courseId: widget.courseId, material: widget.material),
    );
  }

  Future<bool> _ensureStoragePermission() async {
    if (kIsWeb) return false;

    if (defaultTargetPlatform != TargetPlatform.android) {
      return true;
    }

    final storageStatus = await Permission.storage.request();
    if (storageStatus.isGranted) {
      return true;
    }

    final manageStatus = await Permission.manageExternalStorage.request();
    return manageStatus.isGranted;
  }

  String? _validateDownload(CourseMaterialModel material) {
    final file = material.file;
    if (file == null) {
      return 'This document does not have a downloadable file.';
    }

    final fileName = file.fileName.toLowerCase();
    final mimeType = (file.mimeType ?? '').toLowerCase();
    final ext = fileName.contains('.') ? fileName.split('.').last : '';

    const docExtensions = <String>{
      'pdf',
      'doc',
      'docx',
      'ppt',
      'pptx',
      'xls',
      'xlsx',
      'txt',
      'md',
      'zip',
    };
    const imageExtensions = <String>{
      'jpg',
      'jpeg',
      'png',
      'gif',
      'webp',
      'svg',
    };

    final isDocument =
        docExtensions.contains(ext) ||
        mimeType.startsWith('application/') ||
        mimeType.startsWith('text/');
    final isImage =
        imageExtensions.contains(ext) || mimeType.startsWith('image/');

    if (!isDocument && !isImage) {
      return 'Unsupported file type for download.';
    }

    final size = file.fileSize;
    if (size == null) return null;

    const fiftyMb = 50 * 1024 * 1024;
    const tenMb = 10 * 1024 * 1024;

    if (isDocument && size > fiftyMb) {
      return 'Document is larger than 50MB and cannot be downloaded.';
    }

    if (isImage && size > tenMb) {
      return 'Image is larger than 10MB and cannot be downloaded.';
    }

    return null;
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final previewUrl = _previewUrl;

    return BlocListener<MaterialViewerBloc, MaterialViewerState>(
      listenWhen: (previous, current) {
        return previous.downloadedFilePath != current.downloadedFilePath ||
            previous.error != current.error;
      },
      listener: (context, state) {
        if (state.downloadedFilePath != null &&
            state.downloadedFilePath!.isNotEmpty) {
          _showSnack('Downloaded successfully');
        } else if (state.error != null && state.error!.isNotEmpty) {
          _showSnack(state.error!);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.material.title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 240),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1F2937)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: _buildPreviewBody(previewUrl),
            ),
          ),
          const SizedBox(height: 12),
          BlocBuilder<MaterialViewerBloc, MaterialViewerState>(
            builder: (context, state) {
              final canDownload = _validateDownload(widget.material) == null;
              final progressValue =
                  state.downloadProgress <= 0 || state.downloadProgress > 1
                  ? null
                  : state.downloadProgress;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: (!canDownload || state.isDownloading)
                          ? null
                          : _startDownload,
                      icon: const Icon(Icons.download_rounded),
                      label: const Text('Download for offline'),
                    ),
                  ),
                  if (!canDownload)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _validateDownload(widget.material)!,
                        style: const TextStyle(
                          color: Color(0xFFB42318),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (state.isDownloading) ...[
                    const SizedBox(height: 10),
                    LinearProgressIndicator(value: progressValue),
                    const SizedBox(height: 6),
                    Text(
                      progressValue == null
                          ? 'Downloading...'
                          : 'Downloading... ${(progressValue * 100).toStringAsFixed(0)}%',
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewBody(String? previewUrl) {
    if (_accessDenied) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Access denied — contact instructor to grant access',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFB42318),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    if (previewUrl == null || previewUrl.isEmpty) {
      return const Center(
        child: Text('No Google Drive preview is available for this file.'),
      );
    }

    if (!widget.enableWebView) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(previewUrl, textAlign: TextAlign.center),
        ),
      );
    }

    if (_webController == null) {
      return const Center(
        child: Text('Preview could not be initialized for this document.'),
      );
    }

    return Stack(
      children: [
        Positioned.fill(child: WebViewWidget(controller: _webController!)),
        if (_isLoadingPreview)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0x40FFFFFF),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}
