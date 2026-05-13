import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/notifications/notification_cubit.dart';
import '../../../bloc/notifications/notification_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/notifications/notification_model.dart';
import '../../../models/notifications/swipe_action_model.dart';
import '../../../services/notification_swipe_settings_service.dart';
import '../../../utils/navigation/safe_back.dart';
import '../../../utils/notifications/notification_action_resolver.dart';
import '../../../widgets/shared/loading/notification_screen_skeleton.dart';
import '../../../widgets/shared/notifications/shared_notification_action_sheet.dart';
import '../../../widgets/shared/notifications/shared_notification_card.dart';
import '../../../widgets/shared/notifications/shared_notification_confirm_dialog.dart';
import '../../../widgets/shared/notifications/shared_notification_empty_state.dart';
import '../../../widgets/shared/notifications/shared_notification_filter_bar.dart';
import '../../../widgets/shared/notifications/shared_notification_header.dart';
import '../../../widgets/shared/notifications/shared_notification_role_theme.dart';

class SharedNotificationsScreen extends StatefulWidget {
  const SharedNotificationsScreen({super.key, required this.role});

  final SharedNotificationRole role;

  @override
  State<SharedNotificationsScreen> createState() =>
      _SharedNotificationsScreenState();
}

class _SharedNotificationsScreenState extends State<SharedNotificationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  SharedNotificationStatusFilter _statusFilter =
      SharedNotificationStatusFilter.all;
  SharedNotificationTypeFilter _typeFilter = SharedNotificationTypeFilter.all;
  NotificationSwipeSettings _swipeSettings = const NotificationSwipeSettings();

  SharedNotificationRoleTheme get _roleTheme =>
      SharedNotificationRoleTheme.fromRole(widget.role);

  @override
  void initState() {
    super.initState();
    _loadSwipeSettings();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final cubit = context.read<NotificationCubit>();
      cubit.ensureCurrentSessionLoaded();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadSwipeSettings() async {
    final settings = await NotificationSwipeSettingsService.instance
        .getSwipeSettings();
    if (!mounted) {
      return;
    }
    setState(() => _swipeSettings = settings);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final roleTheme = _roleTheme;

    return Scaffold(
      backgroundColor: roleTheme.scaffoldColor(isDark),
      body: SafeArea(
        child: BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) {
            final filtered = _filteredNotifications(state.notifications);
            final isLoading = state.status == NotificationLoadingStatus.loading;
            final hasData = state.notifications.isNotEmpty;

            return RefreshIndicator(
              color: roleTheme.primary,
              backgroundColor: roleTheme.cardColor(isDark),
              onRefresh: () =>
                  context.read<NotificationCubit>().loadNotifications(),
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: SharedNotificationHeader(
                      roleTheme: roleTheme,
                      totalCount: state.notifications.length,
                      unreadCount: state.unreadCount,
                      isRealtimeConnected: state.isRealtimeConnected,
                      canMarkAllRead: state.notifications.any(
                        (notification) =>
                            !notification.isRead &&
                            notification.allowsReadMutation,
                      ),
                      canClearRead: state.notifications.any(
                        (notification) =>
                            notification.isRead &&
                            notification.allowsDeleteMutation,
                      ),
                      canClearAll: state.notifications.any(
                        (notification) => notification.allowsDeleteMutation,
                      ),
                      onBack: () =>
                          safeBack(context, roleTheme.backFallbackRoute),
                      onToolAction: (action) =>
                          _handleToolAction(context, action),
                    ),
                  ),
                  if (isLoading && hasData)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            minHeight: 3,
                            color: roleTheme.primary,
                            backgroundColor: roleTheme.mutedTint(isDark),
                          ),
                        ),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: _SearchBar(
                      roleTheme: roleTheme,
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                      child: SharedNotificationFilterBar(
                        roleTheme: roleTheme,
                        statusFilter: _statusFilter,
                        typeFilter: _typeFilter,
                        onStatusChanged: (value) =>
                            setState(() => _statusFilter = value),
                        onTypeChanged: (value) =>
                            setState(() => _typeFilter = value),
                      ),
                    ),
                  ),
                  if (isLoading && !hasData)
                    SliverFillRemaining(
                      child: NotificationScreenSkeleton(
                        isDark: isDark,
                        showSearchBar: true,
                        showActionButtons: true,
                      ),
                    )
                  else if (state.status == NotificationLoadingStatus.error &&
                      !hasData)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: SharedNotificationEmptyState(
                        roleTheme: roleTheme,
                        icon: Icons.cloud_off_outlined,
                        title: AppLocalizations.of(
                          context,
                        ).sharedNotifLoadFailedTitle,
                        subtitle:
                            state.errorMessage ??
                            AppLocalizations.of(context).errorOccurred,
                        actionLabel: AppLocalizations.of(context).tryAgain,
                        onAction: () => context
                            .read<NotificationCubit>()
                            .loadNotifications(),
                      ),
                    )
                  else if (filtered.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: SharedNotificationEmptyState(
                        roleTheme: roleTheme,
                        icon: _hasActiveFilters
                            ? Icons.manage_search_rounded
                            : Icons.notifications_paused_outlined,
                        title: _hasActiveFilters
                            ? AppLocalizations.of(
                                context,
                              ).sharedNotifNoFilteredTitle
                            : AppLocalizations.of(
                                context,
                              ).notificationNoNotifications,
                        subtitle: _hasActiveFilters
                            ? AppLocalizations.of(
                                context,
                              ).sharedNotifNoFilteredSubtitle
                            : AppLocalizations.of(
                                context,
                              ).notificationNoNotificationsDesc,
                        actionLabel: _hasActiveFilters
                            ? AppLocalizations.of(
                                context,
                              ).notificationClearFilters
                            : null,
                        onAction: _hasActiveFilters ? _clearFilters : null,
                      ),
                    )
                  else ...[
                    SliverToBoxAdapter(
                      child: _ResultSummary(
                        roleTheme: roleTheme,
                        count: filtered.length,
                      ),
                    ),
                    ..._notificationGroups(filtered).expand(
                      (group) => [
                        SliverToBoxAdapter(
                          child: _SectionLabel(
                            roleTheme: roleTheme,
                            label: group.label,
                          ),
                        ),
                        SliverList.builder(
                          itemCount: group.items.length,
                          itemBuilder: (context, index) => _buildSwipeWrapper(
                            context,
                            roleTheme,
                            group.items[index],
                          ),
                        ),
                      ],
                    ),
                    const SliverPadding(padding: EdgeInsets.only(bottom: 18)),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  bool get _hasActiveFilters =>
      _searchController.text.trim().isNotEmpty ||
      _statusFilter != SharedNotificationStatusFilter.all ||
      _typeFilter != SharedNotificationTypeFilter.all;

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _statusFilter = SharedNotificationStatusFilter.all;
      _typeFilter = SharedNotificationTypeFilter.all;
    });
  }

  List<NotificationModel> _filteredNotifications(
    List<NotificationModel> notifications,
  ) {
    final query = _searchController.text.trim().toLowerCase();
    return notifications.where((notification) {
      final statusMatches = switch (_statusFilter) {
        SharedNotificationStatusFilter.all => true,
        SharedNotificationStatusFilter.unread => !notification.isRead,
        SharedNotificationStatusFilter.read => notification.isRead,
      };
      if (!statusMatches || !_typeFilter.matches(notification)) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      final searchable = [
        notification.title,
        notification.message,
        notification.courseName,
        notification.instructorName,
        notification.rawType,
        notification.relatedEntityType,
      ].whereType<String>().join(' ').toLowerCase();
      return searchable.contains(query);
    }).toList();
  }

  List<_NotificationGroup> _notificationGroups(List<NotificationModel> items) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(const Duration(days: 7));
    final today = <NotificationModel>[];
    final thisWeek = <NotificationModel>[];
    final earlier = <NotificationModel>[];

    for (final item in items) {
      if (!item.createdAt.isBefore(todayStart)) {
        today.add(item);
      } else if (!item.createdAt.isBefore(weekStart)) {
        thisWeek.add(item);
      } else {
        earlier.add(item);
      }
    }

    return [
      _NotificationGroup(l10n.notificationToday, today),
      _NotificationGroup(l10n.notificationThisWeek, thisWeek),
      _NotificationGroup(l10n.notificationEarlier, earlier),
    ].where((group) => group.items.isNotEmpty).toList();
  }

  Widget _buildSwipeWrapper(
    BuildContext context,
    SharedNotificationRoleTheme roleTheme,
    NotificationModel notification,
  ) {
    final leftAction = _swipeSettings.leftAction;
    final rightAction = _swipeSettings.rightAction;
    final canSwipeLeft = _canExecuteSwipe(leftAction, notification);
    final canSwipeRight = _canExecuteSwipe(rightAction, notification);

    DismissDirection direction;
    if (canSwipeLeft && canSwipeRight) {
      direction = DismissDirection.horizontal;
    } else if (canSwipeLeft) {
      direction = DismissDirection.endToStart;
    } else if (canSwipeRight) {
      direction = DismissDirection.startToEnd;
    } else {
      direction = DismissDirection.none;
    }

    if (direction == DismissDirection.none) {
      return SharedNotificationCard(
        roleTheme: roleTheme,
        notification: notification,
        onTap: () => _openNotification(notification),
        onMore: () => _showCardActions(notification),
      );
    }

    return Dismissible(
      key: ValueKey('notification-${notification.id}'),
      direction: direction,
      background: _SwipeBackground(action: rightAction, alignStart: true),
      secondaryBackground: _SwipeBackground(
        action: leftAction,
        alignStart: false,
      ),
      confirmDismiss: (dismissDirection) async {
        final action = dismissDirection == DismissDirection.endToStart
            ? leftAction
            : rightAction;
        if (!_canExecuteSwipe(action, notification)) {
          _showSnack(AppLocalizations.of(context).sharedNotifSwipeUnsupported);
          return false;
        }
        if (_swipeSettings.confirmBeforeAction || action.requiresConfirmation) {
          final confirmed = await _confirmSwipeAction(action, notification);
          if (!confirmed) {
            return false;
          }
        }
        if (action == SwipeAction.markRead) {
          await _executeSwipeAction(action, notification);
          return false;
        }
        return true;
      },
      onDismissed: (direction) {
        final action = direction == DismissDirection.endToStart
            ? leftAction
            : rightAction;
        if (action == SwipeAction.delete) {
          _executeSwipeAction(action, notification);
        }
      },
      child: SharedNotificationCard(
        roleTheme: roleTheme,
        notification: notification,
        onTap: () => _openNotification(notification),
        onMore: () => _showCardActions(notification),
      ),
    );
  }

  Future<void> _openNotification(NotificationModel notification) async {
    final cubit = context.read<NotificationCubit>();
    if (!notification.isRead && notification.allowsReadMutation) {
      await cubit.markAsRead(notification.id);
      if (!mounted) {
        return;
      }
    }

    final route = NotificationActionResolver.resolveRoute(
      notification,
      rolePrefix: _roleTheme.rolePrefix,
    );
    if (route == null || route.isEmpty) {
      _showSnack(AppLocalizations.of(context).sharedNotifNoRoute);
      return;
    }

    try {
      context.push(route);
    } catch (_) {
      _showSnack(AppLocalizations.of(context).sharedNotifNoRoute);
    }
  }

  Future<void> _showCardActions(NotificationModel notification) async {
    final action = await SharedNotificationActionSheet.show(
      context: context,
      roleTheme: _roleTheme,
      notification: notification,
    );
    if (!mounted || action == null) {
      return;
    }

    switch (action) {
      case SharedNotificationCardAction.open:
        await _openNotification(notification);
      case SharedNotificationCardAction.markRead:
        await context.read<NotificationCubit>().markAsRead(notification.id);
        if (mounted) {
          _showSnack(AppLocalizations.of(context).notificationMarkedRead);
        }
      case SharedNotificationCardAction.delete:
        await _deleteNotification(notification);
    }
  }

  Future<void> _deleteNotification(NotificationModel notification) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await SharedNotificationConfirmDialog.show(
      context: context,
      roleTheme: _roleTheme,
      icon: Icons.delete_outline_rounded,
      title: l10n.sharedNotifDeleteTitle,
      message: l10n.sharedNotifDeleteMessage(notification.title),
      confirmLabel: l10n.delete,
      isDestructive: true,
    );
    if (!mounted || !confirmed) {
      return;
    }
    await context.read<NotificationCubit>().deleteNotification(notification.id);
    if (mounted) {
      _showSnack(l10n.notificationDeleted);
    }
  }

  Future<void> _handleToolAction(
    BuildContext context,
    SharedNotificationToolAction action,
  ) async {
    final cubit = context.read<NotificationCubit>();
    final l10n = AppLocalizations.of(context);

    switch (action) {
      case SharedNotificationToolAction.swipeSettings:
        await context.push('/settings/swipe-actions/notifications');
        if (!mounted) {
          return;
        }
        NotificationSwipeSettingsService.instance.clearCache();
        await _loadSwipeSettings();
      case SharedNotificationToolAction.markAllRead:
        await cubit.markAllAsRead();
        if (mounted) {
          _showSnack(l10n.notificationMarkedAllRead);
        }
      case SharedNotificationToolAction.clearRead:
        final confirmed = await SharedNotificationConfirmDialog.show(
          context: context,
          roleTheme: _roleTheme,
          icon: Icons.cleaning_services_outlined,
          title: l10n.sharedNotifClearReadTitle,
          message: l10n.sharedNotifClearReadMessage,
          confirmLabel: l10n.notificationConfirm,
          isDestructive: true,
        );
        if (!mounted || !confirmed) {
          return;
        }
        await cubit.clearReadNotifications();
        if (mounted) {
          _showSnack(l10n.notificationReadCleared);
        }
      case SharedNotificationToolAction.clearAll:
        final confirmed = await SharedNotificationConfirmDialog.show(
          context: context,
          roleTheme: _roleTheme,
          icon: Icons.delete_sweep_outlined,
          title: l10n.sharedNotifClearAllTitle,
          message: l10n.sharedNotifClearAllMessage,
          confirmLabel: l10n.delete,
          isDestructive: true,
        );
        if (!mounted || !confirmed) {
          return;
        }
        await cubit.clearAllNotifications();
        if (mounted) {
          _showSnack(l10n.notificationAllCleared);
        }
    }
  }

  bool _canExecuteSwipe(SwipeAction action, NotificationModel notification) {
    switch (action) {
      case SwipeAction.delete:
        return notification.allowsDeleteMutation;
      case SwipeAction.markRead:
        return !notification.isRead && notification.allowsReadMutation;
      case SwipeAction.none:
      case SwipeAction.markUnread:
      case SwipeAction.archive:
      case SwipeAction.bookmark:
        return false;
    }
  }

  Future<bool> _confirmSwipeAction(
    SwipeAction action,
    NotificationModel notification,
  ) {
    final l10n = AppLocalizations.of(context);
    return SharedNotificationConfirmDialog.show(
      context: context,
      roleTheme: _roleTheme,
      icon: action == SwipeAction.delete
          ? Icons.delete_outline_rounded
          : Icons.mark_email_read_outlined,
      title: action == SwipeAction.delete
          ? l10n.sharedNotifDeleteTitle
          : l10n.markAsRead,
      message: action == SwipeAction.delete
          ? l10n.sharedNotifDeleteMessage(notification.title)
          : l10n.sharedNotifMarkReadMessage(notification.title),
      confirmLabel: action == SwipeAction.delete ? l10n.delete : l10n.confirm,
      isDestructive: action == SwipeAction.delete,
    );
  }

  Future<void> _executeSwipeAction(
    SwipeAction action,
    NotificationModel notification,
  ) async {
    final cubit = context.read<NotificationCubit>();
    final l10n = AppLocalizations.of(context);
    switch (action) {
      case SwipeAction.delete:
        await cubit.deleteNotification(notification.id);
        _showSnack(l10n.notificationDeleted);
      case SwipeAction.markRead:
        await cubit.markAsRead(notification.id);
        _showSnack(l10n.notificationMarkedRead);
      case SwipeAction.none:
      case SwipeAction.markUnread:
      case SwipeAction.archive:
      case SwipeAction.bookmark:
        _showSnack(l10n.sharedNotifSwipeUnsupported);
    }
  }

  void _showSnack(String message) {
    if (!mounted) {
      return;
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isDark
              ? const Color(0xFF1E293B)
              : _roleTheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.roleTheme,
    required this.controller,
    required this.onChanged,
  });

  final SharedNotificationRoleTheme roleTheme;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: TextStyle(
          color: roleTheme.textPrimary(isDark),
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: l10n.sharedNotifSearchHint,
          hintStyle: TextStyle(
            color: roleTheme.textSecondary(isDark),
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Icon(Icons.search_rounded, color: roleTheme.primary),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: l10n.notificationClearFilters,
                  icon: Icon(
                    Icons.close_rounded,
                    color: roleTheme.textSecondary(isDark),
                  ),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                ),
          filled: true,
          fillColor: roleTheme.surfaceColor(isDark),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: roleTheme.borderColor(isDark)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: roleTheme.borderColor(isDark)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: roleTheme.primary, width: 1.4),
          ),
        ),
      ),
    );
  }
}

class _ResultSummary extends StatelessWidget {
  const _ResultSummary({required this.roleTheme, required this.count});

  final SharedNotificationRoleTheme roleTheme;
  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      child: Row(
        children: [
          Text(
            l10n.sharedNotifShowingCount(count),
            style: TextStyle(
              color: roleTheme.textSecondary(isDark),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: roleTheme.primary,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.roleTheme, required this.label});

  final SharedNotificationRoleTheme roleTheme;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 9),
      child: Text(
        label,
        style: TextStyle(
          color: roleTheme.textPrimary(isDark),
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({required this.action, required this.alignStart});

  final SwipeAction action;
  final bool alignStart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = switch (action) {
      SwipeAction.delete => l10n.delete,
      SwipeAction.markRead => l10n.markAsRead,
      SwipeAction.none ||
      SwipeAction.markUnread ||
      SwipeAction.archive ||
      SwipeAction.bookmark => l10n.noAction,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        alignment: alignStart ? Alignment.centerLeft : Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          color: action.color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: alignStart
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: [
            Icon(action.icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationGroup {
  const _NotificationGroup(this.label, this.items);

  final String label;
  final List<NotificationModel> items;
}
