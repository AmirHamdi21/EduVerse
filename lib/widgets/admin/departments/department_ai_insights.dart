import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

class DepartmentAiInsights extends StatelessWidget {
  final bool isDark;
  final String mostActiveDepartment;
  final double mostActiveProgress;
  final String underperformingDepartment;
  final double underperformingProgress;
  final int staffShortageCount;
  final VoidCallback onViewDetails;

  const DepartmentAiInsights({
    super.key,
    required this.isDark,
    required this.mostActiveDepartment,
    required this.mostActiveProgress,
    required this.underperformingDepartment,
    required this.underperformingProgress,
    required this.staffShortageCount,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AdminColors.primary.withValues(alpha: 0.05),
            AdminColors.secondary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AdminColors.primary.withValues(alpha: 0.2),
        ),
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
                  gradient: AdminColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n?.aiInsights ?? 'AI Insights',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AdminColors.getTextColor(isDark),
                    ),
                  ),
                  Text(
                    l10n?.departmentAnalytics ?? 'Department analytics',
                    style: TextStyle(
                      fontSize: 12,
                      color: AdminColors.getTextTertiaryColor(isDark),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Most Active
          _buildInsightItem(
            icon: Icons.trending_up_rounded,
            label: l10n?.mostActive ?? 'Most Active',
            value: mostActiveDepartment,
            progress: mostActiveProgress,
            progressColor: AdminColors.success,
          ),
          const SizedBox(height: 16),
          // Underperforming
          _buildInsightItem(
            icon: Icons.trending_down_rounded,
            label: l10n?.underperforming ?? 'Underperforming',
            value: underperformingDepartment,
            progress: underperformingProgress,
            progressColor: AdminColors.error,
          ),
          const SizedBox(height: 16),
          // Staff Shortage
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AdminColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: AdminColors.warning,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n?.staffShortage ?? 'Staff Shortage',
                    style: TextStyle(
                      fontSize: 13,
                      color: AdminColors.getTextColor(isDark),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AdminColors.warning,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$staffShortageCount ${l10n?.departments ?? 'departments'}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
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

  Widget _buildInsightItem({
    required IconData icon,
    required String label,
    required String value,
    required double progress,
    required Color progressColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: progressColor,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AdminColors.getTextTertiaryColor(isDark),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AdminColors.getTextColor(isDark),
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AdminColors.getDividerColor(isDark),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
