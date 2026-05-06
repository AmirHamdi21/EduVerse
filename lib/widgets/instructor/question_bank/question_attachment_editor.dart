import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/question_bank/question_bank_attachment_model.dart';

class QuestionAttachmentEditor extends StatelessWidget {
  const QuestionAttachmentEditor({
    super.key,
    required this.attachments,
    this.onUpload,
    this.onRemove,
  });

  final List<QuestionBankAttachmentModel> attachments;
  final VoidCallback? onUpload;
  final ValueChanged<QuestionBankAttachmentModel>? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final attachment in attachments)
              Container(
                width: 150,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (attachment.imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          attachment.imageUrl!,
                          height: 80,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image_not_supported_outlined),
                        ),
                      )
                    else
                      const Icon(Icons.attach_file_rounded),
                    Text(
                      attachment.caption ?? attachment.attachmentType.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (onRemove != null)
                      TextButton.icon(
                        onPressed: () => onRemove!(attachment),
                        icon: const Icon(Icons.delete_outline),
                        label: Text(l10n.qbRemoveAttachment),
                      ),
                  ],
                ),
              ),
          ],
        ),
        if (onUpload != null) ...[
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onUpload,
            icon: const Icon(Icons.upload_file_rounded),
            label: Text(l10n.qbUploadAttachment),
          ),
        ],
      ],
    );
  }
}
