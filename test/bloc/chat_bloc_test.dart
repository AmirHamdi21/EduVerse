import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/chat/chat_bloc.dart';
import 'package:edu_verse/bloc/chat/chat_event.dart';
import 'package:edu_verse/bloc/chat/chat_models.dart';
import 'package:edu_verse/bloc/chat/chat_state.dart';
import 'package:edu_verse/models/auth_models.dart';
import 'package:edu_verse/services/api/chat_service.dart';
import 'package:edu_verse/services/chat/chat_socket_service.dart';
import 'package:edu_verse/services/storage_service.dart';

class _FakeStorageService extends StorageService {
  final String? token;
  final UserDto? user;

  _FakeStorageService({this.token, this.user});

  @override
  Future<String?> getAccessToken() async => token;

  @override
  Future<UserDto?> getUserData() async => user;

  @override
  Future<String?> getRefreshToken() async => null;
}

class _FakeChatService implements IChatService {
  List<ConversationModel> conversations = <ConversationModel>[];
  final Map<int, List<ChatMessageModel>> messagesByConversation =
      <int, List<ChatMessageModel>>{};

  bool throwOnSend = false;
  int sendCalls = 0;
  int startConversationCalls = 0;

  ConversationModel? startConversationResult;

  @override
  Future<List<ConversationModel>> listConversations() async {
    return conversations;
  }

  @override
  Future<List<ChatMessageModel>> getConversationMessages(
    int conversationId, {
    int? page,
    int? limit,
  }) async {
    return messagesByConversation[conversationId] ?? <ChatMessageModel>[];
  }

  @override
  Future<ChatMessageModel> sendMessage(
    int conversationId,
    String text, {
    int? fileId,
    int? replyToId,
  }) async {
    sendCalls += 1;
    if (throwOnSend) {
      throw Exception('send failed');
    }

    return ChatMessageModel(
      id: 500 + sendCalls,
      conversationId: conversationId,
      text: text,
      senderId: 10,
      senderName: 'Tester',
      sentAt: DateTime.parse('2026-04-06T12:00:00Z'),
      replyToId: replyToId,
      status: 'sent',
    );
  }

  @override
  Future<ConversationModel> startConversation({
    required List<int> participantIds,
    required String type,
    String? text,
    String? groupName,
    int? fileId,
  }) async {
    startConversationCalls += 1;
    return startConversationResult ??
        ConversationModel(
          conversationId: 999,
          type: ConversationType.fromJsonValue(type),
          participants: participantIds,
          name: groupName,
        );
  }

  @override
  Future<List<ChatUserModel>> searchUsers(
    String query, {
    int limit = 20,
  }) async {
    return <ChatUserModel>[
      const ChatUserModel(
        userId: 42,
        firstName: 'Search',
        lastName: 'Result',
        fullName: 'Search Result',
        email: 'search@example.com',
      ),
    ];
  }

  @override
  Future<void> markRead(int messageId) async {}

  @override
  Future<ChatMessageModel> editMessage(int messageId, String text) async {
    return ChatMessageModel(
      id: messageId,
      conversationId: 1,
      text: text,
      senderId: 10,
      senderName: 'Tester',
      sentAt: DateTime.parse('2026-04-06T12:00:00Z'),
      status: 'sent',
    );
  }

  @override
  Future<bool> deleteForMe(int messageId) async => true;

  @override
  Future<bool> deleteForEveryone(int messageId) async => true;
}

class _FakeSocketService implements IChatSocketService {
  final StreamController<ChatConnectionStatus> _connectionController =
      StreamController<ChatConnectionStatus>.broadcast();
  final StreamController<ChatMessageModel> _newMessageController =
      StreamController<ChatMessageModel>.broadcast();
  final StreamController<Set<int>> _onlineUsersListController =
      StreamController<Set<int>>.broadcast();
  final StreamController<ChatMessageModel> _notificationController =
      StreamController<ChatMessageModel>.broadcast();
  final StreamController<UserTypingEvent> _typingController =
      StreamController<UserTypingEvent>.broadcast();
  final StreamController<int> _messageDeletedController =
      StreamController<int>.broadcast();
  final StreamController<ChatMessageModel> _messageEditedController =
      StreamController<ChatMessageModel>.broadcast();
  final StreamController<Map<String, dynamic>> _statusController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<int> _deleteConfirmedController =
      StreamController<int>.broadcast();
  final StreamController<MessageReadEvent> _messageReadController =
      StreamController<MessageReadEvent>.broadcast();

