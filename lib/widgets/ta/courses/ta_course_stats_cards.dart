import 'package:flutter/material.dart';
import '../shared/ta_colors.dart';

class TACourseStatsCards extends StatelessWidget {
  final bool isDark;
  final int studentsCount;
  final int labsCount;
  final int assignmentsCount;
  final int discussionsCount;

  const TACourseStatsCards({
    super.key,
    required this.isDark,
    required this.studentsCount,
    required this.labsCount,
    required this.assignmentsCount,
    required this.discussionsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.people_rounded,
                label: 'Students',
                value: studentsCount.toString(),
                color: TAColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.science_rounded,
                label: 'Labs',
                value: labsCount.toString(),
                color: TAColors.pink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.assignment_rounded,
                label: 'Assignments',
                value: assignmentsCount.toString(),
                color: TAColors.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.forum_rounded,
                label: 'Discussions',
                value: discussionsCount.toString(),
                color: TAColors.teal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? color.withValues(alpha: 0.15)
            : color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.3 : 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: TAColors.textSecondaryColor(isDark),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
