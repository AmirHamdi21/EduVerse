import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/bloc/route_request_controller.dart';

import '../../../models/question_bank/question_bank_enums.dart';
import '../../../models/question_bank/question_bank_question_model.dart';
import '../../../services/api/enrollment_service.dart';
import '../../../services/api/question_bank_service.dart';
import 'question_group_cubit.dart';
import 'question_detail_state.dart';

class QuestionDetailCubit extends Cubit<QuestionDetailState>
    with SafeRouteCubitMixin<QuestionDetailState> {
  QuestionDetailCubit({
    required QuestionBankService questionBankService,
    EnrollmentService? enrollmentService,
  }) : _questionBankService = questionBankService,
       _enrollmentService = enrollmentService,
       super(const QuestionDetailState());

  final QuestionBankService _questionBankService;
  final EnrollmentService? _enrollmentService;

  Future<void> load(int questionId, {bool showSkeleton = true}) async {
    if (showSkeleton) {
      emitIfOpen(
        state.copyWith(isLoading: true, clearError: true, clearAction: true),
      );
    }
    final result = await _questionBankService.getQuestion(questionId);
    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          isLoading: false,
          errorMessage: result.error?.message ?? 'questionLoadFailed',
        ),
      );
      return;
    }
    final question = result.data!;
    final scope = await _resolveQuestionScope(question);
    emitIfOpen(
      state.copyWith(
        isLoading: false,
        question: question,
        courseLabel: scope.courseLabel,
        chapterLabel: scope.chapterLabel,
        clearError: true,
      ),
    );
  }

  Future<_QuestionScopeLabels> _resolveQuestionScope(
    QuestionBankQuestionModel question,
  ) async {
    var courseLabel = '${question.courseId}';
    var chapterLabel = '${question.chapterId}';

    final enrollmentService = _enrollmentService;
    if (enrollmentService != null) {
      final coursesResult = await enrollmentService.getTeachingCourses();
      if (coursesResult.isSuccess && coursesResult.data != null) {
        final course = coursesResult.data!
            .where((course) => course.courseId == question.courseId)
            .firstOrNull;
        if (course != null) {
          final code = course.course.code.trim();
          final name = course.course.name.trim();
          if (code.isNotEmpty && name.isNotEmpty) {
            courseLabel = '$code - $name';
          } else if (code.isNotEmpty) {
            courseLabel = code;
          } else if (name.isNotEmpty) {
            courseLabel = name;
          }
        }
      }
    }

    final chaptersResult = await _questionBankService.getChapters(
      question.courseId,
    );
    if (chaptersResult.isSuccess && chaptersResult.data != null) {
      final chapter = chaptersResult.data!
          .where((chapter) => chapter.id == question.chapterId)
          .firstOrNull;
      if (chapter != null) {
        final name = chapter.name.trim();
        chapterLabel = name.isNotEmpty
            ? '$name • ${chapter.chapterOrder}'
            : '${chapter.chapterOrder}';
      }
    }

    return _QuestionScopeLabels(
      courseLabel: courseLabel,
      chapterLabel: chapterLabel,
    );
  }

  Future<void> statusAction(String action) async {
    final question = state.question;
    if (question == null) return;
    emitIfOpen(
      state.copyWith(
        isMutating: true,
        activeMutationAction: action,
        clearError: true,
        clearAction: true,
      ),
    );
    final result = await _questionBankService.statusAction(
      questionId: question.id,
      action: action,
    );
    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          isLoading: false,
          isMutating: false,
          clearActiveMutationAction: true,
          errorMessage: result.error?.message ?? 'questionStatusFailed',
        ),
      );
      return;
    }
    final confirmed = await _confirmStatus(result.data!, action);
    if (confirmed == null) {
      emitIfOpen(
        state.copyWith(
          isLoading: false,
          isMutating: false,
          clearActiveMutationAction: true,
          errorMessage: 'questionStatusNotConfirmed',
        ),
      );
      return;
    }
    emitIfOpen(
      state.copyWith(
        isLoading: false,
        isMutating: false,
        clearActiveMutationAction: true,
        question: confirmed,
        actionMessage: 'questionStatusUpdated:${confirmed.status.value}',
      ),
    );
  }

  Future<QuestionBankQuestionModel?> _confirmStatus(
    QuestionBankQuestionModel actionResponse,
    String action,
  ) async {
    final expected = _expectedStatus(action);
    if (expected == null) return actionResponse;

    var latest = actionResponse;
    for (var attempt = 0; attempt < 3; attempt++) {
      final result = await _questionBankService.getQuestion(actionResponse.id);
      if (result.isSuccess && result.data != null) {
        latest = result.data!;
        if (latest.status == expected) return latest;
      }
      if (attempt < 2) {
        await Future<void>.delayed(const Duration(milliseconds: 350));
      }
    }
    return latest.status == expected ? latest : null;
  }

  QuestionBankStatus? _expectedStatus(String action) {
    switch (action) {
      case 'submit-for-review':
        return QuestionBankStatus.underReview;
      case 'approve':
        return QuestionBankStatus.approved;
      case 'reject':
        return QuestionBankStatus.rejected;
      case 'archive':
        return QuestionBankStatus.archived;
      case 'restore':
        return QuestionBankStatus.draft;
      default:
        return null;
    }
  }

  Future<bool> deleteQuestion() async {
    final question = state.question;
    if (question == null) return false;
    emitIfOpen(
      state.copyWith(
        isMutating: true,
        activeMutationAction: 'delete',
        clearError: true,
        clearAction: true,
      ),
    );
    final result = await _questionBankService.deleteQuestion(question.id);
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          clearActiveMutationAction: true,
          errorMessage: result.error?.message ?? 'questionDeleteFailed',
        ),
      );
      return false;
    }
    QuestionGroupCubit.purgeQuestionFromCaches(question.id);
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        clearActiveMutationAction: true,
        actionMessage: 'questionDeleted',
      ),
    );
    return true;
  }

  Future<void> addAttachmentByFileId({
    required int fileId,
    QuestionAttachmentType attachmentType = QuestionAttachmentType.image,
    String? caption,
    String? altText,
    int? displayOrder,
    bool? isPrimary,
  }) async {
    final question = state.question;
    if (question == null) return;
    emitIfOpen(
      state.copyWith(
        isMutating: true,
        activeMutationAction: 'attachmentUpdate',
        clearError: true,
        clearAction: true,
      ),
    );
    final result = await _questionBankService.addAttachment(
      questionId: question.id,
      fileId: fileId,
      attachmentType: attachmentType,
      caption: caption,
      altText: altText,
      displayOrder: displayOrder,
      isPrimary: isPrimary,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          clearActiveMutationAction: true,
          errorMessage: result.error?.message ?? 'attachmentAddFailed',
        ),
      );
      return;
    }
    await load(question.id, showSkeleton: false);
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        clearActiveMutationAction: true,
        actionMessage: 'attachmentAdded',
      ),
    );
  }

  Future<void> uploadAttachmentImage(String path) async {
    final question = state.question;
    if (question == null) return;
    emitIfOpen(
      state.copyWith(
        isMutating: true,
        activeMutationAction: 'attachmentUpload',
        clearError: true,
        clearAction: true,
      ),
    );
    final result = await _questionBankService.uploadAttachmentImage(
      questionId: question.id,
      path: path,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          clearActiveMutationAction: true,
          errorMessage: result.error?.message ?? 'attachmentUploadFailed',
        ),
      );
      return;
    }
    await load(question.id, showSkeleton: false);
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        clearActiveMutationAction: true,
        actionMessage: 'attachmentUploaded',
      ),
    );
  }

  Future<void> updateAttachment({
    required int attachmentId,
    String? caption,
    String? altText,
    int? displayOrder,
    bool? isPrimary,
  }) async {
    final question = state.question;
    if (question == null) return;
    emitIfOpen(
      state.copyWith(
        isMutating: true,
        activeMutationAction: 'attachmentUpdate',
        clearError: true,
        clearAction: true,
      ),
    );
    final result = await _questionBankService.updateAttachment(
      questionId: question.id,
      attachmentId: attachmentId,
      caption: caption,
      altText: altText,
      displayOrder: displayOrder,
      isPrimary: isPrimary,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          clearActiveMutationAction: true,
          errorMessage: result.error?.message ?? 'attachmentUpdateFailed',
        ),
      );
      return;
    }
    await load(question.id, showSkeleton: false);
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        clearActiveMutationAction: true,
        actionMessage: 'attachmentMetadataUpdated',
      ),
    );
  }

  Future<void> reorderAttachments(List<int> orderedAttachmentIds) async {
    final question = state.question;
    if (question == null) return;
    emitIfOpen(
      state.copyWith(
        isMutating: true,
        activeMutationAction: 'attachmentReorder',
        clearError: true,
        clearAction: true,
      ),
    );
    final result = await _questionBankService.reorderAttachments(
      questionId: question.id,
      items: [
        for (var i = 0; i < orderedAttachmentIds.length; i++)
          {'attachmentId': orderedAttachmentIds[i], 'displayOrder': i},
      ],
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isLoading: false,
          isMutating: false,
          clearActiveMutationAction: true,
          errorMessage: result.error?.message ?? 'attachmentReorderFailed',
        ),
      );
      return;
    }
    await load(question.id, showSkeleton: false);
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        clearActiveMutationAction: true,
        actionMessage: 'attachmentReordered',
      ),
    );
  }

  Future<void> removeAttachment(int attachmentId) async {
    final question = state.question;
    if (question == null) return;
    emitIfOpen(
      state.copyWith(
        isMutating: true,
        activeMutationAction: 'attachmentRemove',
        clearError: true,
        clearAction: true,
      ),
    );
    final result = await _questionBankService.removeAttachment(
      questionId: question.id,
      attachmentId: attachmentId,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          clearActiveMutationAction: true,
          errorMessage: result.error?.message ?? 'attachmentRemoveFailed',
        ),
      );
      return;
    }
    await load(question.id, showSkeleton: false);
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        clearActiveMutationAction: true,
        actionMessage: 'attachmentRemoved',
      ),
    );
  }
}

class _QuestionScopeLabels {
  const _QuestionScopeLabels({
    required this.courseLabel,
    required this.chapterLabel,
  });

  final String courseLabel;
  final String chapterLabel;
}
