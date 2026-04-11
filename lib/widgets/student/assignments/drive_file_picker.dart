import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../common/utils/responsive.dart';

class DriveFileSelection {
  final String driveId;
  final String fileName;
  final String webViewLink;
  final String downloadUrl;

  const DriveFileSelection({
    required this.driveId,
    required this.fileName,
    required this.webViewLink,
    required this.downloadUrl,
  });
}

class DriveFilePicker extends StatefulWidget {
  final bool isDark;

  const DriveFilePicker({super.key, required this.isDark});

  static Future<DriveFileSelection?> show(
    BuildContext context, {
    required bool isDark,
  }) {
    return showModalBottomSheet<DriveFileSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: DriveFilePicker(isDark: isDark),
      ),
    );
  }

  @override
  State<DriveFilePicker> createState() => _DriveFilePickerState();
}

class _DriveFilePickerState extends State<DriveFilePicker> {
  late final WebViewController _controller;
  final TextEditingController _urlController = TextEditingController(
    text: 'https://drive.google.com/drive/my-drive',
  );
  final TextEditingController _fileNameController = TextEditingController();
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(_urlController.text));
  }

  @override
  void dispose() {
    _urlController.dispose();
    _fileNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Container(
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(responsive.radius24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.all(responsive.p16),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: responsive.p12),
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? Colors.grey.shade700
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                children: [
                  Text(
                    'Pick From Google Drive',
                    style: TextStyle(
                      fontSize: responsive.fontSize18,
                      fontWeight: FontWeight.bold,
                      color: widget.isDark
                          ? Colors.white
                          : const Color(0xFF1E293B),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              SizedBox(height: responsive.p12),
              TextField(
                controller: _urlController,
                style: TextStyle(
                  color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
                ),
                decoration: InputDecoration(
                  labelText: 'Drive File URL',
                  hintText: 'https://drive.google.com/file/d/.../view',
                  errorText: _validationError,
                  filled: true,
                  fillColor: widget.isDark
                      ? Colors.grey.shade800.withValues(alpha: 0.5)
                      : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(responsive.radius12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (_) {
                  if (_validationError != null) {
                    setState(() {
                      _validationError = null;
                    });
                  }
                },
              ),
              SizedBox(height: responsive.p8),
              TextField(
                controller: _fileNameController,
                style: TextStyle(
                  color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
                ),
                decoration: InputDecoration(
                  labelText: 'File Name (optional)',
                  filled: true,
                  fillColor: widget.isDark
                      ? Colors.grey.shade800.withValues(alpha: 0.5)
                      : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(responsive.radius12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: responsive.p8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _previewCurrentUrl,
                      icon: const Icon(Icons.preview_rounded),
                      label: const Text('Preview Link'),
                    ),
                  ),
                  SizedBox(width: responsive.p8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _selectCurrentUrl,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Use This File'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: responsive.p12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(responsive.radius12),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: widget.isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: WebViewWidget(controller: _controller),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _previewCurrentUrl() {
    final uri = Uri.tryParse(_urlController.text.trim());
    if (uri == null || !uri.hasScheme) {
      setState(() {
        _validationError = 'Please enter a valid Google Drive URL';
      });
      return;
    }

    _controller.loadRequest(uri);
  }

  void _selectCurrentUrl() {
    final source = _urlController.text.trim();
    final driveId = _extractDriveId(source);

    if (driveId == null) {
      setState(() {
        _validationError = 'Drive file id was not found in this URL';
      });
      return;
    }

    final resolvedFileName = _fileNameController.text.trim().isNotEmpty
        ? _fileNameController.text.trim()
        : 'drive_file_$driveId';

    Navigator.of(context).pop(
      DriveFileSelection(
        driveId: driveId,
        fileName: resolvedFileName,
        webViewLink: 'https://drive.google.com/file/d/$driveId/view',
        downloadUrl: 'https://drive.google.com/uc?id=$driveId&export=download',
      ),
    );
  }

  String? _extractDriveId(String value) {
    final idPattern = RegExp(r'/d/([a-zA-Z0-9_-]+)');
    final idMatch = idPattern.firstMatch(value);
    if (idMatch != null) {
      return idMatch.group(1);
    }

    final openPattern = RegExp(r'id=([a-zA-Z0-9_-]+)');
    final openMatch = openPattern.firstMatch(value);
    if (openMatch != null) {
      return openMatch.group(1);
    }

    return null;
  }
}
