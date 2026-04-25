import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../config/app_theme.dart';
import '../../../models/notifications/notification_model.dart';
import '../../../models/notifications/swipe_action_model.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../services/notification_swipe_settings_service.dart';

class NotificationTile extends StatefulWidget {
  final NotificationModel notification;
  final bool isDarkMode;
  final VoidCallback? onTap;
  final VoidCallback? onBookmark;
  final VoidCallback? onDelete;
  final VoidCallback? onMarkRead;
  final VoidCallback? onArchive;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.isDarkMode,
    this.onTap,
    this.onBookmark,
    this.onDelete,
    this.onMarkRead,
    this.onArchive,
  });

  @override
  State<NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile>
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
    // Reload settings when returning to this screen
    _loadSwipeSettings();
  }

  Future<void> _loadSwipeSettings() async {
    // Clear cache to get fresh settings
    NotificationSwipeSettingsService.instance.clearCache();
    final settings = await NotificationSwipeSettingsService.instance
        .getSwipeSettings();
    if (mounted) {
      setState(() {
        _swipeSettings = settings;
      });
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
      case SwipeAction.archive:
      case SwipeAction.bookmark:
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
      builder: (ctx) => action == SwipeAction.delete
          ? _DeleteNotificationDialog(
              isDark: widget.isDarkMode,
              l10n: l10n,
              onCancel: () => Navigator.of(ctx).pop(false),
              onDelete: () => Navigator.of(ctx).pop(true),
            )
          : _DeleteNotificationDialog(
              isDark: widget.isDarkMode,
              l10n: l10n,
              onCancel: () => Navigator.of(ctx).pop(false),
              onDelete: () => Navigator.of(ctx).pop(true),
            ),
    );
    return result ?? false;
  }

  String _getActionLabel(SwipeAction action, AppLocalizations l10n) {
    switch (action) {
      case SwipeAction.delete:
        return l10n.delete;
      case SwipeAction.markRead:
        return l10n.markAsRead;
      case SwipeAction.markUnread:
        return l10n.markAsUnread;
      case SwipeAction.archive:
        return l10n.archive;
      case SwipeAction.bookmark:
        return l10n.bookmark;
      case SwipeAction.none:
        return '';
    }
  }

  IconData _getActionIcon(SwipeAction action) {
    switch (action) {
      case SwipeAction.delete:
        return Icons.delete_outline_rounded;
      case SwipeAction.markRead:
        return Icons.mark_email_read_outlined;
      case SwipeAction.markUnread:
        return Icons.mark_email_unread_outlined;
      case SwipeAction.archive:
        return Icons.archive_outlined;
      case SwipeAction.bookmark:
        return widget.notification.isBookmarked
            ? Icons.bookmark
            : Icons.bookmark_outline_rounded;
      case SwipeAction.none:
        return Icons.block_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final leftAction = _swipeSettings.leftAction;
    final rightAction = _swipeSettings.rightAction;

    // Determine dismiss direction based on settings
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
      key: Key('notification_${widget.notification.id}'),
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
          // Return true only for delete to actually dismiss
          return action == SwipeAction.delete;
        }
        return false;
      },
      background: rightAction != SwipeAction.none
          ? _buildSwipeBackground(
              alignment: Alignment.centerLeft,
              color: rightAction.color,
              icon: _getActionIcon(rightAction),
              label: _getActionLabel(rightAction, l10n),
            )
          : const SizedBox.shrink(),
      secondaryBackground: leftAction != SwipeAction.none
          ? _buildSwipeBackground(
              alignment: Alignment.centerRight,
              color: leftAction.color,
              icon: _getActionIcon(leftAction),
              label: _getActionLabel(leftAction, l10n),
            )
          : const SizedBox.shrink(),
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
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.isDarkMode
              ? (widget.notification.isRead
                    ? AppTheme.darkCardColor
                    : AppTheme.darkCardColor.withValues(alpha: 0.9))
              : (widget.notification.isRead ? Colors.white : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.notification.isRead
                ? (widget.isDarkMode
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.grey.withValues(alpha: 0.15))
                : _getPriorityColor(
                    widget.notification.priority,
                  ).withValues(alpha: 0.4),
            width: widget.notification.isRead ? 1 : 1.5,
          ),
          boxShadow: widget.isDarkMode
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
                          widget.notification.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: widget.notification.isRead
                                ? FontWeight.w500
                                : FontWeight.w600,
                            color: widget.isDarkMode
                                ? AppTheme.darkTextPrimary
                                : AppTheme.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (!widget.notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getPriorityColor(
                              widget.notification.priority,
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Message
                  Text(
                    widget.notification.message,
                    style: TextStyle(
                      fontSize: 13,
                      color: widget.isDarkMode
                          ? AppTheme.darkTextSecondary
                          : AppTheme.textLight,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_buildDetailChips().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _buildDetailChips(),
                    ),
                  ],
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
            _getTypeColor(widget.notification.type).withValues(alpha: 0.2),
            _getTypeColor(widget.notification.type).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        _getTypeIcon(widget.notification.type),
        color: _getTypeColor(widget.notification.type),
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
              color: widget.isDarkMode
                  ? AppTheme.darkTextSecondary.withValues(alpha: 0.7)
                  : AppTheme.textLight.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 4),
            Text(
              _formatTime(widget.notification.createdAt, l10n),
              style: TextStyle(
                fontSize: 11,
                color: widget.isDarkMode
                    ? AppTheme.darkTextSecondary.withValues(alpha: 0.7)
                    : AppTheme.textLight.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        // Instructor name if available
        if (widget.notification.instructorName != null) ...[
          Text(
            '•',
            style: TextStyle(
              fontSize: 11,
              color: widget.isDarkMode
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
                color: widget.isDarkMode
                    ? AppTheme.darkTextSecondary.withValues(alpha: 0.7)
                    : AppTheme.textLight.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 4),
              Text(
                widget.notification.instructorName!,
                style: TextStyle(
                  fontSize: 11,
                  color: widget.isDarkMode
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
        if (widget.notification.tags != null)
          ...widget.notification.tags!.keys
              .take(2)
              .map(
                (tag) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _getTypeColor(
                      widget.notification.type,
                    ).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: _getTypeColor(widget.notification.type),
                    ),
                  ),
                ),
              ),
      ],
    );
  }

  List<Widget> _buildDetailChips() {
    final chips = <Widget>[];

    if (widget.notification.courseName != null &&
        widget.notification.courseName!.trim().isNotEmpty) {
      chips.add(
        _buildInfoChip(
          icon: Icons.school_outlined,
          label: widget.notification.courseName!,
        ),
      );
    }

    final entityLabel = _entityLabel();
    if (entityLabel != null) {
      chips.add(
        _buildInfoChip(
          icon: _entityIcon(),
          label: entityLabel,
          tint: _getTypeColor(widget.notification.type),
        ),
      );
    }

    final actionHint = _actionHint();
    if (actionHint != null) {
      chips.add(
        _buildInfoChip(
          icon: Icons.open_in_new_rounded,
          label: actionHint,
        ),
      );
    }

    chips.add(
      _buildInfoChip(
        icon: Icons.label_outline_rounded,
        label: _displayTypeLabel(),
        tint: _getTypeColor(widget.notification.type),
      ),
    );

    chips.add(
      _buildInfoChip(
        icon: Icons.priority_high_rounded,
        label: _priorityLabel(widget.notification.priority),
        tint: _getPriorityColor(widget.notification.priority),
      ),
    );

    return chips;
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    Color? tint,
  }) {
    final baseColor = tint ?? (widget.isDarkMode ? Colors.white70 : Colors.black54);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: widget.isDarkMode ? 0.14 : 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: baseColor.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: baseColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: baseColor,
            ),
          ),
        ],
      ),
    );
  }

  String _displayTypeLabel() {
    switch (widget.notification.type) {
      case NotificationType.assignment:
        return 'Assignment';
      case NotificationType.lab:
        return 'Lab';
      case NotificationType.quiz:
        return 'Quiz';
      case NotificationType.grade:
        return 'Grade';
      case NotificationType.material:
        return 'Material';
      case NotificationType.message:
        return 'Message';
      case NotificationType.deadline:
        return 'Deadline';
      case NotificationType.system:
        return 'System';
      case NotificationType.community:
        return 'Community';
      case NotificationType.discussion:
        return 'Discussion';
      case NotificationType.enrollment:
        return 'Enrollment';
      case NotificationType.schedule:
        return 'Schedule';
      case NotificationType.officeHours:
        return 'Office Hours';
      case NotificationType.announcement:
        return 'Announcement';
      case NotificationType.unknown:
        final rawType = widget.notification.rawType.trim();
        return rawType.isEmpty ? 'Notification' : rawType;
    }
  }

  String _priorityLabel(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return 'Low';
      case NotificationPriority.normal:
        return 'Normal';
      case NotificationPriority.high:
        return 'High';
      case NotificationPriority.urgent:
        return 'Urgent';
    }
  }

  String? _entityLabel() {
    final type = widget.notification.relatedEntityType?.trim();
    final id = widget.notification.relatedEntityId?.trim();
    if ((type == null || type.isEmpty) && (id == null || id.isEmpty)) {
      return null;
    }

    final label = switch ((type ?? '').toLowerCase()) {
      'assignment' => 'Assignment',
      'lab' => 'Lab',
      'quiz' => 'Quiz',
      'discussion' => 'Discussion',
      'material' => 'Material',
      'exam_schedule' => 'Exam',
      'campus_event' => 'Event',
      _ => type ?? 'Item',
    };

    if (id == null || id.isEmpty) {
      return label;
    }
    return '$label #$id';
  }

  IconData _entityIcon() {
    switch ((widget.notification.relatedEntityType ?? '').trim().toLowerCase()) {
      case 'assignment':
        return Icons.assignment_outlined;
      case 'lab':
        return Icons.science_outlined;
      case 'quiz':
        return Icons.quiz_outlined;
      case 'discussion':
        return Icons.forum_outlined;
      case 'material':
        return Icons.menu_book_outlined;
      case 'exam_schedule':
        return Icons.event_note_outlined;
      case 'campus_event':
        return Icons.event_available_outlined;
      default:
        return Icons.link_outlined;
    }
  }

  String? _actionHint() {
    final actionUrl = widget.notification.actionUrl?.trim();
    if (actionUrl == null || actionUrl.isEmpty) {
      return null;
    }

    if (actionUrl.contains('/submissions')) {
      return 'Open submissions';
    }
    if (actionUrl.contains('/grading')) {
      return 'Open grading';
    }
    if (actionUrl.contains('/assignments/')) {
      return 'Open assignments';
    }
    if (actionUrl.contains('/labs/')) {
      return 'Open labs';
    }
    if (actionUrl.contains('/quizzes/')) {
      return 'Open quizzes';
    }
    if (actionUrl.contains('/schedule')) {
      return 'Open schedule';
    }
    return 'Open details';
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.announcement:
        return Icons.campaign_outlined;
      case NotificationType.grade:
        return Icons.grading_outlined;
      case NotificationType.assignment:
        return Icons.assignment_outlined;
      case NotificationType.message:
        return Icons.mail_outline;
      case NotificationType.deadline:
        return Icons.schedule_outlined;
      case NotificationType.system:
        return Icons.info_outline;
      case NotificationType.lab:
        return Icons.science_outlined;
      case NotificationType.quiz:
        return Icons.quiz_outlined;
      case NotificationType.material:
        return Icons.menu_book_outlined;
      case NotificationType.community:
        return Icons.groups_outlined;
      case NotificationType.discussion:
        return Icons.forum_outlined;
      case NotificationType.enrollment:
        return Icons.school_outlined;
      case NotificationType.schedule:
        return Icons.event_outlined;
      case NotificationType.officeHours:
        return Icons.support_agent_outlined;
      case NotificationType.unknown:
        return Icons.notifications_outlined;
    }
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.announcement:
        return const Color(0xFF673AB7);
      case NotificationType.grade:
        return const Color(0xFF1D4ED8);
      case NotificationType.assignment:
        return const Color(0xFFFF6B6B);
      case NotificationType.message:
        return const Color(0xFF9B59B6);
      case NotificationType.deadline:
        return AppTheme.warningColor;
      case NotificationType.system:
        return const Color(0xFF607D8B);
      case NotificationType.lab:
        return const Color(0xFF4CAF50);
      case NotificationType.quiz:
        return const Color(0xFFFF9800);
      case NotificationType.material:
        return AppTheme.primaryColor;
      case NotificationType.community:
        return const Color(0xFFEC4899);
      case NotificationType.discussion:
        return const Color(0xFF059669);
      case NotificationType.enrollment:
        return AppTheme.accentColor;
      case NotificationType.schedule:
        return const Color(0xFF0EA5E9);
      case NotificationType.officeHours:
        return const Color(0xFF8B5CF6);
      case NotificationType.unknown:
        return const Color(0xFF64748B);
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

