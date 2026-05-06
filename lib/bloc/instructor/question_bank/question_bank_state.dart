import 'package:equatable/equatable.dart';

import '../../../models/instructor/teaching_course_model.dart';
import '../../../models/question_bank/course_chapter_model.dart';
import '../../../models/question_bank/question_bank_enums.dart';
import '../../../models/question_bank/question_bank_group_model.dart';
import '../../../models/question_bank/question_bank_question_model.dart';
import '../../../models/question_bank/question_bank_stats_model.dart';

class QuestionBankState extends Equatable {
  const QuestionBankState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isMutating = false,
    this.errorMessage,
    this.actionMessage,
    this.teachingCourses = const <TeachingCourseModel>[],
    this.chapters = const <CourseChapterModel>[],
    this.questions = const <QuestionBankQuestionModel>[],
    this.groups = const <QuestionBankGroupModel>[],
    this.selectedCourseId,
    this.selectedChapterId,
    this.selectedType,
    this.selectedDifficulty,
    this.selectedBloomLevel,
    this.selectedStatus,
    this.hasAttachments,
    this.selectedGroupId,
    this.search = '',
    this.page = 1,
    this.limit = 20,
    this.total = 0,
    this.stats = const QuestionBankStatsModel(),
    this.chapterQuestionCounts = const <int, int>{},
    this.selectedQuestionIds = const <int>{},
    this.isSelectionMode = false,
  });

  final bool isLoading;
  final bool isLoadingMore;
  final bool isMutating;
  final String? errorMessage;
  final String? actionMessage;
  final List<TeachingCourseModel> teachingCourses;
  final List<CourseChapterModel> chapters;
  final List<QuestionBankQuestionModel> questions;
  final List<QuestionBankGroupModel> groups;
  final int? selectedCourseId;
  final int? selectedChapterId;
  final QuestionBankType? selectedType;
  final QuestionBankDifficulty? selectedDifficulty;
  final BloomLevel? selectedBloomLevel;
  final QuestionBankStatus? selectedStatus;
  final bool? hasAttachments;
  final int? selectedGroupId;
  final String search;
  final int page;
  final int limit;
  final int total;
  final QuestionBankStatsModel stats;
  final Map<int, int> chapterQuestionCounts;
  final Set<int> selectedQuestionIds;
  final bool isSelectionMode;

  bool get hasMore => page * limit < total;
  int get approvedCount => stats.approved;
  int get draftCount => stats.draft;
  int get underReviewCount => stats.underReview;
  int get rejectedCount => stats.rejected;
  int get archivedCount => stats.archived;
  int get attachedOrGroupedCount => stats.attachedOrGrouped;
  bool get hasSelectedQuestions => selectedQuestionIds.isNotEmpty;

  QuestionBankState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    bool? isMutating,
    String? errorMessage,
    String? actionMessage,
    bool clearError = false,
    bool clearAction = false,
    List<TeachingCourseModel>? teachingCourses,
    List<CourseChapterModel>? chapters,
    List<QuestionBankQuestionModel>? questions,
    List<QuestionBankGroupModel>? groups,
    int? selectedCourseId,
    bool clearSelectedCourse = false,
    int? selectedChapterId,
    bool clearSelectedChapter = false,
    QuestionBankType? selectedType,
    bool clearType = false,
    QuestionBankDifficulty? selectedDifficulty,
    bool clearDifficulty = false,
    BloomLevel? selectedBloomLevel,
    bool clearBloom = false,
    QuestionBankStatus? selectedStatus,
    bool clearStatus = false,
    bool? hasAttachments,
    bool clearHasAttachments = false,
    int? selectedGroupId,
    bool clearGroup = false,
    String? search,
    int? page,
    int? limit,
    int? total,
    QuestionBankStatsModel? stats,
    Map<int, int>? chapterQuestionCounts,
    Set<int>? selectedQuestionIds,
    bool? isSelectionMode,
    bool clearSelectedQuestionIds = false,
  }) {
    return QuestionBankState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isMutating: isMutating ?? this.isMutating,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      actionMessage: clearAction ? null : actionMessage ?? this.actionMessage,
      teachingCourses: teachingCourses ?? this.teachingCourses,
      chapters: chapters ?? this.chapters,
      questions: questions ?? this.questions,
      groups: groups ?? this.groups,
      selectedCourseId: clearSelectedCourse
          ? null
          : selectedCourseId ?? this.selectedCourseId,
      selectedChapterId: clearSelectedChapter
          ? null
          : selectedChapterId ?? this.selectedChapterId,
      selectedType: clearType ? null : selectedType ?? this.selectedType,
      selectedDifficulty: clearDifficulty
          ? null
          : selectedDifficulty ?? this.selectedDifficulty,
      selectedBloomLevel: clearBloom
          ? null
          : selectedBloomLevel ?? this.selectedBloomLevel,
      selectedStatus: clearStatus
          ? null
          : selectedStatus ?? this.selectedStatus,
      hasAttachments: clearHasAttachments
          ? null
          : hasAttachments ?? this.hasAttachments,
      selectedGroupId: clearGroup
          ? null
          : selectedGroupId ?? this.selectedGroupId,
      search: search ?? this.search,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      total: total ?? this.total,
      stats: stats ?? this.stats,
      chapterQuestionCounts:
          chapterQuestionCounts ?? this.chapterQuestionCounts,
      selectedQuestionIds: clearSelectedQuestionIds
          ? const <int>{}
          : selectedQuestionIds ?? this.selectedQuestionIds,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isLoadingMore,
    isMutating,
    errorMessage,
    actionMessage,
    teachingCourses,
    chapters,
    questions,
    groups,
    selectedCourseId,
    selectedChapterId,
    selectedType,
    selectedDifficulty,
    selectedBloomLevel,
    selectedStatus,
    hasAttachments,
    selectedGroupId,
    search,
    page,
    limit,
    total,
    stats,
    chapterQuestionCounts,
    selectedQuestionIds,
    isSelectionMode,
  ];
}