  final List<int> joinedConversationIds = <int>[];
  final List<int> leftConversationIds = <int>[];
  final List<Map<String, dynamic>> typingEvents = <Map<String, dynamic>>[];
  final List<int> markReadCalls = <int>[];
  int requestOnlineUsersCalls = 0;

  @override
  Stream<ChatConnectionStatus> get connectionStatus =>
      _connectionController.stream;

  @override
  Stream<ChatMessageModel> get newMessageStream => _newMessageController.stream;

  @override
  Stream<Set<int>> get onlineUsersListStream =>
      _onlineUsersListController.stream;

  @override
  Stream<ChatMessageModel> get newMessageNotificationStream =>
      _notificationController.stream;

  @override
  Stream<UserTypingEvent> get typingStream => _typingController.stream;

  @override
  Stream<int> get messageDeletedStream => _messageDeletedController.stream;

  @override
  Stream<ChatMessageModel> get messageEditedStream =>
      _messageEditedController.stream;

  @override
  Stream<Map<String, dynamic>> get userStatusStream => _statusController.stream;

  @override
  Stream<int> get deleteConfirmedStream => _deleteConfirmedController.stream;

  @override
  Stream<MessageReadEvent> get messageReadStream =>
      _messageReadController.stream;

  @override
  void connect(String jwtToken) {
    _connectionController.add(ChatConnectionStatus.connected);
  }

  @override
  void requestOnlineUsers() {
    requestOnlineUsersCalls += 1;
  }

  @override
  void disconnect() {
    _connectionController.add(ChatConnectionStatus.disconnected);
  }

  @override
  void joinConversation(int conversationId) {
    joinedConversationIds.add(conversationId);
  }

  @override
  void leaveConversation(int conversationId) {
    leftConversationIds.add(conversationId);
  }

  @override
  void sendMessage(
    int conversationId,
    String text, {
    int? fileId,
    int? replyToId,
  }) {}

  @override
  void emitTyping(int conversationId, bool isTyping) {
    typingEvents.add({'conversationId': conversationId, 'isTyping': isTyping});
  }

  @override
  void markRead(int conversationId) {
    markReadCalls.add(conversationId);
  }

  @override
  void editMessage(int messageId, String text) {}

  @override
  void deleteMessage(int messageId, {bool forEveryone = false}) {}

  void emitNewMessage(ChatMessageModel message) {
    _newMessageController.add(message);
  }

  void emitTypingEvent(UserTypingEvent event) {
    _typingController.add(event);
  }

  void emitUserStatus(Map<String, dynamic> event) {
    _statusController.add(event);
  }

  void emitOnlineUsersList(Set<int> onlineUsers) {
    _onlineUsersListController.add(onlineUsers);
  }

  void emitDeleteConfirmed(int messageId) {
    _deleteConfirmedController.add(messageId);
  }

  void emitMessageEdited(ChatMessageModel message) {
    _messageEditedController.add(message);
  }

  void emitMessageRead(MessageReadEvent event) {
    _messageReadController.add(event);
  }

  Future<void> dispose() async {
    await _connectionController.close();
    await _newMessageController.close();
    await _onlineUsersListController.close();
    await _notificationController.close();
    await _typingController.close();
    await _messageDeletedController.close();
    await _messageEditedController.close();
    await _statusController.close();
    await _deleteConfirmedController.close();
    await _messageReadController.close();
  }
}

