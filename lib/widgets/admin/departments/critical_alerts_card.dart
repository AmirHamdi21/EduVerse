import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

class CriticalAlert {
  final String id;
  final String message;
  final String actionLabel;
  final AlertType type;

  const CriticalAlert({
    required this.id,
    required this.message,
    required this.actionLabel,
    required this.type,
  });
}

enum AlertType { staffing, head, aiTools }

class CriticalAlertsCard extends StatelessWidget {
  final bool isDark;
  final List<CriticalAlert> alerts;
  final Function(CriticalAlert) onAlertAction;

  const CriticalAlertsCard({
    super.key,
    required this.isDark,
    required this.alerts,
    required this.onAlertAction,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: AdminColors.error,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                l10n?.criticalAlerts ?? 'Critical Alerts',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AdminColors.getTextColor(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...alerts.map((alert) => _buildAlertItem(context, alert)),
        ],
      ),
    );
  }

  Widget _buildAlertItem(BuildContext context, CriticalAlert alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AdminColors.darkSurface : AdminColors.lightBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.getDividerColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            alert.message,
            style: TextStyle(
              fontSize: 13,
              color: AdminColors.getTextColor(isDark),
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () => onAlertAction(alert),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _getAlertColor(alert.type).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getAlertColor(alert.type).withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                alert.actionLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _getAlertColor(alert.type),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getAlertColor(AlertType type) {
    switch (type) {
      case AlertType.staffing:
        return AdminColors.warning;
      case AlertType.head:
        return AdminColors.chartPurple;
      case AlertType.aiTools:
        return AdminColors.primary;
    }
  }
}
