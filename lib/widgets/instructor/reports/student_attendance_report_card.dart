import 'package:flutter/material.dart';
import '../../../models/instructor/reports_model.dart';
import 'reports_colors.dart';

/// Student attendance card for the attendance tab
class StudentAttendanceReportCard extends StatelessWidget {
  final StudentReportData student;
  final bool isDark;
  final VoidCallback? onTap;

  const StudentAttendanceReportCard({
    super.key,
    required this.student,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final attendanceColor = ReportsColors.getAttendanceColor(student.attendanceRate);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? ReportsColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ReportsColors.borderColor(isDark)),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark
                    ? ReportsColors.darkSurface
                    : ReportsColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  student.name.isNotEmpty
                      ? student.name.substring(0, 1).toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: ReportsColors.textPrimaryColor(isDark),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Student info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: TextStyle(
                      color: ReportsColors.textPrimaryColor(isDark),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    student.studentId,
                    style: TextStyle(
                      color: ReportsColors.textSecondaryColor(isDark),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Progress bar
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: ReportsColors.borderColor(isDark),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: student.attendanceRate / 100,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              attendanceColor.withValues(alpha: 0.8),
                              attendanceColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Attendance percentage
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${student.attendanceRate.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: attendanceColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (student.isAtRisk)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: ReportsColors.atRiskLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Low',
                      style: TextStyle(
                        color: ReportsColors.atRisk,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

