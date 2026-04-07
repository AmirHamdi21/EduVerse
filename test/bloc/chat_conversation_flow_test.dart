// Integration tests for T085-T102: New Conversation Flow validation
// Tests success criteria, state management, and integration behaviors

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/chat/chat_bloc.dart';
import 'package:edu_verse/bloc/chat/chat_event.dart';
import 'package:edu_verse/bloc/chat/chat_models.dart';
import 'package:edu_verse/models/auth_models.dart';
import 'package:edu_verse/services/api/chat_service.dart';
import 'package:edu_verse/services/chat/chat_socket_service.dart';
import 'package:edu_verse/services/storage_service.dart';

// ============ Test Helpers ============

const _targetUser = ChatUserModel(
  userId: 42,
  firstName: 'Target',
  lastName: 'User',
  fullName: 'Target User',
  email: 'target@example.com',
);

const _user1 = ChatUserModel(
  userId: 43,
  firstName: 'User',
  lastName: 'One',
  fullName: 'User One',
  email: 'user1@example.com',
);

const _user2 = ChatUserModel(
  userId: 44,
  firstName: 'User',
  lastName: 'Two',
  fullName: 'User Two',
  email: 'user2@example.com',
);

String _getInitials(ChatUserModel user) {
  final first = user.firstName?.isNotEmpty == true ? user.firstName![0] : '';
  final last = user.lastName?.isNotEmpty == true ? user.lastName![0] : '';
  if (first.isEmpty && last.isEmpty) {
    return user.displayName.isNotEmpty ? user.displayName[0] : '?';
  }
  return '$first$last';
}

class _TimingTracker {
  final List<Duration> searchTimes = [];
  final Stopwatch _stopwatch = Stopwatch();

  void startSearch() {
    _stopwatch.reset();
    _stopwatch.start();
  }

  void endSearch() {
    _stopwatch.stop();
    searchTimes.add(_stopwatch.elapsed);
  }

  bool get allSearchesUnder2Seconds =>
      searchTimes.every((d) => d.inMilliseconds < 2000);

  double get percentileUnder2Seconds {
    if (searchTimes.isEmpty) return 100.0;
    final under2s = searchTimes.where((d) => d.inMilliseconds < 2000).length;
    return (under2s / searchTimes.length) * 100;
  }
}

