import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/question_bank/question_bank_enums.dart';
import '../../../models/question_bank/question_bank_form_payload.dart';
import '../../../services/api/question_bank_service.dart';
import 'question_group_state.dart';

class QuestionGroupCubit extends Cubit<QuestionGroupState> {
  QuestionGroupCubit({required QuestionBankService questionBankService})
    : _questionBankService = questionBankService,
      super(const QuestionGroupState());

  final QuestionBankService _questionBankService;

  Future<void> load(int groupId) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearAction: true));
    final groupResult = await _questionBankService.getGroup(groupId);
    final questionResult = await _questionBankService.getQuestions(
      groupId: groupId,
    );
    if (!groupResult.isSuccess || groupResult.data == null) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: groupResult.error?.message ?? 'groupLoadFailed',
        ),
      );
      return;
    }
    final chaptersResult = await _questionBankService.getChapters(
      groupResult.data!.courseId,
    );
    emit(
      state.copyWith(
        isLoading: false,
        group: groupResult.data,
        chapters: chaptersResult.data ?? const [],
        questions: questionResult.data?.data ?? const [],
      ),
    );
  }

  Future<int?> createGroup({
    required int courseId,
    String? title,
    String? sharedPrompt,
    int? sharedFileId,
    String? sharedFileCaption,
    String? sharedFileAltText,
    QuestionGroupType groupType = QuestionGroupType.other,
  }) async {
    emit(state.copyWith(isMutating: true, clearError: true, clearAction: true));
    final result = await _questionBankService.createGroup(
      courseId: courseId,
      title: title,
      sharedPrompt: sharedPrompt,
      sharedFileId: sharedFileId,
      sharedFileCaption: sharedFileCaption,
      sharedFileAltText: sharedFileAltText,
      groupType: groupType,
    );
    if (!result.isSuccess || result.data == null) {
      emit(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'groupCreateFailed',
        ),
      );
      return null;
    }
    emit(
      state.copyWith(
        isMutating: false,
        group: result.data,
        actionMessage: 'groupSaved',
      ),
    );
    return result.data!.id;
  }

  Future<void> updateGroup({
    required int groupId,
    String? title,
    String? sharedPrompt,
    int? sharedFileId,
    String? sharedFileCaption,
    String? sharedFileAltText,
    QuestionGroupType? groupType,
  }) async {
    emit(state.copyWith(isMutating: true, clearError: true, clearAction: true));
    final result = await _questionBankService.updateGroup(
      groupId: groupId,
      title: title,
      sharedPrompt: sharedPrompt,
      sharedFileId: sharedFileId,
      sharedFileCaption: sharedFileCaption,
      sharedFileAltText: sharedFileAltText,
      groupType: groupType,
    );
    if (!result.isSuccess || result.data == null) {
      emit(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'groupUpdateFailed',
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        isMutating: false,
        group: result.data,
        actionMessage: 'groupSaved',
      ),
    );
  }

  Future<int?> uploadGroupImage(String path) async {
    emit(state.copyWith(isMutating: true, clearError: true, clearAction: true));
    final result = await _questionBankService.uploadGroupImage(path);
    if (!result.isSuccess || result.data == null) {
      emit(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'groupImageUploadFailed',
        ),
      );
      return null;
    }
    emit(
      state.copyWith(isMutating: false, actionMessage: 'groupImageUploaded'),
    );
    return result.data!.fileId;
  }

  Future<int?> uploadQuestionImage(String path) async {
    emit(state.copyWith(isMutating: true, clearError: true, clearAction: true));
    final result = await _questionBankService.uploadQuestionImage(path);
    if (!result.isSuccess || result.data == null) {
      emit(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'questionImageUploadFailed',
        ),
      );
      return null;
    }
    emit(
      state.copyWith(isMutating: false, actionMessage: 'questionImageUploaded'),
    );
    return result.data!.fileId;
  }

  Future<void> deleteUploadedQuestionImage(int fileId) async {
    emit(state.copyWith(isMutating: true, clearError: true, clearAction: true));
    final result = await _questionBankService.deleteUploadedFile(fileId);
    emit(
      state.copyWith(
        isMutating: false,
        errorMessage: result.isSuccess
            ? null
            : result.error?.message ?? 'questionImageDeleteFailed',
        actionMessage: result.isSuccess ? 'questionImageRemoved' : null,
      ),
    );
  }

  Future<void> discardUploadedQuestionImages(Iterable<int> fileIds) async {
    for (final fileId in fileIds.toSet()) {
      await _questionBankService.deleteUploadedFile(fileId);
    }
  }

  Future<void> createChapter({
    required String name,
    required int chapterOrder,
  }) async {
    final group = state.group;
    if (group == null) return;
    emit(state.copyWith(isMutating: true, clearError: true, clearAction: true));
    final result = await _questionBankService.createChapter(
      courseId: group.courseId,
      name: name,
      chapterOrder: chapterOrder,
    );
    if (!result.isSuccess || result.data == null) {
      emit(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'chapterCreateFailed',
        ),
      );
      return;
    }
    final chapters = await _questionBankService.getChapters(group.courseId);
    emit(
      state.copyWith(
        isMutating: false,
        chapters: chapters.data ?? [...state.chapters, result.data!],
        actionMessage: 'chapterCreated',
      ),
    );
  }

  Future<bool> deleteGroup(int groupId) async {
    emit(state.copyWith(isMutating: true, clearError: true, clearAction: true));
    final result = await _questionBankService.deleteGroup(groupId);
    if (!result.isSuccess) {
      emit(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'groupDeleteFailed',
        ),
      );
      return false;
    }
    emit(state.copyWith(isMutating: false, actionMessage: 'groupDeleted'));
    return true;
  }

  Future<bool> addGroupedQuestions(
    List<QuestionBankFormPayload> questions,
  ) async {
    final group = state.group;
    if (group == null) return false;
    emit(state.copyWith(isMutating: true, clearError: true, clearAction: true));
    final result = await _questionBankService.addGroupedQuestions(
      groupId: group.id,
      questions: questions,
    );
    if (!result.isSuccess) {
      emit(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'groupedBatchFailed',
        ),
      );
      return false;
    }
    await load(group.id);
    emit(
      state.copyWith(
        isMutating: false,
        createdQuestions: result.data ?? const [],
        actionMessage: 'groupQuestionsAdded',
      ),
    );
    return true;
  }

  Future<bool> statusCreatedQuestions(String action) async {
    if (state.createdQuestions.isEmpty) return false;
    emit(state.copyWith(isMutating: true, clearError: true, clearAction: true));
    final result = await _questionBankService.batchStatusAction(
      questionIds: state.createdQuestions
          .map((question) => question.id)
          .toList(),
      action: action,
    );
    if (!result.isSuccess) {
      emit(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'bulkStatusFailed',
        ),
      );
      return false;
    }
    emit(
      state.copyWith(
        isMutating: false,
        createdQuestions: result.data ?? state.createdQuestions,
        actionMessage: 'questionsBatchUpdated',
      ),
    );
    return true;
  }

  void clearCreatedQuestions() {
    emit(state.copyWith(clearCreatedQuestions: true, clearAction: true));
  }

  Future<bool> removeQuestionFromGroup(int questionId) async {
    final group = state.group;
    if (group == null) return false;
    emit(state.copyWith(isMutating: true, clearError: true, clearAction: true));
    final result = await _questionBankService.unlinkGroupQuestion(
      groupId: group.id,
      questionId: questionId,
    );
    if (!result.isSuccess) {
      emit(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'groupQuestionRemoveFailed',
        ),
      );
      return false;
    }
    await load(group.id);
    emit(
      state.copyWith(isMutating: false, actionMessage: 'groupQuestionRemoved'),
    );
    return true;
  }

  Future<bool> archiveQuestion(int questionId) async {
    final group = state.group;
    if (group == null) return false;
    emit(state.copyWith(isMutating: true, clearError: true, clearAction: true));
    final result = await _questionBankService.statusAction(
      questionId: questionId,
      action: 'archive',
    );
    if (!result.isSuccess) {
      emit(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'questionDeleteFailed',
        ),
      );
      return false;
    }
    await load(group.id);
    emit(state.copyWith(isMutating: false, actionMessage: 'questionDeleted'));
    return true;
  }

  Future<bool> linkExistingQuestions(List<int> questionIds) async {
    final group = state.group;
    if (group == null || questionIds.isEmpty) return false;
    emit(state.copyWith(isMutating: true, clearError: true, clearAction: true));
    final result = await _questionBankService.linkGroupQuestions(
      groupId: group.id,
      questionIds: questionIds,
    );
    if (!result.isSuccess) {
      emit(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'groupLinkQuestionsFailed',
        ),
      );
      return false;
    }
    await load(group.id);
    emit(
      state.copyWith(isMutating: false, actionMessage: 'groupQuestionsAdded'),
    );
    return true;
  }

  Future<void> reorderQuestions(List<int> orderedQuestionIds) async {
    final group = state.group;
    if (group == null) return;
    final existing = state.questions.map((question) => question.id).toSet();
    if (orderedQuestionIds.length != existing.length ||
        orderedQuestionIds.toSet().length != existing.length ||
        !orderedQuestionIds.toSet().containsAll(existing)) {
      emit(state.copyWith(errorMessage: 'groupReorderInvalid'));
      return;
    }
    emit(state.copyWith(isMutating: true, clearError: true, clearAction: true));
    final result = await _questionBankService.reorderGroupQuestions(
      groupId: group.id,
      items: [
        for (var i = 0; i < orderedQuestionIds.length; i++)
          {'questionId': orderedQuestionIds[i], 'itemOrder': i},
      ],
    );
    if (!result.isSuccess) {
      emit(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'groupReorderFailed',
        ),
      );
      return;
    }
    await load(group.id);
    emit(state.copyWith(isMutating: false, actionMessage: 'groupReordered'));
  }
}
