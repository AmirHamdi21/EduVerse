import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../models/auth_models.dart';
import '../../services/api/chat_service.dart';
import '../../services/api/core_api_client.dart';
import '../../services/chat/chat_socket_service.dart';
import '../../services/storage_service.dart';
import 'chat_event.dart';
import 'chat_models.dart';
import 'chat_state.dart';

/// Debounce transformer for search events.
EventTransformer<E> debounce<E>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

class ChatBloc extends Bloc<ChatEvent, ChatState> with WidgetsBindingObserver {
  final IChatService _chatService;
  final IChatSocketService _chatSocketService;
  final StorageService _storageService;
  final Duration _typingDebounceDuration;

  StreamSubscription<ChatConnectionStatus>? _connectionStatusSubscription;
  StreamSubscription<ChatMessageModel>? _newMessageSubscription;
  StreamSubscription<Set<int>>? _onlineUsersListSubscription;
  StreamSubscription<ChatMessageModel>? _notificationMessageSubscription;
  StreamSubscription<UserTypingEvent>? _typingSubscription;
  StreamSubscription<int>? _messageDeletedSubscription;
  StreamSubscription<ChatMessageModel>? _messageEditedSubscription;
  StreamSubscription<Map<String, dynamic>>? _userStatusSubscription;
  StreamSubscription<int>? _deleteConfirmedSubscription;
  StreamSubscription<MessageReadEvent>? _messageReadSubscription;

  Timer? _typingDebounceTimer;
  bool _hasLifecycleObserver = false;

  final Map<int, _PendingMessage> _failedMessages = <int, _PendingMessage>{};
  int _tempIdCounter = -1;

  factory ChatBloc({
    IChatService? chatService,
    IChatSocketService? chatSocketService,
    StorageService? storageService,
    Duration typingDebounceDuration = const Duration(milliseconds: 1500),
  }) {
    final resolvedStorageService = storageService ?? StorageService();
    final resolvedChatService =
        chatService ??
        ChatService(
          coreApiClient: CoreApiClient(storageService: resolvedStorageService),
        );
    final resolvedSocketService =
        chatSocketService ??
        ChatSocketService(storageService: resolvedStorageService);

    return ChatBloc._(
      chatService: resolvedChatService,
      chatSocketService: resolvedSocketService,
      storageService: resolvedStorageService,
      typingDebounceDuration: typingDebounceDuration,
    );
  }

  ChatBloc._({
    required IChatService chatService,
    required IChatSocketService chatSocketService,
    required StorageService storageService,
    required Duration typingDebounceDuration,
  }) : _chatService = chatService,
       _chatSocketService = chatSocketService,
       _storageService = storageService,
       _typingDebounceDuration = typingDebounceDuration,
       super(const ChatState()) {
    _registerLifecycleObserver();

    on<LoadConversations>(_onLoadConversations);
    on<RefreshOnlineUsersRequested>(_onRefreshOnlineUsersRequested);
    on<SelectConversation>(_onSelectConversation);
    on<DeselectConversation>(_onDeselectConversation);
    on<LoadMoreMessages>(_onLoadMoreMessages);
    on<SendMessage>(_onSendMessage);
    on<RetryFailedMessage>(_onRetryFailedMessage);
    on<SearchUsers>(_onSearchUsers);
    on<SearchConversations>(_onSearchConversations);
    on<FilterConversations>(_onFilterConversations);
    on<StartNewConversation>(_onStartNewConversation);
    on<DeleteMessage>(_onDeleteMessage);
    on<DeleteConversation>(_onDeleteConversation);
    on<MarkRead>(_onMarkRead);
    on<TypingChanged>(_onTypingChanged);
    on<WebSocketEventReceived>(_onWebSocketEventReceived);
    on<ClearChatError>(_onClearChatError);
    on<SetReplyContext>(_onSetReplyContext);
    on<HideMessageLocally>(_onHideMessageLocally);
    on<ClearChatCache>(_onClearChatCache);

    // New conversation dialog event handlers (Phase 5)
    on<ChatSearchUsersRequested>(
      _onChatSearchUsersRequested,
      transformer: debounce(const Duration(milliseconds: 300)),
    );
    on<ChatParticipantAdded>(_onChatParticipantAdded);
    on<ChatParticipantRemoved>(_onChatParticipantRemoved);
    on<ChatConversationModeChanged>(_onChatConversationModeChanged);
    on<ChatStartConversationRequested>(_onChatStartConversationRequested);
    on<ChatNewConversationDialogReset>(_onChatNewConversationDialogReset);

    _subscribeToSocketStreams();
    unawaited(_connectSocket());
  }

  void _registerLifecycleObserver() {
    try {
      WidgetsBinding.instance.addObserver(this);
      _hasLifecycleObserver = true;
    } catch (_) {
      _hasLifecycleObserver = false;
    }
  }

  Future<void> _connectSocket() async {
    final token = (await _storageService.getAccessToken() ?? '').trim();
    _chatSocketService.connect(token);
  }

  void _subscribeToSocketStreams() {
    _connectionStatusSubscription = _chatSocketService.connectionStatus.listen((
      status,
    ) {
      add(
        WebSocketEventReceived(eventName: 'connection_status', payload: status),
      );
    });

    _newMessageSubscription = _chatSocketService.newMessageStream.listen((
      message,
    ) {
      add(WebSocketEventReceived(eventName: 'new_message', payload: message));
    });

    _onlineUsersListSubscription = _chatSocketService.onlineUsersListStream
        .listen((onlineUsers) {
          add(
            WebSocketEventReceived(
              eventName: 'online_users_list',
              payload: onlineUsers,
            ),
          );
        });

    _notificationMessageSubscription = _chatSocketService
        .newMessageNotificationStream
        .listen((message) {
          add(
            WebSocketEventReceived(eventName: 'new_message', payload: message),
          );
        });

    _typingSubscription = _chatSocketService.typingStream.listen((typingEvent) {
      add(
        WebSocketEventReceived(eventName: 'user_typing', payload: typingEvent),
      );
    });

    _messageDeletedSubscription = _chatSocketService.messageDeletedStream
        .listen((messageId) {
          add(
            WebSocketEventReceived(
              eventName: 'message_deleted',
              payload: messageId,
            ),
          );
        });

    _messageEditedSubscription = _chatSocketService.messageEditedStream.listen((
      message,
    ) {
      add(
        WebSocketEventReceived(eventName: 'message_edited', payload: message),
      );
    });

    _userStatusSubscription = _chatSocketService.userStatusStream.listen((
      event,
    ) {
      add(WebSocketEventReceived(eventName: 'user_status', payload: event));
    });

    _deleteConfirmedSubscription = _chatSocketService.deleteConfirmedStream
        .listen((messageId) {
          add(
            WebSocketEventReceived(
              eventName: 'delete_confirmed',
              payload: messageId,
            ),
          );
        });

    _messageReadSubscription = _chatSocketService.messageReadStream.listen((
      event,
    ) {
      add(WebSocketEventReceived(eventName: 'message_read', payload: event));
    });
  }

