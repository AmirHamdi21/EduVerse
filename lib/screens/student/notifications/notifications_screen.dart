import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/notifications/notification_cubit.dart';
import '../../../bloc/notifications/notification_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../config/app_theme.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/notifications/notification_model.dart';
import '../../../widgets/student/notifications/ai_insight_card.dart';
import '../../../widgets/student/notifications/notification_filter_chips.dart';
import '../../../widgets/student/notifications/notification_tile.dart';
import '../../../widgets/student/notifications/system_alert_card.dart';
import 'notification_swipe_settings_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showElevation = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);
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

  @override
  Widget build(BuildContext context) {
    // Use the global NotificationCubit instead of creating a new one
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
                // Header
                _buildHeader(context, isDarkMode, l10n),
                // Content
                Expanded(
                  child: BlocBuilder<NotificationCubit, NotificationState>(
                    builder: (context, state) {
                      if (state.status == NotificationLoadingStatus.loading) {
                        return _buildLoadingState(isDarkMode);
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          await context
                              .read<NotificationCubit>()
                              .loadNotifications();
                        },
                        color: AppTheme.primaryColor,
                        backgroundColor: isDarkMode
                            ? AppTheme.darkCardColor
                            : Colors.white,
                        child: CustomScrollView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            // Search bar
                            if (state.isSearching)
                              SliverToBoxAdapter(
                                child: _buildSearchBar(
                                  context,
                                  isDarkMode,
                                  l10n,
                                  state,
                                ),
                              ),
                            // Filter chips
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: NotificationFilterChips(
                                  selectedCategory: state.selectedCategory,
                                  onCategoryChanged: (category) {
                                    context
                                        .read<NotificationCubit>()
                                        .setCategory(category);
                                  },
                                  isDarkMode: isDarkMode,
                                ),
                              ),
                            ),

                            // Notifications section header
                            SliverToBoxAdapter(
                              child: _buildNotificationHeader(
                                context,
                                isDarkMode,
                                l10n,
                                state,
                              ),
                            ),
                            // Notification list or empty state
                            if (state.filteredNotifications.isEmpty)
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: _buildEmptyState(
                                  context,
                                  isDarkMode,
                                  l10n,
                                  state,
                                ),
                              )
                            else
                              _buildNotificationsList(
                                context,
                                isDarkMode,
                                l10n,
                                state,
                              ),
                            // AI Insights Section (collapsed by default)
                            if (state.activeAIInsights.isNotEmpty)
                              SliverToBoxAdapter(
                                child: _buildAIInsightsSection(
                                  context,
                                  isDarkMode,
                                  l10n,
                                  state,
                                ),
                              ),
                            // System Alerts Section (collapsed by default)
                            if (state.activeSystemAlerts.isNotEmpty)
                              SliverToBoxAdapter(
                                child: _buildSystemAlertsSection(
                                  context,
                                  isDarkMode,
                                  l10n,
                                  state,
                                ),
                              ),
                            // Bottom padding
                            const SliverPadding(
                              padding: EdgeInsets.only(bottom: 20),
                            ),
                          ],
                        ),
                      );
                    },
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
    BuildContext context,
    bool isDarkMode,
    AppLocalizations l10n,
  ) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isDarkMode ? AppTheme.darkSurfaceColor : Colors.white,
            boxShadow: _showElevation
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    // Back button
                    _buildIconButton(
                      icon: Icons.arrow_back_ios_new,
                      onTap: () => Navigator.of(context).pop(),
                      isDarkMode: isDarkMode,
                    ),
                    const SizedBox(width: 12),
                    // Title and subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                l10n.notificationsTitle,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? AppTheme.darkTextPrimary
                                      : AppTheme.textDark,
                                ),
                              ),
                              if (state.unreadCount > 0) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.errorColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${state.unreadCount}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.notificationSubtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode
                                  ? AppTheme.darkTextSecondary
                                  : AppTheme.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Search button
                    _buildIconButton(
                      icon: state.isSearching ? Icons.close : Icons.search,
                      onTap: () {
                        context.read<NotificationCubit>().toggleSearchMode();
                        if (!state.isSearching) {
                          _searchController.clear();
                        }
                      },
                      isDarkMode: isDarkMode,
                    ),
                    const SizedBox(width: 8),
                    // More menu
                    _buildMoreMenu(context, isDarkMode, l10n, state),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDarkMode,
    Color? color,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 20,
          color:
              color ??
              (isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textDark),
        ),
      ),
    );
  }

  Widget _buildMoreMenu(
    BuildContext context,
    bool isDarkMode,
    AppLocalizations l10n,
    NotificationState state,
  ) {
    return PopupMenuButton<String>(
      icon: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.more_vert,
          size: 20,
          color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textDark,
        ),
      ),
      color: isDarkMode ? AppTheme.darkCardColor : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      onSelected: (value) =>
          _handleMenuAction(context, value, isDarkMode, l10n),
      itemBuilder: (context) => [
        _buildMenuItem(
          icon: Icons.swipe,
          label: l10n.swipeActions,
          value: 'swipe_settings',
          isDarkMode: isDarkMode,
        ),
        const PopupMenuDivider(),
        _buildMenuItem(
          icon: Icons.done_all,
          label: l10n.notificationMarkAllRead,
          value: 'mark_all_read',
          isDarkMode: isDarkMode,
          enabled: state.unreadCount > 0,
        ),
        _buildMenuItem(
          icon: Icons.cleaning_services_outlined,
          label: l10n.notificationClearRead,
          value: 'clear_read',
          isDarkMode: isDarkMode,
          enabled: state.notifications.any((n) => n.isRead),
        ),
        const PopupMenuDivider(),
        _buildMenuItem(
          icon: Icons.delete_sweep_outlined,
          label: l10n.notificationClearAll,
          value: 'clear_all',
          isDarkMode: isDarkMode,
          enabled: state.notifications.isNotEmpty,
          isDestructive: true,
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isDarkMode,
    bool enabled = true,
    bool isDestructive = false,
  }) {
    final color = !enabled
        ? Colors.grey
        : isDestructive
        ? AppTheme.errorColor
        : (isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textDark);

    return PopupMenuItem(
      value: value,
      enabled: enabled,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: color, fontSize: 14)),
        ],
      ),
    );
  }

  void _handleMenuAction(
    BuildContext context,
    String value,
    bool isDarkMode,
    AppLocalizations l10n,
  ) {
    switch (value) {
      case 'swipe_settings':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const NotificationSwipeSettingsScreen(),
          ),
        ).then((_) {
          // Force rebuild to reload swipe settings
          if (mounted) setState(() {});
        });
        break;
      case 'mark_all_read':
        context.read<NotificationCubit>().markAllAsRead();
        _showSnackBar(context, l10n.notificationMarkedAllRead, isDarkMode);
        break;
      case 'clear_read':
        _showClearDialog(
          context: context,
          title: l10n.notificationClearRead,
          message: l10n.notificationClearReadConfirm,
          onConfirm: () {
            context.read<NotificationCubit>().clearReadNotifications();
            _showSnackBar(context, l10n.notificationReadCleared, isDarkMode);
          },
          isDarkMode: isDarkMode,
          l10n: l10n,
        );
        break;
      case 'clear_all':
        _showClearDialog(
          context: context,
          title: l10n.notificationClearAll,
          message: l10n.notificationClearAllConfirm,
          onConfirm: () {
            context.read<NotificationCubit>().clearAllNotifications();
            _showSnackBar(context, l10n.notificationAllCleared, isDarkMode);
          },
          isDarkMode: isDarkMode,
          l10n: l10n,
          isDestructive: true,
        );
        break;
    }
  }

  Widget _buildSearchBar(
    BuildContext context,
    bool isDarkMode,
    AppLocalizations l10n,
    NotificationState state,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          context.read<NotificationCubit>().setSearchQuery(value);
        },
        style: TextStyle(
          color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textDark,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: l10n.notificationSearchHint,
          hintStyle: TextStyle(
            color: isDarkMode ? AppTheme.darkTextSecondary : AppTheme.textLight,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDarkMode ? AppTheme.darkTextSecondary : AppTheme.textLight,
            size: 20,
          ),
          suffixIcon: state.searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    context.read<NotificationCubit>().setSearchQuery('');
                  },
                  child: Icon(
                    Icons.clear,
                    color: isDarkMode
                        ? AppTheme.darkTextSecondary
                        : AppTheme.textLight,
                    size: 20,
                  ),
                )
              : null,
          filled: true,
          fillColor: isDarkMode
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.grey.withValues(alpha: 0.08),
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

  Widget _buildAIInsightsSection(
    BuildContext context,
    bool isDarkMode,
    AppLocalizations l10n,
    NotificationState state,
  ) {
    return _CollapsibleSection(
      title: l10n.notificationSmartAIInsights,
      icon: Icons.auto_awesome,
      iconColor: const Color(0xFFFF6B35),
      isDarkMode: isDarkMode,
      initiallyExpanded: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: state.activeAIInsights.map((insight) {
            return AIInsightCard(
              insight: insight,
              isDarkMode: isDarkMode,
              onAction: () {
                // Handle action
              },
              onDismiss: () {
                context.read<NotificationCubit>().dismissAIInsight(insight.id);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSystemAlertsSection(
    BuildContext context,
    bool isDarkMode,
    AppLocalizations l10n,
    NotificationState state,
  ) {
    return _CollapsibleSection(
      title: l10n.notificationSystemAlerts,
      icon: Icons.info_outline,
      iconColor: AppTheme.primaryColor,
      isDarkMode: isDarkMode,
      initiallyExpanded: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: state.activeSystemAlerts.map((alert) {
            return SystemAlertCard(
              alert: alert,
              isDarkMode: isDarkMode,
              onDismiss: () {
                context.read<NotificationCubit>().dismissSystemAlert(alert.id);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNotificationHeader(
    BuildContext context,
    bool isDarkMode,
    AppLocalizations l10n,
    NotificationState state,
  ) {
    final count = state.filteredNotifications.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Text(
            l10n.notificationRecentNotifications,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textDark,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count ${l10n.notificationItems}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDarkMode
                    ? AppTheme.darkTextSecondary
                    : AppTheme.textLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(
    BuildContext context,
    bool isDarkMode,
    AppLocalizations l10n,
    NotificationState state,
  ) {
    final todayNotifications = state.todayNotifications;
    final thisWeekNotifications = state.thisWeekNotifications;
    final earlierNotifications = state.earlierNotifications;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // Today
          if (todayNotifications.isNotEmpty) ...[
            _buildSectionLabel(l10n.notificationToday, isDarkMode),
            ...todayNotifications.map(
              (n) => _buildNotificationItem(context, n, isDarkMode, l10n),
            ),
          ],
          // This Week
          if (thisWeekNotifications.isNotEmpty) ...[
            _buildSectionLabel(l10n.notificationThisWeek, isDarkMode),
            ...thisWeekNotifications.map(
              (n) => _buildNotificationItem(context, n, isDarkMode, l10n),
            ),
          ],
          // Earlier
          if (earlierNotifications.isNotEmpty) ...[
            _buildSectionLabel(l10n.notificationEarlier, isDarkMode),
            ...earlierNotifications.map(
              (n) => _buildNotificationItem(context, n, isDarkMode, l10n),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _buildSectionLabel(String label, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDarkMode ? AppTheme.darkTextSecondary : AppTheme.textLight,
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    NotificationModel n,
    bool isDarkMode,
    AppLocalizations l10n,
  ) {
    return NotificationTile(
      notification: n,
      isDarkMode: isDarkMode,
      onTap: () {
        context.read<NotificationCubit>().markAsRead(n.id);
        // Handle navigation based on notification type
      },
      onBookmark: () {
        context.read<NotificationCubit>().toggleBookmark(n.id);
      },
      onDelete: () {
        context.read<NotificationCubit>().deleteNotification(n.id);
        _showSnackBar(context, l10n.notificationDeleted, isDarkMode);
      },
      onMarkRead: () {
        if (n.isRead) {
          context.read<NotificationCubit>().markAsUnread(n.id);
          _showSnackBar(context, l10n.notificationMarkedUnread, isDarkMode);
        } else {
          context.read<NotificationCubit>().markAsRead(n.id);
          _showSnackBar(context, l10n.notificationMarkedRead, isDarkMode);
        }
      },
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    bool isDarkMode,
    AppLocalizations l10n,
    NotificationState state,
  ) {
    final isFiltered =
        state.selectedCategory != NotificationCategory.all ||
        state.searchQuery.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.2),
                    AppTheme.accentColor.withValues(alpha: 0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFiltered
                    ? Icons.filter_list_off
                    : Icons.notifications_off_outlined,
                size: 36,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isFiltered
                  ? l10n.notificationNoFiltered
                  : l10n.notificationNoNotifications,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: isDarkMode
                    ? AppTheme.darkTextPrimary
                    : AppTheme.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? l10n.notificationNoFilteredDesc
                  : l10n.notificationNoNotificationsDesc,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode
                    ? AppTheme.darkTextSecondary
                    : AppTheme.textLight,
              ),
              textAlign: TextAlign.center,
            ),
            if (isFiltered) ...[
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  context.read<NotificationCubit>().setCategory(
                    NotificationCategory.all,
                  );
                  context.read<NotificationCubit>().setSearchQuery('');
                  _searchController.clear();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppTheme.buttonGradient,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    l10n.notificationClearFilters,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading notifications...',
            style: TextStyle(
              color: isDarkMode
                  ? AppTheme.darkTextSecondary
                  : AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, bool isDarkMode) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDarkMode
            ? AppTheme.darkCardColor
            : AppTheme.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showClearDialog({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
    required bool isDarkMode,
    required AppLocalizations l10n,
    bool isDestructive = false,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDarkMode ? AppTheme.darkCardColor : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: TextStyle(
            color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            color: isDarkMode ? AppTheme.darkTextSecondary : AppTheme.textLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color: isDarkMode
                    ? AppTheme.darkTextSecondary
                    : AppTheme.textLight,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onConfirm();
            },
            child: Text(
              l10n.notificationConfirm,
              style: TextStyle(
                color: isDestructive
                    ? AppTheme.errorColor
                    : AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Collapsible section widget for AI Insights and System Alerts
class _CollapsibleSection extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final bool isDarkMode;
  final bool initiallyExpanded;
  final Widget child;

  const _CollapsibleSection({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.isDarkMode,
    required this.initiallyExpanded,
    required this.child,
  });

  @override
  State<_CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<_CollapsibleSection>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _heightFactor = _controller.drive(CurveTween(curve: Curves.easeInOut));
    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    HapticFeedback.lightImpact();
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        GestureDetector(
          onTap: _toggleExpanded,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: widget.iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(widget.icon, color: widget.iconColor, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: widget.isDarkMode
                          ? AppTheme.darkTextPrimary
                          : AppTheme.textDark,
                    ),
                  ),
                ),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: _isExpanded ? 0.5 : 0,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: widget.isDarkMode
                        ? AppTheme.darkTextSecondary
                        : AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Content
        ClipRect(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Align(heightFactor: _heightFactor.value, child: child);
            },
            child: widget.child,
          ),
        ),
      ],
    );
  }
}
