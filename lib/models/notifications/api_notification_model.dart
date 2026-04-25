import '../admin/admin_notification_model.dart';
import '../instructor/instrucor_notification_model.dart';
import 'notification_model.dart';

/// Normalized backend notification transport model.
class ApiNotificationModel {
  final String id;
  final int? userId;
  final String type;
  final String title;
  final String body;
  final bool isRead;
  final String priority;
  final String? actionUrl;
  final String? relatedEntityType;
  final String? relatedEntityId;
  final String? announcementId;
  final DateTime createdAt;
  final DateTime? readAt;
  final Map<String, dynamic>? rawData;

  const ApiNotificationModel({
    required this.id,
    this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    this.priority = 'medium',
    this.actionUrl,
    this.relatedEntityType,
    this.relatedEntityId,
    this.announcementId,
    required this.createdAt,
    this.readAt,
    this.rawData,
  });

  factory ApiNotificationModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['notificationId'] ?? '';
    final body =
        (json['body'] as String?) ?? (json['message'] as String?) ?? '';

    final rawIsRead = json['isRead'];
    final isRead = rawIsRead is bool
        ? rawIsRead
        : rawIsRead is num
        ? rawIsRead != 0
        : json['read'] == true;

    final type =
        (json['notificationType'] as String?) ??
        (json['type'] as String?) ??
        'system';

    final priority = (json['priority'] as String?) ?? 'medium';

    final createdAt =
        DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
        DateTime.now();
    final readAt = json['readAt'] != null
        ? DateTime.tryParse(json['readAt'].toString())
        : null;

