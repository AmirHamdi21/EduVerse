import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/question_bank/question_bank_attachment_model.dart';

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
    final l10n = AppLocalizations.of(context);
    return ReorderableListView.builder(
      shrinkWrap: true,
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
        return ListTile(
          key: ValueKey(attachment.attachmentId),
          leading: const Icon(Icons.drag_indicator_rounded),
          title: Text(attachment.caption ?? '${l10n.attachments} ${index + 1}'),
          subtitle: Text('${l10n.qbDisplayOrder}: ${attachment.displayOrder}'),
        );
      },
    );
  }
}
