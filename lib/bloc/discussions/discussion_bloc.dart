import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/discussion/discussion_models.dart';
import '../../services/api/core_api_client.dart';
import '../../services/api/discussion_service.dart';
import '../../services/storage_service.dart';
import 'discussion_event.dart';
import 'discussion_state.dart';

class DiscussionBloc extends Bloc<DiscussionEvent, DiscussionState> {
  final IDiscussionService _discussionService;

  factory DiscussionBloc({
    IDiscussionService? discussionService,
    StorageService? storageService,
  }) {
    final resolvedStorage = storageService ?? StorageService();
    final resolvedService =
        discussionService ??
        DiscussionService(
          coreApiClient: CoreApiClient(storageService: resolvedStorage),
        );

    return DiscussionBloc._(discussionService: resolvedService);
  }

  DiscussionBloc._({required IDiscussionService discussionService})
    : _discussionService = discussionService,
      super(const DiscussionState()) {
    on<SetDiscussionContext>(_onSetDiscussionContext);
    on<LoadThreads>(_onLoadThreads);
    on<LoadMoreThreads>(_onLoadMoreThreads);
    on<SelectThread>(_onSelectThread);
    on<DeselectThread>(_onDeselectThread);
    on<LoadMoreReplies>(_onLoadMoreReplies);
    on<CreateThreadRequested>(_onCreateThreadRequested);
    on<UpdateThreadRequested>(_onUpdateThreadRequested);
    on<DeleteThreadRequested>(_onDeleteThreadRequested);
    on<PostReplyRequested>(_onPostReplyRequested);
    on<UpdateReplyRequested>(_onUpdateReplyRequested);
    on<DeleteReplyRequested>(_onDeleteReplyRequested);
    on<TogglePinRequested>(_onTogglePinRequested);
    on<ToggleLockRequested>(_onToggleLockRequested);
    on<MarkAnswerRequested>(_onMarkAnswerRequested);
    on<EndorseReplyRequested>(_onEndorseReplyRequested);
    on<ClearDiscussionError>(_onClearDiscussionError);
  }

  void _onSetDiscussionContext(
    SetDiscussionContext event,
    Emitter<DiscussionState> emit,
  ) {
    emit(
      state.copyWith(
        currentCourseId: event.courseId,
        currentUserId: event.currentUserId,
        canModerate: event.canModerate,
      ),
    );
  }

  Future<void> _onLoadThreads(
    LoadThreads event,
    Emitter<DiscussionState> emit,
  ) async {
    final targetCourseId = event.courseId ?? state.currentCourseId;

    if (event.page <= 1 || event.refresh) {
      emit(
        state.copyWith(
          status: DiscussionStatus.loading,
          currentCourseId: targetCourseId,
          currentThreadPage: 1,
          hasMoreThreads: true,
          errorMessage: null,
        ),
      );
    } else {
      emit(state.copyWith(isPaginatingThreads: true, errorMessage: null));
    }

    try {
      final page = await _discussionService.getThreads(
        courseId: targetCourseId,
        page: event.page,
        limit: event.limit,
      );

      final shouldReplace = event.page <= 1 || event.refresh;
      final mergedThreads = shouldReplace
          ? page.data
          : _mergeThreadPages(state.threads, page.data);

      emit(
        state.copyWith(
          status: DiscussionStatus.success,
          threads: mergedThreads,
          currentCourseId: targetCourseId,
          currentThreadPage: page.meta.page,
          hasMoreThreads: page.meta.hasMore,
          isPaginatingThreads: false,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: DiscussionStatus.failure,
          isPaginatingThreads: false,
          errorMessage: _formatError(error),
        ),
      );
    }
  }

  Future<void> _onLoadMoreThreads(
    LoadMoreThreads event,
    Emitter<DiscussionState> emit,
  ) async {
    if (state.isPaginatingThreads || !state.hasMoreThreads) {
      return;
    }

    add(
      LoadThreads(
        courseId: state.currentCourseId,
        page: state.currentThreadPage + 1,
        limit: event.limit,
      ),
    );
  }

