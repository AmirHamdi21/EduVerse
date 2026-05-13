import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import 'shared_notification_role_theme.dart';

enum SharedNotificationToolAction {
  swipeSettings,
  markAllRead,
  clearRead,
  clearAll,
}

class SharedNotificationHeader extends StatelessWidget {
  const SharedNotificationHeader({
    super.key,
    required this.roleTheme,
    required this.totalCount,
    required this.unreadCount,
    required this.isRealtimeConnected,
    required this.canMarkAllRead,
    required this.canClearRead,
    required this.canClearAll,
    required this.onBack,
    required this.onToolAction,
  });

  final SharedNotificationRoleTheme roleTheme;
  final int totalCount;
  final int unreadCount;
  final bool isRealtimeConnected;
  final bool canMarkAllRead;
  final bool canClearRead;
  final bool canClearAll;
  final VoidCallback onBack;
  final ValueChanged<SharedNotificationToolAction> onToolAction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final readCount = (totalCount - unreadCount).clamp(0, totalCount);
    final readRate = totalCount == 0
        ? 0
        : ((readCount / totalCount) * 100).round();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: isDark
            ? roleTheme.darkHeaderGradient
            : roleTheme.headerGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: roleTheme.primary.withValues(alpha: isDark ? 0.22 : 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _HeaderIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: onBack,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.sharedNotifTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.sharedNotifSubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _RealtimePill(isConnected: isRealtimeConnected),
              const SizedBox(width: 8),
              _ToolsMenuButton(
                canMarkAllRead: canMarkAllRead,
                canClearRead: canClearRead,
                canClearAll: canClearAll,
                onSelected: onToolAction,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _HeaderStat(
                  label: l10n.sharedNotifUnreadStat,
                  value: unreadCount.toString(),
                  icon: Icons.markunread_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HeaderStat(
                  label: l10n.sharedNotifTotalStat,
                  value: totalCount.toString(),
                  icon: Icons.notifications_none_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HeaderStat(
                  label: l10n.sharedNotifReadRateStat,
                  value: '$readRate%',
                  icon: Icons.done_all_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

class _RealtimePill extends StatelessWidget {
  const _RealtimePill({required this.isConnected});

  final bool isConnected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Tooltip(
      message: isConnected
          ? l10n.sharedNotifRealtimeConnected
          : l10n.sharedNotifRealtimeDisconnected,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          isConnected
              ? Icons.wifi_tethering_rounded
              : Icons.wifi_tethering_error_rounded,
          color: isConnected
              ? const Color(0xFFBBF7D0)
              : const Color(0xFFFDE68A),
          size: 18,
        ),
      ),
    );
  }
}

class _ToolsMenuButton extends StatelessWidget {
  const _ToolsMenuButton({
    required this.canMarkAllRead,
    required this.canClearRead,
    required this.canClearAll,
    required this.onSelected,
  });

  final bool canMarkAllRead;
  final bool canClearRead;
  final bool canClearAll;
  final ValueChanged<SharedNotificationToolAction> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopupMenuButton<SharedNotificationToolAction>(
      position: PopupMenuPosition.under,
      offset: const Offset(0, 8),
      elevation: 16,
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1E293B)
          : Colors.white,
      surfaceTintColor: Colors.transparent,
      constraints: const BoxConstraints(minWidth: 260, maxWidth: 330),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
      ),
      onSelected: onSelected,
      itemBuilder: (context) => [
        _toolHeader(context, l10n.sharedNotifTools),
        _toolItem(
          context,
          action: SharedNotificationToolAction.swipeSettings,
          icon: Icons.swipe_rounded,
          label: l10n.sharedNotifSwipeSettings,
          enabled: true,
        ),
        const PopupMenuDivider(height: 8),
        _toolItem(
          context,
          action: SharedNotificationToolAction.markAllRead,
          icon: Icons.done_all_rounded,
          label: l10n.notificationMarkAllRead,
          enabled: canMarkAllRead,
        ),
        _toolItem(
          context,
          action: SharedNotificationToolAction.clearRead,
          icon: Icons.cleaning_services_outlined,
          label: l10n.notificationClearRead,
          enabled: canClearRead,
        ),
        _toolItem(
          context,
          action: SharedNotificationToolAction.clearAll,
          icon: Icons.delete_sweep_outlined,
          label: l10n.notificationClearAll,
          enabled: canClearAll,
          destructive: true,
        ),
      ],
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.more_horiz_rounded, color: Colors.white),
      ),
    );
  }

  PopupMenuItem<SharedNotificationToolAction> _toolHeader(
    BuildContext context,
    String label,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopupMenuItem<SharedNotificationToolAction>(
      enabled: false,
      height: 30,
      child: Text(
        label,
        style: TextStyle(
          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  PopupMenuItem<SharedNotificationToolAction> _toolItem(
    BuildContext context, {
    required SharedNotificationToolAction action,
    required IconData icon,
    required String label,
    required bool enabled,
    bool destructive = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = !enabled
        ? const Color(0xFF94A3B8)
        : destructive
        ? const Color(0xFFEF4444)
        : (isDark ? Colors.white : const Color(0xFF0F172A));
    return PopupMenuItem<SharedNotificationToolAction>(
      value: action,
      enabled: enabled,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.82), size: 16),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.76),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
