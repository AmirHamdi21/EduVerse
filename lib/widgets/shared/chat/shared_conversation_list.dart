import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../bloc/chat/chat_bloc.dart';
import '../../../bloc/chat/chat_event.dart';
import '../../../bloc/chat/chat_models.dart';
import '../../../bloc/chat/chat_state.dart';
import 'chat_list_types.dart';
import 'shared_chat_empty_state.dart';
import 'shared_chat_filter_chips.dart';
import 'shared_chat_header.dart';
import 'shared_chat_search_bar.dart';
import 'shared_conversation_tile.dart';

class SharedConversationList extends StatefulWidget {
  final Color accentColor;
  final bool isDark;
  final String title;
  final IconData? leadingIcon;
  final VoidCallback? onLeadingPressed;

  const SharedConversationList({
    super.key,
    required this.accentColor,
    required this.isDark,
    this.title = 'Messages',
    this.leadingIcon,
    this.onLeadingPressed,
  });

  @override
  State<SharedConversationList> createState() => _SharedConversationListState();
}

class _SharedConversationListState extends State<SharedConversationList> {
  static const int _pageSize = 20;
  static const String _pinnedKey = 'chat_pinned_conversation_ids';
  static const String _mutedKey = 'chat_muted_conversation_ids';
  static const String _hiddenKey = 'chat_hidden_conversation_ids';

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Set<int> _pinnedConversations = <int>{};
  Set<int> _mutedConversations = <int>{};
  Set<int> _hiddenConversations = <int>{};

