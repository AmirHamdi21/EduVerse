import 'package:equatable/equatable.dart';
import 'chat_models.dart';
import 'chat_state.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => const [];
}

class LoadConversations extends ChatEvent {
  const LoadConversations();
}

/// Explicitly request an online users refresh from the socket backend.
class RefreshOnlineUsersRequested extends ChatEvent {
  const RefreshOnlineUsersRequested();
}

class SelectConversation extends ChatEvent {
  final int conversationId;

  const SelectConversation(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

/// Clears the active conversation selection (mobile back navigation)
class DeselectConversation extends ChatEvent {
  const DeselectConversation();
}

class LoadMoreMessages extends ChatEvent {
  final int conversationId;
  final int page;

  const LoadMoreMessages({required this.conversationId, required this.page});

  @override
  List<Object?> get props => [conversationId, page];
}

class SendMessage extends ChatEvent {
  final int conversationId;
  final String text;
  final int? replyToId;
  final int? retryMessageId;

  const SendMessage({
    required this.conversationId,
    required this.text,
    this.replyToId,
    this.retryMessageId,
  });

  @override
  List<Object?> get props => [conversationId, text, replyToId, retryMessageId];
}

class RetryFailedMessage extends ChatEvent {
  final int messageId;

  const RetryFailedMessage(this.messageId);

  @override
  List<Object?> get props => [messageId];
}

class SearchUsers extends ChatEvent {
  final String query;
  final int limit;

  const SearchUsers(this.query, {this.limit = 20});

  @override
  List<Object?> get props => [query, limit];
}

class SearchConversations extends ChatEvent {
  final String query;

  const SearchConversations(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterConversations extends ChatEvent {
  final ConversationFilter filter;

  const FilterConversations(this.filter);

  @override
  List<Object?> get props => [filter];
}

class StartNewConversation extends ChatEvent {
  final List<int> participantIds;
  final String type;
  final String? groupName;
  final String? text;
  final int? fileId;

  const StartNewConversation({
    required this.participantIds,
    required this.type,
    this.groupName,
    this.text,
    this.fileId,
  });

  @override
  List<Object?> get props => [participantIds, type, groupName, text, fileId];
}

class DeleteMessage extends ChatEvent {
  final int messageId;
  final bool forEveryone;
  final int? conversationId;

  const DeleteMessage({
    required this.messageId,
    this.forEveryone = false,
    this.conversationId,
  });

  @override
  List<Object?> get props => [messageId, forEveryone, conversationId];
}

class DeleteConversation extends ChatEvent {
  final int conversationId;

  const DeleteConversation(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

class MarkRead extends ChatEvent {
  final int conversationId;

  const MarkRead(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

class TypingChanged extends ChatEvent {
  final int conversationId;
  final bool isTyping;

  const TypingChanged({required this.conversationId, required this.isTyping});

  @override
  List<Object?> get props => [conversationId, isTyping];
}

class WebSocketEventReceived extends ChatEvent {
  final String eventName;
  final dynamic payload;

  const WebSocketEventReceived({required this.eventName, this.payload});

  @override
  List<Object?> get props => [eventName, payload];
}

class ClearChatError extends ChatEvent {
  const ClearChatError();
}

/// Sets or clears the reply context (message being replied to).
/// Pass null to clear the reply context.
class SetReplyContext extends ChatEvent {
  final ChatMessageModel? message;

  const SetReplyContext({this.message});

  @override
  List<Object?> get props => [message];
}

/// Hides a message locally (delete-for-me). Not synced to backend.
class HideMessageLocally extends ChatEvent {
  final int messageId;

  const HideMessageLocally(this.messageId);

  @override
  List<Object?> get props => [messageId];
}

// ============ New Conversation Dialog Events (Phase 5) ============

/// Search for users to add to a new conversation (debounced 400ms)
class ChatSearchUsersRequested extends ChatEvent {
  final String query;

  const ChatSearchUsersRequested(this.query);

  @override
  List<Object?> get props => [query];
}

/// Add a user to the selected participants list
class ChatParticipantAdded extends ChatEvent {
  final ChatUserModel user;

  const ChatParticipantAdded(this.user);

  @override
  List<Object?> get props => [user];
}

/// Remove a user from the selected participants list
class ChatParticipantRemoved extends ChatEvent {
  final int userId;

  const ChatParticipantRemoved(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Change conversation mode between 'direct' and 'group'
class ChatConversationModeChanged extends ChatEvent {
  final String mode;

  const ChatConversationModeChanged(this.mode);

  @override
  List<Object?> get props => [mode];
}

/// Request to create a new conversation with selected participants
class ChatStartConversationRequested extends ChatEvent {
  final List<int> participantIds;
  final List<ChatUserModel> selectedParticipants;
  final String type;
  final String? groupName;
  final String? initialMessage;

  const ChatStartConversationRequested({
    required this.participantIds,
    required this.selectedParticipants,
    required this.type,
    this.groupName,
    this.initialMessage,
  });

  @override
  List<Object?> get props => [
    participantIds,
    selectedParticipants,
    type,
    groupName,
    initialMessage,
  ];
}

/// Reset all new conversation dialog state
class ChatNewConversationDialogReset extends ChatEvent {
  const ChatNewConversationDialogReset();
}
