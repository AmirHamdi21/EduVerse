import 'package:flutter/material.dart';
import '../../../models/instructor/reports_model.dart';
import 'reports_colors.dart';

/// Student performance card for the performance tab
class StudentPerformanceCard extends StatelessWidget {
  final StudentReportData student;
  final bool isDark;
  final bool isSelected;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onSelectionChanged;

  const StudentPerformanceCard({
    super.key,
    required this.student,
    required this.isDark,
    this.isSelected = false,
    this.onTap,
    this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final gradeColor = ReportsColors.getGradeColor(student.averageGrade);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? ReportsColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? ReportsColors.primary
                : ReportsColors.borderColor(isDark),
            width: isSelected ? 2 : 1,
          ),
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
        child: Column(
          children: [
            // Header with student info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Selection checkbox
                  if (onSelectionChanged != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () => onSelectionChanged?.call(!isSelected),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? ReportsColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isSelected
                                  ? ReportsColors.primary
                                  : ReportsColors.borderColor(isDark),
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                    ),
                  // Avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          gradeColor.withValues(alpha: 0.8),
                          gradeColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        student.name.isNotEmpty 
                            ? student.name.substring(0, 1).toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name and ID
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                student.name,
                                style: TextStyle(
                                  color: ReportsColors.textPrimaryColor(isDark),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              ReportsColors.getTrendIcon(
                                student.trend.name,
                              ),
                              size: 16,
                              color: ReportsColors.getTrendColor(
                                student.trend.name,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          student.studentId,
                          style: TextStyle(
                            color: ReportsColors.textSecondaryColor(isDark),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // At risk badge
                  if (student.isAtRisk)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: ReportsColors.atRiskLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning_rounded,
                            size: 12,
                            color: ReportsColors.atRisk,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'At Risk',
                            style: TextStyle(
                              color: ReportsColors.atRisk,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            // Divider
            Container(
              height: 1,
              color: ReportsColors.borderColor(isDark),
            ),
            // Performance metrics
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Average Grade (larger)
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Average Grade',
                          style: TextStyle(
                            color: ReportsColors.textTertiaryColor(isDark),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${student.averageGrade.toStringAsFixed(0)}%',
                              style: TextStyle(
                                color: gradeColor,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Progress indicator
                            Expanded(
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: ReportsColors.borderColor(isDark),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: student.averageGrade / 100,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: gradeColor,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Attendance
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Attendance',
                          style: TextStyle(
                            color: ReportsColors.textTertiaryColor(isDark),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${student.attendanceRate.toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: ReportsColors.getAttendanceColor(
                              student.attendanceRate,
                            ),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Detailed scores row
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  _buildScoreItem('Assign', student.assignmentScore, isDark),
                  _buildScoreItem('Labs', student.labScore, isDark),
                  _buildScoreItem('Quiz', student.quizScore, isDark),
                  _buildScoreItem('Midterm', student.midtermScore, isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreItem(String label, double score, bool isDark) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: ReportsColors.textTertiaryColor(isDark),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${score.toStringAsFixed(0)}%',
            style: TextStyle(
              color: ReportsColors.textSecondaryColor(isDark),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

