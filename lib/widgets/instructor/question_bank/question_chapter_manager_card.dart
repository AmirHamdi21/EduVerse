import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/question_bank/course_chapter_model.dart';

class QuestionChapterManagerCard extends StatelessWidget {
  const QuestionChapterManagerCard({
    super.key,
    required this.chapters,
    required this.onCreate,
    required this.onEdit,
    required this.onDelete,
    this.questionCounts = const <int, int>{},
  });

  final List<CourseChapterModel> chapters;
  final Map<int, int> questionCounts;
  final VoidCallback onCreate;
  final ValueChanged<CourseChapterModel> onEdit;
  final ValueChanged<CourseChapterModel> onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.qbManageChapters,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.add_rounded),
                label: Text(l10n.qbCreateChapter),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (chapters.isEmpty)
            Text(l10n.questionBankEmptyMessage)
          else
            ...chapters.map((chapter) {
              final questionCount = questionCounts[chapter.id] ?? 0;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  child: Text(chapter.chapterOrder.toString()),
                ),
                title: Text(chapter.name),
                subtitle: Text(
                  [
                    chapter.isActive
                        ? l10n.qbChapterActive
                        : l10n.qbChapterInactive,
                    l10n.qbChapterQuestionCount(questionCount),
                  ].join(' • '),
                ),
                trailing: Wrap(
                  spacing: 4,
                  children: [
                    IconButton(
                      onPressed: () => onEdit(chapter),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      tooltip: questionCount > 0
                          ? l10n.qbChapterDeleteBlocked
                          : l10n.qbDeleteChapter,
                      onPressed: questionCount > 0
                          ? null
                          : () => onDelete(chapter),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
