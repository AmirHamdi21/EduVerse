import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../common/utils/student_course_filters.dart';
import '../../../common/utils/student_courses_theme.dart';
import '../../../generated_l10n/app_localizations.dart';

class CourseFilterBar extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final int? selectedSemesterId;
  final List<SemesterFilterOption> semesterOptions;
  final ValueChanged<int?> onSemesterChanged;
  final bool showStatusTabs;

  const CourseFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.selectedSemesterId,
    required this.semesterOptions,
    required this.onSemesterChanged,
    this.showStatusTabs = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.coursesShellSemesterLabel,
              style: TextStyle(
                color: StudentCoursesTheme.secondaryText(isDark),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (showStatusTabs) ...[
                    _buildChip(
                      label: l10n.all,
                      selected: selectedFilter == 'all',
                      isDark: isDark,
                      isPrimary: true,
                      onTap: () => onFilterChanged('all'),
                    ),
                    const SizedBox(width: 10),
                    _buildChip(
                      label: l10n.active,
                      selected: selectedFilter == 'active',
                      isDark: isDark,
                      onTap: () => onFilterChanged('active'),
                    ),
                    const SizedBox(width: 10),
                    _buildChip(
                      label: l10n.completed,
                      selected: selectedFilter == 'completed',
                      isDark: isDark,
                      onTap: () => onFilterChanged('completed'),
                    ),
                    const SizedBox(width: 10),
                    _buildChip(
                      label: l10n.studentCourseDropped,
                      selected: selectedFilter == 'dropped',
                      isDark: isDark,
                      onTap: () => onFilterChanged('dropped'),
                    ),
                    const SizedBox(width: 10),
                  ],
                  _buildChip(
                    label: l10n.allSemesters,
                    selected: selectedSemesterId == null,
                    isDark: isDark,
                    onTap: () => onSemesterChanged(null),
                  ),
                  ...semesterOptions.expand(
                    (option) => [
                      const SizedBox(width: 10),
                      _buildChip(
                        label: option.label,
                        selected: selectedSemesterId == option.id,
                        isDark: isDark,
                        onTap: () => onSemesterChanged(option.id),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChip({
    required String label,
    required bool selected,
    required bool isDark,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    final Color labelColor = selected
        ? (isPrimary ? Colors.white : StudentCoursesTheme.brandBlue)
        : StudentCoursesTheme.primaryText(isDark);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: StudentCoursesTheme.controlAnimationDuration,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected && isPrimary
              ? StudentCoursesTheme.primaryGradient
              : null,
          color: selected && !isPrimary
              ? StudentCoursesTheme.chipSelectedBackground(isDark)
              : StudentCoursesTheme.cardBackground(isDark),
          borderRadius: StudentCoursesTheme.pillRadius,
          border: Border.all(
            color: selected && !isPrimary
                ? StudentCoursesTheme.brandBlue
                : StudentCoursesTheme.borderColor(isDark),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: StudentCoursesTheme.brandBlue.withValues(
                      alpha: 0.18,
                    ),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
