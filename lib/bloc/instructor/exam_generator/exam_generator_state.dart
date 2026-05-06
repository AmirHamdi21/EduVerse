import 'package:equatable/equatable.dart';

import '../../../models/exams/exam_draft_model.dart';
import '../../../models/exams/exam_generation_readiness_model.dart';
import '../../../models/exams/exam_generator_enums.dart';
import '../../../models/exams/exam_response_model.dart';
import '../../../models/exams/exam_shortage_model.dart';
import '../../../models/exams/exam_stats_model.dart';
import '../../../models/instructor/teaching_course_model.dart';

class ExamGeneratorState extends Equatable {
  const ExamGeneratorState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isMutating = false,
    this.errorMessage,
    this.actionMessage,
    this.shortages = const <ExamShortageModel>[],
    this.teachingCourses = const <TeachingCourseModel>[],
    this.drafts = const <ExamDraftModel>[],
    this.exams = const <ExamResponseModel>[],
    this.stats,
    this.readiness,
    this.selectedCourseId,
    this.selectedDraftStatus,
    this.selectedExamStatus,
    this.dateFrom,
    this.dateTo,
    this.draftPage = 1,
    this.examPage = 1,
    this.limit = 20,
    this.draftTotalPages = 1,
    this.examTotalPages = 1,
    this.selectedTabIndex = 0,
  });

  final bool isLoading;
  final bool isLoadingMore;
  final bool isMutating;
  final String? errorMessage;
  final String? actionMessage;
  final List<ExamShortageModel> shortages;
  final List<TeachingCourseModel> teachingCourses;
  final List<ExamDraftModel> drafts;
  final List<ExamResponseModel> exams;
  final ExamStatsModel? stats;
  final ExamGenerationReadinessModel? readiness;
  final int? selectedCourseId;
  final ExamDraftStatus? selectedDraftStatus;
  final ExamStatus? selectedExamStatus;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final int draftPage;
  final int examPage;
  final int limit;
  final int draftTotalPages;
  final int examTotalPages;
  final int selectedTabIndex;

  bool get hasMoreDrafts => draftPage < draftTotalPages;
  bool get hasMoreExams => examPage < examTotalPages;

  ExamGeneratorState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    bool? isMutating,
    String? errorMessage,
    String? actionMessage,
    bool clearError = false,
    bool clearAction = false,
    List<ExamShortageModel>? shortages,
    bool clearShortages = false,
    List<TeachingCourseModel>? teachingCourses,
    List<ExamDraftModel>? drafts,
    List<ExamResponseModel>? exams,
    ExamStatsModel? stats,
    ExamGenerationReadinessModel? readiness,
    int? selectedCourseId,
    bool clearCourse = false,
    ExamDraftStatus? selectedDraftStatus,
    bool clearDraftStatus = false,
    ExamStatus? selectedExamStatus,
    bool clearExamStatus = false,
    DateTime? dateFrom,
    DateTime? dateTo,
    bool clearDates = false,
    int? draftPage,
    int? examPage,
    int? limit,
    int? draftTotalPages,
    int? examTotalPages,
    int? selectedTabIndex,
  }) {
    return ExamGeneratorState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isMutating: isMutating ?? this.isMutating,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      actionMessage: clearAction ? null : actionMessage ?? this.actionMessage,
      shortages: clearShortages ? const [] : shortages ?? this.shortages,
      teachingCourses: teachingCourses ?? this.teachingCourses,
      drafts: drafts ?? this.drafts,
      exams: exams ?? this.exams,
      stats: stats ?? this.stats,
      readiness: readiness ?? this.readiness,
      selectedCourseId: clearCourse
          ? null
          : selectedCourseId ?? this.selectedCourseId,
      selectedDraftStatus: clearDraftStatus
          ? null
          : selectedDraftStatus ?? this.selectedDraftStatus,
      selectedExamStatus: clearExamStatus
          ? null
          : selectedExamStatus ?? this.selectedExamStatus,
      dateFrom: clearDates ? null : dateFrom ?? this.dateFrom,
      dateTo: clearDates ? null : dateTo ?? this.dateTo,
      draftPage: draftPage ?? this.draftPage,
      examPage: examPage ?? this.examPage,
      limit: limit ?? this.limit,
      draftTotalPages: draftTotalPages ?? this.draftTotalPages,
      examTotalPages: examTotalPages ?? this.examTotalPages,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isLoadingMore,
    isMutating,
    errorMessage,
    actionMessage,
    shortages,
    teachingCourses,
    drafts,
    exams,
    stats,
    readiness,
    selectedCourseId,
    selectedDraftStatus,
    selectedExamStatus,
    dateFrom,
    dateTo,
    draftPage,
    examPage,
    limit,
    draftTotalPages,
    examTotalPages,
    selectedTabIndex,
  ];
}
