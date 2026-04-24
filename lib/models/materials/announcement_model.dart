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
      userId: _toNullableInt(json['userId']),
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
      email: json['email']?.toString(),
      profilePictureUrl: json['profilePictureUrl']?.toString(),
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
      name: json['name']?.toString(),
      code: json['code']?.toString(),
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
      createdBy: _toNullableInt(json['createdBy']),
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      announcementType: json['announcementType']?.toString(),
      priority: json['priority']?.toString() ?? 'medium',
      targetAudience: json['targetAudience']?.toString(),
      isPublished: _toBoolInt(json['isPublished']),
      isPinned: json.containsKey('isPinned')
          ? _toNullableBoolInt(json['isPinned'])
          : null,
      viewCount: _toNullableInt(json['viewCount']) ?? 0,
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

int? _toNullableInt(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value.toString());
}

int _toBoolInt(dynamic value) {
  if (value is bool) {
    return value ? 1 : 0;
  }

  final parsed = _toNullableInt(value);
  if (parsed != null) {
    return parsed == 0 ? 0 : 1;
  }

  final normalized = value?.toString().trim().toLowerCase();
  if (normalized == 'true') {
    return 1;
  }
  if (normalized == 'false') {
    return 0;
  }
  return 0;
}

int? _toNullableBoolInt(dynamic value) {
  if (value == null) {
    return null;
  }
  return _toBoolInt(value);
}
