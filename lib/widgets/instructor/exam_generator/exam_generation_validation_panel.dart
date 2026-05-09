import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import 'exam_generator_localized_labels.dart';

class ExamGenerationValidationPanel extends StatelessWidget {
  const ExamGenerationValidationPanel({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        localizedExamMessage(l10n, message!),
        style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
      ),
    );
  }
}
