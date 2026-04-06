import 'package:equatable/equatable.dart';

/// Represents a course announcement broadcast.
///
/// Maps to the backend `/api/announcements` endpoints.
class AnnouncementModel extends Equatable {
  final String id;
  final String courseId;
  final String title;
  final String content;
  final int createdBy;
  final String priority; // 'low' | 'medium' | 'high'
  final DateTime publishedAt;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AnnouncementModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.content,
    required this.createdBy,
    required this.priority,
    required this.publishedAt,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id']?.toString() ?? '',
      courseId: json['courseId']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdBy: json['createdBy'] is int
          ? json['createdBy'] as int
          : int.parse(json['createdBy'].toString()),
      priority: json['priority'] as String? ?? 'low',
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'title': title,
      'content': content,
      'createdBy': createdBy,
      'priority': priority,
      'publishedAt': publishedAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        courseId,
        title,
        content,
        createdBy,
        priority,
        publishedAt,
        expiresAt,
        createdAt,
        updatedAt,
      ];
}
