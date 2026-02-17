import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

/// Course statistics widget
class CourseStatistics extends StatelessWidget {
  final bool isDark;
  final int totalCourses;
  final int activeCourses;
  final int totalStudents;
  final int unassignedCourses;

  const CourseStatistics({
    super.key,
    required this.isDark,
    this.totalCourses = 0,
    this.activeCourses = 0,
    this.totalStudents = 0,
    this.unassignedCourses = 0,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? AdminColors.darkCard.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AdminColors.darkCardBorder : AdminColors.lightCardBorder,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AdminColors.cyanGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.courseStatistics,
                style: TextStyle(
                  color: AdminColors.getTextColor(isDark),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  label: l10n.totalCourses,
                  value: totalCourses.toString(),
                  icon: Icons.school_rounded,
                  gradient: AdminColors.primaryGradient,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  label: l10n.activeCourses,
                  value: activeCourses.toString(),
                  icon: Icons.check_circle_rounded,
                  gradient: AdminColors.greenGradient,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  label: l10n.totalStudents,
                  value: totalStudents.toString(),
                  icon: Icons.people_rounded,
                  gradient: AdminColors.cyanGradient,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  label: l10n.unassignedCourses,
                  value: unassignedCourses.toString(),
                  icon: Icons.warning_rounded,
                  gradient: LinearGradient(
                    colors: [
                      AdminColors.warning,
                      AdminColors.warning.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? AdminColors.darkSurface.withValues(alpha: 0.5)
            : AdminColors.lightBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AdminColors.darkCardBorder : AdminColors.lightDivider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: AdminColors.getTextColor(isDark),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: AdminColors.getTextSecondaryColor(isDark),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
