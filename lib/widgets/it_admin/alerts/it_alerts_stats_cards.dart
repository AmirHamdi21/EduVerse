import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_alerts_barrel.dart';

class ITAlertsStatsCards extends StatelessWidget {
  final bool isDark;
  final AlertStats stats;
  final VoidCallback? onViewHistory;
  final VoidCallback? onManageWindows;

  const ITAlertsStatsCards({
    super.key,
    required this.isDark,
    required this.stats,
    this.onViewHistory,
    this.onManageWindows,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.warning_amber_rounded,
                iconColor: ITColors.error,
                label: 'Active Alerts',
                value: stats.activeAlerts.toString(),
                history: stats.activeHistory,
                historyColor: ITColors.error,
                badge: 'Active',
                badgeColor: ITColors.error,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.check_circle_outline_rounded,
                iconColor: ITColors.success,
                label: 'Resolved (24h)',
                value: stats.resolvedAlerts.toString(),
                history: stats.resolvedHistory,
                historyColor: ITColors.success,
                actionLabel: 'View History',
                onAction: onViewHistory,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.do_not_disturb_on_rounded,
                iconColor: ITColors.purple,
                label: 'Suppressed (24h)',
                value: stats.suppressedAlerts.toString(),
                badge: 'Muted',
                badgeColor: ITColors.purple,
                actionLabel: 'Manage Windows',
                onAction: onManageWindows,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildNoiseScoreCard(stats.noiseScore),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    List<int>? history,
    Color? historyColor,
    String? badge,
    Color? badgeColor,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ITColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ITColors.cardShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const Spacer(),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor?.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: badgeColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: ITColors.textPrimaryColor(isDark),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: ITColors.textSecondaryColor(isDark),
            ),
          ),
          if (history != null && history.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 30,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: history.map((h) {
                  final maxH = history.reduce((a, b) => a > b ? a : b);
                  final height = maxH > 0 ? (h / maxH) * 24 + 4 : 4.0;
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      height: height,
                      decoration: BoxDecoration(
                        color: historyColor?.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          if (actionLabel != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ITColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoiseScoreCard(int score) {
    final Color scoreColor;
    final String label;
    if (score >= 70) {
      scoreColor = ITColors.success;
      label = 'Good';
    } else if (score >= 40) {
      scoreColor = ITColors.warning;
      label = 'Fair';
    } else {
      scoreColor = ITColors.error;
      label = 'Poor';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ITColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ITColors.cardShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ITColors.info.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.auto_graph_rounded, color: ITColors.info, size: 20),
              ),
              const Spacer(),
              Icon(Icons.tune_rounded, size: 18, color: ITColors.textSecondaryColor(isDark)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                score.toString(),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: ITColors.textPrimaryColor(isDark),
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: scoreColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: scoreColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Noise Score (AI)',
            style: TextStyle(
              fontSize: 12,
              color: ITColors.textSecondaryColor(isDark),
            ),
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: score / 100,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [scoreColor, scoreColor.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
