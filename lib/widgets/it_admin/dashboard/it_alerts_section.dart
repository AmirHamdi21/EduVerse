import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import '../../../generated_l10n/app_localizations.dart';

class ITAlertsSection extends StatelessWidget {
  final bool isDark;
  final List<ITAlert> alerts;
  final VoidCallback? onViewAll;
  final Function(ITAlert)? onAlertTap;
  final Function(ITAlert)? onDismiss;

  const ITAlertsSection({
    super.key,
    required this.isDark,
    required this.alerts,
    this.onViewAll,
    this.onAlertTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.white.withValues(alpha: 0.8),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : ITColors.border,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: ITColors.lightCardShadow(isDark),
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
                      color: ITColors.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Stack(
                      children: [
                        Icon(
                          Icons.notifications_active_rounded,
                          color: ITColors.error,
                          size: 20,
                        ),
                        if (alerts.isNotEmpty)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: ITColors.error,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark
                                      ? ITColors.darkCard
                                      : Colors.white,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.itSystemAlerts,
                        style: TextStyle(
                          color: ITColors.textPrimaryColor(isDark),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${alerts.length} ${l10n.itPendingAlerts}',
                        style: TextStyle(
                          color: ITColors.textTertiaryColor(isDark),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: Text(
                    l10n.itViewAll,
                    style: TextStyle(
                      color: ITColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (alerts.isEmpty)
            _buildEmptyState(l10n)
          else
            Column(
              children:
                  alerts.map((alert) => _buildAlertItem(alert, l10n)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.notifications_none_rounded,
            color: ITColors.success,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.itNoAlerts,
            style: TextStyle(
              color: ITColors.textPrimaryColor(isDark),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.itAllClear,
            style: TextStyle(
              color: ITColors.textTertiaryColor(isDark),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(ITAlert alert, AppLocalizations l10n) {
    final severityColor = _getSeverityColor(alert.severity);

    return Dismissible(
      key: Key(alert.id),
      direction: onDismiss != null
          ? DismissDirection.endToStart
          : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: ITColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.close_rounded,
          color: ITColors.error,
        ),
      ),
      onDismissed: (_) => onDismiss?.call(alert),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onAlertTap?.call(alert),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? severityColor.withValues(alpha: 0.1)
                    : severityColor.withValues(alpha: 0.08),
                border: Border.all(
                  color: severityColor.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: severityColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getSeverityIcon(alert.severity),
                      color: severityColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: severityColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                alert.severity.toUpperCase(),
                                style: TextStyle(
                                  color: severityColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              alert.time,
                              style: TextStyle(
                                color: ITColors.textTertiaryColor(isDark),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          alert.message,
                          style: TextStyle(
                            color: ITColors.textPrimaryColor(isDark),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: ITColors.textTertiaryColor(isDark),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return ITColors.critical;
      case 'high':
      case 'error':
        return ITColors.error;
      case 'medium':
      case 'warning':
        return ITColors.warning;
      case 'low':
      case 'info':
        return ITColors.info;
      default:
        return ITColors.textSecondary;
    }
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Icons.dangerous_rounded;
      case 'high':
      case 'error':
        return Icons.error_rounded;
      case 'medium':
      case 'warning':
        return Icons.warning_rounded;
      case 'low':
      case 'info':
        return Icons.info_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }
}

class ITAlert {
  final String id;
  final String message;
  final String severity;
  final String source;
  final String time;

  ITAlert({
    required this.id,
    required this.message,
    required this.severity,
    required this.source,
    required this.time,
  });
}
