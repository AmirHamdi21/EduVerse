import 'package:edu_verse/models/instructor/instrucor_notification_model.dart';
import 'package:edu_verse/models/notifications/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/notifications/notification_cubit.dart';
import '../../../bloc/notifications/notification_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../config/app_theme.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../utils/notifications/notification_action_resolver.dart';
import '../../../widgets/shared/loading/notification_screen_skeleton.dart';
import '../../../widgets/instructor/notifications/instructor_notifications_barrel.dart';

class InstructorNotificationsScreen extends StatefulWidget {
  const InstructorNotificationsScreen({super.key});

  @override
  State<InstructorNotificationsScreen> createState() =>
      _InstructorNotificationsScreenState();
}

class _InstructorNotificationsScreenState
    extends State<InstructorNotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showElevation = false;
  bool _isSearching = false;
  InstructorNotificationCategory _selectedCategory =
      InstructorNotificationCategory.all;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<NotificationCubit>().loadNotifications();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 0 && !_showElevation) {
      setState(() => _showElevation = true);
    } else if (_scrollController.offset <= 0 && _showElevation) {
      setState(() => _showElevation = false);
    }
  }

  List<InstructorNotificationModel> _mapNotifications(List<NotificationModel> items) {
    return items.map((notification) {
      return InstructorNotificationModel(
        id: notification.id,
        title: notification.title,
        message: notification.message,
        type: _mapToInstructorType(notification),
        timestamp: notification.createdAt,
        isRead: notification.isRead,
        courseName: notification.courseName,
        metadata: <String, dynamic>{
          'rawType': notification.rawType,
          'actionUrl': notification.actionUrl,
          'relatedEntityType': notification.relatedEntityType,
          'relatedEntityId': notification.relatedEntityId,
        },
      );
    }).toList();
  }

  InstructorNotificationType _mapToInstructorType(NotificationModel notification) {
    switch (notification.type) {
      case NotificationType.assignment:
      case NotificationType.lab:
      case NotificationType.quiz:
        return InstructorNotificationType.submission;
      case NotificationType.grade:
        return InstructorNotificationType.grading;
      case NotificationType.message:
      case NotificationType.community:
      case NotificationType.discussion:
        return InstructorNotificationType.message;
      case NotificationType.deadline:
      case NotificationType.schedule:
      case NotificationType.officeHours:
        return InstructorNotificationType.deadline;
      case NotificationType.enrollment:
        return InstructorNotificationType.attendance;
      case NotificationType.announcement:
        return InstructorNotificationType.announcement;
      case NotificationType.material:
      case NotificationType.system:
      case NotificationType.unknown:
        return InstructorNotificationType.system;
    }
  }

  List<InstructorNotificationModel> _getFilteredNotifications(
    NotificationState state,
    int tabIndex,
  ) {
    var filtered = _mapNotifications(state.notifications);

    if (tabIndex == 1) {
      filtered = filtered.where((n) => !n.isRead).toList();
    } else if (tabIndex == 2) {
      filtered = filtered.where((n) => n.isRead).toList();
    }

    if (_selectedCategory != InstructorNotificationCategory.all) {
      filtered = filtered.where((n) {
        switch (_selectedCategory) {
          case InstructorNotificationCategory.submissions:
            return n.type == InstructorNotificationType.submission;
          case InstructorNotificationCategory.grading:
            return n.type == InstructorNotificationType.grading;
          case InstructorNotificationCategory.messages:
            return n.type == InstructorNotificationType.message ||
                n.type == InstructorNotificationType.announcement;
          case InstructorNotificationCategory.deadlines:
            return n.type == InstructorNotificationType.deadline;
          case InstructorNotificationCategory.system:
            return n.type == InstructorNotificationType.system ||
                n.type == InstructorNotificationType.attendance;
          case InstructorNotificationCategory.all:
            return true;
        }
      }).toList();
    }

    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((n) {
        return n.title.toLowerCase().contains(query) ||
            n.message.toLowerCase().contains(query) ||
            (n.courseName?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return filtered;
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
      rolePrefix: '/instructor',
    );
    if (!mounted || route == null) return;
    try {
      context.push(route);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.notificationMarkedRead)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) {
            final unreadCount = state.unreadCount;

            return Scaffold(
              backgroundColor: isDarkMode
                  ? AppTheme.darkSurfaceColor
                  : const Color(0xFFF8FAFC),
              body: SafeArea(
                child: Column(
                  children: [
                    InstructorNotificationsHeader(
                      isDarkMode: isDarkMode,
                      showElevation: _showElevation,
                      unreadCount: unreadCount,
                      title: l10n.notifications,
                      isSearching: _isSearching,
                      onBackPressed: () => context.pop(),
                      onSearchPressed: () =>
                          setState(() => _isSearching = !_isSearching),
                      onMarkAllReadPressed: () async {
                        await context.read<NotificationCubit>().markAllAsRead();
                      },
                    ),
                    Expanded(
                      child: state.status == NotificationLoadingStatus.loading
                          ? NotificationScreenSkeleton(
                              isDark: isDarkMode,
                              showSearchBar: _isSearching,
                              showActionButtons: true,
                              showTabs: true,
                            )
                          : RefreshIndicator(
                              onRefresh: () => context
                                  .read<NotificationCubit>()
                                  .loadNotifications(),
                              color: AppTheme.primaryColor,
                              backgroundColor: isDarkMode
                                  ? AppTheme.darkCardColor
                                  : Colors.white,
                              child: CustomScrollView(
                                controller: _scrollController,
                                physics: const AlwaysScrollableScrollPhysics(),
                                slivers: [
                                  if (_isSearching)
                                    SliverToBoxAdapter(
                                      child: InstructorNotificationsSearchBar(
                                        controller: _searchController,
                                        isDarkMode: isDarkMode,
                                        onChanged: (_) => setState(() {}),
                                      ),
                                    ),
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        top: 8,
                                        bottom: 16,
                                      ),
                                      child: InstructorNotificationFilterChips(
                                        selectedCategory: _selectedCategory,
                                        onCategoryChanged: (category) {
                                          setState(
                                            () => _selectedCategory = category,
                                          );
                                        },
                                        isDarkMode: isDarkMode,
                                      ),
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 8,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: state.notifications.any(
                                                (n) => n.isRead,
                                              )
                                                  ? () => context
                                                      .read<NotificationCubit>()
                                                      .clearReadNotifications()
                                                  : null,
                                              icon: const Icon(
                                                Icons.cleaning_services_outlined,
                                              ),
                                              label: const Text('Clear read'),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed:
                                                  state.notifications.isNotEmpty
                                                  ? () => context
                                                        .read<
                                                          NotificationCubit
                                                        >()
                                                        .markAllAsRead()
                                                  : null,
                                              icon: const Icon(Icons.done_all),
                                              label: const Text(
                                                'Mark all read',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    child: InstructorNotificationsTabBar(
                                      controller: _tabController,
                                      isDarkMode: isDarkMode,
                                      allLabel: l10n.all,
                                      unreadLabel: l10n.unread,
                                      readLabel: l10n.read,
                                    ),
                                  ),
                                  SliverFillRemaining(
                                    child: TabBarView(
                                      controller: _tabController,
                                      children: [
                                        _buildNotificationsList(
                                          0,
                                          isDarkMode,
                                          l10n,
                                          state,
                                        ),
                                        _buildNotificationsList(
                                          1,
                                          isDarkMode,
                                          l10n,
                                          state,
                                        ),
                                        _buildNotificationsList(
                                          2,
                                          isDarkMode,
                                          l10n,
                                          state,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNotificationsList(
    int tabIndex,
    bool isDarkMode,
    AppLocalizations l10n,
    NotificationState state,
  ) {
    final notifications = _getFilteredNotifications(state, tabIndex);

    if (notifications.isEmpty) {
      return InstructorNotificationsEmptyState(
        tabIndex: tabIndex,
        isDarkMode: isDarkMode,
        allTitle: l10n.noNotifications,
        allSubtitle: l10n.noNotificationsDesc,
        unreadTitle: l10n.noUnreadNotifications,
        unreadSubtitle: l10n.noUnreadNotificationsDesc,
        readTitle: l10n.noReadNotifications,
        readSubtitle: l10n.noReadNotificationsDesc,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, bottom: 100),
      physics: const BouncingScrollPhysics(),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        final baseNotification = state.notifications.firstWhere(
          (item) => item.id == notification.id,
        );
        return InstructorNotificationTile(
          notification: notification,
          isDarkMode: isDarkMode,
          onTap: () => _openNotification(baseNotification, l10n),
          onDelete: () => context
              .read<NotificationCubit>()
              .deleteNotification(notification.id),
          onMarkRead: () => context
              .read<NotificationCubit>()
              .markAsRead(notification.id),
        );
      },
    );
  }
}
