import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../config/app_theme.dart';
import '../../../models/notifications/notification_model.dart';
import '../../../generated_l10n/app_localizations.dart';

class SystemAlertCard extends StatelessWidget {
  final SystemAlertModel alert;
  final bool isDarkMode;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;

  const SystemAlertCard({
    super.key,
    required this.alert,
    required this.isDarkMode,
    this.onDismiss,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = _getAlertColors(alert.alertType);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getAlertIcon(alert.alertType),
              color: colors,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          // Content
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
                          color: isDarkMode
                              ? AppTheme.darkTextPrimary
                              : AppTheme.textDark,
                        ),
                      ),
                    ),
                    // Close button
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onDismiss?.call();
                      },
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: isDarkMode
                            ? AppTheme.darkTextSecondary
                            : AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  alert.message,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode
                        ? AppTheme.darkTextSecondary
                        : AppTheme.textLight,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(alert.createdAt, l10n),
                  style: TextStyle(
                    fontSize: 10,
                    color: isDarkMode
                        ? AppTheme.darkTextSecondary.withValues(alpha: 0.6)
                        : AppTheme.textLight.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getAlertIcon(SystemAlertType type) {
    switch (type) {
      case SystemAlertType.update:
        return Icons.system_update_outlined;
      case SystemAlertType.maintenance:
        return Icons.build_circle_outlined;
      case SystemAlertType.announcement:
        return Icons.campaign_outlined;
      case SystemAlertType.warning:
        return Icons.warning_amber_outlined;
    }
  }

  Color _getAlertColors(SystemAlertType type) {
    switch (type) {
      case SystemAlertType.update:
        return AppTheme.primaryColor;
      case SystemAlertType.maintenance:
        return AppTheme.warningColor;
      case SystemAlertType.announcement:
        return const Color(0xFF9B59B6);
      case SystemAlertType.warning:
        return AppTheme.errorColor;
    }
  }

  String _formatTime(DateTime dateTime, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return l10n.notificationJustNow;
    } else if (difference.inMinutes < 60) {
      return l10n.notificationMinutesAgo(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return l10n.notificationHoursAgo(difference.inHours);
    } else if (difference.inDays == 1) {
      return l10n.notificationYesterday;
    } else if (difference.inDays < 7) {
      return l10n.notificationDaysAgo(difference.inDays);
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
