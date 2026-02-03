import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../config/app_theme.dart';
import '../../../models/notifications/notification_model.dart';
import '../../../generated_l10n/app_localizations.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final bool isDarkMode;
  final VoidCallback? onTap;
  final VoidCallback? onBookmark;
  final VoidCallback? onDelete;
  final VoidCallback? onMarkRead;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.isDarkMode,
    this.onTap,
    this.onBookmark,
    this.onDelete,
    this.onMarkRead,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Dismissible(
      key: Key('notification_${notification.id}'),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        HapticFeedback.lightImpact();
        if (direction == DismissDirection.endToStart) {
          // Delete
          onDelete?.call();
          return true;
        } else {
          // Mark as read/unread
          onMarkRead?.call();
          return false;
        }
      },
      background: _buildSwipeBackground(
        alignment: Alignment.centerLeft,
        color: AppTheme.primaryColor,
        icon: notification.isRead ? Icons.mark_email_unread : Icons.done,
        label: notification.isRead
            ? l10n.notificationMarkUnread
            : l10n.notificationMarkRead,
      ),
      secondaryBackground: _buildSwipeBackground(
        alignment: Alignment.centerRight,
        color: AppTheme.errorColor,
        icon: Icons.delete_outline,
        label: l10n.delete,
      ),
      child: _buildTileContent(context, l10n),
    );
  }

  Widget _buildSwipeBackground({
    required Alignment alignment,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: alignment == Alignment.centerLeft
            ? [
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ]
            : [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(icon, color: Colors.white, size: 22),
              ],
      ),
    );
  }

  Widget _buildTileContent(BuildContext context, AppLocalizations l10n) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode
              ? (notification.isRead
                  ? AppTheme.darkCardColor
                  : AppTheme.darkCardColor.withValues(alpha: 0.9))
              : (notification.isRead
                  ? Colors.white
                  : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead
                ? (isDarkMode
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.grey.withValues(alpha: 0.15))
                : _getPriorityColor(notification.priority).withValues(alpha: 0.4),
            width: notification.isRead ? 1 : 1.5,
          ),
          boxShadow: isDarkMode
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type Icon
            _buildTypeIcon(),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                                notification.isRead ? FontWeight.w500 : FontWeight.w600,
                            color: isDarkMode
                                ? AppTheme.darkTextPrimary
                                : AppTheme.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Bookmark button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onBookmark?.call();
                        },
                        child: Icon(
                          notification.isBookmarked
                              ? Icons.bookmark
                              : Icons.bookmark_outline,
                          size: 20,
                          color: notification.isBookmarked
                              ? AppTheme.primaryColor
                              : (isDarkMode
                                  ? AppTheme.darkTextSecondary
                                  : AppTheme.textLight),
                        ),
                      ),
                      if (!notification.isRead) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getPriorityColor(notification.priority),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Message
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDarkMode
                          ? AppTheme.darkTextSecondary
                          : AppTheme.textLight,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  // Footer row
                  _buildFooterRow(l10n),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getTypeColor(notification.type).withValues(alpha: 0.2),
            _getTypeColor(notification.type).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        _getTypeIcon(notification.type),
        color: _getTypeColor(notification.type),
        size: 22,
      ),
    );
  }

  Widget _buildFooterRow(AppLocalizations l10n) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Time
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.access_time,
              size: 12,
              color: isDarkMode
                  ? AppTheme.darkTextSecondary.withValues(alpha: 0.7)
                  : AppTheme.textLight.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 4),
            Text(
              _formatTime(notification.createdAt, l10n),
              style: TextStyle(
                fontSize: 11,
                color: isDarkMode
                    ? AppTheme.darkTextSecondary.withValues(alpha: 0.7)
                    : AppTheme.textLight.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        // Instructor name if available
        if (notification.instructorName != null) ...[
          Text(
            '•',
            style: TextStyle(
              fontSize: 11,
              color: isDarkMode
                  ? AppTheme.darkTextSecondary.withValues(alpha: 0.5)
                  : AppTheme.textLight.withValues(alpha: 0.5),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_outline,
                size: 12,
                color: isDarkMode
                    ? AppTheme.darkTextSecondary.withValues(alpha: 0.7)
                    : AppTheme.textLight.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 4),
              Text(
                notification.instructorName!,
                style: TextStyle(
                  fontSize: 11,
                  color: isDarkMode
                      ? AppTheme.darkTextSecondary.withValues(alpha: 0.7)
                      : AppTheme.textLight.withValues(alpha: 0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
        // Tags
        if (notification.tags != null)
          ...notification.tags!.keys.take(2).map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _getTypeColor(notification.type).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: _getTypeColor(notification.type),
                  ),
                ),
              )),
      ],
    );
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.assignment:
        return Icons.assignment_outlined;
      case NotificationType.lecture:
        return Icons.menu_book_outlined;
      case NotificationType.message:
        return Icons.mail_outline;
      case NotificationType.exam:
        return Icons.quiz_outlined;
      case NotificationType.course:
        return Icons.school_outlined;
      case NotificationType.lab:
        return Icons.science_outlined;
      case NotificationType.aiInsight:
        return Icons.auto_awesome;
      case NotificationType.aiRecommendation:
        return Icons.lightbulb_outline;
      case NotificationType.system:
        return Icons.info_outline;
      case NotificationType.announcement:
        return Icons.campaign_outlined;
    }
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.assignment:
        return const Color(0xFFFF6B6B);
      case NotificationType.lecture:
        return AppTheme.primaryColor;
      case NotificationType.message:
        return const Color(0xFF9B59B6);
      case NotificationType.exam:
        return const Color(0xFFFF9800);
      case NotificationType.course:
        return AppTheme.accentColor;
      case NotificationType.lab:
        return const Color(0xFF4CAF50);
      case NotificationType.aiInsight:
        return const Color(0xFFFF6B35);
      case NotificationType.aiRecommendation:
        return const Color(0xFF3498DB);
      case NotificationType.system:
        return const Color(0xFF607D8B);
      case NotificationType.announcement:
        return const Color(0xFF673AB7);
    }
  }

  Color _getPriorityColor(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return AppTheme.textLight;
      case NotificationPriority.normal:
        return AppTheme.primaryColor;
      case NotificationPriority.high:
        return AppTheme.warningColor;
      case NotificationPriority.urgent:
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
