import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/exams/exam_shortage_model.dart';
import '../../../models/question_bank/course_chapter_model.dart';
import '../shared/instructor_colors.dart';

class ExamShortagePanel extends StatelessWidget {
  const ExamShortagePanel({
    super.key,
    required this.shortages,
    this.chapters = const <CourseChapterModel>[],
  });

  final List<ExamShortageModel> shortages;
  final List<CourseChapterModel> chapters;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (shortages.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: InstructorColors.warning.withValues(alpha: isDark ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: InstructorColors.warning.withValues(alpha: 0.24),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: InstructorColors.warning.withValues(
                alpha: isDark ? 0.18 : 0.12,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: InstructorColors.warning,
              size: 21,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.examShortageTitle,
                  style: TextStyle(
                    color: InstructorColors.textPrimaryColor(isDark),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                for (final shortage in shortages)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      _shortageText(l10n, shortage),
                      style: TextStyle(
                        color: InstructorColors.textSecondaryColor(isDark),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _shortageText(AppLocalizations l10n, ExamShortageModel shortage) {
    final chapter = chapters
        .where((item) => item.id == shortage.chapterId)
        .firstOrNull;
    final label = chapter == null
        ? '${l10n.chapter} ${shortage.chapterId}'
        : '${chapter.name} • ${chapter.chapterOrder}';
    return l10n.examShortageNamedLine(
      label,
      shortage.required,
      shortage.available,
    );
  }
}