  Future<void> _onSelectThread(
    SelectThread event,
    Emitter<DiscussionState> emit,
  ) async {
    emit(
      state.copyWith(
        status: DiscussionStatus.loading,
        selectedThread: state.threads
            .where((t) => t.id == event.threadId)
            .firstOrNull,
        replies: const <DiscussionReply>[],
        currentReplyPage: 1,
        hasMoreReplies: true,
        errorMessage: null,
      ),
    );

    try {
      final details = await _discussionService.getThreadDetail(
        event.threadId,
        page: 1,
        limit: 20,
      );

      final updatedThreads = _upsertThread(state.threads, details.thread);

      emit(
        state.copyWith(
          status: DiscussionStatus.success,
          threads: _sortThreads(updatedThreads),
          selectedThread: details.thread,
          replies: _sortReplies(details.replies.data),
          currentReplyPage: details.replies.meta.page,
          hasMoreReplies: details.replies.meta.hasMore,
          errorMessage: null,
        ),
      );
    } catch (error) {
      final isNotFound = _statusCode(error) == 404;
      emit(
        state.copyWith(
          status: DiscussionStatus.failure,
          selectedThread: isNotFound ? null : state.selectedThread,
          errorMessage: isNotFound
              ? 'This thread no longer exists. The list has been refreshed.'
              : _formatError(error),
        ),
      );

      if (isNotFound) {
        add(
          LoadThreads(courseId: state.currentCourseId, page: 1, refresh: true),
        );
      }
    }
  }

  void _onDeselectThread(DeselectThread event, Emitter<DiscussionState> emit) {
    emit(
      state.copyWith(
        selectedThread: null,
        replies: const <DiscussionReply>[],
        currentReplyPage: 1,
        hasMoreReplies: true,
        errorMessage: null,
      ),
    );
  }

  Future<void> _onLoadMoreReplies(
    LoadMoreReplies event,
    Emitter<DiscussionState> emit,
  ) async {
    final selected = state.selectedThread;
    if (selected == null ||
        state.isPaginatingReplies ||
        !state.hasMoreReplies) {
      return;
    }

    emit(state.copyWith(isPaginatingReplies: true, errorMessage: null));

    try {
      final nextPage = state.currentReplyPage + 1;
      final details = await _discussionService.getThreadDetail(
        selected.id,
        page: nextPage,
        limit: event.limit,
      );

      final mergedReplies = _mergeReplyPages(
        state.replies,
        details.replies.data,
      );
      final updatedThreads = _upsertThread(state.threads, details.thread);

      emit(
        state.copyWith(
          status: DiscussionStatus.success,
          threads: _sortThreads(updatedThreads),
          selectedThread: details.thread,
          replies: _sortReplies(mergedReplies),
          currentReplyPage: details.replies.meta.page,
          hasMoreReplies: details.replies.meta.hasMore,
          isPaginatingReplies: false,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: DiscussionStatus.failure,
          isPaginatingReplies: false,
          errorMessage: _formatError(error),
        ),
      );
    }
  }

