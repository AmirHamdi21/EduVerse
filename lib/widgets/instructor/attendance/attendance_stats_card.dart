import 'package:flutter/material.dart';
import 'attendance_colors.dart';

class AttendanceStatsCard extends StatelessWidget {
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final int markedCount;
  final int totalStudents;
  final bool isDark;

  const AttendanceStatsCard({
    super.key,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
    required this.markedCount,
    required this.totalStudents,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AttendanceColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AttendanceColors.darkBorder.withValues(alpha: 0.3)
              : AttendanceColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : AttendanceColors.primary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.check_circle_rounded,
                  label: 'Present',
                  value: presentCount.toString(),
                  subtitle: '${_getPercentage(presentCount)}% of class',
                  color: AttendanceColors.present,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.cancel_rounded,
                  label: 'Absent',
                  value: absentCount.toString(),
                  subtitle: '${_getPercentage(absentCount)}% of class',
                  color: AttendanceColors.absent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.schedule_rounded,
                  label: 'Late',
                  value: lateCount.toString(),
                  subtitle: '${_getPercentage(lateCount)}% of class',
                  color: AttendanceColors.late,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.pie_chart_rounded,
                  label: 'Progress',
                  value: '$markedCount/$totalStudents',
                  subtitle: 'Students marked',
                  color: AttendanceColors.primary,
                  showProgress: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getPercentage(int count) {
    if (totalStudents == 0) return '0';
    return ((count / totalStudents) * 100).toStringAsFixed(0);
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required String subtitle,
    required Color color,
    bool showProgress = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? color.withValues(alpha: 0.1)
            : color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: AttendanceColors.textPrimaryColor(isDark),
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: AttendanceColors.textTertiaryColor(isDark),
              fontSize: 11,
            ),
          ),
          if (showProgress) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: totalStudents > 0 ? markedCount / totalStudents : 0,
                backgroundColor: isDark
                    ? AttendanceColors.darkSurface
                    : AttendanceColors.surface,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AttendanceAIAlert extends StatelessWidget {
  final int studentsAtRisk;
  final bool isDark;
  final VoidCallback? onTap;

  const AttendanceAIAlert({
    super.key,
    required this.studentsAtRisk,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (studentsAtRisk == 0) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AttendanceColors.accent.withValues(alpha: isDark ? 0.2 : 0.1),
              AttendanceColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AttendanceColors.accent.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AttendanceColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 20,
                color: AttendanceColors.accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI detected that $studentsAtRisk students have low attendance this month',
                    style: TextStyle(
                      color: AttendanceColors.textPrimaryColor(isDark),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AttendanceColors.accent,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
