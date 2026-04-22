import 'package:equatable/equatable.dart';

/// Represents a discussion thread within a course forum.
///
/// Maps to the backend `/api/discussions` endpoints.
class DiscussionThreadModel extends Equatable {
  final String id;
  final String forumId;
  final String title;
  final String content;
  final int createdBy;
  final bool isPinned;
  final bool isLocked;
  final int replyCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DiscussionThreadModel({
    required this.id,
    required this.forumId,
    required this.title,
    required this.content,
    required this.createdBy,
    required this.isPinned,
    required this.isLocked,
    required this.replyCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DiscussionThreadModel.fromJson(Map<String, dynamic> json) {
    return DiscussionThreadModel(
      id: json['id']?.toString() ?? '',
      forumId: json['forumId']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdBy: json['createdBy'] is int
          ? json['createdBy'] as int
          : int.parse(json['createdBy'].toString()),
      isPinned: json['isPinned'] == true || json['isPinned'] == 1,
      isLocked: json['isLocked'] == true || json['isLocked'] == 1,
      replyCount: json['replyCount'] is int
          ? json['replyCount'] as int
          : int.tryParse(json['replyCount']?.toString() ?? '') ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'forumId': forumId,
      'title': title,
      'content': content,
      'createdBy': createdBy,
      'isPinned': isPinned,
      'isLocked': isLocked,
      'replyCount': replyCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    forumId,
    title,
    content,
    createdBy,
    isPinned,
    isLocked,
    replyCount,
    createdAt,
    updatedAt,
  ];
}
