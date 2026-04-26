import 'package:freezed_annotation/freezed_annotation.dart';

part 'discussion_models.freezed.dart';
part 'discussion_models.g.dart';

@freezed
class DiscussionThread with _$DiscussionThread {
  const factory DiscussionThread({
    required int id,
    int? courseId,
    required int createdBy,
    @Default('') String createdByName,
    required String title,
    required String description,
    @Default(false) bool isPinned,
    @Default(false) bool isLocked,
    @Default(0) int viewCount,
    @Default(0) int replyCount,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _DiscussionThread;

  factory DiscussionThread.fromJson(Map<String, dynamic> json) =>
      _$DiscussionThreadFromJson(json);
}

@freezed
class DiscussionReply with _$DiscussionReply {
  const factory DiscussionReply({
    required int id,
    required int threadId,
    required int userId,
    @Default('') String userName,
    required String messageText,
    int? parentMessageId,
    @Default(false) bool isAnswer,
    @Default(false) bool isEndorsed,
    @Default(0) int upvoteCount,
    int? endorsedBy,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _DiscussionReply;

  factory DiscussionReply.fromJson(Map<String, dynamic> json) =>
      _$DiscussionReplyFromJson(json);
}

@freezed
class PaginationMeta with _$PaginationMeta {
  const factory PaginationMeta({
    @Default(1) int page,
    @Default(20) int limit,
    @Default(0) int total,
    @Default(false) bool hasMore,
  }) = _PaginationMeta;

  factory PaginationMeta.fromJson(Map<String, dynamic> json) =>
      _$PaginationMetaFromJson(json);
}

@freezed
class DiscussionThreadPage with _$DiscussionThreadPage {
  const factory DiscussionThreadPage({
    @Default(<DiscussionThread>[]) List<DiscussionThread> data,
    @Default(PaginationMeta()) PaginationMeta meta,
  }) = _DiscussionThreadPage;
}

@freezed
class DiscussionReplyPage with _$DiscussionReplyPage {
  const factory DiscussionReplyPage({
    @Default(<DiscussionReply>[]) List<DiscussionReply> data,
    @Default(PaginationMeta()) PaginationMeta meta,
  }) = _DiscussionReplyPage;
}
