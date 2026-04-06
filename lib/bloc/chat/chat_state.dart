import 'package:equatable/equatable.dart';
import 'chat_models.dart';

enum ConnectionStatus { live, offline, connecting }

enum ChatStatus { initial, loading, success, failure }

enum ConversationFilter { all, unread, groups }

class ChatState extends Equatable {
  final List<ConversationModel> conversations;
  final List<ChatMessageModel> activeConversationMessages;
  final int? activeConversationId;
  final ConnectionStatus connectionStatus;
  final Map<int, List<int>> typingUsers;
  final Set<int> onlineUsers;
  final ChatStatus status;
  final String? errorMessage;
  final List<ChatUserModel>? searchResults;
  final bool isLoadingMore;
  final int activePage;
  final String conversationSearchQuery;
  final ConversationFilter conversationFilter;

  const ChatState({
    this.conversations = const <ConversationModel>[],
    this.activeConversationMessages = const <ChatMessageModel>[],
    this.activeConversationId,
    this.connectionStatus = ConnectionStatus.offline,
    this.typingUsers = const <int, List<int>>{},
    this.onlineUsers = const <int>{},
    this.status = ChatStatus.initial,
    this.errorMessage,
    this.searchResults,
    this.isLoadingMore = false,
    this.activePage = 1,
    this.conversationSearchQuery = '',
    this.conversationFilter = ConversationFilter.all,
  });

  ConversationModel? get activeConversation {
    if (activeConversationId == null) {
      return null;
    }

    for (final conversation in conversations) {
      if (conversation.conversationId == activeConversationId) {
        return conversation;
      }
    }

    return null;
  }

  List<ConversationModel> get filteredConversations {
    final normalizedQuery = conversationSearchQuery.trim().toLowerCase();

    Iterable<ConversationModel> filtered = conversations;

    switch (conversationFilter) {
      case ConversationFilter.all:
        break;
      case ConversationFilter.unread:
        filtered = filtered.where(
          (conversation) => conversation.unreadCount > 0,
        );
        break;
      case ConversationFilter.groups:
        filtered = filtered.where(
          (conversation) => conversation.type == ConversationType.group,
        );
        break;
    }

    if (normalizedQuery.isEmpty) {
      return filtered.toList(growable: false);
    }

    return filtered
        .where((conversation) {
          final emailCandidates = <String>[
            if ((conversation.directDisplayUser?.email ?? '').trim().isNotEmpty)
              conversation.directDisplayUser!.email!,
            ...conversation.participantUsers
                .map((user) => user.email ?? '')
                .where((email) => email.trim().isNotEmpty),
          ];

          final textCandidates = <String>[
            conversation.title,
            conversation.lastMessage ?? '',
            conversation.lastMessageInfo?.text ?? '',
            ...conversation.participantUsers.map((user) => user.displayName),
            ...emailCandidates,
          ];

          return textCandidates.any(
            (candidate) => candidate.toLowerCase().contains(normalizedQuery),
          );
        })
        .toList(growable: false);
  }

  ChatState copyWith({
    List<ConversationModel>? conversations,
    List<ChatMessageModel>? activeConversationMessages,
    int? activeConversationId,
    ConnectionStatus? connectionStatus,
    Map<int, List<int>>? typingUsers,
    Set<int>? onlineUsers,
    ChatStatus? status,
    String? errorMessage,
    List<ChatUserModel>? searchResults,
    bool? isLoadingMore,
    int? activePage,
    String? conversationSearchQuery,
    ConversationFilter? conversationFilter,
    bool clearActiveConversationId = false,
    bool clearErrorMessage = false,
    bool clearSearchResults = false,
  }) {
    return ChatState(
      conversations: conversations ?? this.conversations,
      activeConversationMessages:
          activeConversationMessages ?? this.activeConversationMessages,
      activeConversationId: clearActiveConversationId
          ? null
          : activeConversationId ?? this.activeConversationId,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      typingUsers: typingUsers ?? this.typingUsers,
      onlineUsers: onlineUsers ?? this.onlineUsers,
      status: status ?? this.status,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      searchResults: clearSearchResults
          ? null
          : searchResults ?? this.searchResults,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      activePage: activePage ?? this.activePage,
      conversationSearchQuery:
          conversationSearchQuery ?? this.conversationSearchQuery,
      conversationFilter: conversationFilter ?? this.conversationFilter,
    );
  }

  @override
  List<Object?> get props => [
    conversations,
    activeConversationMessages,
    activeConversationId,
    connectionStatus,
    _typingUsersProps,
    _sortedOnlineUsers,
    status,
    errorMessage,
    searchResults,
    isLoadingMore,
    activePage,
    conversationSearchQuery,
    conversationFilter,
  ];

  List<Object> get _typingUsersProps {
    final keys = typingUsers.keys.toList()..sort();
    return keys
        .map((key) {
          final values = [...typingUsers[key] ?? const <int>[]]..sort();
          return '$key:${values.join(',')}';
        })
        .toList(growable: false);
  }

  List<int> get _sortedOnlineUsers {
    final values = onlineUsers.toList()..sort();
    return values;
  }
}