ConversationModel _conversation(
  int id, {
  List<int> participants = const <int>[2],
}) {
  return ConversationModel(
    conversationId: id,
    type: ConversationType.direct,
    participants: participants,
    unreadCount: 1,
    directDisplayUser: const ChatUserModel(
      userId: 2,
      firstName: 'John',
      lastName: 'Doe',
      fullName: 'John Doe',
      email: 'john@example.com',
    ),
  );
}

ChatMessageModel _message(int id, int conversationId, String text) {
  return ChatMessageModel(
    id: id,
    conversationId: conversationId,
    text: text,
    senderId: 2,
    senderName: 'John Doe',
    sentAt: DateTime.parse('2026-04-06T12:00:00Z'),
    status: 'sent',
  );
}

Future<void> _settle() async {
  await Future<void>.delayed(const Duration(milliseconds: 10));
}

void main() {
  group('ChatBloc', () {
    late _FakeChatService chatService;
    late _FakeSocketService socketService;
    late ChatBloc bloc;

    setUp(() {
      chatService = _FakeChatService();
      socketService = _FakeSocketService();

      bloc = ChatBloc(
        chatService: chatService,
        chatSocketService: socketService,
        storageService: _FakeStorageService(
          token: 'token',
          user: UserDto(
            userId: 10,
            email: 'tester@example.com',
            firstName: 'Test',
            lastName: 'User',
          ),
        ),
      );
    });

    tearDown(() async {
      await bloc.close();
      await socketService.dispose();
    });

    test('loads conversations through LoadConversations event', () async {
      chatService.conversations = <ConversationModel>[_conversation(1)];

      bloc.add(const LoadConversations());
      await _settle();

      expect(bloc.state.status, ChatStatus.success);
      expect(bloc.state.conversations, hasLength(1));
      expect(bloc.state.conversations.first.conversationId, 1);
    });

    test('derives frequentlyContacted and participantCache on load', () async {
      chatService.conversations = <ConversationModel>[
        _conversation(1),
        ConversationModel(
          conversationId: 2,
          type: ConversationType.direct,
          participants: const <int>[3],
          directDisplayUser: const ChatUserModel(
            userId: 3,
            firstName: 'Jane',
            lastName: 'Roe',
            fullName: 'Jane Roe',
            email: 'jane@example.com',
          ),
        ),
      ];

      bloc.add(const LoadConversations());
      await _settle();

      expect(bloc.state.frequentlyContacted, isNotEmpty);
      expect(bloc.state.frequentlyContacted.length, lessThanOrEqualTo(5));
      expect(bloc.state.participantCache.keys, containsAll(<int>[2, 3]));
    });

    test(
      'SelectConversation emits join/leave socket lifecycle and loads messages',
      () async {
        chatService.conversations = <ConversationModel>[
          _conversation(1),
          _conversation(2),
        ];
        chatService.messagesByConversation[1] = <ChatMessageModel>[
          _message(11, 1, 'hello 1'),
        ];
        chatService.messagesByConversation[2] = <ChatMessageModel>[
          _message(22, 2, 'hello 2'),
        ];

        bloc.add(const LoadConversations());
        await _settle();
        bloc.add(const SelectConversation(1));
        await _settle();

        expect(socketService.joinedConversationIds, contains(1));
        expect(bloc.state.activeConversationId, 1);
        expect(bloc.state.activeConversationMessages, hasLength(1));

        bloc.add(const SelectConversation(2));
        await _settle();

        expect(socketService.leftConversationIds, contains(1));
        expect(socketService.joinedConversationIds, contains(2));
        expect(bloc.state.activeConversationId, 2);
      },
    );

    test(
      'marks optimistic message failed when socket and REST fallback both fail',
      () async {
        chatService.throwOnSend = true;

        bloc.add(const SendMessage(conversationId: 1, text: 'Will fail'));
        await _settle();

        expect(bloc.state.status, ChatStatus.failure);
        expect(bloc.state.activeConversationMessages, hasLength(1));
        expect(bloc.state.activeConversationMessages.first.status, 'failed');
        expect(bloc.state.activeConversationMessages.first.text, 'Will fail');
      },
    );

    test('retry sends a previously failed optimistic message', () async {
      chatService.throwOnSend = true;
      bloc.add(const SendMessage(conversationId: 1, text: 'Retry me'));
      await _settle();

      final failedMessageId = bloc.state.activeConversationMessages.first.id;
      expect(bloc.state.activeConversationMessages.first.status, 'failed');

      chatService.throwOnSend = false;
      bloc.add(RetryFailedMessage(failedMessageId));
      await _settle();

      expect(chatService.sendCalls, greaterThanOrEqualTo(2));
      expect(bloc.state.activeConversationMessages.last.status, 'sent');
    });

    test(
      'StartNewConversation uses existing direct conversation seamlessly',
      () async {
        chatService.conversations = <ConversationModel>[
          _conversation(77, participants: const <int>[2]),
        ];
        chatService.messagesByConversation[77] = <ChatMessageModel>[];

        bloc.add(const LoadConversations());
        await _settle();

        bloc.add(
          const StartNewConversation(
            participantIds: <int>[2],
            type: 'direct',
            text: 'hello',
          ),
        );
        await _settle();

        expect(chatService.startConversationCalls, 0);
        expect(bloc.state.activeConversationId, 77);
        expect(socketService.joinedConversationIds, contains(77));
      },
    );

    test(
      'websocket inbound events mutate typing, online, message and read states',
      () async {
        chatService.conversations = <ConversationModel>[_conversation(1)];
        chatService.messagesByConversation[1] = <ChatMessageModel>[
          _message(1, 1, 'seed'),
        ];

        bloc.add(const LoadConversations());
        await _settle();
        bloc.add(const SelectConversation(1));
        await _settle();

        socketService.emitNewMessage(_message(2, 1, 'incoming'));
        socketService.emitTypingEvent(
          const UserTypingEvent(conversationId: 1, userId: 33, isTyping: true),
        );
        socketService.emitUserStatus({'userId': 33, 'isOnline': true});
        socketService.emitMessageRead(
          const MessageReadEvent(messageId: 2, conversationId: 1, userId: 33),
        );
        await _settle();

        expect(
          bloc.state.activeConversationMessages.any((m) => m.id == 2),
          isTrue,
        );
        expect(bloc.state.typingUsers[1], contains(33));
        expect(bloc.state.onlineUsers, contains(33));
        expect(
          bloc.state.activeConversationMessages
              .firstWhere((message) => message.id == 2)
              .status,
          'read',
        );

        socketService.emitDeleteConfirmed(2);
        await _settle();
        expect(
          bloc.state.activeConversationMessages.any((m) => m.id == 2),
          isFalse,
        );
      },
    );

    test(
      'tracks online users list and lastSeen for offline transitions',
      () async {
        socketService.emitOnlineUsersList(<int>{20, 21});
        await _settle();

        expect(bloc.state.onlineUsers, containsAll(<int>{20, 21}));

        socketService.emitUserStatus({'userId': 20, 'isOnline': false});
        await _settle();
        expect(bloc.state.onlineUsers.contains(20), isFalse);
        expect(bloc.state.userLastSeen.containsKey(20), isFalse);

        socketService.emitUserStatus({
          'userId': 21,
          'isOnline': false,
          'lastSeen': '2026-04-07T10:00:00Z',
        });
        await _settle();

        expect(bloc.state.onlineUsers.contains(21), isFalse);
        expect(bloc.state.userLastSeen[21], isNotNull);
      },
    );

    test(
      'requests online users when explicit refresh event is dispatched',
      () async {
        final baselineCalls = socketService.requestOnlineUsersCalls;

        bloc.add(const RefreshOnlineUsersRequested());
        await _settle();

        expect(
          socketService.requestOnlineUsersCalls,
          greaterThanOrEqualTo(baselineCalls + 1),
        );
      },
    );
  });
}
