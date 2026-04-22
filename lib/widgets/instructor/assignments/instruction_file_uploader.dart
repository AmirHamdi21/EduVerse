import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../models/core/drive_file_model.dart';
import '../../../services/api/assignment_service.dart';

class InstructionFileUploader extends StatefulWidget {
  const InstructionFileUploader({
    super.key,
    required this.assignmentId,
    required this.assignmentService,
    this.initialFiles = const <DriveFileModel>[],
    this.onFilesChanged,
  });

  final int assignmentId;
  final AssignmentService assignmentService;
  final List<DriveFileModel> initialFiles;
  final ValueChanged<List<DriveFileModel>>? onFilesChanged;

  @override
  State<InstructionFileUploader> createState() =>
      InstructionFileUploaderState();
}

class PendingInstructionUploadResult {
  const PendingInstructionUploadResult({
    this.successCount = 0,
    this.failureCount = 0,
    this.failedFileNames = const <String>[],
  });

  final int successCount;
  final int failureCount;
  final List<String> failedFileNames;

  int get attemptedCount => successCount + failureCount;
}

class InstructionFileUploaderState extends State<InstructionFileUploader> {
  final List<_UploadItem> _items = <_UploadItem>[];

  @override
  void initState() {
    super.initState();
    for (final file in widget.initialFiles) {
      _items.add(
        _UploadItem(
          uploadedFile: file,
          fileDatabaseId: file.fileId > 0
              ? file.fileId
              : (file.driveFileId > 0 ? file.driveFileId : null),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        OutlinedButton.icon(
          onPressed: _pickAndUpload,
          icon: const Icon(Icons.upload_file_rounded),
          label: const Text('Upload Instruction File'),
        ),
        if (widget.assignmentId <= 0)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'You can select files now. They will upload automatically when you save.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        if (_items.isNotEmpty) const SizedBox(height: 10),
        for (var index = 0; index < _items.length; index++)
          _UploadItemTile(
            item: _items[index],
            onRetry:
                _items[index].localPath == null ||
                    _items[index].errorMessage == null
                ? null
                : () => _retryUpload(index),
            onPreview: _items[index].uploadedFile == null
                ? null
                : () => _openPreview(_items[index].uploadedFile!),
            onDownload: _items[index].uploadedFile == null
                ? null
                : () => _openUrl(_items[index].uploadedFile!.downloadUrl),
            onOpen: _items[index].uploadedFile == null
                ? null
                : () => _openUrl(_items[index].uploadedFile!.webViewLink),
            onDelete: _items[index].uploadedFile == null
                ? null
                : () => _deleteFile(index),
          ),
      ],
    );
  }

  Future<void> _deleteFile(int index) async {
    if (index < 0 || index >= _items.length) {
      return;
    }

    final uploadedFile = _items[index].uploadedFile;
    if (uploadedFile == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Instruction File?'),
        content: Text(
          'Are you sure you want to delete "${uploadedFile.fileName}"? This action cannot be undone.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _items[index] = _items[index].copyWith(
        isUploading: true,
        progress: 0,
        errorMessage: null,
      );
    });

    final driveId = uploadedFile.driveId.trim();
    if (driveId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Cannot delete: file drive ID is unknown. Try refreshing the assignment.',
            ),
          ),
        );
      }
      setState(() {
        _items[index] = _items[index].copyWith(isUploading: false);
      });
      return;
    }

    final result = await widget.assignmentService.deleteInstructionFile(
      widget.assignmentId,
      driveId,
    );

    if (!mounted || index >= _items.length) {
      return;
    }

    if (result.isSuccess) {
      setState(() {
        _items.removeAt(index);
      });
      _emitFilesChanged();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Instruction file deleted successfully.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    final message = result.error?.message ?? 'Failed to delete file';
    setState(() {
      _items[index] = _items[index].copyWith(
        isUploading: false,
        errorMessage: message,
      );
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<PendingInstructionUploadResult> uploadPendingFiles(
    int assignmentId,
  ) async {
    final pendingIndexes = <int>[];
    for (var index = 0; index < _items.length; index++) {
      final item = _items[index];
      final localPath = item.localPath;
      if (item.uploadedFile == null &&
          localPath != null &&
          localPath.trim().isNotEmpty) {
        pendingIndexes.add(index);
      }
    }

    if (pendingIndexes.isEmpty) {
      return const PendingInstructionUploadResult();
    }

    if (assignmentId <= 0) {
      final failedNames = <String>[];
      if (mounted) {
        setState(() {
          for (final index in pendingIndexes) {
            final name = _items[index].displayName ?? 'File';
            failedNames.add(name);
            _items[index] = _items[index].copyWith(
              isUploading: false,
              errorMessage: 'Save assignment first to upload this file.',
              pendingUpload: true,
            );
          }
        });
      }
      return PendingInstructionUploadResult(
        successCount: 0,
        failureCount: pendingIndexes.length,
        failedFileNames: failedNames,
      );
    }

    var successCount = 0;
    final failedNames = <String>[];

    for (final index in pendingIndexes) {
      if (!mounted || index >= _items.length) {
        continue;
      }

      final localPath = _items[index].localPath;
      final displayName = _items[index].displayName ?? 'File';
      if (localPath == null || localPath.isEmpty) {
        failedNames.add(displayName);
        continue;
      }

      final file = File(localPath);
      if (!await file.exists()) {
        if (mounted) {
          setState(() {
            _items[index] = _items[index].copyWith(
              isUploading: false,
              errorMessage: 'File no longer exists on disk.',
              pendingUpload: true,
            );
          });
        }
        failedNames.add(displayName);
        continue;
      }

      if (mounted) {
        setState(() {
          _items[index] = _items[index].copyWith(
            isUploading: true,
            errorMessage: null,
            progress: 0,
            pendingUpload: false,
          );
        });
      }

      final uploaded = await _uploadAtIndex(
        index,
        file,
        assignmentIdOverride: assignmentId,
      );
      if (uploaded) {
        successCount++;
      } else {
        failedNames.add(displayName);
      }
    }

    return PendingInstructionUploadResult(
      successCount: successCount,
      failureCount: failedNames.length,
      failedFileNames: failedNames,
    );
  }

  Future<void> _pickAndUpload() async {
    final picked = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (picked == null || picked.files.isEmpty) {
      return;
    }

    var addedPendingCount = 0;

    for (final platformFile in picked.files) {
      final path = platformFile.path;
      if (path == null || path.isEmpty) {
        continue;
      }

      if (widget.assignmentId <= 0) {
        setState(() {
          _items.add(
            _UploadItem(
              localPath: path,
              displayName: platformFile.name,
              isUploading: false,
              progress: 0,
              pendingUpload: true,
            ),
          );
        });
        addedPendingCount++;
        continue;
      }

      final newIndex = _items.length;
      setState(() {
        _items.add(
          _UploadItem(
            localPath: path,
            displayName: platformFile.name,
            isUploading: true,
            progress: 0,
            pendingUpload: false,
          ),
        );
      });

      await _uploadAtIndex(newIndex, File(path));
    }

    if (addedPendingCount > 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$addedPendingCount file(s) selected and will upload when you save.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _retryUpload(int index) async {
    final localPath = _items[index].localPath;
    if (localPath == null || localPath.isEmpty) {
      return;
    }

    final file = File(localPath);
    if (!await file.exists()) {
      setState(() {
        _items[index] = _items[index].copyWith(
          errorMessage: 'File no longer exists on disk.',
          isUploading: false,
        );
      });
      return;
    }

    setState(() {
      _items[index] = _items[index].copyWith(
        isUploading: true,
        errorMessage: null,
        progress: 0,
        pendingUpload: false,
      );
    });

    await _uploadAtIndex(index, file);
  }

  Future<bool> _uploadAtIndex(
    int index,
    File file, {
    int? assignmentIdOverride,
  }) async {
    final assignmentId = assignmentIdOverride ?? widget.assignmentId;
    if (assignmentId <= 0) {
      if (mounted && index < _items.length) {
        setState(() {
          _items[index] = _items[index].copyWith(
            isUploading: false,
            pendingUpload: true,
            errorMessage: 'Save assignment first to upload this file.',
            progress: 0,
          );
        });
      }
      return false;
    }

    final result = await widget.assignmentService.uploadInstructionFile(
      assignmentId,
      file,
      onSendProgress: (sent, total) {
        if (total <= 0 || !mounted || index >= _items.length) {
          return;
        }
        setState(() {
          _items[index] = _items[index].copyWith(
            progress: (sent / total).clamp(0, 1).toDouble(),
          );
        });
      },
    );

    if (!mounted || index >= _items.length) {
      return false;
    }

    if (!result.isSuccess || result.data == null) {
      setState(() {
        _items[index] = _items[index].copyWith(
          isUploading: false,
          errorMessage: result.error?.message ?? 'Upload failed',
          progress: 0,
          pendingUpload: false,
        );
      });
      return false;
    }

    setState(() {
      _items[index] = _items[index].copyWith(
        uploadedFile: result.data,
        fileDatabaseId: result.data!.fileId > 0
            ? result.data!.fileId
            : (result.data!.driveFileId > 0 ? result.data!.driveFileId : null),
        isUploading: false,
        errorMessage: null,
        progress: 1,
        pendingUpload: false,
      );
    });
    _emitFilesChanged();
    return true;
  }

  void _emitFilesChanged() {
    widget.onFilesChanged?.call(
      _items
          .where((item) => item.uploadedFile != null)
          .map((item) => item.uploadedFile!)
          .toList(growable: false),
    );
  }

  void _showUrlError(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _openUrl(String url) async {
    final normalizedUrl = url.trim();
    if (normalizedUrl.isEmpty) {
      _showUrlError('No link available for this file.');
      return;
    }

    final uri = Uri.tryParse(normalizedUrl);
    if (uri == null) {
      _showUrlError('Invalid URL format.');
      return;
    }

    final canOpen = await canLaunchUrl(uri);
    if (!canOpen) {
      _showUrlError('No app available to open this link.');
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        _showUrlError('No app available to open this link.');
      }
    } catch (e) {
      _showUrlError('Failed to open link: $e');
    }
  }

  Future<void> _openPreview(DriveFileModel file) async {
    final previewUrl = file.iframeUrl.trim().isNotEmpty
        ? file.iframeUrl
        : file.webViewLink;

    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: SizedBox(
          width: 900,
          height: 620,
          child: _InstructionPreview(
            title: file.fileName,
            previewUrl: previewUrl,
            fallbackDownloadUrl: file.downloadUrl,
          ),
        ),
      ),
    );
  }
}

class _UploadItemTile extends StatelessWidget {
  const _UploadItemTile({
    required this.item,
    this.onRetry,
    this.onOpen,
    this.onDownload,
    this.onPreview,
    this.onDelete,
  });

  final _UploadItem item;
  final VoidCallback? onRetry;
  final VoidCallback? onOpen;
  final VoidCallback? onDownload;
  final VoidCallback? onPreview;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final title = item.uploadedFile?.fileName ?? item.displayName ?? 'File';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.insert_drive_file_outlined, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              if (item.isUploading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          if (item.isUploading) ...<Widget>[
            const SizedBox(height: 8),
            LinearProgressIndicator(value: item.progress),
          ],
          if (item.errorMessage != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              item.errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
          if (item.pendingUpload && item.errorMessage == null) ...<Widget>[
            const SizedBox(height: 8),
            const Text(
              'Will upload after save.',
              style: TextStyle(color: Colors.orange, fontSize: 12),
            ),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: <Widget>[
              if (onOpen != null)
                TextButton.icon(
                  onPressed: onOpen,
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Open'),
                ),
              if (onPreview != null)
                TextButton.icon(
                  onPressed: onPreview,
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Preview'),
                ),
              if (onDownload != null)
                TextButton.icon(
                  onPressed: onDownload,
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Download'),
                ),
              if (onDelete != null)
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              if (onRetry != null)
                TextButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InstructionPreview extends StatefulWidget {
  const _InstructionPreview({
    required this.title,
    required this.previewUrl,
    required this.fallbackDownloadUrl,
  });

  final String title;
  final String previewUrl;
  final String fallbackDownloadUrl;

  @override
  State<_InstructionPreview> createState() => _InstructionPreviewState();
}

class _InstructionPreviewState extends State<_InstructionPreview> {
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 10),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _hasError
              ? _PreviewFallback(downloadUrl: widget.fallbackDownloadUrl)
              : WebViewWidget(
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
      ],
    );
  }
}

class _PreviewFallback extends StatelessWidget {
  const _PreviewFallback({required this.downloadUrl});

  final String downloadUrl;

  void _showUrlError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _openDownloadUrl(BuildContext context) async {
    final normalizedUrl = downloadUrl.trim();
    if (normalizedUrl.isEmpty) {
      _showUrlError(context, 'No link available for this file.');
      return;
    }

    final uri = Uri.tryParse(normalizedUrl);
    if (uri == null) {
      _showUrlError(context, 'Invalid URL format.');
      return;
    }

    final canOpen = await canLaunchUrl(uri);
    if (!context.mounted) {
      return;
    }
    if (!canOpen) {
      _showUrlError(context, 'No app available to open this link.');
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!context.mounted) {
        return;
      }
      if (!launched) {
        _showUrlError(context, 'No app available to open this link.');
      }
    } catch (e) {
      if (!context.mounted) {
        return;
      }
      _showUrlError(context, 'Failed to open link: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.download_for_offline_outlined, size: 36),
            const SizedBox(height: 8),
            const Text(
              'Preview is not available. Download the file instead.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => _openDownloadUrl(context),
              icon: const Icon(Icons.download_rounded),
              label: const Text('Download File'),
            ),
          ],
        ),
      ),
    );
  }
}

class _UploadItem {
  const _UploadItem({
    this.localPath,
    this.displayName,
    this.uploadedFile,
    this.fileDatabaseId,
    this.progress = 0,
    this.isUploading = false,
    this.pendingUpload = false,
    this.errorMessage,
  });

  final String? localPath;
  final String? displayName;
  final DriveFileModel? uploadedFile;
  final int? fileDatabaseId;
  final double progress;
  final bool isUploading;
  final bool pendingUpload;
  final String? errorMessage;

  _UploadItem copyWith({
    String? localPath,
    String? displayName,
    DriveFileModel? uploadedFile,
    int? fileDatabaseId,
    double? progress,
    bool? isUploading,
    bool? pendingUpload,
    String? errorMessage,
  }) {
    return _UploadItem(
      localPath: localPath ?? this.localPath,
      displayName: displayName ?? this.displayName,
      uploadedFile: uploadedFile ?? this.uploadedFile,
      fileDatabaseId: fileDatabaseId ?? this.fileDatabaseId,
      progress: progress ?? this.progress,
      isUploading: isUploading ?? this.isUploading,
      pendingUpload: pendingUpload ?? this.pendingUpload,
      errorMessage: errorMessage,
    );
  }
}
