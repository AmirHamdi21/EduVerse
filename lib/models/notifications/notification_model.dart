import 'package:equatable/equatable.dart';

/// Full backend-aligned notification types supported by EduVerse.
enum NotificationType {
  announcement,
  grade,
  assignment,
  message,
  deadline,
  system,
  lab,
  quiz,
  material,
  community,
  discussion,
  enrollment,
  schedule,
  officeHours,
  unknown,
}

enum NotificationPriority { low, normal, high, urgent }

enum NotificationCategory { all, courses, deadlines, messages, system }

enum NotificationSource { backendNotification, announcementFeed }

class NotificationModel extends Equatable {
  final String id;
  final int? userId;
  final String title;
  final String message;
  final NotificationType type;
  final String rawType;
  final NotificationPriority priority;
  final NotificationCategory category;
  final DateTime createdAt;
  final DateTime? readAt;
  final bool isRead;
  final bool isBookmarked;
  final String? courseId;
  final String? courseName;
  final String? instructorName;
  final String? actionUrl;
  final String? relatedEntityType;
  final String? relatedEntityId;
  final String? announcementId;
  final Map<String, String>? tags;
  final String? imageUrl;
  final DateTime? dueDate;
  final NotificationSource source;
  final bool allowsReadMutation;
  final bool allowsDeleteMutation;

  const NotificationModel({
    required this.id,
    this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.rawType,
    this.priority = NotificationPriority.normal,
    this.category = NotificationCategory.all,
    required this.createdAt,
    this.readAt,
    this.isRead = false,
    this.isBookmarked = false,
    this.courseId,
    this.courseName,
    this.instructorName,
    this.actionUrl,
    this.relatedEntityType,
    this.relatedEntityId,
    this.announcementId,
    this.tags,
    this.imageUrl,
    this.dueDate,
    this.source = NotificationSource.backendNotification,
    this.allowsReadMutation = true,
    this.allowsDeleteMutation = true,
  });

  bool get isAnnouncementFeedOnly =>
      source == NotificationSource.announcementFeed && !allowsReadMutation;

  bool get isRealtimeActionable => actionUrl != null || relatedEntityId != null;

