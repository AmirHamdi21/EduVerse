import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/ta_colors.dart';

enum TANotificationType {
  question,
  submission,
  discussion,
  system,
  deadline,
  grade,
  announcement,
  material,
  schedule,
  officeHours,
}

class TANotificationCard extends StatelessWidget {
  final bool isDark;
  final TANotificationItem notification;
  final bool isExpanded;
  final VoidCallback? onTap;
  final VoidCallback? onReply;
  final VoidCallback? onResolve;

  const TANotificationCard({
    super.key,
    required this.isDark,
    required this.notification,
    this.isExpanded = false,
    this.onTap,
    this.onReply,
    this.onResolve,
  });

  Color _getTypeColor(TANotificationType type) {
    switch (type) {
      case TANotificationType.question:
        return TAColors.primary;
      case TANotificationType.submission:
        return TAColors.teal;
      case TANotificationType.discussion:
        return TAColors.info;
      case TANotificationType.system:
        return TAColors.textSecondaryColor(isDark);
      case TANotificationType.deadline:
        return TAColors.error;
      case TANotificationType.grade:
        return TAColors.success;
      case TANotificationType.announcement:
        return TAColors.primary;
      case TANotificationType.material:
        return TAColors.warning;
      case TANotificationType.schedule:
        return TAColors.info;
      case TANotificationType.officeHours:
        return TAColors.teal;
    }
  }

  IconData _getTypeIcon(TANotificationType type) {
    switch (type) {
      case TANotificationType.question:
        return Icons.help_outline_rounded;
      case TANotificationType.submission:
        return Icons.upload_file_rounded;
      case TANotificationType.discussion:
        return Icons.forum_rounded;
      case TANotificationType.system:
        return Icons.settings_rounded;
      case TANotificationType.deadline:
        return Icons.schedule_rounded;
      case TANotificationType.grade:
        return Icons.grading_rounded;
      case TANotificationType.announcement:
        return Icons.campaign_rounded;
      case TANotificationType.material:
        return Icons.menu_book_rounded;
      case TANotificationType.schedule:
        return Icons.event_note_rounded;
      case TANotificationType.officeHours:
        return Icons.support_agent_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typeColor = _getTypeColor(notification.type);
    final typeIcon = _getTypeIcon(notification.type);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TAColors.cardColor(isDark),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notification.isUnread
                  ? typeColor.withValues(alpha: 0.3)
                  : TAColors.borderColor(isDark).withValues(alpha: 0.5),
              width: notification.isUnread ? 1.5 : 1,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(typeIcon, color: typeColor, size: 20),
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
                                notification.title,
                                style: TextStyle(
                                  color: TAColors.textPrimaryColor(isDark),
                                  fontSize: 14,
                                  fontWeight: notification.isUnread
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                ),
                              ),
                            ),
                            if (notification.badge != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: typeColor.withValues(
                                    alpha: isDark ? 0.2 : 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  notification.badge!,
                                  style: TextStyle(
                                    color: typeColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            if (notification.secondaryBadge != null) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: TAColors.surfaceColor(
                                    isDark,
                                  ).withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  notification.secondaryBadge!,
                                  style: TextStyle(
                                    color: TAColors.textSecondaryColor(isDark),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          notification.senderName,
                          style: TextStyle(
                            color: TAColors.textSecondaryColor(isDark),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          notification.preview,
                          style: TextStyle(
                            color: TAColors.textSecondaryColor(isDark),
                            fontSize: 13,
                            height: 1.4,
                          ),
                          maxLines: isExpanded ? null : 2,
                          overflow: isExpanded ? null : TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Time and unread indicator
              Row(
                children: [
                  if (notification.isUnread)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: typeColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: TAColors.textTertiaryColor(isDark),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    notification.timeAgo,
                    style: TextStyle(
                      color: TAColors.textTertiaryColor(isDark),
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),
                  if (notification.hasThread)
                    Row(
                      children: [
                        Icon(
                          Icons.forum_outlined,
                          size: 14,
                          color: TAColors.textTertiaryColor(isDark),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${notification.replyCount} ${l10n.taNotifReplies}',
                          style: TextStyle(
                            color: TAColors.textTertiaryColor(isDark),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              // Expanded content
              if (isExpanded && notification.fullContent != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? TAColors.darkSurface.withValues(alpha: 0.5)
                        : TAColors.surfaceColor(isDark),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: TAColors.borderColor(
                        isDark,
                      ).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (notification.relatedTo != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.link_rounded,
                                size: 14,
                                color: TAColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${l10n.taNotifRelatedTo}: ${notification.relatedTo}',
                                style: TextStyle(
                                  color: TAColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                            ),
                          ),
                      if (notification.actionHint != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.open_in_new_rounded,
                                size: 14,
                                color: TAColors.teal,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                notification.actionHint!,
                                style: const TextStyle(
                                  color: TAColors.teal,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Text(
                        notification.fullContent!,
                        style: TextStyle(
                          color: TAColors.textPrimaryColor(isDark),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onReply,
                        icon: Icon(
                          Icons.reply_rounded,
                          size: 18,
                          color: TAColors.primary,
                        ),
                        label: Text(l10n.taNotifReply),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: TAColors.textPrimaryColor(isDark),
                          side: BorderSide(color: TAColors.borderColor(isDark)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onResolve,
                        icon: Icon(
                          Icons.check_circle_outline_rounded,
                          size: 18,
                          color: TAColors.success,
                        ),
                        label: Text(l10n.taNotifResolve),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: TAColors.textPrimaryColor(isDark),
                          side: BorderSide(color: TAColors.borderColor(isDark)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class TANotificationItem {
  final String id;
  final String title;
  final String senderName;
  final String preview;
  final String timeAgo;
  final TANotificationType type;
  final String? badge;
  final bool isUnread;
  final bool hasThread;
  final int replyCount;
  final String? fullContent;
  final String? relatedTo;
  final String? secondaryBadge;
  final String? actionHint;

  TANotificationItem({
    required this.id,
    required this.title,
    required this.senderName,
    required this.preview,
    required this.timeAgo,
    required this.type,
    this.badge,
    this.isUnread = false,
    this.hasThread = false,
    this.replyCount = 0,
    this.fullContent,
    this.relatedTo,
    this.secondaryBadge,
    this.actionHint,
  });
}
