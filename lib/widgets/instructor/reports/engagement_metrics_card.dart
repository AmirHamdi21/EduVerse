import 'package:flutter/material.dart';
import '../../../models/instructor/reports_model.dart';
import 'reports_colors.dart';

/// Engagement metrics card for analytics tab
class EngagementMetricsCard extends StatelessWidget {
  final EngagementMetrics metrics;
  final bool isDark;

  const EngagementMetricsCard({
    super.key,
    required this.metrics,
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
                  color: ReportsColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.insights_rounded,
                  color: ReportsColors.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Engagement Metrics',
                style: TextStyle(
                  color: ReportsColors.textPrimaryColor(isDark),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Metrics list
          _buildMetricRow(
            'Assignment Submission Rate',
            metrics.assignmentSubmissionRate,
            ReportsColors.gradeA,
            isDark,
          ),
          const SizedBox(height: 16),
          _buildMetricRow(
            'Lab Completion Rate',
            metrics.labCompletionRate,
            ReportsColors.gradeB,
            isDark,
          ),
          const SizedBox(height: 16),
          _buildMetricRow(
            'Discussion Participation',
            metrics.discussionParticipation,
            ReportsColors.gradeC,
            isDark,
          ),
          if (metrics.videoWatchRate > 0) ...[
            const SizedBox(height: 16),
            _buildMetricRow(
              'Video Watch Rate',
              metrics.videoWatchRate,
              ReportsColors.teal,
              isDark,
            ),
          ],
          if (metrics.resourceAccessRate > 0) ...[
            const SizedBox(height: 16),
            _buildMetricRow(
              'Resource Access Rate',
              metrics.resourceAccessRate,
              ReportsColors.cyan,
              isDark,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, double value, Color color, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: ReportsColors.textSecondaryColor(isDark),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '${value.toStringAsFixed(0)}%',
              style: TextStyle(
                color: ReportsColors.textPrimaryColor(isDark),
                fontSize: 14,
                fontWeight: FontWeight.w700,
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
            widthFactor: value / 100,
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

