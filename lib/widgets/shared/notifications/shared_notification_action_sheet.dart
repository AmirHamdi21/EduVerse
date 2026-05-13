import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/notifications/notification_model.dart';
import 'shared_notification_role_theme.dart';

enum SharedNotificationCardAction { open, markRead, delete }

class SharedNotificationActionSheet extends StatelessWidget {
  const SharedNotificationActionSheet({
    super.key,
    required this.roleTheme,
    required this.notification,
  });

  final SharedNotificationRoleTheme roleTheme;
  final NotificationModel notification;

  static Future<SharedNotificationCardAction?> show({
    required BuildContext context,
    required SharedNotificationRoleTheme roleTheme,
    required NotificationModel notification,
  }) {
    return showModalBottomSheet<SharedNotificationCardAction>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SharedNotificationActionSheet(
        roleTheme: roleTheme,
        notification: notification,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            decoration: BoxDecoration(
              color: roleTheme.cardColor(isDark),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: roleTheme.borderColor(isDark)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.16),
                  blurRadius: 34,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: roleTheme.borderColor(isDark),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: roleTheme.headerGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.notifications_active_outlined,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.sharedNotifActions,
                              style: TextStyle(
                                color: roleTheme.textPrimary(isDark),
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              notification.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: roleTheme.textSecondary(isDark),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _ActionRow(
                    roleTheme: roleTheme,
                    icon: Icons.open_in_new_rounded,
                    label: l10n.sharedNotifOpen,
                    color: roleTheme.primary,
                    onTap: () => Navigator.of(
                      context,
                    ).pop(SharedNotificationCardAction.open),
                  ),
                  if (notification.allowsReadMutation && !notification.isRead)
                    _ActionRow(
                      roleTheme: roleTheme,
                      icon: Icons.mark_email_read_outlined,
                      label: l10n.markAsRead,
                      color: const Color(0xFF10B981),
                      onTap: () => Navigator.of(
                        context,
                      ).pop(SharedNotificationCardAction.markRead),
                    ),
                  if (notification.allowsDeleteMutation)
                    _ActionRow(
                      roleTheme: roleTheme,
                      icon: Icons.delete_outline_rounded,
                      label: l10n.delete,
                      color: const Color(0xFFEF4444),
                      onTap: () => Navigator.of(
                        context,
                      ).pop(SharedNotificationCardAction.delete),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.roleTheme,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final SharedNotificationRoleTheme roleTheme;
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: roleTheme.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDark ? 0.2 : 0.12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: color, size: 19),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: roleTheme.textPrimary(isDark),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: roleTheme.textSecondary(isDark),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
