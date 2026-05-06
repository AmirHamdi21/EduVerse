import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';

class ExamDraftEditorToolbar extends StatelessWidget {
  const ExamDraftEditorToolbar({
    super.key,
    required this.canEdit,
    required this.onAddSection,
    required this.onAddQuestion,
    required this.onSave,
  });

  final bool canEdit;
  final VoidCallback onAddSection;
  final VoidCallback onAddQuestion;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        FilledButton.icon(
          onPressed: canEdit ? onAddSection : null,
          icon: const Icon(Icons.view_agenda_outlined),
          label: Text(l10n.examCreateSection),
        ),
        FilledButton.icon(
          onPressed: canEdit ? onAddQuestion : null,
          icon: const Icon(Icons.add_rounded),
          label: Text(l10n.examAddQuestion),
        ),
        OutlinedButton.icon(
          onPressed: onSave,
          icon: const Icon(Icons.save_outlined),
          label: Text(l10n.save),
        ),
      ],
    );
  }
}
