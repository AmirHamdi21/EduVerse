import 'package:flutter/material.dart';

/// Available swipe actions for chat conversations
enum ChatSwipeAction {
  delete,
  archive,
  pin,
  mute,
  markRead,
  markUnread,
  none,
}

/// Extension to provide UI properties for chat swipe actions
extension ChatSwipeActionExtension on ChatSwipeAction {
  IconData get icon {
    switch (this) {
      case ChatSwipeAction.delete:
        return Icons.delete_outline_rounded;
      case ChatSwipeAction.archive:
        return Icons.archive_outlined;
      case ChatSwipeAction.pin:
        return Icons.push_pin_outlined;
      case ChatSwipeAction.mute:
        return Icons.notifications_off_outlined;
      case ChatSwipeAction.markRead:
        return Icons.mark_chat_read_outlined;
      case ChatSwipeAction.markUnread:
        return Icons.mark_chat_unread_outlined;
      case ChatSwipeAction.none:
        return Icons.block_outlined;
    }
  }

  Color get color {
    switch (this) {
      case ChatSwipeAction.delete:
        return const Color(0xFFEF4444);
      case ChatSwipeAction.archive:
        return const Color(0xFF3B82F6);
      case ChatSwipeAction.pin:
        return const Color(0xFFF59E0B);
      case ChatSwipeAction.mute:
        return const Color(0xFF6B7280);
      case ChatSwipeAction.markRead:
        return const Color(0xFF10B981);
      case ChatSwipeAction.markUnread:
        return const Color(0xFF8B5CF6);
      case ChatSwipeAction.none:
        return const Color(0xFF6B7280);
    }
  }

  bool get requiresConfirmation {
    switch (this) {
      case ChatSwipeAction.delete:
      case ChatSwipeAction.archive:
        return true;
      case ChatSwipeAction.pin:
      case ChatSwipeAction.mute:
      case ChatSwipeAction.markRead:
      case ChatSwipeAction.markUnread:
      case ChatSwipeAction.none:
        return false;
    }
  }
}

/// Model for chat swipe settings
class ChatSwipeSettings {
  final ChatSwipeAction leftAction;
  final ChatSwipeAction rightAction;
  final bool confirmBeforeAction;
  final double swipeSensitivity;

  const ChatSwipeSettings({
    this.leftAction = ChatSwipeAction.delete,
    this.rightAction = ChatSwipeAction.archive,
    this.confirmBeforeAction = true,
    this.swipeSensitivity = 0.4,
  });

  ChatSwipeSettings copyWith({
    ChatSwipeAction? leftAction,
    ChatSwipeAction? rightAction,
    bool? confirmBeforeAction,
    double? swipeSensitivity,
  }) {
    return ChatSwipeSettings(
      leftAction: leftAction ?? this.leftAction,
      rightAction: rightAction ?? this.rightAction,
      confirmBeforeAction: confirmBeforeAction ?? this.confirmBeforeAction,
      swipeSensitivity: swipeSensitivity ?? this.swipeSensitivity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'leftAction': leftAction.index,
      'rightAction': rightAction.index,
      'confirmBeforeAction': confirmBeforeAction,
      'swipeSensitivity': swipeSensitivity,
    };
  }

  factory ChatSwipeSettings.fromMap(Map<String, dynamic> map) {
    return ChatSwipeSettings(
      leftAction: ChatSwipeAction.values[map['leftAction'] as int? ?? 0],
      rightAction: ChatSwipeAction.values[map['rightAction'] as int? ?? 1],
      confirmBeforeAction: map['confirmBeforeAction'] as bool? ?? true,
      swipeSensitivity: (map['swipeSensitivity'] as num?)?.toDouble() ?? 0.4,
    );
  }
}
