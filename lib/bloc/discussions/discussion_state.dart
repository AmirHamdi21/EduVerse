import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/discussion/discussion_models.dart';

part 'discussion_state.freezed.dart';

enum DiscussionStatus { initial, loading, success, failure }

@freezed
class DiscussionState with _$DiscussionState {
  const factory DiscussionState({
    @Default(DiscussionStatus.initial) DiscussionStatus status,
    @Default(<DiscussionThread>[]) List<DiscussionThread> threads,
    DiscussionThread? selectedThread,
    @Default(<DiscussionReply>[]) List<DiscussionReply> replies,
    @Default(false) bool isPaginatingThreads,
    @Default(false) bool isPaginatingReplies,
    @Default(false) bool isSubmitting,
    @Default(false) bool canModerate,
    int? currentCourseId,
    int? currentUserId,
    @Default(1) int currentThreadPage,
    @Default(1) int currentReplyPage,
    @Default(true) bool hasMoreThreads,
    @Default(true) bool hasMoreReplies,
    String? errorMessage,
  }) = _DiscussionState;
}
