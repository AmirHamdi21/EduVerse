import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/exams/exam_draft_section_model.dart';
import '../shared/instructor_colors.dart';

class ExamDraftSectionCard extends StatelessWidget {
  const ExamDraftSectionCard({
    super.key,
    required this.section,
    required this.children,
  });

  final ExamDraftSectionModel section;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: InstructorColors.primary.withValues(
                alpha: isDark ? 0.14 : 0.06,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: InstructorColors.primary.withValues(
                      alpha: isDark ? 0.2 : 0.1,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.view_agenda_outlined,
                    color: InstructorColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: InstructorColors.textPrimaryColor(isDark),
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 7,
                        runSpacing: 7,
                        children: [
                          _Pill(
                            icon: Icons.sort_rounded,
                            label: l10n.examOrderNumber(
                              section.sectionOrder + 1,
                            ),
                            color: InstructorColors.primary,
                          ),
                          if (section.totalMarks != null)
                            _Pill(
                              icon: Icons.score_outlined,
                              label: '${section.totalMarks} ${l10n.examMarks}',
                              color: InstructorColors.orange,
                            ),
                          _Pill(
                            icon: Icons.checklist_rounded,
                            label: section.answerPolicy.value,
                            color: InstructorColors.teal,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (section.instructions != null &&
              section.instructions!.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Text(
                section.instructions!,
                style: TextStyle(
                  color: InstructorColors.textSecondaryColor(isDark),
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: InstructorColors.textSecondaryColor(isDark),
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
