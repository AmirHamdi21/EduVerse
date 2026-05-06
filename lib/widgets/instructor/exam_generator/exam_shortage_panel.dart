import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/exams/exam_shortage_model.dart';

class ExamShortagePanel extends StatelessWidget {
  const ExamShortagePanel({super.key, required this.shortages});

  final List<ExamShortageModel> shortages;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (shortages.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF97316)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.examShortageTitle,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          for (final shortage in shortages)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                l10n.examShortageLine(
                  shortage.chapterId,
                  shortage.required,
                  shortage.available,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
