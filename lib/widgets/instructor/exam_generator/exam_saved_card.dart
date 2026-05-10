import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/exams/exam_generator_enums.dart';
import '../../../models/exams/exam_response_model.dart';
import '../shared/instructor_colors.dart';
import 'exam_generator_localized_labels.dart';

class ExamSavedCard extends StatelessWidget {
  const ExamSavedCard({
    super.key,
    required this.exam,
    required this.onTap,
    this.onLongPress,
    this.courseLabel,
    this.selectionMode = false,
    this.selected = false,
  });

  final ExamResponseModel exam;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final String? courseLabel;
  final bool selectionMode;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _examColor(exam.status);
    final status = _localizedSavedExamStatus(l10n, exam.status);
    final subtitle = courseLabel?.trim().isNotEmpty == true
        ? courseLabel!.trim()
        : '${l10n.course} ${exam.courseId}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                color: InstructorColors.cardColor(isDark),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? InstructorColors.primary
                      : InstructorColors.borderColor(isDark),
                  width: selected ? 1.6 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Container(width: 5, color: color),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: color.withValues(
                                      alpha: isDark ? 0.18 : 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Icon(
                                    Icons.fact_check_outlined,
                                    color: color,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _RecordBadge(
                                        label: l10n.examSavedRecordBadge,
                                        color: InstructorColors.success,
                                        isDark: isDark,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        exam.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color:
                                              InstructorColors.textPrimaryColor(
                                                isDark,
                                              ),
                                          fontSize: 17,
                                          fontWeight: FontWeight.w900,
                                          height: 1.15,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        subtitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color:
                                              InstructorColors.textSecondaryColor(
                                                isDark,
                                              ),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  selectionMode
                                      ? (selected
                                            ? Icons.check_circle_rounded
                                            : Icons.radio_button_unchecked)
                                      : Icons.chevron_right_rounded,
                                  color: selected
                                      ? InstructorColors.primary
                                      : InstructorColors.textTertiaryColor(
                                          isDark,
                                        ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _InfoPill(
                                  icon: Icons.radio_button_checked_rounded,
                                  label: status,
                                  color: color,
                                  isDark: isDark,
                                ),
                                _InfoPill(
                                  icon: Icons.quiz_outlined,
                                  label:
                                      '${exam.itemCount ?? 0} ${l10n.questions}',
                                  color: InstructorColors.teal,
                                  isDark: isDark,
                                ),
                                _InfoPill(
                                  icon: Icons.view_agenda_outlined,
                                  label:
                                      '${exam.sectionCount ?? 0} ${l10n.sections}',
                                  color: InstructorColors.accent,
                                  isDark: isDark,
                                ),
                                if (exam.totalMarks != null)
                                  _InfoPill(
                                    icon: Icons.grade_outlined,
                                    label:
                                        '${_formatNumber(exam.totalMarks!)} ${l10n.examMarks}',
                                    color: InstructorColors.orange,
                                    isDark: isDark,
                                  ),
                                if (exam.publishedAt != null)
                                  _InfoPill(
                                    icon: Icons.campaign_outlined,
                                    label: _formatDate(exam.publishedAt!),
                                    color: InstructorColors.info,
                                    isDark: isDark,
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
          ),
        ),
      ),
    );
  }

  Color _examColor(ExamStatus status) {
    switch (status) {
      case ExamStatus.draft:
        return InstructorColors.primary;
      case ExamStatus.published:
        return InstructorColors.success;
      case ExamStatus.archived:
        return InstructorColors.warning;
    }
  }
}

class _RecordBadge extends StatelessWidget {
  const _RecordBadge({
    required this.label,
    required this.color,
    required this.isDark,
  });

  final String label;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

String _localizedSavedExamStatus(AppLocalizations l10n, ExamStatus status) {
  if (status == ExamStatus.draft) return l10n.examSavedDraftStatus;
  return localizedExamStatus(l10n, status);
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 30),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final local = date.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$month-$day';
}

String _formatNumber(num value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toStringAsFixed(1);
}
