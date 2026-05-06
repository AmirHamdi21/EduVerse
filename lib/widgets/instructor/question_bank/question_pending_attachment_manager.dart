import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/question_bank/question_attachment_payload.dart';

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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.attachments,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: isUploading ? null : _pickImages,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(l10n.qbUploadQuestionImage),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (attachments.isEmpty)
            Text(
              l10n.questionBankEmptyMessage,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xFF64748B)),
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
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
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
                        style: Theme.of(context).textTheme.titleMedium,
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
    return Card(
      key: key,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.drag_indicator_rounded),
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
                  ),
                ),
                IconButton(
                  tooltip: l10n.qbRemoveQuestionImage,
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              key: ValueKey('caption-${attachment.fileId}'),
              initialValue: attachment.caption,
              decoration: InputDecoration(labelText: l10n.qbImageCaption),
              onChanged: (value) =>
                  onChanged(attachment.copyWith(caption: value)),
            ),
            const SizedBox(height: 8),
            TextFormField(
              key: ValueKey('alt-${attachment.fileId}'),
              initialValue: attachment.altText,
              decoration: InputDecoration(labelText: l10n.qbImageAltText),
              onChanged: (value) =>
                  onChanged(attachment.copyWith(altText: value)),
            ),
          ],
        ),
      ),
    );
  }
}
