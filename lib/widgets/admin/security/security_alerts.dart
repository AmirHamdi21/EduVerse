import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

enum AlertSeverity { critical, high, medium, low }

class SecurityAlert {
  final String id;
  final String title;
  final String description;
  final String timestamp;
  final AlertSeverity severity;
  final bool isResolved;

  const SecurityAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.severity,
    this.isResolved = false,
  });
}

class SecurityAlertsCard extends StatelessWidget {
  final bool isDark;
  final List<SecurityAlert> alerts;
  final Function(SecurityAlert) onAlertTap;
  final Function(SecurityAlert) onResolve;
  final VoidCallback? onViewAll;

  const SecurityAlertsCard({
    super.key,
    required this.isDark,
    required this.alerts,
    required this.onAlertTap,
    required this.onResolve,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AdminColors.error.withValues(alpha: 0.3),
        ),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AdminColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.shield_outlined,
                      color: AdminColors.error,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.securityAlerts,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AdminColors.getTextColor(isDark),
                    ),
                  ),
                ],
              ),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: Text(
                    l10n.viewAll,
                    style: TextStyle(
                      fontSize: 13,
                      color: AdminColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (alerts.isEmpty)
            _buildEmptyState(l10n)
          else
            ...alerts.map((alert) => _buildAlertItem(context, alert)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.verified_user_rounded,
              size: 48,
              color: AdminColors.success,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noActiveAlerts,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AdminColors.success,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem(BuildContext context, SecurityAlert alert) {
    final l10n = AppLocalizations.of(context);
    
    return InkWell(
      onTap: () => onAlertTap(alert),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AdminColors.darkSurface : AdminColors.lightBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getSeverityColor(alert.severity).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getSeverityColor(alert.severity).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getSeverityIcon(alert.severity),
                size: 18,
                color: _getSeverityColor(alert.severity),
              ),
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
                            color: AdminColors.getTextColor(isDark),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getSeverityColor(alert.severity),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getSeverityLabel(alert.severity, l10n),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    alert.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: AdminColors.getTextSecondaryColor(isDark),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        alert.timestamp,
                        style: TextStyle(
                          fontSize: 11,
                          color: AdminColors.getTextTertiaryColor(isDark),
                        ),
                      ),
                      if (!alert.isResolved)
                        InkWell(
                          onTap: () => onResolve(alert),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AdminColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              l10n.resolve,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AdminColors.success,
                              ),
                            ),
                          ),
                        )
                      else
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 14,
                              color: AdminColors.success,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.resolved,
                              style: TextStyle(
                                fontSize: 12,
                                color: AdminColors.success,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return AdminColors.error;
      case AlertSeverity.high:
        return AdminColors.chartOrange;
      case AlertSeverity.medium:
        return AdminColors.warning;
      case AlertSeverity.low:
        return AdminColors.chartCyan;
    }
  }

  IconData _getSeverityIcon(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return Icons.error_rounded;
      case AlertSeverity.high:
        return Icons.warning_rounded;
      case AlertSeverity.medium:
        return Icons.info_rounded;
      case AlertSeverity.low:
        return Icons.info_outline_rounded;
    }
  }

  String _getSeverityLabel(AlertSeverity severity, AppLocalizations l10n) {
    switch (severity) {
      case AlertSeverity.critical:
        return l10n.critical;
      case AlertSeverity.high:
        return l10n.high;
      case AlertSeverity.medium:
        return l10n.medium;
      case AlertSeverity.low:
        return l10n.low;
    }
  }
}
