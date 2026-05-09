import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/question_bank/question_bank_enums.dart';
import '../../../models/question_bank/question_bank_group_model.dart';
import '../../../services/api_service.dart';
import '../../../services/storage_service.dart';
import '../shared/instructor_colors.dart';
import 'question_bank_localized_labels.dart';
import 'question_core_section.dart';
import 'question_form_menu_field.dart';

class QuestionGroupFormCard extends StatefulWidget {
  const QuestionGroupFormCard({
    super.key,
    this.initial,
    required this.courseId,
    required this.onSubmit,
    this.isSubmitting = false,
  });

  final QuestionBankGroupModel? initial;
  final int? courseId;
  final void Function({
    String? title,
    String? sharedPrompt,
    int? sharedFileId,
    String? sharedImageLocalPath,
    String? sharedFileCaption,
    String? sharedFileAltText,
    required QuestionGroupType groupType,
  })
  onSubmit;
  final bool isSubmitting;

  @override
  State<QuestionGroupFormCard> createState() => _QuestionGroupFormCardState();
}

class _QuestionGroupFormCardState extends State<QuestionGroupFormCard> {
  late QuestionGroupType _type =
      widget.initial?.groupType ?? QuestionGroupType.other;
  late final TextEditingController _title = TextEditingController(
    text: widget.initial?.title ?? '',
  );
  late final TextEditingController _prompt = TextEditingController(
    text: widget.initial?.sharedPrompt ?? '',
  );
  late final TextEditingController _caption = TextEditingController(
    text: widget.initial?.sharedFileCaption ?? '',
  );
  late final TextEditingController _altText = TextEditingController(
    text: widget.initial?.sharedFileAltText ?? '',
  );
  late int? _sharedFileId = widget.initial?.sharedFileId;
  late String? _sharedImageUrl = widget.initial?.sharedImageUrl;
  String? _sharedImageLocalPath;
  int _pendingFileSeed = -1;

