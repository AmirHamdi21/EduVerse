import 'package:equatable/equatable.dart';

import '../../../models/exams/exam_draft_model.dart';
import '../../../models/exams/exam_generation_readiness_model.dart';
import '../../../models/exams/exam_generator_enums.dart';
import '../../../models/exams/exam_response_model.dart';
import '../../../models/exams/exam_shortage_model.dart';
import '../../../models/exams/exam_stats_model.dart';
import '../../../models/instructor/teaching_course_model.dart';

enum ExamGeneratorListKind { all, drafts, saved }

class ExamGeneratorState extends Equatable {
  const ExamGeneratorState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.isPoolLoading = false,
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
    this.selectedListKind = ExamGeneratorListKind.all,
    this.search = '',
    this.dateFrom,
    this.dateTo,
    this.draftPage = 1,
    this.examPage = 1,
    this.limit = 20,
    this.draftTotalPages = 1,
    this.examTotalPages = 1,
  });

  final bool isLoading;
  final bool isRefreshing;
  final bool isPoolLoading;
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
  final ExamGeneratorListKind selectedListKind;
  final String search;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final int draftPage;
  final int examPage;
  final int limit;
  final int draftTotalPages;
  final int examTotalPages;

  bool get hasMoreDrafts => draftPage < draftTotalPages;
  bool get hasMoreExams => examPage < examTotalPages;

  ExamGeneratorState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    bool? isPoolLoading,
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
    bool clearStats = false,
    ExamGenerationReadinessModel? readiness,
    bool clearReadiness = false,
    int? selectedCourseId,
    bool clearCourse = false,
    ExamDraftStatus? selectedDraftStatus,
    bool clearDraftStatus = false,
    ExamStatus? selectedExamStatus,
    bool clearExamStatus = false,
    ExamGeneratorListKind? selectedListKind,
    String? search,
    bool clearSearch = false,
    DateTime? dateFrom,
    DateTime? dateTo,
    bool clearDates = false,
    int? draftPage,
    int? examPage,
    int? limit,
    int? draftTotalPages,
    int? examTotalPages,
  }) {
    return ExamGeneratorState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isPoolLoading: isPoolLoading ?? this.isPoolLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isMutating: isMutating ?? this.isMutating,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      actionMessage: clearAction ? null : actionMessage ?? this.actionMessage,
      shortages: clearShortages ? const [] : shortages ?? this.shortages,
      teachingCourses: teachingCourses ?? this.teachingCourses,
      drafts: drafts ?? this.drafts,
      exams: exams ?? this.exams,
      stats: clearStats ? null : stats ?? this.stats,
      readiness: clearReadiness ? null : readiness ?? this.readiness,
      selectedCourseId: clearCourse
          ? null
          : selectedCourseId ?? this.selectedCourseId,
      selectedDraftStatus: clearDraftStatus
          ? null
          : selectedDraftStatus ?? this.selectedDraftStatus,
      selectedExamStatus: clearExamStatus
          ? null
          : selectedExamStatus ?? this.selectedExamStatus,
      selectedListKind: selectedListKind ?? this.selectedListKind,
      search: clearSearch ? '' : search ?? this.search,
      dateFrom: clearDates ? null : dateFrom ?? this.dateFrom,
      dateTo: clearDates ? null : dateTo ?? this.dateTo,
      draftPage: draftPage ?? this.draftPage,
      examPage: examPage ?? this.examPage,
      limit: limit ?? this.limit,
      draftTotalPages: draftTotalPages ?? this.draftTotalPages,
      examTotalPages: examTotalPages ?? this.examTotalPages,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isRefreshing,
    isPoolLoading,
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
    selectedListKind,
    search,
    dateFrom,
    dateTo,
    draftPage,
    examPage,
    limit,
    draftTotalPages,
    examTotalPages,
  ];
}