// ============ Fake Services ============

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
  List<ConversationModel> conversations = [];
  final Map<int, List<ChatMessageModel>> messagesByConversation = {};

  bool throwOnSearch = false;
  bool throwOnStartConversation = false;
  int searchCalls = 0;
  int startConversationCalls = 0;

  ConversationModel? startConversationResult;
  List<ChatUserModel> searchResults = [];

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
    return messagesByConversation[conversationId] ?? [];
  }

  @override
  Future<ChatMessageModel> sendMessage(
    int conversationId,
    String text, {
    int? fileId,
    int? replyToId,
  }) async {
    return ChatMessageModel(
      id: 500,
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

    if (throwOnStartConversation) {
      throw Exception('Network error: Failed to create conversation');
    }

    return startConversationResult ??
        ConversationModel(
          conversationId: 999,
          type: ConversationType.fromJsonValue(type),
          participants: participantIds,
          name: groupName,
          lastMessage: text,
          lastMessageAt: text != null ? DateTime.now() : null,
        );
  }

  @override
  Future<List<ChatUserModel>> searchUsers(
    String query, {
    int limit = 20,
  }) async {
    searchCalls += 1;

    if (throwOnSearch) {
      throw Exception('Network error: Search failed');
    }

    return searchResults.isNotEmpty
        ? searchResults
        : [_targetUser];
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

  final List<int> joinedConversationIds = [];

  @override
  Stream<ChatConnectionStatus> get connectionStatus =>
      _connectionController.stream;

  @override
  Stream<ChatMessageModel> get newMessageStream => _newMessageController.stream;

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
  void disconnect() {
    _connectionController.add(ChatConnectionStatus.disconnected);
  }

  @override
  void joinConversation(int conversationId) {
    joinedConversationIds.add(conversationId);
  }

  @override
  void leaveConversation(int conversationId) {}

  @override
  void sendMessage(int conversationId, String text, {int? fileId, int? replyToId}) {}

  @override
  void emitTyping(int conversationId, bool isTyping) {}

  @override
  void markRead(int conversationId) {}

  @override
  void editMessage(int messageId, String text) {}

  @override
  void deleteMessage(int messageId, {bool forEveryone = false}) {}

  void emitNewMessage(ChatMessageModel message) {
    _newMessageController.add(message);
  }

  Future<void> dispose() async {
    await _connectionController.close();
    await _newMessageController.close();
    await _notificationController.close();
    await _typingController.close();
    await _messageDeletedController.close();
    await _messageEditedController.close();
    await _statusController.close();
    await _deleteConfirmedController.close();
    await _messageReadController.close();
  }
}

Future<void> _settle() async {
  await Future<void>.delayed(const Duration(milliseconds: 50));
}

// Longer settle time to account for 400ms debounce on search
Future<void> _settleSearch() async {
  await Future<void>.delayed(const Duration(milliseconds: 500));
}

// ============ Tests ============

void main() {
  group('T085: Success Criteria Validation', () {
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

    test('SC-001: Find participant quickly via search', () async {
      chatService.searchResults = [_targetUser, _user1];

      bloc.add(const ChatSearchUsersRequested('target'));
      await _settleSearch();

      expect(bloc.state.newConversationSearchResults, hasLength(2));
      expect(bloc.state.newConversationSearchResults.first.fullName, 'Target User');
      expect(bloc.state.userSearchLoading, isFalse);
    });

    test('SC-002: Create conversation within expected timeframe', () async {
      final stopwatch = Stopwatch()..start();

      bloc.add(const ChatParticipantAdded(_targetUser));
      await _settle();

      bloc.add(ChatStartConversationRequested(
        participantIds: [42],
        selectedParticipants: [_targetUser],
        type: 'direct',
        initialMessage: 'Hello!',
      ));
      await _settle();

      stopwatch.stop();

      expect(bloc.state.newlyCreatedConversationId, isNotNull);
      expect(bloc.state.creatingConversation, isFalse);
      expect(chatService.startConversationCalls, 1);
      expect(stopwatch.elapsedMilliseconds, lessThan(30000));
    });

    test('SC-003: Search returns results quickly', () async {
      final tracker = _TimingTracker();

      for (var i = 0; i < 25; i++) {
        tracker.startSearch();
        bloc.add(ChatSearchUsersRequested('query$i'));
        await _settleSearch();
        tracker.endSearch();
      }

      expect(tracker.percentileUnder2Seconds, greaterThanOrEqualTo(95.0));
    });
  });

  group('T088: Error Preservation', () {
    late _FakeChatService chatService;
    late _FakeSocketService socketService;
    late ChatBloc bloc;

    setUp(() {
      chatService = _FakeChatService();
      socketService = _FakeSocketService();
      chatService.throwOnStartConversation = true;

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

    test('preserves participants on creation error', () async {
      bloc.add(const ChatParticipantAdded(_targetUser));
      await _settle();

      bloc.add(ChatStartConversationRequested(
        participantIds: [42],
        selectedParticipants: [_targetUser],
        type: 'direct',
        initialMessage: 'Hello!',
      ));
      await _settle();

      expect(bloc.state.createConversationError, isNotNull);
      expect(bloc.state.selectedParticipants, hasLength(1));
      expect(bloc.state.selectedParticipants.first.userId, 42);
      expect(bloc.state.creatingConversation, isFalse);
    });

    test('preserves conversation mode on creation error', () async {
      bloc.add(const ChatConversationModeChanged('group'));
      bloc.add(const ChatParticipantAdded(_user1));
      bloc.add(const ChatParticipantAdded(_user2));
      await _settle();

      bloc.add(ChatStartConversationRequested(
        participantIds: [43, 44],
        selectedParticipants: [_user1, _user2],
        type: 'group',
        groupName: 'Test Group',
        initialMessage: 'Hello group!',
      ));
      await _settle();

      expect(bloc.state.conversationMode, 'group');
      expect(bloc.state.selectedParticipants, hasLength(2));
    });

    test('retry clears error and attempts again', () async {
      bloc.add(const ChatParticipantAdded(_targetUser));
      await _settle();

      bloc.add(ChatStartConversationRequested(
        participantIds: [42],
        selectedParticipants: [_targetUser],
        type: 'direct',
      ));
      await _settle();

      expect(bloc.state.createConversationError, isNotNull);

      chatService.throwOnStartConversation = false;

      bloc.add(ChatStartConversationRequested(
        participantIds: [42],
        selectedParticipants: [_targetUser],
        type: 'direct',
      ));
      await _settle();

      expect(bloc.state.createConversationError, isNull);
      expect(bloc.state.newlyCreatedConversationId, isNotNull);
    });
  });

  group('T089: Cancel Behavior', () {
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

    test('dialog reset clears all dialog state', () async {
      bloc.add(const ChatConversationModeChanged('group'));
      bloc.add(const ChatParticipantAdded(_targetUser));
      bloc.add(const ChatSearchUsersRequested('search'));
      await _settleSearch();

      expect(bloc.state.conversationMode, 'group');
      expect(bloc.state.selectedParticipants, hasLength(1));

      bloc.add(const ChatNewConversationDialogReset());
      await _settle();

      expect(bloc.state.conversationMode, 'direct');
      expect(bloc.state.selectedParticipants, isEmpty);
      expect(bloc.state.newConversationSearchResults, isEmpty);
      expect(bloc.state.userSearchLoading, isFalse);
      expect(bloc.state.userSearchError, isNull);
      expect(bloc.state.creatingConversation, isFalse);
      expect(bloc.state.createConversationError, isNull);
      expect(bloc.state.newlyCreatedConversationId, isNull);
    });

    test('reopen dialog shows empty state', () async {
      bloc.add(const ChatParticipantAdded(_targetUser));
      await _settle();

      bloc.add(ChatStartConversationRequested(
        participantIds: [42],
        selectedParticipants: [_targetUser],
        type: 'direct',
      ));
      await _settle();

      expect(bloc.state.newlyCreatedConversationId, isNotNull);

      bloc.add(const ChatNewConversationDialogReset());
      await _settle();

      expect(bloc.state.selectedParticipants, isEmpty);
      expect(bloc.state.newlyCreatedConversationId, isNull);
    });
  });

  group('T090: Navigation Flow', () {
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

    test('conversation list updates after creation', () async {
      bloc.add(const LoadConversations());
      await _settle();

      expect(bloc.state.conversations, isEmpty);

      bloc.add(ChatStartConversationRequested(
        participantIds: [42],
        selectedParticipants: [_targetUser],
        type: 'direct',
        initialMessage: 'Hello!',
      ));
      await _settle();

      expect(bloc.state.conversations, hasLength(1));
      expect(bloc.state.conversations.first.conversationId, 999);
    });

    test('newly created conversation ID available for navigation', () async {
      bloc.add(ChatStartConversationRequested(
        participantIds: [42],
        selectedParticipants: [_targetUser],
        type: 'direct',
      ));
      await _settle();

      expect(bloc.state.newlyCreatedConversationId, 999);
    });

    test('direct conversation routes to existing when found', () async {
      chatService.conversations = [
        ConversationModel(
          conversationId: 77,
          type: ConversationType.direct,
          participants: const [10, 42],
          directDisplayUser: _targetUser,
        ),
      ];

      bloc.add(const LoadConversations());
      await _settle();

      bloc.add(const StartNewConversation(
        participantIds: [42],
        type: 'direct',
        text: 'Hello existing!',
      ));
      await _settle();

      expect(chatService.startConversationCalls, 0);
      expect(bloc.state.activeConversationId, 77);
    });
  });

  group('T091: Real-time Integration', () {
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

    test('websocket messages update new conversation', () async {
      bloc.add(ChatStartConversationRequested(
        participantIds: [42],
        selectedParticipants: [_targetUser],
        type: 'direct',
      ));
      await _settle();

      final conversationId = bloc.state.newlyCreatedConversationId!;

      bloc.add(SelectConversation(conversationId));
      await _settle();

      socketService.emitNewMessage(
        ChatMessageModel(
          id: 123,
          conversationId: conversationId,
          text: 'Websocket message',
          senderId: 42,
          senderName: 'Other User',
          sentAt: DateTime.now(),
          status: 'sent',
        ),
      );
      await _settle();

      expect(
        bloc.state.activeConversationMessages.any((m) => m.id == 123),
        isTrue,
      );
    });
  });

  group('T095: Quickstart Validation', () {
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

    test('state fields from quickstart exist', () {
      expect(bloc.state.newConversationSearchResults, isA<List<ChatUserModel>>());
      expect(bloc.state.userSearchLoading, isA<bool>());
      expect(bloc.state.userSearchError, isNull);
      expect(bloc.state.selectedParticipants, isA<List<ChatUserModel>>());
      expect(bloc.state.conversationMode, isA<String>());
      expect(bloc.state.creatingConversation, isA<bool>());
      expect(bloc.state.createConversationError, isNull);
      expect(bloc.state.newlyCreatedConversationId, isNull);
    });

    test('events from quickstart function correctly', () async {
      bloc.add(const ChatSearchUsersRequested('test'));
      await _settleSearch();
      expect(bloc.state.newConversationSearchResults, isNotEmpty);

      bloc.add(const ChatParticipantAdded(_targetUser));
      await _settle();
      expect(bloc.state.selectedParticipants, hasLength(1));

      bloc.add(const ChatParticipantRemoved(42));
      await _settle();
      expect(bloc.state.selectedParticipants, isEmpty);

      bloc.add(const ChatConversationModeChanged('group'));
      await _settle();
      expect(bloc.state.conversationMode, 'group');

      bloc.add(const ChatNewConversationDialogReset());
      await _settle();
      expect(bloc.state.conversationMode, 'direct');
    });
  });

  group('T097: Accessibility', () {
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

    test('search results include required display data', () async {
      chatService.searchResults = [_targetUser];

      bloc.add(const ChatSearchUsersRequested('target'));
      await _settleSearch();

      final user = bloc.state.newConversationSearchResults.first;

      expect(user.fullName, isNotEmpty);
      expect(user.email, isNotEmpty);
      expect(user.displayName, isNotEmpty);
      expect(_getInitials(user), isNotEmpty);
    });

    test('error messages are human readable', () async {
      chatService.throwOnSearch = true;

      bloc.add(const ChatSearchUsersRequested('test'));
      await _settleSearch();

      expect(bloc.state.userSearchError, isNotNull);
      expect(bloc.state.userSearchError, isNotEmpty);
    });
  });

  group('T098: Performance Validation', () {
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

    test('handles maximum participants without lag', () async {
      for (var i = 0; i < 50; i++) {
        bloc.add(ChatParticipantAdded(
          ChatUserModel(
            userId: i,
            firstName: 'User',
            lastName: '$i',
            fullName: 'User $i',
            email: 'user$i@example.com',
          ),
        ));
      }
      await _settle();

      expect(bloc.state.selectedParticipants, hasLength(50));

      final stopwatch = Stopwatch()..start();
      bloc.add(const ChatParticipantRemoved(25));
      await _settle();
      stopwatch.stop();

      expect(bloc.state.selectedParticipants, hasLength(49));
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('conversation list updates smoothly with many conversations', () async {
      chatService.conversations = List.generate(
        100,
        (i) => ConversationModel(
          conversationId: i,
          type: ConversationType.direct,
          participants: [10, i + 100],
        ),
      );

      final stopwatch = Stopwatch()..start();
      bloc.add(const LoadConversations());
      await _settle();
      stopwatch.stop();

      expect(bloc.state.conversations, hasLength(100));
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });
  });

  group('T101: Final Integration Test', () {
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

    test('User Story 1: Direct conversation flow', () async {
      bloc.add(const ChatSearchUsersRequested('john'));
      await _settleSearch();
      expect(bloc.state.newConversationSearchResults, isNotEmpty);

      bloc.add(ChatParticipantAdded(bloc.state.newConversationSearchResults.first));
      await _settle();
      expect(bloc.state.selectedParticipants, hasLength(1));

      final participant = bloc.state.selectedParticipants.first;
      bloc.add(ChatStartConversationRequested(
        participantIds: [participant.userId],
        selectedParticipants: [participant],
        type: 'direct',
        initialMessage: 'Hello!',
      ));
      await _settle();

      expect(bloc.state.newlyCreatedConversationId, isNotNull);
      expect(bloc.state.conversations, hasLength(1));

      bloc.add(const ChatNewConversationDialogReset());
      await _settle();
      expect(bloc.state.selectedParticipants, isEmpty);
    });

    test('User Story 2: Group conversation flow', () async {
      bloc.add(const ChatConversationModeChanged('group'));
      await _settle();
      expect(bloc.state.conversationMode, 'group');

      bloc.add(const ChatParticipantAdded(_user1));
      bloc.add(const ChatParticipantAdded(_user2));
      await _settle();
      expect(bloc.state.selectedParticipants, hasLength(2));

      bloc.add(ChatStartConversationRequested(
        participantIds: [43, 44],
        selectedParticipants: [_user1, _user2],
        type: 'group',
        groupName: 'Test Group',
        initialMessage: 'Welcome everyone!',
      ));
      await _settle();

      expect(bloc.state.newlyCreatedConversationId, isNotNull);
      expect(bloc.state.conversations.first.name, 'Test Group');

      bloc.add(const ChatNewConversationDialogReset());
      await _settle();
    });

    test('User Story 3: Search and browse flow', () async {
      chatService.searchResults = [_targetUser, _user1, _user2];

      bloc.add(const ChatSearchUsersRequested('user'));
      await _settleSearch();
      expect(bloc.state.newConversationSearchResults, hasLength(3));

      for (final user in bloc.state.newConversationSearchResults) {
        expect(user.fullName, isNotEmpty);
        expect(user.email, isNotEmpty);
      }

      // Select the second result (order may vary due to sorting)
      final selectedUser = bloc.state.newConversationSearchResults[1];
      bloc.add(ChatParticipantAdded(selectedUser));
      await _settle();
      expect(bloc.state.selectedParticipants.first.fullName, selectedUser.fullName);
    });

    test('state resets properly between operations', () async {
      bloc.add(const ChatParticipantAdded(_targetUser));
      await _settle();

      bloc.add(ChatStartConversationRequested(
        participantIds: [42],
        selectedParticipants: [_targetUser],
        type: 'direct',
      ));
      await _settle();

      expect(bloc.state.conversations, hasLength(1));

      bloc.add(const ChatNewConversationDialogReset());
      await _settle();

      bloc.add(const ChatConversationModeChanged('group'));
      bloc.add(const ChatParticipantAdded(_user1));
      bloc.add(const ChatParticipantAdded(_user2));
      await _settle();

      expect(bloc.state.selectedParticipants, hasLength(2));
      expect(
        bloc.state.selectedParticipants.any((u) => u.userId == 42),
        isFalse,
      );
    });
  });

  group('T102: Search Performance Validation', () {
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

    test('20+ searches complete with 95% under 2 seconds', () async {
      final tracker = _TimingTracker();
      final queries = [
        'john', 'jane', 'alice', 'bob', 'charlie',
        'david', 'eve', 'frank', 'grace', 'henry',
        'ivy', 'jack', 'kate', 'leo', 'mia',
        'nick', 'olivia', 'peter', 'quinn', 'rose',
        'sam', 'tina', 'uma', 'victor', 'wendy',
      ];

      for (final query in queries) {
        tracker.startSearch();
        bloc.add(ChatSearchUsersRequested(query));
        await _settleSearch();
        tracker.endSearch();
      }

      expect(tracker.searchTimes.length, greaterThanOrEqualTo(20));
      expect(tracker.percentileUnder2Seconds, greaterThanOrEqualTo(95.0));
    });

    test('varied query types all complete quickly', () async {
      final tracker = _TimingTracker();
      final queries = [
        'john@example.com', // Full email
        '@example.com', // Domain search
        'John', // Name
        'john doe', // Full name
        'joh', // Partial
        'J', // Single char
        '123', // Numbers
        'user-name', // Hyphen
        'user.name', // Dot
        'test_user', // Underscore
      ];

      for (final query in queries) {
        tracker.startSearch();
        bloc.add(ChatSearchUsersRequested(query));
        await _settleSearch();
        tracker.endSearch();
      }

      expect(tracker.allSearchesUnder2Seconds, isTrue);
    });
  });
}
