import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/core/drive_file_model.dart';
import '../../../models/core/lab_instruction_model.dart';
import '../../../services/api/lab_service.dart';
import '../../student/shared/drive_file_preview_screen.dart';
import '../../ta/shared/ta_colors.dart';
import '../shared/instructor_colors.dart';

class PendingLabInstructionUploadResult {
  const PendingLabInstructionUploadResult({
    this.successCount = 0,
    this.failureCount = 0,
    this.failedFileNames = const <String>[],
  });

  final int successCount;
  final int failureCount;
  final List<String> failedFileNames;
}

class LabEditorInstructionFileUploader extends StatefulWidget {
  const LabEditorInstructionFileUploader({
    super.key,
    required this.labId,
    required this.labService,
    this.initialFiles = const <DriveFileModel>[],
    this.initialInstructions = const <LabInstructionModel>[],
    this.useTAColors = false,
    this.onFilesChanged,
  });

  final int labId;
  final LabService labService;
  final List<DriveFileModel> initialFiles;
  final List<LabInstructionModel> initialInstructions;
  final bool useTAColors;
  final ValueChanged<List<DriveFileModel>>? onFilesChanged;

  @override
  State<LabEditorInstructionFileUploader> createState() =>
      LabEditorInstructionFileUploaderState();
}

