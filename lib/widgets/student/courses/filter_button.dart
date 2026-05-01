import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../common/utils/student_course_filters.dart';
import '../../../common/utils/student_courses_theme.dart';
import '../../../generated_l10n/app_localizations.dart';

class FilterButton extends StatelessWidget {
  final String selectedFilter;
  final int? selectedSemesterId;
  final List<SemesterFilterOption> semesterOptions;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<int?> onSemesterChanged;
  final bool iconOnly;

  const FilterButton({
    required this.onFilterChanged,
    required this.onSemesterChanged,
    required this.selectedFilter,
    required this.selectedSemesterId,
    required this.semesterOptions,
    this.iconOnly = false,
    super.key,
  });

  bool get _hasSelection =>
      selectedFilter != 'all' || selectedSemesterId != null;

  String _filterLabel(String filter, AppLocalizations l10n) {
    switch (filter) {
      case 'active':
        return l10n.active;
      case 'completed':
        return l10n.completed;
      case 'dropped':
        return l10n.studentCourseDropped;
      case 'all':
      default:
        return l10n.filter;
    }
  }

  String _label(AppLocalizations l10n) {
    return _filterLabel(selectedFilter, l10n);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Semantics(
          button: true,
          label: l10n.filter,
          value: _label(l10n),
          hint: l10n.filterAndSort,
          child: PopupMenuButton<String>(
            tooltip: l10n.filter,
            position: PopupMenuPosition.under,
            offset: const Offset(0, 8),
            color: StudentCoursesTheme.elevatedCardBackground(isDark),
            surfaceTintColor: Colors.transparent,
            elevation: 14,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: BorderSide(color: StudentCoursesTheme.borderColor(isDark)),
            ),
            onSelected: onFilterChanged,
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              _buildFilterMenuItem(
                value: 'all',
                label: l10n.all,
                isDark: isDark,
              ),
              _buildFilterMenuItem(
                value: 'active',
                label: l10n.active,
                isDark: isDark,
              ),
              _buildFilterMenuItem(
                value: 'completed',
                label: l10n.completed,
                isDark: isDark,
              ),
              _buildFilterMenuItem(
                value: 'dropped',
                label: l10n.studentCourseDropped,
                isDark: isDark,
              ),
            ],
            child: iconOnly
                ? _buildIconOnlyButton(isDark)
                : _buildPillButton(isDark, l10n),
          ),
        );
      },
    );
  }

  Widget _buildIconOnlyButton(bool isDark) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: isDark
            ? StudentCoursesTheme.darkSurfaceRaised
            : Colors.white.withValues(alpha: 0.96),
        borderRadius: StudentCoursesTheme.pillRadius,
        border: Border.all(
          color: _hasSelection
              ? StudentCoursesTheme.brandBlue
              : StudentCoursesTheme.borderColor(isDark),
          width: _hasSelection ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.tune_rounded,
            color: _hasSelection
                ? StudentCoursesTheme.brandBlue
                : (isDark ? Colors.white70 : const Color(0xFF475467)),
            size: 22,
          ),
          if (_hasSelection)
            PositionedDirectional(
              top: 10,
              end: 10,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: StudentCoursesTheme.brandBlue,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? StudentCoursesTheme.darkSurfaceRaised
                        : Colors.white,
                    width: 1.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPillButton(bool isDark, AppLocalizations l10n) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: StudentCoursesTheme.cardBackground(isDark),
        borderRadius: StudentCoursesTheme.pillRadius,
        border: Border.all(
          color: _hasSelection
              ? StudentCoursesTheme.brandBlue
              : StudentCoursesTheme.borderColor(isDark),
          width: _hasSelection ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.tune_rounded,
            color: _hasSelection
                ? StudentCoursesTheme.brandBlue
                : (isDark ? Colors.white70 : const Color(0xFF475467)),
            size: 20,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              _label(l10n),
              style: TextStyle(
                color: _hasSelection
                    ? StudentCoursesTheme.brandBlue
                    : StudentCoursesTheme.primaryText(isDark),
                fontSize: 14,
                fontWeight: _hasSelection ? FontWeight.w700 : FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildFilterMenuItem({
    required String value,
    required String label,
    required bool isDark,
  }) {
    final selected = selectedFilter == value;

    return PopupMenuItem<String>(
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
