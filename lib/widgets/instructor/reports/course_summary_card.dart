import 'package:flutter/material.dart';
import 'reports_colors.dart';

/// Course summary statistics card for reports header
class CourseSummaryCard extends StatelessWidget {
  final String courseCode;
  final String courseName;
  final int totalStudents;
  final double averageGrade;
  final double attendanceRate;
  final int studentsAtRisk;
  final String? aiInsight;
  final bool isDark;

  const CourseSummaryCard({
    super.key,
    required this.courseCode,
    required this.courseName,
    required this.totalStudents,
    required this.averageGrade,
    required this.attendanceRate,
    required this.studentsAtRisk,
    this.aiInsight,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: isDark
            ? ReportsColors.darkHeaderGradient
            : ReportsColors.headerGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ReportsColors.primary.withValues(alpha: isDark ? 0.2 : 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course info header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$courseCode — $courseName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                // Stats row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Total Students',
                        totalStudents.toString(),
                        null,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Average Grade',
                        '${averageGrade.toStringAsFixed(1)}%',
                        ReportsColors.getGradeColor(averageGrade),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Attendance Rate',
                        '${attendanceRate.toStringAsFixed(1)}%',
                        ReportsColors.getAttendanceColor(attendanceRate),
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'At Risk',
                        studentsAtRisk.toString(),
                        studentsAtRisk > 0 ? ReportsColors.atRisk : ReportsColors.gradeA,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // AI Insight section
          if (aiInsight != null && aiInsight!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.amber.shade200,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      aiInsight!,
                      style: TextStyle(
                        color: Colors.amber.shade100,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color? valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

