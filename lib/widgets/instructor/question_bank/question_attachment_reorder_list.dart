import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/question_bank/question_bank_attachment_model.dart';
import '../shared/instructor_colors.dart';

class QuestionAttachmentReorderList extends StatelessWidget {
  const QuestionAttachmentReorderList({
    super.key,
    required this.attachments,
    required this.onReorder,
  });

  final List<QuestionBankAttachmentModel> attachments;
  final ValueChanged<List<int>> onReorder;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      buildDefaultDragHandles: false,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: attachments.length,
      onReorder: (oldIndex, newIndex) {
        final ids = attachments.map((item) => item.attachmentId).toList();
        final target = newIndex > oldIndex ? newIndex - 1 : newIndex;
        final moved = ids.removeAt(oldIndex);
        ids.insert(target, moved);
        onReorder(ids);
      },
      itemBuilder: (context, index) {
        final attachment = attachments[index];
        return _ReorderAttachmentTile(
          key: ValueKey(attachment.attachmentId),
          attachment: attachment,
          index: index,
        );
      },
    );
  }
}

class _ReorderAttachmentTile extends StatelessWidget {
  const _ReorderAttachmentTile({
    super.key,
    required this.attachment,
    required this.index,
  });

  final QuestionBankAttachmentModel attachment;
  final int index;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: InstructorColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index,
            child: Icon(
              Icons.drag_indicator_rounded,
              color: InstructorColors.textSecondaryColor(isDark),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: InstructorColors.primary.withValues(
                alpha: isDark ? 0.2 : 0.1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: InstructorColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
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
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${l10n.qbDisplayOrder}: ${attachment.displayOrder}',
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
        ],
      ),
    );
  }
}