  @override
  void dispose() {
    _title.dispose();
    _prompt.dispose();
    _caption.dispose();
    _altText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final groupImagePreviewUrl =
        _sharedImageLocalPath ??
        _resolveFormGroupImageUrl(_sharedImageUrl, _sharedFileId);
    final groupImageLabel = _groupImageLabel(l10n);
    return Column(
      children: [
        QuestionSectionCard(
          title: widget.initial == null ? l10n.qbCreateGroup : l10n.qbEditGroup,
          icon: Icons.folder_copy_outlined,
          color: InstructorColors.accent,
          children: [
            TextField(
              controller: _title,
              decoration: _decoration(context, l10n.title, Icons.title_rounded),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _prompt,
              minLines: 4,
              maxLines: 7,
              decoration: _decoration(
                context,
                l10n.qbSharedPrompt,
                Icons.notes_rounded,
              ),
            ),
            const SizedBox(height: 12),
            _GroupImagePanel(
              fileId: _sharedFileId,
              imageLabel: groupImageLabel,
              isUploading: widget.isSubmitting,
              isDark: isDark,
              onPick: _pickSharedImage,
              onPreview: groupImagePreviewUrl == null
                  ? null
                  : () => _showImagePreview(
                      context,
                      imageUrl: groupImagePreviewUrl,
                      title: _caption.text.trim().isNotEmpty
                          ? _caption.text
                          : groupImageLabel,
                    ),
              onRemove: _sharedFileId == null ? null : _removeSharedImage,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _caption,
              decoration: _decoration(
                context,
                l10n.qbImageCaption,
                Icons.closed_caption_outlined,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _altText,
              decoration: _decoration(
                context,
                l10n.qbImageAltText,
                Icons.accessibility_new_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        QuestionSectionCard(
          title: l10n.qbQuestionSettings,
          icon: Icons.tune_rounded,
          color: InstructorColors.teal,
          children: [
            QuestionFormMenuField<QuestionGroupType>(
              label: l10n.qbGroupType,
              value: _type,
              icon: Icons.category_outlined,
              color: InstructorColors.teal,
              options: QuestionGroupType.values
                  .map(
                    (type) => QuestionFormMenuOption<QuestionGroupType>(
                      value: type,
                      label: localizedGroupType(l10n, type),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _type = value ?? _type),
            ),
          ],
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton.icon(
            onPressed: widget.isSubmitting || widget.courseId == null
                ? null
                : () => widget.onSubmit(
                    title: _title.text,
                    sharedPrompt: _prompt.text,
                    sharedFileId: _sharedFileId,
                    sharedImageLocalPath: _sharedImageLocalPath,
                    sharedFileCaption: _caption.text,
                    sharedFileAltText: _altText.text,
                    groupType: _type,
                  ),
            style: FilledButton.styleFrom(
              backgroundColor: InstructorColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: InstructorColors.primary.withValues(
                alpha: 0.42,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            icon: widget.isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.save_rounded),
            label: Text(
              l10n.save,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickSharedImage() async {
    final picked = await FilePicker.platform.pickFiles(type: FileType.image);
    final path = picked?.files.single.path;
    if (path == null) return;
    setState(() {
      _sharedFileId = _nextPendingFileId();
      _sharedImageLocalPath = path;
      _sharedImageUrl = null;
    });
  }

  Future<void> _removeSharedImage() async {
    final fileId = _sharedFileId;
    if (fileId == null) return;
    if (!mounted) return;
    setState(() {
      _sharedFileId = null;
      _sharedImageUrl = null;
      _sharedImageLocalPath = null;
      _caption.clear();
      _altText.clear();
    });
  }

  int _nextPendingFileId() => _pendingFileSeed--;

  String _groupImageLabel(AppLocalizations l10n) {
    final fileId = _sharedFileId;
    final localPath = _sharedImageLocalPath;
    if (fileId != null &&
        fileId <= 0 &&
        localPath != null &&
        localPath.trim().isNotEmpty) {
      return _fileNameFromPath(localPath);
    }
    if (fileId != null) return '${l10n.qbGroupImage} #$fileId';
    return l10n.qbGroupImage;
  }

  Future<void> _showImagePreview(
    BuildContext context, {
    required String imageUrl,
    required String title,
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(18),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 760,
            maxHeight: MediaQuery.sizeOf(context).height * 0.88,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: InstructorColors.cardColor(isDark),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: InstructorColors.borderColor(isDark)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: InstructorColors.accent.withValues(
                            alpha: isDark ? 0.2 : 0.1,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.image_outlined,
                          color: InstructorColors.accent,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: InstructorColors.textPrimaryColor(isDark),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: InteractiveViewer(
                    minScale: 0.7,
                    maxScale: 4,
                    child: _GroupFormPreviewImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      height: MediaQuery.sizeOf(context).height * 0.72,
                      isDark: isDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(
    BuildContext context,
    String label,
    IconData icon,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: InstructorColors.surfaceColor(isDark),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: InstructorColors.borderColor(isDark)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: InstructorColors.primary,
          width: 1.4,
        ),
      ),
    );
  }
}

class _GroupFormPreviewImage extends StatelessWidget {
  const _GroupFormPreviewImage({
    required this.imageUrl,
    required this.fit,
    required this.height,
    required this.isDark,
  });

  final String imageUrl;
  final BoxFit fit;
  final double height;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.startsWith('data:image')) {
      final comma = imageUrl.indexOf(',');
      if (comma > -1) {
        try {
          return Image.memory(
            base64Decode(imageUrl.substring(comma + 1)),
            width: double.infinity,
            height: height,
            fit: fit,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded || frame != null) return child;
              return _GroupFormImageLoadingBox(height: height, isDark: isDark);
            },
            errorBuilder: (_, __, ___) =>
                _GroupFormImageErrorBox(height: height, isDark: isDark),
          );
        } on FormatException {
          return _GroupFormImageErrorBox(height: height, isDark: isDark);
        }
      }
    }

    if (!imageUrl.startsWith('http://') && !imageUrl.startsWith('https://')) {
      return Image.file(
        File(imageUrl),
        width: double.infinity,
        height: height,
        fit: fit,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) return child;
          return _GroupFormImageLoadingBox(height: height, isDark: isDark);
        },
        errorBuilder: (_, __, ___) =>
            _GroupFormImageErrorBox(height: height, isDark: isDark),
      );
    }

    if (_requiresFormGroupImageAuth(imageUrl)) {
      return FutureBuilder<String?>(
        future: StorageService().getAccessToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return _GroupFormImageLoadingBox(height: height, isDark: isDark);
          }
          final token = snapshot.data;
          if (token == null || token.isEmpty) {
            return _GroupFormImageErrorBox(height: height, isDark: isDark);
          }
          return _networkImage(<String, String>{
            'Authorization': 'Bearer $token',
          });
        },
      );
    }

    return _networkImage(null);
  }

  Widget _networkImage(Map<String, String>? headers) {
    return Image.network(
      imageUrl,
      headers: headers,
      width: double.infinity,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _GroupFormImageLoadingBox(height: height, isDark: isDark);
      },
      errorBuilder: (_, __, ___) =>
          _GroupFormImageErrorBox(height: height, isDark: isDark),
    );
  }
}

String? _resolveFormGroupImageUrl(String? imageUrl, int? fileId) {
  final trimmed = imageUrl?.trim();
  if (trimmed != null && trimmed.isNotEmpty) return trimmed;
  if (fileId == null || fileId <= 0) return null;
  return '${ApiService.baseUrl}/files/$fileId/download';
}

bool _requiresFormGroupImageAuth(String url) {
  return url.contains('/api/files/') ||
      url.startsWith('${ApiService.baseUrl}/files/');
}

String _fileNameFromPath(String path) {
  final parts = path.split(RegExp(r'[\\/]'));
  return parts.isEmpty ? path : parts.last;
}

class _GroupFormImageLoadingBox extends StatelessWidget {
  const _GroupFormImageLoadingBox({required this.height, required this.isDark});

  final double height;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      alignment: Alignment.center,
      color: InstructorColors.accent.withValues(alpha: isDark ? 0.16 : 0.08),
      child: const SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(strokeWidth: 2.5),
      ),
    );
  }
}

class _GroupFormImageErrorBox extends StatelessWidget {
  const _GroupFormImageErrorBox({required this.height, required this.isDark});

  final double height;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      alignment: Alignment.center,
      color: InstructorColors.accent.withValues(alpha: isDark ? 0.16 : 0.08),
      child: Icon(
        Icons.image_not_supported_outlined,
        color: InstructorColors.textSecondaryColor(isDark),
        size: 44,
      ),
    );
  }
}

