import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../../models/notifications/api_notification_model.dart';
import '../../models/notifications/notification_model.dart';

class NotificationPayloadMapper {
  const NotificationPayloadMapper._();

  static NotificationModel? fromRemoteMessage(RemoteMessage message) {
    final data = Map<String, dynamic>.from(message.data);
    final title =
        _read(data, 'title') ?? message.notification?.title ?? 'EduVerse';
    final body = _read(data, 'body') ?? message.notification?.body ?? '';

    if (title.trim().isEmpty && body.trim().isEmpty) {
      return null;
    }

    final json = <String, dynamic>{
      'id':
          _read(data, 'notificationId') ??
          _read(data, 'id') ??
          message.messageId ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      'notificationId':
          _read(data, 'notificationId') ??
          _read(data, 'id') ??
          message.messageId,
      'userId': _read(data, 'userId'),
      'notificationType':
          _read(data, 'notificationType') ?? _read(data, 'type') ?? 'system',
      'title': title,
      'body': body,
      'priority': _read(data, 'priority') ?? 'medium',
      'actionUrl': _read(data, 'actionUrl'),
      'relatedEntityType': _read(data, 'relatedEntityType'),
      'relatedEntityId': _read(data, 'relatedEntityId'),
      'announcementId': _read(data, 'announcementId'),
      'createdAt': _read(data, 'createdAt') ?? DateTime.now().toIso8601String(),
      'isRead': false,
    }..removeWhere((_, value) => value == null);

    return ApiNotificationModel.fromJson(json).toNotificationModel();
  }

  static NotificationModel? fromPayload(String? payload) {
    if (payload == null || payload.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return NotificationModel.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  static String toPayload(NotificationModel notification) {
    return jsonEncode(notification.toJson());
  }

  static String? _read(Map<String, dynamic> data, String key) {
    final value = data[key];
    final text = value?.toString();
    if (text == null || text.trim().isEmpty) {
      return null;
    }
    return text;
  }
}
