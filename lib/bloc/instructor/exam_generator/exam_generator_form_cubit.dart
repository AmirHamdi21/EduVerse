import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/bloc/route_request_controller.dart';

import '../../../models/exams/exam_generation_form_model.dart';
import '../../../models/exams/exam_generation_rule_model.dart';
import '../../../models/exams/exam_generation_section_model.dart';
import '../../../models/exams/exam_generator_enums.dart';
import '../../../models/exams/exam_shortage_model.dart';
import '../../../services/api/enrollment_service.dart';
import '../../../services/api/exam_generator_service.dart';
import '../../../services/api/question_bank_service.dart';
import 'exam_generator_form_state.dart';

class ExamGeneratorFormCubit extends Cubit<ExamGeneratorFormState>
    with SafeRouteCubitMixin<ExamGeneratorFormState> {
  ExamGeneratorFormCubit({
    required ExamGeneratorService examGeneratorService,
    required QuestionBankService questionBankService,
    required EnrollmentService enrollmentService,
  }) : _examGeneratorService = examGeneratorService,
       _questionBankService = questionBankService,
       _enrollmentService = enrollmentService,
       super(const ExamGeneratorFormState());

  final ExamGeneratorService _examGeneratorService;
  final QuestionBankService _questionBankService;
  final EnrollmentService _enrollmentService;
  late final RouteRequestController _availabilityRequest = trackRouteRequest(
    RouteRequestController(),
  );
  late final RouteRequestController _courseDataRequest = trackRouteRequest(
    RouteRequestController(),
  );
  Timer? _availabilityDebounce;

  Future<void> initialize() async {
    emitIfOpen(state.copyWith(isLoading: true, clearError: true));
    final coursesResult = await _enrollmentService.getTeachingCourses();
    final courses = coursesResult.data ?? const [];
    final courseId = courses.isNotEmpty ? courses.first.courseId : null;
    emitIfOpen(state.copyWith(courses: courses, courseId: courseId));
    if (courseId != null) {
      await selectCourse(courseId);
    }
    emitIfOpen(state.copyWith(isLoading: false));
  }

  Future<void> selectCourse(int? courseId) async {
    _availabilityDebounce?.cancel();
    _availabilityRequest.cancel('course_changed');
    emitIfOpen(
      state.copyWith(
        courseId: courseId,
        clearCourse: courseId == null,
        isLoadingCourseData: courseId != null,
        chapters: const [],
        groups: const [],
        clearAvailability: true,
        clearShortages: true,
        clearError: true,
      ),
    );
    if (courseId == null) {
      emitIfOpen(state.copyWith(isLoadingCourseData: false));
      return;
    }
    final requestId = _courseDataRequest.begin();
    final chaptersResult = await _questionBankService.getChapters(
      courseId,
      cancelToken: _courseDataRequest.token,
    );
    final groupsResult = await _questionBankService.getGroups(
      courseId: courseId,
      cancelToken: _courseDataRequest.token,
    );
    if (!isRequestCurrent(_courseDataRequest, requestId)) return;
    final list = chaptersResult.data ?? const [];
    final groups = groupsResult.data ?? const [];
    final validChapterIds = list.map((chapter) => chapter.id).toSet();
    final validGroupIds = groups.map((group) => group.id).toSet();
    final fallbackChapterId = list.isNotEmpty ? list.first.id : null;
    final normalizedRules = _normalizeRules(
      state.rules,
      validChapterIds,
      validGroupIds,
      fallbackChapterId,
    );
    final normalizedSections = [
      for (final section in state.sections)
        ExamGenerationSectionModel(
          title: section.title,
          instructions: section.instructions,
          totalMarks: section.totalMarks,
          answerPolicy: section.answerPolicy,
          requiredAnswerCount: section.requiredAnswerCount,
          rules: _normalizeRules(
            section.rules,
            validChapterIds,
            validGroupIds,
            fallbackChapterId,
          ),
        ),
    ];
    emitIfOpen(
      state.copyWith(
        chapters: list,
        groups: groups,
        isLoadingCourseData: false,
        rules: normalizedRules.isEmpty && fallbackChapterId != null
            ? [
                ExamGenerationRuleModel(
                  chapterId: fallbackChapterId,
                  count: 10,
                  weightPerQuestion: 1,
                ),
              ]
            : normalizedRules,
        sections: normalizedSections,
      ),
    );
    await checkAvailability(debounce: false);
  }

  List<ExamGenerationRuleModel> _normalizeRules(
    List<ExamGenerationRuleModel> rules,
    Set<int> validChapterIds,
    Set<int> validGroupIds,
    int? fallbackChapterId,
  ) {
    return [
      for (final rule in rules)
        rule.copyWith(
          chapterId: validChapterIds.contains(rule.chapterId)
              ? rule.chapterId
              : fallbackChapterId,
          chapterIds: rule.chapterIds
              .where(validChapterIds.contains)
              .toList(growable: false),
          groupIds: rule.groupIds
              .where(validGroupIds.contains)
              .toList(growable: false),
        ),
    ];
  }

  void updateBasics({
    String? title,
    double? totalMarks,
    bool clearTotalMarks = false,
    ExamGenerationMode? mode,
    ExamMarkDistributionMode? markDistributionMode,
    ExamRoundingPolicy? roundingPolicy,
    ExamGroupSelectionMode? groupSelectionMode,
    String? seed,
    int? durationMinutes,
    bool clearDuration = false,
    String? instructions,
    String? headerText,
    String? footerText,
  }) {
    final affectsAvailability = mode != null || groupSelectionMode != null;
    emitIfOpen(
      state.copyWith(
        title: title,
        totalMarks: totalMarks,
        clearTotalMarks: clearTotalMarks,
        mode: mode,
        markDistributionMode: markDistributionMode,
        roundingPolicy: roundingPolicy,
        groupSelectionMode: groupSelectionMode,
        seed: seed,
        durationMinutes: durationMinutes,
        clearDuration: clearDuration,
        instructions: instructions,
        headerText: headerText,
        footerText: footerText,
        clearError: true,
        clearAvailability: affectsAvailability,
      ),
    );
    if (affectsAvailability) {
      checkAvailability();
    }
  }

  void updateRules(List<ExamGenerationRuleModel> rules) {
    emitIfOpen(
      state.copyWith(rules: rules, clearError: true, clearShortages: true),
    );
    checkAvailability();
  }

  void updateSections(List<ExamGenerationSectionModel> sections) {
    emitIfOpen(
      state.copyWith(
        sections: sections,
        clearError: true,
        clearShortages: true,
      ),
    );
    checkAvailability();
  }

  void randomizeSeed() {
    const alphabet = 'abcdefghjkmnpqrstuvwxyz23456789';
    final random = Random();
    final token = List.generate(
      8,
      (_) => alphabet[random.nextInt(alphabet.length)],
    ).join();
    updateBasics(seed: 'version-$token');
  }

  void clearSeed() {
    updateBasics(seed: '');
  }

  Future<void> checkAvailability({bool debounce = true}) async {
    _availabilityDebounce?.cancel();
    if (debounce) {
      _availabilityDebounce = Timer(const Duration(milliseconds: 520), () {
        if (!isClosed) {
          _runAvailabilityCheck();
        }
      });
      return;
    }
    await _runAvailabilityCheck();
  }

  Future<void> _runAvailabilityCheck() async {
    if (state.courseId == null || state.isLoadingCourseData) return;
    final rules = state.mode == ExamGenerationMode.flat
        ? state.rules
        : const <ExamGenerationRuleModel>[];
    final sections = state.mode == ExamGenerationMode.sectioned
        ? state.sections
        : const <ExamGenerationSectionModel>[];
    if (rules.isEmpty && sections.isEmpty) return;
    final requestId = _availabilityRequest.begin();
    final snapshot = state;
    emitIfOpen(state.copyWith(isCheckingAvailability: true, clearError: true));
    final result = await _examGeneratorService.checkGenerationAvailability(
      courseId: snapshot.courseId!,
      title: snapshot.title,
      rules: rules,
      sections: sections,
      totalMarks: snapshot.totalMarks,
      markDistributionMode: snapshot.markDistributionMode,
      roundingPolicy: snapshot.roundingPolicy,
      groupSelectionMode: snapshot.groupSelectionMode,
      seed: snapshot.seed,
      durationMinutes: snapshot.durationMinutes,
      instructions: snapshot.instructions,
      headerText: snapshot.headerText,
      footerText: snapshot.footerText,
      cancelToken: _availabilityRequest.token,
    );
    if (!isRequestCurrent(_availabilityRequest, requestId)) return;
    emitIfOpen(
      state.copyWith(
        isCheckingAvailability: false,
        availability: result.data,
        errorMessage: result.isSuccess ? null : result.error?.message,
      ),
    );
  }

  Future<int?> submit() async {
    final form = ExamGenerationFormModel(
      courseId: state.courseId,
      title: state.title,
      totalMarks: state.totalMarks,
      mode: state.mode,
      markDistributionMode: state.markDistributionMode,
      roundingPolicy: state.roundingPolicy,
      groupSelectionMode: state.groupSelectionMode,
      seed: state.seed,
      durationMinutes: state.durationMinutes,
      instructions: state.instructions,
      headerText: state.headerText,
      footerText: state.footerText,
      rules: state.rules,
      sections: state.sections,
    );
    final validation = form.validate();
    if (validation != null) {
      emitIfOpen(state.copyWith(errorMessage: validation));
      return null;
    }
    emitIfOpen(
      state.copyWith(
        isSubmitting: true,
        clearError: true,
        clearShortages: true,
        clearDraft: true,
      ),
    );
    final result = await _examGeneratorService.generatePreview(
      courseId: state.courseId!,
      title: state.title,
      rules: state.mode == ExamGenerationMode.flat ? state.rules : const [],
      sections: state.mode == ExamGenerationMode.sectioned
          ? state.sections
          : const [],
      totalMarks: state.totalMarks,
      markDistributionMode: state.markDistributionMode,
      roundingPolicy: state.roundingPolicy,
      groupSelectionMode: state.groupSelectionMode,
      seed: state.seed,
      durationMinutes: state.durationMinutes,
      instructions: state.instructions,
      headerText: state.headerText,
      footerText: state.footerText,
    );
    if (!result.isSuccess || result.data == null) {
      final original = result.error?.originalError;
      emitIfOpen(
        state.copyWith(
          isSubmitting: false,
          errorMessage: result.error?.message ?? 'examGenerateFailed',
          shortages: original is ExamShortageException
              ? original.shortages
              : const <ExamShortageModel>[],
        ),
      );
      return null;
    }
    emitIfOpen(
      state.copyWith(isSubmitting: false, createdDraftId: result.data!.id),
    );
    return result.data!.id;
  }

  @override
  Future<void> close() {
    _availabilityDebounce?.cancel();
    return super.close();
  }
}
