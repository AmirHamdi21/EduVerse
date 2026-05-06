import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/exams/exam_generation_form_model.dart';

class ExamGenerationModeToggle extends StatelessWidget {
  const ExamGenerationModeToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ExamGenerationMode value;
  final ValueChanged<ExamGenerationMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<ExamGenerationMode>(
          segments: [
            ButtonSegment(
              value: ExamGenerationMode.flat,
              icon: const Icon(Icons.rule_outlined),
              label: Text(l10n.examSimpleMode),
            ),
            ButtonSegment(
              value: ExamGenerationMode.sectioned,
              icon: const Icon(Icons.view_agenda_outlined),
              label: Text(l10n.examSectionedMode),
            ),
          ],
          selected: {value},
          onSelectionChanged: (set) => onChanged(set.first),
        ),
        const SizedBox(height: 8),
        Text(
          value == ExamGenerationMode.flat
              ? l10n.examSimpleModeHelp
              : l10n.examSectionedModeHelp,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
