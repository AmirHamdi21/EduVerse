import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/bloc/route_request_controller.dart';

import '../../../models/exams/exam_draft_item_update_payload.dart';
import '../../../models/exams/exam_draft_section_payload.dart';
import '../../../models/exams/exam_generator_enums.dart';
import '../../../models/question_bank/question_bank_enums.dart';
import '../../../models/question_bank/question_bank_question_model.dart';
import '../../../services/api/question_bank_service.dart';
import '../../../services/api/exam_generator_service.dart';
import 'exam_draft_editor_state.dart';

class ExamDraftEditorCubit extends Cubit<ExamDraftEditorState>
    with SafeRouteCubitMixin<ExamDraftEditorState> {
  ExamDraftEditorCubit({
    required ExamGeneratorService examGeneratorService,
    QuestionBankService? questionBankService,
  }) : _examGeneratorService = examGeneratorService,
       _questionBankService = questionBankService,
       super(const ExamDraftEditorState());

  final ExamGeneratorService _examGeneratorService;
  final QuestionBankService? _questionBankService;

  void _startMutation(String action) {
    emitIfOpen(
      state.copyWith(
        isMutating: true,
        activeMutationAction: action,
        clearError: true,
        clearAction: true,
      ),
    );
  }

  Future<void> loadDraft(int draftId, {bool showLoading = true}) async {
    if (showLoading) {
      emitIfOpen(state.copyWith(isLoading: true, clearError: true));
    } else {
      emitIfOpen(state.copyWith(clearError: true));
    }
    final result = await _examGeneratorService.getDraft(draftId);
    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          isLoading: false,
          errorMessage: result.error?.message ?? 'Failed to load draft',
        ),
      );
      return;
    }
    final validation = await _examGeneratorService.validateDraft(draftId);
    final questionService = _questionBankService;
    final chapters = questionService == null
        ? null
        : await questionService.getChapters(result.data!.courseId);
    final groups = questionService == null
        ? null
        : await questionService.getGroups(
            courseId: result.data!.courseId,
            limit: 200,
          );
    emitIfOpen(
      state.copyWith(
        isLoading: false,
        draft: result.data,
        validation: validation.data,
        candidateChapters: chapters?.data,
        candidateGroups: groups?.data,
      ),
    );
  }

  Future<void> createSection({
    required String title,
    String? instructions,
    double? totalMarks,
    ExamSectionAnswerPolicy? answerPolicy,
  }) async {
    final draft = state.draft;
    if (draft == null || !draft.isEditable) {
      emitIfOpen(state.copyWith(errorMessage: 'Draft is not editable'));
      return;
    }
    _startMutation('Creating section');
    final result = await _examGeneratorService.createSection(
      draftId: draft.id,
      title: title,
      instructions: instructions,
      totalMarks: totalMarks,
      answerPolicy: answerPolicy,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          clearMutationAction: true,
          errorMessage: result.error?.message ?? 'Failed to create section',
        ),
      );
      return;
    }
    await loadDraft(draft.id, showLoading: false);
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        clearMutationAction: true,
        actionMessage: 'Section created',
      ),
    );
  }

  Future<bool> upsertSection({
    int? sectionId,
    required ExamDraftSectionPayload payload,
  }) async {
    final draft = state.draft;
    if (draft == null || !draft.isEditable) {
      emitIfOpen(state.copyWith(errorMessage: 'Draft is not editable'));
      return false;
    }
    final validation = payload.validate();
    if (validation != null) {
      emitIfOpen(state.copyWith(errorMessage: validation));
      return false;
    }
    _startMutation(sectionId == null ? 'Creating section' : 'Saving section');
    final result = sectionId == null
        ? await _examGeneratorService.createSection(
            draftId: draft.id,
            title: payload.title,
            instructions: payload.instructions,
            totalMarks: payload.totalMarks,
            answerPolicy: payload.answerPolicy,
            requiredAnswerCount: payload.requiredAnswerCount,
          )
        : await _examGeneratorService.updateSection(
            draftId: draft.id,
            sectionId: sectionId,
            title: payload.title,
            instructions: payload.instructions,
            totalMarks: payload.totalMarks,
            answerPolicy: payload.answerPolicy,
            requiredAnswerCount: payload.requiredAnswerCount,
          );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          clearMutationAction: true,
          errorMessage: result.error?.message ?? 'Failed to save section',
        ),
      );
      return false;
    }
    await loadDraft(draft.id, showLoading: false);
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        clearMutationAction: true,
        actionMessage: 'Section saved',
      ),
    );
    return true;
  }

  Future<void> deleteSection(int sectionId) async {
    final draft = state.draft;
    if (draft == null || !draft.isEditable) {
      emitIfOpen(state.copyWith(errorMessage: 'Draft is not editable'));
      return;
    }
    _startMutation('Deleting section');
    final result = await _examGeneratorService.deleteSection(
      draftId: draft.id,
      sectionId: sectionId,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          clearMutationAction: true,
          errorMessage: result.error?.message ?? 'Failed to delete section',
        ),
      );
      return;
    }
    await loadDraft(draft.id, showLoading: false);
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        clearMutationAction: true,
        actionMessage: 'Section deleted',
      ),
    );
  }

  Future<void> reorderSections(List<int> orderedSectionIds) async {
    final draft = state.draft;
    if (draft == null || !draft.isEditable) {
      emitIfOpen(state.copyWith(errorMessage: 'Draft is not editable'));
      return;
    }
    final existing = draft.sections.map((section) => section.id).toSet();
    if (orderedSectionIds.length != existing.length ||
        orderedSectionIds.toSet().length != existing.length ||
        !orderedSectionIds.toSet().containsAll(existing)) {
      emitIfOpen(
        state.copyWith(errorMessage: 'Reorder must include every section once'),
      );
      return;
    }
    _startMutation('Saving section order');
    final result = await _examGeneratorService.reorderSections(
      draftId: draft.id,
      items: [
        for (var i = 0; i < orderedSectionIds.length; i++)
          {'sectionId': orderedSectionIds[i], 'sectionOrder': i},
      ],
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          clearMutationAction: true,
          errorMessage: result.error?.message,
        ),
      );
      return;
    }
    await loadDraft(draft.id, showLoading: false);
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        clearMutationAction: true,
        actionMessage: 'Section order saved',
      ),
    );
  }

  Future<void> addItem({
    required int questionId,
    int? draftSectionId,
    double? weightUnits,
    double? marks,
    String? overrideReason,
  }) async {
    final draft = state.draft;
    if (draft == null || !draft.isEditable) {
      emitIfOpen(state.copyWith(errorMessage: 'Draft is not editable'));
      return;
    }
    final existingQuestionIds = {
      for (final item in draft.items) ...[
        item.questionId,
        if (item.question != null) item.question!.id,
        if (item.question != null) item.question!.questionId,
      ],
    };
    if (existingQuestionIds.contains(questionId)) {
      emitIfOpen(state.copyWith(errorMessage: 'Question is already in draft'));
      return;
    }
    _startMutation('Adding question');
    final result = await _examGeneratorService.addItem(
      draftId: draft.id,
      questionId: questionId,
      draftSectionId: draftSectionId,
      weightUnits: weightUnits,
      marks: marks,
      overrideReason: overrideReason,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          clearMutationAction: true,
          clearAction: true,
          errorMessage: result.error?.message ?? 'Failed to add item',
        ),
      );
      return;
    }
    await loadDraft(draft.id, showLoading: false);
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        clearMutationAction: true,
        actionMessage: 'Item added',
      ),
    );
  }

  Future<void> updateItem({
    required int itemId,
    required ExamDraftItemUpdatePayload payload,
    bool requiresOverrideReason = false,
  }) async {
    final draft = state.draft;
    if (draft == null || !draft.isEditable) {
      emitIfOpen(state.copyWith(errorMessage: 'Draft is not editable'));
      return;
    }
    final validation = payload.validate(
      requiresOverrideReason: requiresOverrideReason,
    );
    if (validation != null) {
      emitIfOpen(state.copyWith(errorMessage: validation));
      return;
    }
    _startMutation('Updating question');
    final result = await _examGeneratorService.updateItem(
      draftId: draft.id,
      itemId: itemId,
      replacementQuestionId: payload.replacementQuestionId,
      draftSectionId: payload.draftSectionId,
      weight: payload.weight,
      weightUnits: payload.weightUnits,
      marks: payload.marks,
      itemOrder: payload.itemOrder,
      overrideReason: payload.overrideReason,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          clearMutationAction: true,
          errorMessage: result.error?.message ?? 'Failed to update item',
        ),
      );
      return;
    }
    await loadDraft(draft.id, showLoading: false);
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        clearMutationAction: true,
        actionMessage: 'Item updated',
      ),
    );
  }

  Future<bool> replacementRequiresOverride({
    required int itemId,
    required int replacementQuestionId,
  }) async {
    final draft = state.draft;
    if (draft == null) return true;
    final result = await _examGeneratorService.checkReplacement(
      draftId: draft.id,
      itemId: itemId,
      replacementQuestionId: replacementQuestionId,
    );
    if (!result.isSuccess || result.data == null) {
      emitIfOpen(state.copyWith(errorMessage: result.error?.message));
      return true;
    }
    if (result.data!.requiresOverrideReason) {
      emitIfOpen(
        state.copyWith(
          actionMessage: result.data!.reasons.isEmpty
              ? 'Replacement is outside the original rules'
              : result.data!.reasons.join('\n'),
        ),
      );
    }
    return result.data!.requiresOverrideReason;
  }

  Future<void> removeItem(int itemId) async {
    final draft = state.draft;
    if (draft == null || !draft.isEditable) {
      emitIfOpen(state.copyWith(errorMessage: 'Draft is not editable'));
      return;
    }
    if (draft.items.length <= 1) {
      emitIfOpen(
        state.copyWith(errorMessage: 'Cannot remove the last draft item'),
      );
      return;
    }
    _startMutation('Removing question');
    final result = await _examGeneratorService.removeItem(
      draftId: draft.id,
      itemId: itemId,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          clearMutationAction: true,
          errorMessage: result.error?.message ?? 'Failed to remove item',
        ),
      );
      return;
    }
    await loadDraft(draft.id, showLoading: false);
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        clearMutationAction: true,
        actionMessage: 'Item removed',
      ),
    );
  }

  Future<void> reorderItems(List<int> orderedItemIds) async {
    final draft = state.draft;
    if (draft == null || !draft.isEditable) {
      emitIfOpen(state.copyWith(errorMessage: 'Draft is not editable'));
      return;
    }
    final existing = draft.items.map((item) => item.id).toSet();
    if (orderedItemIds.length != existing.length ||
        orderedItemIds.toSet().length != existing.length ||
        !orderedItemIds.toSet().containsAll(existing)) {
      emitIfOpen(
        state.copyWith(errorMessage: 'Reorder must include every item once'),
      );
      return;
    }
    _startMutation('Saving question order');
    final result = await _examGeneratorService.reorderItems(
      draftId: draft.id,
      items: <Map<String, int>>[
        for (var i = 0; i < orderedItemIds.length; i++)
          <String, int>{'itemId': orderedItemIds[i], 'itemOrder': i},
      ],
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          clearMutationAction: true,
          errorMessage: result.error?.message,
        ),
      );
      return;
    }
    await loadDraft(draft.id, showLoading: false);
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        clearMutationAction: true,
        actionMessage: 'Question order saved',
      ),
    );
  }

  Future<bool> saveDraftOrder({
    required List<int> orderedItemIds,
    required List<int> orderedSectionIds,
  }) async {
    final draft = state.draft;
    if (draft == null || !draft.isEditable) {
      emitIfOpen(state.copyWith(errorMessage: 'Draft is not editable'));
      return false;
    }
    final existingItems = draft.items.map((item) => item.id).toSet();
    if (orderedItemIds.length != existingItems.length ||
        orderedItemIds.toSet().length != existingItems.length ||
        !orderedItemIds.toSet().containsAll(existingItems)) {
      emitIfOpen(
        state.copyWith(errorMessage: 'Reorder must include every item once'),
      );
      return false;
    }
    final existingSections = draft.sections
        .map((section) => section.id)
        .toSet();
    if (orderedSectionIds.length != existingSections.length ||
        orderedSectionIds.toSet().length != existingSections.length ||
        !orderedSectionIds.toSet().containsAll(existingSections)) {
      emitIfOpen(
        state.copyWith(errorMessage: 'Reorder must include every section once'),
      );
      return false;
    }

    final currentItemIds =
        ([...draft.items]..sort((a, b) => a.itemOrder.compareTo(b.itemOrder)))
            .map((item) => item.id)
            .toList();
    final currentSectionIds =
        ([...draft.sections]
              ..sort((a, b) => a.sectionOrder.compareTo(b.sectionOrder)))
            .map((section) => section.id)
            .toList();
    final shouldSaveItems =
        currentItemIds.join(',') != orderedItemIds.join(',');
    final shouldSaveSections =
        currentSectionIds.join(',') != orderedSectionIds.join(',');
    if (!shouldSaveItems && !shouldSaveSections) return true;

    _startMutation('Saving draft order');
    if (shouldSaveSections && orderedSectionIds.isNotEmpty) {
      final result = await _examGeneratorService.reorderSections(
        draftId: draft.id,
        items: [
          for (var i = 0; i < orderedSectionIds.length; i++)
            {'sectionId': orderedSectionIds[i], 'sectionOrder': i},
        ],
      );
      if (!result.isSuccess) {
        emitIfOpen(
          state.copyWith(
            isMutating: false,
            clearMutationAction: true,
            errorMessage: result.error?.message,
          ),
        );
        return false;
      }
    }
    if (shouldSaveItems) {
      final result = await _examGeneratorService.reorderItems(
        draftId: draft.id,
        items: <Map<String, int>>[
          for (var i = 0; i < orderedItemIds.length; i++)
            <String, int>{'itemId': orderedItemIds[i], 'itemOrder': i},
        ],
      );
      if (!result.isSuccess) {
        emitIfOpen(
          state.copyWith(
            isMutating: false,
            clearMutationAction: true,
            errorMessage: result.error?.message,
          ),
        );
        return false;
      }
    }
    await loadDraft(draft.id, showLoading: false);
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        clearMutationAction: true,
        actionMessage: 'Draft order saved',
      ),
    );
    return true;
  }

  Future<void> loadCandidateQuestions({
    int? chapterId,
    int? groupId,
    QuestionBankType? questionType,
    QuestionBankDifficulty? difficulty,
    BloomLevel? bloomLevel,
    String? search,
    bool append = false,
  }) async {
    final draft = state.draft;
    final service = _questionBankService;
    if (draft == null || service == null) return;
    final nextPage = append ? state.candidatePage + 1 : 1;
    emitIfOpen(
      state.copyWith(
        isLoadingCandidates: true,
        candidateChapterId: chapterId,
        candidateGroupId: groupId,
        candidateQuestionType: questionType,
        candidateDifficulty: difficulty,
        candidateBloomLevel: bloomLevel,
        candidateSearch: search,
        clearCandidateChapter: chapterId == null,
        clearCandidateGroup: groupId == null,
        clearCandidateType: questionType == null,
        clearCandidateDifficulty: difficulty == null,
        clearCandidateBloom: bloomLevel == null,
        clearCandidateSearch: search == null || search.trim().isEmpty,
      ),
    );
    final result = await service.getQuestions(
      courseId: draft.courseId,
      chapterId: chapterId,
      groupId: groupId,
      questionType: questionType,
      difficulty: difficulty,
      bloomLevel: bloomLevel,
      status: QuestionBankStatus.approved,
      search: search,
      page: nextPage,
      limit: 25,
    );
    final page = result.data;
    final questions = page?.data ?? const [];
    emitIfOpen(
      state.copyWith(
        isLoadingCandidates: false,
        candidateQuestions: append
            ? <QuestionBankQuestionModel>[
                ...state.candidateQuestions,
                ...questions,
              ]
            : questions,
        candidatePage: page?.page ?? nextPage,
        candidateHasMore: page?.hasMore ?? false,
        errorMessage: result.isSuccess ? null : result.error?.message,
        clearError: result.isSuccess,
      ),
    );
  }

  Future<void> loadMoreCandidateQuestions() {
    return loadCandidateQuestions(
      chapterId: state.candidateChapterId,
      groupId: state.candidateGroupId,
      questionType: state.candidateQuestionType,
      difficulty: state.candidateDifficulty,
      bloomLevel: state.candidateBloomLevel,
      search: state.candidateSearch,
      append: true,
    );
  }

  Future<int?> saveDraft() async {
    final draft = state.draft;
    if (draft == null) return null;
    _startMutation('Saving exam');
    final validation = await _examGeneratorService.validateDraft(draft.id);
    if (validation.isSuccess &&
        validation.data != null &&
        !validation.data!.canSave) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          clearMutationAction: true,
          validation: validation.data,
          errorMessage: validation.data!.errors.join('\n'),
        ),
      );
      return null;
    }
    final result = await _examGeneratorService.saveDraft(draft.id);
    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          clearMutationAction: true,
          errorMessage: result.error?.message ?? 'Failed to save exam',
        ),
      );
      return null;
    }
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        clearMutationAction: true,
        savedExam: result.data,
        actionMessage: 'Exam saved',
      ),
    );
    return result.data!.id;
  }

  Future<int?> regenerateDraft({
    String? seed,
    bool keepManualEdits = false,
  }) async {
    final draft = state.draft;
    if (draft == null || !draft.isEditable) {
      emitIfOpen(state.copyWith(errorMessage: 'Draft is not editable'));
      return null;
    }
    _startMutation('Regenerating draft');
    final result = await _examGeneratorService.regenerateDraft(
      draftId: draft.id,
      seed: seed,
      keepManualEdits: keepManualEdits,
    );
    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          clearMutationAction: true,
          errorMessage: result.error?.message ?? 'Failed to regenerate draft',
        ),
      );
      return null;
    }
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        clearMutationAction: true,
        actionMessage: 'Draft regenerated',
      ),
    );
    return result.data!.id;
  }

  Future<int?> duplicateDraft({
    String? title,
    String? seed,
    bool regenerate = false,
  }) async {
    final draft = state.draft;
    if (draft == null) return null;
    _startMutation('Duplicating draft');
    final result = await _examGeneratorService.duplicateDraft(
      draftId: draft.id,
      title: title,
      seed: seed,
      regenerate: regenerate,
    );
    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          clearMutationAction: true,
          errorMessage: result.error?.message ?? 'Failed to duplicate draft',
        ),
      );
      return null;
    }
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        clearMutationAction: true,
        actionMessage: 'Draft duplicated',
      ),
    );
    return result.data!.id;
  }

  Future<void> reloadAfterSourceEdit() async {
    final draft = state.draft;
    if (draft == null) return;
    _startMutation('Refreshing draft');
    await loadDraft(draft.id, showLoading: false);
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        clearMutationAction: true,
        actionMessage: 'Draft revalidated',
      ),
    );
  }

  Future<int?> reshuffleSection(int sectionId, {String? seed}) async {
    final draft = state.draft;
    if (draft == null || !draft.isEditable) {
      emitIfOpen(state.copyWith(errorMessage: 'Draft is not editable'));
      return null;
    }
    _startMutation('Reshuffling section');
    final result = await _examGeneratorService.reshuffleSection(
      draftId: draft.id,
      sectionId: sectionId,
      seed: seed,
    );
    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          clearMutationAction: true,
          errorMessage: result.error?.message ?? 'Failed to reshuffle section',
        ),
      );
      return null;
    }
    await loadDraft(result.data!.id, showLoading: false);
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        clearMutationAction: true,
        actionMessage: 'Section reshuffled',
      ),
    );
    return result.data!.id;
  }

  Future<void> normalizeSectionMarks(
    int sectionId, {
    double? totalMarks,
  }) async {
    final draft = state.draft;
    if (draft == null || !draft.isEditable) {
      emitIfOpen(state.copyWith(errorMessage: 'Draft is not editable'));
      return;
    }
    _startMutation('Normalizing section marks');
    final result = await _examGeneratorService.normalizeSectionMarks(
      draftId: draft.id,
      sectionId: sectionId,
      totalMarks: totalMarks,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          clearMutationAction: true,
          errorMessage: result.error?.message ?? 'Failed to normalize marks',
        ),
      );
      return;
    }
    await loadDraft(draft.id, showLoading: false);
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        clearMutationAction: true,
        actionMessage: 'Section marks normalized',
      ),
    );
  }

  Future<void> moveItemsToSection(List<int> itemIds, int? sectionId) async {
    final draft = state.draft;
    if (draft == null || !draft.isEditable) {
      emitIfOpen(state.copyWith(errorMessage: 'Draft is not editable'));
      return;
    }
    if (itemIds.isEmpty) {
      emitIfOpen(state.copyWith(errorMessage: 'Select at least one question'));
      return;
    }
    _startMutation(
      sectionId == null ? 'Unassigning questions' : 'Moving questions',
    );
    for (final itemId in itemIds) {
      final result = await _examGeneratorService.updateItem(
        draftId: draft.id,
        itemId: itemId,
        draftSectionId: sectionId,
        clearDraftSection: sectionId == null,
      );
      if (!result.isSuccess) {
        emitIfOpen(
          state.copyWith(
            isMutating: false,
            clearMutationAction: true,
            errorMessage:
                result.error?.message ?? 'Failed to move selected questions',
          ),
        );
        return;
      }
    }
    await loadDraft(draft.id, showLoading: false);
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        clearMutationAction: true,
        actionMessage: 'Selected questions moved',
      ),
    );
  }
}
