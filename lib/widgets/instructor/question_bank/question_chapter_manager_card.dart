import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/question_bank/course_chapter_model.dart';
import '../shared/instructor_colors.dart';

class QuestionChapterManagerCard extends StatelessWidget {
  const QuestionChapterManagerCard({
    super.key,
    required this.chapters,
    required this.onCreate,
    required this.onEdit,
    required this.onDelete,
    this.questionCounts = const <int, int>{},
    this.totalChapters,
  });

  final List<CourseChapterModel> chapters;
  final int? totalChapters;
  final Map<int, int> questionCounts;
  final VoidCallback onCreate;
  final ValueChanged<CourseChapterModel> onEdit;
  final ValueChanged<CourseChapterModel> onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.055),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: InstructorColors.teal.withValues(
                    alpha: isDark ? 0.2 : 0.1,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.library_books_outlined,
                  color: InstructorColors.teal,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.qbManageChapters,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: InstructorColors.textPrimaryColor(isDark),
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.qbChapterCount(totalChapters ?? chapters.length),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: InstructorColors.textSecondaryColor(isDark),
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              // IconButton(
              //   tooltip: l10n.qbCreateChapter,
              //   onPressed: onCreate,
              //   style: IconButton.styleFrom(
              //     backgroundColor: InstructorColors.primary,
              //     foregroundColor: Colors.white,
              //     fixedSize: const Size(44, 44),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(16),
              //     ),
              //   ),
              //   icon: const Icon(Icons.add_rounded),
              // ),
            ],
          ),
          const SizedBox(height: 14),
          if (chapters.isEmpty)
            _EmptyChapters(onCreate: onCreate)
          else
            ...chapters.map(
              (chapter) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ChapterTile(
                  chapter: chapter,
                  questionCount: questionCounts[chapter.id] ?? 0,
                  onEdit: () => onEdit(chapter),
                  onDelete: () => onDelete(chapter),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ChapterTile extends StatelessWidget {
  const _ChapterTile({
    required this.chapter,
    required this.questionCount,
    required this.onEdit,
    required this.onDelete,
  });

  final CourseChapterModel chapter;
  final int questionCount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = chapter.isActive
        ? InstructorColors.success
        : InstructorColors.textTertiaryColor(isDark);
    final canDelete = questionCount == 0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: InstructorColors.surfaceColor(isDark),
          border: Border.all(color: InstructorColors.borderColor(isDark)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 5,
                color: chapter.isActive
                    ? InstructorColors.teal
                    : InstructorColors.textTertiaryColor(isDark),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 10, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: InstructorColors.primary.withValues(
                            alpha: isDark ? 0.2 : 0.1,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          chapter.chapterOrder.toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: InstructorColors.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              chapter.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: InstructorColors.textPrimaryColor(
                                  isDark,
                                ),
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _InfoPill(
                                  label: chapter.isActive
                                      ? l10n.qbChapterActive
                                      : l10n.qbChapterInactive,
                                  icon: chapter.isActive
                                      ? Icons.check_circle_outline_rounded
                                      : Icons.pause_circle_outline_rounded,
                                  color: statusColor,
                                ),
                                _InfoPill(
                                  label: l10n.qbChapterQuestionCount(
                                    questionCount,
                                  ),
                                  icon: Icons.quiz_outlined,
                                  color: InstructorColors.primary,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: l10n.edit,
                            onPressed: onEdit,
                            style: IconButton.styleFrom(
                              backgroundColor: InstructorColors.primary
                                  .withValues(alpha: isDark ? 0.18 : 0.09),
                              foregroundColor: InstructorColors.primary,
                              fixedSize: const Size(40, 40),
                            ),
                            icon: const Icon(Icons.edit_outlined, size: 20),
                          ),
                          const SizedBox(height: 6),
                          IconButton(
                            tooltip: canDelete
                                ? l10n.qbDeleteChapter
                                : l10n.qbChapterDeleteBlocked,
                            onPressed: canDelete ? onDelete : null,
                            style: IconButton.styleFrom(
                              backgroundColor: InstructorColors.error
                                  .withValues(alpha: isDark ? 0.18 : 0.09),
                              disabledBackgroundColor:
                                  InstructorColors.textTertiaryColor(
                                    isDark,
                                  ).withValues(alpha: 0.1),
                              foregroundColor: InstructorColors.error,
                              disabledForegroundColor:
                                  InstructorColors.textTertiaryColor(isDark),
                              fixedSize: const Size(40, 40),
                            ),
                            icon: const Icon(Icons.delete_outline, size: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChapters extends StatelessWidget {
  const _EmptyChapters({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: InstructorColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: InstructorColors.primary.withValues(
                alpha: isDark ? 0.2 : 0.1,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.menu_book_outlined,
              color: InstructorColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.qbManageChapters,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: InstructorColors.textPrimaryColor(isDark),
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.qbNoChaptersMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: InstructorColors.textSecondaryColor(isDark),
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onCreate,
              style: FilledButton.styleFrom(
                backgroundColor: InstructorColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.qbCreateChapter),
            ),
          ),
        ],
      ),
    );
  }
}