  int _visibleCount = _pageSize;
  bool _isSearchVisible = false;
  ChatListFilter _currentFilter = ChatListFilter.all;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatBloc>().add(const LoadConversations());
      _loadLocalPreferences();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadLocalPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _pinnedConversations = _parseStoredIds(prefs.getStringList(_pinnedKey));
      _mutedConversations = _parseStoredIds(prefs.getStringList(_mutedKey));
      _hiddenConversations = _parseStoredIds(prefs.getStringList(_hiddenKey));
    });
  }

  Set<int> _parseStoredIds(List<String>? rawIds) {
    if (rawIds == null) {
      return <int>{};
    }

    return rawIds
        .map(int.tryParse)
        .whereType<int>()
        .where((id) => id > 0)
        .toSet();
  }

  Future<void> _persistIds(String key, Set<int> values) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      key,
      values.map((id) => id.toString()).toList(growable: false),
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    if (_scrollController.position.extentAfter < 280) {
      setState(() {
        _visibleCount += _pageSize;
      });
    }
  }

  Future<void> _togglePinned(ConversationModel conversation) async {
    final updated = Set<int>.from(_pinnedConversations);

    if (updated.contains(conversation.conversationId)) {
      updated.remove(conversation.conversationId);
    } else {
      updated.add(conversation.conversationId);
    }

    setState(() {
      _pinnedConversations = updated;
    });

    await _persistIds(_pinnedKey, updated);
  }

  Future<void> _toggleMuted(ConversationModel conversation) async {
    final updated = Set<int>.from(_mutedConversations);

    if (updated.contains(conversation.conversationId)) {
      updated.remove(conversation.conversationId);
    } else {
      updated.add(conversation.conversationId);
    }

    setState(() {
      _mutedConversations = updated;
    });

    await _persistIds(_mutedKey, updated);
  }

  Future<void> _deleteConversation(ConversationModel conversation) async {
    final updated = Set<int>.from(_hiddenConversations)
      ..add(conversation.conversationId);

    setState(() {
      _hiddenConversations = updated;
    });

    await _persistIds(_hiddenKey, updated);

    if (!mounted) {
      return;
    }

    context.read<ChatBloc>().add(
      DeleteConversation(conversation.conversationId),
    );
  }

  void _onQueryChanged(String value) {
    setState(() {
      _visibleCount = _pageSize;
    });
    context.read<ChatBloc>().add(SearchConversations(value));
  }

  void _onFilterChanged(ChatListFilter nextFilter) {
    setState(() {
      _currentFilter = nextFilter;
      _visibleCount = _pageSize;
    });

    context.read<ChatBloc>().add(
      FilterConversations(_toConversationFilter(nextFilter)),
    );
  }

  ConversationFilter _toConversationFilter(ChatListFilter filter) {
    switch (filter) {
      case ChatListFilter.all:
        return ConversationFilter.all;
      case ChatListFilter.unread:
        return ConversationFilter.unread;
      case ChatListFilter.groups:
        return ConversationFilter.groups;
    }
  }

  void _clearFilters() {
    _searchController.clear();
    _onQueryChanged('');
    _onFilterChanged(ChatListFilter.all);
  }

  bool _isConversationOnline(
    ConversationModel conversation,
    Set<int> onlineUsers,
  ) {
    if (conversation.type == ConversationType.group) {
      return false;
    }

    final directId = conversation.directDisplayUser?.userId;
    if (directId != null && onlineUsers.contains(directId)) {
      return true;
    }

    return conversation.participants.any(onlineUsers.contains);
  }

  List<ConversationModel> _orderedVisibleConversations(ChatState state) {
    final filtered = state.filteredConversations
        .where(
          (conversation) =>
              !_hiddenConversations.contains(conversation.conversationId),
        )
        .toList(growable: false);

    filtered.sort((left, right) {
      final leftPinned = _pinnedConversations.contains(left.conversationId);
      final rightPinned = _pinnedConversations.contains(right.conversationId);

      if (leftPinned != rightPinned) {
        return leftPinned ? -1 : 1;
      }

      return right.updatedAt.compareTo(left.updatedAt);
    });

    if (_visibleCount >= filtered.length) {
      return filtered;
    }

    return filtered.take(_visibleCount).toList(growable: false);
  }

  void _openNewConversationModal() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _SharedNewConversationModal(
          isDark: widget.isDark,
          accentColor: widget.accentColor,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state.status == ChatStatus.failure &&
            (state.errorMessage ?? '').trim().isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          context.read<ChatBloc>().add(const ClearChatError());
        }
      },
      builder: (context, state) {
        final allMatches =
            state.filteredConversations
                .where(
                  (conversation) => !_hiddenConversations.contains(
                    conversation.conversationId,
                  ),
                )
                .toList(growable: false)
              ..sort((left, right) {
                final leftPinned = _pinnedConversations.contains(
                  left.conversationId,
                );
                final rightPinned = _pinnedConversations.contains(
                  right.conversationId,
                );

                if (leftPinned != rightPinned) {
                  return leftPinned ? -1 : 1;
                }

                return right.updatedAt.compareTo(left.updatedAt);
              });

        final visibleConversations = _orderedVisibleConversations(state);
        final hasMoreItems = visibleConversations.length < allMatches.length;

        final isFiltered =
            state.conversationSearchQuery.trim().isNotEmpty ||
            _currentFilter != ChatListFilter.all;

        return Column(
          children: [
            SharedChatHeader(
              isDark: widget.isDark,
              accentColor: widget.accentColor,
              connectionStatus: state.connectionStatus,
              isSearching: _isSearchVisible,
              onToggleSearch: () {
                setState(() {
                  _isSearchVisible = !_isSearchVisible;
                  if (!_isSearchVisible) {
                    _clearFilters();
                  }
                });
              },
              onNewChat: _openNewConversationModal,
              title: widget.title,
              leadingIcon: widget.leadingIcon,
              onLeadingPressed: widget.onLeadingPressed,
            ),
            if (_isSearchVisible)
              SharedChatSearchBar(
                controller: _searchController,
                onChanged: _onQueryChanged,
                isDark: widget.isDark,
                accentColor: widget.accentColor,
              ),
            SharedChatFilterChips(
              currentFilter: _currentFilter,
              onFilterChanged: _onFilterChanged,
              isDark: widget.isDark,
              accentColor: widget.accentColor,
            ),
            Expanded(
              child:
                  state.status == ChatStatus.loading &&
                      state.conversations.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : visibleConversations.isEmpty
                  ? SharedChatEmptyState(
                      isDark: widget.isDark,
                      isFiltered: isFiltered,
                      accentColor: widget.accentColor,
                      onStartNewChat: _openNewConversationModal,
                      onClearFilters: _clearFilters,
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        context.read<ChatBloc>().add(const LoadConversations());
                      },
                      child: ListView.separated(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount:
                            visibleConversations.length +
                            (hasMoreItems ? 1 : 0),
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: widget.isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFE2E8F0),
                        ),
                        itemBuilder: (context, index) {
                          if (index >= visibleConversations.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          }

                          final conversation = visibleConversations[index];

                          return SharedConversationTile(
                            conversation: conversation,
                            isDark: widget.isDark,
                            accentColor: widget.accentColor,
                            isOnline: _isConversationOnline(
                              conversation,
                              state.onlineUsers,
                            ),
                            isPinned: _pinnedConversations.contains(
                              conversation.conversationId,
                            ),
                            isMuted: _mutedConversations.contains(
                              conversation.conversationId,
                            ),
                            onTap: () {
                              context.read<ChatBloc>().add(
                                SelectConversation(conversation.conversationId),
                              );
                              context.read<ChatBloc>().add(
                                MarkRead(conversation.conversationId),
                              );
                            },
                            onPin: () => _togglePinned(conversation),
                            onMute: () => _toggleMuted(conversation),
                            onDelete: () => _deleteConversation(conversation),
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _SharedNewConversationModal extends StatefulWidget {
  final bool isDark;
  final Color accentColor;

  const _SharedNewConversationModal({
    required this.isDark,
    required this.accentColor,
  });

  @override
  State<_SharedNewConversationModal> createState() =>
      _SharedNewConversationModalState();
}

class _SharedNewConversationModalState
    extends State<_SharedNewConversationModal> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  List<ChatUserModel> _results = const <ChatUserModel>[];

  @override
  void initState() {
    super.initState();
    final searchResults = context.read<ChatBloc>().state.searchResults;
    if (searchResults != null) {
      _results = searchResults;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _searchUsers(String rawValue) {
    final query = rawValue.trim();
    if (query.isEmpty) {
      setState(() {
        _results = const <ChatUserModel>[];
      });
      return;
    }

    context.read<ChatBloc>().add(SearchUsers(query));
  }

  void _startConversation(ChatUserModel user) {
    final messageText = _messageController.text.trim();

    context.read<ChatBloc>().add(
      StartNewConversation(
        participantIds: <int>[user.userId],
        type: 'direct',
        text: messageText.isEmpty ? null : messageText,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state.searchResults != null) {
          setState(() {
            _results = state.searchResults!;
          });
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.76,
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: widget.isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Text(
                    'New conversation',
                    style: TextStyle(
                      color: widget.isDark
                          ? Colors.white
                          : const Color(0xFF0F172A),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: widget.isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: _searchUsers,
                decoration: const InputDecoration(
                  hintText: 'Search by name or email',
                  prefixIcon: Icon(Icons.search_rounded),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _messageController,
                minLines: 1,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Optional first message',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _results.isEmpty
                  ? Center(
                      child: Text(
                        _searchController.text.trim().isEmpty
                            ? 'Start typing to find users'
                            : 'No users found',
                        style: TextStyle(
                          color: widget.isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: _results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final user = _results[index];
                        return _UserResultTile(
                          user: user,
                          isDark: widget.isDark,
                          accentColor: widget.accentColor,
                          onTap: () => _startConversation(user),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserResultTile extends StatelessWidget {
  final ChatUserModel user;
  final bool isDark;
  final Color accentColor;
  final VoidCallback onTap;

  const _UserResultTile({
    required this.user,
    required this.isDark,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: accentColor,
                child: Text(
                  _initials(user.displayName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if ((user.email ?? '').trim().isNotEmpty)
                      Text(
                        user.email!,
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.chat_bubble_outline_rounded,
                color: isDark
                    ? const Color(0xFFCBD5E1)
                    : const Color(0xFF475569),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _initials(String value) {
    final tokens = value
        .split(RegExp(r'\s+'))
        .where((token) => token.trim().isNotEmpty)
        .toList(growable: false);

    if (tokens.isEmpty) {
      return 'U';
    }

    if (tokens.length == 1) {
      final token = tokens.first;
      return token.length > 1
          ? token.substring(0, 2).toUpperCase()
          : token.toUpperCase();
    }

    return '${tokens.first[0]}${tokens[1][0]}'.toUpperCase();
  }
}
