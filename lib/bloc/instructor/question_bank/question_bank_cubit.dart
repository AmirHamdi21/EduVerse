import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/bloc/route_request_controller.dart';
import '../../../models/question_bank/question_bank_enums.dart';
import '../../../models/question_bank/question_bank_group_model.dart';
import '../../../models/question_bank/question_bank_question_model.dart';
import '../../../services/api/enrollment_service.dart';
import '../../../services/api/question_bank_service.dart';
import 'question_group_cubit.dart';
import 'question_bank_state.dart';

class QuestionBankCubit extends Cubit<QuestionBankState>
    with SafeRouteCubitMixin<QuestionBankState> {
  QuestionBankCubit({
    required QuestionBankService questionBankService,
    required EnrollmentService enrollmentService,
  }) : _questionBankService = questionBankService,
       _enrollmentService = enrollmentService,
       super(const QuestionBankState());

  final QuestionBankService _questionBankService;
  final EnrollmentService _enrollmentService;
  late final RouteRequestController _loadRequest = trackRouteRequest(
    RouteRequestController(),
  );
  late final RouteRequestController _questionsRequest = trackRouteRequest(
    RouteRequestController(),
  );
  late final RouteRequestController _statsRequest = trackRouteRequest(
    RouteRequestController(),
  );
  final Map<int, QuestionBankQuestionModel> _questionCache =
      <int, QuestionBankQuestionModel>{};
  Timer? _remoteFilterDebounce;

  Future<void> initialize({int? preferredCourseId}) async {
    final request = _loadRequest.begin();
    emitIfOpen(state.copyWith(isLoading: true, clearError: true));

    final coursesResult = await _enrollmentService.getTeachingCourses(
      cancelToken: _loadRequest.token,
    );
    if (!isRequestCurrent(_loadRequest, request)) return;
    if (!coursesResult.isSuccess || coursesResult.data == null) {
      emitIfOpen(
        state.copyWith(
          isLoading: false,
          errorMessage:
              coursesResult.error?.message ?? 'Failed to load courses',
        ),
      );
      return;
    }

    final courses = coursesResult.data!;
    final selected =
        preferredCourseId != null &&
            courses.any((course) => course.courseId == preferredCourseId)
        ? preferredCourseId
        : courses.isNotEmpty
        ? courses.first.courseId
        : null;

    emitIfOpen(
      state.copyWith(
        teachingCourses: courses,
        selectedCourseId: selected,
        isLoading: true,
        clearError: true,
      ),
    );

    await _loadDependent(resetPage: true);
  }

  Future<void> selectCourse(int? courseId) async {
    _remoteFilterDebounce?.cancel();
    final nextState = _withLocalQuestionPreview(
      state.copyWith(
        selectedCourseId: courseId,
        clearSelectedCourse: courseId == null,
        clearSelectedChapter: true,
        clearGroup: true,
        clearSelectedQuestionIds: true,
        clearExcludedQuestionIds: true,
        isAllMatchingQuestionsSelected: false,
        page: 1,
        isLoading: false,
        isLoadingMore: false,
        clearError: true,
      ),
    );
    emitIfOpen(nextState);
    await Future.wait(<Future<void>>[
      loadChapters(),
      loadGroups(),
      loadQuestions(refresh: true, refreshStats: false),
      loadStats(),
    ]);
  }

  Future<void> setFilters({
    int? chapterId,
    bool clearChapter = false,
    QuestionBankType? type,
    bool clearType = false,
    QuestionBankDifficulty? difficulty,
    bool clearDifficulty = false,
    BloomLevel? bloomLevel,
    bool clearBloom = false,
    QuestionBankStatus? status,
    bool clearStatus = false,
    bool? hasAttachments,
    bool clearHasAttachments = false,
    int? groupId,
    bool clearGroup = false,
    String? search,
    bool debounceRemote = false,
  }) async {
    _remoteFilterDebounce?.cancel();
    final nextState = _withLocalQuestionPreview(
      state.copyWith(
        selectedChapterId: chapterId,
        clearSelectedChapter: clearChapter,
        selectedType: type,
        clearType: clearType,
        selectedDifficulty: difficulty,
        clearDifficulty: clearDifficulty,
        selectedBloomLevel: bloomLevel,
        clearBloom: clearBloom,
        selectedStatus: status,
        clearStatus: clearStatus,
        hasAttachments: hasAttachments,
        clearHasAttachments: clearHasAttachments,
        selectedGroupId: groupId,
        clearGroup: clearGroup,
        search: search,
        page: 1,
        isLoading: false,
        isLoadingMore: false,
        clearSelectedQuestionIds: true,
        clearExcludedQuestionIds: true,
        isAllMatchingQuestionsSelected: false,
        clearError: true,
      ),
    );
    emitIfOpen(nextState);
    if (debounceRemote) {
      _remoteFilterDebounce = Timer(const Duration(milliseconds: 120), () {
        if (!isClosed) {
          loadQuestions(refresh: true);
        }
      });
      return;
    }
    await loadQuestions(refresh: true);
  }

  Future<void> refresh() => _loadDependent(resetPage: true);

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;
    await loadQuestions(page: state.page + 1);
  }

  Future<void> _loadDependent({required bool resetPage}) async {
    await Future.wait(<Future<void>>[
      loadChapters(),
      loadGroups(),
      loadQuestions(refresh: resetPage, refreshStats: false),
      loadStats(),
    ]);
  }

  Future<void> loadChapters() async {
    final courseId = state.selectedCourseId;
    if (courseId == null) {
      emitIfOpen(state.copyWith(chapters: const []));
      return;
    }
    final result = await _questionBankService.getChapters(courseId);
    if (result.isSuccess && result.data != null) {
      emitIfOpen(state.copyWith(chapters: result.data!));
      await loadChapterQuestionCounts();
    }
  }

  Future<void> loadChapterQuestionCounts() async {
    final courseId = state.selectedCourseId;
    if (courseId == null || state.chapters.isEmpty) {
      emitIfOpen(state.copyWith(chapterQuestionCounts: const <int, int>{}));
      return;
    }
    final result = await _questionBankService.getChapterQuestionCounts(
      courseId,
    );
    if (result.isSuccess && result.data != null) {
      emitIfOpen(state.copyWith(chapterQuestionCounts: result.data!));
    }
  }

  Future<bool> createChapter({required String name, int? chapterOrder}) async {
    final courseId = state.selectedCourseId;
    if (courseId == null) {
      emitIfOpen(state.copyWith(errorMessage: 'courseRequired'));
      return false;
    }
    emitIfOpen(
      state.copyWith(isMutating: true, clearError: true, clearAction: true),
    );
    final result = await _questionBankService.createChapter(
      courseId: courseId,
      name: name,
      chapterOrder: chapterOrder,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'chapterCreateFailed',
        ),
      );
      return false;
    }
    await _loadDependent(resetPage: true);
    emitIfOpen(
      state.copyWith(isMutating: false, actionMessage: 'chapterCreated'),
    );
    return true;
  }

  Future<bool> updateChapter({
    required int chapterId,
    String? name,
    int? chapterOrder,
    bool? isActive,
  }) async {
    final courseId = state.selectedCourseId;
    if (courseId == null) return false;
    emitIfOpen(
      state.copyWith(isMutating: true, clearError: true, clearAction: true),
    );
    final result = await _questionBankService.updateChapter(
      courseId: courseId,
      chapterId: chapterId,
      name: name,
      chapterOrder: chapterOrder,
      isActive: isActive,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'chapterUpdateFailed',
        ),
      );
      return false;
    }
    await _loadDependent(resetPage: true);
    emitIfOpen(
      state.copyWith(isMutating: false, actionMessage: 'chapterUpdated'),
    );
    return true;
  }

  Future<bool> deleteChapter(int chapterId) async {
    final courseId = state.selectedCourseId;
    if (courseId == null) return false;
    emitIfOpen(
      state.copyWith(isMutating: true, clearError: true, clearAction: true),
    );
    final result = await _questionBankService.deleteChapter(
      courseId: courseId,
      chapterId: chapterId,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'chapterDeleteFailed',
        ),
      );
      return false;
    }
    emitIfOpen(
      state.copyWith(
        selectedChapterId: null,
        clearSelectedChapter: state.selectedChapterId == chapterId,
      ),
    );
    await _loadDependent(resetPage: true);
    emitIfOpen(
      state.copyWith(isMutating: false, actionMessage: 'chapterDeleted'),
    );
    return true;
  }

  Future<void> loadGroups() async {
    final result = await _questionBankService.getGroups(
      courseId: state.selectedCourseId,
      chapterId: state.selectedChapterId,
    );
    if (result.isSuccess && result.data != null) {
      emitIfOpen(state.copyWith(groups: result.data!));
    }
  }

  Future<void> loadQuestions({
    int page = 1,
    bool refresh = false,
    bool quiet = false,
    bool refreshStats = true,
  }) async {
    final request = _questionsRequest.begin();
    final queryState = state;
    if (!(quiet && page == 1)) {
      emitIfOpen(
        state.copyWith(
          isLoading: page == 1,
          isLoadingMore: page > 1,
          clearError: true,
        ),
      );
    }
    final result = await _questionBankService.getQuestions(
      courseId: queryState.selectedCourseId,
      chapterId: queryState.selectedChapterId,
      questionType: queryState.selectedType,
      difficulty: queryState.selectedDifficulty,
      bloomLevel: queryState.selectedBloomLevel,
      status: queryState.selectedStatus,
      search: queryState.search,
      hasAttachments: queryState.hasAttachments,
      groupId: queryState.selectedGroupId,
      page: page,
      limit: queryState.limit,
      cancelToken: _questionsRequest.token,
    );
    if (!isRequestCurrent(_questionsRequest, request)) return;
    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          errorMessage: result.error?.message ?? 'Failed to load questions',
        ),
      );
      return;
    }
    final pageData = result.data!;
    _cacheQuestions(pageData.data);
    emitIfOpen(
      state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        questions: page == 1
            ? pageData.data
            : <QuestionBankQuestionModel>[...state.questions, ...pageData.data],
        page: pageData.page,
        limit: pageData.limit,
        total: pageData.total,
        clearError: true,
      ),
    );
    if (page == 1 && refreshStats) {
      await loadStats();
    }
  }

  Future<void> loadStats() async {
    final request = _statsRequest.begin();
    final queryState = state;
    final result = await _questionBankService.getQuestionStats(
      courseId: queryState.selectedCourseId,
      chapterId: queryState.selectedChapterId,
      questionType: queryState.selectedType,
      difficulty: queryState.selectedDifficulty,
      bloomLevel: queryState.selectedBloomLevel,
      status: queryState.selectedStatus,
      search: queryState.search,
      hasAttachments: queryState.hasAttachments,
      groupId: queryState.selectedGroupId,
      cancelToken: _statsRequest.token,
    );
    if (!isRequestCurrent(_statsRequest, request)) return;
    if (result.isSuccess && result.data != null) {
      emitIfOpen(state.copyWith(stats: result.data!));
    }
  }

  Future<void> statusAction(int questionId, String action) async {
    emitIfOpen(state.copyWith(isMutating: true, clearAction: true));
    final result = await _questionBankService.statusAction(
      questionId: questionId,
      action: action,
    );
    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'Failed to update question',
        ),
      );
      return;
    }
    final updated = result.data!;
    _questionCache[updated.id] = updated;
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        questions: state.questions
            .map((question) => question.id == updated.id ? updated : question)
            .toList(),
        actionMessage: 'questionStatusUpdated:${updated.status.value}',
      ),
    );
    await loadStats();
  }

  void setSelectionMode(bool enabled) {
    emitIfOpen(
      state.copyWith(
        isSelectionMode: enabled,
        clearSelectedQuestionIds: !enabled,
        clearExcludedQuestionIds: !enabled,
        isAllMatchingQuestionsSelected: enabled
            ? state.isAllMatchingQuestionsSelected
            : false,
      ),
    );
  }

  void toggleQuestionSelection(int questionId) {
    if (state.isAllMatchingQuestionsSelected) {
      final excluded = Set<int>.from(state.excludedQuestionIds);
      if (excluded.contains(questionId)) {
        excluded.remove(questionId);
      } else {
        excluded.add(questionId);
      }
      emitIfOpen(
        state.copyWith(excludedQuestionIds: excluded, isSelectionMode: true),
      );
      return;
    }
    final selected = Set<int>.from(state.selectedQuestionIds);
    if (selected.contains(questionId)) {
      selected.remove(questionId);
    } else {
      selected.add(questionId);
    }
    emitIfOpen(
      state.copyWith(
        selectedQuestionIds: selected,
        isSelectionMode: selected.isNotEmpty || state.isSelectionMode,
      ),
    );
  }

  void setCurrentQuestionsSelected(bool selected) {
    final currentIds = state.questions.map((question) => question.id).toSet();
    if (selected) {
      final next = Set<int>.from(state.selectedQuestionIds)..addAll(currentIds);
      emitIfOpen(
        state.copyWith(
          selectedQuestionIds: next,
          clearExcludedQuestionIds: true,
          isAllMatchingQuestionsSelected: false,
          isSelectionMode: true,
        ),
      );
    } else {
      final next = Set<int>.from(state.selectedQuestionIds)
        ..removeAll(currentIds);
      emitIfOpen(
        state.copyWith(
          selectedQuestionIds: next,
          clearExcludedQuestionIds: true,
          isAllMatchingQuestionsSelected: false,
          isSelectionMode: true,
        ),
      );
    }
  }

  void selectAllMatchingQuestions() {
    if (state.total <= 0) return;
    emitIfOpen(
      state.copyWith(
        selectedQuestionIds: const <int>{},
        clearExcludedQuestionIds: true,
        isAllMatchingQuestionsSelected: true,
        isSelectionMode: true,
      ),
    );
  }

  Future<void> batchStatusAction(String action) async {
    if (!state.hasSelectedQuestions) return;
    emitIfOpen(
      state.copyWith(
        isMutating: true,
        activeBatchAction: action,
        clearAction: true,
        clearError: true,
      ),
    );
    final result = await _questionBankService.batchStatusAction(
      questionIds: state.selectedQuestionIds.toList(),
      action: action,
      allMatchingFilters: state.isAllMatchingQuestionsSelected,
      excludeQuestionIds: state.excludedQuestionIds.toList(),
      expectedQuestionCount: state.selectedQuestionCount,
      courseId: state.selectedCourseId,
      chapterId: state.selectedChapterId,
      questionType: state.selectedType,
      difficulty: state.selectedDifficulty,
      bloomLevel: state.selectedBloomLevel,
      status: state.selectedStatus,
      search: state.search,
      hasAttachments: state.hasAttachments,
      groupId: state.selectedGroupId,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          clearActiveBatchAction: true,
          errorMessage:
              result.error?.message ?? 'Failed to update selected questions',
        ),
      );
      return;
    }
    await _refreshAfterBatchAction();
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        clearActiveBatchAction: true,
        isSelectionMode: false,
        clearSelectedQuestionIds: true,
        clearExcludedQuestionIds: true,
        isAllMatchingQuestionsSelected: false,
        actionMessage: 'questionsBatchUpdated',
      ),
    );
  }

  Future<void> batchDeleteQuestions() async {
    if (!state.hasSelectedQuestions) return;
    emitIfOpen(
      state.copyWith(
        isMutating: true,
        activeBatchAction: 'delete',
        clearAction: true,
        clearError: true,
      ),
    );
    final result = await _questionBankService.batchDeleteQuestions(
      questionIds: state.selectedQuestionIds.toList(),
      allMatchingFilters: state.isAllMatchingQuestionsSelected,
      excludeQuestionIds: state.excludedQuestionIds.toList(),
      expectedQuestionCount: state.selectedQuestionCount,
      courseId: state.selectedCourseId,
      chapterId: state.selectedChapterId,
      questionType: state.selectedType,
      difficulty: state.selectedDifficulty,
      bloomLevel: state.selectedBloomLevel,
      status: state.selectedStatus,
      search: state.search,
      hasAttachments: state.hasAttachments,
      groupId: state.selectedGroupId,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          clearActiveBatchAction: true,
          errorMessage: result.error?.message ?? 'questionsDeleteFailed',
        ),
      );
      return;
    }
    final deletedIds = result.data ?? const <int>[];
    for (final questionId in deletedIds) {
      _questionCache.remove(questionId);
      QuestionGroupCubit.purgeQuestionFromCaches(questionId);
    }
    await _refreshAfterBatchAction();
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        clearActiveBatchAction: true,
        isSelectionMode: false,
        clearSelectedQuestionIds: true,
        clearExcludedQuestionIds: true,
        isAllMatchingQuestionsSelected: false,
        actionMessage: 'questionsDeleted',
      ),
    );
  }

  bool isQuestionSelected(int questionId) {
    if (state.isAllMatchingQuestionsSelected) {
      return !state.excludedQuestionIds.contains(questionId);
    }
    return state.selectedQuestionIds.contains(questionId);
  }

  Future<void> _refreshAfterBatchAction() async {
    await loadQuestions(refresh: true, quiet: true, refreshStats: true);
    await Future.wait(<Future<void>>[loadChapters(), loadGroups()]);
  }

  Future<void> deleteQuestion(int questionId) async {
    final removedQuestion = _questionById(questionId);
    emitIfOpen(
      state.copyWith(
        isMutating: true,
        activeBatchAction: 'delete',
        clearAction: true,
        clearError: true,
      ),
    );
    final result = await _questionBankService.deleteQuestion(questionId);
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          clearActiveBatchAction: true,
          errorMessage: result.error?.message ?? 'questionDeleteFailed',
        ),
      );
      return;
    }
    _questionCache.remove(questionId);
    QuestionGroupCubit.purgeQuestionFromCaches(questionId);
    await _refreshAfterBatchAction();
    final adjustedGroups = removedQuestion == null
        ? state.groups
        : _decrementGroupCountersForQuestion(state.groups, removedQuestion);
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        clearActiveBatchAction: true,
        groups: adjustedGroups,
        actionMessage: 'questionDeleted',
      ),
    );
  }

  Future<void> unlinkQuestionFromGroup({
    required int questionId,
    required int groupId,
  }) async {
    final removedQuestion = _questionById(questionId);
    emitIfOpen(
      state.copyWith(
        isMutating: true,
        activeBatchAction: 'unlink',
        clearAction: true,
        clearError: true,
      ),
    );
    final result = await _questionBankService.unlinkGroupQuestion(
      groupId: groupId,
      questionId: questionId,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          clearActiveBatchAction: true,
          errorMessage: result.error?.message ?? 'groupQuestionRemoveFailed',
        ),
      );
      return;
    }
    QuestionGroupCubit.removeCachedQuestionFromGroup(
      groupId: groupId,
      questionId: questionId,
    );
    await _refreshAfterBatchAction();
    final adjustedGroups = removedQuestion == null
        ? state.groups
        : _decrementGroupCountersForQuestion(
            state.groups,
            removedQuestion,
            onlyGroupId: groupId,
          );
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        clearActiveBatchAction: true,
        groups: adjustedGroups,
        actionMessage: 'groupQuestionRemoved',
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
      state.copyWith(
        groups: state.groups.where((group) => group.id != groupId).toList(),
      ),
    );
    await loadGroups();
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        groups: state.groups.where((group) => group.id != groupId).toList(),
        actionMessage: 'groupDeleted',
      ),
    );
    return true;
  }

  QuestionBankQuestionModel? _questionById(int questionId) {
    for (final question in state.questions) {
      if (question.id == questionId) return question;
    }
    return _questionCache[questionId];
  }

  List<QuestionBankGroupModel> _decrementGroupCountersForQuestion(
    List<QuestionBankGroupModel> groups,
    QuestionBankQuestionModel question, {
    int? onlyGroupId,
  }) {
    final affectedGroupIds = onlyGroupId == null
        ? question.groups.map((group) => group.groupId).toSet()
        : <int>{onlyGroupId};
    if (affectedGroupIds.isEmpty) return groups;
    return [
      for (final group in groups)
        affectedGroupIds.contains(group.id)
            ? _decrementGroupCounters(group, question.status)
            : group,
    ];
  }

  QuestionBankGroupModel _decrementGroupCounters(
    QuestionBankGroupModel group,
    QuestionBankStatus status,
  ) {
    int decrement(int value) => value <= 0 ? 0 : value - 1;
    return switch (status) {
      QuestionBankStatus.approved => group.copyWith(
        totalQuestions: decrement(group.totalQuestions),
        approvedQuestions: decrement(group.approvedQuestions),
      ),
      QuestionBankStatus.draft => group.copyWith(
        totalQuestions: decrement(group.totalQuestions),
        draftQuestions: decrement(group.draftQuestions),
      ),
      QuestionBankStatus.underReview => group.copyWith(
        totalQuestions: decrement(group.totalQuestions),
        underReviewQuestions: decrement(group.underReviewQuestions),
      ),
      QuestionBankStatus.rejected => group.copyWith(
        totalQuestions: decrement(group.totalQuestions),
        rejectedQuestions: decrement(group.rejectedQuestions),
      ),
      QuestionBankStatus.archived => group.copyWith(
        totalQuestions: decrement(group.totalQuestions),
        archivedQuestions: decrement(group.archivedQuestions),
      ),
    };
  }

  QuestionBankState _withLocalQuestionPreview(QuestionBankState nextState) {
    if (_questionCache.isEmpty) {
      return nextState;
    }

    final filtered = _filteredCachedQuestions(nextState);
    return nextState.copyWith(
      questions: filtered,
      page: 1,
      total: filtered.length,
      isLoading: false,
      isLoadingMore: false,
    );
  }

  List<QuestionBankQuestionModel> _filteredCachedQuestions(
    QuestionBankState filters,
  ) {
    final query = filters.search.trim().toLowerCase();
    return _questionCache.values.where((question) {
      if (filters.selectedCourseId != null &&
          question.courseId != filters.selectedCourseId) {
        return false;
      }
      if (filters.selectedChapterId != null &&
          question.chapterId != filters.selectedChapterId) {
        return false;
      }
      if (filters.selectedType != null &&
          question.questionType != filters.selectedType) {
        return false;
      }
      if (filters.selectedDifficulty != null &&
          question.difficulty != filters.selectedDifficulty) {
        return false;
      }
      if (filters.selectedBloomLevel != null &&
          question.bloomLevel != filters.selectedBloomLevel) {
        return false;
      }
      if (filters.selectedStatus != null &&
          question.status != filters.selectedStatus) {
        return false;
      }
      if (filters.hasAttachments != null &&
          question.hasAttachments != filters.hasAttachments) {
        return false;
      }
      if (filters.selectedGroupId != null &&
          !question.groups.any(
            (group) => group.groupId == filters.selectedGroupId,
          )) {
        return false;
      }
      if (query.isNotEmpty &&
          !(question.questionText ?? '').toLowerCase().contains(query)) {
        return false;
      }
      return true;
    }).toList();
  }

  void _cacheQuestions(List<QuestionBankQuestionModel> questions) {
    for (final question in questions) {
      _questionCache[question.id] = question;
    }
  }

  @override
  Future<void> close() {
    _remoteFilterDebounce?.cancel();
    return super.close();
  }
}
