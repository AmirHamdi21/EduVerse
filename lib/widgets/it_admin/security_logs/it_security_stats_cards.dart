import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_security_logs_barrel.dart';

class ITSecurityStatsCards extends StatelessWidget {
  final bool isDark;
  final SecurityStats stats;
  final VoidCallback? onViewAllEvents;
  final VoidCallback? onInvestigateBreaches;

  const ITSecurityStatsCards({
    super.key,
    required this.isDark,
    required this.stats,
    this.onViewAllEvents,
    this.onInvestigateBreaches,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // First row
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.verified_user_rounded,
                iconColor: ITColors.primary,
                title: 'Auth Events',
                subtitle: '24 hours',
                value: _formatNumber(stats.authEvents24h),
                trend: stats.authEventsTrend,
                actionLabel: 'View All Events',
                onAction: onViewAllEvents,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.error_outline_rounded,
                iconColor: ITColors.error,
                title: 'Failed Logins',
                subtitle: '24 hours',
                value: stats.failedLogins24h.toString(),
                note: stats.failedLoginsNote,
                noteColor: ITColors.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Second row
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.gpp_bad_rounded,
                iconColor: ITColors.orange,
                title: 'Breach Attempts',
                subtitle: 'Active incidents',
                value: stats.breachAttempts.toString(),
                actionLabel: 'Investigate Now',
                onAction: onInvestigateBreaches,
                isWarning: stats.breachAttempts > 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.admin_panel_settings_rounded,
                iconColor: ITColors.purple,
                title: 'Privilege Changes',
                subtitle: 'Last 7 days',
                value: stats.privilegeChanges7d.toString(),
                badge: '${stats.authorizedChanges} authorized changes',
                badgeColor: ITColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String value,
    double? trend,
    String? note,
    Color? noteColor,
    String? badge,
    Color? badgeColor,
    String? actionLabel,
    VoidCallback? onAction,
    bool isWarning = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ITColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWarning
              ? ITColors.orange.withValues(alpha: 0.3)
              : (isDark ? Colors.white.withValues(alpha: 0.1) : ITColors.border),
        ),
        boxShadow: ITColors.lightCardShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const Spacer(),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (trend >= 0 ? ITColors.success : ITColors.error)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trend >= 0
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        color: trend >= 0 ? ITColors.success : ITColors.error,
                        size: 12,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${trend >= 0 ? '+' : ''}${trend.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: trend >= 0 ? ITColors.success : ITColors.error,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: ITColors.textTertiaryColor(isDark),
              fontSize: 11,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: ITColors.textTertiaryColor(isDark),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: ITColors.textPrimaryColor(isDark),
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (note != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 12, color: noteColor),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    note,
                    style: TextStyle(
                      color: noteColor ?? ITColors.textTertiaryColor(isDark),
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          if (badge != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (badgeColor ?? ITColors.success).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 12,
                    color: badgeColor ?? ITColors.success,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      badge,
                      style: TextStyle(
                        color: badgeColor ?? ITColors.success,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onAction,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionLabel,
                    style: TextStyle(
                      color: ITColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: ITColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
