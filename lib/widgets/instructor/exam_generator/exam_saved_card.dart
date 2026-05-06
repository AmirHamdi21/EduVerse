import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/exams/exam_response_model.dart';
import 'exam_generator_localized_labels.dart';

class ExamSavedCard extends StatelessWidget {
  const ExamSavedCard({super.key, required this.exam, required this.onTap});

  final ExamResponseModel exam;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFECFDF5),
          child: Icon(Icons.fact_check_outlined, color: Color(0xFF059669)),
        ),
        title: Text(exam.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${localizedExamStatus(l10n, exam.status)} • ${exam.totalMarks ?? 0} ${l10n.examMarks}',
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
