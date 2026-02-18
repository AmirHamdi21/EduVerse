import 'package:equatable/equatable.dart';

/// Types of admin notifications
enum AdminNotificationType {
  userActivity,
  systemAlert,
  courseUpdate,
  announcement,
  security,
  report,
  maintenance,
  approval,
}

/// Priority levels for admin notifications
enum AdminNotificationPriority {
  low,
  normal,
  high,
  urgent,
  critical,
}

/// Category for filtering admin notifications
enum AdminNotificationCategory {
  all,
  users,
  courses,
  system,
  security,
  announcements,
  reports,
}

/// Target audience for announcements
enum AnnouncementTarget {
  all,
  students,
  instructors,
  teachingAssistants,
  admins,
  department,
  course,
}

/// Main admin notification model
class AdminNotificationModel extends Equatable {
  final String id;
  final String title;
  final String message;
  final AdminNotificationType type;
  final AdminNotificationPriority priority;
  final AdminNotificationCategory category;
  final DateTime createdAt;
  final bool isRead;
  final bool isBookmarked;
  final bool isArchived;
  final String? userId;
  final String? userName;
  final String? userRole;
  final String? courseId;
  final String? courseName;
  final String? actionUrl;
  final Map<String, String>? metadata;
  final String? imageUrl;
  final bool requiresAction;

  const AdminNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.priority = AdminNotificationPriority.normal,
    this.category = AdminNotificationCategory.all,
    required this.createdAt,
    this.isRead = false,
    this.isBookmarked = false,
    this.isArchived = false,
    this.userId,
    this.userName,
    this.userRole,
    this.courseId,
    this.courseName,
    this.actionUrl,
    this.metadata,
    this.imageUrl,
    this.requiresAction = false,
  });

  AdminNotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    AdminNotificationType? type,
    AdminNotificationPriority? priority,
    AdminNotificationCategory? category,
    DateTime? createdAt,
    bool? isRead,
    bool? isBookmarked,
    bool? isArchived,
    String? userId,
    String? userName,
    String? userRole,
    String? courseId,
    String? courseName,
    String? actionUrl,
    Map<String, String>? metadata,
    String? imageUrl,
    bool? requiresAction,
  }) {
    return AdminNotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isArchived: isArchived ?? this.isArchived,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userRole: userRole ?? this.userRole,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      actionUrl: actionUrl ?? this.actionUrl,
      metadata: metadata ?? this.metadata,
      imageUrl: imageUrl ?? this.imageUrl,
      requiresAction: requiresAction ?? this.requiresAction,
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
      'isArchived': isArchived,
      'userId': userId,
      'userName': userName,
      'userRole': userRole,
      'courseId': courseId,
      'courseName': courseName,
      'actionUrl': actionUrl,
      'metadata': metadata,
      'imageUrl': imageUrl,
      'requiresAction': requiresAction,
    };
  }

  factory AdminNotificationModel.fromJson(Map<String, dynamic> json) {
    return AdminNotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: AdminNotificationType.values[json['type'] as int],
      priority: AdminNotificationPriority.values[json['priority'] as int? ?? 1],
      category: AdminNotificationCategory.values[json['category'] as int? ?? 0],
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      isArchived: json['isArchived'] as bool? ?? false,
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      userRole: json['userRole'] as String?,
      courseId: json['courseId'] as String?,
      courseName: json['courseName'] as String?,
      actionUrl: json['actionUrl'] as String?,
      metadata: json['metadata'] != null
          ? Map<String, String>.from(json['metadata'] as Map)
          : null,
      imageUrl: json['imageUrl'] as String?,
      requiresAction: json['requiresAction'] as bool? ?? false,
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
        isArchived,
        userId,
        userName,
        userRole,
        courseId,
        courseName,
        actionUrl,
        metadata,
        imageUrl,
        requiresAction,
      ];
}

/// Admin Announcement model
class AdminAnnouncementModel extends Equatable {
  final String id;
  final String title;
  final String content;
  final AnnouncementTarget target;
  final String? targetId;
  final String? targetName;
  final AdminNotificationPriority priority;
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final DateTime? expiresAt;
  final bool isPublished;
  final bool isPinned;
  final String createdBy;
  final int viewCount;
  final List<String>? attachments;

  const AdminAnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.target,
    this.targetId,
    this.targetName,
    this.priority = AdminNotificationPriority.normal,
    required this.createdAt,
    this.scheduledAt,
    this.expiresAt,
    this.isPublished = true,
    this.isPinned = false,
    required this.createdBy,
    this.viewCount = 0,
    this.attachments,
  });

  AdminAnnouncementModel copyWith({
    String? id,
    String? title,
    String? content,
    AnnouncementTarget? target,
    String? targetId,
    String? targetName,
    AdminNotificationPriority? priority,
    DateTime? createdAt,
    DateTime? scheduledAt,
    DateTime? expiresAt,
    bool? isPublished,
    bool? isPinned,
    String? createdBy,
    int? viewCount,
    List<String>? attachments,
  }) {
    return AdminAnnouncementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      target: target ?? this.target,
      targetId: targetId ?? this.targetId,
      targetName: targetName ?? this.targetName,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isPublished: isPublished ?? this.isPublished,
      isPinned: isPinned ?? this.isPinned,
      createdBy: createdBy ?? this.createdBy,
      viewCount: viewCount ?? this.viewCount,
      attachments: attachments ?? this.attachments,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        target,
        targetId,
        targetName,
        priority,
        createdAt,
        scheduledAt,
        expiresAt,
        isPublished,
        isPinned,
        createdBy,
        viewCount,
        attachments,
      ];
}
