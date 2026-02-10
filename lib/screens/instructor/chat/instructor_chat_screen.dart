import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/instructor/shared/instructor_colors.dart';
import '../../../widgets/instructor/chat/instructor_chat_barrel.dart';

/// Instructor Chat/Messages Screen
class InstructorChatScreen extends StatefulWidget {
  const InstructorChatScreen({super.key});

  @override
  State<InstructorChatScreen> createState() => _InstructorChatScreenState();
}

class _InstructorChatScreenState extends State<InstructorChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';
  InstructorChatFilter _currentFilter = InstructorChatFilter.all;
  InstructorConversation? _selectedConversation;

  // Mock data
  List<InstructorConversation> _conversations = [];
  List<InstructorChatMessage> _currentMessages = [];

  @override
  void initState() {
    super.initState();
    _generateMockConversations();
  }

  void _generateMockConversations() {
    final now = DateTime.now();
    _conversations = [
      InstructorConversation(
        id: '1',
        name: 'John Smith',
        avatar: 'JS',
        lastMessage: 'Thank you for the feedback, Professor!',
        timestamp: now.subtract(const Duration(minutes: 5)),
        unreadCount: 2,
        isOnline: true,
        type: InstructorConversationType.student,
        courseName: 'CS 101',
      ),
      InstructorConversation(
        id: '2',
        name: 'Emily Johnson',
        avatar: 'EJ',
        lastMessage: 'I have a question about Assignment 3...',
        timestamp: now.subtract(const Duration(minutes: 30)),
        unreadCount: 1,
        isOnline: true,
        type: InstructorConversationType.student,
        courseName: 'CS 201',
      ),
      InstructorConversation(
        id: '3',
        name: 'Dr. Robert Williams',
        avatar: 'RW',
        lastMessage: 'See you at the meeting tomorrow!',
        timestamp: now.subtract(const Duration(hours: 2)),
        unreadCount: 0,
        isOnline: false,
        type: InstructorConversationType.colleague,
      ),
      InstructorConversation(
        id: '4',
        name: 'CS 101 - General',
        avatar: '101',
        lastMessage: 'Reminder: Quiz on Friday!',
        timestamp: now.subtract(const Duration(hours: 3)),
        unreadCount: 0,
        isOnline: false,
        type: InstructorConversationType.group,
        courseName: 'CS 101',
        memberCount: 45,
      ),
      InstructorConversation(
        id: '5',
        name: 'Michael Brown',
        avatar: 'MB',
        lastMessage: 'Got it, thank you!',
        timestamp: now.subtract(const Duration(hours: 5)),
        unreadCount: 0,
        isOnline: false,
        type: InstructorConversationType.student,
        courseName: 'CS 101',
      ),
      InstructorConversation(
        id: '6',
        name: 'CS 201 - Questions',
        avatar: '201',
        lastMessage: 'Can someone explain linked lists?',
        timestamp: now.subtract(const Duration(hours: 8)),
        unreadCount: 5,
        isOnline: false,
        type: InstructorConversationType.group,
        courseName: 'CS 201',
        memberCount: 38,
      ),
      InstructorConversation(
        id: '7',
        name: 'Department Faculty',
        avatar: 'DF',
        lastMessage: 'Meeting notes attached',
        timestamp: now.subtract(const Duration(days: 1)),
        unreadCount: 0,
        isOnline: false,
        type: InstructorConversationType.group,
        memberCount: 12,
        isPinned: true,
      ),
      InstructorConversation(
        id: '8',
        name: 'Sarah Davis',
        avatar: 'SD',
        lastMessage: 'When is the office hours?',
        timestamp: now.subtract(const Duration(days: 1, hours: 4)),
        unreadCount: 0,
        isOnline: true,
        type: InstructorConversationType.student,
        courseName: 'CS 301',
      ),
      InstructorConversation(
        id: '9',
        name: 'Dr. Lisa Anderson',
        avatar: 'LA',
        lastMessage: 'The research proposal looks great!',
        timestamp: now.subtract(const Duration(days: 2)),
        unreadCount: 0,
        isOnline: false,
        type: InstructorConversationType.colleague,
      ),
    ];
  }

  void _generateMockMessages(InstructorConversation conversation) {
    final now = DateTime.now();
    _currentMessages = [
      InstructorChatMessage(
        id: '1',
        content: 'Good morning, Professor!',
        isMe: false,
        timestamp: now.subtract(const Duration(hours: 1)),
        senderName: conversation.name,
        senderAvatar: conversation.avatar,
      ),
      InstructorChatMessage(
        id: '2',
        content: 'Good morning! How can I help you?',
        isMe: true,
        timestamp: now.subtract(const Duration(minutes: 55)),
        status: MessageStatus.read,
      ),
      InstructorChatMessage(
        id: '3',
        content:
            'I had a question about Assignment 3. Could you clarify the requirements for the second part?',
        isMe: false,
        timestamp: now.subtract(const Duration(minutes: 50)),
        senderName: conversation.name,
        senderAvatar: conversation.avatar,
      ),
      InstructorChatMessage(
        id: '4',
        content:
            'Of course! The second part asks you to implement a binary search tree with insert, delete, and search operations.',
        isMe: true,
        timestamp: now.subtract(const Duration(minutes: 45)),
        status: MessageStatus.read,
      ),
      InstructorChatMessage(
        id: '5',
        content: 'Thank you for the clarification! That helps a lot.',
        isMe: false,
        timestamp: now.subtract(const Duration(minutes: 40)),
        senderName: conversation.name,
        senderAvatar: conversation.avatar,
      ),
    ];
  }

  List<InstructorConversation> get _filteredConversations {
    var filtered = _conversations;

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (c) =>
                c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                c.lastMessage.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    // Filter by category
    switch (_currentFilter) {
      case InstructorChatFilter.students:
        filtered = filtered
            .where((c) => c.type == InstructorConversationType.student)
            .toList();
        break;
      case InstructorChatFilter.colleagues:
        filtered = filtered
            .where((c) => c.type == InstructorConversationType.colleague)
            .toList();
        break;
      case InstructorChatFilter.groups:
        filtered = filtered
            .where((c) => c.type == InstructorConversationType.group)
            .toList();
        break;
      case InstructorChatFilter.all:
        break;
    }

    return filtered;
  }

  int get _totalUnreadCount =>
      _conversations.fold(0, (sum, c) => sum + c.unreadCount);

  void _onSearch(String query) {
    setState(() => _searchQuery = query);
  }

  void _onFilterChanged(InstructorChatFilter filter) {
    setState(() => _currentFilter = filter);
  }

  void _selectConversation(InstructorConversation conversation) {
    setState(() {
      _selectedConversation = conversation;
      _generateMockMessages(conversation);
      // Mark as read
      final index = _conversations.indexWhere((c) => c.id == conversation.id);
      if (index != -1) {
        _conversations[index] = _conversations[index].copyWith(unreadCount: 0);
      }
    });

    // // On mobile, show chat detail sheet
    // if (MediaQuery.of(context).size.width <= 900) {
    //   _showChatDetailSheet(conversation);
    // }
  }

  void _onNewChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) => InstructorNewChatDialog(
          isDark: themeState.isDark,
          onCreate: (name, type, course) {
            // Create new conversation
            final newConversation = InstructorConversation(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: name,
              avatar: name.split(' ').map((e) => e[0]).take(2).join(),
              lastMessage: 'Start a conversation...',
              timestamp: DateTime.now(),
              type: type,
              courseName: course,
            );
            setState(() {
              _conversations.insert(0, newConversation);
              _selectConversation(newConversation);
            });
          },
        ),
      ),
    );
  }

  void _deleteConversation(String id) {
    setState(() {
      _conversations.removeWhere((c) => c.id == id);
      if (_selectedConversation?.id == id) {
        _selectedConversation = null;
        _currentMessages = [];
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Conversation deleted'),
        backgroundColor: InstructorColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _togglePinConversation(String id) {
    setState(() {
      final index = _conversations.indexWhere((c) => c.id == id);
      if (index != -1) {
        _conversations[index] = _conversations[index].copyWith(
          isPinned: !_conversations[index].isPinned,
        );
      }
    });
  }

  void _toggleMuteConversation(String id) {
    setState(() {
      final index = _conversations.indexWhere((c) => c.id == id);
      if (index != -1) {
        _conversations[index] = _conversations[index].copyWith(
          isMuted: !_conversations[index].isMuted,
        );
      }
    });
  }

  void _markAsRead(String id) {
    setState(() {
      final index = _conversations.indexWhere((c) => c.id == id);
      if (index != -1) {
        _conversations[index] = _conversations[index].copyWith(unreadCount: 0);
      }
    });
  }

  void _sendMessage(String message) {
    if (_selectedConversation == null) return;

    setState(() {
      _currentMessages.add(
        InstructorChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: message,
          isMe: true,
          timestamp: DateTime.now(),
          status: MessageStatus.sent,
        ),
      );

      // Update conversation's last message
      final index = _conversations.indexWhere(
        (c) => c.id == _selectedConversation!.id,
      );
      if (index != -1) {
        _conversations[index] = _conversations[index].copyWith(
          lastMessage: message,
          timestamp: DateTime.now(),
        );
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        // If a conversation is selected on mobile, show the detail view
        if (_selectedConversation != null &&
            MediaQuery.of(context).size.width <= 900) {
          return Scaffold(
            backgroundColor: InstructorColors.background(isDark),
            body: SafeArea(
              child: InstructorChatDetailView(
                conversation: _selectedConversation!,
                messages: _currentMessages,
                isDark: isDark,
                onBack: () => setState(() {
                  _selectedConversation = null;
                  _currentMessages = [];
                }),
                onSendMessage: _sendMessage,
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: InstructorColors.background(isDark),
          body: SafeArea(
            child: Row(
              children: [
                // Conversation list
                Expanded(
                  flex: MediaQuery.of(context).size.width > 900 ? 1 : 2,
                  child: Column(
                    children: [
                      // Header
                      InstructorChatHeader(
                        isDark: isDark,
                        onNewChat: _onNewChat,
                        isSearching: _isSearching,
                        onToggleSearch: () {
                          setState(() {
                            _isSearching = !_isSearching;
                            if (!_isSearching) {
                              _searchController.clear();
                              _searchQuery = '';
                            }
                          });
                        },
                        unreadCount: _totalUnreadCount,
                      ),
                      // Search bar
                      AnimatedCrossFade(
                        firstChild: const SizedBox.shrink(),
                        secondChild: InstructorChatSearchBar(
                          controller: _searchController,
                          isDark: isDark,
                          onChanged: _onSearch,
                        ),
                        crossFadeState: _isSearching
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 200),
                      ),
                      // Filter chips
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: InstructorChatFilterChips(
                          currentFilter: _currentFilter,
                          isDark: isDark,
                          onFilterChanged: _onFilterChanged,
                        ),
                      ),
                      // Conversation list
                      Expanded(
                        child: _filteredConversations.isEmpty
                            ? InstructorChatEmptyState(
                                isDark: isDark,
                                isFiltered:
                                    _currentFilter !=
                                        InstructorChatFilter.all ||
                                    _searchQuery.isNotEmpty,
                                onClearFilters: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                    _currentFilter = InstructorChatFilter.all;
                                  });
                                },
                                onNewChat: _onNewChat,
                              )
                            : InstructorChatConversationList(
                                conversations: _filteredConversations,
                                isDark: isDark,
                                selectedConversationId:
                                    _selectedConversation?.id,
                                onConversationTap: _selectConversation,
                                onConversationLongPress: (conversation) {
                                  _showConversationOptions(
                                    context,
                                    conversation,
                                    isDark,
                                  );
                                },
                                onDelete: _deleteConversation,
                                onPin: _togglePinConversation,
                                onMute: _toggleMuteConversation,
                                onMarkRead: _markAsRead,
                              ),
                      ),
                    ],
                  ),
                ),
                // Chat detail view (only on desktop)
                if (MediaQuery.of(context).size.width > 900)
                  Expanded(
                    flex: 2,
                    child: _selectedConversation != null
                        ? InstructorChatDetailView(
                            conversation: _selectedConversation!,
                            messages: _currentMessages,
                            isDark: isDark,
                            onBack: () => setState(() {
                              _selectedConversation = null;
                              _currentMessages = [];
                            }),
                            onSendMessage: _sendMessage,
                          )
                        : _buildEmptyChatDetail(isDark, l10n),
                  ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _onNewChat,
            backgroundColor: InstructorColors.primary,
            child: const Icon(Icons.edit_outlined, color: Colors.white),
          ),
        );
      },
    );
  }

  void _showChatDetailSheet(InstructorConversation conversation) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final isDark = themeState.isDark;
          return Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: BoxDecoration(
              color: InstructorColors.cardColor(isDark),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
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
                Expanded(
                  child: InstructorChatDetailView(
                    conversation: conversation,
                    messages: _currentMessages,
                    isDark: isDark,
                    onBack: () => Navigator.pop(context),
                    onSendMessage: (message) {
                      _sendMessage(message);
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showConversationOptions(
    BuildContext context,
    InstructorConversation conversation,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: InstructorColors.cardColor(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: InstructorColors.borderColor(isDark),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                // Conversation info
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
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
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (conversation.courseName != null)
                            Text(
                              conversation.courseName!,
                              style: TextStyle(
                                color: InstructorColors.textTertiaryColor(
                                  isDark,
                                ),
                                fontSize: 13,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildOptionTile(
                  icon: conversation.isPinned
                      ? Icons.push_pin
                      : Icons.push_pin_outlined,
                  label: conversation.isPinned ? 'Unpin' : 'Pin Chat',
                  isDark: isDark,
                  onTap: () {
                    _togglePinConversation(conversation.id);
                    Navigator.pop(ctx);
                  },
                ),
                _buildOptionTile(
                  icon: conversation.isMuted
                      ? Icons.notifications
                      : Icons.notifications_off_outlined,
                  label: conversation.isMuted ? 'Unmute' : 'Mute',
                  isDark: isDark,
                  onTap: () {
                    _toggleMuteConversation(conversation.id);
                    Navigator.pop(ctx);
                  },
                ),
                _buildOptionTile(
                  icon: Icons.delete_outline_rounded,
                  label: 'Delete',
                  isDark: isDark,
                  isDestructive: true,
                  onTap: () {
                    Navigator.pop(ctx);
                    _deleteConversation(conversation.id);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive
        ? InstructorColors.error
        : InstructorColors.textPrimaryColor(isDark);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
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
}
