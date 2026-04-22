import 'package:edu_verse/models/instructor/instrucor_notification_model.dart';
import 'package:edu_verse/models/notifications/api_notification_model.dart';
import 'package:edu_verse/services/api/notification_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../config/app_theme.dart';
import '../../../generated_l10n/app_localizations.dart';
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
  bool _isLoading = true;
  InstructorNotificationCategory _selectedCategory =
      InstructorNotificationCategory.all;

  List<InstructorNotificationModel> _notifications = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);
    _loadNotificationsFromApi();
  }

  /// Load notifications from the real backend API.
  Future<void> _loadNotificationsFromApi() async {
    setState(() => _isLoading = true);

    try {
      final service = context.read<NotificationApiService>();
      final result = await service.getAll(limit: 100);

      if (result.isSuccess && result.data != null) {
        final apiNotifications = result.data!
            .map((json) => ApiNotificationModel.fromJson(json))
            .map((api) => api.toInstructorNotification())
            .toList();

        if (mounted) {
          setState(() {
            _notifications = apiNotifications;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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

  List<InstructorNotificationModel> _getFilteredNotifications(int tabIndex) {
    var filtered = _notifications;

    // Filter by tab (All, Unread, Read)
    if (tabIndex == 1) {
      filtered = filtered.where((n) => !n.isRead).toList();
    } else if (tabIndex == 2) {
      filtered = filtered.where((n) => n.isRead).toList();
    }

    // Filter by category
    if (_selectedCategory != InstructorNotificationCategory.all) {
      filtered = filtered.where((n) {
        switch (_selectedCategory) {
          case InstructorNotificationCategory.submissions:
            return n.type == InstructorNotificationType.submission;
          case InstructorNotificationCategory.grading:
            return n.type == InstructorNotificationType.grading;
          case InstructorNotificationCategory.messages:
            return n.type == InstructorNotificationType.message;
          case InstructorNotificationCategory.deadlines:
            return n.type == InstructorNotificationType.deadline;
          case InstructorNotificationCategory.system:
            return n.type == InstructorNotificationType.system ||
                n.type == InstructorNotificationType.attendance ||
                n.type == InstructorNotificationType.announcement;
          default:
            return true;
        }
      }).toList();
    }

    // Filter by search
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((n) {
        return n.title.toLowerCase().contains(query) ||
            n.message.toLowerCase().contains(query) ||
            (n.studentName?.toLowerCase().contains(query) ?? false) ||
            (n.courseName?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return filtered;
  }

  void _markAsRead(String id) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
      }
    });

    // Fire-and-forget API call
    try {
      context.read<NotificationApiService>().markAsRead(id);
    } catch (_) {}
  }

  void _deleteNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });

    // Fire-and-forget API call
    try {
      context.read<NotificationApiService>().deleteNotification(id);
    } catch (_) {}

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notification deleted'),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
    });

    // Fire-and-forget API call
    try {
      context.read<NotificationApiService>().markAllAsRead();
    } catch (_) {}

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('All notifications marked as read'),
        backgroundColor: const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDark;
        final l10n = AppLocalizations.of(context);

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
                  unreadCount: _notifications.where((n) => !n.isRead).length,
                  title: l10n.notifications,
                  isSearching: _isSearching,
                  onBackPressed: () => context.pop(),
                  onSearchPressed: () =>
                      setState(() => _isSearching = !_isSearching),
                  onMarkAllReadPressed: _markAllAsRead,
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadNotificationsFromApi,
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
                              onChanged: (value) => setState(() {}),
                            ),
                          ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 16),
                            child: InstructorNotificationFilterChips(
                              selectedCategory: _selectedCategory,
                              onCategoryChanged: (category) {
                                setState(() => _selectedCategory = category);
                              },
                              isDarkMode: isDarkMode,
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
                        if (_isLoading)
                          const SliverFillRemaining(
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else
                          SliverFillRemaining(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildNotificationsList(0, isDarkMode, l10n),
                                _buildNotificationsList(1, isDarkMode, l10n),
                                _buildNotificationsList(2, isDarkMode, l10n),
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
  }

  Widget _buildNotificationsList(
    int tabIndex,
    bool isDarkMode,
    AppLocalizations l10n,
  ) {
    final notifications = _getFilteredNotifications(tabIndex);

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
        return InstructorNotificationTile(
          notification: notification,
          isDarkMode: isDarkMode,
          onTap: () => _markAsRead(notification.id),
          onDelete: () => _deleteNotification(notification.id),
          onMarkRead: () => _markAsRead(notification.id),
        );
      },
    );
  }
}
