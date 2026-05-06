import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/question_bank/course_chapter_model.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<int>(
          isExpanded: true,
          initialValue: value,
          decoration: InputDecoration(
            labelText: l10n.chapter,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
          items: chapters
              .map((chapter) => DropdownMenuItem<int>(
                    value: chapter.id,
                    child: Text(chapter.name, overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: onCreateChapter,
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.qbCreateChapter),
          ),
        ),
      ],
    );
  }
}
