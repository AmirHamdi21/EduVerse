import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/ta/shared/ta_colors.dart';
import '../../../widgets/ta/dashboard/ta_drawer.dart';

class TAMessagesScreen extends StatefulWidget {
  const TAMessagesScreen({super.key});

  @override
  State<TAMessagesScreen> createState() => _TAMessagesScreenState();
}

class _TAMessagesScreenState extends State<TAMessagesScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  
  String _selectedFilter = 'all';
  String? _selectedChatId;
  
  final List<Map<String, dynamic>> _conversations = [
    {
      'id': '1',
      'name': 'Ahmed Hassan',
      'avatar': 'AH',
      'type': 'student',
      'lastMessage': 'Thank you for the feedback on my submission!',
      'time': DateTime.now().subtract(const Duration(minutes: 5)),
      'unread': 2,
      'online': true,
      'course': 'Data Structures',
    },
    {
      'id': '2',
      'name': 'Dr. Sarah Johnson',
      'avatar': 'SJ',
      'type': 'instructor',
      'lastMessage': 'Can you help with the lab grading tomorrow?',
      'time': DateTime.now().subtract(const Duration(hours: 1)),
      'unread': 0,
      'online': true,
      'course': 'Machine Learning',
    },
    {
      'id': '3',
      'name': 'Omar Ali',
      'avatar': 'OA',
      'type': 'student',
      'lastMessage': 'I have a question about the assignment deadline',
      'time': DateTime.now().subtract(const Duration(hours: 2)),
      'unread': 1,
      'online': false,
      'course': 'Data Structures',
    },
    {
      'id': '4',
      'name': 'CS201 - Lab Group',
      'avatar': 'LG',
      'type': 'group',
      'lastMessage': 'Lab session rescheduled to Friday',
      'time': DateTime.now().subtract(const Duration(hours: 3)),
      'unread': 0,
      'online': false,
      'course': 'Data Structures',
      'members': 28,
    },
    {
      'id': '5',
      'name': 'Fatima Nour',
      'avatar': 'FN',
      'type': 'student',
      'lastMessage': 'Can I schedule office hours?',
      'time': DateTime.now().subtract(const Duration(days: 1)),
      'unread': 0,
      'online': true,
      'course': 'Database Systems',
    },
    {
      'id': '6',
      'name': 'Prof. Michael Brown',
      'avatar': 'MB',
      'type': 'instructor',
      'lastMessage': 'Please review the updated syllabus',
      'time': DateTime.now().subtract(const Duration(days: 1)),
      'unread': 0,
      'online': false,
      'course': 'Computer Networks',
    },
  ];

  final Map<String, List<Map<String, dynamic>>> _chatMessages = {
    '1': [
      {'content': 'Hi, I submitted my lab assignment. Could you take a look?', 'isMe': false, 'time': DateTime.now().subtract(const Duration(hours: 2))},
      {'content': 'Sure! I\'ll review it and get back to you.', 'isMe': true, 'time': DateTime.now().subtract(const Duration(hours: 1, minutes: 50))},
      {'content': 'I\'ve reviewed your submission. Great work on the algorithm implementation!', 'isMe': true, 'time': DateTime.now().subtract(const Duration(minutes: 30))},
      {'content': 'A few suggestions: consider adding error handling for edge cases.', 'isMe': true, 'time': DateTime.now().subtract(const Duration(minutes: 28))},
      {'content': 'Thank you for the feedback on my submission!', 'isMe': false, 'time': DateTime.now().subtract(const Duration(minutes: 5))},
    ],
    '2': [
      {'content': 'Hi! Hope you\'re doing well.', 'isMe': false, 'time': DateTime.now().subtract(const Duration(hours: 2))},
      {'content': 'Yes, thank you! How can I help?', 'isMe': true, 'time': DateTime.now().subtract(const Duration(hours: 1, minutes: 45))},
      {'content': 'Can you help with the lab grading tomorrow?', 'isMe': false, 'time': DateTime.now().subtract(const Duration(hours: 1))},
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.themeMode == AppThemeMode.dark;
        final l10n = AppLocalizations.of(context);
        final isWideScreen = MediaQuery.of(context).size.width > 800;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: TAColors.scaffoldColor(isDark),
          drawer: const TADrawer(currentRoute: '/ta/messages'),
          body: SafeArea(
            child: isWideScreen
                ? _buildWideLayout(isDark, l10n)
                : _buildNarrowLayout(isDark, l10n),
          ),
          floatingActionButton: _selectedChatId == null
              ? FloatingActionButton(
                  onPressed: () => _showNewMessageSheet(isDark, l10n),
                  backgroundColor: TAColors.primary,
                  child: const Icon(Icons.edit, color: Colors.white),
                )
              : null,
        );
      },
    );
  }

  Widget _buildWideLayout(bool isDark, AppLocalizations l10n) {
    return Row(
      children: [
        SizedBox(
          width: 350,
          child: Column(
            children: [
              _buildAppBar(isDark, l10n, showBack: false),
              _buildSearchBar(isDark, l10n),
              _buildFilterChips(isDark, l10n),
              Expanded(child: _buildConversationsList(isDark, l10n)),
            ],
          ),
        ),
        Container(width: 1, color: TAColors.borderColor(isDark)),
        Expanded(
          child: _selectedChatId != null
              ? _buildChatView(isDark, l10n)
              : _buildNoChatSelected(isDark, l10n),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(bool isDark, AppLocalizations l10n) {
    if (_selectedChatId != null) {
      return _buildChatView(isDark, l10n);
    }
    return Column(
      children: [
        _buildAppBar(isDark, l10n, showBack: false),
        _buildSearchBar(isDark, l10n),
        _buildFilterChips(isDark, l10n),
        Expanded(child: _buildConversationsList(isDark, l10n)),
      ],
    );
  }

  Widget _buildAppBar(bool isDark, AppLocalizations l10n, {bool showBack = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (showBack)
            IconButton(
              icon: Icon(Icons.arrow_back, color: TAColors.textPrimaryColor(isDark)),
              onPressed: () => setState(() => _selectedChatId = null),
            )
          else
            IconButton(
              icon: Icon(Icons.menu, color: TAColors.textPrimaryColor(isDark)),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          const SizedBox(width: 8),
          Text(
            l10n.messages,
            style: TextStyle(
              color: TAColors.textPrimaryColor(isDark),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          _buildUnreadBadge(isDark),
          IconButton(
            icon: Icon(Icons.more_vert, color: TAColors.textSecondaryColor(isDark)),
            onPressed: () => _showOptionsMenu(isDark, l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildUnreadBadge(bool isDark) {
    final unreadCount = _conversations.fold<int>(
      0, (sum, conv) => sum + (conv['unread'] as int),
    );
    if (unreadCount == 0) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: TAColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$unreadCount',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: l10n.searchMessages,
          hintStyle: TextStyle(color: TAColors.textTertiaryColor(isDark)),
          prefixIcon: Icon(Icons.search, color: TAColors.textSecondaryColor(isDark)),
          filled: true,
          fillColor: TAColors.scaffoldColor(isDark),
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
            borderSide: const BorderSide(color: TAColors.primary),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        style: TextStyle(color: TAColors.textPrimaryColor(isDark)),
        onChanged: (value) => setState(() {}),
      ),
    );
  }

  Widget _buildFilterChips(bool isDark, AppLocalizations l10n) {
    final filters = [
      {'id': 'all', 'label': l10n.all},
      {'id': 'students', 'label': l10n.students},
      {'id': 'instructors', 'label': l10n.instructors},
      {'id': 'groups', 'label': l10n.groups},
      {'id': 'unread', 'label': l10n.unread},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = _selectedFilter == filter['id'];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: isSelected,
                showCheckmark: false,
                label: Text(filter['label'] as String),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : TAColors.textPrimaryColor(isDark),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 12,
                ),
                backgroundColor: TAColors.cardColor(isDark),
                selectedColor: TAColors.primary,
                side: BorderSide(
                  color: isSelected ? TAColors.primary : TAColors.borderColor(isDark),
                ),
                onSelected: (selected) {
                  setState(() => _selectedFilter = filter['id'] as String);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildConversationsList(bool isDark, AppLocalizations l10n) {
    final filteredConversations = _getFilteredConversations();
    
    if (filteredConversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: TAColors.textTertiaryColor(isDark),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noMessages,
              style: TextStyle(
                color: TAColors.textSecondaryColor(isDark),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: filteredConversations.length,
      itemBuilder: (context, index) {
        final conversation = filteredConversations[index];
        return _buildConversationTile(isDark, l10n, conversation);
      },
    );
  }

  List<Map<String, dynamic>> _getFilteredConversations() {
    var filtered = _conversations.toList();
    
    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((conv) {
        return (conv['name'] as String).toLowerCase().contains(query) ||
               (conv['lastMessage'] as String).toLowerCase().contains(query);
      }).toList();
    }
    
    // Apply type filter
    switch (_selectedFilter) {
      case 'students':
        filtered = filtered.where((conv) => conv['type'] == 'student').toList();
        break;
      case 'instructors':
        filtered = filtered.where((conv) => conv['type'] == 'instructor').toList();
        break;
      case 'groups':
        filtered = filtered.where((conv) => conv['type'] == 'group').toList();
        break;
      case 'unread':
        filtered = filtered.where((conv) => (conv['unread'] as int) > 0).toList();
        break;
    }
    
    return filtered;
  }

  Widget _buildConversationTile(bool isDark, AppLocalizations l10n, Map<String, dynamic> conversation) {
    final isSelected = _selectedChatId == conversation['id'];
    final unread = conversation['unread'] as int;
    final isOnline = conversation['online'] as bool;
    final type = conversation['type'] as String;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? TAColors.primaryLight : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() => _selectedChatId = conversation['id']),
          onLongPress: () => _showConversationOptions(isDark, l10n, conversation),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: _getTypeColor(type),
                      radius: 24,
                      child: type == 'group'
                          ? const Icon(Icons.group, color: Colors.white, size: 20)
                          : Text(
                              conversation['avatar'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                    ),
                    if (isOnline && type != 'group')
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: TAColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: TAColors.cardColor(isDark),
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
                              conversation['name'],
                              style: TextStyle(
                                color: TAColors.textPrimaryColor(isDark),
                                fontWeight: unread > 0 ? FontWeight.bold : FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _formatTime(conversation['time'] as DateTime),
                            style: TextStyle(
                              color: unread > 0 ? TAColors.primary : TAColors.textTertiaryColor(isDark),
                              fontSize: 11,
                              fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (type == 'group')
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              margin: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                color: TAColors.info.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${conversation['members']} members',
                                style: TextStyle(
                                  color: TAColors.info,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          Expanded(
                            child: Text(
                              conversation['lastMessage'],
                              style: TextStyle(
                                color: TAColors.textSecondaryColor(isDark),
                                fontSize: 13,
                                fontWeight: unread > 0 ? FontWeight.w500 : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (unread > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: TAColors.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$unread',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (conversation['course'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            conversation['course'],
                            style: TextStyle(
                              color: TAColors.textTertiaryColor(isDark),
                              fontSize: 11,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoChatSelected(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: TAColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: TAColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.selectConversation,
            style: TextStyle(
              color: TAColors.textPrimaryColor(isDark),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a conversation from the list to start messaging',
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatView(bool isDark, AppLocalizations l10n) {
    final conversation = _conversations.firstWhere(
      (conv) => conv['id'] == _selectedChatId,
      orElse: () => {},
    );
    
    if (conversation.isEmpty) {
      return _buildNoChatSelected(isDark, l10n);
    }

    final messages = _chatMessages[_selectedChatId] ?? [];
    final isWideScreen = MediaQuery.of(context).size.width > 800;

    return Column(
      children: [
        _buildChatHeader(isDark, l10n, conversation, showBack: !isWideScreen),
        Expanded(
          child: messages.isEmpty
              ? _buildEmptyChatState(isDark, l10n)
              : _buildMessagesList(isDark, l10n, messages),
        ),
        _buildMessageInput(isDark, l10n),
      ],
    );
  }

  Widget _buildChatHeader(bool isDark, AppLocalizations l10n, Map<String, dynamic> conversation, {bool showBack = true}) {
    final isOnline = conversation['online'] as bool;
    final type = conversation['type'] as String;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (showBack)
            IconButton(
              icon: Icon(Icons.arrow_back, color: TAColors.textPrimaryColor(isDark)),
              onPressed: () => setState(() => _selectedChatId = null),
            ),
          Stack(
            children: [
              CircleAvatar(
                backgroundColor: _getTypeColor(type),
                radius: 20,
                child: type == 'group'
                    ? const Icon(Icons.group, color: Colors.white, size: 18)
                    : Text(
                        conversation['avatar'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
              ),
              if (isOnline && type != 'group')
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: TAColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: TAColors.cardColor(isDark),
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
                Text(
                  conversation['name'],
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: isOnline ? TAColors.success : TAColors.textTertiaryColor(isDark),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.videocam_outlined, color: TAColors.textSecondaryColor(isDark)),
            onPressed: () => _startVideoCall(l10n),
          ),
          IconButton(
            icon: Icon(Icons.call_outlined, color: TAColors.textSecondaryColor(isDark)),
            onPressed: () => _startVoiceCall(l10n),
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: TAColors.textSecondaryColor(isDark)),
            onPressed: () => _showChatOptions(isDark, l10n, conversation),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChatState(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat,
            size: 64,
            color: TAColors.textTertiaryColor(isDark),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.startConversation,
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(bool isDark, AppLocalizations l10n, List<Map<String, dynamic>> messages) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      reverse: true,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[messages.length - 1 - index];
        return _buildMessageBubble(isDark, message);
      },
    );
  }

  Widget _buildMessageBubble(bool isDark, Map<String, dynamic> message) {
    final isMe = message['isMe'] as bool;
    
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isMe ? TAColors.primary : TAColors.cardColor(isDark),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                border: isMe ? null : Border.all(color: TAColors.borderColor(isDark)),
              ),
              child: Text(
                message['content'],
                style: TextStyle(
                  color: isMe ? Colors.white : TAColors.textPrimaryColor(isDark),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message['time'] as DateTime),
                  style: TextStyle(
                    color: TAColors.textTertiaryColor(isDark),
                    fontSize: 10,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.done_all,
                    size: 14,
                    color: TAColors.primary,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.attach_file, color: TAColors.textSecondaryColor(isDark)),
            onPressed: () => _showAttachmentOptions(isDark, l10n),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: TAColors.scaffoldColor(isDark),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: TAColors.borderColor(isDark)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: l10n.typeMessage,
                        hintStyle: TextStyle(color: TAColors.textTertiaryColor(isDark)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      style: TextStyle(color: TAColors.textPrimaryColor(isDark)),
                      maxLines: 4,
                      minLines: 1,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.emoji_emotions_outlined, color: TAColors.textSecondaryColor(isDark)),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: TAColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () => _sendMessage(l10n),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'student':
        return TAColors.info;
      case 'instructor':
        return TAColors.success;
      case 'group':
        return TAColors.warning;
      default:
        return TAColors.primary;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inMinutes < 1) return 'Now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return DateFormat('MMM d').format(time);
  }

  void _showNewMessageSheet(bool isDark, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: TAColors.cardColor(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
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
              l10n.newMessage,
              style: TextStyle(
                color: TAColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: l10n.searchStudents,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildRecipientOption(isDark, 'AH', 'Ahmed Hassan', 'Student - CS201'),
                  _buildRecipientOption(isDark, 'SM', 'Sara Mohamed', 'Student - CS201'),
                  _buildRecipientOption(isDark, 'SJ', 'Dr. Sarah Johnson', 'Instructor - ML'),
                  _buildRecipientOption(isDark, 'OA', 'Omar Ali', 'Student - CS301'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipientOption(bool isDark, String avatar, String name, String subtitle) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: TAColors.primaryLight,
        child: Text(avatar, style: const TextStyle(color: TAColors.primary, fontWeight: FontWeight.bold)),
      ),
      title: Text(name, style: TextStyle(color: TAColors.textPrimaryColor(isDark))),
      subtitle: Text(subtitle, style: TextStyle(color: TAColors.textSecondaryColor(isDark))),
      onTap: () => Navigator.pop(context),
    );
  }

  void _showOptionsMenu(bool isDark, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: TAColors.cardColor(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
            _buildOptionTile(isDark, Icons.mark_as_unread, l10n.markAllRead, () => Navigator.pop(context)),
            _buildOptionTile(isDark, Icons.archive, l10n.archivedChats, () => Navigator.pop(context)),
            _buildOptionTile(isDark, Icons.settings, l10n.messageSettings, () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(bool isDark, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: TAColors.primary),
      title: Text(title, style: TextStyle(color: TAColors.textPrimaryColor(isDark))),
      onTap: onTap,
    );
  }

  void _showConversationOptions(bool isDark, AppLocalizations l10n, Map<String, dynamic> conversation) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: TAColors.cardColor(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
            _buildOptionTile(isDark, Icons.push_pin, l10n.pinConversation, () => Navigator.pop(context)),
            _buildOptionTile(isDark, Icons.notifications_off, l10n.muteNotifications, () => Navigator.pop(context)),
            _buildOptionTile(isDark, Icons.archive, l10n.archive, () => Navigator.pop(context)),
            _buildOptionTile(isDark, Icons.delete_outline, l10n.delete, () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }

  void _showChatOptions(bool isDark, AppLocalizations l10n, Map<String, dynamic> conversation) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: TAColors.cardColor(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
            _buildOptionTile(isDark, Icons.person, l10n.viewProfile, () => Navigator.pop(context)),
            _buildOptionTile(isDark, Icons.search, l10n.searchInChat, () => Navigator.pop(context)),
            _buildOptionTile(isDark, Icons.notifications_off, l10n.muteNotifications, () => Navigator.pop(context)),
            _buildOptionTile(isDark, Icons.wallpaper, l10n.chatWallpaper, () => Navigator.pop(context)),
            _buildOptionTile(isDark, Icons.block, l10n.block, () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }

  void _showAttachmentOptions(bool isDark, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: TAColors.cardColor(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachOption(isDark, Icons.image, l10n.photo, () => Navigator.pop(context)),
                _buildAttachOption(isDark, Icons.camera_alt, l10n.camera, () => Navigator.pop(context)),
                _buildAttachOption(isDark, Icons.description, l10n.document, () => Navigator.pop(context)),
                _buildAttachOption(isDark, Icons.location_on, l10n.location, () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachOption(bool isDark, IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TAColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: TAColors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: TAColors.textSecondaryColor(isDark),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.messageSent),
        backgroundColor: TAColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _startVideoCall(AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.startingVideoCall),
        backgroundColor: TAColors.info,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _startVoiceCall(AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.startingVoiceCall),
        backgroundColor: TAColors.info,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
