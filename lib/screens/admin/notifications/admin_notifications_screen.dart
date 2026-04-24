import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/admin_notifications/admin_notification_cubit.dart';
import '../../../bloc/admin_notifications/admin_notification_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/admin/admin_notification_model.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../widgets/admin/notifications/admin_notifications_barrel.dart';
import 'admin_notification_swipe_settings_screen.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      context.read<AdminNotificationCubit>().setCurrentTab(
        _tabController.index,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminNotificationCubit(),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final isDark = themeState.isDark;
          final l10n = AppLocalizations.of(context);

          return Scaffold(
            backgroundColor: AdminColors.getBackgroundColor(isDark),
            body: SafeArea(
              child: Container(
                decoration: isDark
                    ? null
                    : BoxDecoration(
                        gradient: AdminColors.lightBackgroundGradient,
                      ),
                child:
                    BlocBuilder<AdminNotificationCubit, AdminNotificationState>(
                      builder: (context, state) {
                        return Column(
                          children: [
                            _buildAppBar(context, isDark, l10n, state),
                            _buildTabBar(isDark, l10n),
                            if (state.isSearching)
                              _buildSearchBar(context, isDark, l10n, state),
                            _buildStatsCard(isDark, state),
                            Expanded(
                              child: _buildContent(
                                context,
                                isDark,
                                l10n,
                                state,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
              ),
            ),
            floatingActionButton: _buildFAB(context, isDark),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    AdminNotificationState state,
  ) {
    return AdminNotificationAppBar(
      title: l10n.adminNotificationsTitle,
      subtitle: l10n.adminNotificationsSubtitle,
      unreadCount: state.unreadCount,
      isDark: isDark,
      isSearching: state.isSearching,
      onBack: () => Navigator.of(context).pop(),
      onSearch: () {
        context.read<AdminNotificationCubit>().toggleSearchMode();
        if (state.isSearching) {
          _searchController.clear();
        }
      },
      onSwipeSettings: () {
        Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (_) => const AdminNotificationSwipeSettingsScreen(),
              ),
            )
            .then((_) {
              if (mounted) setState(() {});
            });
      },
      onMarkAllRead: () {
        context.read<AdminNotificationCubit>().markAllAsRead();
        _showSnackBar(context, l10n.adminNotificationMarkedAllRead, isDark);
      },
      onClearAll: () {
        _showClearAllDialog(context, isDark, l10n);
      },
    );
  }

  Widget _buildTabBar(bool isDark, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AdminColors.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AdminColors.getTextSecondaryColor(isDark),
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.notifications_rounded, size: 16),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    l10n.adminNotificationsTab,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.campaign_rounded, size: 16),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    l10n.adminAnnouncementsTab,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.archive_rounded, size: 16),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    l10n.adminArchivedTab,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    AdminNotificationState state,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          context.read<AdminNotificationCubit>().setSearchQuery(value);
        },
        style: TextStyle(color: AdminColors.getTextColor(isDark), fontSize: 14),
        decoration: InputDecoration(
          hintText: l10n.adminNotificationSearchHint,
          hintStyle: TextStyle(
            color: AdminColors.getTextTertiaryColor(isDark),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AdminColors.getTextTertiaryColor(isDark),
            size: 20,
          ),
          suffixIcon: state.searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    context.read<AdminNotificationCubit>().setSearchQuery('');
                  },
                  child: Icon(
                    Icons.clear_rounded,
                    color: AdminColors.getTextTertiaryColor(isDark),
                    size: 20,
                  ),
                )
              : null,
          filled: true,
          fillColor: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.grey.withOpacity(0.08),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(bool isDark, AdminNotificationState state) {
    return AdminNotificationStatsCard(
      totalNotifications: state.notifications.length,
      unreadCount: state.unreadCount,
      pendingActions: state.pendingActionsCount,
      announcementsCount: state.announcementsCount,
      isDark: isDark,
    );
  }

  Widget _buildContent(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    AdminNotificationState state,
  ) {
    if (state.status == AdminNotificationLoadingStatus.loading) {
      return _buildLoadingState(isDark);
    }

    if (state.status == AdminNotificationLoadingStatus.error) {
      return _buildErrorState(context, isDark, l10n, state.errorMessage);
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildNotificationsTab(context, isDark, l10n, state),
        _buildAnnouncementsTab(context, isDark, l10n, state),
        _buildArchivedTab(context, isDark, l10n, state),
      ],
    );
  }

  Widget _buildNotificationsTab(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    AdminNotificationState state,
  ) {
    return Column(
      children: [
        AdminNotificationFilterChips(
          selectedCategory: state.selectedCategory,
          onCategoryChanged: (category) {
            context.read<AdminNotificationCubit>().setCategory(category);
          },
          isDark: isDark,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: state.filteredNotifications.isEmpty
              ? AdminNotificationEmptyState(
                  title: l10n.adminNoNotifications,
                  message: l10n.adminNoNotificationsMessage,
                  icon: Icons.notifications_off_rounded,
                  isDark: isDark,
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await context
                        .read<AdminNotificationCubit>()
                        .loadNotifications();
                  },
                  color: AdminColors.primary,
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: state.filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final notification = state.filteredNotifications[index];
                      return AdminNotificationTile(
                        notification: notification,
                        isDark: isDark,
                        onTap: () => _handleNotificationTap(
                          context,
                          notification,
                          isDark,
                          l10n,
                        ),
                        onBookmark: () {
                          context.read<AdminNotificationCubit>().toggleBookmark(
                            notification.id,
                          );
                        },
                        onDelete: () {
                          context
                              .read<AdminNotificationCubit>()
                              .deleteNotification(notification.id);
                          _showSnackBar(
                            context,
                            l10n.adminNotificationDeleted,
                            isDark,
                          );
                        },
                        onMarkRead: () {
                          if (notification.isRead) {
                            context.read<AdminNotificationCubit>().markAsUnread(
                              notification.id,
                            );
                          } else {
                            context.read<AdminNotificationCubit>().markAsRead(
                              notification.id,
                            );
                          }
                        },
                        onArchive: () {
                          context
                              .read<AdminNotificationCubit>()
                              .archiveNotification(notification.id);
                          _showSnackBar(
                            context,
                            l10n.adminNotificationArchived,
                            isDark,
                          );
                        },
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildAnnouncementsTab(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    AdminNotificationState state,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AdminColors.getCardColor(isDark),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.06),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.campaign_rounded,
                size: 46,
                color: AdminColors.primary,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.adminAnnouncementsTab,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AdminColors.getTextColor(isDark),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Open the dedicated announcements manager to create, publish, and manage announcements with live backend data.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: AdminColors.getTextSecondaryColor(isDark),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => context.push('/admin/announcements'),
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: const Text('Open Announcement Manager'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArchivedTab(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    AdminNotificationState state,
  ) {
    if (state.archivedNotifications.isEmpty) {
      return AdminNotificationEmptyState(
        title: l10n.adminNoArchivedNotifications,
        message: l10n.adminNoArchivedNotificationsMessage,
        icon: Icons.archive_outlined,
        isDark: isDark,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<AdminNotificationCubit>().loadNotifications();
      },
      color: AdminColors.primary,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: state.archivedNotifications.length,
        itemBuilder: (context, index) {
          final notification = state.archivedNotifications[index];
          return AdminNotificationTile(
            notification: notification,
            isDark: isDark,
            onTap: () =>
                _handleNotificationTap(context, notification, isDark, l10n),
            onDelete: () {
              context.read<AdminNotificationCubit>().deleteNotification(
                notification.id,
              );
              _showSnackBar(context, l10n.adminNotificationDeleted, isDark);
            },
            onArchive: () {
              context.read<AdminNotificationCubit>().unarchiveNotification(
                notification.id,
              );
              _showSnackBar(context, l10n.adminNotificationUnarchived, isDark);
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AdminColors.primary, strokeWidth: 3),
          const SizedBox(height: 16),
          Text(
            'Loading notifications...',
            style: TextStyle(
              color: AdminColors.getTextSecondaryColor(isDark),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    String? errorMessage,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AdminColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: AdminColors.error,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.errorOccurred,
              style: TextStyle(
                color: AdminColors.getTextColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'An unexpected error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<AdminNotificationCubit>().loadNotifications();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.tryAgain),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB(BuildContext context, bool isDark) {
    return BlocBuilder<AdminNotificationCubit, AdminNotificationState>(
      builder: (context, state) {
        // Only show FAB on announcements tab
        if (state.currentTab != 1) return const SizedBox();

        return FloatingActionButton.extended(
          onPressed: () => context.push('/admin/announcements'),
          backgroundColor: AdminColors.primary,
          icon: const Icon(Icons.open_in_new_rounded, color: Colors.white),
          label: const Text(
            'Open Manager',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        );
      },
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    AdminNotificationModel notification,
    bool isDark,
    AppLocalizations l10n,
  ) {
    // Mark as read when tapped
    if (!notification.isRead) {
      context.read<AdminNotificationCubit>().markAsRead(notification.id);
    }

    // Show notification details
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          _buildNotificationDetailsSheet(ctx, notification, isDark, l10n),
    );
  }

  Widget _buildNotificationDetailsSheet(
    BuildContext context,
    AdminNotificationModel notification,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AdminColors.getTextTertiaryColor(isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AdminColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.notifications_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.getTextColor(isDark),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(notification.createdAt),
                      style: TextStyle(
                        fontSize: 13,
                        color: AdminColors.getTextTertiaryColor(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            notification.message,
            style: TextStyle(
              fontSize: 15,
              color: AdminColors.getTextSecondaryColor(isDark),
              height: 1.6,
            ),
          ),
          if (notification.userName != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.person_rounded,
                    size: 20,
                    color: AdminColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${notification.userName}${notification.userRole != null ? ' • ${notification.userRole}' : ''}',
                    style: TextStyle(
                      fontSize: 13,
                      color: AdminColors.getTextColor(isDark),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          if (notification.requiresAction)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Handle action based on notification type
                  _showSnackBar(context, 'Action feature coming soon', isDark);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Take Action',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showClearAllDialog(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AdminColors.getCardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.adminClearAllTitle,
          style: TextStyle(color: AdminColors.getTextColor(isDark)),
        ),
        content: Text(
          l10n.adminClearAllMessage,
          style: TextStyle(color: AdminColors.getTextSecondaryColor(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AdminNotificationCubit>().clearAllNotifications();
              _showSnackBar(context, l10n.adminAllNotificationsCleared, isDark);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.adminClearAllButton),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, bool isDark) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: AdminColors.getCardColor(isDark),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
