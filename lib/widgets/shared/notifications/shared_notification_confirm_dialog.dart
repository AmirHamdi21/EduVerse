import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import 'shared_notification_role_theme.dart';

class SharedNotificationConfirmDialog extends StatelessWidget {
  const SharedNotificationConfirmDialog({
    super.key,
    required this.roleTheme,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.icon,
    this.isDestructive = false,
  });

  final SharedNotificationRoleTheme roleTheme;
  final String title;
  final String message;
  final String confirmLabel;
  final IconData icon;
  final bool isDestructive;

  static Future<bool> show({
    required BuildContext context,
    required SharedNotificationRoleTheme roleTheme,
    required String title,
    required String message,
    required String confirmLabel,
    required IconData icon,
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => SharedNotificationConfirmDialog(
        roleTheme: roleTheme,
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        icon: icon,
        isDestructive: isDestructive,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final actionColor = isDestructive
        ? const Color(0xFFEF4444)
        : roleTheme.primary;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Container(
          decoration: BoxDecoration(
            color: roleTheme.cardColor(isDark),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: roleTheme.borderColor(isDark)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.38 : 0.14),
                blurRadius: 34,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      actionColor.withValues(alpha: isDark ? 0.26 : 0.16),
                      actionColor.withValues(alpha: isDark ? 0.10 : 0.06),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: actionColor.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(icon, color: actionColor, size: 25),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: roleTheme.textPrimary(isDark),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: roleTheme.surfaceColor(isDark),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: roleTheme.borderColor(isDark),
                        ),
                      ),
                      child: Text(
                        message,
                        style: TextStyle(
                          color: roleTheme.textSecondary(isDark),
                          fontSize: 14,
                          height: 1.45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.of(context).pop(false),
                            icon: const Icon(Icons.close_rounded, size: 18),
                            label: Text(l10n.cancel),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: roleTheme.textSecondary(isDark),
                              side: BorderSide(
                                color: roleTheme.borderColor(isDark),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: FilledButton.icon(
                            onPressed: () => Navigator.of(context).pop(true),
                            icon: Icon(icon, size: 18),
                            label: Text(confirmLabel),
                            style: FilledButton.styleFrom(
                              backgroundColor: actionColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
