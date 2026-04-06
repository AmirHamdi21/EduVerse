import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/chat/chat_models.dart';
import 'package:edu_verse/services/chat/chat_socket_service.dart';

class _EmittedEvent {
  final String event;
  final dynamic payload;

  _EmittedEvent(this.event, this.payload);
}

class _FakeSocketClient implements ChatSocketClient {
  final Map<String, List<void Function(dynamic)>> _handlers = {};
  final List<_EmittedEvent> emittedEvents = [];

  bool _connected = false;

  @override
  bool get connected => _connected;

  @override
  void connect() {
    _connected = true;
    _dispatch('__connect__', null);
  }

  @override
  void disconnect() {
    _connected = false;
    _dispatch('__disconnect__', null);
  }

  @override
  void dispose() {}

  @override
  void emit(String event, dynamic data) {
    emittedEvents.add(_EmittedEvent(event, data));
  }

  @override
  void on(String event, void Function(dynamic data) handler) {
    _handlers.putIfAbsent(event, () => []).add(handler);
  }

  @override
  void onConnect(void Function(dynamic data) handler) {
    _handlers.putIfAbsent('__connect__', () => []).add(handler);
  }

  @override
  void onDisconnect(void Function(dynamic data) handler) {
    _handlers.putIfAbsent('__disconnect__', () => []).add(handler);
  }

  @override
  void onConnectError(void Function(dynamic data) handler) {
    _handlers.putIfAbsent('__connect_error__', () => []).add(handler);
  }

  @override
  void off(String event) {
    _handlers.remove(event);
  }

  void simulateEvent(String event, dynamic data) {
    _dispatch(event, data);
  }

  void simulateConnectError(dynamic data) {
    _dispatch('__connect_error__', data);
    _dispatch('connect_error', data);
  }

  void _dispatch(String event, dynamic data) {
    final listeners = _handlers[event];
    if (listeners == null) {
      return;
    }

    for (final handler in List<void Function(dynamic)>.from(listeners)) {
      handler(data);
    }
  }
}

