import 'package:equatable/equatable.dart';

abstract class DiscussionEvent extends Equatable {
  const DiscussionEvent();

  @override
  List<Object?> get props => [];
}

class SetDiscussionContext extends DiscussionEvent {
  final int? courseId;
  final int? currentUserId;
  final bool canModerate;

  const SetDiscussionContext({
    required this.courseId,
    required this.currentUserId,
    required this.canModerate,
  });

  @override
  List<Object?> get props => [courseId, currentUserId, canModerate];
}

class LoadThreads extends DiscussionEvent {
  final int? courseId;
  final int page;
  final int limit;
  final bool refresh;

  const LoadThreads({
    this.courseId,
    this.page = 1,
    this.limit = 20,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [courseId, page, limit, refresh];
}

class LoadMoreThreads extends DiscussionEvent {
  final int limit;

  const LoadMoreThreads({this.limit = 20});

  @override
  List<Object?> get props => [limit];
}

class SelectThread extends DiscussionEvent {
  final int threadId;
  final bool incrementView;

  const SelectThread({required this.threadId, this.incrementView = true});

  @override
  List<Object?> get props => [threadId, incrementView];
}

class DeselectThread extends DiscussionEvent {
  const DeselectThread();
}

class LoadMoreReplies extends DiscussionEvent {
  final int limit;

  const LoadMoreReplies({this.limit = 20});

  @override
  List<Object?> get props => [limit];
}

class CreateThreadRequested extends DiscussionEvent {
  final int courseId;
  final String title;
  final String description;

  const CreateThreadRequested({
    required this.courseId,
    required this.title,
    required this.description,
  });

  @override
  List<Object?> get props => [courseId, title, description];
}

class UpdateThreadRequested extends DiscussionEvent {
  final int threadId;
  final String title;
  final String description;

  const UpdateThreadRequested({
    required this.threadId,
    required this.title,
    required this.description,
  });

  @override
  List<Object?> get props => [threadId, title, description];
}

class DeleteThreadRequested extends DiscussionEvent {
  final int threadId;

  const DeleteThreadRequested(this.threadId);

  @override
  List<Object?> get props => [threadId];
}

class PostReplyRequested extends DiscussionEvent {
  final int threadId;
  final String messageText;
  final int? parentMessageId;

  const PostReplyRequested({
    required this.threadId,
    required this.messageText,
    this.parentMessageId,
  });

  @override
  List<Object?> get props => [threadId, messageText, parentMessageId];
}

class UpdateReplyRequested extends DiscussionEvent {
  final int replyId;
  final String messageText;

  const UpdateReplyRequested({
    required this.replyId,
    required this.messageText,
  });

  @override
  List<Object?> get props => [replyId, messageText];
}

class DeleteReplyRequested extends DiscussionEvent {
  final int replyId;

  const DeleteReplyRequested(this.replyId);

  @override
  List<Object?> get props => [replyId];
}

class TogglePinRequested extends DiscussionEvent {
  final int threadId;

  const TogglePinRequested(this.threadId);

  @override
  List<Object?> get props => [threadId];
}

class ToggleLockRequested extends DiscussionEvent {
  final int threadId;

  const ToggleLockRequested(this.threadId);

  @override
  List<Object?> get props => [threadId];
}

class MarkAnswerRequested extends DiscussionEvent {
  final int replyId;

  const MarkAnswerRequested(this.replyId);

  @override
  List<Object?> get props => [replyId];
}

class EndorseReplyRequested extends DiscussionEvent {
  final int replyId;

  const EndorseReplyRequested(this.replyId);

  @override
  List<Object?> get props => [replyId];
}

class ClearDiscussionError extends DiscussionEvent {
  const ClearDiscussionError();
}
