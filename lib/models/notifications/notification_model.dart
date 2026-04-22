import 'package:equatable/equatable.dart';

/// Types of notifications in EduVerse
enum NotificationType {
  assignment,
  lecture,
  message,
  exam,
  course,
  lab,
  aiInsight,
  aiRecommendation,
  system,
  announcement,
}

/// Priority levels for notifications
enum NotificationPriority { low, normal, high, urgent }

/// Category for filtering notifications
enum NotificationCategory {
  all,
  courses,
  deadlines,
  messages,
  aiInsights,
  system,
}

/// Main notification model for EduVerse
class NotificationModel extends Equatable {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationPriority priority;
  final NotificationCategory category;
  final DateTime createdAt;
  final bool isRead;
  final bool isBookmarked;
  final String? courseId;
  final String? courseName;
  final String? instructorName;
  final String? actionUrl;
  final Map<String, String>? tags;
  final String? imageUrl;
  final DateTime? dueDate;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.priority = NotificationPriority.normal,
    this.category = NotificationCategory.all,
    required this.createdAt,
    this.isRead = false,
    this.isBookmarked = false,
    this.courseId,
    this.courseName,
    this.instructorName,
    this.actionUrl,
    this.tags,
    this.imageUrl,
    this.dueDate,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    NotificationPriority? priority,
    NotificationCategory? category,
    DateTime? createdAt,
    bool? isRead,
    bool? isBookmarked,
    String? courseId,
    String? courseName,
    String? instructorName,
    String? actionUrl,
    Map<String, String>? tags,
    String? imageUrl,
    DateTime? dueDate,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      instructorName: instructorName ?? this.instructorName,
      actionUrl: actionUrl ?? this.actionUrl,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.index,
      'priority': priority.index,
      'category': category.index,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'isBookmarked': isBookmarked,
      'courseId': courseId,
      'courseName': courseName,
      'instructorName': instructorName,
      'actionUrl': actionUrl,
      'tags': tags,
      'imageUrl': imageUrl,
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: NotificationType.values[json['type'] as int],
      priority: NotificationPriority.values[json['priority'] as int? ?? 1],
      category: NotificationCategory.values[json['category'] as int? ?? 0],
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      courseId: json['courseId'] as String?,
      courseName: json['courseName'] as String?,
      instructorName: json['instructorName'] as String?,
      actionUrl: json['actionUrl'] as String?,
      tags: json['tags'] != null
          ? Map<String, String>.from(json['tags'] as Map)
          : null,
      imageUrl: json['imageUrl'] as String?,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    message,
    type,
    priority,
    category,
    createdAt,
    isRead,
    isBookmarked,
    courseId,
    courseName,
    instructorName,
    actionUrl,
    tags,
    imageUrl,
    dueDate,
  ];
}

/// AI Insight model for special AI-related notifications
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

/// System Alert model
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
