import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

class DepartmentStatistics extends StatelessWidget {
  final bool isDark;
  final int totalDepartments;
  final int totalPrograms;
  final int totalStudents;
  final int totalCourses;

  const DepartmentStatistics({
    super.key,
    required this.isDark,
    required this.totalDepartments,
    required this.totalPrograms,
    required this.totalStudents,
    required this.totalCourses,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
      ),
      child: Column(
        children: [
          _buildStatRow(
            label: l10n?.totalDepartments ?? 'Total Departments',
            value: totalDepartments.toString(),
            color: AdminColors.primary,
          ),
          _buildDivider(),
          _buildStatRow(
            label: l10n?.totalPrograms ?? 'Total Programs',
            value: totalPrograms.toString(),
            color: AdminColors.secondary,
          ),
          _buildDivider(),
          _buildStatRow(
            label: l10n?.totalStudents ?? 'Total Students',
            value: _formatNumber(totalStudents),
            color: AdminColors.chartCyan,
          ),
          _buildDivider(),
          _buildStatRow(
            label: l10n?.totalCourses ?? 'Total Courses',
            value: totalCourses.toString(),
            color: AdminColors.chartGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AdminColors.getTextSecondaryColor(isDark),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: AdminColors.getDividerColor(isDark));
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
