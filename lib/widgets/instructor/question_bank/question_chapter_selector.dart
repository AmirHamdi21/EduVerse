import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/question_bank/course_chapter_model.dart';
import '../shared/instructor_colors.dart';
import 'question_form_menu_field.dart';

class QuestionChapterSelector extends StatelessWidget {
  const QuestionChapterSelector({
    super.key,
    required this.value,
    required this.chapters,
    required this.onChanged,
    required this.onCreateChapter,
  });

  final int? value;
  final List<CourseChapterModel> chapters;
  final ValueChanged<int?> onChanged;
  final VoidCallback onCreateChapter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 430;
        final dropdown = QuestionFormMenuField<int>(
          label: l10n.chapter,
          value: value,
          icon: Icons.menu_book_outlined,
          color: InstructorColors.primary,
          options: chapters
              .map(
                (chapter) => QuestionFormMenuOption<int>(
                  value: chapter.id,
                  label: chapter.name,
                  icon: Icons.bookmark_border_rounded,
                ),
              )
              .toList(),
          onChanged: onChanged,
          enabled: chapters.isNotEmpty,
        );
        final createButton = OutlinedButton.icon(
          onPressed: onCreateChapter,
          style: OutlinedButton.styleFrom(
            backgroundColor: InstructorColors.teal.withValues(
              alpha: isDark ? 0.18 : 0.08,
            ),
            foregroundColor: InstructorColors.teal,
            side: BorderSide(
              color: InstructorColors.teal.withValues(alpha: 0.24),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.add_rounded),
          label: Text(
            l10n.qbCreateChapter,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [dropdown, const SizedBox(height: 10), createButton],
          );
        }
        return Row(
          children: [
            Expanded(child: dropdown),
            const SizedBox(width: 10),
            SizedBox(width: 174, height: 56, child: createButton),
          ],
        );
      },
    );
  }
}
