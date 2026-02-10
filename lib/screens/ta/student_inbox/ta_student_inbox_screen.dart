import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/ta/shared/ta_colors.dart';
import '../../../widgets/ta/dashboard/ta_drawer.dart';
import '../../../widgets/ta/student_inbox/ta_student_inbox_barrel.dart';

class TAStudentInboxScreen extends StatefulWidget {
  const TAStudentInboxScreen({super.key});

  @override
  State<TAStudentInboxScreen> createState() => _TAStudentInboxScreenState();
}

class _TAStudentInboxScreenState extends State<TAStudentInboxScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String _selectedFilter = 'all';
  List<TAStudentChatItem> _allChats = [];
  List<TAStudentChatItem> _filteredChats = [];

  final List<String> _filterOptions = ['all', 'unread', 'at_risk', 'forwarded'];

  @override
  void initState() {
    super.initState();
    _loadChats();
    _searchController.addListener(_filterChats);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadChats() async {
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _allChats = [
        const TAStudentChatItem(
          id: '1',
          studentName: 'Ahmed Mohamed',
          studentId: 'CS2023001',
          message:
              'I need help understanding the lab exercise about data structures...',
          timeAgo: '5m ago',
          status: TAStudentChatStatus.unread,
          attendancePercent: 92,
          isAIFlagged: true,
          unreadCount: 3,
        ),
        const TAStudentChatItem(
          id: '2',
          studentName: 'Sara Hassan',
          studentId: 'CS2023002',
          message: 'When is the deadline for the assignment submission?',
          timeAgo: '15m ago',
          status: TAStudentChatStatus.atRisk,
          attendancePercent: 58,
          isAIFlagged: true,
          unreadCount: 1,
        ),
        const TAStudentChatItem(
          id: '3',
          studentName: 'Omar Ali',
          studentId: 'CS2023003',
          message: 'Thank you for the help during office hours!',
          timeAgo: '1h ago',
          status: TAStudentChatStatus.read,
          attendancePercent: 95,
        ),
        const TAStudentChatItem(
          id: '4',
          studentName: 'Fatima Nour',
          studentId: 'CS2023004',
          message: 'Could you please review my code solution?',
          timeAgo: '2h ago',
          status: TAStudentChatStatus.unread,
          attendancePercent: 88,
          unreadCount: 2,
        ),
        const TAStudentChatItem(
          id: '5',
          studentName: 'Youssef Khalil',
          studentId: 'CS2023005',
          message: 'I forwarded this to Dr. Smith as requested.',
          timeAgo: '3h ago',
          status: TAStudentChatStatus.forwarded,
          attendancePercent: 78,
        ),
        const TAStudentChatItem(
          id: '6',
          studentName: 'Mona Samir',
          studentId: 'CS2023006',
          message: 'Is there an extra office hour before the exam?',
          timeAgo: '5h ago',
          status: TAStudentChatStatus.read,
          attendancePercent: 65,
          isAIFlagged: false,
        ),
      ];
      _filteredChats = List.from(_allChats);
      _isLoading = false;
    });
  }

  void _filterChats() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      _filteredChats = _allChats.where((chat) {
        // Search filter
        final matchesSearch =
            query.isEmpty ||
            chat.studentName.toLowerCase().contains(query) ||
            chat.studentId.toLowerCase().contains(query) ||
            chat.message.toLowerCase().contains(query);

        // Status filter
        bool matchesFilter = true;
        switch (_selectedFilter) {
          case 'unread':
            matchesFilter = chat.status == TAStudentChatStatus.unread;
            break;
          case 'at_risk':
            matchesFilter = chat.status == TAStudentChatStatus.atRisk;
            break;
          case 'forwarded':
            matchesFilter = chat.status == TAStudentChatStatus.forwarded;
            break;
        }

        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  int get _atRiskCount =>
      _allChats.where((c) => c.status == TAStudentChatStatus.atRisk).length;

  int get _unreadCount =>
      _allChats.where((c) => c.status == TAStudentChatStatus.unread).length;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: TAColors.scaffoldColor(isDark),
          drawer: const TADrawer(currentRoute: '/ta/student-inbox'),
          appBar: _buildAppBar(isDark, l10n),
          body: _buildBody(context, isDark, l10n),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showNewMessageDialog(context, isDark, l10n),
            backgroundColor: TAColors.primary,
            icon: const Icon(Icons.edit_rounded, color: Colors.white),
            label: Text(
              l10n.taInboxNewMessage,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark, AppLocalizations l10n) {
    return AppBar(
      backgroundColor: TAColors.cardColor(isDark),
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.menu_rounded,
          color: TAColors.textPrimaryColor(isDark),
        ),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: Text(
        l10n.taInboxTitle,
        style: TextStyle(
          color: TAColors.textPrimaryColor(isDark),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: TAColors.textSecondaryColor(isDark),
          ),
          onPressed: () => context.read<ThemeBloc>().add(ToggleThemeEvent()),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, bool isDark, AppLocalizations l10n) {
    return Column(
      children: [
        _buildSearchAndFilters(isDark, l10n),
        TAAtRiskBanner(
          isDark: isDark,
          atRiskCount: _atRiskCount,
          onViewAll: () {
            setState(() {
              _selectedFilter = 'at_risk';
              _filterChats();
            });
          },
        ),
        Expanded(
          child: _isLoading
              ? _buildLoadingState(isDark)
              : _filteredChats.isEmpty
              ? _buildEmptyState(isDark, l10n)
              : _buildChatList(isDark, l10n),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: TAColors.cardColor(isDark),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
              ),
            ),
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                color: TAColors.textPrimaryColor(isDark),
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: l10n.taInboxSearchStudents,
                hintStyle: TextStyle(color: TAColors.textTertiaryColor(isDark)),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: TAColors.textTertiaryColor(isDark),
                  size: 20,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: TAColors.textTertiaryColor(isDark),
                          size: 18,
                        ),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Filter chips
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _filterOptions.map((filter) {
                final isSelected = _selectedFilter == filter;
                String label;
                int count = 0;

                switch (filter) {
                  case 'unread':
                    label = l10n.taInboxFilterUnread;
                    count = _unreadCount;
                    break;
                  case 'at_risk':
                    label = l10n.taInboxFilterAtRisk;
                    count = _atRiskCount;
                    break;
                  case 'forwarded':
                    label = l10n.taInboxFilterForwarded;
                    break;
                  default:
                    label = l10n.taInboxFilterAll;
                }

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(label),
                        if (count > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.3)
                                  : TAColors.error.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              count.toString(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? Colors.white
                                    : TAColors.error,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                        _filterChats();
                      });
                    },
                    backgroundColor: TAColors.cardColor(isDark),
                    selectedColor: TAColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : TAColors.textSecondaryColor(isDark),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? TAColors.primary
                            : TAColors.borderColor(isDark),
                      ),
                    ),
                    showCheckmark: false,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList(bool isDark, AppLocalizations l10n) {
    return RefreshIndicator(
      onRefresh: _loadChats,
      color: TAColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filteredChats.length,
        itemBuilder: (context, index) {
          final chat = _filteredChats[index];
          return TAStudentChatCard(
            chat: chat,
            isDark: isDark,
            onTap: () => _openChatDetail(context, chat, isDark, l10n),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: TAColors.primary),
          const SizedBox(height: 16),
          Text(
            'Loading messages...',
            style: TextStyle(color: TAColors.textSecondaryColor(isDark)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: TAColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.inbox_rounded, size: 48, color: TAColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.taInboxEmpty,
            style: TextStyle(
              color: TAColors.textPrimaryColor(isDark),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.taInboxEmptyDesc,
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _openChatDetail(
    BuildContext context,
    TAStudentChatItem chat,
    bool isDark,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: TAColors.cardColor(isDark),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: TAColors.borderColor(isDark),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: TAColors.primary.withValues(alpha: 0.15),
                      child: Text(
                        chat.studentName[0].toUpperCase(),
                        style: TextStyle(
                          color: TAColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chat.studentName,
                            style: TextStyle(
                              color: TAColors.textPrimaryColor(isDark),
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            chat.studentId,
                            style: TextStyle(
                              color: TAColors.textTertiaryColor(isDark),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: TAColors.textSecondaryColor(isDark),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'forward',
                          child: Row(
                            children: [
                              Icon(
                                Icons.forward_rounded,
                                color: TAColors.info,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(l10n.taInboxForward),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'mark_read',
                          child: Row(
                            children: [
                              Icon(
                                Icons.done_all_rounded,
                                color: TAColors.success,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(l10n.taInboxMarkRead),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'view_profile',
                          child: Row(
                            children: [
                              Icon(
                                Icons.person_rounded,
                                color: TAColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(l10n.taInboxViewProfile),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        // Navigator.pop(context);
                        // _handleChatAction(context, value, chat, isDark, l10n);
                      },
                    ),
                  ],
                ),
              ),
              Divider(color: TAColors.borderColor(isDark), height: 1),
              // Chat messages area
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Sample messages
                    _buildMessageBubble(
                      chat.message,
                      chat.timeAgo,
                      false,
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildMessageBubble(
                      'Sure, I can help you with that. Let me explain the concept step by step.',
                      '2m ago',
                      true,
                      isDark,
                    ),
                  ],
                ),
              ),
              // Message input
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: TAColors.cardColor(isDark),
                  border: Border(
                    top: BorderSide(color: TAColors.borderColor(isDark)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          style: TextStyle(
                            color: TAColors.textPrimaryColor(isDark),
                          ),
                          decoration: InputDecoration(
                            hintText: l10n.taInboxTypeMessage,
                            hintStyle: TextStyle(
                              color: TAColors.textTertiaryColor(isDark),
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: TAColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.taInboxMessageSent),
                              backgroundColor: TAColors.success,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(
    String message,
    String time,
    bool isMe,
    bool isDark,
  ) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe
              ? TAColors.primary
              : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.grey.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                color: isMe ? Colors.white : TAColors.textPrimaryColor(isDark),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                color: isMe
                    ? Colors.white.withValues(alpha: 0.7)
                    : TAColors.textTertiaryColor(isDark),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleChatAction(
    BuildContext context,
    String action,
    TAStudentChatItem chat,
    bool isDark,
    AppLocalizations l10n,
  ) {
    switch (action) {
      case 'forward':
        _showForwardDialog(context, chat, isDark, l10n);
        break;
      case 'mark_read':
        setState(() {
          final index = _allChats.indexWhere((c) => c.id == chat.id);
          if (index != -1) {
            _allChats[index] = TAStudentChatItem(
              id: chat.id,
              studentName: chat.studentName,
              studentId: chat.studentId,
              message: chat.message,
              timeAgo: chat.timeAgo,
              status: TAStudentChatStatus.read,
              attendancePercent: chat.attendancePercent,
              isAIFlagged: chat.isAIFlagged,
              unreadCount: 0,
            );
            _filterChats();
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.taInboxMarkedAsRead),
            backgroundColor: TAColors.success,
          ),
        );
        break;
      case 'view_profile':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening ${chat.studentName}\'s profile...'),
            backgroundColor: TAColors.info,
          ),
        );
        break;
    }
  }

  void _showForwardDialog(
    BuildContext context,
    TAStudentChatItem chat,
    bool isDark,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TAColors.cardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.taInboxForwardTo,
          style: TextStyle(color: TAColors.textPrimaryColor(isDark)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildForwardOption(
              'Dr. Ahmed Hassan',
              'Course Instructor',
              Icons.person_rounded,
              isDark,
              () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.taInboxForwarded),
                    backgroundColor: TAColors.success,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildForwardOption(
              'Academic Advisor',
              'Student Affairs',
              Icons.support_agent_rounded,
              isDark,
              () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.taInboxForwarded),
                    backgroundColor: TAColors.success,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: TAColors.textSecondaryColor(isDark)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForwardOption(
    String name,
    String role,
    IconData icon,
    bool isDark,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(
            color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: TAColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: TAColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: TAColors.textPrimaryColor(isDark),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    role,
                    style: TextStyle(
                      color: TAColors.textSecondaryColor(isDark),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: TAColors.textTertiaryColor(isDark),
            ),
          ],
        ),
      ),
    );
  }

  void _showNewMessageDialog(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final studentController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TAColors.cardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.taInboxNewMessage,
          style: TextStyle(color: TAColors.textPrimaryColor(isDark)),
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: studentController,
                style: TextStyle(color: TAColors.textPrimaryColor(isDark)),
                decoration: InputDecoration(
                  hintText: l10n.taInboxSearchStudents,
                  hintStyle: TextStyle(
                    color: TAColors.textTertiaryColor(isDark),
                  ),
                  prefixIcon: Icon(
                    Icons.person_search_rounded,
                    color: TAColors.textTertiaryColor(isDark),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: TAColors.borderColor(isDark)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: TAColors.borderColor(isDark)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: TAColors.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                maxLines: 4,
                style: TextStyle(color: TAColors.textPrimaryColor(isDark)),
                decoration: InputDecoration(
                  hintText: l10n.taInboxTypeMessage,
                  hintStyle: TextStyle(
                    color: TAColors.textTertiaryColor(isDark),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: TAColors.borderColor(isDark)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: TAColors.borderColor(isDark)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: TAColors.primary, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: TAColors.textSecondaryColor(isDark)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.taInboxMessageSent),
                  backgroundColor: TAColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TAColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(l10n.send, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
