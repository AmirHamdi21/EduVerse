import 'package:flutter/material.dart';

/// Available swipe actions for notifications
enum SwipeAction { delete, markRead, markUnread, archive, bookmark, none }

/// Extension to provide UI properties for swipe actions
extension SwipeActionExtension on SwipeAction {
  IconData get icon {
    switch (this) {
      case SwipeAction.delete:
        return Icons.delete_outline_rounded;
      case SwipeAction.markRead:
        return Icons.mark_email_read_outlined;
      case SwipeAction.markUnread:
        return Icons.mark_email_unread_outlined;
      case SwipeAction.archive:
        return Icons.archive_outlined;
      case SwipeAction.bookmark:
        return Icons.bookmark_outline_rounded;
      case SwipeAction.none:
        return Icons.block_outlined;
    }
  }

  Color get color {
    switch (this) {
      case SwipeAction.delete:
        return const Color(0xFFEF4444);
      case SwipeAction.markRead:
        return const Color(0xFF10B981);
      case SwipeAction.markUnread:
        return const Color(0xFFF59E0B);
      case SwipeAction.archive:
        return const Color(0xFF3B82F6);
      case SwipeAction.bookmark:
        return const Color(0xFF8B5CF6);
      case SwipeAction.none:
        return const Color(0xFF6B7280);
    }
  }

  bool get requiresConfirmation {
    switch (this) {
      case SwipeAction.delete:
      case SwipeAction.archive:
        return true;
      case SwipeAction.markRead:
      case SwipeAction.markUnread:
      case SwipeAction.bookmark:
      case SwipeAction.none:
        return false;
    }
  }
}

/// Model for notification swipe settings
class NotificationSwipeSettings {
  final SwipeAction leftAction;
  final SwipeAction rightAction;
  final bool confirmBeforeAction;
  final double swipeSensitivity;

  const NotificationSwipeSettings({
    this.leftAction = SwipeAction.delete,
    this.rightAction = SwipeAction.markRead,
    this.confirmBeforeAction = true,
    this.swipeSensitivity = 0.4,
  });

  NotificationSwipeSettings copyWith({
    SwipeAction? leftAction,
    SwipeAction? rightAction,
    bool? confirmBeforeAction,
    double? swipeSensitivity,
  }) {
    return NotificationSwipeSettings(
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

  factory NotificationSwipeSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSwipeSettings(
      leftAction: SwipeAction.values[map['leftAction'] as int? ?? 0],
      rightAction: SwipeAction.values[map['rightAction'] as int? ?? 1],
      confirmBeforeAction: map['confirmBeforeAction'] as bool? ?? true,
      swipeSensitivity: (map['swipeSensitivity'] as num?)?.toDouble() ?? 0.4,
    );
  }
}