    return ApiNotificationModel(
      id: rawId.toString(),
      userId: _parseNullableInt(json['userId']),
      type: type,
      title: (json['title'] as String?) ?? 'Notification',
      body: body,
      isRead: isRead,
      priority: priority,
      actionUrl: json['actionUrl']?.toString(),
      relatedEntityType: json['relatedEntityType']?.toString(),
      relatedEntityId: json['relatedEntityId']?.toString(),
      announcementId: json['announcementId']?.toString(),
      createdAt: createdAt,
      readAt: readAt,
      rawData: json,
    );
  }

  NotificationModel toNotificationModel() {
    final rawType = type.trim().toLowerCase();
    final resolvedType = _mapToNotificationType(rawType);
    return NotificationModel(
      id: id,
      userId: userId,
      title: title,
      message: body,
      type: resolvedType,
      rawType: rawType,
      priority: _mapToNotificationPriority(priority),
      category: _mapToNotificationCategory(resolvedType),
      createdAt: createdAt,
      readAt: readAt,
      isRead: isRead,
      actionUrl: actionUrl,
      relatedEntityType: relatedEntityType,
      relatedEntityId: relatedEntityId,
      announcementId: announcementId,
      courseId: _extractString(rawData?['courseId']),
      courseName: _extractCourseName(rawData),
      instructorName: _extractInstructorName(rawData),
      source: NotificationSource.backendNotification,
      allowsReadMutation: true,
      allowsDeleteMutation: true,
    );
  }

  InstructorNotificationModel toInstructorNotification() {
    final notification = toNotificationModel();
    return InstructorNotificationModel(
      id: notification.id,
      title: notification.title,
      message: notification.message,
      type: _mapToInstructorType(notification.type),
      timestamp: notification.createdAt,
      isRead: notification.isRead,
      studentName: null,
      courseName: notification.courseName,
      metadata: <String, dynamic>{
        'rawType': notification.rawType,
        'actionUrl': notification.actionUrl,
        'relatedEntityType': notification.relatedEntityType,
        'relatedEntityId': notification.relatedEntityId,
      },
    );
  }

  AdminNotificationModel toAdminNotificationModel() {
    final notification = toNotificationModel();
    return AdminNotificationModel(
      id: notification.id,
      title: notification.title,
      message: notification.message,
      type: _mapToAdminType(notification.type),
      priority: _mapToAdminPriority(notification.priority),
      category: _mapToAdminCategory(notification.type),
      createdAt: notification.createdAt,
      isRead: notification.isRead,
    );
  }

  static NotificationType _mapToNotificationType(String type) {
    switch (type) {
      case 'announcement':
        return NotificationType.announcement;
      case 'grade':
        return NotificationType.grade;
      case 'assignment':
        return NotificationType.assignment;
      case 'message':
        return NotificationType.message;
      case 'deadline':
        return NotificationType.deadline;
      case 'system':
        return NotificationType.system;
      case 'lab':
        return NotificationType.lab;
      case 'quiz':
        return NotificationType.quiz;
      case 'material':
        return NotificationType.material;
      case 'community':
        return NotificationType.community;
      case 'discussion':
        return NotificationType.discussion;
      case 'enrollment':
        return NotificationType.enrollment;
      case 'schedule':
        return NotificationType.schedule;
      case 'office_hours':
        return NotificationType.officeHours;
      default:
        return NotificationType.unknown;
    }
  }

  static NotificationCategory _mapToNotificationCategory(NotificationType type) {
    switch (type) {
      case NotificationType.assignment:
      case NotificationType.lab:
      case NotificationType.quiz:
      case NotificationType.material:
      case NotificationType.enrollment:
      case NotificationType.grade:
        return NotificationCategory.courses;
      case NotificationType.deadline:
      case NotificationType.schedule:
      case NotificationType.officeHours:
        return NotificationCategory.deadlines;
      case NotificationType.message:
      case NotificationType.community:
      case NotificationType.discussion:
      case NotificationType.announcement:
        return NotificationCategory.messages;
      case NotificationType.system:
      case NotificationType.unknown:
        return NotificationCategory.system;
    }
  }

  static NotificationPriority _mapToNotificationPriority(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return NotificationPriority.urgent;
      case 'high':
        return NotificationPriority.high;
      case 'low':
        return NotificationPriority.low;
      case 'medium':
      default:
        return NotificationPriority.normal;
    }
  }

  static InstructorNotificationType _mapToInstructorType(
    NotificationType type,
  ) {
    switch (type) {
      case NotificationType.assignment:
      case NotificationType.lab:
      case NotificationType.quiz:
        return InstructorNotificationType.submission;
      case NotificationType.grade:
        return InstructorNotificationType.grading;
      case NotificationType.message:
      case NotificationType.community:
      case NotificationType.discussion:
        return InstructorNotificationType.message;
      case NotificationType.deadline:
      case NotificationType.schedule:
      case NotificationType.officeHours:
        return InstructorNotificationType.deadline;
      case NotificationType.announcement:
        return InstructorNotificationType.announcement;
      case NotificationType.enrollment:
        return InstructorNotificationType.attendance;
      case NotificationType.material:
      case NotificationType.system:
      case NotificationType.unknown:
        return InstructorNotificationType.system;
    }
  }

  static AdminNotificationType _mapToAdminType(NotificationType type) {
    switch (type) {
      case NotificationType.assignment:
      case NotificationType.lab:
      case NotificationType.quiz:
        return AdminNotificationType.approval;
      case NotificationType.grade:
        return AdminNotificationType.report;
      case NotificationType.announcement:
      case NotificationType.system:
      case NotificationType.schedule:
      case NotificationType.officeHours:
      case NotificationType.deadline:
        return AdminNotificationType.systemAlert;
      case NotificationType.enrollment:
      case NotificationType.message:
      case NotificationType.community:
      case NotificationType.discussion:
      case NotificationType.material:
      case NotificationType.unknown:
        return AdminNotificationType.userActivity;
    }
  }

  static AdminNotificationPriority _mapToAdminPriority(
    NotificationPriority priority,
  ) {
    switch (priority) {
      case NotificationPriority.urgent:
        return AdminNotificationPriority.urgent;
      case NotificationPriority.high:
        return AdminNotificationPriority.high;
      case NotificationPriority.low:
        return AdminNotificationPriority.low;
      case NotificationPriority.normal:
        return AdminNotificationPriority.normal;
    }
  }

  static AdminNotificationCategory _mapToAdminCategory(NotificationType type) {
    switch (type) {
      case NotificationType.assignment:
      case NotificationType.lab:
      case NotificationType.quiz:
      case NotificationType.grade:
      case NotificationType.material:
        return AdminNotificationCategory.courses;
      case NotificationType.enrollment:
      case NotificationType.message:
      case NotificationType.community:
      case NotificationType.discussion:
        return AdminNotificationCategory.users;
      case NotificationType.announcement:
      case NotificationType.system:
      case NotificationType.deadline:
      case NotificationType.schedule:
      case NotificationType.officeHours:
      case NotificationType.unknown:
        return AdminNotificationCategory.system;
    }
  }
}

int? _parseNullableInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

String? _extractString(dynamic value) {
  final text = value?.toString();
  if (text == null || text.trim().isEmpty) return null;
  return text;
}

String? _extractCourseName(Map<String, dynamic>? json) {
  if (json == null) return null;
  final course = json['course'];
  if (course is Map<String, dynamic>) {
    final code = _extractString(course['code']);
    final name = _extractString(course['name']);
    final combined = [if (code != null) code, if (name != null) name].join(' - ');
    return combined.isEmpty ? name : combined;
  }
  return _extractString(json['courseName']);
}

String? _extractInstructorName(Map<String, dynamic>? json) {
  if (json == null) return null;
  final author = json['author'];
  if (author is Map<String, dynamic>) {
    final firstName = _extractString(author['firstName']);
    final lastName = _extractString(author['lastName']);
    final fullName = [if (firstName != null) firstName, if (lastName != null) lastName]
        .join(' ')
        .trim();
    if (fullName.isNotEmpty) return fullName;
  }
  return _extractString(json['instructorName']);
}
