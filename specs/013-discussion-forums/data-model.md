# Discussion Forums Data Model

Based on the backend integration and unification specification (`CHAT_FEATURE_DOCUMENTATION_SPECKIT_PLAN.md` and Backend Docs), the data model must accurately represent the responses from `/api/discussions`.

## Entites & Freezed Models

### `DiscussionThread`
Represents a forum topic.

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'discussion_thread.freezed.dart';
part 'discussion_thread.g.dart';

@freezed
class DiscussionThread with _$DiscussionThread {
  const factory DiscussionThread({
    required int id,
    required int courseId,
    required int createdBy, // User ID of the author
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
```

### `DiscussionReply`
Represents a response within a thread.

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'discussion_reply.freezed.dart';
part 'discussion_reply.g.dart';

@freezed
class DiscussionReply with _$DiscussionReply {
  const factory DiscussionReply({
    required int id,
    required int threadId,
    required int userId, // Author ID
    required String messageText,
    int? parentMessageId, // For nested replies
    @Default(false) bool isAnswer, // Instructor marked as correct answer
    @Default(false) bool isEndorsed, // Instructor staff-endorsed
    int? endorsedBy, // User ID of the staff who endorsed
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _DiscussionReply;

  factory DiscussionReply.fromJson(Map<String, dynamic> json) =>
      _$DiscussionReplyFromJson(json);
}
```

## BLoC State representation

`DiscussionState` will be defined as follows to manage paginated sequences, deduplication, and role-based modulation.

```dart
@freezed
class DiscussionState with _$DiscussionState {
  const factory DiscussionState({
    @Default([]) List<DiscussionThread> threads,
    DiscussionThread? selectedThread,
    @Default([]) List<DiscussionReply> replies,
    @Default(false) bool isLoading,
    @Default(false) bool isSubmitting,
    @Default(false) bool isPaginating,
    String? error,
    @Default(false) bool canModerate,
    int? currentCourseId,
    @Default(1) int currentThreadPage,
    @Default(1) int currentReplyPage,
    @Default(false) bool hasReachedMaxThreads,
    @Default(false) bool hasReachedMaxReplies,
  }) = _DiscussionState;
}

```