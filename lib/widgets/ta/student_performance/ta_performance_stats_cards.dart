import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/ta_colors.dart';

class TAPerformanceStatsCards extends StatelessWidget {
  final bool isDark;
  final int studentsCount;
  final int submissionsCount;
  final double avgScore;
  final double attendance;

  const TAPerformanceStatsCards({
    super.key,
    required this.isDark,
    required this.studentsCount,
    required this.submissionsCount,
    required this.avgScore,
    required this.attendance,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.people_rounded,
                  value: studentsCount.toString(),
                  label: l10n.taLabStudents,
                  color: TAColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.assignment_turned_in_rounded,
                  value: submissionsCount.toString(),
                  label: l10n.taLabSubmissions,
                  color: TAColors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.analytics_rounded,
                  value: '${avgScore.toStringAsFixed(1)}%',
                  label: l10n.taPerformanceAvgScore,
                  color: TAColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.event_available_rounded,
                  value: '${attendance.toStringAsFixed(1)}%',
                  label: l10n.taLabAttendance,
                  color: TAColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: TAColors.textSecondaryColor(isDark),
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
