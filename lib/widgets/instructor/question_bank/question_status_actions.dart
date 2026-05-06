import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/question_bank/question_bank_enums.dart';

class QuestionStatusActions extends StatelessWidget {
  const QuestionStatusActions({
    super.key,
    required this.status,
    required this.onAction,
  });

  final QuestionBankStatus status;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final actions = <Widget>[
      if (status == QuestionBankStatus.draft ||
          status == QuestionBankStatus.rejected)
        FilledButton.icon(
          onPressed: () => onAction('submit-for-review'),
          icon: const Icon(Icons.send_outlined),
          label: Text(l10n.qbSubmit),
        ),
      if (status == QuestionBankStatus.draft ||
          status == QuestionBankStatus.underReview)
        FilledButton.icon(
          onPressed: () => onAction('approve'),
          icon: const Icon(Icons.verified_outlined),
          label: Text(l10n.qbApprove),
        ),
      if (status == QuestionBankStatus.underReview)
        OutlinedButton.icon(
          onPressed: () => onAction('reject'),
          icon: const Icon(Icons.undo_rounded),
          label: Text(l10n.qbReject),
        ),
      if (status != QuestionBankStatus.archived)
        OutlinedButton.icon(
          onPressed: () => onAction('archive'),
          icon: const Icon(Icons.archive_outlined),
          label: Text(l10n.qbArchive),
        ),
      if (status == QuestionBankStatus.archived)
        FilledButton.icon(
          onPressed: () => onAction('restore'),
          icon: const Icon(Icons.restore_rounded),
          label: Text(l10n.qbRestore),
        ),
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: actions,
    );
  }
}
