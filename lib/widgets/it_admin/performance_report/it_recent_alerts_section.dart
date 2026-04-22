import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_performance_report_barrel.dart';

class ITRecentAlertsSection extends StatelessWidget {
  final bool isDark;
  final List<PerformanceAlert> alerts;
  final ValueChanged<PerformanceAlert>? onAlertTap;
  final VoidCallback? onViewAll;

  const ITRecentAlertsSection({
    super.key,
    required this.isDark,
    required this.alerts,
    this.onAlertTap,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? ITColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.1),
        ),
        boxShadow: isDark ? null : ITColors.cardShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ITColors.warning.withValues(alpha: 0.2),
                      ITColors.orange.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.notifications_active_rounded,
                  color: ITColors.warning,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Alerts',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ITColors.textPrimaryColor(isDark),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _buildAlertCount(
                          alerts
                              .where(
                                (a) => a.severity == AlertSeverity.critical,
                              )
                              .length,
                          ITColors.error,
                        ),
                        const SizedBox(width: 8),
                        _buildAlertCount(
                          alerts
                              .where((a) => a.severity == AlertSeverity.warning)
                              .length,
                          ITColors.warning,
                        ),
                        const SizedBox(width: 8),
                        _buildAlertCount(
                          alerts
                              .where((a) => a.severity == AlertSeverity.info)
                              .length,
                          ITColors.info,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ITColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Alerts List
          ...alerts.take(5).map((alert) => _buildAlertCard(alert)),

          if (alerts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 48,
                      color: ITColors.success,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No recent alerts',
                      style: TextStyle(
                        fontSize: 14,
                        color: ITColors.textSecondaryColor(isDark),
                      ),
                    ),
                    Text(
                      'System is running smoothly',
                      style: TextStyle(fontSize: 12, color: ITColors.success),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAlertCount(int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        count.toString(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildAlertCard(PerformanceAlert alert) {
    return GestureDetector(
      onTap: () => onAlertTap?.call(alert),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.03)
              : alert.severityColor.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : alert.severityColor.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: alert.severityColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(alert.typeIcon, size: 20, color: alert.severityColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          alert.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ITColors.textPrimaryColor(isDark),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: alert.severityColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          alert.severityText,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: alert.severityColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alert.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: ITColors.textSecondaryColor(isDark),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: ITColors.textSecondaryColor(isDark),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTimestamp(alert.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: ITColors.textSecondaryColor(isDark),
                        ),
                      ),
                      if (alert.isResolved) ...[
                        const SizedBox(width: 12),
                        Icon(
                          Icons.check_circle_rounded,
                          size: 12,
                          color: ITColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Resolved',
                          style: TextStyle(
                            fontSize: 11,
                            color: ITColors.success,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: ITColors.textSecondaryColor(isDark),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}
