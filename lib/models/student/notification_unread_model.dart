import 'package:equatable/equatable.dart';

class NotificationUnreadModel extends Equatable {
  final int unreadCount;

  const NotificationUnreadModel({required this.unreadCount});

  factory NotificationUnreadModel.fromJson(Map<String, dynamic> json) {
    final payload = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return NotificationUnreadModel(
      unreadCount: _parseInt(
        payload['unreadCount'] ?? payload['count'] ?? payload['totalUnread'],
      ),
    );
  }

  @override
  List<Object?> get props => <Object?>[unreadCount];
}

int _parseInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
