import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../widgets/admin/dashboard/admin_drawer.dart';
import '../../../widgets/admin/messages/messages_barrel.dart';

class AdminMessagesScreen extends StatefulWidget {
  const AdminMessagesScreen({super.key});

  @override
  State<AdminMessagesScreen> createState() => _AdminMessagesScreenState();
}

class _AdminMessagesScreenState extends State<AdminMessagesScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  late TabController _tabController;

  String _selectedFilter = 'all';
  String? _selectedChatId;
  bool _isLoading = false;

  final List<Conversation> _conversations = [
    Conversation(
      id: '1',
      name: 'Ahmed Hassan',
      avatar: 'AH',
      type: 'student',
      lastMessage: 'Thank you for resolving my issue!',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
      unreadCount: 2,
      isOnline: true,
      department: 'Computer Science',
    ),
    Conversation(
      id: '2',
      name: 'Dr. Sarah Johnson',
      avatar: 'SJ',
      type: 'instructor',
      lastMessage: 'The course enrollment issue has been fixed.',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
      unreadCount: 0,
      isOnline: true,
      department: 'Computer Science',
    ),
    Conversation(
      id: '3',
      name: 'Omar Ali (TA)',
      avatar: 'OA',
      type: 'ta',
      lastMessage: 'Need help with grading permissions',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
      unreadCount: 1,
      isOnline: false,
      department: 'Data Structures',
    ),
    Conversation(
      id: '4',
      name: 'Admin Team',
      avatar: 'AT',
      type: 'group',
      lastMessage: 'System maintenance scheduled for tonight',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 3)),
      unreadCount: 0,
      isOnline: false,
      memberCount: 8,
    ),
    Conversation(
      id: '5',
      name: 'Fatima Nour',
      avatar: 'FN',
      type: 'student',
      lastMessage: 'How do I reset my password?',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 0,
      isOnline: true,
      department: 'Software Engineering',
    ),
    Conversation(
      id: '6',
      name: 'System Alerts',
      avatar: 'SA',
      type: 'system',
      lastMessage: 'Backup completed successfully',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 5,
      isOnline: false,
    ),
  ];

  final Map<String, List<ChatMessage>> _chatMessages = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _initializeMockMessages();
  }

  void _initializeMockMessages() {
    _chatMessages['1'] = [
      ChatMessage(
        id: '1',
        content: 'Hi, I\'m having trouble accessing my course materials.',
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        senderName: 'Ahmed Hassan',
      ),
      ChatMessage(
        id: '2',
        content: 'Let me check your account permissions.',
        isMe: true,
        timestamp: DateTime.now().subtract(
          const Duration(hours: 1, minutes: 50),
        ),
        isRead: true,
      ),
      ChatMessage(
        id: '3',
        content: 'I\'ve updated your access. Please try logging in again.',
        isMe: true,
        timestamp: DateTime.now().subtract(
          const Duration(hours: 1, minutes: 45),
        ),
        isRead: true,
      ),
      ChatMessage(
        id: '4',
        content: 'Thank you for resolving my issue!',
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        senderName: 'Ahmed Hassan',
      ),
    ];

    _chatMessages['2'] = [
      ChatMessage(
        id: '1',
        content: 'There seems to be an enrollment issue with CS301.',
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        senderName: 'Dr. Sarah Johnson',
      ),
      ChatMessage(
        id: '2',
        content: 'I\'ll look into it right away.',
        isMe: true,
        timestamp: DateTime.now().subtract(
          const Duration(hours: 2, minutes: 30),
        ),
        isRead: true,
      ),
      ChatMessage(
        id: '3',
        content: 'The course enrollment issue has been fixed.',
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        senderName: 'Dr. Sarah Johnson',
      ),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    _chatScrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  List<Conversation> get _filteredConversations {
    var filtered = _conversations;

    // Filter by tab
    if (_selectedFilter != 'all') {
      filtered = filtered.where((c) => c.type == _selectedFilter).toList();
    }

    // Filter by search
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered
          .where(
            (c) =>
                c.name.toLowerCase().contains(query) ||
                c.lastMessage.toLowerCase().contains(query),
          )
          .toList();
    }

    return filtered;
  }

  void _selectConversation(Conversation conversation) {
    setState(() {
      _selectedChatId = conversation.id;
    });

    // Mark as read
    final index = _conversations.indexWhere((c) => c.id == conversation.id);
    if (index != -1 && _conversations[index].unreadCount > 0) {
      setState(() {
        _conversations[index] = Conversation(
          id: conversation.id,
          name: conversation.name,
          avatar: conversation.avatar,
          type: conversation.type,
          lastMessage: conversation.lastMessage,
          lastMessageTime: conversation.lastMessageTime,
          unreadCount: 0,
          isOnline: conversation.isOnline,
          department: conversation.department,
          memberCount: conversation.memberCount,
        );
      });
    }

    // Scroll to bottom of chat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String content) {
    if (_selectedChatId == null || content.isEmpty) return;

    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isMe: true,
      timestamp: DateTime.now(),
      isRead: false,
    );

    setState(() {
      _chatMessages.putIfAbsent(_selectedChatId!, () => []);
      _chatMessages[_selectedChatId!]!.add(newMessage);
    });

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Simulate response
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted || _selectedChatId == null) return;

      final responseMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Thanks for your message! I\'ll get back to you soon.',
        isMe: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        _chatMessages[_selectedChatId!]!.add(responseMessage);
      });

      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);
        final isWideScreen = MediaQuery.of(context).size.width > 800;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: isDark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: AdminColors.getBackgroundColor(isDark),
            // drawer: const AdminDrawer(),
            body: Container(
              decoration: isDark
                  ? null
                  : BoxDecoration(
                      gradient: AdminColors.lightBackgroundGradient,
                    ),
              child: SafeArea(
                child: isWideScreen
                    ? _buildWideLayout(isDark, l10n)
                    : _buildNarrowLayout(isDark, l10n),
              ),
            ),
            floatingActionButton: _selectedChatId == null
                ? FloatingActionButton(
                    onPressed: () => _showNewMessageDialog(context, isDark),
                    backgroundColor: AdminColors.primary,
                    child: const Icon(Icons.edit_rounded, color: Colors.white),
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildWideLayout(bool isDark, AppLocalizations l10n) {
    return Row(
      children: [
        SizedBox(width: 360, child: _buildConversationList(isDark, l10n)),
        Container(
          width: 1,
          color: isDark ? AdminColors.darkDivider : AdminColors.lightDivider,
        ),
        Expanded(
          child: _selectedChatId != null
              ? _buildChatView(isDark, l10n)
              : _buildEmptyChatState(isDark, l10n),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(bool isDark, AppLocalizations l10n) {
    if (_selectedChatId != null) {
      return _buildChatView(isDark, l10n);
    }
    return _buildConversationList(isDark, l10n);
  }

  Widget _buildConversationList(bool isDark, AppLocalizations l10n) {
    return Column(
      children: [
        _buildHeader(isDark, l10n),
        _buildSearchBar(isDark),
        _buildFilterTabs(isDark),
        Expanded(
          child: AdminConversationList(
            isDark: isDark,
            conversations: _filteredConversations,
            selectedId: _selectedChatId,
            onConversationTap: _selectConversation,
            searchQuery: _searchController.text,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: isDark ? AdminColors.darkText : AdminColors.lightText,
            ),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 8),
          Text(
            l10n.messages,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? AdminColors.darkText : AdminColors.lightText,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AdminColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.circle, size: 8, color: AdminColors.success),
                const SizedBox(width: 6),
                Text(
                  '${_conversations.where((c) => c.isOnline).length} Online',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AdminColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AdminColors.darkCard : AdminColors.lightCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? AdminColors.darkCardBorder
                : AdminColors.lightCardBorder,
          ),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          style: TextStyle(
            color: isDark ? AdminColors.darkText : AdminColors.lightText,
          ),
          decoration: InputDecoration(
            hintText: 'Search conversations...',
            hintStyle: TextStyle(
              color: isDark
                  ? AdminColors.darkTextTertiary
                  : AdminColors.lightTextTertiary,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: isDark
                  ? AdminColors.darkTextSecondary
                  : AdminColors.lightTextSecondary,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      color: isDark
                          ? AdminColors.darkTextSecondary
                          : AdminColors.lightTextSecondary,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs(bool isDark) {
    final tabs = [
      ('all', 'All', null),
      ('student', 'Students', Icons.school_rounded),
      ('instructor', 'Instructors', Icons.person_rounded),
      ('ta', 'TAs', Icons.assistant_rounded),
      ('group', 'Groups', Icons.groups_rounded),
    ];

    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final isSelected = _selectedFilter == tab.$1;
          final unreadCount = tab.$1 == 'all'
              ? _conversations.fold(0, (sum, c) => sum + c.unreadCount)
              : _conversations
                    .where((c) => c.type == tab.$1)
                    .fold(0, (sum, c) => sum + c.unreadCount);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _selectedFilter = tab.$1;
                });
              },
              avatar: tab.$3 != null
                  ? Icon(
                      tab.$3,
                      size: 18,
                      color: isSelected ? Colors.white : AdminColors.primary,
                    )
                  : null,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(tab.$2),
                  if (unreadCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : AdminColors.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        unreadCount.toString(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? AdminColors.primary
                              : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark ? AdminColors.darkText : AdminColors.lightText),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              backgroundColor: isDark
                  ? AdminColors.darkCard
                  : AdminColors.lightCard,
              selectedColor: AdminColors.primary,
              side: BorderSide(
                color: isSelected
                    ? AdminColors.primary
                    : (isDark
                          ? AdminColors.darkCardBorder
                          : AdminColors.lightCardBorder),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatView(bool isDark, AppLocalizations l10n) {
    final conversation = _conversations.firstWhere(
      (c) => c.id == _selectedChatId,
      orElse: () => _conversations.first,
    );
    final messages = _chatMessages[_selectedChatId] ?? [];

    return Column(
      children: [
        AdminConversationHeader(
          isDark: isDark,
          name: conversation.name,
          subtitle: conversation.department ?? 'Unknown',
          avatar: conversation.avatar,
          isOnline: conversation.isOnline,
          onBack: () {
            setState(() {
              _selectedChatId = null;
            });
          },
          onCall: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Starting voice call...'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          onVideoCall: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Starting video call...'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          onInfo: () {
            _showConversationInfo(context, conversation, isDark);
          },
        ),
        Expanded(
          child: messages.isEmpty
              ? _buildEmptyMessages(isDark)
              : ListView.builder(
                  controller: _chatScrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return AdminChatBubble(
                      isDark: isDark,
                      message: messages[index],
                      showSenderName: conversation.type == 'group',
                    );
                  },
                ),
        ),
        AdminMessageInput(
          isDark: isDark,
          onSend: _sendMessage,
          onAttachFile: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Attach file...'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          onVoiceMessage: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Recording voice message...'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyChatState(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AdminColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 64,
              color: AdminColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Select a conversation',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AdminColors.darkText : AdminColors.lightText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a conversation from the list to start messaging',
            style: TextStyle(
              color: isDark
                  ? AdminColors.darkTextSecondary
                  : AdminColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMessages(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.message_outlined,
            size: 48,
            color: isDark
                ? AdminColors.darkTextTertiary
                : AdminColors.lightTextTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AdminColors.darkText : AdminColors.lightText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start the conversation by sending a message',
            style: TextStyle(
              color: isDark
                  ? AdminColors.darkTextSecondary
                  : AdminColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showNewMessageDialog(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AdminColors.darkCard : AdminColors.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New Message',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AdminColors.darkText : AdminColors.lightText,
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AdminColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.person_add_rounded,
                    color: AdminColors.primary,
                  ),
                ),
                title: const Text('New Individual Message'),
                subtitle: const Text('Message a student, instructor, or TA'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Opening contact picker...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AdminColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.group_add_rounded,
                    color: AdminColors.secondary,
                  ),
                ),
                title: const Text('New Group'),
                subtitle: const Text('Create a group conversation'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Creating new group...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AdminColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.campaign_rounded,
                    color: AdminColors.warning,
                  ),
                ),
                title: const Text('Broadcast Message'),
                subtitle: const Text('Send to multiple recipients'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Opening broadcast editor...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showConversationInfo(
    BuildContext context,
    Conversation conversation,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AdminColors.darkCard : AdminColors.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AdminColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    conversation.avatar,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                conversation.name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AdminColors.darkText : AdminColors.lightText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                conversation.department ?? conversation.type.toUpperCase(),
                style: TextStyle(
                  color: isDark
                      ? AdminColors.darkTextSecondary
                      : AdminColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildInfoAction(
                    Icons.notifications_off_rounded,
                    'Mute',
                    isDark,
                  ),
                  _buildInfoAction(Icons.search_rounded, 'Search', isDark),
                  _buildInfoAction(Icons.archive_rounded, 'Archive', isDark),
                  _buildInfoAction(
                    Icons.delete_rounded,
                    'Delete',
                    isDark,
                    isDestructive: true,
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoAction(
    IconData icon,
    String label,
    bool isDark, {
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label tapped'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDestructive
                  ? AdminColors.error.withValues(alpha: 0.1)
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isDestructive
                  ? AdminColors.error
                  : (isDark ? AdminColors.darkText : AdminColors.lightText),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDestructive
                  ? AdminColors.error
                  : (isDark
                        ? AdminColors.darkTextSecondary
                        : AdminColors.lightTextSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
