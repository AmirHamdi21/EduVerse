import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/admin/admin_notification_model.dart';
import '../shared/admin_colors.dart';

class AdminAnnouncementCard extends StatelessWidget {
  final AdminAnnouncementModel announcement;
  final bool isDark;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onPin;

  const AdminAnnouncementCard({
    super.key,
    required this.announcement,
    required this.isDark,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onPin,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AdminColors.getCardColor(isDark),
          borderRadius: BorderRadius.circular(20),
          border: announcement.isPinned
              ? Border.all(
                  color: AdminColors.warning.withOpacity(0.5),
                  width: 1.5,
                )
              : Border.all(
                  color: AdminColors.getCardBorderColor(isDark),
                  width: 1,
                ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _getPriorityGradient(announcement.priority),
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.campaign_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (announcement.isPinned) ...[
                              const Icon(
                                Icons.push_pin_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Expanded(
                              child: Text(
                                announcement.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getTargetLabel(announcement.target),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatDate(announcement.createdAt),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildActionsMenu(context),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    announcement.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: AdminColors.getTextSecondaryColor(isDark),
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 14,
                        color: AdminColors.getTextTertiaryColor(isDark),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        announcement.createdBy,
                        style: TextStyle(
                          fontSize: 12,
                          color: AdminColors.getTextTertiaryColor(isDark),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.visibility_outlined,
                        size: 14,
                        color: AdminColors.getTextTertiaryColor(isDark),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${announcement.viewCount} views',
                        style: TextStyle(
                          fontSize: 12,
                          color: AdminColors.getTextTertiaryColor(isDark),
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
    );
  }

  Widget _buildActionsMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.more_vert_rounded,
          color: Colors.white,
          size: 18,
        ),
      ),
      color: AdminColors.getCardColor(isDark),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        HapticFeedback.lightImpact();
        switch (value) {
          case 'pin':
            onPin?.call();
            break;
          case 'edit':
            onEdit?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'pin',
          child: Row(
            children: [
              Icon(
                announcement.isPinned
                    ? Icons.push_pin_outlined
                    : Icons.push_pin_rounded,
                size: 20,
                color: AdminColors.warning,
              ),
              const SizedBox(width: 12),
              Text(
                announcement.isPinned ? 'Unpin' : 'Pin',
                style: TextStyle(color: AdminColors.getTextColor(isDark)),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_rounded, size: 20, color: AdminColors.primary),
              const SizedBox(width: 12),
              Text(
                'Edit',
                style: TextStyle(color: AdminColors.getTextColor(isDark)),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_rounded, size: 20, color: AdminColors.error),
              const SizedBox(width: 12),
              Text('Delete', style: TextStyle(color: AdminColors.error)),
            ],
          ),
        ),
      ],
    );
  }

  List<Color> _getPriorityGradient(AdminNotificationPriority priority) {
    switch (priority) {
      case AdminNotificationPriority.low:
        return [const Color(0xFF64748B), const Color(0xFF475569)];
      case AdminNotificationPriority.normal:
        return [AdminColors.primary, AdminColors.primaryDark];
      case AdminNotificationPriority.high:
        return [AdminColors.warning, const Color(0xFFD97706)];
      case AdminNotificationPriority.urgent:
        return [AdminColors.error, const Color(0xFFDC2626)];
      case AdminNotificationPriority.critical:
        return [const Color(0xFFDC2626), const Color(0xFF991B1B)];
    }
  }

  String _getTargetLabel(AnnouncementTarget target) {
    switch (target) {
      case AnnouncementTarget.all:
        return 'Everyone';
      case AnnouncementTarget.students:
        return 'Students';
      case AnnouncementTarget.instructors:
        return 'Instructors';
      case AnnouncementTarget.teachingAssistants:
        return 'TAs';
      case AnnouncementTarget.admins:
        return 'Admins';
      case AnnouncementTarget.department:
        return 'Department';
      case AnnouncementTarget.course:
        return 'Course';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
