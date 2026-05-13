import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/question_bank/question_bank_attachment_model.dart';
import '../../../models/question_bank/question_bank_enums.dart';
import '../shared/instructor_colors.dart';
import 'question_attachment_form_card.dart';
import 'question_attachment_reorder_list.dart';
import 'question_bank_localized_labels.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AttachmentIntroCard(
          count: widget.attachments.length,
          isBusy: widget.isMutating,
          onUpload: _pickAttachmentImage,
        ),
        if (_editing != null) ...[
          const SizedBox(height: 12),
          QuestionAttachmentFormCard(
            key: ValueKey(_editing!.attachmentId),
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
            onCancel: () => setState(() => _editing = null),
          ),
        ],
        const SizedBox(height: 12),
        if (widget.attachments.isEmpty)
          _AttachmentEmptyState(
            isBusy: widget.isMutating,
            onUpload: _pickAttachmentImage,
          )
        else ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: InstructorColors.cardColor(isDark),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: InstructorColors.borderColor(isDark)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _AttachmentIcon(
                      icon: Icons.drag_indicator_rounded,
                      color: InstructorColors.accent,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.qbReorderAttachments,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: InstructorColors.textPrimaryColor(isDark),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                QuestionAttachmentReorderList(
                  attachments: widget.attachments,
                  onReorder: widget.onReorder,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...widget.attachments.map(
            (attachment) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _AttachmentTile(
                attachment: attachment,
                onPreview: attachment.imageUrl == null
                    ? null
                    : () => _showAttachmentPreview(context, attachment),
                onEdit: () => setState(() => _editing = attachment),
                onRemove: () => _confirmRemove(context, attachment),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: InstructorColors.cardColor(isDark),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: InstructorColors.borderColor(isDark)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _AttachmentIcon(
                    icon: Icons.delete_outline_rounded,
                    color: InstructorColors.error,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.qbRemoveAttachment,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: InstructorColors.textPrimaryColor(isDark),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                attachment.caption ??
                    '${l10n.attachments} ${attachment.attachmentId}',
                style: TextStyle(
                  color: InstructorColors.textSecondaryColor(isDark),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: InstructorColors.error,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: Text(l10n.qbRemoveAttachment),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (ok == true) widget.onRemove(attachment.attachmentId);
  }

  Future<void> _showAttachmentPreview(
    BuildContext context,
    QuestionBankAttachmentModel attachment,
  ) async {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(18),
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 760, maxHeight: 760),
          decoration: BoxDecoration(
            color: InstructorColors.cardColor(isDark),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: InstructorColors.borderColor(isDark)),
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
                        attachment.caption ??
                            '${l10n.attachments} ${attachment.attachmentId}',
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

class _AttachmentIntroCard extends StatelessWidget {
  const _AttachmentIntroCard({
    required this.count,
    required this.isBusy,
    required this.onUpload,
  });

  final int count;
  final bool isBusy;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 390;
          final title = Row(
            children: [
              _AttachmentIcon(
                icon: Icons.attach_file_rounded,
                color: InstructorColors.cyan,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.attachments,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: InstructorColors.textPrimaryColor(isDark),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.qbAttachmentCount(count),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: InstructorColors.textSecondaryColor(isDark),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
          final upload = count == 0
              ? null
              : FilledButton.icon(
                  onPressed: isBusy ? null : onUpload,
                  style: FilledButton.styleFrom(
                    backgroundColor: InstructorColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.upload_rounded),
                  label: Text(
                    l10n.qbUploadAttachment,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                title,
                if (upload != null) ...[const SizedBox(height: 12), upload],
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: title),
              if (upload != null) ...[
                const SizedBox(width: 10),
                Flexible(child: upload),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _AttachmentTile extends StatelessWidget {
  const _AttachmentTile({
    required this.attachment,
    required this.onEdit,
    required this.onRemove,
    this.onPreview,
  });

  final QuestionBankAttachmentModel attachment;
  final VoidCallback? onPreview;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _attachmentColor(attachment.attachmentType);
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onPreview,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: InstructorColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: InstructorColors.borderColor(isDark)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 58,
                height: 58,
                color: color.withValues(alpha: isDark ? 0.2 : 0.1),
                child: attachment.imageUrl == null
                    ? Icon(
                        _attachmentIcon(attachment.attachmentType),
                        color: color,
                      )
                    : Image.network(
                        attachment.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Icon(Icons.broken_image_outlined, color: color),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attachment.caption ??
                        '${l10n.attachments} ${attachment.attachmentId}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: InstructorColors.textPrimaryColor(isDark),
                      fontSize: 15.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _AttachmentPill(
                        label: localizedAttachmentType(
                          l10n,
                          attachment.attachmentType,
                        ),
                        icon: _attachmentIcon(attachment.attachmentType),
                        color: color,
                      ),
                      if (attachment.isPrimary)
                        _AttachmentPill(
                          label: l10n.qbPrimaryAttachment,
                          icon: Icons.star_rounded,
                          color: InstructorColors.warning,
                        ),
                      _AttachmentPill(
                        label:
                            '${l10n.qbDisplayOrder} ${attachment.displayOrder}',
                        icon: Icons.format_list_numbered_rounded,
                        color: InstructorColors.accent,
                      ),
                    ],
                  ),
                  if (attachment.altText?.trim().isNotEmpty == true) ...[
                    const SizedBox(height: 7),
                    Text(
                      attachment.altText!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: InstructorColors.textSecondaryColor(isDark),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: l10n.edit,
                  onPressed: onEdit,
                  style: IconButton.styleFrom(
                    backgroundColor: InstructorColors.primary.withValues(
                      alpha: isDark ? 0.18 : 0.1,
                    ),
                    foregroundColor: InstructorColors.primary,
                    fixedSize: const Size(40, 40),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 20),
                ),
                const SizedBox(height: 6),
                IconButton(
                  tooltip: l10n.qbRemoveAttachment,
                  onPressed: onRemove,
                  style: IconButton.styleFrom(
                    backgroundColor: InstructorColors.error.withValues(
                      alpha: isDark ? 0.18 : 0.1,
                    ),
                    foregroundColor: InstructorColors.error,
                    fixedSize: const Size(40, 40),
                  ),
                  icon: const Icon(Icons.delete_outline, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentEmptyState extends StatelessWidget {
  const _AttachmentEmptyState({required this.isBusy, required this.onUpload});

  final bool isBusy;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Column(
        children: [
          _AttachmentIcon(
            icon: Icons.attach_file_rounded,
            color: InstructorColors.cyan,
            size: 54,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.qbNoAttachments,
            style: TextStyle(
              color: InstructorColors.textPrimaryColor(isDark),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.qbNoAttachmentsMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: InstructorColors.textSecondaryColor(isDark),
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isBusy ? null : onUpload,
              icon: isBusy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload_rounded),
              label: Text(l10n.qbUploadAttachment),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentIcon extends StatelessWidget {
  const _AttachmentIcon({
    required this.icon,
    required this.color,
    this.size = 42,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(icon, color: color, size: size * 0.48),
    );
  }
}

class _AttachmentPill extends StatelessWidget {
  const _AttachmentPill({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

IconData _attachmentIcon(QuestionAttachmentType type) {
  switch (type) {
    case QuestionAttachmentType.audio:
      return Icons.graphic_eq_rounded;
    case QuestionAttachmentType.document:
      return Icons.description_outlined;
    case QuestionAttachmentType.image:
      return Icons.image_outlined;
    case QuestionAttachmentType.video:
      return Icons.play_circle_outline_rounded;
  }
}

Color _attachmentColor(QuestionAttachmentType type) {
  switch (type) {
    case QuestionAttachmentType.audio:
      return InstructorColors.orange;
    case QuestionAttachmentType.document:
      return InstructorColors.primary;
    case QuestionAttachmentType.image:
      return InstructorColors.cyan;
    case QuestionAttachmentType.video:
      return InstructorColors.accent;
  }
}
