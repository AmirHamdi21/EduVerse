import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/bloc/route_request_controller.dart';
import '../../../models/question_bank/question_bank_enums.dart';
import '../../../models/question_bank/question_bank_question_model.dart';
import '../../../services/api/enrollment_service.dart';
import '../../../services/api/question_bank_service.dart';
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
    emitIfOpen(
      state.copyWith(
        selectedCourseId: courseId,
        clearSelectedCourse: courseId == null,
        clearSelectedChapter: true,
        clearGroup: true,
        page: 1,
        questions: const [],
      ),
    );
    await _loadDependent(resetPage: true);
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
        clearError: true,
      ),
    );
    emitIfOpen(nextState);
    if (debounceRemote) {
      _remoteFilterDebounce = Timer(const Duration(milliseconds: 120), () {
        if (!isClosed) {
          loadQuestions(refresh: true, quiet: true);
        }
      });
      return;
    }
    await loadQuestions(refresh: true, quiet: true);
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

  Future<void> createChapter({required String name, int? chapterOrder}) async {
    final courseId = state.selectedCourseId;
    if (courseId == null) {
      emitIfOpen(state.copyWith(errorMessage: 'courseRequired'));
      return;
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
      return;
    }
    await _loadDependent(resetPage: true);
    emitIfOpen(
      state.copyWith(isMutating: false, actionMessage: 'chapterCreated'),
    );
  }

  Future<void> updateChapter({
    required int chapterId,
    String? name,
    int? chapterOrder,
    bool? isActive,
  }) async {
    final courseId = state.selectedCourseId;
    if (courseId == null) return;
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
      return;
    }
    await _loadDependent(resetPage: true);
    emitIfOpen(
      state.copyWith(isMutating: false, actionMessage: 'chapterUpdated'),
    );
  }

  Future<void> deleteChapter(int chapterId) async {
    final courseId = state.selectedCourseId;
    if (courseId == null) return;
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
      return;
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
        actionMessage: 'Question updated',
      ),
    );
    await loadStats();
  }

  void setSelectionMode(bool enabled) {
    emitIfOpen(
      state.copyWith(
        isSelectionMode: enabled,
        clearSelectedQuestionIds: !enabled,
      ),
    );
  }

  void toggleQuestionSelection(int questionId) {
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
    final next = Set<int>.from(state.selectedQuestionIds);
    if (selected) {
      next.addAll(currentIds);
    } else {
      next.removeAll(currentIds);
    }
    emitIfOpen(
      state.copyWith(
        selectedQuestionIds: next,
        isSelectionMode: next.isNotEmpty || state.isSelectionMode,
      ),
    );
  }

  Future<void> batchStatusAction(String action) async {
    if (state.selectedQuestionIds.isEmpty) return;
    emitIfOpen(state.copyWith(isMutating: true, clearAction: true));
    final result = await _questionBankService.batchStatusAction(
      questionIds: state.selectedQuestionIds.toList(),
      action: action,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage:
              result.error?.message ?? 'Failed to update selected questions',
        ),
      );
      return;
    }
    await _loadDependent(resetPage: true);
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        isSelectionMode: false,
        clearSelectedQuestionIds: true,
        actionMessage: 'questionsBatchUpdated',
      ),
    );
  }

  Future<void> deleteQuestion(int questionId) async {
    emitIfOpen(
      state.copyWith(isMutating: true, clearAction: true, clearError: true),
    );
    final result = await _questionBankService.deleteQuestion(questionId);
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'questionDeleteFailed',
        ),
      );
      return;
    }
    _questionCache.remove(questionId);
    await loadQuestions(refresh: true);
    emitIfOpen(
      state.copyWith(isMutating: false, actionMessage: 'questionDeleted'),
    );
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
