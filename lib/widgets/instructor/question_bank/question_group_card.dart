import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/question_bank/question_bank_group_model.dart';
import 'question_bank_localized_labels.dart';
import 'question_text_renderer.dart';

class QuestionGroupCard extends StatelessWidget {
  const QuestionGroupCard({
    super.key,
    required this.group,
    required this.onTap,
  });

  final QuestionBankGroupModel group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          child: Icon(
            group.sharedFileId == null
                ? Icons.folder_copy_outlined
                : Icons.image_outlined,
          ),
        ),
        title: Text(group.title ?? l10n.questionBankGroupDetails),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n.type}: ${localizedGroupType(l10n, group.groupType)}'),
            Text(
              '${l10n.questions}: ${group.totalQuestions} • ${l10n.approved}: ${group.approvedQuestions}',
            ),
            if (group.sharedPrompt != null)
              QuestionFormattedText(
                text: group.sharedPrompt,
                fallback: '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
