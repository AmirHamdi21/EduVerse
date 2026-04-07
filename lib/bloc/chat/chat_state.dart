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

  /// The message being replied to (for reply context in input bar)
  final ChatMessageModel? replyToMessage;

  /// Set of message IDs hidden locally (delete-for-me, not synced to backend)
  final Set<int> hiddenMessageIds;

  // ============ New Conversation Dialog State (Phase 5) ============

  /// User search results for new conversation dialog (max 20)
  final List<ChatUserModel> newConversationSearchResults;

  /// True while searching for users in new conversation dialog
  final bool userSearchLoading;

  /// Error message if user search fails (null if no error)
  final String? userSearchError;

  /// Last search query (for retry on error)
  final String? lastSearchQuery;

  /// Users selected for the new conversation
  final List<ChatUserModel> selectedParticipants;

  /// Current conversation mode ('direct' or 'group')
  final String conversationMode;

  /// Group name entered by user (required for groups)
  final String? groupNameInput;

  /// Optional first message text
  final String? initialMessageInput;

  /// True while conversation creation API call is in progress
  final bool creatingConversation;

  /// Error message if creation fails (null if no error)
  final String? createConversationError;

  /// ID of conversation just created (triggers navigation)
  final int? newlyCreatedConversationId;

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
    this.replyToMessage,
    this.hiddenMessageIds = const <int>{},
    // New conversation dialog state
    this.newConversationSearchResults = const <ChatUserModel>[],
    this.userSearchLoading = false,
    this.userSearchError,
    this.lastSearchQuery,
    this.selectedParticipants = const <ChatUserModel>[],
    this.conversationMode = 'direct',
    this.groupNameInput,
    this.initialMessageInput,
    this.creatingConversation = false,
    this.createConversationError,
    this.newlyCreatedConversationId,
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
    ChatMessageModel? replyToMessage,
    Set<int>? hiddenMessageIds,
    bool clearActiveConversationId = false,
    bool clearErrorMessage = false,
    bool clearSearchResults = false,
    bool clearReplyToMessage = false,
    // New conversation dialog fields
    List<ChatUserModel>? newConversationSearchResults,
    bool? userSearchLoading,
    String? userSearchError,
    String? lastSearchQuery,
    List<ChatUserModel>? selectedParticipants,
    String? conversationMode,
    String? groupNameInput,
    String? initialMessageInput,
    bool? creatingConversation,
    String? createConversationError,
    int? newlyCreatedConversationId,
    bool clearUserSearchError = false,
    bool clearLastSearchQuery = false,
    bool clearGroupNameInput = false,
    bool clearInitialMessageInput = false,
    bool clearCreateConversationError = false,
    bool clearNewlyCreatedConversationId = false,
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
      replyToMessage: clearReplyToMessage
          ? null
          : replyToMessage ?? this.replyToMessage,
      hiddenMessageIds: hiddenMessageIds ?? this.hiddenMessageIds,
      // New conversation dialog fields
      newConversationSearchResults:
          newConversationSearchResults ?? this.newConversationSearchResults,
      userSearchLoading: userSearchLoading ?? this.userSearchLoading,
      userSearchError: clearUserSearchError
          ? null
          : userSearchError ?? this.userSearchError,
      lastSearchQuery: clearLastSearchQuery
          ? null
          : lastSearchQuery ?? this.lastSearchQuery,
      selectedParticipants: selectedParticipants ?? this.selectedParticipants,
      conversationMode: conversationMode ?? this.conversationMode,
      groupNameInput: clearGroupNameInput
          ? null
          : groupNameInput ?? this.groupNameInput,
      initialMessageInput: clearInitialMessageInput
          ? null
          : initialMessageInput ?? this.initialMessageInput,
      creatingConversation: creatingConversation ?? this.creatingConversation,
      createConversationError: clearCreateConversationError
          ? null
          : createConversationError ?? this.createConversationError,
      newlyCreatedConversationId: clearNewlyCreatedConversationId
          ? null
          : newlyCreatedConversationId ?? this.newlyCreatedConversationId,
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
    replyToMessage,
    _sortedHiddenMessageIds,
    // New conversation dialog fields
    newConversationSearchResults,
    userSearchLoading,
    userSearchError,
    lastSearchQuery,
    selectedParticipants,
    conversationMode,
    groupNameInput,
    initialMessageInput,
    creatingConversation,
    createConversationError,
    newlyCreatedConversationId,
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

  List<int> get _sortedHiddenMessageIds {
    final values = hiddenMessageIds.toList()..sort();
    return values;
  }
}
