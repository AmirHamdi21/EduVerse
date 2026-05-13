import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/bloc/route_request_controller.dart';

import '../../../models/question_bank/question_bank_enums.dart';
import '../../../models/question_bank/question_bank_form_payload.dart';
import '../../../models/question_bank/question_bank_group_model.dart';
import '../../../models/question_bank/question_bank_question_model.dart';
import '../../../models/question_bank/question_bank_upload_response.dart';
import '../../../services/api/question_bank_service.dart';
import 'question_group_state.dart';

class QuestionGroupCubit extends Cubit<QuestionGroupState>
    with SafeRouteCubitMixin<QuestionGroupState> {
  QuestionGroupCubit({required QuestionBankService questionBankService})
    : _questionBankService = questionBankService,
      super(const QuestionGroupState());

  final QuestionBankService _questionBankService;
  static final Map<int, List<QuestionBankQuestionModel>> _recentGroupQuestions =
      <int, List<QuestionBankQuestionModel>>{};

  static void purgeQuestionFromCaches(int questionId) {
    for (final groupId in _recentGroupQuestions.keys.toList()) {
      _recentGroupQuestions[groupId] =
          (_recentGroupQuestions[groupId] ?? const [])
              .where((question) => question.id != questionId)
              .toList();
      if (_recentGroupQuestions[groupId]?.isEmpty ?? false) {
        _recentGroupQuestions.remove(groupId);
      }
    }
  }

  static void removeCachedQuestionFromGroup({
    required int groupId,
    required int questionId,
  }) {
    _recentGroupQuestions[groupId] =
        (_recentGroupQuestions[groupId] ?? const [])
            .where((question) => question.id != questionId)
            .toList();
    if (_recentGroupQuestions[groupId]?.isEmpty ?? false) {
      _recentGroupQuestions.remove(groupId);
    }
  }

  Future<void> load(int groupId) async {
    emitIfOpen(
      state.copyWith(isLoading: true, clearError: true, clearAction: true),
    );
    final groupResult = await _questionBankService.getGroup(groupId);
    final questionResult = await _questionBankService.getQuestions(
      groupId: groupId,
    );
    if (!groupResult.isSuccess || groupResult.data == null) {
      emitIfOpen(
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
    final questions = questionResult.data?.data ?? const [];
    final resolvedQuestions = _mergeQuestions(
      questions.isNotEmpty
          ? questions
          : await _resolveGroupQuestions(groupResult.data!),
      _recentGroupQuestions[groupId] ?? const <QuestionBankQuestionModel>[],
    );
    emitIfOpen(
      state.copyWith(
        isLoading: false,
        group: groupResult.data,
        chapters: chaptersResult.data ?? const [],
        questions: resolvedQuestions,
      ),
    );
  }

  Future<List<QuestionBankQuestionModel>> _resolveGroupQuestions(
    QuestionBankGroupModel group,
  ) async {
    final itemQuestions = await _loadGroupItemQuestions(group);
    if (itemQuestions.isNotEmpty) return itemQuestions;
    return _loadCourseQuestionsForGroup(group);
  }

  Future<List<QuestionBankQuestionModel>> _loadGroupItemQuestions(
    QuestionBankGroupModel group,
  ) async {
    if (group.items.isEmpty) return const [];
    final loaded = <QuestionBankQuestionModel>[];
    final sortedItems = [...group.items]
      ..sort((a, b) => a.itemOrder.compareTo(b.itemOrder));
    for (final item in sortedItems) {
      final result = await _questionBankService.getQuestion(item.questionId);
      if (result.isSuccess && result.data != null) loaded.add(result.data!);
    }
    return loaded;
  }

  Future<List<QuestionBankQuestionModel>> _loadCourseQuestionsForGroup(
    QuestionBankGroupModel group,
  ) async {
    final result = await _questionBankService.getQuestions(
      courseId: group.courseId,
      limit: 500,
    );
    if (!result.isSuccess || result.data == null) return const [];
    return result.data!.data
        .where(
          (question) =>
              question.groups.any((summary) => summary.groupId == group.id),
        )
        .toList()
      ..sort((a, b) {
        final aOrder = _groupItemOrder(a, group.id);
        final bOrder = _groupItemOrder(b, group.id);
        return aOrder.compareTo(bOrder);
      });
  }

  int _groupItemOrder(QuestionBankQuestionModel question, int groupId) {
    for (final summary in question.groups) {
      if (summary.groupId == groupId) return summary.itemOrder;
    }
    return question.id;
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
    emitIfOpen(
      state.copyWith(isMutating: true, clearError: true, clearAction: true),
    );
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
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'groupCreateFailed',
        ),
      );
      return null;
    }
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        group: result.data,
        actionMessage: 'groupSaved',
      ),
    );
    return result.data!.id;
  }

  Future<bool> updateGroup({
    required int groupId,
    String? title,
    String? sharedPrompt,
    int? sharedFileId,
    String? sharedFileCaption,
    String? sharedFileAltText,
    QuestionGroupType? groupType,
    bool clearSharedFile = false,
  }) async {
    emitIfOpen(
      state.copyWith(isMutating: true, clearError: true, clearAction: true),
    );
    final result = await _questionBankService.updateGroup(
      groupId: groupId,
      title: title,
      sharedPrompt: sharedPrompt,
      sharedFileId: sharedFileId,
      sharedFileCaption: sharedFileCaption,
      sharedFileAltText: sharedFileAltText,
      groupType: groupType,
      clearSharedFile: clearSharedFile,
    );
    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'groupUpdateFailed',
        ),
      );
      return false;
    }
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        group: result.data,
        actionMessage: 'groupSaved',
      ),
    );
    return true;
  }

  Future<QuestionBankUploadResponse?> uploadGroupImage(
    String path, {
    bool showSuccessMessage = true,
  }) async {
    emitIfOpen(
      state.copyWith(isMutating: true, clearError: true, clearAction: true),
    );
    final result = await _questionBankService.uploadGroupImage(path);
    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'groupImageUploadFailed',
        ),
      );
      return null;
    }
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        actionMessage: showSuccessMessage ? 'groupImageUploaded' : null,
      ),
    );
    return result.data;
  }

  Future<int?> uploadQuestionImage(
    String path, {
    bool showSuccessMessage = true,
  }) async {
    emitIfOpen(
      state.copyWith(isMutating: true, clearError: true, clearAction: true),
    );
    final result = await _questionBankService.uploadQuestionImage(path);
    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'questionImageUploadFailed',
        ),
      );
      return null;
    }
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        actionMessage: showSuccessMessage ? 'questionImageUploaded' : null,
      ),
    );
    return result.data!.fileId;
  }

  Future<void> deleteUploadedQuestionImage(
    int fileId, {
    bool showSuccessMessage = true,
  }) async {
    emitIfOpen(
      state.copyWith(isMutating: true, clearError: true, clearAction: true),
    );
    final result = await _questionBankService.deleteUploadedFile(fileId);
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        errorMessage: result.isSuccess
            ? null
            : result.error?.message ?? 'questionImageDeleteFailed',
        actionMessage: result.isSuccess && showSuccessMessage
            ? 'questionImageRemoved'
            : null,
      ),
    );
  }

  Future<void> discardUploadedQuestionImages(Iterable<int> fileIds) async {
    for (final fileId in fileIds.toSet()) {
      if (fileId > 0) {
        await _questionBankService.deleteUploadedFile(fileId);
      }
    }
  }

  Future<void> createChapter({
    required String name,
    required int chapterOrder,
  }) async {
    final group = state.group;
    if (group == null) return;
    emitIfOpen(
      state.copyWith(isMutating: true, clearError: true, clearAction: true),
    );
    final result = await _questionBankService.createChapter(
      courseId: group.courseId,
      name: name,
      chapterOrder: chapterOrder,
    );
    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'chapterCreateFailed',
        ),
      );
      return;
    }
    final chapters = await _questionBankService.getChapters(group.courseId);
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        chapters: chapters.data ?? [...state.chapters, result.data!],
        actionMessage: 'chapterCreated',
      ),
    );
  }

  Future<bool> deleteGroup(int groupId) async {
    emitIfOpen(
      state.copyWith(isMutating: true, clearError: true, clearAction: true),
    );
    final result = await _questionBankService.deleteGroup(groupId);
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'groupDeleteFailed',
        ),
      );
      return false;
    }
    emitIfOpen(
      state.copyWith(isMutating: false, actionMessage: 'groupDeleted'),
    );
    return true;
  }

  Future<bool> addGroupedQuestions(
    List<QuestionBankFormPayload> questions,
  ) async {
    final group = state.group;
    if (group == null) return false;
    emitIfOpen(
      state.copyWith(isMutating: true, clearError: true, clearAction: true),
    );
    final result = await _questionBankService.addGroupedQuestions(
      groupId: group.id,
      questions: questions,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'groupedBatchFailed',
        ),
      );
      return false;
    }
    final createdQuestions = result.data ?? const <QuestionBankQuestionModel>[];
    _cacheGroupQuestions(group.id, createdQuestions);
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        createdQuestions: createdQuestions,
        questions: _mergeQuestions(state.questions, createdQuestions),
        actionMessage: 'groupedQuestionsCreated',
      ),
    );
    return true;
  }

  Future<bool> statusCreatedQuestions(String action) async {
    if (state.createdQuestions.isEmpty) return false;
    emitIfOpen(
      state.copyWith(isMutating: true, clearError: true, clearAction: true),
    );
    final result = await _questionBankService.batchStatusAction(
      questionIds: state.createdQuestions
          .map((question) => question.id)
          .toList(),
      action: action,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'bulkStatusFailed',
        ),
      );
      return false;
    }
    final updatedQuestions = result.data ?? state.createdQuestions;
    final groupId = state.group?.id;
    if (groupId != null) _cacheGroupQuestions(groupId, updatedQuestions);
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        createdQuestions: updatedQuestions,
        questions: _mergeQuestions(state.questions, updatedQuestions),
        actionMessage: 'questionsStatusUpdated',
      ),
    );
    return true;
  }

  Future<bool> statusCreatedQuestion({
    required int questionId,
    required String action,
  }) async {
    if (state.createdQuestions.isEmpty) return false;
    emitIfOpen(
      state.copyWith(isMutating: true, clearError: true, clearAction: true),
    );
    final result = await _questionBankService.statusAction(
      questionId: questionId,
      action: action,
    );
    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'bulkStatusFailed',
        ),
      );
      return false;
    }
    final updated = result.data!;
    final groupId = state.group?.id;
    if (groupId != null) _cacheGroupQuestions(groupId, [updated]);
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        createdQuestions: state.createdQuestions
            .map((question) => question.id == questionId ? updated : question)
            .toList(),
        questions: state.questions
            .map((question) => question.id == questionId ? updated : question)
            .toList(),
        actionMessage: 'questionStatusUpdated:${updated.status.value}',
      ),
    );
    return true;
  }

  void clearCreatedQuestions() {
    emitIfOpen(state.copyWith(clearCreatedQuestions: true, clearAction: true));
  }

  void syncResolvedQuestions(List<QuestionBankQuestionModel> questions) {
    if (questions.isEmpty || state.questions.length >= questions.length) {
      return;
    }
    final groupId = state.group?.id;
    if (groupId != null) _cacheGroupQuestions(groupId, questions);
    emitIfOpen(
      state.copyWith(questions: _mergeQuestions(state.questions, questions)),
    );
  }

  Future<bool> removeQuestionFromGroup(int questionId) async {
    final group = state.group;
    if (group == null) return false;
    emitIfOpen(
      state.copyWith(isMutating: true, clearError: true, clearAction: true),
    );
    final result = await _questionBankService.unlinkGroupQuestion(
      groupId: group.id,
      questionId: questionId,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'groupQuestionRemoveFailed',
        ),
      );
      return false;
    }
    _recentGroupQuestions[group.id] =
        (_recentGroupQuestions[group.id] ?? const [])
            .where((question) => question.id != questionId)
            .toList();
    if (_recentGroupQuestions[group.id]?.isEmpty ?? false) {
      _recentGroupQuestions.remove(group.id);
    }
    await load(group.id);
    emitIfOpen(
      state.copyWith(isMutating: false, actionMessage: 'groupQuestionRemoved'),
    );
    return true;
  }

  Future<bool> archiveQuestion(int questionId) async {
    final group = state.group;
    if (group == null) return false;
    emitIfOpen(
      state.copyWith(isMutating: true, clearError: true, clearAction: true),
    );
    final result = await _questionBankService.statusAction(
      questionId: questionId,
      action: 'archive',
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'questionDeleteFailed',
        ),
      );
      return false;
    }
    _recentGroupQuestions[group.id] =
        (_recentGroupQuestions[group.id] ?? const [])
            .where((question) => question.id != questionId)
            .toList();
    if (_recentGroupQuestions[group.id]?.isEmpty ?? false) {
      _recentGroupQuestions.remove(group.id);
    }
    await load(group.id);
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        actionMessage:
            'questionStatusUpdated:${QuestionBankStatus.archived.value}',
      ),
    );
    return true;
  }

  Future<bool> linkExistingQuestions(List<int> questionIds) async {
    final group = state.group;
    if (group == null || questionIds.isEmpty) return false;
    emitIfOpen(
      state.copyWith(isMutating: true, clearError: true, clearAction: true),
    );
    final result = await _questionBankService.linkGroupQuestions(
      groupId: group.id,
      questionIds: questionIds,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'groupLinkQuestionsFailed',
        ),
      );
      return false;
    }
    final linkedQuestions = result.data ?? const <QuestionBankQuestionModel>[];
    _cacheGroupQuestions(group.id, linkedQuestions);
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        questions: _mergeQuestions(state.questions, linkedQuestions),
        actionMessage: 'groupQuestionsLinked',
      ),
    );
    return true;
  }

  List<QuestionBankQuestionModel> _mergeQuestions(
    List<QuestionBankQuestionModel> current,
    List<QuestionBankQuestionModel> incoming,
  ) {
    if (incoming.isEmpty) return current;
    final byId = <int, QuestionBankQuestionModel>{
      for (final question in current) question.id: question,
    };
    for (final question in incoming) {
      byId[question.id] = question;
    }
    return byId.values.toList();
  }

  void _cacheGroupQuestions(
    int groupId,
    List<QuestionBankQuestionModel> questions,
  ) {
    if (questions.isEmpty) return;
    _recentGroupQuestions[groupId] = _mergeQuestions(
      _recentGroupQuestions[groupId] ?? const <QuestionBankQuestionModel>[],
      questions,
    );
  }

  Future<void> reorderQuestions(List<int> orderedQuestionIds) async {
    final group = state.group;
    if (group == null) return;
    final existing = state.questions.map((question) => question.id).toSet();
    if (orderedQuestionIds.length != existing.length ||
        orderedQuestionIds.toSet().length != existing.length ||
        !orderedQuestionIds.toSet().containsAll(existing)) {
      emitIfOpen(state.copyWith(errorMessage: 'groupReorderInvalid'));
      return;
    }
    emitIfOpen(
      state.copyWith(isMutating: true, clearError: true, clearAction: true),
    );
    final result = await _questionBankService.reorderGroupQuestions(
      groupId: group.id,
      items: [
        for (var i = 0; i < orderedQuestionIds.length; i++)
          {'questionId': orderedQuestionIds[i], 'itemOrder': i},
      ],
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'groupReorderFailed',
        ),
      );
      return;
    }
    await load(group.id);
    emitIfOpen(
      state.copyWith(isMutating: false, actionMessage: 'groupReordered'),
    );
  }
}