  NotificationModel copyWith({
    String? id,
    int? userId,
    String? title,
    String? message,
    NotificationType? type,
    String? rawType,
    NotificationPriority? priority,
    NotificationCategory? category,
    DateTime? createdAt,
    DateTime? readAt,
    bool? isRead,
    bool? isBookmarked,
    String? courseId,
    String? courseName,
    String? instructorName,
    String? actionUrl,
    String? relatedEntityType,
    String? relatedEntityId,
    String? announcementId,
    Map<String, String>? tags,
    String? imageUrl,
    DateTime? dueDate,
    NotificationSource? source,
    bool? allowsReadMutation,
    bool? allowsDeleteMutation,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      rawType: rawType ?? this.rawType,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      isRead: isRead ?? this.isRead,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      instructorName: instructorName ?? this.instructorName,
      actionUrl: actionUrl ?? this.actionUrl,
      relatedEntityType: relatedEntityType ?? this.relatedEntityType,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
      announcementId: announcementId ?? this.announcementId,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      dueDate: dueDate ?? this.dueDate,
      source: source ?? this.source,
      allowsReadMutation: allowsReadMutation ?? this.allowsReadMutation,
      allowsDeleteMutation: allowsDeleteMutation ?? this.allowsDeleteMutation,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type.name,
      'rawType': rawType,
      'priority': priority.name,
      'category': category.name,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'isRead': isRead,
      'isBookmarked': isBookmarked,
      'courseId': courseId,
      'courseName': courseName,
      'instructorName': instructorName,
      'actionUrl': actionUrl,
      'relatedEntityType': relatedEntityType,
      'relatedEntityId': relatedEntityId,
      'announcementId': announcementId,
      'tags': tags,
      'imageUrl': imageUrl,
      'dueDate': dueDate?.toIso8601String(),
      'source': source.name,
      'allowsReadMutation': allowsReadMutation,
      'allowsDeleteMutation': allowsDeleteMutation,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      userId: _parseNullableInt(json['userId']),
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      type: _notificationTypeFromString(
        json['type']?.toString() ?? json['rawType']?.toString() ?? 'unknown',
      ),
      rawType:
          json['rawType']?.toString() ?? json['type']?.toString() ?? 'unknown',
      priority: _priorityFromString(json['priority']?.toString() ?? 'medium'),
      category: _categoryFromString(json['category']?.toString()),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      readAt: json['readAt'] != null
          ? DateTime.tryParse(json['readAt'].toString())
          : null,
      isRead: json['isRead'] == true,
      isBookmarked: json['isBookmarked'] == true,
      courseId: json['courseId']?.toString(),
      courseName: json['courseName']?.toString(),
      instructorName: json['instructorName']?.toString(),
      actionUrl: json['actionUrl']?.toString(),
      relatedEntityType: json['relatedEntityType']?.toString(),
      relatedEntityId: json['relatedEntityId']?.toString(),
      announcementId: json['announcementId']?.toString(),
      tags: json['tags'] is Map
          ? Map<String, String>.from(json['tags'] as Map)
          : null,
      imageUrl: json['imageUrl']?.toString(),
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'].toString())
          : null,
      source: _sourceFromString(
        json['source']?.toString() ?? NotificationSource.backendNotification.name,
      ),
      allowsReadMutation: json['allowsReadMutation'] as bool? ?? true,
      allowsDeleteMutation: json['allowsDeleteMutation'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    message,
    type,
    rawType,
    priority,
    category,
    createdAt,
    readAt,
    isRead,
    isBookmarked,
    courseId,
    courseName,
    instructorName,
    actionUrl,
    relatedEntityType,
    relatedEntityId,
    announcementId,
    tags,
    imageUrl,
    dueDate,
    source,
    allowsReadMutation,
    allowsDeleteMutation,
  ];
}

NotificationType _notificationTypeFromString(String rawType) {
  switch (rawType.trim().toLowerCase()) {
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

NotificationPriority _priorityFromString(String rawPriority) {
  switch (rawPriority.trim().toLowerCase()) {
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

NotificationCategory _categoryFromString(String? value) {
  switch ((value ?? '').trim().toLowerCase()) {
    case 'courses':
      return NotificationCategory.courses;
    case 'deadlines':
      return NotificationCategory.deadlines;
    case 'messages':
      return NotificationCategory.messages;
    case 'system':
      return NotificationCategory.system;
    case 'all':
    default:
      return NotificationCategory.all;
  }
}

NotificationSource _sourceFromString(String rawSource) {
  switch (rawSource.trim().toLowerCase()) {
    case 'announcementfeed':
    case 'announcement_feed':
      return NotificationSource.announcementFeed;
    case 'backendnotification':
    case 'backend_notification':
    default:
      return NotificationSource.backendNotification;
  }
}

int? _parseNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

class AIInsightModel extends Equatable {
  final String id;
  final String title;
  final String message;
  final AIInsightType insightType;
  final String? actionText;
  final String? actionUrl;
  final DateTime createdAt;
  final bool isDismissed;

  const AIInsightModel({
    required this.id,
    required this.title,
    required this.message,
    required this.insightType,
    this.actionText,
    this.actionUrl,
    required this.createdAt,
    this.isDismissed = false,
  });

  AIInsightModel copyWith({
    String? id,
    String? title,
    String? message,
    AIInsightType? insightType,
    String? actionText,
    String? actionUrl,
    DateTime? createdAt,
    bool? isDismissed,
  }) {
    return AIInsightModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      insightType: insightType ?? this.insightType,
      actionText: actionText ?? this.actionText,
      actionUrl: actionUrl ?? this.actionUrl,
      createdAt: createdAt ?? this.createdAt,
      isDismissed: isDismissed ?? this.isDismissed,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    message,
    insightType,
    actionText,
    actionUrl,
    createdAt,
    isDismissed,
  ];
}

enum AIInsightType { performanceAlert, recommendation, studyTip, reminder }

class SystemAlertModel extends Equatable {
  final String id;
  final String title;
  final String message;
  final SystemAlertType alertType;
  final DateTime createdAt;
  final bool isDismissed;
  final String? actionText;

  const SystemAlertModel({
    required this.id,
    required this.title,
    required this.message,
    required this.alertType,
    required this.createdAt,
    this.isDismissed = false,
    this.actionText,
  });

  SystemAlertModel copyWith({
    String? id,
    String? title,
    String? message,
    SystemAlertType? alertType,
    DateTime? createdAt,
    bool? isDismissed,
    String? actionText,
  }) {
    return SystemAlertModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      alertType: alertType ?? this.alertType,
      createdAt: createdAt ?? this.createdAt,
      isDismissed: isDismissed ?? this.isDismissed,
      actionText: actionText ?? this.actionText,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    message,
    alertType,
    createdAt,
    isDismissed,
    actionText,
  ];
}

enum SystemAlertType { update, maintenance, announcement, warning }