  Future<void> _onLoadConversations(
    LoadConversations event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(status: ChatStatus.loading, clearErrorMessage: true));

    var emittedCachedData = false;

    try {
      final cachedConversationsJson = await _storageService
          .getCachedConversations();
      if ((cachedConversationsJson ?? '').trim().isNotEmpty &&
          state.conversations.isEmpty) {
        final cachedConversations = _parseCachedConversations(
          cachedConversationsJson!,
        );

        if (cachedConversations.isNotEmpty) {
          final sortedCachedConversations = _sortConversations(
            cachedConversations,
          );
          final cachedParticipantCache =
              _buildParticipantCacheFromConversations(
                sortedCachedConversations,
                seed: state.participantCache,
              );

          emit(
            state.copyWith(
              conversations: sortedCachedConversations,
              frequentlyContacted: _deriveFrequentlyContacted(
                sortedCachedConversations,
              ),
              participantCache: cachedParticipantCache,
              status: ChatStatus.success,
              clearErrorMessage: true,
            ),
          );
          emittedCachedData = true;
        }
      }
    } catch (_) {
      // Ignore malformed cache and continue with network fetch.
    }

    try {
      final conversations = await _chatService.listConversations();
      final sortedConversations = _sortConversations(conversations);
      final participantCache = _buildParticipantCacheFromConversations(
        sortedConversations,
      );

      emit(
        state.copyWith(
          conversations: sortedConversations,
          frequentlyContacted: _deriveFrequentlyContacted(sortedConversations),
          participantCache: participantCache,
          status: ChatStatus.success,
          clearErrorMessage: true,
        ),
      );

      final cacheableConversations = sortedConversations
          .take(200)
          .toList(growable: false);
      final jsonString = jsonEncode(
        cacheableConversations
            .map((conversation) => conversation.toJson())
            .toList(growable: false),
      );
      final didCache = await _storageService.cacheConversations(jsonString);
      if (!didCache) {
        emit(
          state.copyWith(
            errorMessage: 'Storage full — offline mode unavailable',
          ),
        );
      }

      add(const RefreshOnlineUsersRequested());
    } catch (error) {
      if (emittedCachedData || state.conversations.isNotEmpty) {
        emit(state.copyWith(errorMessage: error.toString()));
        return;
      }

      emit(
        state.copyWith(
          status: ChatStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onRefreshOnlineUsersRequested(
    RefreshOnlineUsersRequested event,
    Emitter<ChatState> emit,
  ) async {
    _chatSocketService.requestOnlineUsers();
  }

  Future<void> _onSelectConversation(
    SelectConversation event,
    Emitter<ChatState> emit,
  ) async {
    if (state.activeConversationId != null &&
        state.activeConversationId != event.conversationId) {
      _chatSocketService.leaveConversation(state.activeConversationId!);
    }

    _chatSocketService.joinConversation(event.conversationId);

    emit(
      state.copyWith(
        status: ChatStatus.loading,
        activeConversationId: event.conversationId,
        activeConversationMessages: const <ChatMessageModel>[],
        activePage: 1,
        isLoadingMore: false,
        clearErrorMessage: true,
      ),
    );

    var emittedCachedMessages = false;

    try {
      final cachedMessagesJson = await _storageService.getCachedMessages(
        event.conversationId,
      );

      if ((cachedMessagesJson ?? '').trim().isNotEmpty) {
        final cachedMessages = _parseCachedMessages(cachedMessagesJson!);
        if (cachedMessages.isNotEmpty) {
          final updatedConversations = state.conversations
              .map(
                (conversation) =>
                    conversation.conversationId == event.conversationId
                    ? conversation.copyWith(unreadCount: 0)
                    : conversation,
              )
              .toList(growable: false);

          final sortedCachedMessages = _sortMessages(cachedMessages);
          final nextParticipantCache = _mergeParticipantCacheWithMessages(
            base: _buildParticipantCacheFromConversations(
              updatedConversations,
              seed: state.participantCache,
            ),
            messages: sortedCachedMessages,
          );

          emit(
            state.copyWith(
              conversations: _sortConversations(updatedConversations),
              activeConversationMessages: sortedCachedMessages,
              activeConversationId: event.conversationId,
              activePage: 1,
              participantCache: nextParticipantCache,
              status: ChatStatus.success,
              clearErrorMessage: true,
            ),
          );
          emittedCachedMessages = true;
        }
      }
    } catch (_) {
      // Ignore malformed cache and continue with network fetch.
    }

    try {
      final messages = await _chatService.getConversationMessages(
        event.conversationId,
        page: 1,
      );
      final updatedConversations = state.conversations
          .map(
            (conversation) =>
                conversation.conversationId == event.conversationId
                ? conversation.copyWith(unreadCount: 0)
                : conversation,
          )
          .toList(growable: false);

      final nextParticipantCache = _mergeParticipantCacheWithMessages(
        base: _buildParticipantCacheFromConversations(
          updatedConversations,
          seed: state.participantCache,
        ),
        messages: _sortMessages(messages),
      );

      final sortedMessages = _sortMessages(messages);

      emit(
        state.copyWith(
          conversations: _sortConversations(updatedConversations),
          activeConversationMessages: sortedMessages,
          activeConversationId: event.conversationId,
          activePage: 1,
          participantCache: nextParticipantCache,
          status: ChatStatus.success,
          clearErrorMessage: true,
        ),
      );

      final cacheableMessages = sortedMessages.take(50).toList(growable: false);
      final jsonString = jsonEncode(
        cacheableMessages
            .map((message) => message.toJson())
            .toList(growable: false),
      );
      final didCache = await _storageService.cacheMessages(
        event.conversationId,
        jsonString,
      );
      if (!didCache) {
        emit(
          state.copyWith(
            errorMessage: 'Storage full — offline mode unavailable',
          ),
        );
      }
    } catch (error) {
      if (emittedCachedMessages ||
          state.activeConversationMessages.isNotEmpty) {
        emit(state.copyWith(errorMessage: error.toString()));
        return;
      }

      emit(
        state.copyWith(
          status: ChatStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  /// Clears active conversation (for mobile back navigation)
  void _onDeselectConversation(
    DeselectConversation event,
    Emitter<ChatState> emit,
  ) {
    if (state.activeConversationId != null) {
      _chatSocketService.leaveConversation(state.activeConversationId!);
    }
    emit(
      state.copyWith(
        clearActiveConversationId: true,
        activeConversationMessages: const <ChatMessageModel>[],
      ),
    );
  }

  Future<void> _onLoadMoreMessages(
    LoadMoreMessages event,
    Emitter<ChatState> emit,
  ) async {
    if (state.isLoadingMore ||
        state.activeConversationId != event.conversationId) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true, clearErrorMessage: true));

    try {
      final nextPage = event.page <= 0 ? state.activePage + 1 : event.page;
      final olderMessages = await _chatService.getConversationMessages(
        event.conversationId,
        page: nextPage,
      );

      final mergedMessages = _mergeMessages(
        olderMessages,
        state.activeConversationMessages,
      );

      emit(
        state.copyWith(
          activeConversationMessages: _sortMessages(mergedMessages),
          activePage: nextPage,
          isLoadingMore: false,
          status: ChatStatus.success,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoadingMore: false,
          status: ChatStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    final trimmedText = event.text.trim();
    if (trimmedText.isEmpty) {
      return;
    }

    final currentUser = await _storageService.getUserData();
    final localMessageId = event.retryMessageId ?? _nextTempMessageId();

    final optimisticMessage = ChatMessageModel(
      id: localMessageId,
      text: trimmedText,
      senderId: currentUser?.userId ?? 0,
      senderName: _resolveSenderName(currentUser),
      sentAt: DateTime.now().toUtc(),
      replyToId: event.replyToId,
      conversationId: event.conversationId,
      status: 'sending',
    );

    final pendingMessage = _PendingMessage(
      localMessageId: localMessageId,
      conversationId: event.conversationId,
      text: trimmedText,
      replyToId: event.replyToId,
    );

    _failedMessages[localMessageId] = pendingMessage;

    final optimisticList = event.retryMessageId == null
        ? [...state.activeConversationMessages, optimisticMessage]
        : state.activeConversationMessages
              .map(
                (message) => message.id == event.retryMessageId
                    ? optimisticMessage
                    : message,
              )
              .toList(growable: false);

    emit(
      state.copyWith(
        activeConversationMessages: _sortMessages(optimisticList),
        status: ChatStatus.success,
        clearErrorMessage: true,
      ),
    );

    ChatMessageModel? confirmedMessage;

    try {
      if (state.connectionStatus == ConnectionStatus.live) {
        _chatSocketService.sendMessage(
          event.conversationId,
          trimmedText,
          replyToId: event.replyToId,
        );
        confirmedMessage = optimisticMessage.copyWith(status: 'sent');
      } else {
        confirmedMessage = await _chatService.sendMessage(
          event.conversationId,
          trimmedText,
          replyToId: event.replyToId,
        );
      }
    } catch (_) {
      try {
        confirmedMessage = await _chatService.sendMessage(
          event.conversationId,
          trimmedText,
          replyToId: event.replyToId,
        );
      } catch (error) {
        final failedMessage = optimisticMessage.copyWith(status: 'failed');
        final updatedFailedList = _replaceById(
          state.activeConversationMessages,
          failedMessage,
        );

        emit(
          state.copyWith(
            activeConversationMessages: updatedFailedList,
            status: ChatStatus.failure,
            errorMessage: error.toString(),
          ),
        );
        return;
      }
    }

    final resolvedMessage = confirmedMessage.copyWith(status: 'sent');
    _failedMessages.remove(localMessageId);

    final updatedMessages = _replaceByTempOrAppend(
      state.activeConversationMessages,
      localMessageId,
      resolvedMessage,
    );

    final updatedConversations = _upsertConversationWithMessage(
      state.conversations,
      resolvedMessage,
      incrementUnread: false,
    );

    emit(
      state.copyWith(
        activeConversationMessages: _sortMessages(updatedMessages),
        conversations: _sortConversations(updatedConversations),
        status: ChatStatus.success,
        clearErrorMessage: true,
      ),
    );
  }

  Future<void> _onRetryFailedMessage(
    RetryFailedMessage event,
    Emitter<ChatState> emit,
  ) async {
    final pending = _failedMessages[event.messageId];
    if (pending == null) {
      return;
    }

    add(
      SendMessage(
        conversationId: pending.conversationId,
        text: pending.text,
        replyToId: pending.replyToId,
        retryMessageId: pending.localMessageId,
      ),
    );
  }

  Future<void> _onSearchUsers(
    SearchUsers event,
    Emitter<ChatState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(state.copyWith(clearSearchResults: true));
      return;
    }

    emit(state.copyWith(status: ChatStatus.loading, clearErrorMessage: true));

    try {
      final results = await _chatService.searchUsers(query, limit: event.limit);
      emit(
        state.copyWith(
          searchResults: results,
          status: ChatStatus.success,
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ChatStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onSearchConversations(
    SearchConversations event,
    Emitter<ChatState> emit,
  ) async {
    emit(
      state.copyWith(
        conversationSearchQuery: event.query,
        clearErrorMessage: true,
      ),
    );
  }

  Future<void> _onFilterConversations(
    FilterConversations event,
    Emitter<ChatState> emit,
  ) async {
    emit(
      state.copyWith(conversationFilter: event.filter, clearErrorMessage: true),
    );
  }

  Future<void> _onStartNewConversation(
    StartNewConversation event,
    Emitter<ChatState> emit,
  ) async {
    final localExisting = _findExistingConversation(
      state.conversations,
      participantIds: event.participantIds,
      type: event.type,
    );

    if (localExisting != null) {
      add(SelectConversation(localExisting.conversationId));
      return;
    }

    emit(state.copyWith(status: ChatStatus.loading, clearErrorMessage: true));

    try {
      final created = await _chatService.startConversation(
        participantIds: event.participantIds,
        type: event.type,
        groupName: event.groupName,
        text: event.text,
        fileId: event.fileId,
      );

      final existingById = state.conversations.where(
        (conversation) => conversation.conversationId == created.conversationId,
      );
      final selectedConversation = existingById.isNotEmpty
          ? existingById.first
          : created;

      final updatedConversations = _upsertConversation(
        state.conversations,
        selectedConversation,
      );

      emit(
        state.copyWith(
          conversations: _sortConversations(updatedConversations),
          activeConversationId: selectedConversation.conversationId,
          status: ChatStatus.success,
          clearErrorMessage: true,
        ),
      );

      add(SelectConversation(selectedConversation.conversationId));
    } catch (error) {
      emit(
        state.copyWith(
          status: ChatStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteMessage(
    DeleteMessage event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final deleted = event.forEveryone
          ? await _chatService.deleteForEveryone(event.messageId)
          : await _chatService.deleteForMe(event.messageId);

      if (!deleted) {
        throw Exception('Unable to delete message ${event.messageId}.');
      }

      _chatSocketService.deleteMessage(
        event.messageId,
        forEveryone: event.forEveryone,
      );

      final updatedMessages = state.activeConversationMessages
          .where((message) => message.id != event.messageId)
          .toList(growable: false);

      emit(
        state.copyWith(
          activeConversationMessages: updatedMessages,
          status: ChatStatus.success,
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ChatStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteConversation(
    DeleteConversation event,
    Emitter<ChatState> emit,
  ) async {
    final updatedConversations = state.conversations
        .where(
          (conversation) => conversation.conversationId != event.conversationId,
        )
        .toList(growable: false);

    final wasActiveConversation =
        state.activeConversationId == event.conversationId;

    if (wasActiveConversation) {
      _chatSocketService.leaveConversation(event.conversationId);
    }

    emit(
      state.copyWith(
        conversations: _sortConversations(updatedConversations),
        activeConversationMessages: wasActiveConversation
            ? const <ChatMessageModel>[]
            : state.activeConversationMessages,
        clearActiveConversationId: wasActiveConversation,
        status: ChatStatus.success,
        clearErrorMessage: true,
      ),
    );
  }

  Future<void> _onMarkRead(MarkRead event, Emitter<ChatState> emit) async {
    try {
      final targetConversation = state.conversations.where(
        (conversation) => conversation.conversationId == event.conversationId,
      );

      final markerId = state.activeConversationMessages.isNotEmpty
          ? state.activeConversationMessages.last.id
          : (targetConversation.isNotEmpty
                ? targetConversation.first.lastMessageInfo?.id
                : null);

      if (markerId != null && markerId > 0) {
        await _chatService.markRead(markerId);
      }

      _chatSocketService.markRead(event.conversationId);

      final updatedConversations = state.conversations
          .map(
            (conversation) =>
                conversation.conversationId == event.conversationId
                ? conversation.copyWith(unreadCount: 0)
                : conversation,
          )
          .toList(growable: false);

      emit(
        state.copyWith(
          conversations: _sortConversations(updatedConversations),
          status: ChatStatus.success,
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ChatStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onTypingChanged(
    TypingChanged event,
    Emitter<ChatState> emit,
  ) async {
    _chatSocketService.emitTyping(event.conversationId, event.isTyping);

    if (event.isTyping) {
      _typingDebounceTimer?.cancel();
      _typingDebounceTimer = Timer(_typingDebounceDuration, () {
        add(
          TypingChanged(conversationId: event.conversationId, isTyping: false),
        );
      });
    }
  }

  Future<void> _onWebSocketEventReceived(
    WebSocketEventReceived event,
    Emitter<ChatState> emit,
  ) async {
    switch (event.eventName) {
      case 'connection_status':
        final nextStatus = _mapConnectionStatus(event.payload);
        emit(state.copyWith(connectionStatus: nextStatus));
        if (nextStatus == ConnectionStatus.live) {
          add(const RefreshOnlineUsersRequested());
        }
        return;
      case 'new_message':
        final message = event.payload is ChatMessageModel
            ? event.payload as ChatMessageModel
            : ChatMessageModel.fromSocketPayload(event.payload);

        final mergedMessages =
            state.activeConversationId == message.conversationId
            ? _mergeIncomingWithOptimistic(
                state.activeConversationMessages,
                message,
              )
            : state.activeConversationMessages;

        final updatedConversations = _upsertConversationWithMessage(
          state.conversations,
          message,
          incrementUnread: state.activeConversationId != message.conversationId,
        );

        final nextParticipantCache = _upsertParticipantFromMessage(
          state.participantCache,
          message,
        );

        emit(
          state.copyWith(
            conversations: _sortConversations(updatedConversations),
            activeConversationMessages: _sortMessages(mergedMessages),
            participantCache: nextParticipantCache,
            status: ChatStatus.success,
          ),
        );
        return;
      case 'user_typing':
        final typingEvent = event.payload is UserTypingEvent
            ? event.payload as UserTypingEvent
            : UserTypingEvent.fromJson(
                Map<String, dynamic>.from(event.payload as Map),
              );

        final updatedTypingUsers = Map<int, List<int>>.from(state.typingUsers);
        final currentUsers = [
          ...updatedTypingUsers[typingEvent.conversationId] ?? const <int>[],
        ];

        if (typingEvent.isTyping) {
          if (!currentUsers.contains(typingEvent.userId)) {
            currentUsers.add(typingEvent.userId);
          }
        } else {
          currentUsers.removeWhere((userId) => userId == typingEvent.userId);
        }

        updatedTypingUsers[typingEvent.conversationId] = currentUsers;
        emit(state.copyWith(typingUsers: updatedTypingUsers));
        return;
      case 'message_deleted':
      case 'delete_confirmed':
        final messageId = _extractMessageId(event.payload);
        if (messageId <= 0) {
          return;
        }

        final updatedMessages = state.activeConversationMessages
            .where((message) => message.id != messageId)
            .toList(growable: false);

        emit(
          state.copyWith(
            activeConversationMessages: updatedMessages,
            status: ChatStatus.success,
          ),
        );
        return;
      case 'message_edited':
        final editedMessage = event.payload is ChatMessageModel
            ? event.payload as ChatMessageModel
            : ChatMessageModel.fromSocketPayload(event.payload);

        final updatedMessages = _replaceById(
          state.activeConversationMessages,
          editedMessage,
        );

        final updatedConversations = _upsertConversationWithMessage(
          state.conversations,
          editedMessage,
          incrementUnread: false,
        );

        final nextParticipantCache = _upsertParticipantFromMessage(
          state.participantCache,
          editedMessage,
        );

        emit(
          state.copyWith(
            conversations: _sortConversations(updatedConversations),
            activeConversationMessages: _sortMessages(updatedMessages),
            participantCache: nextParticipantCache,
            status: ChatStatus.success,
          ),
        );
        return;
      case 'user_status':
        final statusMap = Map<String, dynamic>.from(event.payload as Map);
        final userId = _parseInt(statusMap['userId']);
        if (userId <= 0) {
          return;
        }

        final nextOnlineUsers = Set<int>.from(state.onlineUsers);
        final nextLastSeen = Map<int, DateTime>.from(state.userLastSeen);
        final isOnline = _parseBool(statusMap['isOnline']);
        if (isOnline) {
          nextOnlineUsers.add(userId);
          nextLastSeen.remove(userId);
        } else {
          nextOnlineUsers.remove(userId);
          final lastSeen = _parseDateTime(statusMap['lastSeen']);
          if (lastSeen != null) {
            nextLastSeen[userId] = lastSeen;
          }
        }

        emit(
          state.copyWith(
            onlineUsers: nextOnlineUsers,
            userLastSeen: nextLastSeen,
          ),
        );
        return;
      case 'online_users_list':
        final incoming = event.payload;
        final updatedOnlineUsers = <int>{};
        if (incoming is Set<int>) {
          updatedOnlineUsers.addAll(incoming);
        } else if (incoming is List) {
          for (final value in incoming) {
            final id = _parseInt(value);
            if (id > 0) {
              updatedOnlineUsers.add(id);
            }
          }
        } else if (incoming is Map) {
          final map = Map<String, dynamic>.from(incoming);
          final values = map['data'] ?? map['onlineUsers'] ?? map['users'];
          if (values is List) {
            for (final value in values) {
              if (value is Map) {
                final nested = Map<String, dynamic>.from(value);
                final id = _parseInt(nested['userId'] ?? nested['id']);
                if (id > 0) {
                  updatedOnlineUsers.add(id);
                }
              } else {
                final id = _parseInt(value);
                if (id > 0) {
                  updatedOnlineUsers.add(id);
                }
              }
            }
          }
        }
        emit(state.copyWith(onlineUsers: updatedOnlineUsers));
        return;
      case 'message_read':
        final readEvent = event.payload is MessageReadEvent
            ? event.payload as MessageReadEvent
            : MessageReadEvent.fromJson(
                Map<String, dynamic>.from(event.payload as Map),
              );

        final updatedMessages = state.activeConversationMessages
            .map(
              (message) => message.id == readEvent.messageId
                  ? message.copyWith(status: 'read')
                  : message,
            )
            .toList(growable: false);

        emit(
          state.copyWith(
            activeConversationMessages: updatedMessages,
            status: ChatStatus.success,
          ),
        );
        return;
      default:
        return;
    }
  }

  Future<void> _onClearChatError(
    ClearChatError event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(clearErrorMessage: true));
  }

  /// Sets or clears the reply context (the message being replied to).
  void _onSetReplyContext(SetReplyContext event, Emitter<ChatState> emit) {
    if (event.message == null) {
      emit(state.copyWith(clearReplyToMessage: true));
    } else {
      emit(state.copyWith(replyToMessage: event.message));
    }
  }

  /// Hides a message locally (delete-for-me). Not synced to backend.
  void _onHideMessageLocally(
    HideMessageLocally event,
    Emitter<ChatState> emit,
  ) {
    final updatedHiddenIds = Set<int>.from(state.hiddenMessageIds)
      ..add(event.messageId);
    emit(state.copyWith(hiddenMessageIds: updatedHiddenIds));
  }

  Future<void> _onClearChatCache(
    ClearChatCache event,
    Emitter<ChatState> emit,
  ) async {
    await _storageService.clearChatCache();
    emit(const ChatState());
  }

  ConnectionStatus _mapConnectionStatus(dynamic status) {
    if (status is! ChatConnectionStatus) {
      return ConnectionStatus.offline;
    }

    switch (status) {
      case ChatConnectionStatus.connected:
        return ConnectionStatus.live;
      case ChatConnectionStatus.reconnecting:
        return ConnectionStatus.connecting;
      case ChatConnectionStatus.disconnected:
        return ConnectionStatus.offline;
    }
  }

  List<ConversationModel> _sortConversations(
    List<ConversationModel> conversations,
  ) {
    final sorted = [...conversations];
    sorted.sort((first, second) => second.updatedAt.compareTo(first.updatedAt));
    return sorted;
  }

  /// Sort messages with newest first (descending order).
  /// Combined with ListView.reverse=true, this displays newest at bottom (WhatsApp-style).
  List<ChatMessageModel> _sortMessages(List<ChatMessageModel> messages) {
    final sorted = [...messages];
    sorted.sort((first, second) => second.sentAt.compareTo(first.sentAt));
    return sorted;
  }

  List<ConversationModel> _parseCachedConversations(String jsonString) {
    final decoded = jsonDecode(jsonString);
    if (decoded is! List) {
      return const <ConversationModel>[];
    }

    return decoded
        .whereType<Map>()
        .map(
          (item) => ConversationModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .where((conversation) => conversation.conversationId > 0)
        .toList(growable: false);
  }

  List<ChatMessageModel> _parseCachedMessages(String jsonString) {
    final decoded = jsonDecode(jsonString);
    if (decoded is! List) {
      return const <ChatMessageModel>[];
    }

    return decoded
        .whereType<Map>()
        .map(
          (item) => ChatMessageModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .where((message) => message.id != 0)
        .toList(growable: false);
  }

  List<ChatUserModel> _deriveFrequentlyContacted(
    List<ConversationModel> conversations,
  ) {
    final byUserId = <int, ChatUserModel>{};
    final sorted = _sortConversations(conversations);

    for (final conversation in sorted) {
      if (conversation.type != ConversationType.direct) {
        continue;
      }

      final candidate =
          conversation.directDisplayUser ??
          conversation.participantUsers.firstOrNull;
      if (candidate == null) {
        continue;
      }

      byUserId.putIfAbsent(candidate.userId, () => candidate);
      if (byUserId.length >= 5) {
        break;
      }
    }

    return byUserId.values.toList(growable: false);
  }

  Map<int, ChatUserModel> _buildParticipantCacheFromConversations(
    List<ConversationModel> conversations, {
    Map<int, ChatUserModel>? seed,
  }) {
    final cache = <int, ChatUserModel>{if (seed != null) ...seed};

    for (final conversation in conversations) {
      final directUser = conversation.directDisplayUser;
      if (directUser != null && directUser.userId > 0) {
        cache[directUser.userId] = directUser;
      }

      for (final participant in conversation.participantUsers) {
        if (participant.userId > 0) {
          cache[participant.userId] = participant;
        }
      }

      final lastMessage = conversation.lastMessageInfo;
      if (lastMessage != null) {
        final updated = _upsertParticipantFromMessage(cache, lastMessage);
        if (!identical(updated, cache)) {
          cache
            ..clear()
            ..addAll(updated);
        }
      }
    }

    return cache;
  }

  Map<int, ChatUserModel> _mergeParticipantCacheWithMessages({
    required Map<int, ChatUserModel> base,
    required List<ChatMessageModel> messages,
  }) {
    var current = Map<int, ChatUserModel>.from(base);
    for (final message in messages) {
      current = _upsertParticipantFromMessage(current, message);
    }
    return current;
  }

  Map<int, ChatUserModel> _upsertParticipantFromMessage(
    Map<int, ChatUserModel> cache,
    ChatMessageModel message,
  ) {
    final senderId = message.senderId;
    if (senderId <= 0) {
      return cache;
    }

    final senderName = message.senderName?.trim();
    final existing = cache[senderId];
    if ((senderName == null || senderName.isEmpty) && existing != null) {
      return cache;
    }

    final tokens = (senderName ?? '').split(RegExp(r'\s+'))
      ..removeWhere((entry) => entry.trim().isEmpty);

    final firstName = tokens.isNotEmpty ? tokens.first : existing?.firstName;
    final lastName = tokens.length > 1
        ? tokens.sublist(1).join(' ')
        : existing?.lastName;

    final next = Map<int, ChatUserModel>.from(cache);
    next[senderId] = ChatUserModel(
      userId: senderId,
      firstName: firstName,
      lastName: lastName,
      fullName: senderName ?? existing?.fullName,
      email: existing?.email,
      role: existing?.role,
    );
    return next;
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value is DateTime) {
      return value.toUtc();
    }
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value)?.toUtc();
    }
    return null;
  }

  List<ChatMessageModel> _mergeMessages(
    List<ChatMessageModel> first,
    List<ChatMessageModel> second,
  ) {
    final byId = <int, ChatMessageModel>{
      for (final message in second) message.id: message,
    };
    for (final message in first) {
      byId[message.id] = message;
    }
    return byId.values.toList(growable: false);
  }

  List<ConversationModel> _upsertConversation(
    List<ConversationModel> conversations,
    ConversationModel conversation,
  ) {
    final index = conversations.indexWhere(
      (entry) => entry.conversationId == conversation.conversationId,
    );

    if (index == -1) {
      return [...conversations, conversation];
    }

    final copy = [...conversations];
    copy[index] = conversation;
    return copy;
  }

  List<ConversationModel> _upsertConversationWithMessage(
    List<ConversationModel> conversations,
    ChatMessageModel message, {
    required bool incrementUnread,
  }) {
    final index = conversations.indexWhere(
      (conversation) => conversation.conversationId == message.conversationId,
    );

    if (index == -1) {
      return conversations;
    }

    final target = conversations[index];
    final updated = target.copyWith(
      lastMessage: message.isDeleted ? message.deletedText : message.text,
      lastMessageInfo: message,
      lastMessageAt: message.sentAt,
      unreadCount: incrementUnread
          ? target.unreadCount + 1
          : target.unreadCount,
    );

    final copy = [...conversations];
    copy[index] = updated;
    return copy;
  }

  List<ChatMessageModel> _replaceById(
    List<ChatMessageModel> messages,
    ChatMessageModel nextMessage,
  ) {
    final index = messages.indexWhere(
      (message) => message.id == nextMessage.id,
    );
    if (index == -1) {
      return [...messages, nextMessage];
    }

    final copy = [...messages];
    copy[index] = nextMessage;
    return copy;
  }

  List<ChatMessageModel> _replaceByTempOrAppend(
    List<ChatMessageModel> messages,
    int tempId,
    ChatMessageModel nextMessage,
  ) {
    final tempIndex = messages.indexWhere((message) => message.id == tempId);
    if (tempIndex != -1) {
      final copy = [...messages];
      copy[tempIndex] = nextMessage;
      return copy;
    }

    return _replaceById(messages, nextMessage);
  }

  List<ChatMessageModel> _mergeIncomingWithOptimistic(
    List<ChatMessageModel> messages,
    ChatMessageModel incoming,
  ) {
    final byIdMatch = messages.indexWhere(
      (message) => message.id == incoming.id,
    );
    if (byIdMatch != -1) {
      final copy = [...messages];
      copy[byIdMatch] = incoming;
      return copy;
    }

    final optimisticIndex = messages.indexWhere(
      (message) =>
          message.id < 0 &&
          message.conversationId == incoming.conversationId &&
          message.text == incoming.text &&
          (message.status == 'sending' || message.status == 'sent'),
    );

    if (optimisticIndex != -1) {
      final copy = [...messages];
      copy[optimisticIndex] = incoming;
      return copy;
    }

    return [...messages, incoming];
  }

  ConversationModel? _findExistingConversation(
    List<ConversationModel> conversations, {
    required List<int> participantIds,
    required String type,
  }) {
    final normalizedType = ConversationType.fromJsonValue(type);
    if (normalizedType == ConversationType.group) {
      return null;
    }

    final participantSet = Set<int>.from(participantIds);

    for (final conversation in conversations) {
      if (conversation.type != ConversationType.direct) {
        continue;
      }

      final existingSet = Set<int>.from(conversation.participants);
      if (participantSet.containsAll(existingSet) ||
          existingSet.containsAll(participantSet)) {
        return conversation;
      }
    }

    return null;
  }

  int _extractMessageId(dynamic payload) {
    if (payload is int) {
      return payload;
    }

    if (payload is Map<String, dynamic>) {
      return _parseInt(payload['messageId'] ?? payload['id']);
    }

    if (payload is Map) {
      final casted = payload.map(
        (key, value) => MapEntry(key.toString(), value),
      );
      return _parseInt(casted['messageId'] ?? casted['id']);
    }

    return 0;
  }

  int _nextTempMessageId() {
    _tempIdCounter -= 1;
    return _tempIdCounter;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      add(const RefreshOnlineUsersRequested());
    }
  }

  String _resolveSenderName(UserDto? currentUser) {
    if (currentUser == null) {
      return 'Me';
    }
    final firstName = currentUser.firstName.trim();
    final lastName = currentUser.lastName.trim();
    final fullName = '$firstName $lastName'.trim();
    return fullName.isEmpty ? 'Me' : fullName;
  }

  int _parseInt(dynamic value, {int fallback = 0}) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  bool _parseBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == '1' || normalized == 'true' || normalized == 'yes';
    }
    return false;
  }

  // ============ New Conversation Dialog Event Handlers (Phase 5) ============

  /// Handle user search request with debounced 400ms delay
  Future<void> _onChatSearchUsersRequested(
    ChatSearchUsersRequested event,
    Emitter<ChatState> emit,
  ) async {
    final query = event.query.trim();

    // Clear results if query is empty
    if (query.isEmpty) {
      emit(
        state.copyWith(
          newConversationSearchResults: const <ChatUserModel>[],
          contactSearchResults: const <ChatUserModel>[],
          userSearchLoading: false,
          clearUserSearchError: true,
          clearLastSearchQuery: true,
        ),
      );
      return;
    }

    // Store query for retry and show loading
    emit(
      state.copyWith(
        userSearchLoading: true,
        lastSearchQuery: query,
        clearUserSearchError: true,
      ),
    );

    try {
      final results = await _chatService.searchUsers(query, limit: 20);

      // Sort results by relevance:
      // 1. Exact email match
      // 2. Partial email match
      // 3. Name match
      // 4. Alphabetical by displayName
      final sortedResults = _sortSearchResults(results, query);

      emit(
        state.copyWith(
          newConversationSearchResults: sortedResults,
          contactSearchResults: sortedResults,
          userSearchLoading: false,
          clearUserSearchError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          userSearchLoading: false,
          userSearchError: 'Failed to search users. Please try again.',
        ),
      );
    }
  }

  /// Sort search results by relevance (exact email > partial email > name > alphabetical)
  List<ChatUserModel> _sortSearchResults(
    List<ChatUserModel> results,
    String query,
  ) {
    final normalizedQuery = query.toLowerCase();

    return [...results]..sort((a, b) {
      final aEmail = (a.email ?? '').toLowerCase();
      final bEmail = (b.email ?? '').toLowerCase();
      final aName = a.displayName.toLowerCase();
      final bName = b.displayName.toLowerCase();

      // Priority 1: Exact email match
      final aExactEmail = aEmail == normalizedQuery;
      final bExactEmail = bEmail == normalizedQuery;
      if (aExactEmail && !bExactEmail) return -1;
      if (bExactEmail && !aExactEmail) return 1;

      // Priority 2: Partial email match (starts with)
      final aPartialEmail = aEmail.startsWith(normalizedQuery);
      final bPartialEmail = bEmail.startsWith(normalizedQuery);
      if (aPartialEmail && !bPartialEmail) return -1;
      if (bPartialEmail && !aPartialEmail) return 1;

      // Priority 3: Email contains query
      final aEmailContains = aEmail.contains(normalizedQuery);
      final bEmailContains = bEmail.contains(normalizedQuery);
      if (aEmailContains && !bEmailContains) return -1;
      if (bEmailContains && !aEmailContains) return 1;

      // Priority 4: Name match
      final aNameContains = aName.contains(normalizedQuery);
      final bNameContains = bName.contains(normalizedQuery);
      if (aNameContains && !bNameContains) return -1;
      if (bNameContains && !aNameContains) return 1;

      // Priority 5: Alphabetical by displayName
      return aName.compareTo(bName);
    });
  }

  /// Handle adding a participant to selected list
  void _onChatParticipantAdded(
    ChatParticipantAdded event,
    Emitter<ChatState> emit,
  ) {
    final existingIds = state.selectedParticipants
        .map((user) => user.userId)
        .toSet();

    // Prevent adding duplicate
    if (existingIds.contains(event.user.userId)) {
      return;
    }

    final updatedParticipants = [...state.selectedParticipants, event.user];

    emit(
      state.copyWith(
        selectedParticipants: updatedParticipants,
        newConversationSearchResults: const <ChatUserModel>[],
        contactSearchResults: const <ChatUserModel>[],
        clearUserSearchError: true,
      ),
    );
  }

  /// Handle removing a participant from selected list
  void _onChatParticipantRemoved(
    ChatParticipantRemoved event,
    Emitter<ChatState> emit,
  ) {
    final updatedParticipants = state.selectedParticipants
        .where((user) => user.userId != event.userId)
        .toList();

    emit(state.copyWith(selectedParticipants: updatedParticipants));
  }

  /// Handle conversation mode change (direct/group)
  void _onChatConversationModeChanged(
    ChatConversationModeChanged event,
    Emitter<ChatState> emit,
  ) {
    emit(
      state.copyWith(
        conversationMode: event.mode,
        clearCreateConversationError: true,
      ),
    );
  }

  /// Handle starting a new conversation
  Future<void> _onChatStartConversationRequested(
    ChatStartConversationRequested event,
    Emitter<ChatState> emit,
  ) async {
    // Get current user to filter them out of participant count for group validation
    final currentUser = await _storageService.getUserData();
    final currentUserId = currentUser?.userId ?? 0;

    // Filter out current user from participant IDs for group validation
    final otherParticipantIds = event.participantIds
        .where((id) => id != currentUserId)
        .toList();

    // Validation: Check if participants list is empty
    if (event.participantIds.isEmpty) {
      emit(
        state.copyWith(
          createConversationError: 'At least one participant required',
        ),
      );
      return;
    }

    // Validation for direct mode: exactly 1 participant (can be self or other)
    if (event.type == 'direct' && event.participantIds.length != 1) {
      emit(
        state.copyWith(
          createConversationError:
              'Direct conversations require exactly 1 participant',
        ),
      );
      return;
    }

    // Validation for group mode: at least 2 other participants (total 3 including you)
    if (event.type == 'group') {
      if (otherParticipantIds.length < 2) {
        emit(
          state.copyWith(
            createConversationError:
                'Groups require at least 2 other participants (3 total including you)',
          ),
        );
        return;
      }

      // Validate group name
      if (event.groupName == null || event.groupName!.trim().isEmpty) {
        emit(state.copyWith(createConversationError: 'Group name is required'));
        return;
      }
    }

    // For direct conversations, check if one already exists with this participant
    if (event.type == 'direct' && otherParticipantIds.length == 1) {
      final targetUserId = otherParticipantIds.first;
      final existingConversation = state.conversations.firstWhere(
        (c) =>
            c.type == ConversationType.direct &&
            c.participants.contains(targetUserId),
        orElse: () => ConversationModel(
          conversationId: -1,
          type: ConversationType.direct,
        ),
      );

      if (existingConversation.conversationId > 0) {
        // Existing conversation found - navigate to it instead of creating new
        emit(
          state.copyWith(
            creatingConversation: false,
            newlyCreatedConversationId: existingConversation.conversationId,
          ),
        );
        return;
      }
    }

    // Show loading state
    emit(
      state.copyWith(
        creatingConversation: true,
        clearCreateConversationError: true,
      ),
    );

    try {
      final conversation = await _chatService.startConversation(
        participantIds: event.participantIds,
        type: event.type,
        groupName: event.groupName,
        text: event.initialMessage,
      );

      // Enhance conversation with directDisplayUser if missing for direct chats
      ConversationModel enhancedConversation = conversation;
      if (event.type == 'direct' &&
          conversation.directDisplayUser == null &&
          event.selectedParticipants.isNotEmpty) {
        enhancedConversation = conversation.copyWith(
          directDisplayUser: event.selectedParticipants.first,
          participantUsers: event.selectedParticipants,
        );
      } else if (event.type == 'group' &&
          conversation.participantUsers.isEmpty &&
          event.selectedParticipants.isNotEmpty) {
        // For groups, set the participant users list
        enhancedConversation = conversation.copyWith(
          participantUsers: event.selectedParticipants,
        );
      }

      // Set lastMessage if an initial message was provided and it's not already set
      if (event.initialMessage != null &&
          event.initialMessage!.trim().isNotEmpty &&
          (enhancedConversation.lastMessage == null ||
              enhancedConversation.lastMessage!.isEmpty)) {
        enhancedConversation = enhancedConversation.copyWith(
          lastMessage: event.initialMessage,
          lastMessageAt: DateTime.now().toUtc(),
        );
      }

      // Check if conversation ID is valid (0 means backend didn't create it properly)
      if (enhancedConversation.conversationId <= 0) {
        emit(
          state.copyWith(
            creatingConversation: false,
            createConversationError:
                'Failed to create conversation. Please try again.',
          ),
        );
        return;
      }

      // Prepend new conversation to list (or update if existing)
      final existingIndex = state.conversations.indexWhere(
        (c) => c.conversationId == enhancedConversation.conversationId,
      );

      List<ConversationModel> updatedConversations;
      if (existingIndex >= 0) {
        // Conversation exists - move it to top with updated data
        updatedConversations = [
          enhancedConversation,
          ...state.conversations.where(
            (c) => c.conversationId != enhancedConversation.conversationId,
          ),
        ];
      } else {
        // New conversation - prepend to list
        updatedConversations = [enhancedConversation, ...state.conversations];
      }

      final nextParticipantCache = Map<int, ChatUserModel>.from(
        state.participantCache,
      );
      for (final participant in event.selectedParticipants) {
        if (participant.userId > 0) {
          nextParticipantCache[participant.userId] = participant;
        }
      }

      emit(
        state.copyWith(
          conversations: updatedConversations,
          frequentlyContacted: _deriveFrequentlyContacted(updatedConversations),
          participantCache: nextParticipantCache,
          creatingConversation: false,
          newlyCreatedConversationId: enhancedConversation.conversationId,
        ),
      );
    } catch (e) {
      String errorMessage = 'Failed to create conversation. Please try again.';

      // Extract more specific error message if available
      if (e is DioException) {
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic>) {
          // Handle both String and List<dynamic> error messages
          final message = responseData['message'] ?? responseData['error'];
          if (message is String && message.isNotEmpty) {
            errorMessage = message;
          } else if (message is List && message.isNotEmpty) {
            errorMessage = message.map((m) => m.toString()).join(', ');
          }
        } else if (responseData is String && responseData.isNotEmpty) {
          errorMessage = responseData;
        }
      } else if (e is Exception) {
        final exceptionString = e.toString();
        if (exceptionString.startsWith('Exception: ')) {
          errorMessage = exceptionString.substring(11);
        }
      }

      emit(
        state.copyWith(
          creatingConversation: false,
          createConversationError: errorMessage,
        ),
      );
    }
  }

  /// Reset all new conversation dialog state
  void _onChatNewConversationDialogReset(
    ChatNewConversationDialogReset event,
    Emitter<ChatState> emit,
  ) {
    emit(
      state.copyWith(
        newConversationSearchResults: const <ChatUserModel>[],
        contactSearchResults: const <ChatUserModel>[],
        userSearchLoading: false,
        clearUserSearchError: true,
        clearLastSearchQuery: true,
        selectedParticipants: const <ChatUserModel>[],
        conversationMode: 'direct',
        clearGroupNameInput: true,
        clearInitialMessageInput: true,
        creatingConversation: false,
        clearCreateConversationError: true,
        clearNewlyCreatedConversationId: true,
      ),
    );
  }

  @override
  Future<void> close() async {
    if (_hasLifecycleObserver) {
      WidgetsBinding.instance.removeObserver(this);
    }
    await _connectionStatusSubscription?.cancel();
    await _newMessageSubscription?.cancel();
    await _onlineUsersListSubscription?.cancel();
    await _notificationMessageSubscription?.cancel();
    await _typingSubscription?.cancel();
    await _messageDeletedSubscription?.cancel();
    await _messageEditedSubscription?.cancel();
    await _userStatusSubscription?.cancel();
    await _deleteConfirmedSubscription?.cancel();
    await _messageReadSubscription?.cancel();
    _typingDebounceTimer?.cancel();
    _chatSocketService.disconnect();
    return super.close();
  }
}

class _PendingMessage {
  final int localMessageId;
  final int conversationId;
  final String text;
  final int? replyToId;

  const _PendingMessage({
    required this.localMessageId,
    required this.conversationId,
    required this.text,
    this.replyToId,
  });
}
