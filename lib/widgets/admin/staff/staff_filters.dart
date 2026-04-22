import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

/// Filter chips for staff assignment screen
class StaffFilters extends StatelessWidget {
  final bool isDark;
  final String selectedFilter;
  final String? selectedDepartment;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<String?> onDepartmentChanged;
  final Map<String, int> filterCounts;
  final List<String> departments;

  const StaffFilters({
    super.key,
    required this.isDark,
    required this.selectedFilter,
    this.selectedDepartment,
    required this.onFilterChanged,
    required this.onDepartmentChanged,
    this.filterCounts = const {},
    this.departments = const [],
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final filters = [
      _FilterItem('all', l10n.allCourses, Icons.grid_view_rounded),
      _FilterItem(
        'needsInstructor',
        l10n.needsInstructor,
        Icons.person_off_rounded,
      ),
      _FilterItem('needsTA', l10n.needsTA, Icons.group_off_rounded),
      _FilterItem(
        'instructorOverloaded',
        l10n.instructorOverloaded,
        Icons.warning_amber_rounded,
      ),
      _FilterItem('taOverloaded', l10n.taOverloaded, Icons.schedule_rounded),
      _FilterItem(
        'aiSuggestions',
        l10n.aiSuggestions,
        Icons.auto_awesome_rounded,
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filters.map((filter) {
                final isSelected = selectedFilter == filter.id;
                final count = filterCounts[filter.id] ?? 0;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onFilterChanged(filter.id),
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? AdminColors.primaryGradient
                              : null,
                          color: isSelected
                              ? null
                              : (isDark
                                    ? AdminColors.darkSurface
                                    : Colors.white),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : (isDark
                                      ? AdminColors.darkCardBorder
                                      : AdminColors.lightCardBorder),
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AdminColors.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              filter.icon,
                              size: 16,
                              color: isSelected
                                  ? Colors.white
                                  : AdminColors.getTextSecondaryColor(isDark),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              filter.label,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AdminColors.getTextColor(isDark),
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                            if (count > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.2)
                                      : AdminColors.primary.withValues(
                                          alpha: 0.1,
                                        ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$count',
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AdminColors.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          _buildDepartmentDropdown(l10n),
        ],
      ),
    );
  }

  Widget _buildDepartmentDropdown(AppLocalizations l10n) {
    final deptList = departments.isEmpty
        ? [
            'Computer Science',
            'Mathematics',
            'Physics',
            'Engineering',
            'Chemistry',
          ]
        : departments;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AdminColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? AdminColors.darkCardBorder
              : AdminColors.lightCardBorder,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedDepartment,
          isExpanded: true,
          hint: Row(
            children: [
              Icon(
                Icons.business_rounded,
                size: 18,
                color: AdminColors.getTextTertiaryColor(isDark),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.allDepartments,
                style: TextStyle(
                  color: AdminColors.getTextSecondaryColor(isDark),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AdminColors.getTextSecondaryColor(isDark),
          ),
          dropdownColor: isDark ? AdminColors.darkCard : Colors.white,
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text(
                l10n.allDepartments,
                style: TextStyle(
                  color: AdminColors.getTextColor(isDark),
                  fontSize: 14,
                ),
              ),
            ),
            ...deptList.map((dept) {
              return DropdownMenuItem<String>(
                value: dept,
                child: Text(
                  dept,
                  style: TextStyle(
                    color: AdminColors.getTextColor(isDark),
                    fontSize: 14,
                  ),
                ),
              );
            }),
          ],
          onChanged: onDepartmentChanged,
        ),
      ),
    );
  }
}

class _FilterItem {
  final String id;
  final String label;
  final IconData icon;

  _FilterItem(this.id, this.label, this.icon);
}
