import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/question_bank/question_attachment_payload.dart';
import '../shared/instructor_colors.dart';

class QuestionPendingAttachmentManager extends StatelessWidget {
  const QuestionPendingAttachmentManager({
    super.key,
    required this.attachments,
    required this.onUpload,
    required this.onChanged,
    required this.onRemove,
    required this.onReorder,
    this.isUploading = false,
  });

  final List<QuestionAttachmentPayload> attachments;
  final ValueChanged<List<String>> onUpload;
  final ValueChanged<QuestionAttachmentPayload> onChanged;
  final ValueChanged<int> onRemove;
  final ValueChanged<List<int>> onReorder;
  final bool isUploading;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: InstructorColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 390;
              final title = Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: InstructorColors.cyan.withValues(
                        alpha: isDark ? 0.2 : 0.1,
                      ),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.collections_outlined,
                      color: InstructorColors.cyan,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.attachments,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: InstructorColors.textPrimaryColor(isDark),
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              );
              final uploadButton = OutlinedButton.icon(
                onPressed: isUploading ? null : _pickImages,
                style: OutlinedButton.styleFrom(
                  backgroundColor: InstructorColors.cyan.withValues(
                    alpha: isDark ? 0.18 : 0.08,
                  ),
                  foregroundColor: InstructorColors.cyan,
                  side: BorderSide(
                    color: InstructorColors.cyan.withValues(alpha: 0.24),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                icon: isUploading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_photo_alternate_outlined),
                label: Text(
                  l10n.qbUploadQuestionImage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [title, const SizedBox(height: 10), uploadButton],
                );
              }
              return Row(
                children: [
                  Expanded(child: title),
                  const SizedBox(width: 10),
                  Flexible(child: uploadButton),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          if (attachments.isEmpty)
            Text(
              l10n.questionBankEmptyMessage,
              style: TextStyle(
                color: InstructorColors.textSecondaryColor(isDark),
                fontWeight: FontWeight.w700,
              ),
            )
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: attachments.length,
              onReorder: (oldIndex, newIndex) {
                final ids = attachments
                    .map((attachment) => attachment.fileId)
                    .whereType<int>()
                    .toList();
                final target = newIndex > oldIndex ? newIndex - 1 : newIndex;
                final moved = ids.removeAt(oldIndex);
                ids.insert(target, moved);
                onReorder(ids);
              },
              itemBuilder: (context, index) {
                final attachment = attachments[index];
                return _PendingAttachmentCard(
                  key: ValueKey(attachment.fileId ?? index),
                  attachment: attachment,
                  index: index,
                  onChanged: onChanged,
                  onRemove: attachment.fileId == null
                      ? null
                      : () => onRemove(attachment.fileId!),
                  onPreview: attachment.imageUrl == null
                      ? null
                      : () => _showPreview(context, attachment),
                );
              },
            ),
        ],
      ),
    );
  }

  Future<void> _pickImages() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    final paths =
        picked?.files.map((file) => file.path).whereType<String>().toList() ??
        const <String>[];
    if (paths.isNotEmpty) onUpload(paths);
  }

  Future<void> _showPreview(
    BuildContext context,
    QuestionAttachmentPayload attachment,
  ) async {
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(18),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Builder(
            builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Container(
                decoration: BoxDecoration(
                  color: InstructorColors.cardColor(isDark),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: InstructorColors.borderColor(isDark),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              attachment.caption?.trim().isNotEmpty == true
                                  ? attachment.caption!
                                  : attachment.fileName ?? l10n.attachments,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: InstructorColors.textPrimaryColor(
                                  isDark,
                                ),
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
                          attachment.imageUrl!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image_outlined, size: 64),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PendingAttachmentCard extends StatelessWidget {
  const _PendingAttachmentCard({
    super.key,
    required this.attachment,
    required this.index,
    required this.onChanged,
    required this.onRemove,
    required this.onPreview,
  });

  final QuestionAttachmentPayload attachment;
  final int index;
  final ValueChanged<QuestionAttachmentPayload> onChanged;
  final VoidCallback? onRemove;
  final VoidCallback? onPreview;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.drag_indicator_rounded,
                  color: InstructorColors.textTertiaryColor(isDark),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onPreview,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: attachment.imageUrl == null
                        ? const SizedBox(
                            width: 56,
                            height: 56,
                            child: Icon(Icons.image_outlined),
                          )
                        : Image.network(
                            attachment.imageUrl!,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image_outlined),
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    attachment.fileName ??
                        '${l10n.questionBankImageQuestion} ${index + 1}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: InstructorColors.textPrimaryColor(isDark),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l10n.qbRemoveQuestionImage,
                  onPressed: onRemove,
                  style: IconButton.styleFrom(
                    backgroundColor: InstructorColors.error.withValues(
                      alpha: isDark ? 0.18 : 0.1,
                    ),
                    foregroundColor: InstructorColors.error,
                  ),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              key: ValueKey('caption-${attachment.fileId}'),
              initialValue: attachment.caption,
              decoration: _decoration(context, l10n.qbImageCaption),
              onChanged: (value) =>
                  onChanged(attachment.copyWith(caption: value)),
            ),
            const SizedBox(height: 8),
            TextFormField(
              key: ValueKey('alt-${attachment.fileId}'),
              initialValue: attachment.altText,
              decoration: _decoration(context, l10n.qbImageAltText),
              onChanged: (value) =>
                  onChanged(attachment.copyWith(altText: value)),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _decoration(BuildContext context, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: InstructorColors.surfaceColor(isDark),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: InstructorColors.borderColor(isDark)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: InstructorColors.primary,
          width: 1.4,
        ),
      ),
    );
  }
}
