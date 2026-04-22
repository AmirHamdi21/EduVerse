import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/ta_colors.dart';

enum StudentRiskLevel { high, medium, low }

class TAStudentCard extends StatelessWidget {
  final bool isDark;
  final TAStudentPerformance student;
  final VoidCallback? onViewSummary;

  const TAStudentCard({
    super.key,
    required this.isDark,
    required this.student,
    this.onViewSummary,
  });

  Color _getRiskColor(StudentRiskLevel risk) {
    switch (risk) {
      case StudentRiskLevel.high:
        return TAColors.error;
      case StudentRiskLevel.medium:
        return TAColors.warning;
      case StudentRiskLevel.low:
        return TAColors.success;
    }
  }

  String _getRiskLabel(StudentRiskLevel risk, AppLocalizations l10n) {
    switch (risk) {
      case StudentRiskLevel.high:
        return l10n.taPerformanceHighRisk;
      case StudentRiskLevel.medium:
        return l10n.taPerformanceMediumRisk;
      case StudentRiskLevel.low:
        return l10n.taPerformanceLowRisk;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final riskColor = _getRiskColor(student.riskLevel);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
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
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        TAColors.primary,
                        TAColors.primary.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      student.name.isNotEmpty
                          ? student.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Student Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              student.name,
                              style: TextStyle(
                                color: TAColors.textPrimaryColor(isDark),
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: TAColors.textTertiaryColor(isDark),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        student.studentId,
                        style: TextStyle(
                          color: TAColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        student.email,
                        style: TextStyle(
                          color: TAColors.textSecondaryColor(isDark),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Scores Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildScoreItem(
                    label: l10n.taPerformanceLabAverage,
                    value: student.labAverage,
                    isDark: isDark,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: TAColors.borderColor(isDark),
                ),
                Expanded(
                  child: _buildScoreItem(
                    label: l10n.taLabAttendance,
                    value: student.attendance,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Submission Info & Risk Badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.update_rounded,
                  size: 14,
                  color: TAColors.textTertiaryColor(isDark),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${l10n.taPerformanceLast}: ${student.lastSubmitted}',
                    style: TextStyle(
                      color: TAColors.textSecondaryColor(isDark),
                      fontSize: 11,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: riskColor.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: riskColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _getRiskLabel(student.riskLevel, l10n),
                    style: TextStyle(
                      color: riskColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // View Summary Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onViewSummary,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TAColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  l10n.taPerformanceViewSummary,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreItem({
    required String label,
    required double value,
    required bool isDark,
  }) {
    final color = value >= 85
        ? TAColors.success
        : value >= 70
        ? TAColors.warning
        : TAColors.error;

    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: TAColors.textSecondaryColor(isDark),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${value.toStringAsFixed(0)}%',
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class TAStudentPerformance {
  final String id;
  final String name;
  final String studentId;
  final String email;
  final double labAverage;
  final double attendance;
  final String lastSubmitted;
  final StudentRiskLevel riskLevel;
  final List<double> labScores;
  final List<bool> attendanceHistory;
  final String? aiNotes;

  TAStudentPerformance({
    required this.id,
    required this.name,
    required this.studentId,
    required this.email,
    required this.labAverage,
    required this.attendance,
    required this.lastSubmitted,
    required this.riskLevel,
    this.labScores = const [],
    this.attendanceHistory = const [],
    this.aiNotes,
  });
}
