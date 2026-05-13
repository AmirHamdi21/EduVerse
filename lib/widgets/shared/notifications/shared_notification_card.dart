import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/notifications/notification_model.dart';
import 'shared_notification_role_theme.dart';

class SharedNotificationCard extends StatelessWidget {
  const SharedNotificationCard({
    super.key,
    required this.roleTheme,
    required this.notification,
    required this.onTap,
    required this.onMore,
  });

  final SharedNotificationRoleTheme roleTheme;
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typeColor = _typeColor(notification.type);
    final isUnread = !notification.isRead;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          onLongPress: onMore,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            decoration: BoxDecoration(
              color: roleTheme.cardColor(isDark),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isUnread
                    ? roleTheme.primary.withValues(alpha: isDark ? 0.42 : 0.34)
                    : roleTheme.borderColor(isDark),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                if (isUnread)
                  PositionedDirectional(
                    start: 0,
                    top: 16,
                    bottom: 16,
                    child: Container(
                      width: 4,
                      decoration: BoxDecoration(
                        color: roleTheme.primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 13, 10, 13),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _IconTile(
                        icon: _typeIcon(notification.type),
                        color: typeColor,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    notification.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: roleTheme.textPrimary(isDark),
                                      fontSize: 14.5,
                                      height: 1.18,
                                      fontWeight: isUnread
                                          ? FontWeight.w900
                                          : FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _relativeTime(l10n, notification.createdAt),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: roleTheme.textTertiary(isDark),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              notification.message,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: roleTheme.textSecondary(isDark),
                                fontSize: 12.2,
                                height: 1.34,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 7,
                              runSpacing: 7,
                              children: [
                                _MiniChip(
                                  label: _typeLabel(l10n, notification.type),
                                  icon: _typeIcon(notification.type),
                                  color: typeColor,
                                  isDark: isDark,
                                ),
                                if (notification.courseName
                                        ?.trim()
                                        .isNotEmpty ??
                                    false)
                                  _MiniChip(
                                    label: notification.courseName!.trim(),
                                    icon: Icons.menu_book_outlined,
                                    color: roleTheme.primary,
                                    isDark: isDark,
                                  ),
                                if (notification.relatedEntityType
                                        ?.trim()
                                        .isNotEmpty ??
                                    false)
                                  _MiniChip(
                                    label: _entityLabel(
                                      l10n,
                                      notification.relatedEntityType!.trim(),
                                    ),
                                    icon: Icons.link_rounded,
                                    color: roleTheme.secondary,
                                    isDark: isDark,
                                  ),
                                if (notification.priority !=
                                    NotificationPriority.normal)
                                  _MiniChip(
                                    label: _priorityLabel(
                                      l10n,
                                      notification.priority,
                                    ),
                                    icon: Icons.priority_high_rounded,
                                    color: _priorityColor(
                                      notification.priority,
                                    ),
                                    isDark: isDark,
                                  ),
                                if (notification.isRealtimeActionable)
                                  _MiniChip(
                                    label: l10n.sharedNotifOpenDetails,
                                    icon: Icons.open_in_new_rounded,
                                    color: roleTheme.accent,
                                    isDark: isDark,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 34,
                        height: 34,
                        child: IconButton(
                          onPressed: onMore,
                          tooltip: l10n.sharedNotifActions,
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.more_vert_rounded,
                            color: roleTheme.textSecondary(isDark),
                            size: 19,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.icon,
    required this.color,
    required this.isDark,
  });

  final IconData icon;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.22 : 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.28 : 0.18),
        ),
      ),
      child: Icon(icon, color: color, size: 21),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.28 : 0.16),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.white : color,
                fontSize: 10.8,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

IconData _typeIcon(NotificationType type) {
  switch (type) {
    case NotificationType.announcement:
      return Icons.campaign_outlined;
    case NotificationType.grade:
      return Icons.grading_outlined;
    case NotificationType.assignment:
      return Icons.assignment_turned_in_outlined;
    case NotificationType.message:
      return Icons.mail_outline_rounded;
    case NotificationType.deadline:
      return Icons.event_busy_outlined;
    case NotificationType.system:
      return Icons.settings_outlined;
    case NotificationType.lab:
      return Icons.science_outlined;
    case NotificationType.quiz:
      return Icons.quiz_outlined;
    case NotificationType.material:
      return Icons.library_books_outlined;
    case NotificationType.community:
    case NotificationType.discussion:
      return Icons.forum_outlined;
    case NotificationType.enrollment:
      return Icons.how_to_reg_outlined;
    case NotificationType.schedule:
    case NotificationType.officeHours:
      return Icons.event_note_outlined;
    case NotificationType.unknown:
      return Icons.notifications_none_rounded;
  }
}

Color _typeColor(NotificationType type) {
  switch (type) {
    case NotificationType.announcement:
      return const Color(0xFFF59E0B);
    case NotificationType.grade:
      return const Color(0xFF10B981);
    case NotificationType.assignment:
    case NotificationType.lab:
    case NotificationType.quiz:
    case NotificationType.material:
      return const Color(0xFF3B82F6);
    case NotificationType.message:
    case NotificationType.community:
    case NotificationType.discussion:
      return const Color(0xFF8B5CF6);
    case NotificationType.deadline:
    case NotificationType.schedule:
    case NotificationType.officeHours:
      return const Color(0xFFEF4444);
    case NotificationType.enrollment:
      return const Color(0xFF14B8A6);
    case NotificationType.system:
    case NotificationType.unknown:
      return const Color(0xFF64748B);
  }
}

Color _priorityColor(NotificationPriority priority) {
  switch (priority) {
    case NotificationPriority.low:
      return const Color(0xFF64748B);
    case NotificationPriority.normal:
      return const Color(0xFF3B82F6);
    case NotificationPriority.high:
      return const Color(0xFFF59E0B);
    case NotificationPriority.urgent:
      return const Color(0xFFEF4444);
  }
}

String _typeLabel(AppLocalizations l10n, NotificationType type) {
  switch (type) {
    case NotificationType.announcement:
      return l10n.sharedNotifTypeAnnouncement;
    case NotificationType.grade:
      return l10n.sharedNotifTypeGrade;
    case NotificationType.assignment:
      return l10n.sharedNotifTypeAssignment;
    case NotificationType.message:
      return l10n.sharedNotifTypeMessage;
    case NotificationType.deadline:
      return l10n.sharedNotifTypeDeadline;
    case NotificationType.system:
      return l10n.sharedNotifSystem;
    case NotificationType.lab:
      return l10n.sharedNotifTypeLab;
    case NotificationType.quiz:
      return l10n.sharedNotifTypeQuiz;
    case NotificationType.material:
      return l10n.sharedNotifTypeMaterial;
    case NotificationType.community:
      return l10n.sharedNotifTypeCommunity;
    case NotificationType.discussion:
      return l10n.sharedNotifTypeDiscussion;
    case NotificationType.enrollment:
      return l10n.sharedNotifTypeEnrollment;
    case NotificationType.schedule:
      return l10n.sharedNotifTypeSchedule;
    case NotificationType.officeHours:
      return l10n.sharedNotifTypeOfficeHours;
    case NotificationType.unknown:
      return l10n.sharedNotifTypeNotification;
  }
}

String _priorityLabel(AppLocalizations l10n, NotificationPriority priority) {
  switch (priority) {
    case NotificationPriority.low:
      return l10n.sharedNotifPriorityLow;
    case NotificationPriority.normal:
      return l10n.sharedNotifPriorityNormal;
    case NotificationPriority.high:
      return l10n.sharedNotifPriorityHigh;
    case NotificationPriority.urgent:
      return l10n.sharedNotifPriorityUrgent;
  }
}

String _entityLabel(AppLocalizations l10n, String raw) {
  final normalized = raw.replaceAll('_', ' ').trim();
  if (normalized.isEmpty) {
    return l10n.sharedNotifRelatedTo;
  }
  return normalized
      .split(RegExp(r'\s+'))
      .map(
        (part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}',
      )
      .join(' ');
}

String _relativeTime(AppLocalizations l10n, DateTime createdAt) {
  final delta = DateTime.now().difference(createdAt);
  if (delta.inMinutes < 1) {
    return l10n.notificationJustNow;
  }
  if (delta.inHours < 1) {
    return l10n.notificationMinutesAgo(delta.inMinutes);
  }
  if (delta.inDays < 1) {
    return l10n.notificationHoursAgo(delta.inHours);
  }
  if (delta.inDays == 1) {
    return l10n.notificationYesterday;
  }
  if (delta.inDays < 7) {
    return l10n.notificationDaysAgo(delta.inDays);
  }
  final local = createdAt.toLocal();
  return '${local.day}/${local.month}/${local.year}';
}
