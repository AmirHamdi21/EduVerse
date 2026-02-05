import 'package:equatable/equatable.dart';
import 'chat_models.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatLoaded extends ChatState {
  final List<Conversation> conversations;
  final List<Conversation> filteredConversations;
  final ChatFilter currentFilter;
  final String searchQuery;
  final Conversation? selectedConversation;
  final List<ChatMessage> currentMessages;
  final bool isLoadingMessages;
  final String? error;
  final bool isSendingMessage;
  final ChatMessage? replyingTo;
  final List<ChatUser> availableUsers;
  final bool isSearchingUsers;

  const ChatLoaded({
    required this.conversations,
    required this.filteredConversations,
    this.currentFilter = ChatFilter.all,
    this.searchQuery = '',
    this.selectedConversation,
    this.currentMessages = const [],
    this.isLoadingMessages = false,
    this.error,
    this.isSendingMessage = false,
    this.replyingTo,
    this.availableUsers = const [],
    this.isSearchingUsers = false,
  });

  ChatLoaded copyWith({
    List<Conversation>? conversations,
    List<Conversation>? filteredConversations,
    ChatFilter? currentFilter,
    String? searchQuery,
    Conversation? selectedConversation,
    bool clearSelectedConversation = false,
    List<ChatMessage>? currentMessages,
    bool? isLoadingMessages,
    String? error,
    bool clearError = false,
    bool? isSendingMessage,
    ChatMessage? replyingTo,
    bool clearReplyingTo = false,
    List<ChatUser>? availableUsers,
    bool? isSearchingUsers,
  }) {
    return ChatLoaded(
      conversations: conversations ?? this.conversations,
      filteredConversations: filteredConversations ?? this.filteredConversations,
      currentFilter: currentFilter ?? this.currentFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedConversation: clearSelectedConversation 
          ? null 
          : selectedConversation ?? this.selectedConversation,
      currentMessages: currentMessages ?? this.currentMessages,
      isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages,
      error: clearError ? null : error ?? this.error,
      isSendingMessage: isSendingMessage ?? this.isSendingMessage,
      replyingTo: clearReplyingTo ? null : replyingTo ?? this.replyingTo,
      availableUsers: availableUsers ?? this.availableUsers,
      isSearchingUsers: isSearchingUsers ?? this.isSearchingUsers,
    );
  }

  @override
  List<Object?> get props => [
        conversations,
        filteredConversations,
        currentFilter,
        searchQuery,
        selectedConversation,
        currentMessages,
        isLoadingMessages,
        error,
        isSendingMessage,
        replyingTo,
        availableUsers,
        isSearchingUsers,
      ];
}

class ChatError extends ChatState {
  final String message;

  const ChatError({required this.message});

  @override
  List<Object?> get props => [message];
}
