import 'package:flutter/material.dart';
import '../shared/admin_colors.dart';

enum AttendanceFilterType { all, present, absent, late, excused }

class AdminAttendanceFilters extends StatelessWidget {
  final bool isDark;
  final AttendanceFilterType selectedFilter;
  final Function(AttendanceFilterType) onFilterChanged;
  final String searchQuery;
  final Function(String) onSearchChanged;
  final String? selectedDepartment;
  final List<String> departments;
  final Function(String?) onDepartmentChanged;
  final VoidCallback? onClearFilters;

  const AdminAttendanceFilters({
    super.key,
    required this.isDark,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.searchQuery,
    required this.onSearchChanged,
    this.selectedDepartment,
    required this.departments,
    required this.onDepartmentChanged,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(),
          const SizedBox(height: 16),
          _buildFilterChips(),
          const SizedBox(height: 12),
          _buildDepartmentDropdown(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AdminColors.darkCard : AdminColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? AdminColors.darkCardBorder
              : AdminColors.lightCardBorder,
        ),
      ),
      child: TextField(
        onChanged: onSearchChanged,
        style: TextStyle(
          color: isDark ? AdminColors.darkText : AdminColors.lightText,
        ),
        decoration: InputDecoration(
          hintText: 'Search courses, instructors, students...',
          hintStyle: TextStyle(
            color: isDark
                ? AdminColors.darkTextTertiary
                : AdminColors.lightTextTertiary,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDark
                ? AdminColors.darkTextSecondary
                : AdminColors.lightTextSecondary,
          ),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: isDark
                        ? AdminColors.darkTextSecondary
                        : AdminColors.lightTextSecondary,
                  ),
                  onPressed: () => onSearchChanged(''),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      (AttendanceFilterType.all, 'All', Icons.list_rounded),
      (AttendanceFilterType.present, 'Present', Icons.check_circle_rounded),
      (AttendanceFilterType.absent, 'Absent', Icons.cancel_rounded),
      (AttendanceFilterType.late, 'Late', Icons.schedule_rounded),
      (AttendanceFilterType.excused, 'Excused', Icons.assignment_late_rounded),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter.$1;
          final color = _getFilterColor(filter.$1);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              onSelected: (_) => onFilterChanged(filter.$1),
              avatar: Icon(
                filter.$3,
                size: 18,
                color: isSelected ? Colors.white : color,
              ),
              label: Text(filter.$2),
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : isDark
                    ? AdminColors.darkText
                    : AdminColors.lightText,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              backgroundColor: isDark
                  ? AdminColors.darkCard
                  : AdminColors.lightCard,
              selectedColor: color,
              side: BorderSide(
                color: isSelected
                    ? color
                    : (isDark
                          ? AdminColors.darkCardBorder
                          : AdminColors.lightCardBorder),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDepartmentDropdown() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? AdminColors.darkCard : AdminColors.lightCard,
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
                hint: Text(
                  'All Departments',
                  style: TextStyle(
                    color: isDark
                        ? AdminColors.darkTextSecondary
                        : AdminColors.lightTextSecondary,
                  ),
                ),
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: isDark
                      ? AdminColors.darkTextSecondary
                      : AdminColors.lightTextSecondary,
                ),
                dropdownColor: isDark
                    ? AdminColors.darkCard
                    : AdminColors.lightCard,
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text(
                      'All Departments',
                      style: TextStyle(
                        color: isDark
                            ? AdminColors.darkText
                            : AdminColors.lightText,
                      ),
                    ),
                  ),
                  ...departments.map(
                    (dept) => DropdownMenuItem<String>(
                      value: dept,
                      child: Text(
                        dept,
                        style: TextStyle(
                          color: isDark
                              ? AdminColors.darkText
                              : AdminColors.lightText,
                        ),
                      ),
                    ),
                  ),
                ],
                onChanged: onDepartmentChanged,
              ),
            ),
          ),
        ),
        if (onClearFilters != null &&
            (selectedDepartment != null ||
                selectedFilter != AttendanceFilterType.all)) ...[
          const SizedBox(width: 12),
          TextButton.icon(
            onPressed: onClearFilters,
            icon: const Icon(Icons.clear_all_rounded, size: 18),
            label: const Text('Clear'),
            style: TextButton.styleFrom(foregroundColor: AdminColors.error),
          ),
        ],
      ],
    );
  }

  Color _getFilterColor(AttendanceFilterType type) {
    switch (type) {
      case AttendanceFilterType.all:
        return AdminColors.primary;
      case AttendanceFilterType.present:
        return AdminColors.success;
      case AttendanceFilterType.absent:
        return AdminColors.error;
      case AttendanceFilterType.late:
        return AdminColors.warning;
      case AttendanceFilterType.excused:
        return AdminColors.secondary;
    }
  }
}
