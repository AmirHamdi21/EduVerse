// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discussion_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DiscussionThreadImpl _$$DiscussionThreadImplFromJson(
  Map<String, dynamic> json,
) => _$DiscussionThreadImpl(
  id: (json['id'] as num).toInt(),
  courseId: (json['courseId'] as num?)?.toInt(),
  createdBy: (json['createdBy'] as num).toInt(),
  createdByName: json['createdByName'] as String? ?? '',
  title: json['title'] as String,
  description: json['description'] as String,
  isPinned: json['isPinned'] as bool? ?? false,
  isLocked: json['isLocked'] as bool? ?? false,
  viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
  replyCount: (json['replyCount'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$DiscussionThreadImplToJson(
  _$DiscussionThreadImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'courseId': instance.courseId,
  'createdBy': instance.createdBy,
  'createdByName': instance.createdByName,
  'title': instance.title,
  'description': instance.description,
  'isPinned': instance.isPinned,
  'isLocked': instance.isLocked,
  'viewCount': instance.viewCount,
  'replyCount': instance.replyCount,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

_$DiscussionReplyImpl _$$DiscussionReplyImplFromJson(
  Map<String, dynamic> json,
) => _$DiscussionReplyImpl(
  id: (json['id'] as num).toInt(),
  threadId: (json['threadId'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  userName: json['userName'] as String? ?? '',
  messageText: json['messageText'] as String,
  parentMessageId: (json['parentMessageId'] as num?)?.toInt(),
  isAnswer: json['isAnswer'] as bool? ?? false,
  isEndorsed: json['isEndorsed'] as bool? ?? false,
  endorsedBy: (json['endorsedBy'] as num?)?.toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$DiscussionReplyImplToJson(
  _$DiscussionReplyImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'threadId': instance.threadId,
  'userId': instance.userId,
  'userName': instance.userName,
  'messageText': instance.messageText,
  'parentMessageId': instance.parentMessageId,
  'isAnswer': instance.isAnswer,
  'isEndorsed': instance.isEndorsed,
  'endorsedBy': instance.endorsedBy,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

_$PaginationMetaImpl _$$PaginationMetaImplFromJson(Map<String, dynamic> json) =>
    _$PaginationMetaImpl(
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      total: (json['total'] as num?)?.toInt() ?? 0,
      hasMore: json['hasMore'] as bool? ?? false,
    );

Map<String, dynamic> _$$PaginationMetaImplToJson(
  _$PaginationMetaImpl instance,
) => <String, dynamic>{
  'page': instance.page,
  'limit': instance.limit,
  'total': instance.total,
  'hasMore': instance.hasMore,
};
