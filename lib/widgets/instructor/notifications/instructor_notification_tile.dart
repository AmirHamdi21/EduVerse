import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../config/app_theme.dart';
import '../../../models/instructor/instrucor_notification_model.dart';

class InstructorNotificationTile extends StatelessWidget {
  final InstructorNotificationModel notification;
  final bool isDarkMode;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onMarkRead;

  const InstructorNotificationTile({
    super.key,
    required this.notification,
    required this.isDarkMode,
    this.onTap,
    this.onDelete,
    this.onMarkRead,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          onDelete?.call();
          return true;
        } else if (direction == DismissDirection.startToEnd) {
          onMarkRead?.call();
          return false;
        }
        return false;
      },
      background: _buildSwipeBackground(
        color: const Color(0xFF059669),
        icon: Icons.check_rounded,
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _buildSwipeBackground(
        color: const Color(0xFFEF4444),
        icon: Icons.delete_outline_rounded,
        alignment: Alignment.centerRight,
      ),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          decoration: BoxDecoration(
            color: notification.isRead
                ? (isDarkMode
                      ? AppTheme.darkCardColor.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.7))
                : (isDarkMode ? AppTheme.darkCardColor : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notification.isRead
                  ? (isDarkMode
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.grey.withValues(alpha: 0.1))
                  : _getTypeColor(notification.type).withValues(alpha: 0.3),
              width: notification.isRead ? 1 : 1.5,
            ),
            boxShadow: notification.isRead
                ? null
                : [
                    BoxShadow(
                      color: _getTypeColor(
                        notification.type,
                      ).withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIcon(),
                const SizedBox(width: 14),
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
                                fontSize: 15,
                                fontWeight: notification.isRead
                                    ? FontWeight.w500
                                    : FontWeight.w600,
                                color: isDarkMode
                                    ? AppTheme.darkTextPrimary
                                    : AppTheme.textDark,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _getTypeColor(notification.type),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
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
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: isDarkMode
                                ? AppTheme.darkTextSecondary
                                : AppTheme.textLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTimestamp(notification.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode
                                  ? AppTheme.darkTextSecondary
                                  : AppTheme.textLight,
                            ),
                          ),
                          if (notification.courseName != null) ...[
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.grey.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                notification.courseName!,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: isDarkMode
                                      ? AppTheme.darkTextSecondary
                                      : AppTheme.textLight,
                                ),
                              ),
                            ),
                          ],
                        ],
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

  Widget _buildIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _getTypeColor(notification.type).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        _getTypeIcon(notification.type),
        color: _getTypeColor(notification.type),
        size: 22,
      ),
    );
  }

  Widget _buildSwipeBackground({
    required Color color,
    required IconData icon,
    required Alignment alignment,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }

  Color _getTypeColor(InstructorNotificationType type) {
    switch (type) {
      case InstructorNotificationType.submission:
        return const Color(0xFF155CFB);
      case InstructorNotificationType.grading:
        return const Color(0xFF7C3AED);
      case InstructorNotificationType.message:
        return const Color(0xFF059669);
      case InstructorNotificationType.deadline:
        return const Color(0xFFEF4444);
      case InstructorNotificationType.attendance:
        return const Color(0xFFF59E0B);
      case InstructorNotificationType.announcement:
        return const Color(0xFF0EA5E9);
      case InstructorNotificationType.system:
        return const Color(0xFF64748B);
    }
  }

  IconData _getTypeIcon(InstructorNotificationType type) {
    switch (type) {
      case InstructorNotificationType.submission:
        return Icons.assignment_turned_in_rounded;
      case InstructorNotificationType.grading:
        return Icons.grading_rounded;
      case InstructorNotificationType.message:
        return Icons.mail_rounded;
      case InstructorNotificationType.deadline:
        return Icons.schedule_rounded;
      case InstructorNotificationType.attendance:
        return Icons.how_to_reg_rounded;
      case InstructorNotificationType.announcement:
        return Icons.campaign_rounded;
      case InstructorNotificationType.system:
        return Icons.settings_rounded;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.month}/${timestamp.day}/${timestamp.year}';
    }
  }
}
