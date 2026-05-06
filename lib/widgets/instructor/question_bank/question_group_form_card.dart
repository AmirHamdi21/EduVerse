import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/question_bank/question_bank_enums.dart';
import '../../../models/question_bank/question_bank_group_model.dart';
import '../../../models/question_bank/question_bank_upload_response.dart';
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
    this.onUploadSharedImage,
    this.onRemoveSharedImage,
    this.isSubmitting = false,
  });

  final QuestionBankGroupModel? initial;
  final int? courseId;
  final void Function({
    String? title,
    String? sharedPrompt,
    int? sharedFileId,
    String? sharedFileCaption,
    String? sharedFileAltText,
    required QuestionGroupType groupType,
  })
  onSubmit;
  final Future<QuestionBankUploadResponse?> Function(String path)?
  onUploadSharedImage;
  final Future<void> Function(int fileId)? onRemoveSharedImage;
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
  bool _isUploading = false;

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
              imageUrl: _sharedImageUrl,
              isUploading: _isUploading || widget.isSubmitting,
              isDark: isDark,
              onPick: widget.onUploadSharedImage == null
                  ? null
                  : _pickSharedImage,
              onPreview: _sharedImageUrl == null
                  ? null
                  : () => _showImagePreview(
                      context,
                      imageUrl: _sharedImageUrl!,
                      title: _caption.text.trim().isNotEmpty
                          ? _caption.text
                          : '${l10n.qbGroupImage}: $_sharedFileId',
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
    if (path == null || widget.onUploadSharedImage == null) return;
    setState(() => _isUploading = true);
    final upload = await widget.onUploadSharedImage!(path);
    if (!mounted) return;
    setState(() {
      _sharedFileId = upload?.fileId ?? _sharedFileId;
      _sharedImageUrl = upload?.imageUrl ?? _sharedImageUrl;
      _isUploading = false;
    });
  }

  Future<void> _removeSharedImage() async {
    final fileId = _sharedFileId;
    if (fileId == null) return;
    setState(() => _isUploading = true);
    await widget.onRemoveSharedImage?.call(fileId);
    if (!mounted) return;
    setState(() {
      _sharedFileId = null;
      _sharedImageUrl = null;
      _caption.clear();
      _altText.clear();
      _isUploading = false;
    });
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
          constraints: const BoxConstraints(maxWidth: 680),
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
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image_outlined, size: 64),
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

class _GroupImagePanel extends StatelessWidget {
  const _GroupImagePanel({
    required this.fileId,
    required this.imageUrl,
    required this.isUploading,
    required this.isDark,
    required this.onPick,
    required this.onPreview,
    required this.onRemove,
  });

  final int? fileId;
  final String? imageUrl;
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
                      hasImage ? '${l10n.qbGroupImage} #$fileId' : l10n.image,
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
              if (hasImage && imageUrl != null) ...[
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
