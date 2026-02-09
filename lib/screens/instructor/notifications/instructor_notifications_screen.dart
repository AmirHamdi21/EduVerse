import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../config/app_theme.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/instructor/notifications/instructor_notification_filter_chips.dart';
import '../../../widgets/instructor/notifications/instructor_notification_tile.dart';

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
        message: 'Ahmed Hassan submitted Assignment 3 for CS201 - Data Structures',
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
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
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
          backgroundColor:
              isDarkMode ? AppTheme.darkSurfaceColor : const Color(0xFFF8FAFC),
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, isDarkMode, l10n),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await Future.delayed(const Duration(seconds: 1));
                      _loadMockData();
                      setState(() {});
                    },
                    color: AppTheme.primaryColor,
                    backgroundColor:
                        isDarkMode ? AppTheme.darkCardColor : Colors.white,
                    child: CustomScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        if (_isSearching)
                          SliverToBoxAdapter(
                            child: _buildSearchBar(context, isDarkMode, l10n),
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
                          child: _buildTabBar(isDarkMode),
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

  Widget _buildHeader(
      BuildContext context, bool isDarkMode, AppLocalizations l10n) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkSurfaceColor : const Color(0xFFF8FAFC),
        boxShadow: _showElevation
            ? [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.15),
                  ),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: isDarkMode
                      ? AppTheme.darkTextPrimary
                      : AppTheme.textDark,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.notifications,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode
                          ? AppTheme.darkTextPrimary
                          : AppTheme.textDark,
                    ),
                  ),
                  if (unreadCount > 0)
                    Text(
                      '$unreadCount unread',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDarkMode
                            ? AppTheme.darkTextSecondary
                            : AppTheme.textLight,
                      ),
                    ),
                ],
              ),
            ),
            _buildHeaderAction(
              icon: Icons.search_rounded,
              isDarkMode: isDarkMode,
              onTap: () => setState(() => _isSearching = !_isSearching),
              isActive: _isSearching,
            ),
            const SizedBox(width: 8),
            _buildHeaderAction(
              icon: Icons.done_all_rounded,
              isDarkMode: isDarkMode,
              onTap: _markAllAsRead,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderAction({
    required IconData icon,
    required bool isDarkMode,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primaryColor.withValues(alpha: 0.15)
              : (isDarkMode
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? AppTheme.primaryColor.withValues(alpha: 0.3)
                : (isDarkMode
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.15)),
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isActive
              ? AppTheme.primaryColor
              : (isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textDark),
        ),
      ),
    );
  }

  Widget _buildSearchBar(
      BuildContext context, bool isDarkMode, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() {}),
        style: TextStyle(
          color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textDark,
        ),
        decoration: InputDecoration(
          hintText: 'Search notifications...',
          hintStyle: TextStyle(
            color: isDarkMode ? AppTheme.darkTextSecondary : AppTheme.textLight,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDarkMode ? AppTheme.darkTextSecondary : AppTheme.textLight,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor:
              isDarkMode ? AppTheme.darkCardColor : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                BorderSide(color: AppTheme.primaryColor, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildTabBar(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.withValues(alpha: 0.15),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor:
            isDarkMode ? AppTheme.darkTextSecondary : AppTheme.textLight,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        padding: const EdgeInsets.all(4),
        tabs: [
          Tab(text: AppLocalizations.of(context).all),
          Tab(text: AppLocalizations.of(context).unread),
          Tab(text: AppLocalizations.of(context).read),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(
      int tabIndex, bool isDarkMode, AppLocalizations l10n) {
    final notifications = _getFilteredNotifications(tabIndex);

    if (notifications.isEmpty) {
      return _buildEmptyState(tabIndex, isDarkMode, l10n);
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

  Widget _buildEmptyState(int tabIndex, bool isDarkMode, AppLocalizations l10n) {
    String title;
    String subtitle;
    IconData icon;

    switch (tabIndex) {
      case 1:
        title = l10n.noUnreadNotifications;
        subtitle = l10n.noUnreadNotificationsDesc;
        icon = Icons.mark_email_read_rounded;
        break;
      case 2:
        title = l10n.noReadNotifications;
        subtitle = l10n.noReadNotificationsDesc;
        icon = Icons.inbox_rounded;
        break;
      default:
        title = l10n.noNotifications;
        subtitle = l10n.noNotificationsDesc;
        icon = Icons.notifications_off_rounded;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppTheme.darkCardColor
                    : Colors.grey.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: isDarkMode
                    ? AppTheme.darkTextSecondary
                    : AppTheme.textLight,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDarkMode
                    ? AppTheme.darkTextPrimary
                    : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode
                    ? AppTheme.darkTextSecondary
                    : AppTheme.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
