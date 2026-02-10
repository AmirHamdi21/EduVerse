import 'package:edu_verse/models/instructor/instrucor_notification_model.dart';
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
  InstructorNotificationCategory _selectedCategory =
      InstructorNotificationCategory.all;

  // Mock data
  List<InstructorNotificationModel> _notifications = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);
    _loadMockData();
  }

  void _loadMockData() {
    final now = DateTime.now();
    _notifications = [
      InstructorNotificationModel(
        id: '1',
        title: 'New Assignment Submission',
        message:
            'Ahmed Hassan submitted Assignment 3 for CS201 - Data Structures',
        type: InstructorNotificationType.submission,
        timestamp: now.subtract(const Duration(minutes: 5)),
        studentName: 'Ahmed Hassan',
        courseName: 'CS201',
      ),
      InstructorNotificationModel(
        id: '2',
        title: 'Grading Reminder',
        message: 'You have 12 pending submissions to grade for CS301',
        type: InstructorNotificationType.grading,
        timestamp: now.subtract(const Duration(hours: 1)),
        courseName: 'CS301',
      ),
      InstructorNotificationModel(
        id: '3',
        title: 'New Message',
        message: 'Sara Ali sent you a message about the midterm exam',
        type: InstructorNotificationType.message,
        timestamp: now.subtract(const Duration(hours: 2)),
        studentName: 'Sara Ali',
        isRead: true,
      ),
      InstructorNotificationModel(
        id: '4',
        title: 'Assignment Deadline Tomorrow',
        message: 'Assignment 4 deadline for CS201 is tomorrow at 11:59 PM',
        type: InstructorNotificationType.deadline,
        timestamp: now.subtract(const Duration(hours: 5)),
        courseName: 'CS201',
      ),
      InstructorNotificationModel(
        id: '5',
        title: 'Low Attendance Alert',
        message: '5 students have attendance below 75% in CS401',
        type: InstructorNotificationType.attendance,
        timestamp: now.subtract(const Duration(days: 1)),
        courseName: 'CS401',
        isRead: true,
      ),
      InstructorNotificationModel(
        id: '6',
        title: 'System Update',
        message: 'New grading features are now available in the platform',
        type: InstructorNotificationType.system,
        timestamp: now.subtract(const Duration(days: 2)),
        isRead: true,
      ),
      InstructorNotificationModel(
        id: '7',
        title: 'Late Submission',
        message: 'Omar Khaled submitted Assignment 2 late (2 days)',
        type: InstructorNotificationType.submission,
        timestamp: now.subtract(const Duration(days: 1)),
        studentName: 'Omar Khaled',
        courseName: 'CS201',
      ),
    ];
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
  }

  void _deleteNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notification deleted'),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            // Undo would restore the notification
          },
        ),
      ),
    );
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
    });
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
                    onRefresh: () async {
                      await Future.delayed(const Duration(seconds: 1));
                      _loadMockData();
                      setState(() {});
                    },
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
