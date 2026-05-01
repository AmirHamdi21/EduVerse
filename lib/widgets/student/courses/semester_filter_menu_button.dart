import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../common/utils/student_course_filters.dart';
import '../../../common/utils/student_courses_theme.dart';
import '../../../generated_l10n/app_localizations.dart';

class SemesterFilterMenuButton extends StatelessWidget {
  final int? selectedSemesterId;
  final List<SemesterFilterOption> semesterOptions;
  final ValueChanged<int?> onSemesterChanged;

  const SemesterFilterMenuButton({
    super.key,
    required this.selectedSemesterId,
    required this.semesterOptions,
    required this.onSemesterChanged,
  });

  String _label(AppLocalizations l10n) {
    if (selectedSemesterId == null) {
      return l10n.allSemesters;
    }

    for (final SemesterFilterOption option in semesterOptions) {
      if (option.id == selectedSemesterId) {
        return option.label;
      }
    }

    return l10n.allSemesters;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);
        final isActive = selectedSemesterId != null;

        return Semantics(
          button: true,
          label: l10n.coursesShellSemesterLabel,
          value: _label(l10n),
          hint: l10n.selectSemester,
          child: PopupMenuButton<int?>(
            tooltip: l10n.coursesShellSemesterLabel,
            position: PopupMenuPosition.under,
            offset: const Offset(0, 8),
            padding: EdgeInsets.zero,
            color: StudentCoursesTheme.elevatedCardBackground(isDark),
            surfaceTintColor: Colors.transparent,
            elevation: 14,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: BorderSide(color: StudentCoursesTheme.borderColor(isDark)),
            ),
            onSelected: onSemesterChanged,
            itemBuilder: (context) => <PopupMenuEntry<int?>>[
              _buildSemesterItem(null, l10n.allSemesters, isDark),
              ...semesterOptions.map(
                (option) => _buildSemesterItem(option.id, option.label, isDark),
              ),
            ],
            child: _SemesterMenuCard(
              isDark: isDark,
              title: l10n.coursesShellSemesterLabel,
              subtitle: _label(l10n),
              icon: Icons.school_rounded,
              color: const Color(0xFF06B6D4),
              isActive: isActive,
            ),
          ),
        );
      },
    );
  }

  PopupMenuItem<int?> _buildSemesterItem(
    int? value,
    String label,
    bool isDark,
  ) {
    final selected = selectedSemesterId == value;

    return PopupMenuItem<int?>(
      value: value,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: selected
                    ? StudentCoursesTheme.brandBlue
                    : StudentCoursesTheme.primaryText(isDark),
                fontSize: 14,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
          Icon(
            selected ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: selected
                ? StudentCoursesTheme.brandBlue
                : StudentCoursesTheme.secondaryText(isDark),
            size: 18,
          ),
        ],
      ),
    );
  }
}

class _SemesterMenuCard extends StatelessWidget {
  final bool isDark;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isActive;

  const _SemesterMenuCard({
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
            color: StudentCoursesTheme.cardBackground(isDark),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? color : StudentCoursesTheme.borderColor(isDark),
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
              if (bounded)
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
                          color: StudentCoursesTheme.primaryText(isDark),
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
                              : StudentCoursesTheme.secondaryText(isDark),
                          fontSize: 11.5,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Flexible(
                  fit: FlexFit.loose,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: StudentCoursesTheme.primaryText(isDark),
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
                              : StudentCoursesTheme.secondaryText(isDark),
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
                color: StudentCoursesTheme.secondaryText(isDark),
                size: 20,
              ),
            ],
          ),
        );
      },
    );
  }
}
