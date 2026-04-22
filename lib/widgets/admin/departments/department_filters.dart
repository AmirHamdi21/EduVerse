import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

enum DepartmentViewType { list, card, health }

enum DepartmentFilterType {
  all,
  understaffed,
  missingCourses,
  noHead,
  aiWarnings,
}

class DepartmentFilters extends StatelessWidget {
  final bool isDark;
  final String searchQuery;
  final String selectedFaculty;
  final DepartmentViewType viewType;
  final DepartmentFilterType filterType;
  final List<String> faculties;
  final int allCount;
  final int understaffedCount;
  final int missingCoursesCount;
  final int noHeadCount;
  final int aiWarningsCount;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onFacultyChanged;
  final ValueChanged<DepartmentViewType> onViewTypeChanged;
  final ValueChanged<DepartmentFilterType> onFilterChanged;

  const DepartmentFilters({
    super.key,
    required this.isDark,
    required this.searchQuery,
    required this.selectedFaculty,
    required this.viewType,
    required this.filterType,
    required this.faculties,
    required this.allCount,
    required this.understaffedCount,
    required this.missingCoursesCount,
    required this.noHeadCount,
    required this.aiWarningsCount,
    required this.onSearchChanged,
    required this.onFacultyChanged,
    required this.onViewTypeChanged,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        // Search and Faculty Filter Row
        Row(
          children: [
            Expanded(flex: 2, child: _buildSearchField(l10n)),
            const SizedBox(width: 12),
            Expanded(child: _buildFacultyDropdown(l10n)),
            const SizedBox(width: 12),
            _buildViewToggle(),
          ],
        ),
        const SizedBox(height: 16),
        // Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(
                label: l10n?.allDepartments ?? 'All Departments',
                count: allCount,
                isSelected: filterType == DepartmentFilterType.all,
                onTap: () => onFilterChanged(DepartmentFilterType.all),
                color: AdminColors.primary,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: l10n?.understaffed ?? 'Understaffed',
                count: understaffedCount,
                isSelected: filterType == DepartmentFilterType.understaffed,
                onTap: () => onFilterChanged(DepartmentFilterType.understaffed),
                color: AdminColors.warning,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: l10n?.missingCourses ?? 'Missing Courses',
                count: missingCoursesCount,
                isSelected: filterType == DepartmentFilterType.missingCourses,
                onTap: () =>
                    onFilterChanged(DepartmentFilterType.missingCourses),
                color: AdminColors.error,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: l10n?.noHeadAssigned ?? 'No Head Assigned',
                count: noHeadCount,
                isSelected: filterType == DepartmentFilterType.noHead,
                onTap: () => onFilterChanged(DepartmentFilterType.noHead),
                color: AdminColors.chartPurple,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: l10n?.aiWarnings ?? 'AI Warnings',
                count: aiWarningsCount,
                isSelected: filterType == DepartmentFilterType.aiWarnings,
                onTap: () => onFilterChanged(DepartmentFilterType.aiWarnings),
                color: AdminColors.chartOrange,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(AppLocalizations? l10n) {
    return Container(
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
      ),
      child: TextField(
        onChanged: onSearchChanged,
        style: TextStyle(color: AdminColors.getTextColor(isDark), fontSize: 14),
        decoration: InputDecoration(
          hintText: l10n?.searchDepartments ?? 'Search departments...',
          hintStyle: TextStyle(
            color: AdminColors.getTextTertiaryColor(isDark),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AdminColors.getTextTertiaryColor(isDark),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildFacultyDropdown(AppLocalizations? l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedFaculty,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AdminColors.getTextTertiaryColor(isDark),
          ),
          dropdownColor: AdminColors.getCardColor(isDark),
          style: TextStyle(
            color: AdminColors.getTextColor(isDark),
            fontSize: 14,
          ),
          items: faculties.map((faculty) {
            return DropdownMenuItem(
              value: faculty,
              child: Text(
                faculty == 'All'
                    ? (l10n?.allFaculties ?? 'All Faculties')
                    : faculty,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) onFacultyChanged(value);
          },
        ),
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildViewButton(
            icon: Icons.list_rounded,
            type: DepartmentViewType.list,
          ),
          _buildViewButton(
            icon: Icons.grid_view_rounded,
            type: DepartmentViewType.card,
          ),
          _buildViewButton(
            icon: Icons.bar_chart_rounded,
            type: DepartmentViewType.health,
          ),
        ],
      ),
    );
  }

  Widget _buildViewButton({
    required IconData icon,
    required DepartmentViewType type,
  }) {
    final isSelected = viewType == type;
    return InkWell(
      onTap: () => onViewTypeChanged(type),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? AdminColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected
              ? AdminColors.primary
              : AdminColors.getTextTertiaryColor(isDark),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : AdminColors.getCardColor(isDark),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AdminColors.getCardBorderColor(isDark),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : AdminColors.getTextColor(isDark),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
