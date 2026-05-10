import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/bloc/route_request_controller.dart';
import '../../../models/exams/exam_draft_model.dart';
import '../../../models/exams/exam_generation_readiness_model.dart';
import '../../../models/exams/exam_generation_rule_model.dart';
import '../../../models/exams/exam_generation_section_model.dart';
import '../../../models/exams/exam_generator_enums.dart';
import '../../../models/exams/exam_response_model.dart';
import '../../../models/exams/exam_shortage_model.dart';
import '../../../models/exams/exam_stats_model.dart';
import '../../../services/api/enrollment_service.dart';
import '../../../services/api/exam_generator_service.dart';
import 'exam_generator_state.dart';

class ExamGeneratorCubit extends Cubit<ExamGeneratorState>
    with SafeRouteCubitMixin<ExamGeneratorState> {
  ExamGeneratorCubit({
    required ExamGeneratorService examGeneratorService,
    required EnrollmentService enrollmentService,
  }) : _examGeneratorService = examGeneratorService,
       _enrollmentService = enrollmentService,
       super(const ExamGeneratorState());

  final ExamGeneratorService _examGeneratorService;
  final EnrollmentService _enrollmentService;
  late final RouteRequestController _loadRequest = trackRouteRequest(
    RouteRequestController(),
  );
  late final RouteRequestController _statsRequest = trackRouteRequest(
    RouteRequestController(),
  );
  late final RouteRequestController _readinessRequest = trackRouteRequest(
    RouteRequestController(),
  );
  late final RouteRequestController _draftsRequest = trackRouteRequest(
    RouteRequestController(),
  );
  late final RouteRequestController _examsRequest = trackRouteRequest(
    RouteRequestController(),
  );
  final Map<int, ExamDraftModel> _draftCache = <int, ExamDraftModel>{};
  final Map<int, ExamResponseModel> _examCache = <int, ExamResponseModel>{};
  final Map<int, ExamStatsModel> _statsCache = <int, ExamStatsModel>{};
  final Map<int, ExamGenerationReadinessModel> _readinessCache =
      <int, ExamGenerationReadinessModel>{};
  Timer? _filterDebounce;

  Future<void> initialize({int? preferredCourseId}) async {
    final request = _loadRequest.begin();
    emitIfOpen(state.copyWith(isLoading: true, clearError: true));
    final courses = await _enrollmentService.getTeachingCourses(
      cancelToken: _loadRequest.token,
    );
    if (!isRequestCurrent(_loadRequest, request)) return;
    if (!courses.isSuccess || courses.data == null) {
      emitIfOpen(
        state.copyWith(
          isLoading: false,
          errorMessage: courses.error?.message ?? 'Failed to load courses',
        ),
      );
      return;
    }
    final list = courses.data!;
    final selected =
        preferredCourseId != null &&
            list.any((course) => course.courseId == preferredCourseId)
        ? preferredCourseId
        : list.isNotEmpty
        ? list.first.courseId
        : null;
    emitIfOpen(
      state.copyWith(
        teachingCourses: list,
        selectedCourseId: selected,
        isLoading: false,
      ),
    );
    await refresh();
  }

  Future<void> refresh({bool quiet = false}) async {
    await Future.wait(<Future<void>>[
      loadStats(),
      loadReadiness(),
      loadDrafts(refresh: true, quiet: quiet || state.drafts.isNotEmpty),
      loadExams(refresh: true, quiet: quiet || state.exams.isNotEmpty),
    ]);
  }

  Future<void> loadStats() async {
    final courseId = state.selectedCourseId;
    if (courseId != null && _statsCache.containsKey(courseId)) {
      emitIfOpen(state.copyWith(stats: _statsCache[courseId]));
    }
    final request = _statsRequest.begin();
    final result = await _examGeneratorService.getStats(courseId: courseId);
    if (!isRequestCurrent(_statsRequest, request)) return;
    if (result.isSuccess) {
      if (courseId != null && result.data != null) {
        _statsCache[courseId] = result.data!;
      }
      emitIfOpen(state.copyWith(stats: result.data, clearError: true));
    }
  }

  Future<void> loadReadiness() async {
    final courseId = state.selectedCourseId;
    if (courseId == null) {
      emitIfOpen(state.copyWith(clearReadiness: true, isPoolLoading: false));
      return;
    }
    if (_readinessCache.containsKey(courseId)) {
      emitIfOpen(state.copyWith(readiness: _readinessCache[courseId]));
    } else {
      emitIfOpen(state.copyWith(isPoolLoading: true));
    }
    final request = _readinessRequest.begin();
    final result = await _examGeneratorService.getGenerationReadiness(
      courseId: courseId,
    );
    if (!isRequestCurrent(_readinessRequest, request)) return;
    if (result.isSuccess) {
      if (result.data != null) {
        _readinessCache[courseId] = result.data!;
      }
      emitIfOpen(state.copyWith(readiness: result.data, clearError: true));
    }
    emitIfOpen(state.copyWith(isPoolLoading: false));
  }

  Future<void> setFilters({
    int? courseId,
    bool clearCourse = false,
    ExamDraftStatus? draftStatus,
    bool clearDraftStatus = false,
    ExamStatus? examStatus,
    bool clearExamStatus = false,
    ExamGeneratorListKind? listKind,
    String? search,
    bool clearSearch = false,
    DateTime? dateFrom,
    DateTime? dateTo,
    bool clearDates = false,
    bool refreshRemote = true,
  }) async {
    _filterDebounce?.cancel();
    final targetCourseId = clearCourse
        ? null
        : courseId ?? state.selectedCourseId;
    final courseChanged = targetCourseId != state.selectedCourseId;
    final targetListKind = listKind ?? state.selectedListKind;
    final normalizeDraftStatus =
        clearDraftStatus ||
        targetListKind == ExamGeneratorListKind.saved ||
        listKind == ExamGeneratorListKind.all;
    final normalizeExamStatus =
        clearExamStatus ||
        targetListKind == ExamGeneratorListKind.drafts ||
        listKind == ExamGeneratorListKind.all;
    final cachedStats = targetCourseId == null
        ? null
        : _statsCache[targetCourseId];
    final cachedReadiness = targetCourseId == null
        ? null
        : _readinessCache[targetCourseId];
    final nextState = _withLocalPreview(
      state.copyWith(
        selectedCourseId: courseId,
        clearCourse: clearCourse,
        stats: cachedStats,
        clearStats: courseChanged && cachedStats == null,
        readiness: cachedReadiness,
        clearReadiness: courseChanged && cachedReadiness == null,
        selectedDraftStatus: draftStatus,
        clearDraftStatus: normalizeDraftStatus,
        selectedExamStatus: examStatus,
        clearExamStatus: normalizeExamStatus,
        selectedListKind: listKind,
        search: search,
        clearSearch: clearSearch,
        dateFrom: dateFrom,
        dateTo: dateTo,
        clearDates: clearDates,
        draftPage: 1,
        examPage: 1,
        isRefreshing: refreshRemote,
        isLoading: false,
        isLoadingMore: false,
        isSelectionMode: false,
        clearSelection: true,
        clearError: true,
      ),
    );
    emitIfOpen(nextState);
    if (!refreshRemote) return;
    _filterDebounce = Timer(const Duration(milliseconds: 80), () {
      if (!isClosed) {
        refresh(quiet: true);
      }
    });
  }

  void toggleDraftSelection(int draftId) {
    final nextDraftIds = _toggleId(state.selectedDraftIds, draftId);
    emitIfOpen(
      state.copyWith(
        isSelectionMode: true,
        selectedDraftIds: nextDraftIds,
        clearError: true,
      ),
    );
  }

  void toggleExamSelection(int examId) {
    final nextExamIds = _toggleId(state.selectedExamIds, examId);
    emitIfOpen(
      state.copyWith(
        isSelectionMode: true,
        selectedExamIds: nextExamIds,
        clearError: true,
      ),
    );
  }

  void setSelectionMode(bool enabled) {
    emitIfOpen(
      state.copyWith(
        isSelectionMode: enabled,
        clearSelection: !enabled,
        clearError: true,
      ),
    );
  }

  void selectVisibleRecords({
    required Iterable<int> draftIds,
    required Iterable<int> examIds,
  }) {
    emitIfOpen(
      state.copyWith(
        isSelectionMode: true,
        selectedDraftIds: _sortedIds(draftIds),
        selectedExamIds: _sortedIds(examIds),
        clearError: true,
      ),
    );
  }

  void clearSelection() {
    emitIfOpen(state.copyWith(clearSelection: true, clearError: true));
  }

  Future<bool> deleteSelectedRecords() async {
    final draftIds = List<int>.from(state.selectedDraftIds);
    final examIds = List<int>.from(state.selectedExamIds);
    if (draftIds.isEmpty && examIds.isEmpty) return false;
    emitIfOpen(
      state.copyWith(
        isMutating: true,
        activeMutationAction: 'delete',
        clearAction: true,
        clearError: true,
      ),
    );
    final result = await _examGeneratorService.batchDeleteRecords(
      draftIds: draftIds,
      examIds: examIds,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage:
              result.error?.message ?? 'Failed to delete selected records',
          clearActiveMutationAction: true,
        ),
      );
      return false;
    }
    _removeDeletedRecords(draftIds: draftIds, examIds: examIds);
    await refresh(quiet: true);
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        actionMessage: 'Selected exam records deleted',
        isSelectionMode: false,
        clearSelection: true,
        clearActiveMutationAction: true,
      ),
    );
    return true;
  }

  Future<bool> deleteDraftRecord(int draftId) async {
    emitIfOpen(
      state.copyWith(
        isMutating: true,
        activeMutationAction: 'delete',
        clearAction: true,
        clearError: true,
      ),
    );
    final result = await _examGeneratorService.deleteDraft(draftId);
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'Failed to delete draft',
          clearActiveMutationAction: true,
        ),
      );
      return false;
    }
    _removeDeletedRecords(draftIds: <int>[draftId]);
    await refresh(quiet: true);
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        actionMessage: 'Draft deleted',
        isSelectionMode: false,
        clearSelection: true,
        clearActiveMutationAction: true,
      ),
    );
    return true;
  }

  Future<bool> deleteExamRecord(int examId) async {
    emitIfOpen(
      state.copyWith(
        isMutating: true,
        activeMutationAction: 'delete',
        clearAction: true,
        clearError: true,
      ),
    );
    final result = await _examGeneratorService.deleteExam(examId);
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'Failed to delete exam',
          clearActiveMutationAction: true,
        ),
      );
      return false;
    }
    _removeDeletedRecords(examIds: <int>[examId]);
    await refresh(quiet: true);
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        actionMessage: 'Exam deleted',
        isSelectionMode: false,
        clearSelection: true,
        clearActiveMutationAction: true,
      ),
    );
    return true;
  }

  Future<bool> saveSelectedDrafts() async {
    final draftIds = List<int>.from(state.selectedDraftIds);
    if (draftIds.isEmpty) return false;
    emitIfOpen(
      state.copyWith(
        isMutating: true,
        activeMutationAction: 'save',
        clearAction: true,
        clearError: true,
      ),
    );
    final result = await _examGeneratorService.batchSaveDrafts(draftIds);
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'Failed to save drafts',
          clearActiveMutationAction: true,
        ),
      );
      return false;
    }
    _draftCache.removeWhere((id, draft) => draftIds.contains(id));
    await refresh(quiet: true);
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        actionMessage: 'Selected drafts saved',
        isSelectionMode: false,
        clearSelection: true,
        clearActiveMutationAction: true,
      ),
    );
    return true;
  }

  Future<bool> applySelectedExamLifecycle(String action) async {
    final examIds = List<int>.from(state.selectedExamIds);
    if (examIds.isEmpty) return false;
    emitIfOpen(
      state.copyWith(
        isMutating: true,
        activeMutationAction: action,
        clearAction: true,
        clearError: true,
      ),
    );
    final updated = <ExamResponseModel>[];
    for (final examId in examIds) {
      final result = await _examGeneratorService.lifecycle(
        examId: examId,
        action: action,
      );
      if (!result.isSuccess || result.data == null) {
        emitIfOpen(
          state.copyWith(
            isMutating: false,
            errorMessage:
                result.error?.message ?? 'Failed to update selected exams',
            clearActiveMutationAction: true,
          ),
        );
        return false;
      }
      updated.add(result.data!);
    }
    _cacheExams(updated);
    await refresh(quiet: true);
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        actionMessage: _bulkLifecycleMessage(action),
        isSelectionMode: false,
        clearSelection: true,
        clearActiveMutationAction: true,
      ),
    );
    return true;
  }

  Future<void> loadDrafts({
    bool refresh = false,
    int? page,
    bool quiet = false,
  }) async {
    final request = _draftsRequest.begin();
    final queryState = state;
    final nextPage = refresh ? 1 : page ?? state.draftPage;
    if (!quiet) {
      emitIfOpen(
        state.copyWith(
          isLoading: nextPage == 1,
          isLoadingMore: nextPage > 1,
          clearError: true,
        ),
      );
    } else {
      emitIfOpen(state.copyWith(isRefreshing: true, clearError: true));
    }
    final result = await _examGeneratorService.getDrafts(
      courseId: queryState.selectedCourseId,
      status: queryState.selectedDraftStatus,
      dateFrom: queryState.dateFrom,
      dateTo: queryState.dateTo,
      page: nextPage,
      limit: queryState.limit,
    );
    if (!isRequestCurrent(_draftsRequest, request)) return;
    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          isLoading: false,
          isRefreshing: false,
          isLoadingMore: false,
          errorMessage: result.error?.message ?? 'Failed to load drafts',
        ),
      );
      return;
    }
    final pageData = result.data!;
    _cacheDrafts(pageData.data);
    final nextState = state.copyWith(
      draftPage: pageData.page,
      draftTotalPages: pageData.totalPages,
    );
    emitIfOpen(
      nextState.copyWith(
        isLoading: false,
        isRefreshing: false,
        isLoadingMore: false,
        drafts: _filteredCachedDrafts(nextState),
        clearError: true,
      ),
    );
  }

  Future<void> loadExams({
    bool refresh = false,
    int? page,
    bool quiet = false,
  }) async {
    final request = _examsRequest.begin();
    final queryState = state;
    final nextPage = refresh ? 1 : page ?? state.examPage;
    if (!quiet) {
      emitIfOpen(
        state.copyWith(
          isLoading: nextPage == 1,
          isLoadingMore: nextPage > 1,
          clearError: true,
        ),
      );
    } else {
      emitIfOpen(state.copyWith(isRefreshing: true, clearError: true));
    }
    final result = await _examGeneratorService.getExams(
      courseId: queryState.selectedCourseId,
      status: queryState.selectedExamStatus,
      dateFrom: queryState.dateFrom,
      dateTo: queryState.dateTo,
      page: nextPage,
      limit: queryState.limit,
    );
    if (!isRequestCurrent(_examsRequest, request)) return;
    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          isLoading: false,
          isRefreshing: false,
          isLoadingMore: false,
          errorMessage: result.error?.message ?? 'Failed to load exams',
        ),
      );
      return;
    }
    final pageData = result.data!;
    _cacheExams(pageData.data);
    final nextState = state.copyWith(
      examPage: pageData.page,
      examTotalPages: pageData.totalPages,
    );
    emitIfOpen(
      nextState.copyWith(
        isLoading: false,
        isRefreshing: false,
        isLoadingMore: false,
        exams: _filteredCachedExams(nextState),
        clearError: true,
      ),
    );
  }

  Future<int?> generateDraft({
    required int courseId,
    required String title,
    List<ExamGenerationRuleModel> rules = const <ExamGenerationRuleModel>[],
    List<ExamGenerationSectionModel> sections =
        const <ExamGenerationSectionModel>[],
    double? totalMarks,
    ExamGroupSelectionMode groupSelectionMode =
        ExamGroupSelectionMode.independent,
  }) async {
    emitIfOpen(
      state.copyWith(isMutating: true, clearShortages: true, clearError: true),
    );
    final result = await _examGeneratorService.generatePreview(
      courseId: courseId,
      title: title,
      rules: rules,
      sections: sections,
      totalMarks: totalMarks,
      groupSelectionMode: groupSelectionMode,
    );
    if (!result.isSuccess || result.data == null) {
      final original = result.error?.originalError;
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'Failed to generate draft',
          shortages: original is ExamShortageException
              ? original.shortages
              : const <ExamShortageModel>[],
        ),
      );
      return null;
    }
    emitIfOpen(
      state.copyWith(isMutating: false, actionMessage: 'Draft generated'),
    );
    return result.data!.id;
  }

  ExamGeneratorState _withLocalPreview(ExamGeneratorState nextState) {
    return nextState.copyWith(
      drafts: _filteredCachedDrafts(nextState),
      exams: _filteredCachedExams(nextState),
    );
  }

  List<ExamDraftModel> _filteredCachedDrafts(ExamGeneratorState filters) {
    final query = filters.search.trim().toLowerCase();
    return _draftCache.values.where((draft) {
      if (filters.selectedCourseId != null &&
          draft.courseId != filters.selectedCourseId) {
        return false;
      }
      if (filters.selectedDraftStatus != null &&
          draft.status != filters.selectedDraftStatus) {
        return false;
      }
      if (!_matchesDate(
        draft.createdAt ?? draft.updatedAt ?? draft.expiresAt,
        filters,
      )) {
        return false;
      }
      if (query.isNotEmpty && !draft.title.toLowerCase().contains(query)) {
        return false;
      }
      return true;
    }).toList()..sort(
      (a, b) => (b.updatedAt ?? b.createdAt ?? b.expiresAt).compareTo(
        a.updatedAt ?? a.createdAt ?? a.expiresAt,
      ),
    );
  }

  List<ExamResponseModel> _filteredCachedExams(ExamGeneratorState filters) {
    final query = filters.search.trim().toLowerCase();
    return _examCache.values.where((exam) {
      if (filters.selectedCourseId != null &&
          exam.courseId != filters.selectedCourseId) {
        return false;
      }
      if (filters.selectedExamStatus != null &&
          exam.status != filters.selectedExamStatus) {
        return false;
      }
      final date =
          exam.updatedAt ??
          exam.createdAt ??
          exam.publishedAt ??
          exam.archivedAt;
      if (date != null && !_matchesDate(date, filters)) {
        return false;
      }
      if (query.isNotEmpty && !exam.title.toLowerCase().contains(query)) {
        return false;
      }
      return true;
    }).toList()..sort((a, b) {
      final bDate =
          b.updatedAt ??
          b.createdAt ??
          b.publishedAt ??
          b.archivedAt ??
          DateTime.fromMillisecondsSinceEpoch(b.id);
      final aDate =
          a.updatedAt ??
          a.createdAt ??
          a.publishedAt ??
          a.archivedAt ??
          DateTime.fromMillisecondsSinceEpoch(a.id);
      return bDate.compareTo(aDate);
    });
  }

  List<int> _toggleId(List<int> ids, int id) {
    final next = ids.toSet();
    next.contains(id) ? next.remove(id) : next.add(id);
    return _sortedIds(next);
  }

  List<int> _sortedIds(Iterable<int> ids) {
    return ids.where((id) => id > 0).toSet().toList()..sort();
  }

  void _removeDeletedRecords({
    List<int> draftIds = const <int>[],
    List<int> examIds = const <int>[],
  }) {
    final deletedDraftIds = draftIds.toSet();
    final deletedExamIds = examIds.toSet();
    for (final id in deletedDraftIds) {
      _draftCache.remove(id);
    }
    for (final id in deletedExamIds) {
      _examCache.remove(id);
    }
    if (deletedExamIds.isNotEmpty) {
      _draftCache.removeWhere(
        (_, draft) =>
            draft.finalizedExamId != null &&
            deletedExamIds.contains(draft.finalizedExamId),
      );
    }
    final nextState = _withLocalPreview(
      state.copyWith(
        selectedDraftIds: state.selectedDraftIds
            .where((id) => !deletedDraftIds.contains(id))
            .toList(),
        selectedExamIds: state.selectedExamIds
            .where((id) => !deletedExamIds.contains(id))
            .toList(),
      ),
    );
    emitIfOpen(nextState);
  }

  String _bulkLifecycleMessage(String action) {
    switch (action) {
      case 'publish':
        return 'Selected exams published';
      case 'unpublish':
        return 'Selected exams moved to draft';
      case 'archive':
        return 'Selected exams archived';
      default:
        return 'Selected exams updated';
    }
  }

  bool _matchesDate(DateTime date, ExamGeneratorState filters) {
    final local = DateTime(date.year, date.month, date.day);
    final from = filters.dateFrom == null
        ? null
        : DateTime(
            filters.dateFrom!.year,
            filters.dateFrom!.month,
            filters.dateFrom!.day,
          );
    final to = filters.dateTo == null
        ? null
        : DateTime(
            filters.dateTo!.year,
            filters.dateTo!.month,
            filters.dateTo!.day,
          );
    if (from != null && local.isBefore(from)) return false;
    if (to != null && local.isAfter(to)) return false;
    return true;
  }

  void _cacheDrafts(List<ExamDraftModel> drafts) {
    for (final draft in drafts) {
      _draftCache[draft.id] = draft;
    }
  }

  void _cacheExams(List<ExamResponseModel> exams) {
    for (final exam in exams) {
      _examCache[exam.id] = exam;
    }
  }

  @override
  Future<void> close() {
    _filterDebounce?.cancel();
    return super.close();
  }
}
