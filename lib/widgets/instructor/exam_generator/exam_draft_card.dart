import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/exams/exam_draft_model.dart';
import 'exam_generator_localized_labels.dart';

class ExamDraftCard extends StatelessWidget {
  const ExamDraftCard({super.key, required this.draft, required this.onTap});

  final ExamDraftModel draft;
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
          backgroundColor: Color(0xFFEFF6FF),
          child: Icon(Icons.description_outlined, color: Color(0xFF2563EB)),
        ),
        title: Text(draft.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${draft.items.length} ${l10n.questions} • ${localizedDraftStatus(l10n, draft.status)}',
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
