import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/bloc/route_request_controller.dart';
import '../../../models/exams/exam_draft_model.dart';
import '../../../models/exams/exam_generation_rule_model.dart';
import '../../../models/exams/exam_generation_section_model.dart';
import '../../../models/exams/exam_generator_enums.dart';
import '../../../models/exams/exam_response_model.dart';
import '../../../models/exams/exam_shortage_model.dart';
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
    final selected = preferredCourseId != null &&
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

  Future<void> refresh() async {
    await Future.wait(<Future<void>>[
      loadStats(),
      loadReadiness(),
      loadDrafts(refresh: true),
      loadExams(refresh: true),
    ]);
  }

  Future<void> loadStats() async {
    final result = await _examGeneratorService.getStats(
      courseId: state.selectedCourseId,
    );
    if (result.isSuccess) {
      emitIfOpen(state.copyWith(stats: result.data, clearError: true));
    }
  }

  Future<void> loadReadiness() async {
    final courseId = state.selectedCourseId;
    if (courseId == null) return;
    final result = await _examGeneratorService.getGenerationReadiness(
      courseId: courseId,
    );
    if (result.isSuccess) {
      emitIfOpen(state.copyWith(readiness: result.data, clearError: true));
    }
  }

  Future<void> selectTab(int index) async {
    emitIfOpen(state.copyWith(selectedTabIndex: index));
  }

  Future<void> setFilters({
    int? courseId,
    bool clearCourse = false,
    ExamDraftStatus? draftStatus,
    bool clearDraftStatus = false,
    ExamStatus? examStatus,
    bool clearExamStatus = false,
    DateTime? dateFrom,
    DateTime? dateTo,
    bool clearDates = false,
  }) async {
    emitIfOpen(
      state.copyWith(
        selectedCourseId: courseId,
        clearCourse: clearCourse,
        selectedDraftStatus: draftStatus,
        clearDraftStatus: clearDraftStatus,
        selectedExamStatus: examStatus,
        clearExamStatus: clearExamStatus,
        dateFrom: dateFrom,
        dateTo: dateTo,
        clearDates: clearDates,
        draftPage: 1,
        examPage: 1,
      ),
    );
    await refresh();
  }

  Future<void> loadDrafts({bool refresh = false, int? page}) async {
    final nextPage = refresh ? 1 : page ?? state.draftPage;
    emitIfOpen(state.copyWith(isLoading: nextPage == 1, isLoadingMore: nextPage > 1));
    final result = await _examGeneratorService.getDrafts(
      courseId: state.selectedCourseId,
      status: state.selectedDraftStatus,
      dateFrom: state.dateFrom,
      dateTo: state.dateTo,
      page: nextPage,
      limit: state.limit,
    );
    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          errorMessage: result.error?.message ?? 'Failed to load drafts',
        ),
      );
      return;
    }
    final pageData = result.data!;
    emitIfOpen(
      state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        drafts: nextPage == 1
            ? pageData.data
            : <ExamDraftModel>[...state.drafts, ...pageData.data],
        draftPage: pageData.page,
        draftTotalPages: pageData.totalPages,
        clearError: true,
      ),
    );
  }

  Future<void> loadExams({bool refresh = false, int? page}) async {
    final nextPage = refresh ? 1 : page ?? state.examPage;
    emitIfOpen(state.copyWith(isLoading: nextPage == 1, isLoadingMore: nextPage > 1));
    final result = await _examGeneratorService.getExams(
      courseId: state.selectedCourseId,
      status: state.selectedExamStatus,
      dateFrom: state.dateFrom,
      dateTo: state.dateTo,
      page: nextPage,
      limit: state.limit,
    );
    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          errorMessage: result.error?.message ?? 'Failed to load exams',
        ),
      );
      return;
    }
    final pageData = result.data!;
    emitIfOpen(
      state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        exams: nextPage == 1
            ? pageData.data
            : <ExamResponseModel>[...state.exams, ...pageData.data],
        examPage: pageData.page,
        examTotalPages: pageData.totalPages,
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
    ExamGroupSelectionMode groupSelectionMode = ExamGroupSelectionMode.independent,
  }) async {
    emitIfOpen(state.copyWith(isMutating: true, clearShortages: true, clearError: true));
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
    emitIfOpen(state.copyWith(isMutating: false, actionMessage: 'Draft generated'));
    return result.data!.id;
  }
}
