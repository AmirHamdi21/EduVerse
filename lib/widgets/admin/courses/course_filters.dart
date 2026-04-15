import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

/// Course filter chip model
class CourseFilter {
  final String id;
  final String label;
  final int count;
  final IconData? icon;
  final Color? color;

  CourseFilter({
    required this.id,
    required this.label,
    required this.count,
    this.icon,
    this.color,
  });
}

/// Course filters widget
class CourseFilters extends StatelessWidget {
  final bool isDark;
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final Map<String, int> filterCounts;

  const CourseFilters({
    super.key,
    required this.isDark,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.filterCounts,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final filters = [
      CourseFilter(
        id: 'all',
        label: l10n.allCourses,
        count: filterCounts['all'] ?? 0,
      ),
      CourseFilter(
        id: 'active',
        label: l10n.active,
        count: filterCounts['active'] ?? 0,
        color: AdminColors.success,
      ),
      CourseFilter(
        id: 'inactive',
        label: l10n.inactive,
        count: filterCounts['inactive'] ?? 0,
        color: AdminColors.warning,
      ),
      CourseFilter(
        id: 'needs_instructor',
        label: l10n.needsInstructor,
        count: filterCounts['needs_instructor'] ?? 0,
        color: AdminColors.error,
      ),
      CourseFilter(
        id: 'needs_ta',
        label: l10n.needsTA,
        count: filterCounts['needs_ta'] ?? 0,
        color: AdminColors.secondary,
      ),
      CourseFilter(
        id: 'ai_flagged',
        label: l10n.aiFlagged,
        count: filterCounts['ai_flagged'] ?? 0,
        icon: Icons.auto_awesome_rounded,
        color: AdminColors.accent,
      ),
      CourseFilter(
        id: 'lab_based',
        label: l10n.labBased,
        count: filterCounts['lab_based'] ?? 0,
        icon: Icons.science_rounded,
        color: AdminColors.primary,
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AdminColors.darkCard.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AdminColors.darkCardBorder
              : AdminColors.lightCardBorder,
        ),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: filters.map((filter) => _buildFilterChip(filter)).toList(),
      ),
    );
  }

  Widget _buildFilterChip(CourseFilter filter) {
    final isSelected = selectedFilter == filter.id;
    final chipColor = filter.color ?? AdminColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onFilterChanged(filter.id),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [chipColor, chipColor.withValues(alpha: 0.8)],
                  )
                : null,
            color: isSelected
                ? null
                : (isDark
                      ? AdminColors.darkSurface.withValues(alpha: 0.5)
                      : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? chipColor
                  : (isDark
                        ? AdminColors.darkCardBorder
                        : AdminColors.lightDivider),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: chipColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (filter.icon != null) ...[
                Icon(
                  filter.icon,
                  size: 16,
                  color: isSelected
                      ? Colors.white
                      : AdminColors.getTextSecondaryColor(isDark),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                filter.label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : AdminColors.getTextColor(isDark),
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.2)
                      : chipColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  filter.count.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : chipColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
