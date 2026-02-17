import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

class Department {
  final String id;
  final String name;
  final String faculty;
  final Color iconColor;
  final IconData icon;
  final int studentCount;
  final List<String> programs;
  final int courseCount;
  final int instructorCount;
  final int taCount;
  final String? headName;
  final bool hasWarning;
  final String? warningMessage;
  final double healthPercent;

  const Department({
    required this.id,
    required this.name,
    required this.faculty,
    required this.iconColor,
    required this.icon,
    required this.studentCount,
    required this.programs,
    required this.courseCount,
    required this.instructorCount,
    required this.taCount,
    this.headName,
    this.hasWarning = false,
    this.warningMessage,
    this.healthPercent = 100,
  });
}

class DepartmentTable extends StatelessWidget {
  final bool isDark;
  final List<Department> departments;
  final Function(Department) onViewDetails;
  final Function(Department) onEdit;
  final Function(Department) onAssignHead;

  const DepartmentTable({
    super.key,
    required this.isDark,
    required this.departments,
    required this.onViewDetails,
    required this.onEdit,
    required this.onAssignHead,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AdminColors.getCardBorderColor(isDark),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isDark
                  ? AdminColors.darkSurface
                  : AdminColors.lightBackground,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    l10n?.department ?? 'Department',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AdminColors.getTextSecondaryColor(isDark),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    l10n?.programs ?? 'Programs',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AdminColors.getTextSecondaryColor(isDark),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    l10n?.courses ?? 'Courses',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AdminColors.getTextSecondaryColor(isDark),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Table Rows
          ...departments.map((dept) => _buildTableRow(context, dept, l10n)),
        ],
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, Department dept, AppLocalizations? l10n) {
    return InkWell(
      onTap: () => onViewDetails(dept),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AdminColors.getDividerColor(isDark),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Department Info
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: dept.iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      dept.icon,
                      color: dept.iconColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                dept.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AdminColors.getTextColor(isDark),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (dept.hasWarning) ...[
                              const SizedBox(width: 6),
                              Icon(
                                Icons.warning_amber_rounded,
                                color: AdminColors.warning,
                                size: 16,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${dept.studentCount} ${l10n?.students ?? 'students'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AdminColors.getTextTertiaryColor(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Programs
            Expanded(
              flex: 2,
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: dept.programs.map((program) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getProgramColor(program).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      program,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _getProgramColor(program),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            // Courses
            Expanded(
              child: Center(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AdminColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      dept.courseCount.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AdminColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getProgramColor(String program) {
    switch (program.toLowerCase()) {
      case 'bsc':
        return AdminColors.primary;
      case 'msc':
        return AdminColors.secondary;
      case 'phd':
        return AdminColors.chartPink;
      case 'diploma':
        return AdminColors.chartCyan;
      case 'bba':
        return AdminColors.chartGreen;
      case 'mba':
        return AdminColors.chartOrange;
      default:
        return AdminColors.chartPurple;
    }
  }
}
