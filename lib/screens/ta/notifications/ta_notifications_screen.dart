import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/notifications/notification_cubit.dart';
import '../../../bloc/notifications/notification_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/notifications/notification_model.dart';
import '../../../models/notifications/swipe_action_model.dart';
import '../../../services/notification_swipe_settings_service.dart';
import '../../../utils/notifications/notification_action_resolver.dart';
import '../../../widgets/shared/loading/notification_screen_skeleton.dart';
import '../../../widgets/ta/dashboard/ta_drawer.dart';
import '../../../widgets/ta/notifications/ta_notifications_barrel.dart';
import '../../../widgets/ta/shared/ta_colors.dart';

class TANotificationsScreen extends StatefulWidget {
  const TANotificationsScreen({super.key});

  @override
  State<TANotificationsScreen> createState() => _TANotificationsScreenState();
}

class _TANotificationsScreenState extends State<TANotificationsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _searchQuery = '';
  String _selectedFilter = 'all';
  String? _expandedNotificationId;
  NotificationSwipeSettings _swipeSettings = const NotificationSwipeSettings();

  @override
  void initState() {
    super.initState();
    _loadSwipeSettings();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<NotificationCubit>().loadNotifications();
    });
  }

  Future<void> _loadSwipeSettings() async {
    final settings = await NotificationSwipeSettingsService.instance
        .getSwipeSettings();
    if (!mounted) return;
    setState(() => _swipeSettings = settings);
  }

  List<NotificationModel> _filteredNotifications(NotificationState state) {
    var filtered = List<NotificationModel>.from(state.notifications);

    switch (_selectedFilter) {
      case 'unread':
        filtered = filtered.where((n) => !n.isRead).toList();
        break;
      case 'read':
        filtered = filtered.where((n) => n.isRead).toList();
        break;
      case 'submissions':
        filtered = filtered
            .where(
              (n) =>
                  n.type == NotificationType.assignment ||
                  n.type == NotificationType.lab ||
                  n.type == NotificationType.quiz,
            )
            .toList();
        break;
      case 'grading':
        filtered = filtered
            .where((n) => n.type == NotificationType.grade)
            .toList();
        break;
      case 'discussions':
        filtered = filtered
            .where(
              (n) =>
                  n.type == NotificationType.discussion ||
                  n.type == NotificationType.message ||
                  n.type == NotificationType.community,
            )
            .toList();
        break;
      case 'schedule':
        filtered = filtered
            .where(
              (n) =>
                  n.type == NotificationType.schedule ||
                  n.type == NotificationType.officeHours ||
                  n.type == NotificationType.deadline,
            )
            .toList();
        break;
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (n) =>
                n.title.toLowerCase().contains(query) ||
                n.message.toLowerCase().contains(query) ||
                (n.courseName?.toLowerCase().contains(query) ?? false),
          )
          .toList();
    }

    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
  }

  TANotificationItem _mapToTAItem(NotificationModel notification) {
    final diff = DateTime.now().difference(notification.createdAt);
    final timeAgo = diff.inMinutes < 60
        ? '${diff.inMinutes.clamp(0, 59)} mins ago'
        : diff.inHours < 24
        ? '${diff.inHours} hours ago'
        : '${diff.inDays} days ago';

    return TANotificationItem(
      id: notification.id,
      title: notification.title,
      senderName: notification.instructorName ?? 'EduVerse',
      preview: notification.message,
      timeAgo: timeAgo,
      type: _mapType(notification.type),
      badge: _primaryBadge(notification),
      secondaryBadge: _priorityBadge(notification),
      isUnread: !notification.isRead,
      fullContent: notification.message,
      relatedTo: _relatedLabel(notification),
      actionHint: _actionHint(notification),
    );
  }

  String _primaryBadge(NotificationModel notification) {
    switch (notification.type) {
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
      case NotificationType.discussion:
        return 'Discussion';
      case NotificationType.message:
        return 'Message';
      case NotificationType.community:
        return 'Community';
      case NotificationType.deadline:
        return 'Deadline';
      case NotificationType.schedule:
        return 'Schedule';
      case NotificationType.officeHours:
        return 'Office Hours';
      case NotificationType.enrollment:
        return 'Enrollment';
      case NotificationType.announcement:
        return 'Announcement';
      case NotificationType.system:
      case NotificationType.unknown:
        return notification.rawType;
    }
  }

  String _priorityBadge(NotificationModel notification) {
    switch (notification.priority) {
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

  String? _relatedLabel(NotificationModel notification) {
    final parts = <String>[];
    if (notification.courseName?.trim().isNotEmpty == true) {
      parts.add(notification.courseName!.trim());
    }
    final entityType = notification.relatedEntityType?.trim();
    final entityId = notification.relatedEntityId?.trim();
    if (entityType != null && entityType.isNotEmpty) {
      final normalizedType = switch (entityType.toLowerCase()) {
        'assignment' => 'Assignment',
        'lab' => 'Lab',
        'quiz' => 'Quiz',
        'discussion' => 'Discussion',
        'material' => 'Material',
        'exam_schedule' => 'Exam',
        'campus_event' => 'Event',
        _ => entityType,
      };
      parts.add(
        entityId != null && entityId.isNotEmpty
            ? '$normalizedType #$entityId'
            : normalizedType,
      );
    }
    if (parts.isEmpty) {
      return null;
    }
    return parts.join(' • ');
  }

  String? _actionHint(NotificationModel notification) {
    final actionUrl = notification.actionUrl?.trim();
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

  TANotificationType _mapType(NotificationType type) {
    switch (type) {
      case NotificationType.assignment:
      case NotificationType.lab:
      case NotificationType.quiz:
        return TANotificationType.submission;
      case NotificationType.grade:
        return TANotificationType.grade;
      case NotificationType.announcement:
        return TANotificationType.announcement;
      case NotificationType.discussion:
      case NotificationType.message:
      case NotificationType.community:
        return TANotificationType.discussion;
      case NotificationType.material:
        return TANotificationType.material;
      case NotificationType.deadline:
        return TANotificationType.deadline;
      case NotificationType.schedule:
        return TANotificationType.schedule;
      case NotificationType.officeHours:
        return TANotificationType.officeHours;
      case NotificationType.enrollment:
      case NotificationType.system:
      case NotificationType.unknown:
        return TANotificationType.system;
    }
  }

  Future<void> _openNotification(
    NotificationModel notification,
    AppLocalizations l10n,
  ) async {
    if (!notification.isRead) {
      await context.read<NotificationCubit>().markAsRead(notification.id);
    }

    final route = NotificationActionResolver.resolveRoute(
      notification,
      rolePrefix: '/ta',
    );
    if (!mounted || route == null) return;
    try {
      context.push(route);
    } catch (_) {
      _showSnackBar(l10n.notificationMarkedRead);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _executeSwipeAction(SwipeAction action, NotificationModel notification) {
    switch (action) {
      case SwipeAction.delete:
        context.read<NotificationCubit>().deleteNotification(notification.id);
        _showSnackBar('Notification deleted');
        break;
      case SwipeAction.markRead:
        context.read<NotificationCubit>().markAsRead(notification.id);
        _showSnackBar('Notification marked as read');
        break;
      case SwipeAction.markUnread:
      case SwipeAction.archive:
      case SwipeAction.bookmark:
      case SwipeAction.none:
        break;
    }
  }

  Future<bool> _showSwipeActionConfirmation(
    bool isDark,
    AppLocalizations l10n,
    NotificationModel notification,
    SwipeAction action,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TAColors.cardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          action == SwipeAction.delete ? l10n.delete : l10n.markAsRead,
          style: TextStyle(color: TAColors.textPrimaryColor(isDark)),
        ),
        content: Text(
          action == SwipeAction.delete
              ? 'Delete "${notification.title}"?'
              : 'Mark "${notification.title}" as read?',
          style: TextStyle(color: TAColors.textSecondaryColor(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action == SwipeAction.delete ? l10n.delete : l10n.confirm),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showBulkActionsSheet(
    bool isDark,
    AppLocalizations l10n,
    NotificationState state,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: TAColors.cardColor(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: TAColors.borderColor(isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.taNotifBulkActions,
              style: TextStyle(
                color: TAColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            _buildBulkActionItem(
              icon: Icons.mark_email_read_outlined,
              label: l10n.taNotifMarkAllRead,
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                this.context.read<NotificationCubit>().markAllAsRead();
              },
            ),
            _buildBulkActionItem(
              icon: Icons.cleaning_services_outlined,
              label: 'Clear read',
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                this.context.read<NotificationCubit>().clearReadNotifications();
              },
            ),
            _buildBulkActionItem(
              icon: Icons.delete_sweep_outlined,
              label: l10n.taNotifDeleteAll,
              color: TAColors.error,
              isDark: isDark,
              onTap: state.notifications.isEmpty
                  ? null
                  : () {
                      Navigator.pop(context);
                      _showDeleteAllConfirmation(isDark, l10n);
                    },
            ),
            _buildBulkActionItem(
              icon: Icons.settings_outlined,
              label: l10n.taNotifSwipeSettings,
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                context.push('/settings/swipe-actions/notifications').then((_) {
                  NotificationSwipeSettingsService.instance.clearCache();
                  _loadSwipeSettings();
                });
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildBulkActionItem({
    required IconData icon,
    required String label,
    required bool isDark,
    Color? color,
    VoidCallback? onTap,
  }) {
    return ListTile(
      enabled: onTap != null,
      leading: Icon(icon, color: color ?? TAColors.primary),
      title: Text(
        label,
        style: TextStyle(
          color: color ?? TAColors.textPrimaryColor(isDark),
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  void _showDeleteAllConfirmation(bool isDark, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TAColors.cardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.taNotifDeleteAllTitle,
          style: TextStyle(color: TAColors.textPrimaryColor(isDark)),
        ),
        content: Text(
          l10n.taNotifDeleteAllMessage,
          style: TextStyle(color: TAColors.textSecondaryColor(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              this.context.read<NotificationCubit>().clearAllNotifications();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TAColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) {
            final notifications = _filteredNotifications(state);

            return Scaffold(
              key: _scaffoldKey,
              backgroundColor: TAColors.scaffoldColor(isDark),
              drawer: TADrawer(currentRoute: '/ta/notifications', isDark: isDark),
              body: SafeArea(
                child: state.status == NotificationLoadingStatus.loading
                    ? CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          _buildAppBar(isDark, l10n, state),
                          SliverFillRemaining(
                            child: NotificationScreenSkeleton(
                              isDark: isDark,
                              showSearchBar: true,
                              showActionButtons: true,
                            ),
                          ),
                        ],
                      )
                    : RefreshIndicator(
                        onRefresh: () => context
                            .read<NotificationCubit>()
                            .loadNotifications(),
                        color: TAColors.primary,
                        child: CustomScrollView(
                          slivers: [
                            _buildAppBar(isDark, l10n, state),
                            SliverToBoxAdapter(
                              child: _buildActionBar(isDark, l10n, state),
                            ),
                            SliverToBoxAdapter(
                              child: _buildFilterChips(isDark, l10n),
                            ),
                            if (notifications.isEmpty)
                              SliverToBoxAdapter(
                                child: _buildEmptyState(isDark, l10n),
                              )
                            else
                              SliverPadding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate((
                                    context,
                                    index,
                                  ) {
                                    final notification = notifications[index];
                                    final cardItem = _mapToTAItem(notification);
                                    final isExpanded =
                                        _expandedNotificationId ==
                                        notification.id;

                                    return Dismissible(
                                      key: Key('ta_notif_${notification.id}'),
                                      direction:
                                          DismissDirection.horizontal,
                                      dismissThresholds: {
                                        DismissDirection.startToEnd:
                                            _swipeSettings.swipeSensitivity,
                                        DismissDirection.endToStart:
                                            _swipeSettings.swipeSensitivity,
                                      },
                                      confirmDismiss: (direction) async {
                                        HapticFeedback.lightImpact();
                                        final action = direction ==
                                                DismissDirection.endToStart
                                            ? _swipeSettings.leftAction
                                            : _swipeSettings.rightAction;

                                        if (action == SwipeAction.none) {
                                          return false;
                                        }
                                        if (action.requiresConfirmation &&
                                            await _showSwipeActionConfirmation(
                                              isDark,
                                              l10n,
                                              notification,
                                              action,
                                            )) {
                                          _executeSwipeAction(
                                            action,
                                            notification,
                                          );
                                          return action ==
                                              SwipeAction.delete;
                                        }

                                        if (!action.requiresConfirmation) {
                                          _executeSwipeAction(
                                            action,
                                            notification,
                                          );
                                          return action ==
                                              SwipeAction.delete;
                                        }

                                        return false;
                                      },
                                      background: _buildSwipeBackground(
                                        action: _swipeSettings.rightAction,
                                        alignment: Alignment.centerLeft,
                                        l10n: l10n,
                                        isLeft: true,
                                      ),
                                      secondaryBackground:
                                          _buildSwipeBackground(
                                            action: _swipeSettings.leftAction,
                                            alignment:
                                                Alignment.centerRight,
                                            l10n: l10n,
                                            isLeft: false,
                                          ),
                                      child: TANotificationCard(
                                        isDark: isDark,
                                        notification: cardItem,
                                        isExpanded: isExpanded,
                                        onTap: () {
                                          setState(() {
                                            _expandedNotificationId =
                                                isExpanded
                                                ? null
                                                : notification.id;
                                          });
                                          _openNotification(
                                            notification,
                                            l10n,
                                          );
                                        },
                                        onReply: () => _openNotification(
                                          notification,
                                          l10n,
                                        ),
                                        onResolve: () => context
                                            .read<NotificationCubit>()
                                            .markAsRead(notification.id),
                                      ),
                                    );
                                  }, childCount: notifications.length),
                                ),
                              ),
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 24),
                            ),
                          ],
                        ),
                      ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSwipeBackground({
    required SwipeAction action,
    required AlignmentGeometry alignment,
    required AppLocalizations l10n,
    required bool isLeft,
  }) {
    final label = switch (action) {
      SwipeAction.delete => l10n.delete,
      SwipeAction.markRead => l10n.markAsRead,
      SwipeAction.none ||
      SwipeAction.markUnread ||
      SwipeAction.archive ||
      SwipeAction.bookmark => '',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: action.color,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: alignment,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: isLeft
            ? [
                Icon(action.icon, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ]
            : [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(action.icon, color: Colors.white),
              ],
      ),
    );
  }

  SliverAppBar _buildAppBar(
    bool isDark,
    AppLocalizations l10n,
    NotificationState state,
  ) {
    return SliverAppBar(
      backgroundColor: TAColors.scaffoldColor(isDark),
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        icon: Icon(
          Icons.menu_rounded,
          color: TAColors.textPrimaryColor(isDark),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.taNotifTitle,
            style: TextStyle(
              color: TAColors.textPrimaryColor(isDark),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            '${state.unreadCount} unread',
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontSize: 11,
            ),
          ),
        ],
      ),
      actions: [
        Icon(
          state.isRealtimeConnected
              ? Icons.wifi_tethering_rounded
              : Icons.wifi_tethering_error_rounded,
          color: state.isRealtimeConnected ? TAColors.success : TAColors.warning,
          size: 18,
        ),
        IconButton(
          onPressed: () =>
              context.read<ThemeBloc>().add(const ToggleThemeEvent()),
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: TAColors.textPrimaryColor(isDark),
          ),
        ),
      ],
      floating: true,
      pinned: true,
    );
  }

  Widget _buildActionBar(
    bool isDark,
    AppLocalizations l10n,
    NotificationState state,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: TAColors.cardColor(isDark),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
                ),
              ),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText: l10n.taNotifSearch,
                  hintStyle: TextStyle(
                    color: TAColors.textTertiaryColor(isDark),
                    fontSize: 13,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: TAColors.textTertiaryColor(isDark),
                    size: 18,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.tonalIcon(
            onPressed: () => _showBulkActionsSheet(isDark, l10n, state),
            icon: const Icon(Icons.checklist_rounded, size: 16),
            label: Text(l10n.taNotifBulkActions),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(bool isDark, AppLocalizations l10n) {
    final filters = [
      {'id': 'all', 'label': l10n.all, 'icon': Icons.all_inbox_rounded},
      {'id': 'unread', 'label': l10n.unread, 'icon': Icons.markunread_rounded},
      {'id': 'read', 'label': l10n.read, 'icon': Icons.drafts_rounded},
      {
        'id': 'submissions',
        'label': 'Submissions',
        'icon': Icons.upload_file_rounded,
      },
      {'id': 'grading', 'label': 'Grading', 'icon': Icons.grading_rounded},
      {
        'id': 'discussions',
        'label': 'Discussions',
        'icon': Icons.forum_rounded,
      },
      {'id': 'schedule', 'label': 'Schedule', 'icon': Icons.event_note_rounded},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    filter['icon'] as IconData,
                    size: 14,
                    color: isSelected
                        ? Colors.white
                        : TAColors.textSecondaryColor(isDark),
                  ),
                  const SizedBox(width: 6),
                  Text(filter['label'] as String),
                ],
              ),
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : TAColors.textPrimaryColor(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              backgroundColor: TAColors.cardColor(isDark),
              selectedColor: TAColors.primary,
              checkmarkColor: Colors.white,
              showCheckmark: false,
              side: BorderSide(
                color: isSelected
                    ? TAColors.primary
                    : TAColors.borderColor(isDark).withValues(alpha: 0.5),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onSelected: (_) {
                setState(() => _selectedFilter = filter['id'] as String);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 64,
            color: TAColors.textTertiaryColor(isDark),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.taNotifNoNotifications,
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.taNotifNoNotificationsHint,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: TAColors.textTertiaryColor(isDark),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
