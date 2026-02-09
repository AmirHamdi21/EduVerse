import 'package:flutter/material.dart';

/// Notification type for instructors
enum InstructorNotificationType {
  submission,
  grading,
  announcement,
  message,
  course,
  attendance,
  deadline,
  system,
}

extension InstructorNotificationTypeExtension on InstructorNotificationType {
  String get displayName {
    switch (this) {
      case InstructorNotificationType.submission:
        return 'Submission';
      case InstructorNotificationType.grading:
        return 'Grading';
      case InstructorNotificationType.announcement:
        return 'Announcement';
      case InstructorNotificationType.message:
        return 'Message';
      case InstructorNotificationType.course:
        return 'Course';
      case InstructorNotificationType.attendance:
        return 'Attendance';
      case InstructorNotificationType.deadline:
        return 'Deadline';
      case InstructorNotificationType.system:
        return 'System';
    }
  }

  IconData get icon {
    switch (this) {
      case InstructorNotificationType.submission:
        return Icons.upload_file_outlined;
      case InstructorNotificationType.grading:
        return Icons.grading_outlined;
      case InstructorNotificationType.announcement:
        return Icons.campaign_outlined;
      case InstructorNotificationType.message:
        return Icons.chat_bubble_outline;
      case InstructorNotificationType.course:
        return Icons.school_outlined;
      case InstructorNotificationType.attendance:
        return Icons.how_to_reg_outlined;
      case InstructorNotificationType.deadline:
        return Icons.alarm_outlined;
      case InstructorNotificationType.system:
        return Icons.info_outline;
    }
  }

  Color get color {
    switch (this) {
      case InstructorNotificationType.submission:
        return const Color(0xFF155CFB);
      case InstructorNotificationType.grading:
        return const Color(0xFF10B981);
      case InstructorNotificationType.announcement:
        return const Color(0xFF8B5CF6);
      case InstructorNotificationType.message:
        return const Color(0xFF06B6D4);
      case InstructorNotificationType.course:
        return const Color(0xFF14B8A6);
      case InstructorNotificationType.attendance:
        return const Color(0xFFF59E0B);
      case InstructorNotificationType.deadline:
        return const Color(0xFFEF4444);
      case InstructorNotificationType.system:
        return const Color(0xFF64748B);
    }
  }

  Color get lightColor {
    switch (this) {
      case InstructorNotificationType.submission:
        return const Color(0xFFEEF5FF);
      case InstructorNotificationType.grading:
        return const Color(0xFFD1FAE5);
      case InstructorNotificationType.announcement:
        return const Color(0xFFEDE9FE);
      case InstructorNotificationType.message:
        return const Color(0xFFCFFAFE);
      case InstructorNotificationType.course:
        return const Color(0xFFCCFBF1);
      case InstructorNotificationType.attendance:
        return const Color(0xFFFEF3C7);
      case InstructorNotificationType.deadline:
        return const Color(0xFFFEE2E2);
      case InstructorNotificationType.system:
        return const Color(0xFFF1F5F9);
    }
  }
}

/// Instructor notification model
class InstructorNotification {
  final String id;
  final String title;
  final String message;
  final InstructorNotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final String? route;
  final Map<String, dynamic>? extra;
  final String? senderName;
  final String? senderAvatar;

  const InstructorNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.route,
    this.extra,
    this.senderName,
    this.senderAvatar,
  });

  InstructorNotification copyWith({
    String? id,
    String? title,
    String? message,
    InstructorNotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    String? route,
    Map<String, dynamic>? extra,
    String? senderName,
    String? senderAvatar,
  }) {
    return InstructorNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      route: route ?? this.route,
      extra: extra ?? this.extra,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

/// Notification filter for instructors
class InstructorNotificationFilter {
  final Set<InstructorNotificationType> types;
  final bool showRead;
  final bool showUnread;

  const InstructorNotificationFilter({
    this.types = const {},
    this.showRead = true,
    this.showUnread = true,
  });

  bool get hasActiveFilters => types.isNotEmpty || !showRead || !showUnread;

  InstructorNotificationFilter copyWith({
    Set<InstructorNotificationType>? types,
    bool? showRead,
    bool? showUnread,
  }) {
    return InstructorNotificationFilter(
      types: types ?? this.types,
      showRead: showRead ?? this.showRead,
      showUnread: showUnread ?? this.showUnread,
    );
  }
}