class LabEditorInstructionFileUploaderState
    extends State<LabEditorInstructionFileUploader> {
  final List<_LabUploadItem> _items = <_LabUploadItem>[];

  Color get _primaryColor =>
      widget.useTAColors ? TAColors.primary : InstructorColors.primary;
  Color get _errorColor =>
      widget.useTAColors ? TAColors.error : InstructorColors.error;
  Color _darkCardColor() =>
      widget.useTAColors ? TAColors.darkCard : InstructorColors.darkCard;
  Color _textPrimaryColor(bool isDark) => widget.useTAColors
      ? TAColors.textPrimaryColor(isDark)
      : InstructorColors.textPrimaryColor(isDark);
  Color _textSecondaryColor(bool isDark) => widget.useTAColors
      ? TAColors.textSecondaryColor(isDark)
      : InstructorColors.textSecondaryColor(isDark);

  @override
  void initState() {
    super.initState();
    _seedInitialItems();
  }

  @override
  void didUpdateWidget(covariant LabEditorInstructionFileUploader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialFiles != widget.initialFiles ||
        oldWidget.initialInstructions != widget.initialInstructions) {
      _mergeInitialItems();
    }
  }

  Future<PendingLabInstructionUploadResult> uploadPendingFiles(int labId) async {
    final pendingIndexes = <int>[];
    for (var index = 0; index < _items.length; index++) {
      final item = _items[index];
      if (item.uploadedFile == null &&
          item.localPath != null &&
          item.localPath!.trim().isNotEmpty) {
        pendingIndexes.add(index);
      }
    }

    if (pendingIndexes.isEmpty) {
      return const PendingLabInstructionUploadResult();
    }

    if (labId <= 0) {
      final failedNames = <String>[];
      if (mounted) {
        setState(() {
          for (final index in pendingIndexes) {
            final name = _items[index].displayName ?? 'File';
            failedNames.add(name);
            _items[index] = _items[index].copyWith(
              isUploading: false,
              errorMessage:
                  AppLocalizations.of(context).labEditorInstructionSaveFirst,
              pendingUpload: true,
              progress: 0,
            );
          }
        });
      }
      return PendingLabInstructionUploadResult(
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
              errorMessage:
                  AppLocalizations.of(context).labEditorInstructionMissingFile,
              pendingUpload: true,
              progress: 0,
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

      final uploaded = await _uploadAtIndex(index, file, labIdOverride: labId);
      if (uploaded) {
        successCount++;
      } else {
        failedNames.add(displayName);
      }
    }

    return PendingLabInstructionUploadResult(
      successCount: successCount,
      failureCount: failedNames.length,
      failedFileNames: failedNames,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark
                ? _darkCardColor().withValues(alpha: 0.65)
                : Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _primaryColor.withValues(alpha: 0.12)),
          ),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final isCompact = constraints.maxWidth < 380;
              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildUploaderIntro(isDark, l10n),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonalIcon(
                        onPressed: _pickAndUpload,
                        style: FilledButton.styleFrom(
                          foregroundColor: _primaryColor,
                          backgroundColor:
                              _primaryColor.withValues(alpha: 0.12),
                        ),
                        icon: const Icon(Icons.add_rounded),
                        label: Text(l10n.addFiles),
                      ),
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: _buildUploaderIntro(isDark, l10n)),
                  const SizedBox(width: 12),
                  FilledButton.tonalIcon(
                    onPressed: _pickAndUpload,
                    style: FilledButton.styleFrom(
                      foregroundColor: _primaryColor,
                      backgroundColor: _primaryColor.withValues(alpha: 0.12),
                    ),
                    icon: const Icon(Icons.add_rounded),
                    label: Text(l10n.addFiles),
                  ),
                ],
              );
            },
          ),
        ),
        if (_items.isNotEmpty) const SizedBox(height: 10),
        if (_items.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? _darkCardColor().withValues(alpha: 0.58)
                  : Colors.white.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _primaryColor.withValues(alpha: 0.10)),
            ),
            child: Text(
              l10n.assignmentNoInstructionFiles,
              style: TextStyle(color: _textSecondaryColor(isDark)),
            ),
          )
        else
          for (var index = 0; index < _items.length; index++)
            _LabUploadItemTile(
              item: _items[index],
              useTAColors: widget.useTAColors,
              onRetry: _items[index].localPath == null ||
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
              onDelete: () => _deleteItem(index),
            ),
      ],
    );
  }

  Widget _buildUploaderIntro(bool isDark, AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _primaryColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.upload_file_rounded, color: _primaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                l10n.labEditorInstructionFilesTitle,
                style: TextStyle(
                  color: _textPrimaryColor(isDark),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.labId <= 0
                    ? l10n.labEditorInstructionFilesPendingHint
                    : l10n.labEditorInstructionFilesUploadHint,
                style: TextStyle(
                  color: _textSecondaryColor(isDark),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _seedInitialItems() {
    final mappedInstructions = _mapInstructionIds(widget.initialInstructions);
    for (final file in widget.initialFiles) {
      final uniqueKey = _buildFileKey(file);
      if (_items.any((item) => item.uniqueFileKey == uniqueKey)) {
        continue;
      }
      _items.add(
        _LabUploadItem(
          uploadedFile: file,
          instructionId: mappedInstructions[uniqueKey],
          uniqueFileKey: uniqueKey,
        ),
      );
    }
  }

  void _mergeInitialItems() {
    final mappedInstructions = _mapInstructionIds(widget.initialInstructions);
    var changed = false;
    for (final file in widget.initialFiles) {
      final uniqueKey = _buildFileKey(file);
      final index = _items.indexWhere((item) => item.uniqueFileKey == uniqueKey);
      if (index == -1) {
        _items.add(
          _LabUploadItem(
            uploadedFile: file,
            instructionId: mappedInstructions[uniqueKey],
            uniqueFileKey: uniqueKey,
          ),
        );
        changed = true;
        continue;
      }
      final item = _items[index];
      if (item.uploadedFile == null || item.instructionId == null) {
        _items[index] = item.copyWith(
          uploadedFile: file,
          instructionId: item.instructionId ?? mappedInstructions[uniqueKey],
          uniqueFileKey: uniqueKey,
        );
        changed = true;
      }
    }
    if (changed && mounted) {
      setState(() {});
      _emitFilesChanged();
    }
  }

  Map<String, int> _mapInstructionIds(List<LabInstructionModel> instructions) {
    final mapping = <String, int>{};
    for (final instruction in instructions) {
      final file = instruction.file;
      if (file == null) {
        continue;
      }
      mapping[_buildFileKey(file)] = instruction.id;
    }
    return mapping;
  }

  String _buildFileKey(DriveFileModel file) {
    if (file.driveId.trim().isNotEmpty) {
      return 'drive:${file.driveId.trim()}';
    }
    if (file.fileId > 0) {
      return 'file:${file.fileId}';
    }
    if (file.driveFileId > 0) {
      return 'drive-file:${file.driveFileId}';
    }
    return 'name:${file.fileName.trim().toLowerCase()}';
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

      if (widget.labId <= 0) {
        setState(() {
          _items.add(
            _LabUploadItem(
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
          _LabUploadItem(
            localPath: path,
            displayName: platformFile.name,
            isUploading: true,
            progress: 0,
          ),
        );
      });
      await _uploadAtIndex(newIndex, File(path));
    }

    if (addedPendingCount > 0 && mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.labEditorInstructionFilesQueued(addedPendingCount),
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
      if (!mounted) {
        return;
      }
      setState(() {
        _items[index] = _items[index].copyWith(
          errorMessage:
              AppLocalizations.of(context).labEditorInstructionMissingFile,
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
    int? labIdOverride,
  }) async {
    final l10n = AppLocalizations.of(context);
    final labId = labIdOverride ?? widget.labId;
    if (labId <= 0) {
      if (mounted && index < _items.length) {
        setState(() {
          _items[index] = _items[index].copyWith(
            isUploading: false,
            pendingUpload: true,
            errorMessage: l10n.labEditorInstructionSaveFirst,
            progress: 0,
          );
        });
      }
      return false;
    }

    final result = await widget.labService.uploadInstructionFile(
      labId,
      file,
      orderIndex: index,
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
          errorMessage: result.error?.message ?? l10n.failed,
          progress: 0,
          pendingUpload: false,
        );
      });
      return false;
    }

    final uploadedFile = result.data!;
    final resolvedInstructionId = await _resolveInstructionId(
      labId,
      uploadedFile,
      fallbackInstructions: const <LabInstructionModel>[],
    );

    if (!mounted || index >= _items.length) {
      return false;
    }

    setState(() {
      _items[index] = _items[index].copyWith(
        uploadedFile: uploadedFile,
        instructionId: resolvedInstructionId,
        uniqueFileKey: _buildFileKey(uploadedFile),
        isUploading: false,
        errorMessage: null,
        progress: 1,
        pendingUpload: false,
      );
    });
    _emitFilesChanged();
    return true;
  }

  Future<void> _deleteItem(int index) async {
    if (index < 0 || index >= _items.length) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    final item = _items[index];

    if (item.uploadedFile == null) {
      setState(() {
        _items.removeAt(index);
      });
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.labEditorInstructionDeleteTitle),
        content: Text(
          l10n.labEditorInstructionDeleteMessage(
            item.uploadedFile!.fileName,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: _errorColor),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    if (widget.labId <= 0) {
      setState(() {
        _items.removeAt(index);
      });
      _emitFilesChanged();
      return;
    }

    setState(() {
      _items[index] = _items[index].copyWith(
        isUploading: true,
        errorMessage: null,
        progress: 0,
      );
    });

    final instructionId =
        item.instructionId ??
        await _resolveInstructionId(
          widget.labId,
          item.uploadedFile!,
          fallbackInstructions: widget.initialInstructions,
        );

    if (!mounted || index >= _items.length) {
      return;
    }

    if (instructionId == null || instructionId <= 0) {
      setState(() {
        _items[index] = _items[index].copyWith(
          isUploading: false,
          errorMessage: l10n.labEditorInstructionDeleteUnavailable,
        );
      });
      return;
    }

    final result = await widget.labService.deleteInstruction(
      widget.labId,
      instructionId,
    );

    if (!mounted || index >= _items.length) {
      return;
    }

    if (!result.isSuccess) {
      setState(() {
        _items[index] = _items[index].copyWith(
          isUploading: false,
          errorMessage: result.error?.message ?? l10n.failed,
        );
      });
      return;
    }

    setState(() {
      _items.removeAt(index);
    });
    _emitFilesChanged();
  }

  Future<int?> _resolveInstructionId(
    int labId,
    DriveFileModel file, {
    required List<LabInstructionModel> fallbackInstructions,
  }) async {
    final localMatch = _matchInstruction(fallbackInstructions, file);
    if (localMatch != null) {
      return localMatch.id;
    }

    final result = await widget.labService.getInstructions(labId);
    if (!result.isSuccess || result.data == null) {
      return null;
    }

    final remoteMatch = _matchInstruction(result.data!, file);
    return remoteMatch?.id;
  }

  LabInstructionModel? _matchInstruction(
    List<LabInstructionModel> instructions,
    DriveFileModel file,
  ) {
    for (final instruction in instructions) {
      final instructionFile = instruction.file;
      if (instructionFile == null) {
        continue;
      }
      final sameDriveId = instructionFile.driveId.trim().isNotEmpty &&
          instructionFile.driveId == file.driveId;
      final sameFileId =
          instructionFile.fileId > 0 &&
          file.fileId > 0 &&
          instructionFile.fileId == file.fileId;
      final sameDriveFileId =
          instructionFile.driveFileId > 0 &&
          file.driveFileId > 0 &&
          instructionFile.driveFileId == file.driveFileId;
      final sameName = instructionFile.fileName == file.fileName;

      if (sameDriveId || sameFileId || sameDriveFileId || sameName) {
        return instruction;
      }
    }
    return null;
  }

  void _emitFilesChanged() {
    widget.onFilesChanged?.call(
      _items
          .where((item) => item.uploadedFile != null)
          .map((item) => item.uploadedFile!)
          .toList(growable: false),
    );
  }

  Future<void> _openPreview(DriveFileModel file) async {
    if (!mounted) {
      return;
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    await openDriveFilePreviewScreen(context, file: file, isDark: isDark);
  }

  Future<void> _openUrl(String value) async {
    final uri = Uri.tryParse(value.trim());
    if (uri == null) {
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _LabUploadItemTile extends StatelessWidget {
  const _LabUploadItemTile({
    required this.item,
    this.useTAColors = false,
    this.onRetry,
    this.onOpen,
    this.onDownload,
    this.onPreview,
    this.onDelete,
  });

  final _LabUploadItem item;
  final bool useTAColors;
  final VoidCallback? onRetry;
  final VoidCallback? onOpen;
  final VoidCallback? onDownload;
  final VoidCallback? onPreview;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final title = item.uploadedFile?.fileName ?? item.displayName ?? 'File';
    final primaryColor =
        useTAColors ? TAColors.primary : InstructorColors.primary;
    final warningColor =
        useTAColors ? TAColors.warning : InstructorColors.warning;
    final errorColor = useTAColors ? TAColors.error : InstructorColors.error;
    final errorLightColor =
        useTAColors ? TAColors.errorLight : InstructorColors.errorLight;
    final darkCardColor =
        useTAColors ? TAColors.darkCard : InstructorColors.darkCard;
    final textPrimaryColor = useTAColors
        ? TAColors.textPrimaryColor(isDark)
        : InstructorColors.textPrimaryColor(isDark);
    final textSecondaryColor = useTAColors
        ? TAColors.textSecondaryColor(isDark)
        : InstructorColors.textSecondaryColor(isDark);
    final borderColor = item.errorMessage != null
        ? errorColor.withValues(alpha: 0.24)
        : primaryColor.withValues(alpha: 0.10);
    final backgroundColor = item.errorMessage != null
        ? errorLightColor.withValues(alpha: isDark ? 0.10 : 0.55)
        : (isDark
            ? darkCardColor.withValues(alpha: 0.72)
            : Colors.white.withValues(alpha: 0.96));

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: item.errorMessage != null
                      ? errorColor.withValues(alpha: 0.12)
                      : primaryColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.errorMessage != null
                      ? Icons.warning_amber_rounded
                      : Icons.insert_drive_file_outlined,
                  size: 18,
                  color: item.errorMessage != null ? errorColor : primaryColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: textPrimaryColor,
                  ),
                ),
              ),
              if (item.pendingUpload && !item.isUploading)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: warningColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    l10n.pending,
                    style: TextStyle(
                      color: warningColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
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
              style: TextStyle(
                color: errorColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              if (item.uploadedFile != null) ...<Widget>[
                OutlinedButton.icon(
                  onPressed: onPreview,
                  icon: const Icon(Icons.visibility_outlined),
                  label: Text(l10n.preview),
                ),
                OutlinedButton.icon(
                  onPressed: onOpen,
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: Text(l10n.labEditorOpenInDrive),
                ),
                OutlinedButton.icon(
                  onPressed: onDownload,
                  icon: const Icon(Icons.download_rounded),
                  label: Text(l10n.download),
                ),
              ],
              if (item.errorMessage != null && onRetry != null)
                OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l10n.retry),
                ),
              OutlinedButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
                label: Text(l10n.delete),
                style: OutlinedButton.styleFrom(
                  foregroundColor: errorColor,
                ),
              ),
            ],
          ),
          if (item.pendingUpload && item.errorMessage == null) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              l10n.labEditorInstructionPendingCaption,
              style: TextStyle(
                color: textSecondaryColor,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LabUploadItem {
  const _LabUploadItem({
    this.localPath,
    this.displayName,
    this.uploadedFile,
    this.instructionId,
    this.isUploading = false,
    this.progress = 0,
    this.errorMessage,
    this.pendingUpload = false,
    this.uniqueFileKey,
  });

  final String? localPath;
  final String? displayName;
  final DriveFileModel? uploadedFile;
  final int? instructionId;
  final bool isUploading;
  final double progress;
  final String? errorMessage;
  final bool pendingUpload;
  final String? uniqueFileKey;

  _LabUploadItem copyWith({
    String? localPath,
    String? displayName,
    DriveFileModel? uploadedFile,
    int? instructionId,
    bool? isUploading,
    double? progress,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? pendingUpload,
    String? uniqueFileKey,
  }) {
    return _LabUploadItem(
      localPath: localPath ?? this.localPath,
      displayName: displayName ?? this.displayName,
      uploadedFile: uploadedFile ?? this.uploadedFile,
      instructionId: instructionId ?? this.instructionId,
      isUploading: isUploading ?? this.isUploading,
      progress: progress ?? this.progress,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      pendingUpload: pendingUpload ?? this.pendingUpload,
      uniqueFileKey: uniqueFileKey ?? this.uniqueFileKey,
    );
  }
}
