import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';
import 'department_table.dart';

class DepartmentHealthMap extends StatelessWidget {
  final bool isDark;
  final List<Department> departments;
  final Function(Department) onViewDetails;

  const DepartmentHealthMap({
    super.key,
    required this.isDark,
    required this.departments,
    required this.onViewDetails,
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.departmentHealthMap ?? 'Department Health Map',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AdminColors.getTextColor(isDark),
            ),
          ),
          const SizedBox(height: 20),
          ...departments.map((dept) => _buildHealthItem(context, dept)),
        ],
      ),
    );
  }

  Widget _buildHealthItem(BuildContext context, Department dept) {
    final l10n = AppLocalizations.of(context);
    final healthColor = _getHealthColor(dept.healthPercent);

    return InkWell(
      onTap: () => onViewDetails(dept),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AdminColors.darkSurface : AdminColors.lightBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AdminColors.getDividerColor(isDark)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: dept.iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(dept.icon, color: dept.iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dept.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AdminColors.getTextColor(isDark),
                        ),
                      ),
                      Text(
                        '${dept.instructorCount} ${l10n?.instructors ?? 'Instructors'}, ${dept.taCount} ${l10n?.teachingAssistants ?? 'TAs'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AdminColors.getTextTertiaryColor(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: healthColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${dept.healthPercent.toInt()}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: healthColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: dept.healthPercent / 100,
                backgroundColor: AdminColors.getDividerColor(isDark),
                valueColor: AlwaysStoppedAnimation<Color>(healthColor),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getHealthColor(double percent) {
    if (percent >= 80) {
      return AdminColors.success;
    } else if (percent >= 60) {
      return AdminColors.chartCyan;
    } else if (percent >= 40) {
      return AdminColors.warning;
    } else {
      return AdminColors.error;
    }
  }
}
