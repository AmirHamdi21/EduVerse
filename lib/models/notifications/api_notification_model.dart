import '../instructor/instrucor_notification_model.dart';
import '../admin/admin_notification_model.dart';
import 'notification_model.dart';

/// Lightweight model that maps 1:1 to the backend notification JSON shape.
///
/// Handles the normalizer logic from the web frontend:
///   - `id` / `notificationId` aliasing
///   - `body` / `message` aliasing
///   - `isRead` as int(0|1) → bool
///   - `notificationType` string → enum
///   - `priority` string → enum
class ApiNotificationModel {
  final String id;
  final int? userId;
  final String type;
  final String title;
  final String body;
  final bool isRead;
  final String priority;
  final String? actionUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ApiNotificationModel({
    required this.id,
    this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    this.priority = 'medium',
    this.actionUrl,
    required this.createdAt,
    this.updatedAt,
  });

  /// Normalizer factory — handles all the field aliasing the web frontend does.
  factory ApiNotificationModel.fromJson(Map<String, dynamic> json) {
    // ID normalization: 'id' or 'notificationId'
    final rawId = json['id'] ?? json['notificationId'] ?? '';
    final id = rawId.toString();

    // Body normalization: 'body' or 'message'
    final body = (json['body'] as String?) ??
        (json['message'] as String?) ??
        '';

    // isRead normalization: bool or int(0|1)
    final rawIsRead = json['isRead'];
    bool isRead;
    if (rawIsRead is bool) {
      isRead = rawIsRead;
    } else if (rawIsRead is int) {
      isRead = rawIsRead != 0;
    } else {
      isRead = false;
    }

    // Type normalization
    final type = (json['notificationType'] as String?) ??
        (json['type'] as String?) ??
        'system';

    // Priority normalization
    final priority = (json['priority'] as String?) ?? 'medium';

    // Date parsing
    DateTime createdAt;
    try {
      createdAt = DateTime.parse(json['createdAt'].toString());
    } catch (_) {
      createdAt = DateTime.now();
    }

    DateTime? updatedAt;
    if (json['updatedAt'] != null) {
      try {
        updatedAt = DateTime.parse(json['updatedAt'].toString());
      } catch (_) {
        updatedAt = null;
      }
    }

    return ApiNotificationModel(
      id: id,
      userId: json['userId'] is int ? json['userId'] as int : null,
      type: type,
      title: (json['title'] as String?) ?? 'Notification',
      body: body,
      isRead: isRead,
      priority: priority,
      actionUrl: json['actionUrl'] as String?,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // ── Converters to role-specific models ──────────────────────────

  /// Convert to the Student `NotificationModel`.
  NotificationModel toNotificationModel() {
    return NotificationModel(
      id: id,
      title: title,
      message: body,
      type: _mapToNotificationType(type),
      category: _mapToNotificationCategory(type),
      priority: _mapToNotificationPriority(priority),
      createdAt: createdAt,
      isRead: isRead,
      actionUrl: actionUrl,
    );
  }

  /// Convert to the Instructor `InstructorNotificationModel`.
  InstructorNotificationModel toInstructorNotification() {
    return InstructorNotificationModel(
      id: id,
      title: title,
      message: body,
      type: _mapToInstructorType(type),
      timestamp: createdAt,
      isRead: isRead,
    );
  }

  /// Convert to the Admin `AdminNotificationModel`.
  AdminNotificationModel toAdminNotificationModel() {
    return AdminNotificationModel(
      id: id,
      title: title,
      message: body,
      type: _mapToAdminType(type),
      priority: _mapToAdminPriority(priority),
      category: _mapToAdminCategory(type),
      createdAt: createdAt,
      isRead: isRead,
    );
  }

  // ── Private mapping helpers ─────────────────────────────────────

  static NotificationType _mapToNotificationType(String type) {
    switch (type.toLowerCase()) {
      case 'assignment':
        return NotificationType.assignment;
      case 'grade':
        return NotificationType.course;
      case 'announcement':
        return NotificationType.announcement;
      case 'enrollment':
        return NotificationType.course;
      case 'system':
      default:
        return NotificationType.system;
    }
  }

  static NotificationCategory _mapToNotificationCategory(String type) {
    switch (type.toLowerCase()) {
      case 'assignment':
        return NotificationCategory.deadlines;
      case 'grade':
        return NotificationCategory.courses;
      case 'announcement':
        return NotificationCategory.system;
      case 'enrollment':
        return NotificationCategory.courses;
      case 'system':
      default:
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



  static InstructorNotificationType _mapToInstructorType(String type) {
    switch (type.toLowerCase()) {
      case 'assignment':
        return InstructorNotificationType.submission;
      case 'grade':
        return InstructorNotificationType.grading;
      case 'announcement':
        return InstructorNotificationType.announcement;
      case 'enrollment':
        return InstructorNotificationType.attendance;
      case 'system':
      default:
        return InstructorNotificationType.system;
    }
  }

  static AdminNotificationType _mapToAdminType(String type) {
    switch (type.toLowerCase()) {
      case 'assignment':
        return AdminNotificationType.approval;
      case 'grade':
        return AdminNotificationType.report;
      case 'announcement':
        return AdminNotificationType.systemAlert;
      case 'enrollment':
        return AdminNotificationType.userActivity;
      case 'system':
      default:
        return AdminNotificationType.maintenance;
    }
  }

  static AdminNotificationPriority _mapToAdminPriority(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return AdminNotificationPriority.urgent;
      case 'high':
        return AdminNotificationPriority.high;
      case 'low':
        return AdminNotificationPriority.low;
      case 'medium':
      default:
        return AdminNotificationPriority.normal;
    }
  }

  static AdminNotificationCategory _mapToAdminCategory(String type) {
    switch (type.toLowerCase()) {
      case 'assignment':
      case 'grade':
        return AdminNotificationCategory.courses;
      case 'announcement':
      case 'system':
        return AdminNotificationCategory.system;
      case 'enrollment':
        return AdminNotificationCategory.users;
      default:
        return AdminNotificationCategory.system;
    }
  }
}
