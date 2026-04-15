import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/ta_colors.dart';

class TAResponsePerformance extends StatelessWidget {
  final bool isDark;
  final String avgResponseTime;
  final int messagesToday;
  final int aiRepliesUsed;
  final String aiRepliesTrend;

  const TAResponsePerformance({
    super.key,
    required this.isDark,
    required this.avgResponseTime,
    required this.messagesToday,
    required this.aiRepliesUsed,
    required this.aiRepliesTrend,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights_rounded, color: TAColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                l10n.taNotifResponsePerformance,
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatRow(
            label: l10n.taNotifAvgResponseTime,
            value: avgResponseTime,
            color: TAColors.info,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            label: l10n.taNotifMessagesToday,
            value: messagesToday.toString(),
            color: TAColors.teal,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            label: l10n.taNotifAIRepliesUsed,
            value: aiRepliesUsed.toString(),
            trend: aiRepliesTrend,
            color: TAColors.primary,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required String label,
    required String value,
    String? trend,
    required Color color,
    required bool isDark,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontSize: 13,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (trend != null) ...[
          const SizedBox(width: 8),
          Text(
            trend,
            style: TextStyle(
              color: TAColors.success,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
