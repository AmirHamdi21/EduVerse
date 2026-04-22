import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:edu_verse/bloc/chat/chat_models.dart';
import 'package:edu_verse/services/api/chat_service.dart';
import 'package:edu_verse/services/api/core_api_client.dart';

class _MockAdapter implements HttpClientAdapter {
  final Map<String, dynamic> Function(RequestOptions) _handler;

  _MockAdapter(this._handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final result = _handler(options);
    final statusCode = result['statusCode'] as int? ?? 200;
    final data = result['data'];

    return ResponseBody.fromString(
      data is String ? data : jsonEncode(data),
      statusCode,
      headers: {
        'content-type': ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late CoreApiClient coreApiClient;
  late ChatService chatService;

  group('ChatService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      coreApiClient = CoreApiClient.test();
      chatService = ChatService(coreApiClient: coreApiClient);
    });

    test('listConversations sends GET and parses payload', () async {
      String? capturedPath;
      String? capturedMethod;

      coreApiClient.dio.httpClientAdapter = _MockAdapter((options) {
        capturedPath = options.path;
        capturedMethod = options.method;

        return {
          'statusCode': 200,
          'data': [
            {
              'conversationId': 15,
              'type': 'direct',
              'participants': [1, 2],
              'unreadCount': 2,
            },
          ],
        };
      });

      final result = await chatService.listConversations();

      expect(capturedMethod, 'GET');
      expect(capturedPath, '/messages/conversations');
      expect(result, hasLength(1));
      expect(result.first.conversationId, 15);
      expect(result.first.type, ConversationType.direct);
      expect(result.first.unreadCount, 2);
    });

    test('getConversationMessages sends GET with pagination', () async {
      String? capturedPath;
      Map<String, dynamic>? capturedQuery;

      coreApiClient.dio.httpClientAdapter = _MockAdapter((options) {
        capturedPath = options.path;
        capturedQuery = options.queryParameters;

        return {
          'statusCode': 200,
          'data': {
            'data': [
              {
                'id': 33,
                'conversationId': 15,
                'text': 'Hello',
                'senderId': 2,
                'sentAt': '2026-04-06T12:30:00Z',
              },
            ],
          },
        };
      });

      final result = await chatService.getConversationMessages(
        15,
        page: 2,
        limit: 30,
      );

      expect(capturedPath, '/messages/conversations/15');
      expect(capturedQuery?['page'], 2);
      expect(capturedQuery?['limit'], 30);
      expect(result, hasLength(1));
      expect(result.first.id, 33);
      expect(result.first.text, 'Hello');
    });

    test('sendMessage sends POST with expected payload', () async {
      String? capturedPath;
      String? capturedMethod;
      dynamic capturedData;

      coreApiClient.dio.httpClientAdapter = _MockAdapter((options) {
        capturedPath = options.path;
        capturedMethod = options.method;
        capturedData = options.data;

        return {
          'statusCode': 201,
          'data': {
            'id': 101,
            'conversationId': 7,
            'text': 'Hi there',
            'senderId': 1,
            'sentAt': '2026-04-06T12:30:00Z',
          },
        };
      });

      final result = await chatService.sendMessage(
        7,
        'Hi there',
        fileId: 11,
        replyToId: 99,
      );

      expect(capturedMethod, 'POST');
      expect(capturedPath, '/messages/conversations/7');
      expect(capturedData['text'], 'Hi there');
      expect(capturedData['fileId'], 11);
      expect(capturedData['replyToId'], 99);
      expect(result.id, 101);
      expect(result.conversationId, 7);
    });

    test('startConversation creates payload and parses response', () async {
      String? capturedPath;
      dynamic capturedData;

      coreApiClient.dio.httpClientAdapter = _MockAdapter((options) {
        capturedPath = options.path;
        capturedData = options.data;

        return {
          'statusCode': 201,
          'data': {
            'conversationId': 45,
            'type': 'direct',
            'participants': [1, 2],
          },
        };
      });

      final result = await chatService.startConversation(
        participantIds: const [2],
        type: 'direct',
        text: 'Hello',
      );

      expect(capturedPath, '/messages/conversations');
      expect(capturedData['participantIds'], [2]);
      expect(capturedData['type'], 'direct');
      expect(capturedData['text'], 'Hello');
      expect(result.conversationId, 45);
      expect(result.type, ConversationType.direct);
    });

    test('searchUsers sends query and parses users', () async {
      String? capturedPath;
      Map<String, dynamic>? capturedQuery;

      coreApiClient.dio.httpClientAdapter = _MockAdapter((options) {
        capturedPath = options.path;
        capturedQuery = options.queryParameters;

        return {
          'statusCode': 200,
          'data': [
            {
              'userId': 8,
              'firstName': 'John',
              'lastName': 'Doe',
              'email': 'john@eduverse.com',
            },
          ],
        };
      });

      final result = await chatService.searchUsers('john', limit: 5);

      expect(capturedPath, '/messages/users/search');
      expect(capturedQuery?['query'], 'john');
      expect(capturedQuery?['limit'], 5);
      expect(result, hasLength(1));
      expect(result.first.userId, 8);
      expect(result.first.displayName, 'John Doe');
    });

    test('edit and delete methods parse success response', () async {
      final calls = <String>[];

      coreApiClient.dio.httpClientAdapter = _MockAdapter((options) {
        calls.add('${options.method} ${options.path}');

        if (options.path.endsWith('/everyone')) {
          return {
            'statusCode': 200,
            'data': {'ok': true},
          };
        }

        if (options.method == 'PATCH') {
          return {
            'statusCode': 200,
            'data': {
              'id': 90,
              'conversationId': 7,
              'text': 'edited',
              'senderId': 1,
              'sentAt': '2026-04-06T12:30:00Z',
              'editedAt': '2026-04-06T12:45:00Z',
            },
          };
        }

        return {
          'statusCode': 200,
          'data': {'ok': true},
        };
      });

      final edited = await chatService.editMessage(90, 'edited');
      final deletedForMe = await chatService.deleteForMe(90);
      final deletedForEveryone = await chatService.deleteForEveryone(90);

      expect(edited.text, 'edited');
      expect(edited.id, 90);
      expect(deletedForMe, isTrue);
      expect(deletedForEveryone, isTrue);
      expect(calls, contains('PATCH /messages/90'));
      expect(calls, contains('DELETE /messages/90'));
      expect(calls, contains('DELETE /messages/90/everyone'));
    });

    test('markRead sends PATCH to read endpoint', () async {
      String? captured;

      coreApiClient.dio.httpClientAdapter = _MockAdapter((options) {
        captured = '${options.method} ${options.path}';
        return {
          'statusCode': 200,
          'data': {'ok': true},
        };
      });

      await chatService.markRead(77);

      expect(captured, 'PATCH /messages/77/read');
    });

    test('queues retriable request when backend responds with 429', () async {
      coreApiClient.dio.httpClientAdapter = _MockAdapter((options) {
        return {
          'statusCode': 429,
          'data': {'message': 'Too many requests'},
        };
      });

      await expectLater(
        () => chatService.sendMessage(11, 'retry me'),
        throwsA(isA<DioException>()),
      );

      final prefs = await SharedPreferences.getInstance();
      final queued = prefs.getString(ChatService.retryQueueStorageKey);

      expect(queued, isNotNull);
      expect(queued, contains('/messages/conversations/11'));
    });
  });
}