class _GroupImagePanel extends StatelessWidget {
  const _GroupImagePanel({
    required this.fileId,
    required this.imageLabel,
    required this.isUploading,
    required this.isDark,
    required this.onPick,
    required this.onPreview,
    required this.onRemove,
  });

  final int? fileId;
  final String imageLabel;
  final bool isUploading;
  final bool isDark;
  final VoidCallback? onPick;
  final VoidCallback? onPreview;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasImage = fileId != null;
    final color = hasImage ? InstructorColors.teal : InstructorColors.accent;
    final label = hasImage ? l10n.qbGroupImage : l10n.qbUploadGroupImage;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isUploading ? null : onPreview ?? onPick,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.14 : 0.07),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: 0.22)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: isUploading
                    ? Padding(
                        padding: const EdgeInsets.all(11),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      )
                    : Icon(
                        hasImage
                            ? Icons.image_search_rounded
                            : Icons.add_photo_alternate_outlined,
                        color: color,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: InstructorColors.textPrimaryColor(isDark),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      hasImage ? imageLabel : l10n.image,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: InstructorColors.textSecondaryColor(isDark),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: l10n.qbUploadGroupImage,
                onPressed: isUploading ? null : onPick,
                style: IconButton.styleFrom(
                  backgroundColor: color.withValues(alpha: isDark ? 0.2 : 0.1),
                  foregroundColor: color,
                  minimumSize: const Size(40, 40),
                ),
                icon: Icon(
                  hasImage ? Icons.sync_rounded : Icons.upload_rounded,
                ),
              ),
              if (hasImage && onPreview != null) ...[
                const SizedBox(width: 6),
                IconButton(
                  tooltip: l10n.qbGroupImage,
                  onPressed: isUploading ? null : onPreview,
                  style: IconButton.styleFrom(
                    backgroundColor: InstructorColors.primary.withValues(
                      alpha: isDark ? 0.18 : 0.1,
                    ),
                    foregroundColor: InstructorColors.primary,
                    minimumSize: const Size(40, 40),
                  ),
                  icon: const Icon(Icons.visibility_outlined),
                ),
              ],
              if (hasImage && onRemove != null) ...[
                const SizedBox(width: 6),
                IconButton(
                  tooltip: l10n.remove,
                  onPressed: isUploading ? null : onRemove,
                  style: IconButton.styleFrom(
                    backgroundColor: InstructorColors.error.withValues(
                      alpha: isDark ? 0.18 : 0.1,
                    ),
                    foregroundColor: InstructorColors.error,
                    minimumSize: const Size(40, 40),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
