import 'package:flutter/material.dart';
import '../../../models/instructor/reports_model.dart';
import 'reports_colors.dart';

/// Grade distribution chart for analytics tab
class GradeDistributionCard extends StatelessWidget {
  final GradeDistribution distribution;
  final bool isDark;

  const GradeDistributionCard({
    super.key,
    required this.distribution,
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
                  Icons.bar_chart_rounded,
                  color: ReportsColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Grade Distribution',
                style: TextStyle(
                  color: ReportsColors.textPrimaryColor(isDark),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Distribution bars
          _buildGradeBar('A (90-100%)', distribution.gradeA, ReportsColors.gradeA, isDark),
          const SizedBox(height: 16),
          _buildGradeBar('B (80-89%)', distribution.gradeB, ReportsColors.gradeB, isDark),
          const SizedBox(height: 16),
          _buildGradeBar('C (70-79%)', distribution.gradeC, ReportsColors.gradeC, isDark),
          const SizedBox(height: 16),
          _buildGradeBar('D (60-69%)', distribution.gradeD, ReportsColors.gradeD, isDark),
          const SizedBox(height: 16),
          _buildGradeBar('F (Below 60%)', distribution.gradeF, ReportsColors.gradeF, isDark),
        ],
      ),
    );
  }

  Widget _buildGradeBar(String label, int count, Color color, bool isDark) {
    final maxCount = [
      distribution.gradeA,
      distribution.gradeB,
      distribution.gradeC,
      distribution.gradeD,
      distribution.gradeF,
    ].reduce((a, b) => a > b ? a : b);
    
    final percentage = maxCount > 0 ? count / maxCount : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: ReportsColors.textSecondaryColor(isDark),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              count == 1 ? '1 student' : '$count students',
              style: TextStyle(
                color: ReportsColors.textPrimaryColor(isDark),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: ReportsColors.borderColor(isDark),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

