import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'system_health_models.dart';

class SystemHealthAlertsSection extends StatelessWidget {
  final bool isDark;
  final List<HealthAlert> alerts;
  final Function(HealthAlert) onAlertTap;
  final VoidCallback onViewAll;

  const SystemHealthAlertsSection({
    super.key,
    required this.isDark,
    required this.alerts,
    required this.onAlertTap,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Alerts',
              style: TextStyle(
                color: ITColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: onViewAll,
              child: Text(
                'View All',
                style: TextStyle(color: ITColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (alerts.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: ITColors.successLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: ITColors.success, size: 24),
                const SizedBox(width: 12),
                Text(
                  'No active alerts - System running smoothly',
                  style: TextStyle(
                    color: ITColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        else
          ...alerts.take(3).map((alert) => _buildAlertItem(alert)),
      ],
    );
  }

  Widget _buildAlertItem(HealthAlert alert) {
    final severityColor = ITColors.getPriorityColor(alert.severity);

    return GestureDetector(
      onTap: () => onAlertTap(alert),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: severityColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: severityColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: severityColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                alert.severity == 'critical'
                    ? Icons.error_rounded
                    : Icons.warning_rounded,
                color: severityColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.title,
                    style: TextStyle(
                      color: ITColors.textPrimaryColor(isDark),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    alert.source,
                    style: TextStyle(
                      color: ITColors.textSecondaryColor(isDark),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              alert.time,
              style: TextStyle(
                color: ITColors.textTertiaryColor(isDark),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
