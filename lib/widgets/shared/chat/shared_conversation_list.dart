import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
  static const int _initialVisibleCount = 50;
  static const int _visibleIncrement = 25;
  static const String _pinnedKey = 'chat_pinned_conversation_ids';
  static const String _mutedKey = 'chat_muted_conversation_ids';
  static const String _hiddenKey = 'chat_hidden_conversation_ids';

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Set<int> _pinnedConversations = <int>{};
  Set<int> _mutedConversations = <int>{};
  Set<int> _hiddenConversations = <int>{};

  int _visibleCount = _initialVisibleCount;
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
        _visibleCount += _visibleIncrement;
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
      _visibleCount = _initialVisibleCount;
    });
    context.read<ChatBloc>().add(SearchConversations(value));
  }

  void _onFilterChanged(ChatListFilter nextFilter) {
    setState(() {
      _currentFilter = nextFilter;
      _visibleCount = _initialVisibleCount;
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

      // Primary sort: by updated time (newest first)
      final timeComparison = right.updatedAt.compareTo(left.updatedAt);
      if (timeComparison != 0) {
        return timeComparison;
      }

      // Secondary sort: by conversation ID for stability
      return right.conversationId.compareTo(left.conversationId);
    });

    if (filtered.length <= _initialVisibleCount ||
        _visibleCount >= filtered.length) {
      return filtered;
    }

    return filtered.take(_visibleCount).toList(growable: false);
  }

  Future<void> _openNewConversationScreen() async {
    final conversationId = await context.push<int>('/messages/new');
    if (conversationId != null && conversationId > 0) {
      await _handleConversationCreated(conversationId);
    }
  }

  Future<void> _handleConversationCreated(int conversationId) async {
    await _unhideConversation(conversationId);
    if (!mounted) {
      return;
    }

    context.read<ChatBloc>().add(SelectConversation(conversationId));
    context.read<ChatBloc>().add(MarkRead(conversationId));
  }

  Future<void> _unhideConversation(int conversationId) async {
    if (!_hiddenConversations.contains(conversationId)) {
      return;
    }

    final updated = Set<int>.from(_hiddenConversations)..remove(conversationId);

    setState(() {
      _hiddenConversations = updated;
    });

    await _persistIds(_hiddenKey, updated);
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
              onConversationCreated: _handleConversationCreated,
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
                      isError: state.status == ChatStatus.failure,
                      isOffline:
                          state.connectionStatus == ConnectionStatus.offline &&
                          state.conversations.isEmpty,
                      searchQuery:
                          state.conversationSearchQuery.trim().isNotEmpty
                          ? state.conversationSearchQuery
                          : null,
                      accentColor: widget.accentColor,
                      onStartNewChat: _openNewConversationScreen,
                      onClearFilters: _clearFilters,
                      onRetry: () => context.read<ChatBloc>().add(
                        const LoadConversations(),
                      ),
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
                            onAvatarTap: conversation.directDisplayUser == null
                                ? null
                                : () {
                                    context.push(
                                      '/messages/profile/${conversation.directDisplayUser!.userId}',
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
