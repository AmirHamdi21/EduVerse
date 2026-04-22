import 'package:equatable/equatable.dart';

class AnnouncementAuthor extends Equatable {
  final int? userId;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? profilePictureUrl;

  const AnnouncementAuthor({
    this.userId,
    this.firstName,
    this.lastName,
    this.email,
    this.profilePictureUrl,
  });

  factory AnnouncementAuthor.fromJson(Map<String, dynamic> json) {
    return AnnouncementAuthor(
      userId: json['userId'] as int?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: json['email'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
    );
  }

  String get displayName {
    final name = '${firstName ?? ''} ${lastName ?? ''}'.trim();
    return name.isNotEmpty ? name : (email ?? 'System');
  }

  @override
  List<Object?> get props => [userId, firstName, lastName, email];
}

class AnnouncementCourse extends Equatable {
  final String? id;
  final String? name;
  final String? code;

  const AnnouncementCourse({this.id, this.name, this.code});

  factory AnnouncementCourse.fromJson(Map<String, dynamic> json) {
    return AnnouncementCourse(
      id: json['id']?.toString(),
      name: json['name'] as String?,
      code: json['code'] as String?,
    );
  }

  String get displayLabel {
    if (name != null || code != null) {
      return '${name ?? ''}${code != null ? ' ($code)' : ''}'.trim();
    }
    return 'Campus-wide';
  }

  @override
  List<Object?> get props => [id, name, code];
}

class AnnouncementModel extends Equatable {
  final String id;
  final String? courseId;
  final int? createdBy;
  final String title;
  final String content;
  final String? announcementType;
  final String priority;
  final String? targetAudience;
  final int isPublished;
  final int? isPinned;
  final int viewCount;
  final String? attachmentFileId;
  final DateTime? publishedAt;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final AnnouncementAuthor? author;
  final AnnouncementCourse? course;

  const AnnouncementModel({
    required this.id,
    this.courseId,
    this.createdBy,
    required this.title,
    required this.content,
    this.announcementType,
    required this.priority,
    this.targetAudience,
    this.isPublished = 0,
    this.isPinned,
    this.viewCount = 0,
    this.attachmentFileId,
    this.publishedAt,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
    this.author,
    this.course,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id']?.toString() ?? '',
      courseId: json['courseId']?.toString(),
      createdBy: json['createdBy'] as int?,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      announcementType: json['announcementType'] as String?,
      priority: json['priority'] as String? ?? 'medium',
      targetAudience: json['targetAudience'] as String?,
      isPublished: json['isPublished'] is bool
          ? (json['isPublished'] as bool ? 1 : 0)
          : (json['isPublished'] as int? ?? 0),
      isPinned: json['isPinned'] is bool
          ? (json['isPinned'] as bool ? 1 : 0)
          : json['isPinned'] as int?,
      viewCount: json['viewCount'] as int? ?? 0,
      attachmentFileId: json['attachmentFileId']?.toString(),
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'].toString())
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'].toString())
          : null,
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
      author: json['author'] is Map<String, dynamic>
          ? AnnouncementAuthor.fromJson(json['author'] as Map<String, dynamic>)
          : null,
      course: json['course'] is Map<String, dynamic>
          ? AnnouncementCourse.fromJson(json['course'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'courseId': courseId,
    'title': title,
    'content': content,
    'announcementType': announcementType,
    'priority': priority,
    'targetAudience': targetAudience,
    'isPublished': isPublished,
    'isPinned': isPinned,
    'viewCount': viewCount,
    'publishedAt': publishedAt?.toIso8601String(),
    'expiresAt': expiresAt?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [id, title, isPublished, isPinned, updatedAt];
}
