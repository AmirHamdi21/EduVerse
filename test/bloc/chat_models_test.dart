import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/chat/chat_models.dart';
import 'package:edu_verse/models/chat/chat_models.dart';

void main() {
  group('ChatUserModel', () {
    test('parses all expected backend fields', () {
      final user = ChatUserModel.fromJson({
        'userId': 12,
        'firstName': 'Ada',
        'lastName': 'Lovelace',
        'fullName': 'Ada Lovelace',
        'email': 'ada@example.com',
      });

      expect(user.userId, 12);
      expect(user.firstName, 'Ada');
      expect(user.lastName, 'Lovelace');
      expect(user.fullName, 'Ada Lovelace');
      expect(user.email, 'ada@example.com');
      expect(user.role, isNull);
      expect(user.displayName, 'Ada Lovelace');
    });

    test('parses direct role string fields', () {
      final user = ChatUserModel.fromJson({
        'userId': 19,
        'firstName': 'Linus',
        'lastName': 'Torvalds',
        'email': 'linus@example.com',
        'role': 'Instructor',
      });

      expect(user.userId, 19);
      expect(user.role, 'Instructor');
    });

    test('parses role from roles list payload', () {
      final user = ChatUserModel.fromJson({
        'userId': 20,
        'fullName': 'New User',
        'email': 'new@example.com',
        'roles': [
          {'name': 'Teaching Assistant'},
        ],
      });

      expect(user.userId, 20);
      expect(user.role, 'Teaching Assistant');
    });
  });

  group('ChatMessageModel', () {
    test('uses deletedText fallback when message is deleted', () {
      final message = ChatMessageModel.fromJson({
        'id': 99,
        'conversationId': 7,
        'senderId': 5,
        'isDeleted': true,
        'deletedText': 'Message removed by moderator',
        'sentAt': '2026-04-06T10:00:00Z',
      });

      expect(message.id, 99);
      expect(message.isDeleted, isTrue);
      expect(message.deletedText, 'Message removed by moderator');
      expect(message.text, 'Message removed by moderator');
      expect(message.status, 'deleted');
    });

    test('defaults deletedText when backend omits it', () {
      final message = ChatMessageModel.fromJson({
        'id': 100,
        'conversationId': 7,
        'senderId': 5,
        'isDeleted': true,
        'sentAt': '2026-04-06T10:05:00Z',
      });

      expect(message.deletedText, ChatMessageModel.defaultDeletedText);
      expect(message.text, ChatMessageModel.defaultDeletedText);
    });
  });

  group('ConversationModel', () {
    test('parses full API payload and keeps group/direct only', () {
      final conversation = ConversationModel.fromJson({
        'conversationId': 44,
        'type': 'group',
        'name': 'Algorithms Group',
        'participants': [1, 2, 3],
        'participantUsers': [
          {
            'userId': 1,
            'firstName': 'Alan',
            'lastName': 'Turing',
            'fullName': 'Alan Turing',
            'email': 'alan@example.com',
          },
        ],
        'directDisplayUser': {
          'userId': 2,
          'firstName': 'Grace',
          'lastName': 'Hopper',
          'fullName': 'Grace Hopper',
          'email': 'grace@example.com',
        },
        'lastMessage': {'id': 9, 'text': 'hello', 'senderId': 2},
        'unreadCount': 4,
        'lastMessageAt': '2026-04-06T11:00:00Z',
      });

      expect(conversation.conversationId, 44);
      expect(conversation.type, ConversationType.group);
      expect(conversation.participants, [1, 2, 3]);
      expect(conversation.participantUsers, hasLength(1));
      expect(conversation.directDisplayUser?.displayName, 'Grace Hopper');
      expect(conversation.unreadCount, 4);
      expect(conversation.lastMessage, 'hello');
      expect(conversation.lastMessageInfo, isNotNull);
    });

    test('normalizes unsupported type values away from legacy course', () {
      final conversation = ConversationModel.fromJson({
        'conversationId': 55,
        'type': 'course',
        'participants': [1, 2],
      });

      expect(conversation.type, isNot(ConversationType.group));
      expect(conversation.type, ConversationType.direct);
    });
  });

  group('HydratedMessage extension', () {
    test('uses senderName when available', () {
      final message = ChatMessageModel(
        id: 1,
        text: 'hello',
        senderId: 20,
        senderName: 'Known User',
        sentAt: DateTime.parse('2026-04-06T10:00:00Z'),
        conversationId: 7,
      );

      final result = message.hydratedReplyToName(const <int, ChatUserModel>{});
      expect(result, 'Known User');
    });

    test('falls back to participant cache when senderName is missing', () {
      final message = ChatMessageModel(
        id: 2,
        text: 'hello',
        senderId: 33,
        senderName: null,
        sentAt: DateTime.parse('2026-04-06T10:00:00Z'),
        conversationId: 7,
      );

      final result = message.hydratedReplyToName({
        33: const ChatUserModel(
          userId: 33,
          firstName: 'Cache',
          lastName: 'Hit',
          fullName: 'Cache Hit',
        ),
      });

      expect(result, 'Cache Hit');
    });

    test('returns Unknown User when sender cannot be resolved', () {
      final message = ChatMessageModel(
        id: 3,
        text: 'hello',
        senderId: 44,
        senderName: null,
        sentAt: DateTime.parse('2026-04-06T10:00:00Z'),
        conversationId: 7,
      );

      final result = message.hydratedReplyToName(const <int, ChatUserModel>{});
      expect(result, 'Unknown User');
    });
  });
}
