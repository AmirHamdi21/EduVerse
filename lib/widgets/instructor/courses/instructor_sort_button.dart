import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../common/utils/instructor_courses_theme.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/instructor/extended_course_model.dart';

class InstructorSortButton extends StatelessWidget {
  final CourseSortOption selectedSort;
  final ValueChanged<CourseSortOption> onSortChanged;

  const InstructorSortButton({
    super.key,
    required this.selectedSort,
    required this.onSortChanged,
  });

  String _label(AppLocalizations l10n) {
    switch (selectedSort) {
      case CourseSortOption.oldest:
        return l10n.oldestFirst;
      case CourseSortOption.mostStudents:
        return 'Most students';
      case CourseSortOption.leastStudents:
        return 'Least students';
      case CourseSortOption.alphabetical:
        return 'A-Z';
      case CourseSortOption.reverseAlphabetical:
        return 'Z-A';
      case CourseSortOption.mostEngagement:
        return 'Top engagement';
      case CourseSortOption.newest:
        return l10n.newestFirst;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return PopupMenuButton<CourseSortOption>(
          tooltip: l10n.sortBy,
          position: PopupMenuPosition.under,
          offset: const Offset(0, 8),
          padding: EdgeInsets.zero,
          color: InstructorCoursesTheme.elevatedCardBackground(isDark),
          surfaceTintColor: Colors.transparent,
          elevation: 14,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: InstructorCoursesTheme.borderColor(isDark)),
          ),
          onSelected: onSortChanged,
          itemBuilder: (context) => CourseSortOption.values
              .map(
                (option) => PopupMenuItem<CourseSortOption>(
                  value: option,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _labelForOption(option, l10n),
                          style: TextStyle(
                            color: selectedSort == option
                                ? InstructorCoursesTheme.brandBlue
                                : InstructorCoursesTheme.primaryText(isDark),
                            fontSize: 14,
                            fontWeight: selectedSort == option
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        selectedSort == option
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        color: selectedSort == option
                            ? InstructorCoursesTheme.brandBlue
                            : InstructorCoursesTheme.secondaryText(isDark),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              )
              .toList(growable: false),
          child: _MenuCard(
            isDark: isDark,
            title: l10n.sortBy,
            subtitle: _label(l10n),
            icon: Icons.swap_vert_rounded,
            color: InstructorCoursesTheme.brandBlue,
            isActive: selectedSort != CourseSortOption.newest,
          ),
        );
      },
    );
  }

  String _labelForOption(CourseSortOption option, AppLocalizations l10n) {
    switch (option) {
      case CourseSortOption.oldest:
        return l10n.oldestFirst;
      case CourseSortOption.mostStudents:
        return 'Most students';
      case CourseSortOption.leastStudents:
        return 'Least students';
      case CourseSortOption.alphabetical:
        return 'A-Z';
      case CourseSortOption.reverseAlphabetical:
        return 'Z-A';
      case CourseSortOption.mostEngagement:
        return 'Top engagement';
      case CourseSortOption.newest:
        return l10n.newestFirst;
    }
  }
}

class _MenuCard extends StatelessWidget {
  final bool isDark;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isActive;

  const _MenuCard({
    required this.isDark,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bounded =
            constraints.hasBoundedWidth &&
            constraints.maxWidth != double.infinity;

        return Container(
          width: bounded ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: InstructorCoursesTheme.cardBackground(isDark),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive
                  ? color
                  : InstructorCoursesTheme.borderColor(isDark),
              width: isActive ? 1.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.18 : 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: InstructorCoursesTheme.primaryText(isDark),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isActive
                            ? color
                            : InstructorCoursesTheme.secondaryText(isDark),
                        fontSize: 11.5,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: InstructorCoursesTheme.secondaryText(isDark),
                size: 20,
              ),
            ],
          ),
        );
      },
    );
  }
}