// Delete Notification Dialog
class _DeleteNotificationDialog extends StatefulWidget {
  final bool isDark;
  final AppLocalizations l10n;
  final VoidCallback onCancel;
  final VoidCallback onDelete;

  const _DeleteNotificationDialog({
    required this.isDark,
    required this.l10n,
    required this.onCancel,
    required this.onDelete,
  });

  @override
  State<_DeleteNotificationDialog> createState() =>
      _DeleteNotificationDialogState();
}

class _DeleteNotificationDialogState extends State<_DeleteNotificationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 340),
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF1E1E2D) : Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with icon
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFEF4444).withValues(alpha: 0.15),
                        const Color(0xFFDC2626).withValues(alpha: 0.08),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 600),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: 0.8 + (0.2 * value),
                            child: Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFEF4444),
                                    Color(0xFFDC2626),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFEF4444,
                                    ).withValues(alpha: 0.4),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.delete_forever_rounded,
                                color: Colors.white,
                                size: 44,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.l10n.delete,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: widget.isDark
                              ? Colors.white
                              : const Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content section
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Warning card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: widget.isDark
                              ? const Color(0xFF252D48)
                              : const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(
                              0xFFEF4444,
                            ).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFEF4444,
                                ).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.warning_amber_rounded,
                                color: Color(0xFFEF4444),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                'Are you sure you want to delete this notification? This action cannot be undone.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: widget.isDark
                                      ? const Color(0xFF9CA3AF)
                                      : const Color(0xFF6B7280),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Action buttons
                      Row(
                        children: [
                          // Cancel button
                          Expanded(
                            child: GestureDetector(
                              onTap: widget.onCancel,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.isDark
                                      ? const Color(0xFF252D48)
                                      : const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: widget.isDark
                                        ? const Color(0xFF374151)
                                        : const Color(0xFFE5E7EB),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.close_rounded,
                                      color: widget.isDark
                                          ? const Color(0xFF9CA3AF)
                                          : const Color(0xFF6B7280),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      widget.l10n.cancel,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: widget.isDark
                                            ? const Color(0xFF9CA3AF)
                                            : const Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Delete button
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: widget.onDelete,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFEF4444),
                                      Color(0xFFDC2626),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFEF4444,
                                      ).withValues(alpha: 0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.delete_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      widget.l10n.delete,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
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
      ),
    );
  }
}

