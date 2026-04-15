import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/admin/admin_notification_model.dart';
import '../../../models/notifications/swipe_action_model.dart';
import '../../../services/admin_notification_swipe_settings_service.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

class AdminNotificationTile extends StatefulWidget {
  final AdminNotificationModel notification;
  final bool isDark;
  final VoidCallback? onTap;
  final VoidCallback? onBookmark;
  final VoidCallback? onDelete;
  final VoidCallback? onMarkRead;
  final VoidCallback? onArchive;

  const AdminNotificationTile({
    super.key,
    required this.notification,
    required this.isDark,
    this.onTap,
    this.onBookmark,
    this.onDelete,
    this.onMarkRead,
    this.onArchive,
  });

  @override
  State<AdminNotificationTile> createState() => _AdminNotificationTileState();
}

class _AdminNotificationTileState extends State<AdminNotificationTile>
    with WidgetsBindingObserver {
  NotificationSwipeSettings _swipeSettings = const NotificationSwipeSettings();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSwipeSettings();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadSwipeSettings();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSwipeSettings();
  }

  Future<void> _loadSwipeSettings() async {
    AdminNotificationSwipeSettingsService.instance.clearCache();
    final settings = await AdminNotificationSwipeSettingsService.instance
        .getSwipeSettings();
    if (mounted) {
      setState(() => _swipeSettings = settings);
    }
  }

  void _executeAction(SwipeAction action) {
    switch (action) {
      case SwipeAction.delete:
        widget.onDelete?.call();
        break;
      case SwipeAction.markRead:
        widget.onMarkRead?.call();
        break;
      case SwipeAction.markUnread:
        widget.onMarkRead?.call();
        break;
      case SwipeAction.archive:
        widget.onArchive?.call();
        break;
      case SwipeAction.bookmark:
        widget.onBookmark?.call();
        break;
      case SwipeAction.none:
        break;
    }
  }

  Future<bool> _confirmAction(BuildContext context, SwipeAction action) async {
    if (!_swipeSettings.confirmBeforeAction || !action.requiresConfirmation) {
      return true;
    }

    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AdminColors.getCardColor(widget.isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          action == SwipeAction.delete
              ? l10n.adminNotificationDeleteConfirmTitle
              : l10n.adminNotificationArchiveConfirmTitle,
          style: TextStyle(color: AdminColors.getTextColor(widget.isDark)),
        ),
        content: Text(
          action == SwipeAction.delete
              ? l10n.adminNotificationDeleteConfirmMessage
              : l10n.adminNotificationArchiveConfirmMessage,
          style: TextStyle(
            color: AdminColors.getTextSecondaryColor(widget.isDark),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: action == SwipeAction.delete
                  ? AdminColors.error
                  : AdminColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(
              action == SwipeAction.delete ? l10n.delete : l10n.archive,
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final leftAction = _swipeSettings.leftAction;
    final rightAction = _swipeSettings.rightAction;

    DismissDirection direction;
    if (leftAction == SwipeAction.none && rightAction == SwipeAction.none) {
      direction = DismissDirection.none;
    } else if (leftAction == SwipeAction.none) {
      direction = DismissDirection.startToEnd;
    } else if (rightAction == SwipeAction.none) {
      direction = DismissDirection.endToStart;
    } else {
      direction = DismissDirection.horizontal;
    }

    return Dismissible(
      key: Key('admin_notification_${widget.notification.id}'),
      direction: direction,
      dismissThresholds: {
        DismissDirection.startToEnd: _swipeSettings.swipeSensitivity,
        DismissDirection.endToStart: _swipeSettings.swipeSensitivity,
      },
      confirmDismiss: (dir) async {
        HapticFeedback.lightImpact();

        SwipeAction action;
        if (dir == DismissDirection.endToStart) {
          action = leftAction;
        } else {
          action = rightAction;
        }

        if (action == SwipeAction.none) return false;

        final confirmed = await _confirmAction(context, action);
        if (confirmed) {
          _executeAction(action);
        }
        return action == SwipeAction.delete && confirmed;
      },
      background: _buildSwipeBackground(rightAction, true),
      secondaryBackground: _buildSwipeBackground(leftAction, false),
      child: _buildNotificationContent(),
    );
  }

  Widget _buildSwipeBackground(SwipeAction action, bool isLeft) {
    if (action == SwipeAction.none) return const SizedBox();

    return Container(
      alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      padding: EdgeInsets.only(left: isLeft ? 24 : 0, right: isLeft ? 0 : 24),
      decoration: BoxDecoration(
        color: action.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isLeft) ...[
            Text(
              _getActionLabel(action),
              style: TextStyle(
                color: action.color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: action.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(action.icon, color: Colors.white, size: 20),
          ),
          if (isLeft) ...[
            const SizedBox(width: 8),
            Text(
              _getActionLabel(action),
              style: TextStyle(
                color: action.color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getActionLabel(SwipeAction action) {
    switch (action) {
      case SwipeAction.delete:
        return 'Delete';
      case SwipeAction.markRead:
        return widget.notification.isRead ? 'Unread' : 'Read';
      case SwipeAction.markUnread:
        return 'Unread';
      case SwipeAction.archive:
        return 'Archive';
      case SwipeAction.bookmark:
        return 'Bookmark';
      case SwipeAction.none:
        return '';
    }
  }

  Widget _buildNotificationContent() {
    final notification = widget.notification;
    final isDark = widget.isDark;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AdminColors.getCardColor(isDark),
          borderRadius: BorderRadius.circular(16),
          border: notification.isRead
              ? null
              : Border.all(
                  color: AdminColors.primary.withOpacity(0.3),
                  width: 1,
                ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNotificationIcon(),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (notification.requiresAction) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AdminColors.warning.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Action Required',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: AdminColors.warning,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: notification.isRead
                                ? FontWeight.w500
                                : FontWeight.w600,
                            color: AdminColors.getTextColor(isDark),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 13,
                      color: AdminColors.getTextSecondaryColor(isDark),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: AdminColors.getTextTertiaryColor(isDark),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(notification.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: AdminColors.getTextTertiaryColor(isDark),
                        ),
                      ),
                      if (notification.userName != null) ...[
                        const SizedBox(width: 12),
                        Icon(
                          Icons.person_outline_rounded,
                          size: 12,
                          color: AdminColors.getTextTertiaryColor(isDark),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            notification.userName!,
                            style: TextStyle(
                              fontSize: 11,
                              color: AdminColors.getTextTertiaryColor(isDark),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                if (!notification.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AdminColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                if (notification.isBookmarked) ...[
                  const SizedBox(height: 8),
                  Icon(
                    Icons.bookmark_rounded,
                    size: 16,
                    color: AdminColors.secondary,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    final notification = widget.notification;
    final iconData = _getTypeIcon(notification.type);
    final colors = _getTypeColors(notification.type);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors[0].withOpacity(0.15), colors[1].withOpacity(0.15)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(iconData, color: colors[0], size: 22),
    );
  }

  IconData _getTypeIcon(AdminNotificationType type) {
    switch (type) {
      case AdminNotificationType.userActivity:
        return Icons.person_add_rounded;
      case AdminNotificationType.systemAlert:
        return Icons.warning_amber_rounded;
      case AdminNotificationType.courseUpdate:
        return Icons.school_rounded;
      case AdminNotificationType.announcement:
        return Icons.campaign_rounded;
      case AdminNotificationType.security:
        return Icons.security_rounded;
      case AdminNotificationType.report:
        return Icons.analytics_rounded;
      case AdminNotificationType.maintenance:
        return Icons.build_rounded;
      case AdminNotificationType.approval:
        return Icons.approval_rounded;
    }
  }

  List<Color> _getTypeColors(AdminNotificationType type) {
    switch (type) {
      case AdminNotificationType.userActivity:
        return [AdminColors.primary, AdminColors.primaryLight];
      case AdminNotificationType.systemAlert:
        return [AdminColors.warning, AdminColors.warningLight];
      case AdminNotificationType.courseUpdate:
        return [AdminColors.secondary, const Color(0xFF7C3AED)];
      case AdminNotificationType.announcement:
        return [AdminColors.accent, AdminColors.primary];
      case AdminNotificationType.security:
        return [AdminColors.error, AdminColors.errorLight];
      case AdminNotificationType.report:
        return [AdminColors.success, AdminColors.successLight];
      case AdminNotificationType.maintenance:
        return [AdminColors.warning, AdminColors.warningLight];
      case AdminNotificationType.approval:
        return [AdminColors.primary, AdminColors.secondary];
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
