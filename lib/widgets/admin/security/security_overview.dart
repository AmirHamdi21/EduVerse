import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

class SecurityOverviewCard extends StatelessWidget {
  final bool isDark;
  final int totalEvents;
  final int failedLogins;
  final int securityAlerts;
  final int activeSessions;
  final Function(String) onCardTap;

  const SecurityOverviewCard({
    super.key,
    required this.isDark,
    required this.totalEvents,
    required this.failedLogins,
    required this.securityAlerts,
    required this.activeSessions,
    required this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          title: l10n.totalEvents,
          value: _formatNumber(totalEvents),
          icon: Icons.event_note_rounded,
          color: AdminColors.primary,
          trend: '+12%',
          isPositive: true,
          onTap: () => onCardTap('totalEvents'),
        ),
        _buildStatCard(
          title: l10n.failedLogins,
          value: failedLogins.toString(),
          icon: Icons.error_outline_rounded,
          color: AdminColors.error,
          trend: '-5%',
          isPositive: true,
          onTap: () => onCardTap('failedLogins'),
        ),
        _buildStatCard(
          title: l10n.securityAlerts,
          value: securityAlerts.toString(),
          icon: Icons.warning_amber_rounded,
          color: AdminColors.warning,
          trend: '+2',
          isPositive: false,
          onTap: () => onCardTap('securityAlerts'),
        ),
        _buildStatCard(
          title: l10n.activeSessions,
          value: _formatNumber(activeSessions),
          icon: Icons.devices_rounded,
          color: AdminColors.success,
          trend: '+8%',
          isPositive: true,
          onTap: () => onCardTap('activeSessions'),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String trend,
    required bool isPositive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AdminColors.getCardColor(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (isPositive ? AdminColors.success : AdminColors.error)
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        size: 12,
                        color: isPositive
                            ? AdminColors.success
                            : AdminColors.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trend,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isPositive
                              ? AdminColors.success
                              : AdminColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.getTextColor(isDark),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: AdminColors.getTextSecondaryColor(isDark),
                  ),
                ),
              ],
            ),
          ],
        ),
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
