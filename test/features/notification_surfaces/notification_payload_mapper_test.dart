import 'package:edu_verse/features/notification_surfaces/notification_payload_mapper.dart';
import 'package:edu_verse/models/notifications/notification_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationPayloadMapper', () {
    test('maps Android FCM data payload into a backend notification model', () {
      final notification = NotificationPayloadMapper.fromRemoteMessage(
        const RemoteMessage(
          messageId: 'fallback-message-id',
          data: {
            'notificationId': '42',
            'userId': '7',
            'type': 'assignment',
            'title': 'Assignment posted',
            'body': 'Your week 4 task is ready.',
            'priority': 'high',
            'actionUrl': '/courses/2/assignments/42',
            'relatedEntityType': 'assignment',
            'relatedEntityId': '42',
            'createdAt': '2026-05-17T10:00:00.000Z',
          },
        ),
      );

      expect(notification, isNotNull);
      expect(notification!.id, '42');
      expect(notification.userId, 7);
      expect(notification.type, NotificationType.assignment);
      expect(notification.priority, NotificationPriority.high);
      expect(notification.title, 'Assignment posted');
      expect(notification.message, 'Your week 4 task is ready.');
      expect(notification.actionUrl, '/courses/2/assignments/42');
      expect(notification.relatedEntityId, '42');
    });

    test('round-trips local notification tap payloads', () {
      final original = NotificationModel(
        id: '99',
        userId: 12,
        title: 'New message',
        message: 'A reply arrived in your discussion.',
        type: NotificationType.message,
        rawType: 'message',
        priority: NotificationPriority.normal,
        createdAt: DateTime.utc(2026, 5, 17, 10),
        actionUrl: '/discussions',
      );

      final decoded = NotificationPayloadMapper.fromPayload(
        NotificationPayloadMapper.toPayload(original),
      );

      expect(decoded, isNotNull);
      expect(decoded!.id, original.id);
      expect(decoded.title, original.title);
      expect(decoded.message, original.message);
      expect(decoded.type, original.type);
      expect(decoded.actionUrl, original.actionUrl);
    });
  });
}