  Future<void> _onCreateThreadRequested(
    CreateThreadRequested event,
    Emitter<DiscussionState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      final thread = await _discussionService.createThread(
        courseId: event.courseId,
        title: event.title,
        description: event.description,
      );

      final merged = _upsertThread(state.threads, thread, prependWhenNew: true);

      emit(
        state.copyWith(
          status: DiscussionStatus.success,
          threads: _sortThreads(merged),
          selectedThread: thread,
          replies: const <DiscussionReply>[],
          currentReplyPage: 1,
          hasMoreReplies: true,
          isSubmitting: false,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: DiscussionStatus.failure,
          isSubmitting: false,
          errorMessage: _formatError(error),
        ),
      );
    }
  }

  Future<void> _onUpdateThreadRequested(
    UpdateThreadRequested event,
    Emitter<DiscussionState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      final updated = await _discussionService.updateThread(
        threadId: event.threadId,
        title: event.title,
        description: event.description,
      );

      emit(
        state.copyWith(
          status: DiscussionStatus.success,
          threads: _sortThreads(_upsertThread(state.threads, updated)),
          selectedThread: state.selectedThread?.id == updated.id
              ? updated
              : state.selectedThread,
          isSubmitting: false,
          errorMessage: null,
        ),
      );
    } catch (error) {
      final isNotFound = _statusCode(error) == 404;
      emit(
        state.copyWith(
          status: DiscussionStatus.failure,
          isSubmitting: false,
          selectedThread: isNotFound ? null : state.selectedThread,
          errorMessage: isNotFound
              ? 'This thread no longer exists. The list has been refreshed.'
              : _formatError(error),
        ),
      );

      if (isNotFound) {
        add(
          LoadThreads(courseId: state.currentCourseId, page: 1, refresh: true),
        );
      }
    }
  }

  Future<void> _onDeleteThreadRequested(
    DeleteThreadRequested event,
    Emitter<DiscussionState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      await _discussionService.deleteThread(event.threadId);

      final remaining = state.threads
          .where((thread) => thread.id != event.threadId)
          .toList(growable: false);

      emit(
        state.copyWith(
          status: DiscussionStatus.success,
          threads: remaining,
          selectedThread: state.selectedThread?.id == event.threadId
              ? null
              : state.selectedThread,
          replies: state.selectedThread?.id == event.threadId
              ? const <DiscussionReply>[]
              : state.replies,
          isSubmitting: false,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: DiscussionStatus.failure,
          isSubmitting: false,
          errorMessage: _formatError(error),
        ),
      );
    }
  }

  Future<void> _onPostReplyRequested(
    PostReplyRequested event,
    Emitter<DiscussionState> emit,
  ) async {
    final selected = state.selectedThread;
    if (selected != null && selected.isLocked) {
      emit(
        state.copyWith(
          status: DiscussionStatus.failure,
          errorMessage: 'This thread has been locked.',
        ),
      );
      return;
    }

    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      final reply = await _discussionService.postReply(
        threadId: event.threadId,
        messageText: event.messageText,
        parentMessageId: event.parentMessageId,
      );

      final mergedReplies = _mergeReplyPages(state.replies, [reply]);
      final updatedSelected = state.selectedThread?.copyWith(
        replyCount: state.selectedThread!.replyCount + 1,
      );

      final updatedThreads = updatedSelected == null
          ? state.threads
          : _upsertThread(state.threads, updatedSelected);

      emit(
        state.copyWith(
          status: DiscussionStatus.success,
          replies: _sortReplies(mergedReplies),
          selectedThread: updatedSelected,
          threads: _sortThreads(updatedThreads),
          isSubmitting: false,
          errorMessage: null,
        ),
      );
    } catch (error) {
      final statusCode = _statusCode(error);
      emit(
        state.copyWith(
          status: DiscussionStatus.failure,
          isSubmitting: false,
          errorMessage: statusCode == 400
              ? 'This thread has been locked.'
              : _formatError(error),
        ),
      );

      if (statusCode == 400 && state.selectedThread != null) {
        add(SelectThread(threadId: state.selectedThread!.id));
      }
    }
  }

  Future<void> _onUpdateReplyRequested(
    UpdateReplyRequested event,
    Emitter<DiscussionState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      final updated = await _discussionService.updateReply(
        replyId: event.replyId,
        messageText: event.messageText,
      );

      final replies = state.replies
          .map((reply) => reply.id == updated.id ? updated : reply)
          .toList(growable: false);

      emit(
        state.copyWith(
          status: DiscussionStatus.success,
          replies: _sortReplies(replies),
          isSubmitting: false,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: DiscussionStatus.failure,
          isSubmitting: false,
          errorMessage: _formatError(error),
        ),
      );
    }
  }

  Future<void> _onDeleteReplyRequested(
    DeleteReplyRequested event,
    Emitter<DiscussionState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      await _discussionService.deleteReply(event.replyId);

      final replies = state.replies
          .where((reply) => reply.id != event.replyId)
          .toList(growable: false);

      final updatedSelected = state.selectedThread == null
          ? null
          : state.selectedThread!.copyWith(
              replyCount: state.selectedThread!.replyCount > 0
                  ? state.selectedThread!.replyCount - 1
                  : 0,
            );

      emit(
        state.copyWith(
          status: DiscussionStatus.success,
          replies: replies,
          selectedThread: updatedSelected,
          threads: updatedSelected == null
              ? state.threads
              : _sortThreads(_upsertThread(state.threads, updatedSelected)),
          isSubmitting: false,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: DiscussionStatus.failure,
          isSubmitting: false,
          errorMessage: _formatError(error),
        ),
      );
    }
  }

  Future<void> _onTogglePinRequested(
    TogglePinRequested event,
    Emitter<DiscussionState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      await _discussionService.togglePin(event.threadId);
      final updatedThreads = state.threads
          .map((thread) {
            if (thread.id == event.threadId) {
              return thread.copyWith(isPinned: !thread.isPinned);
            }
            return thread;
          })
          .toList(growable: false);

      final selected = state.selectedThread?.id == event.threadId
          ? state.selectedThread!.copyWith(
              isPinned: !state.selectedThread!.isPinned,
            )
          : state.selectedThread;

      emit(
        state.copyWith(
          status: DiscussionStatus.success,
          threads: _sortThreads(updatedThreads),
          selectedThread: selected,
          isSubmitting: false,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: DiscussionStatus.failure,
          isSubmitting: false,
          errorMessage: _formatError(error),
        ),
      );
    }
  }

  Future<void> _onToggleLockRequested(
    ToggleLockRequested event,
    Emitter<DiscussionState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      await _discussionService.toggleLock(event.threadId);
      final updatedThreads = state.threads
          .map((thread) {
            if (thread.id == event.threadId) {
              return thread.copyWith(isLocked: !thread.isLocked);
            }
            return thread;
          })
          .toList(growable: false);

      final selected = state.selectedThread?.id == event.threadId
          ? state.selectedThread!.copyWith(
              isLocked: !state.selectedThread!.isLocked,
            )
          : state.selectedThread;

      emit(
        state.copyWith(
          status: DiscussionStatus.success,
          threads: _sortThreads(updatedThreads),
          selectedThread: selected,
          isSubmitting: false,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: DiscussionStatus.failure,
          isSubmitting: false,
          errorMessage: _formatError(error),
        ),
      );
    }
  }

  Future<void> _onMarkAnswerRequested(
    MarkAnswerRequested event,
    Emitter<DiscussionState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      await _discussionService.markAnswer(event.replyId);

      final updated = state.replies
          .map((reply) {
            if (reply.id == event.replyId) {
              return reply.copyWith(isAnswer: !reply.isAnswer);
            }
            if (reply.isAnswer) {
              return reply.copyWith(isAnswer: false);
            }
            return reply;
          })
          .toList(growable: false);

      emit(
        state.copyWith(
          status: DiscussionStatus.success,
          replies: _sortReplies(updated),
          isSubmitting: false,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: DiscussionStatus.failure,
          isSubmitting: false,
          errorMessage: _formatError(error),
        ),
      );
    }
  }

  Future<void> _onEndorseReplyRequested(
    EndorseReplyRequested event,
    Emitter<DiscussionState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      await _discussionService.endorseReply(event.replyId);

      final updated = state.replies
          .map((reply) {
            if (reply.id == event.replyId) {
              return reply.copyWith(isEndorsed: !reply.isEndorsed);
            }
            return reply;
          })
          .toList(growable: false);

      emit(
        state.copyWith(
          status: DiscussionStatus.success,
          replies: _sortReplies(updated),
          isSubmitting: false,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: DiscussionStatus.failure,
          isSubmitting: false,
          errorMessage: _formatError(error),
        ),
      );
    }
  }

  void _onClearDiscussionError(
    ClearDiscussionError event,
    Emitter<DiscussionState> emit,
  ) {
    emit(state.copyWith(errorMessage: null));
  }

  List<DiscussionThread> _mergeThreadPages(
    List<DiscussionThread> existing,
    List<DiscussionThread> incoming,
  ) {
    final map = <int, DiscussionThread>{
      for (final thread in existing) thread.id: thread,
    };

    for (final thread in incoming) {
      map[thread.id] = thread;
    }

    return _sortThreads(map.values.toList(growable: false));
  }

  List<DiscussionThread> _upsertThread(
    List<DiscussionThread> existing,
    DiscussionThread incoming, {
    bool prependWhenNew = false,
  }) {
    final index = existing.indexWhere((thread) => thread.id == incoming.id);
    if (index == -1) {
      return prependWhenNew ? [incoming, ...existing] : [...existing, incoming];
    }

    final next = [...existing];
    next[index] = incoming;
    return next;
  }

  List<DiscussionThread> _sortThreads(List<DiscussionThread> threads) {
    final sorted = [...threads];
    sorted.sort((a, b) {
      final pinCompare = (b.isPinned ? 1 : 0).compareTo(a.isPinned ? 1 : 0);
      if (pinCompare != 0) {
        return pinCompare;
      }
      return b.createdAt.compareTo(a.createdAt);
    });
    return sorted;
  }

  List<DiscussionReply> _mergeReplyPages(
    List<DiscussionReply> existing,
    List<DiscussionReply> incoming,
  ) {
    final map = <int, DiscussionReply>{
      for (final reply in existing) reply.id: reply,
    };

    for (final reply in incoming) {
      map[reply.id] = reply;
    }

    return map.values.toList(growable: false);
  }

  List<DiscussionReply> _sortReplies(List<DiscussionReply> replies) {
    final sorted = [...replies];
    sorted.sort((a, b) {
      final answerCompare = (b.isAnswer ? 1 : 0).compareTo(a.isAnswer ? 1 : 0);
      if (answerCompare != 0) {
        return answerCompare;
      }
      return a.createdAt.compareTo(b.createdAt);
    });
    return sorted;
  }

  String _formatError(Object error) {
    if (error is DioException) {
      final serverMessage = error.response?.data is Map<String, dynamic>
          ? (error.response?.data['message']?.toString())
          : null;
      if (serverMessage != null && serverMessage.trim().isNotEmpty) {
        return serverMessage;
      }

      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        return 'You are not authorized to perform this action.';
      }
      if (statusCode == 404) {
        return 'The requested discussion resource was not found.';
      }
      if (statusCode == 429) {
        return 'Too many requests. Please try again shortly.';
      }
      if (statusCode == 500) {
        return 'Server error. Please try again later.';
      }
    }

    return error.toString().replaceFirst('Exception: ', '');
  }

  int? _statusCode(Object error) {
    if (error is DioException) {
      return error.response?.statusCode;
    }
    return null;
  }
}
