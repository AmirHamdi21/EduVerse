import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/instructor/shared/instructor_colors.dart';

/// Instructor Chat/Messages Screen
class InstructorChatScreen extends StatefulWidget {
  const InstructorChatScreen({super.key});

  @override
  State<InstructorChatScreen> createState() => _InstructorChatScreenState();
}

class _InstructorChatScreenState extends State<InstructorChatScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedConversationId;

  // Mock data
  final List<_Conversation> _conversations = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _generateMockConversations();
  }

  void _generateMockConversations() {
    final now = DateTime.now();
    _conversations.addAll([
      _Conversation(
        id: '1',
        name: 'John Smith',
        avatar: 'JS',
        lastMessage: 'Thank you for the feedback, Professor!',
        timestamp: now.subtract(const Duration(minutes: 5)),
        unreadCount: 2,
        isOnline: true,
        type: _ConversationType.student,
        courseName: 'CS 101',
      ),
      _Conversation(
        id: '2',
        name: 'Emily Johnson',
        avatar: 'EJ',
        lastMessage: 'I have a question about Assignment 3...',
        timestamp: now.subtract(const Duration(minutes: 30)),
        unreadCount: 1,
        isOnline: true,
        type: _ConversationType.student,
        courseName: 'CS 201',
      ),
      _Conversation(
        id: '3',
        name: 'Dr. Robert Williams',
        avatar: 'RW',
        lastMessage: 'See you at the meeting tomorrow!',
        timestamp: now.subtract(const Duration(hours: 2)),
        unreadCount: 0,
        isOnline: false,
        type: _ConversationType.colleague,
        courseName: null,
      ),
      _Conversation(
        id: '4',
        name: 'CS 101 - General',
        avatar: '101',
        lastMessage: 'Reminder: Quiz on Friday!',
        timestamp: now.subtract(const Duration(hours: 3)),
        unreadCount: 0,
        isOnline: false,
        type: _ConversationType.group,
        courseName: 'CS 101',
        memberCount: 45,
      ),
      _Conversation(
        id: '5',
        name: 'Michael Brown',
        avatar: 'MB',
        lastMessage: 'Got it, thank you!',
        timestamp: now.subtract(const Duration(hours: 5)),
        unreadCount: 0,
        isOnline: false,
        type: _ConversationType.student,
        courseName: 'CS 101',
      ),
      _Conversation(
        id: '6',
        name: 'CS 201 - Questions',
        avatar: '201',
        lastMessage: 'Can someone explain linked lists?',
        timestamp: now.subtract(const Duration(hours: 8)),
        unreadCount: 5,
        isOnline: false,
        type: _ConversationType.group,
        courseName: 'CS 201',
        memberCount: 38,
      ),
      _Conversation(
        id: '7',
        name: 'Department Faculty',
        avatar: 'DF',
        lastMessage: 'Meeting notes attached',
        timestamp: now.subtract(const Duration(days: 1)),
        unreadCount: 0,
        isOnline: false,
        type: _ConversationType.group,
        memberCount: 12,
      ),
      _Conversation(
        id: '8',
        name: 'Sarah Davis',
        avatar: 'SD',
        lastMessage: 'When is the office hours?',
        timestamp: now.subtract(const Duration(days: 1, hours: 4)),
        unreadCount: 0,
        isOnline: true,
        type: _ConversationType.student,
        courseName: 'CS 301',
      ),
    ]);
  }

  List<_Conversation> _getFilteredConversations(int tab) {
    var filtered = _conversations;

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((c) =>
              c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              c.lastMessage.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Filter by tab
    switch (tab) {
      case 1: // Students
        filtered = filtered.where((c) => c.type == _ConversationType.student).toList();
        break;
      case 2: // Groups
        filtered = filtered.where((c) => c.type == _ConversationType.group).toList();
        break;
    }

    return filtered..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  int get _totalUnreadCount => _conversations.fold(0, (sum, c) => sum + c.unreadCount);

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          backgroundColor: InstructorColors.background(isDark),
          body: SafeArea(
            child: Row(
              children: [
                // Conversation list (full width on mobile, sidebar on desktop)
                Expanded(
                  flex: MediaQuery.of(context).size.width > 900 ? 1 : 2,
                  child: Column(
                    children: [
                      _buildAppBar(isDark, l10n),
                      _buildSearchBar(isDark, l10n),
                      _buildTabs(isDark, l10n),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildConversationList(0, isDark, l10n),
                            _buildConversationList(1, isDark, l10n),
                            _buildConversationList(2, isDark, l10n),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Chat detail view (only on desktop)
                if (MediaQuery.of(context).size.width > 900)
                  Expanded(
                    flex: 2,
                    child: _selectedConversationId != null
                        ? _buildChatDetail(isDark, l10n)
                        : _buildEmptyChatDetail(isDark, l10n),
                  ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showNewChatSheet(isDark, l10n),
            backgroundColor: InstructorColors.primary,
            child: const Icon(Icons.edit_outlined, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: InstructorColors.textPrimaryColor(isDark),
              size: 20,
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Text(
                  l10n.messages,
                  style: TextStyle(
                    color: InstructorColors.textPrimaryColor(isDark),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (_totalUnreadCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: InstructorColors.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _totalUnreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.more_vert_rounded,
              color: InstructorColors.textPrimaryColor(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          style: TextStyle(
            color: InstructorColors.textPrimaryColor(isDark),
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: l10n.searchConversations,
            hintStyle: TextStyle(
              color: InstructorColors.textTertiaryColor(isDark),
              fontSize: 15,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: InstructorColors.textTertiaryColor(isDark),
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildTabs(bool isDark, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: InstructorColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: InstructorColors.textSecondaryColor(isDark),
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        tabs: [
          Tab(text: l10n.all),
          Tab(text: l10n.students),
          Tab(text: l10n.groups),
        ],
      ),
    );
  }

  Widget _buildConversationList(int tab, bool isDark, AppLocalizations l10n) {
    final conversations = _getFilteredConversations(tab);

    if (conversations.isEmpty) {
      return _buildEmptyState(tab, isDark, l10n);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        return _buildConversationTile(conversations[index], isDark);
      },
    );
  }

  Widget _buildConversationTile(_Conversation conversation, bool isDark) {
    final isSelected = _selectedConversationId == conversation.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedConversationId = conversation.id;
          // Mark as read
          final index = _conversations.indexWhere((c) => c.id == conversation.id);
          if (index != -1) {
            _conversations[index] = _Conversation(
              id: conversation.id,
              name: conversation.name,
              avatar: conversation.avatar,
              lastMessage: conversation.lastMessage,
              timestamp: conversation.timestamp,
              unreadCount: 0,
              isOnline: conversation.isOnline,
              type: conversation.type,
              courseName: conversation.courseName,
              memberCount: conversation.memberCount,
            );
          }
        });

        // On mobile, navigate to chat detail
        if (MediaQuery.of(context).size.width <= 900) {
          _showChatDetailSheet(conversation, isDark);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? InstructorColors.primary.withValues(alpha: 0.1)
              : InstructorColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? InstructorColors.primary.withValues(alpha: 0.3)
                : InstructorColors.borderColor(isDark),
          ),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: conversation.type == _ConversationType.group
                        ? InstructorColors.accent.withValues(alpha: 0.1)
                        : InstructorColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: conversation.type == _ConversationType.group
                        ? Icon(
                            Icons.group_outlined,
                            color: InstructorColors.accent,
                            size: 24,
                          )
                        : Text(
                            conversation.avatar,
                            style: TextStyle(
                              color: InstructorColors.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                if (conversation.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: InstructorColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: InstructorColors.cardColor(isDark),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.name,
                          style: TextStyle(
                            color: InstructorColors.textPrimaryColor(isDark),
                            fontSize: 15,
                            fontWeight: conversation.unreadCount > 0
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        conversation.timeAgo,
                        style: TextStyle(
                          color: conversation.unreadCount > 0
                              ? InstructorColors.primary
                              : InstructorColors.textTertiaryColor(isDark),
                          fontSize: 12,
                          fontWeight: conversation.unreadCount > 0
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessage,
                          style: TextStyle(
                            color: conversation.unreadCount > 0
                                ? InstructorColors.textPrimaryColor(isDark)
                                : InstructorColors.textTertiaryColor(isDark),
                            fontSize: 13,
                            fontWeight: conversation.unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: InstructorColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            conversation.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (conversation.courseName != null ||
                      conversation.memberCount != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (conversation.courseName != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: InstructorColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              conversation.courseName!,
                              style: TextStyle(
                                color: InstructorColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if (conversation.memberCount != null) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.people_outline,
                            size: 12,
                            color: InstructorColors.textTertiaryColor(isDark),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${conversation.memberCount} members',
                            style: TextStyle(
                              color: InstructorColors.textTertiaryColor(isDark),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(int tab, bool isDark, AppLocalizations l10n) {
    String title;
    String message;
    IconData icon;

    switch (tab) {
      case 1:
        title = l10n.noStudentChats;
        message = l10n.noStudentChatsDesc;
        icon = Icons.school_outlined;
        break;
      case 2:
        title = l10n.noGroupChats;
        message = l10n.noGroupChatsDesc;
        icon = Icons.group_outlined;
        break;
      default:
        title = l10n.noConversations;
        message = l10n.noConversationsDesc;
        icon = Icons.chat_bubble_outline;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: InstructorColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: InstructorColors.primary, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: InstructorColors.textPrimaryColor(isDark),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: InstructorColors.textTertiaryColor(isDark),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChatDetail(bool isDark, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        border: Border(
          left: BorderSide(color: InstructorColors.borderColor(isDark)),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: InstructorColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                color: InstructorColors.primary,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.selectConversation,
              style: TextStyle(
                color: InstructorColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.selectConversationDesc,
              style: TextStyle(
                color: InstructorColors.textTertiaryColor(isDark),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatDetail(bool isDark, AppLocalizations l10n) {
    final conversation = _conversations.firstWhere(
      (c) => c.id == _selectedConversationId,
      orElse: () => _conversations.first,
    );

    return Container(
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        border: Border(
          left: BorderSide(color: InstructorColors.borderColor(isDark)),
        ),
      ),
      child: Column(
        children: [
          _buildChatHeader(conversation, isDark),
          Expanded(
            child: _buildMessagesList(isDark),
          ),
          _buildMessageInput(isDark, l10n),
        ],
      ),
    );
  }

  Widget _buildChatHeader(_Conversation conversation, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        border: Border(
          bottom: BorderSide(color: InstructorColors.borderColor(isDark)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: InstructorColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                conversation.avatar,
                style: TextStyle(
                  color: InstructorColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation.name,
                  style: TextStyle(
                    color: InstructorColors.textPrimaryColor(isDark),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  conversation.isOnline
                      ? 'Online'
                      : 'Last seen ${conversation.timeAgo}',
                  style: TextStyle(
                    color: conversation.isOnline
                        ? InstructorColors.success
                        : InstructorColors.textTertiaryColor(isDark),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.videocam_outlined,
              color: InstructorColors.textSecondaryColor(isDark),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.call_outlined,
              color: InstructorColors.textSecondaryColor(isDark),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.more_vert_rounded,
              color: InstructorColors.textSecondaryColor(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(bool isDark) {
    // Mock messages
    final messages = [
      _Message(
        id: '1',
        text: 'Good morning, Professor!',
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      _Message(
        id: '2',
        text: 'Good morning! How can I help you?',
        isMe: true,
        timestamp: DateTime.now().subtract(const Duration(minutes: 55)),
      ),
      _Message(
        id: '3',
        text: 'I had a question about Assignment 3. Could you clarify the requirements for the second part?',
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 50)),
      ),
      _Message(
        id: '4',
        text: 'Of course! The second part asks you to implement a binary search tree with insert, delete, and search operations.',
        isMe: true,
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
      _Message(
        id: '5',
        text: 'Thank you for the clarification! That helps a lot.',
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 40)),
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        return _buildMessageBubble(messages[index], isDark);
      },
    );
  }

  Widget _buildMessageBubble(_Message message, bool isDark) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.6,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: message.isMe
              ? InstructorColors.primary
              : isDark
                  ? InstructorColors.darkSurface
                  : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isMe ? 16 : 4),
            bottomRight: Radius.circular(message.isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isMe
                    ? Colors.white
                    : InstructorColors.textPrimaryColor(isDark),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: message.isMe
                    ? Colors.white.withValues(alpha: 0.7)
                    : InstructorColors.textTertiaryColor(isDark),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        border: Border(
          top: BorderSide(color: InstructorColors.borderColor(isDark)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.attach_file_outlined,
              color: InstructorColors.textSecondaryColor(isDark),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                style: TextStyle(
                  color: InstructorColors.textPrimaryColor(isDark),
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: l10n.typeMessage,
                  hintStyle: TextStyle(
                    color: InstructorColors.textTertiaryColor(isDark),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: InstructorColors.primary,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.send_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  void _showChatDetailSheet(_Conversation conversation, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: InstructorColors.cardColor(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: InstructorColors.borderColor(isDark),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            _buildChatHeader(conversation, isDark),
            Expanded(child: _buildMessagesList(isDark)),
            _buildMessageInput(isDark, AppLocalizations.of(context)),
          ],
        ),
      ),
    );
  }

  void _showNewChatSheet(bool isDark, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: InstructorColors.cardColor(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.newMessage,
              style: TextStyle(
                color: InstructorColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            _buildNewChatOption(
              isDark,
              Icons.person_add_outlined,
              l10n.messageStudent,
              l10n.messageStudentDesc,
              InstructorColors.primary,
            ),
            _buildNewChatOption(
              isDark,
              Icons.group_add_outlined,
              l10n.createGroupChat,
              l10n.createGroupChatDesc,
              InstructorColors.accent,
            ),
            _buildNewChatOption(
              isDark,
              Icons.campaign_outlined,
              l10n.broadcastMessage,
              l10n.broadcastMessageDesc,
              InstructorColors.warning,
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }

  Widget _buildNewChatOption(
    bool isDark,
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: InstructorColors.textPrimaryColor(isDark),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: InstructorColors.textTertiaryColor(isDark),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}

enum _ConversationType { student, colleague, group }

class _Conversation {
  final String id;
  final String name;
  final String avatar;
  final String lastMessage;
  final DateTime timestamp;
  final int unreadCount;
  final bool isOnline;
  final _ConversationType type;
  final String? courseName;
  final int? memberCount;

  const _Conversation({
    required this.id,
    required this.name,
    required this.avatar,
    required this.lastMessage,
    required this.timestamp,
    required this.unreadCount,
    required this.isOnline,
    required this.type,
    this.courseName,
    this.memberCount,
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}

class _Message {
  final String id;
  final String text;
  final bool isMe;
  final DateTime timestamp;

  const _Message({
    required this.id,
    required this.text,
    required this.isMe,
    required this.timestamp,
  });
}
