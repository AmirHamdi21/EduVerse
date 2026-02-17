import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

/// App bar for course management screen
class CourseManagementAppBar extends StatelessWidget {
  final bool isDark;
  final int totalCourses;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onAddCourse;
  final String sortBy;
  final bool sortAscending;
  final ValueChanged<String> onSortChanged;
  final List<String> departments;
  final String? selectedDepartment;
  final ValueChanged<String?> onDepartmentChanged;

  const CourseManagementAppBar({
    super.key,
    required this.isDark,
    required this.totalCourses,
    required this.searchController,
    required this.onSearchChanged,
    required this.onAddCourse,
    this.sortBy = 'name',
    this.sortAscending = true,
    required this.onSortChanged,
    this.departments = const [],
    this.selectedDepartment,
    required this.onDepartmentChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AdminColors.darkSurface.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AdminColors.darkDivider
                : AdminColors.lightCardBorder,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => context.pushReplacement('/admin/dashboard'),
                icon: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: AdminColors.getTextColor(isDark),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AdminColors.cyanGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.courseManagement,
                      style: TextStyle(
                        color: AdminColors.getTextColor(isDark),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$totalCourses ${l10n.courses.toLowerCase()}',
                      style: TextStyle(
                        color: AdminColors.getTextSecondaryColor(isDark),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _buildActionButton(
                icon: Icons.add_rounded,
                label: l10n.addCourse,
                gradient: AdminColors.primaryGradient,
                onTap: onAddCourse,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSearchBar(l10n),
          const SizedBox(height: 12),
          _buildSortRow(l10n),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AdminColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AdminColors.darkCardBorder : AdminColors.lightDivider,
        ),
      ),
      child: TextField(
        controller: searchController,
        onChanged: onSearchChanged,
        style: TextStyle(color: AdminColors.getTextColor(isDark)),
        decoration: InputDecoration(
          hintText: l10n.searchCourses,
          hintStyle: TextStyle(color: AdminColors.getTextTertiaryColor(isDark)),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AdminColors.getTextTertiaryColor(isDark),
          ),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    searchController.clear();
                    onSearchChanged('');
                  },
                  icon: Icon(
                    Icons.clear_rounded,
                    color: AdminColors.getTextTertiaryColor(isDark),
                  ),
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

  Widget _buildSortRow(AppLocalizations l10n) {
    return Row(
      children: [
        _buildSortButton(
          label: l10n.name,
          isSelected: sortBy == 'name',
          isAscending: sortAscending,
          onTap: () => onSortChanged('name'),
        ),
        const SizedBox(width: 12),
        _buildDepartmentDropdown(l10n),
      ],
    );
  }

  Widget _buildSortButton({
    required String label,
    required bool isSelected,
    required bool isAscending,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AdminColors.primary.withValues(alpha: 0.1)
                  : (isDark ? AdminColors.darkCard : Colors.white),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? AdminColors.primary
                    : (isDark
                          ? AdminColors.darkCardBorder
                          : AdminColors.lightDivider),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.sort_by_alpha_rounded,
                  size: 16,
                  color: isSelected
                      ? AdminColors.primary
                      : AdminColors.getTextSecondaryColor(isDark),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? AdminColors.primary
                        : AdminColors.getTextColor(isDark),
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                const Spacer(),
                Icon(
                  isAscending
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  color: isSelected
                      ? AdminColors.primary
                      : AdminColors.getTextSecondaryColor(isDark),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDepartmentDropdown(AppLocalizations l10n) {
    final allDepartments = [l10n.allDepartments, ...departments];

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: selectedDepartment != null
              ? AdminColors.accent.withValues(alpha: 0.1)
              : (isDark ? AdminColors.darkCard : Colors.white),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selectedDepartment != null
                ? AdminColors.accent
                : (isDark
                      ? AdminColors.darkCardBorder
                      : AdminColors.lightDivider),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String?>(
            value: selectedDepartment,
            isExpanded: true,
            hint: Row(
              children: [
                Icon(
                  Icons.business_rounded,
                  size: 16,
                  color: AdminColors.getTextSecondaryColor(isDark),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.allDepartments,
                  style: TextStyle(
                    color: AdminColors.getTextColor(isDark),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: selectedDepartment != null
                  ? AdminColors.accent
                  : AdminColors.getTextSecondaryColor(isDark),
              size: 20,
            ),
            dropdownColor: isDark ? AdminColors.darkCard : Colors.white,
            items: allDepartments.map((dept) {
              final isAll = dept == l10n.allDepartments;
              return DropdownMenuItem<String?>(
                value: isAll ? null : dept,
                child: Row(
                  children: [
                    Icon(
                      Icons.business_rounded,
                      size: 16,
                      color: isAll
                          ? AdminColors.getTextSecondaryColor(isDark)
                          : AdminColors.accent,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dept,
                      style: TextStyle(
                        color: AdminColors.getTextColor(isDark),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: onDepartmentChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AdminColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
