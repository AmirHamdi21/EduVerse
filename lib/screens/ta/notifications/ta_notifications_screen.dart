import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/ta/shared/ta_colors.dart';
import '../../../widgets/ta/dashboard/ta_drawer.dart';
import '../../../widgets/ta/notifications/ta_notifications_barrel.dart';
import '../../../services/notification_swipe_settings_service.dart';
import '../../../models/notifications/swipe_action_model.dart';

class TANotificationsScreen extends StatefulWidget {
  const TANotificationsScreen({super.key});

  @override
  State<TANotificationsScreen> createState() => _TANotificationsScreenState();
}

class _TANotificationsScreenState extends State<TANotificationsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'all';
  bool _aiRepliesEnabled = true;
  String? _expandedNotificationId;
  bool _isSelectionMode = false;
  final Set<String> _selectedNotifications = {};
  NotificationSwipeSettings _swipeSettings = const NotificationSwipeSettings();

  List<TANotificationItem> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadSwipeSettings();
    _loadNotifications();
  }

  Future<void> _loadSwipeSettings() async {
    final settings = await NotificationSwipeSettingsService.instance
        .getSwipeSettings();
    setState(() => _swipeSettings = settings);
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 600));

    _notifications = _getMockNotifications();

    setState(() => _isLoading = false);
  }

  List<TANotificationItem> _getMockNotifications() {
    return [
      TANotificationItem(
        id: '1',
        title: 'Question in Lab 3 Thread',
        senderName: 'Ahmed Hassan',
        preview: 'Ahmed asked a question about process synchronization.',
        timeAgo: '5 mins ago',
        type: TANotificationType.question,
        badge: 'Lab 3',
        isUnread: true,
        hasThread: true,
        replyCount: 3,
        fullContent:
            'Hi TA, I\'m having trouble understanding the producer-consumer problem. Could you explain how semaphores prevent race conditions in this scenario?',
        relatedTo: 'Lab 3 - Process Synchronization',
      ),
      TANotificationItem(
        id: '2',
        title: 'New Lab Submission',
        senderName: 'Sara Johnson',
        preview: 'Sara submitted her lab assignment.',
        timeAgo: '15 mins ago',
        type: TANotificationType.submission,
        badge: 'Lab 3',
        isUnread: true,
      ),
      TANotificationItem(
        id: '3',
        title: 'Plagiarism Check Request',
        senderName: 'Dr. Michael Chen',
        preview: 'Instructor requested TA to check plagiarism report.',
        timeAgo: '1 hour ago',
        type: TANotificationType.plagiarism,
        badge: 'Assignment 2',
        isUnread: false,
      ),
      TANotificationItem(
        id: '4',
        title: 'Students Needing Support',
        senderName: 'CampusOne AI',
        preview: 'AI identified 2 struggling students in Lab 4.',
        timeAgo: '2 hours ago',
        type: TANotificationType.aiAlert,
        badge: 'Lab 4',
        isUnread: true,
      ),
      TANotificationItem(
        id: '5',
        title: 'System Maintenance',
        senderName: 'CampusOne System',
        preview: 'CampusOne update scheduled for 2 AM tonight.',
        timeAgo: '3 hours ago',
        type: TANotificationType.system,
        badge: 'System',
        isUnread: false,
      ),
      TANotificationItem(
        id: '6',
        title: 'Lab Deadline Extension?',
        senderName: 'Emily Rodriguez',
        preview: 'Emily asked about extending the lab deadline.',
        timeAgo: '5 hours ago',
        type: TANotificationType.deadline,
        badge: 'Lab 3',
        isUnread: false,
        hasThread: true,
        replyCount: 2,
      ),
    ];
  }

  List<TANotificationItem> get _filteredNotifications {
    var filtered = _notifications;

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (n) =>
                n.title.toLowerCase().contains(query) ||
                n.senderName.toLowerCase().contains(query) ||
                n.preview.toLowerCase().contains(query),
          )
          .toList();
    }

    switch (_selectedFilter) {
      case 'students':
        filtered = filtered
            .where(
              (n) =>
                  n.type == TANotificationType.question ||
                  n.type == TANotificationType.submission ||
                  n.type == TANotificationType.deadline,
            )
            .toList();
        break;
      case 'instructors':
        filtered = filtered
            .where(
              (n) =>
                  n.type == TANotificationType.plagiarism ||
                  n.type == TANotificationType.announcement,
            )
            .toList();
        break;
      case 'ai':
        filtered = filtered
            .where((n) => n.type == TANotificationType.aiAlert)
            .toList();
        break;
    }

    return filtered;
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

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedNotifications.clear();
      }
    });
  }

  void _toggleNotificationSelection(String id) {
    setState(() {
      if (_selectedNotifications.contains(id)) {
        _selectedNotifications.remove(id);
      } else {
        _selectedNotifications.add(id);
      }
    });
  }

  void _selectAll() {
    setState(() {
      _selectedNotifications.addAll(_filteredNotifications.map((n) => n.id));
    });
  }

  void _deselectAll() {
    setState(() {
      _selectedNotifications.clear();
    });
  }

  void _deleteSelected() {
    if (_selectedNotifications.isEmpty) return;

    setState(() {
      _notifications.removeWhere((n) => _selectedNotifications.contains(n.id));
      _selectedNotifications.clear();
      _isSelectionMode = false;
    });
    _showSnackBar('Deleted selected notifications');
  }

  void _markSelectedAsRead() {
    if (_selectedNotifications.isEmpty) return;

    setState(() {
      for (var i = 0; i < _notifications.length; i++) {
        if (_selectedNotifications.contains(_notifications[i].id)) {
          _notifications[i] = TANotificationItem(
            id: _notifications[i].id,
            title: _notifications[i].title,
            senderName: _notifications[i].senderName,
            preview: _notifications[i].preview,
            timeAgo: _notifications[i].timeAgo,
            type: _notifications[i].type,
            badge: _notifications[i].badge,
            isUnread: false,
            hasThread: _notifications[i].hasThread,
            replyCount: _notifications[i].replyCount,
            fullContent: _notifications[i].fullContent,
            relatedTo: _notifications[i].relatedTo,
          );
        }
      }
      _selectedNotifications.clear();
      _isSelectionMode = false;
    });
    _showSnackBar('Marked as read');
  }

  void _markAsRead(String id) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        final n = _notifications[index];
        _notifications[index] = TANotificationItem(
          id: n.id,
          title: n.title,
          senderName: n.senderName,
          preview: n.preview,
          timeAgo: n.timeAgo,
          type: n.type,
          badge: n.badge,
          isUnread: !n.isUnread,
          hasThread: n.hasThread,
          replyCount: n.replyCount,
          fullContent: n.fullContent,
          relatedTo: n.relatedTo,
        );
      }
    });
    _showSnackBar('Updated notification');
  }

  void _deleteNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });
    _showSnackBar('Notification deleted');
  }

  void _executeSwipeAction(
    SwipeAction action,
    TANotificationItem notification,
  ) {
    switch (action) {
      case SwipeAction.delete:
        // Handled by onDismissed
        break;
      case SwipeAction.markRead:
        _markAsRead(notification.id);
        break;
      case SwipeAction.markUnread:
        _markAsRead(notification.id);
        break;
      case SwipeAction.archive:
        _archiveNotification(notification.id);
        break;
      case SwipeAction.bookmark:
        _bookmarkNotification(notification.id);
        break;
      case SwipeAction.none:
        break;
    }
  }

  void _archiveNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });
    _showSnackBar('Notification archived');
  }

  void _bookmarkNotification(String id) {
    _showSnackBar('Notification bookmarked');
  }

  Future<bool> _showSwipeActionConfirmation(
    bool isDark,
    AppLocalizations l10n,
    TANotificationItem notification,
    SwipeAction action,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TAColors.cardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          _getSwipeActionTitle(action, l10n),
          style: TextStyle(color: TAColors.textPrimaryColor(isDark)),
        ),
        content: Text(
          _getSwipeActionMessage(action, notification, l10n),
          style: TextStyle(color: TAColors.textSecondaryColor(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.taLabCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: action.color,
              foregroundColor: Colors.white,
            ),
            child: Text(_getSwipeActionButtonText(action, l10n)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  String _getSwipeActionTitle(SwipeAction action, AppLocalizations l10n) {
    switch (action) {
      case SwipeAction.delete:
        return l10n.delete;
      case SwipeAction.archive:
        return l10n.archive;
      default:
        return '';
    }
  }

  String _getSwipeActionMessage(
    SwipeAction action,
    TANotificationItem notification,
    AppLocalizations l10n,
  ) {
    switch (action) {
      case SwipeAction.delete:
        return 'Delete notification from ${notification.senderName}?';
      case SwipeAction.archive:
        return 'Archive notification from ${notification.senderName}?';
      default:
        return '';
    }
  }

  String _getSwipeActionButtonText(SwipeAction action, AppLocalizations l10n) {
    switch (action) {
      case SwipeAction.delete:
        return l10n.delete;
      case SwipeAction.archive:
        return l10n.archive;
      default:
        return l10n.confirm;
    }
  }

  Widget _buildSwipeBackground({
    required SwipeAction action,
    required AlignmentGeometry alignment,
    required TANotificationItem notification,
    required AppLocalizations l10n,
  }) {
    final isLeft = alignment == Alignment.centerLeft;

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
        mainAxisAlignment: isLeft
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: isLeft
            ? [
                Icon(action.icon, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  _getSwipeActionLabel(action, notification, l10n),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ]
            : [
                Text(
                  _getSwipeActionLabel(action, notification, l10n),
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

  String _getSwipeActionLabel(
    SwipeAction action,
    TANotificationItem notification,
    AppLocalizations l10n,
  ) {
    switch (action) {
      case SwipeAction.delete:
        return l10n.delete;
      case SwipeAction.markRead:
        return notification.isUnread ? l10n.markAsRead : l10n.markAsUnread;
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

  void _showBulkActionsSheet(bool isDark, AppLocalizations l10n) {
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
              icon: Icons.select_all_rounded,
              label: l10n.taNotifSelectAll,
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                _toggleSelectionMode();
                _selectAll();
              },
            ),
            _buildBulkActionItem(
              icon: Icons.mark_email_read_outlined,
              label: l10n.taNotifMarkAllRead,
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  for (var i = 0; i < _notifications.length; i++) {
                    _notifications[i] = TANotificationItem(
                      id: _notifications[i].id,
                      title: _notifications[i].title,
                      senderName: _notifications[i].senderName,
                      preview: _notifications[i].preview,
                      timeAgo: _notifications[i].timeAgo,
                      type: _notifications[i].type,
                      badge: _notifications[i].badge,
                      isUnread: false,
                      hasThread: _notifications[i].hasThread,
                      replyCount: _notifications[i].replyCount,
                      fullContent: _notifications[i].fullContent,
                      relatedTo: _notifications[i].relatedTo,
                    );
                  }
                });
                _showSnackBar('All marked as read');
              },
            ),
            _buildBulkActionItem(
              icon: Icons.delete_sweep_outlined,
              label: l10n.taNotifDeleteAll,
              color: TAColors.error,
              isDark: isDark,
              onTap: () {
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
                  // Clear cache and reload swipe settings when returning
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
    required VoidCallback onTap,
  }) {
    return ListTile(
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
            child: Text(l10n.taLabCancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _notifications.clear());
              _showSnackBar('All notifications deleted');
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

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: TAColors.scaffoldColor(isDark),
          drawer: TADrawer(currentRoute: '/ta/notifications', isDark: isDark),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadNotifications,
              color: TAColors.primary,
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(isDark, l10n),
                  if (_isSelectionMode)
                    SliverToBoxAdapter(child: _buildSelectionBar(isDark, l10n)),
                  SliverToBoxAdapter(child: _buildActionBar(isDark, l10n)),
                  SliverToBoxAdapter(child: _buildFilterChips(isDark, l10n)),
                  _buildNotificationsList(isDark, l10n),
                  if (_expandedNotificationId != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: TAAIReplyAssistant(
                          isDark: isDark,
                          onGenerateReply: () =>
                              _showSnackBar('Generating AI reply...'),
                          onExplainIssue: () =>
                              _showSnackBar('Analyzing issue...'),
                          onSendReply: (reply) =>
                              _showSnackBar('Reply sent: $reply'),
                        ),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TAResponsePerformance(
                        isDark: isDark,
                        avgResponseTime: '28 mins',
                        messagesToday: 12,
                        aiRepliesUsed: 37,
                        aiRepliesTrend: 'this week',
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectionBar(bool isDark, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: TAColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TAColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text(
            '${_selectedNotifications.length} ${l10n.taNotifSelected}',
            style: TextStyle(
              color: TAColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: _selectAll,
            icon: Icon(
              Icons.select_all_rounded,
              color: TAColors.primary,
              size: 20,
            ),
            tooltip: l10n.taNotifSelectAll,
          ),
          IconButton(
            onPressed: _markSelectedAsRead,
            icon: Icon(
              Icons.mark_email_read_outlined,
              color: TAColors.success,
              size: 20,
            ),
            tooltip: l10n.taNotifMarkAllRead,
          ),
          IconButton(
            onPressed: _deleteSelected,
            icon: Icon(
              Icons.delete_outline_rounded,
              color: TAColors.error,
              size: 20,
            ),
            tooltip: l10n.delete,
          ),
          IconButton(
            onPressed: _toggleSelectionMode,
            icon: Icon(
              Icons.close_rounded,
              color: TAColors.textSecondaryColor(isDark),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(bool isDark, AppLocalizations l10n) {
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
            l10n.taNotifSubtitle,
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontSize: 11,
            ),
          ),
        ],
      ),
      actions: [
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

  Widget _buildActionBar(bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          // Search
          Expanded(
            flex: 2,
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
          // AI Replies Toggle
          _buildActionButton(
            icon: Icons.auto_awesome,
            label: l10n.taNotifAIReplies,
            isActive: _aiRepliesEnabled,
            isDark: isDark,
            onTap: () => setState(() => _aiRepliesEnabled = !_aiRepliesEnabled),
          ),
          const SizedBox(width: 8),
          // Bulk Actions
          _buildActionButton(
            icon: Icons.checklist_rounded,
            label: l10n.taNotifBulkActions,
            isDark: isDark,
            onTap: () => _showBulkActionsSheet(isDark, l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isDark,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? TAColors.primary.withValues(alpha: 0.15)
                : TAColors.cardColor(isDark),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive
                  ? TAColors.primary.withValues(alpha: 0.3)
                  : TAColors.borderColor(isDark).withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive
                    ? TAColors.primary
                    : TAColors.textSecondaryColor(isDark),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: isActive
                      ? TAColors.primary
                      : TAColors.textPrimaryColor(isDark),
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(bool isDark, AppLocalizations l10n) {
    final filters = [
      {'id': 'all', 'label': l10n.taNotifAll, 'icon': Icons.all_inbox_rounded},
      {
        'id': 'students',
        'label': l10n.taNotifStudents,
        'icon': Icons.school_rounded,
      },
      {
        'id': 'instructors',
        'label': l10n.taNotifInstructors,
        'icon': Icons.person_rounded,
      },
      {'id': 'ai', 'label': 'AI', 'icon': Icons.auto_awesome},
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
              onSelected: (selected) {
                setState(() => _selectedFilter = filter['id'] as String);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNotificationsList(bool isDark, AppLocalizations l10n) {
    if (_isLoading) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: CircularProgressIndicator(color: TAColors.primary),
          ),
        ),
      );
    }

    final notifications = _filteredNotifications;

    if (notifications.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyState(isDark, l10n));
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final notification = notifications[index];
          final isExpanded = _expandedNotificationId == notification.id;
          final isSelected = _selectedNotifications.contains(notification.id);

          return Dismissible(
            key: Key('ta_notif_${notification.id}'),
            direction: _isSelectionMode
                ? DismissDirection.none
                : DismissDirection.horizontal,
            dismissThresholds: {
              DismissDirection.startToEnd: _swipeSettings.swipeSensitivity,
              DismissDirection.endToStart: _swipeSettings.swipeSensitivity,
            },
            confirmDismiss: (direction) async {
              HapticFeedback.lightImpact();
              final action = direction == DismissDirection.endToStart
                  ? _swipeSettings.leftAction
                  : _swipeSettings.rightAction;

              if (action == SwipeAction.none) return false;

              if (action.requiresConfirmation &&
                  _swipeSettings.confirmBeforeAction) {
                return await _showSwipeActionConfirmation(
                  isDark,
                  l10n,
                  notification,
                  action,
                );
              }

              _executeSwipeAction(action, notification);
              return action == SwipeAction.delete;
            },
            onDismissed: (direction) {
              final action = direction == DismissDirection.endToStart
                  ? _swipeSettings.leftAction
                  : _swipeSettings.rightAction;
              if (action == SwipeAction.delete) {
                _deleteNotification(notification.id);
              }
            },
            background: _buildSwipeBackground(
              action: _swipeSettings.rightAction,
              alignment: Alignment.centerLeft,
              notification: notification,
              l10n: l10n,
            ),
            secondaryBackground: _buildSwipeBackground(
              action: _swipeSettings.leftAction,
              alignment: Alignment.centerRight,
              notification: notification,
              l10n: l10n,
            ),
            child: GestureDetector(
              onLongPress: () {
                if (!_isSelectionMode) {
                  HapticFeedback.mediumImpact();
                  _toggleSelectionMode();
                  _toggleNotificationSelection(notification.id);
                }
              },
              child: Stack(
                children: [
                  TANotificationCard(
                    isDark: isDark,
                    notification: notification,
                    isExpanded: isExpanded,
                    onTap: () {
                      if (_isSelectionMode) {
                        _toggleNotificationSelection(notification.id);
                      } else {
                        setState(() {
                          _expandedNotificationId = isExpanded
                              ? null
                              : notification.id;
                        });
                      }
                    },
                    onReply: () =>
                        _showSnackBar('Replying to ${notification.senderName}'),
                    onResolve: () => _showSnackBar('Marked as resolved'),
                  ),
                  if (_isSelectionMode)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? TAColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSelected
                                ? TAColors.primary
                                : TAColors.borderColor(isDark),
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                            : null,
                      ),
                    ),
                ],
              ),
            ),
          );
        }, childCount: notifications.length),
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
