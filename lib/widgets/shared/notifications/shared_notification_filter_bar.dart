import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/notifications/notification_model.dart';
import 'shared_notification_role_theme.dart';

enum SharedNotificationStatusFilter { all, unread, read }

enum SharedNotificationTypeFilter {
  all,
  coursework,
  grades,
  discussions,
  schedule,
  announcements,
  system,
}

class SharedNotificationFilterBar extends StatelessWidget {
  const SharedNotificationFilterBar({
    super.key,
    required this.roleTheme,
    required this.statusFilter,
    required this.typeFilter,
    required this.onStatusChanged,
    required this.onTypeChanged,
  });

  final SharedNotificationRoleTheme roleTheme;
  final SharedNotificationStatusFilter statusFilter;
  final SharedNotificationTypeFilter typeFilter;
  final ValueChanged<SharedNotificationStatusFilter> onStatusChanged;
  final ValueChanged<SharedNotificationTypeFilter> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        Expanded(
          child: _FilterMenuButton<SharedNotificationStatusFilter>(
            title: l10n.sharedNotifStatusFilter,
            subtitle: statusFilter.label(l10n),
            icon: Icons.mark_email_read_outlined,
            color: roleTheme.primary,
            isActive: statusFilter != SharedNotificationStatusFilter.all,
            isDark: isDark,
            roleTheme: roleTheme,
            options: SharedNotificationStatusFilter.values,
            selected: statusFilter,
            optionLabel: (value) => value.label(l10n),
            optionIcon: (value) => value.icon,
            onSelected: onStatusChanged,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _FilterMenuButton<SharedNotificationTypeFilter>(
            title: l10n.sharedNotifTypeFilter,
            subtitle: typeFilter.label(l10n),
            icon: Icons.category_outlined,
            color: roleTheme.accent,
            isActive: typeFilter != SharedNotificationTypeFilter.all,
            isDark: isDark,
            roleTheme: roleTheme,
            options: SharedNotificationTypeFilter.values,
            selected: typeFilter,
            optionLabel: (value) => value.label(l10n),
            optionIcon: (value) => value.icon,
            onSelected: onTypeChanged,
          ),
        ),
      ],
    );
  }
}

class _FilterMenuButton<T> extends StatelessWidget {
  const _FilterMenuButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isActive,
    required this.isDark,
    required this.roleTheme,
    required this.options,
    required this.selected,
    required this.optionLabel,
    required this.optionIcon,
    required this.onSelected,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isActive;
  final bool isDark;
  final SharedNotificationRoleTheme roleTheme;
  final List<T> options;
  final T selected;
  final String Function(T value) optionLabel;
  final IconData Function(T value) optionIcon;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      position: PopupMenuPosition.under,
      offset: const Offset(0, 8),
      elevation: 16,
      color: roleTheme.cardColor(isDark),
      surfaceTintColor: Colors.transparent,
      constraints: const BoxConstraints(minWidth: 250, maxWidth: 340),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: roleTheme.borderColor(isDark)),
      ),
      onSelected: onSelected,
      itemBuilder: (context) => [
        PopupMenuItem<T>(
          enabled: false,
          height: 30,
          child: Text(
            title,
            style: TextStyle(
              color: roleTheme.textSecondary(isDark),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const PopupMenuDivider(height: 8),
        ...options.map(
          (option) => PopupMenuItem<T>(
            value: option,
            child: Row(
              children: [
                Icon(
                  option == selected
                      ? Icons.check_circle_rounded
                      : optionIcon(option),
                  size: 18,
                  color: option == selected
                      ? color
                      : roleTheme.textSecondary(isDark),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    optionLabel(option),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: option == selected
                          ? color
                          : roleTheme.textPrimary(isDark),
                      fontWeight: option == selected
                          ? FontWeight.w900
                          : FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      child: Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
        decoration: BoxDecoration(
          color: roleTheme.surfaceColor(isDark),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive ? color : roleTheme.borderColor(isDark),
            width: isActive ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 19),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: roleTheme.textPrimary(isDark),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isActive ? color : roleTheme.textSecondary(isDark),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: roleTheme.textSecondary(isDark),
            ),
          ],
        ),
      ),
    );
  }
}

extension SharedNotificationStatusFilterX on SharedNotificationStatusFilter {
  String label(AppLocalizations l10n) {
    switch (this) {
      case SharedNotificationStatusFilter.all:
        return l10n.sharedNotifAllStatuses;
      case SharedNotificationStatusFilter.unread:
        return l10n.unread;
      case SharedNotificationStatusFilter.read:
        return l10n.read;
    }
  }

  IconData get icon {
    switch (this) {
      case SharedNotificationStatusFilter.all:
        return Icons.all_inbox_outlined;
      case SharedNotificationStatusFilter.unread:
        return Icons.markunread_outlined;
      case SharedNotificationStatusFilter.read:
        return Icons.drafts_outlined;
    }
  }
}

extension SharedNotificationTypeFilterX on SharedNotificationTypeFilter {
  String label(AppLocalizations l10n) {
    switch (this) {
      case SharedNotificationTypeFilter.all:
        return l10n.sharedNotifAllTypes;
      case SharedNotificationTypeFilter.coursework:
        return l10n.sharedNotifCoursework;
      case SharedNotificationTypeFilter.grades:
        return l10n.sharedNotifGrades;
      case SharedNotificationTypeFilter.discussions:
        return l10n.sharedNotifDiscussions;
      case SharedNotificationTypeFilter.schedule:
        return l10n.sharedNotifSchedule;
      case SharedNotificationTypeFilter.announcements:
        return l10n.sharedNotifAnnouncements;
      case SharedNotificationTypeFilter.system:
        return l10n.sharedNotifSystem;
    }
  }

  IconData get icon {
    switch (this) {
      case SharedNotificationTypeFilter.all:
        return Icons.category_outlined;
      case SharedNotificationTypeFilter.coursework:
        return Icons.assignment_turned_in_outlined;
      case SharedNotificationTypeFilter.grades:
        return Icons.grading_outlined;
      case SharedNotificationTypeFilter.discussions:
        return Icons.forum_outlined;
      case SharedNotificationTypeFilter.schedule:
        return Icons.event_note_outlined;
      case SharedNotificationTypeFilter.announcements:
        return Icons.campaign_outlined;
      case SharedNotificationTypeFilter.system:
        return Icons.settings_outlined;
    }
  }

  bool matches(NotificationModel notification) {
    switch (this) {
      case SharedNotificationTypeFilter.all:
        return true;
      case SharedNotificationTypeFilter.coursework:
        return {
          NotificationType.assignment,
          NotificationType.lab,
          NotificationType.quiz,
          NotificationType.material,
          NotificationType.enrollment,
        }.contains(notification.type);
      case SharedNotificationTypeFilter.grades:
        return notification.type == NotificationType.grade;
      case SharedNotificationTypeFilter.discussions:
        return {
          NotificationType.discussion,
          NotificationType.message,
          NotificationType.community,
        }.contains(notification.type);
      case SharedNotificationTypeFilter.schedule:
        return {
          NotificationType.deadline,
          NotificationType.schedule,
          NotificationType.officeHours,
        }.contains(notification.type);
      case SharedNotificationTypeFilter.announcements:
        return notification.type == NotificationType.announcement;
      case SharedNotificationTypeFilter.system:
        return {
          NotificationType.system,
          NotificationType.unknown,
        }.contains(notification.type);
    }
  }
}
