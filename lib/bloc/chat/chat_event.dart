import 'package:equatable/equatable.dart';
import 'chat_state.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => const [];
}

class LoadConversations extends ChatEvent {
  const LoadConversations();
}

class SelectConversation extends ChatEvent {
  final int conversationId;

  const SelectConversation(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
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
