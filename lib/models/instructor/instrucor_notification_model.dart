enum InstructorNotificationType {
  submission,
  grading,
  message,
  deadline,
  attendance,
  announcement,
  system,
}

class InstructorNotificationModel {
  final String id;
  final String title;
  final String message;
  final InstructorNotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final String? studentName;
  final String? courseName;
  final String? avatarUrl;
  final Map<String, dynamic>? metadata;

  const InstructorNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.studentName,
    this.courseName,
    this.avatarUrl,
    this.metadata,
  });

  InstructorNotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    InstructorNotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    String? studentName,
    String? courseName,
    String? avatarUrl,
    Map<String, dynamic>? metadata,
  }) {
    return InstructorNotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      studentName: studentName ?? this.studentName,
      courseName: courseName ?? this.courseName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      metadata: metadata ?? this.metadata,
    );
  }
}