void main() {
  group('ChatSocketService', () {
    setUp(() {
      ChatSocketService.resetInstanceForTest();
    });

    test(
      'connect uses messaging namespace and emits connection states',
      () async {
        late _FakeSocketClient fakeSocket;
        String? capturedUrl;
        String? capturedToken;

        final service = ChatSocketService(
          socketClientFactory:
              ({
                required String url,
                required String token,
                required int reconnectionAttempts,
                required int reconnectionDelayMs,
              }) {
                capturedUrl = url;
                capturedToken = token;
                fakeSocket = _FakeSocketClient();
                return fakeSocket;
              },
        );

        final states = <ChatConnectionStatus>[];
        final sub = service.connectionStatus.listen(states.add);

        service.connect('jwt-token-123');
        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(capturedUrl, isNotNull);
        expect(capturedUrl, endsWith('/messaging'));
        expect(capturedToken, 'jwt-token-123');
        expect(states, contains(ChatConnectionStatus.reconnecting));
        expect(states, contains(ChatConnectionStatus.connected));

        await sub.cancel();
        ChatSocketService.resetInstanceForTest();
      },
    );

    test('emits expected socket events for chat actions', () async {
      late _FakeSocketClient fakeSocket;

      final service = ChatSocketService(
        socketClientFactory:
            ({
              required String url,
              required String token,
              required int reconnectionAttempts,
              required int reconnectionDelayMs,
            }) {
              fakeSocket = _FakeSocketClient();
              return fakeSocket;
            },
      );

      service.connect('token');
      await Future<void>.delayed(const Duration(milliseconds: 10));

      service.joinConversation(10);
      service.leaveConversation(10);
      service.sendMessage(10, 'hello', fileId: 5, replyToId: 2);
      service.emitTyping(10, true);
      service.markRead(10);
      service.editMessage(200, 'edited');
      service.deleteMessage(200, forEveryone: true);

      final names = fakeSocket.emittedEvents
          .map((event) => event.event)
          .toList();

      expect(names, contains('join_conversation'));
      expect(names, contains('leave_conversation'));
      expect(names, contains('send_message'));
      expect(names, contains('typing'));
      expect(names, contains('mark_read'));
      expect(names, contains('edit_message'));
      expect(names, contains('delete_message'));

      final sendPayload =
          fakeSocket.emittedEvents
                  .firstWhere((event) => event.event == 'send_message')
                  .payload
              as Map<String, dynamic>;

      expect(sendPayload['conversationId'], 10);
      expect(sendPayload['text'], 'hello');
      expect(sendPayload['fileId'], 5);
      expect(sendPayload['replyToId'], 2);

      ChatSocketService.resetInstanceForTest();
    });

    test('maps incoming socket events into streams', () async {
      late _FakeSocketClient fakeSocket;

      final service = ChatSocketService(
        socketClientFactory:
            ({
              required String url,
              required String token,
              required int reconnectionAttempts,
              required int reconnectionDelayMs,
            }) {
              fakeSocket = _FakeSocketClient();
              return fakeSocket;
            },
      );

      final newMessages = <ChatMessageModel>[];
      final notifications = <ChatMessageModel>[];
      final typing = <UserTypingEvent>[];
      final deletedIds = <int>[];
      final editedMessages = <ChatMessageModel>[];
      final statusEvents = <Map<String, dynamic>>[];
      final deleteConfirmedIds = <int>[];
      final readEvents = <MessageReadEvent>[];

      final subs = [
        service.newMessageStream.listen(newMessages.add),
        service.newMessageNotificationStream.listen(notifications.add),
        service.typingStream.listen(typing.add),
        service.messageDeletedStream.listen(deletedIds.add),
        service.messageEditedStream.listen(editedMessages.add),
        service.userStatusStream.listen(statusEvents.add),
        service.deleteConfirmedStream.listen(deleteConfirmedIds.add),
        service.messageReadStream.listen(readEvents.add),
      ];

      service.connect('token');
      await Future<void>.delayed(const Duration(milliseconds: 10));

      fakeSocket.simulateEvent('new_message', {
        'id': 1,
        'conversationId': 9,
        'text': 'incoming',
        'senderId': 7,
        'sentAt': '2026-04-06T13:00:00Z',
      });

      fakeSocket.simulateEvent('new_message_notification', {
        'conversationId': 9,
        'message': {
          'id': 2,
          'conversationId': 9,
          'text': 'notify',
          'senderId': 8,
          'sentAt': '2026-04-06T13:01:00Z',
        },
      });

      fakeSocket.simulateEvent('user_typing', {
        'conversationId': 9,
        'userId': 7,
        'isTyping': true,
      });

      fakeSocket.simulateEvent('message_deleted', {'messageId': 31});
      fakeSocket.simulateEvent('delete_confirmed', {
        'data': {'messageId': 32},
      });

      fakeSocket.simulateEvent('message_edited', {
        'id': 45,
        'conversationId': 9,
        'text': 'edited text',
        'senderId': 7,
        'sentAt': '2026-04-06T13:02:00Z',
      });

      fakeSocket.simulateEvent('user_status', {
        'userId': 7,
        'isOnline': true,
        'lastSeen': '2026-04-06T13:03:00Z',
      });

      fakeSocket.simulateEvent('message_read', {
        'messageId': 45,
        'conversationId': 9,
        'userId': 7,
      });

      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(newMessages, hasLength(1));
      expect(newMessages.first.text, 'incoming');
      expect(notifications, hasLength(1));
      expect(notifications.first.text, 'notify');
      expect(typing, hasLength(1));
      expect(typing.first.userId, 7);
      expect(typing.first.isTyping, isTrue);
      expect(deletedIds, [31]);
      expect(deleteConfirmedIds, [32]);
      expect(editedMessages, hasLength(1));
      expect(editedMessages.first.id, 45);
      expect(statusEvents, hasLength(1));
      expect(statusEvents.first['userId'], 7);
      expect(readEvents, hasLength(1));
      expect(readEvents.first.messageId, 45);

      for (final sub in subs) {
        await sub.cancel();
      }

      ChatSocketService.resetInstanceForTest();
    });

    test('connect error pushes reconnecting status', () async {
      late _FakeSocketClient fakeSocket;

      final service = ChatSocketService(
        socketClientFactory:
            ({
              required String url,
              required String token,
              required int reconnectionAttempts,
              required int reconnectionDelayMs,
            }) {
              fakeSocket = _FakeSocketClient();
              return fakeSocket;
            },
      );

      final states = <ChatConnectionStatus>[];
      final sub = service.connectionStatus.listen(states.add);

      service.connect('token');
      await Future<void>.delayed(const Duration(milliseconds: 10));

      fakeSocket.simulateConnectError('network failure');
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(states.last, ChatConnectionStatus.reconnecting);

      await sub.cancel();
      ChatSocketService.resetInstanceForTest();
    });
  });
}
