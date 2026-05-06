import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/question_bank/question_bank_attachment_model.dart';
import '../../../models/question_bank/question_bank_enums.dart';
import 'question_attachment_form_card.dart';
import 'question_attachment_reorder_list.dart';

class QuestionAttachmentManager extends StatefulWidget {
  const QuestionAttachmentManager({
    super.key,
    required this.attachments,
    required this.onAddByFileId,
    required this.onUploadImage,
    required this.onUpdate,
    required this.onReorder,
    required this.onRemove,
    this.isMutating = false,
  });

  final List<QuestionBankAttachmentModel> attachments;
  final void Function({
    required int fileId,
    required QuestionAttachmentType attachmentType,
    String? caption,
    String? altText,
    int? displayOrder,
    bool? isPrimary,
  })
  onAddByFileId;
  final ValueChanged<String> onUploadImage;
  final void Function({
    required int attachmentId,
    String? caption,
    String? altText,
    int? displayOrder,
    bool? isPrimary,
  })
  onUpdate;
  final ValueChanged<List<int>> onReorder;
  final ValueChanged<int> onRemove;
  final bool isMutating;

  @override
  State<QuestionAttachmentManager> createState() =>
      _QuestionAttachmentManagerState();
}

class _QuestionAttachmentManagerState extends State<QuestionAttachmentManager> {
  QuestionBankAttachmentModel? _editing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuestionAttachmentFormCard(
          key: ValueKey(_editing?.attachmentId ?? 0),
          initial: _editing,
          isSubmitting: widget.isMutating,
          onAddByFileId: widget.onAddByFileId,
          onUpdate:
              ({
                required attachmentId,
                caption,
                altText,
                displayOrder,
                isPrimary,
              }) {
                widget.onUpdate(
                  attachmentId: attachmentId,
                  caption: caption,
                  altText: altText,
                  displayOrder: displayOrder,
                  isPrimary: isPrimary,
                );
                setState(() => _editing = null);
              },
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: widget.isMutating ? null : _pickAttachmentImage,
          icon: const Icon(Icons.image_outlined),
          label: Text(l10n.qbUploadAttachment),
        ),
        const SizedBox(height: 16),
        if (widget.attachments.isEmpty)
          Text(l10n.questionBankEmptyMessage)
        else ...[
          QuestionAttachmentReorderList(
            attachments: widget.attachments,
            onReorder: widget.onReorder,
          ),
          const SizedBox(height: 8),
          ...widget.attachments.map(
            (attachment) => Card(
              child: ListTile(
                onTap: attachment.imageUrl == null
                    ? null
                    : () => _showAttachmentPreview(context, attachment),
                leading: attachment.imageUrl == null
                    ? const Icon(Icons.attach_file_rounded)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          attachment.imageUrl!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image_outlined),
                        ),
                      ),
                title: Text(
                  attachment.caption ??
                      '${l10n.attachments} ${attachment.attachmentId}',
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  attachment.altText ?? attachment.fileId.toString(),
                ),
                trailing: Wrap(
                  spacing: 4,
                  children: [
                    IconButton(
                      onPressed: () => setState(() => _editing = attachment),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      tooltip: l10n.qbRemoveAttachment,
                      onPressed: () => _confirmRemove(context, attachment),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _pickAttachmentImage() async {
    final picked = await FilePicker.platform.pickFiles(type: FileType.image);
    final path = picked?.files.single.path;
    if (path != null) widget.onUploadImage(path);
  }

  Future<void> _confirmRemove(
    BuildContext context,
    QuestionBankAttachmentModel attachment,
  ) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.qbRemoveAttachment),
        content: Text(
          attachment.caption ??
              '${l10n.attachments} ${attachment.attachmentId}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.qbRemoveAttachment),
          ),
        ],
      ),
    );
    if (ok == true) widget.onRemove(attachment.attachmentId);
  }

  Future<void> _showAttachmentPreview(
    BuildContext context,
    QuestionBankAttachmentModel attachment,
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
                        attachment.caption ??
                            '${l10n.attachments} ${attachment.attachmentId}',
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
