import 'package:flutter/material.dart';
import '../../../models/instructor/reports_model.dart';
import 'reports_colors.dart';

/// Attendance overview card showing present/absent/late breakdown
class AttendanceOverviewCard extends StatelessWidget {
  final AttendanceBreakdown breakdown;
  final bool isDark;

  const AttendanceOverviewCard({
    super.key,
    required this.breakdown,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ReportsColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  color: ReportsColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Attendance Overview',
                style: TextStyle(
                  color: ReportsColors.textPrimaryColor(isDark),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Circular indicators row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCircularIndicator(
                percentage: breakdown.presentRate,
                label: 'Present',
                color: ReportsColors.present,
                icon: Icons.check_circle_rounded,
                isDark: isDark,
              ),
              _buildCircularIndicator(
                percentage: breakdown.absentRate,
                label: 'Absent',
                color: ReportsColors.absent,
                icon: Icons.cancel_rounded,
                isDark: isDark,
              ),
              _buildCircularIndicator(
                percentage: breakdown.lateRate,
                label: 'Late',
                color: ReportsColors.late,
                icon: Icons.schedule_rounded,
                isDark: isDark,
              ),
            ],
          ),
          // AI Insight
          if (breakdown.insight != null && breakdown.insight!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? ReportsColors.primary.withValues(alpha: 0.1)
                    : ReportsColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: ReportsColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      breakdown.insight!,
                      style: TextStyle(
                        color: isDark
                            ? ReportsColors.primaryLighter
                            : ReportsColors.primaryDark,
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

  Widget _buildCircularIndicator({
    required double percentage,
    required String label,
    required Color color,
    required IconData icon,
    required bool isDark,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Background circle
            SizedBox(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                value: 1,
                strokeWidth: 6,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark
                      ? color.withValues(alpha: 0.2)
                      : color.withValues(alpha: 0.15),
                ),
              ),
            ),
            // Progress circle
            SizedBox(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                value: percentage / 100,
                strokeWidth: 6,
                strokeCap: StrokeCap.round,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            // Center content
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 18),
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: ReportsColors.textSecondaryColor(isDark),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