// Archive Notification Dialog
class _ArchiveNotificationDialog extends StatefulWidget {
  final bool isDark;
  final AppLocalizations l10n;
  final VoidCallback onCancel;
  final VoidCallback onArchive;

  const _ArchiveNotificationDialog({
    required this.isDark,
    required this.l10n,
    required this.onCancel,
    required this.onArchive,
  });

  @override
  State<_ArchiveNotificationDialog> createState() =>
      _ArchiveNotificationDialogState();
}

class _ArchiveNotificationDialogState extends State<_ArchiveNotificationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 340),
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF1E1E2D) : Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with icon
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFF59E0B).withValues(alpha: 0.15),
                        const Color(0xFFD97706).withValues(alpha: 0.08),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 600),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: 0.8 + (0.2 * value),
                            child: Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFF59E0B),
                                    Color(0xFFD97706),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFF59E0B,
                                    ).withValues(alpha: 0.4),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.archive_rounded,
                                color: Colors.white,
                                size: 44,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.l10n.archive,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: widget.isDark
                              ? Colors.white
                              : const Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content section
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Info card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: widget.isDark
                              ? const Color(0xFF252D48)
                              : const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(
                              0xFFF59E0B,
                            ).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFF59E0B,
                                ).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.info_outline_rounded,
                                color: Color(0xFFF59E0B),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                'Archive this notification? You can find it later in the archived section.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: widget.isDark
                                      ? const Color(0xFF9CA3AF)
                                      : const Color(0xFF6B7280),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Action buttons
                      Row(
                        children: [
                          // Cancel button
                          Expanded(
                            child: GestureDetector(
                              onTap: widget.onCancel,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.isDark
                                      ? const Color(0xFF252D48)
                                      : const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: widget.isDark
                                        ? const Color(0xFF374151)
                                        : const Color(0xFFE5E7EB),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.close_rounded,
                                      color: widget.isDark
                                          ? const Color(0xFF9CA3AF)
                                          : const Color(0xFF6B7280),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      widget.l10n.cancel,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: widget.isDark
                                            ? const Color(0xFF9CA3AF)
                                            : const Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Archive button
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: widget.onArchive,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFF59E0B),
                                      Color(0xFFD97706),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFF59E0B,
                                      ).withValues(alpha: 0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.archive_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      widget.l10n.archive,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
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
      ),
    );
  }
}
