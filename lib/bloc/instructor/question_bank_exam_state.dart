import 'package:equatable/equatable.dart';

import '../../models/core/paginated_response.dart';
import '../../models/instructor/question_bank_exam_models.dart';
import '../../models/instructor/teaching_course_model.dart';

class QuestionBankExamState extends Equatable {
  const QuestionBankExamState({
    this.isLoading = false,
    this.isMutating = false,
    this.errorMessage,
    this.successMessage,
    this.teachingCourses = const <TeachingCourseModel>[],
    this.selectedCourseId,
    this.chapters = const <CourseChapterModel>[],
    this.questions,
    this.groups,
    this.exams,
    this.drafts,
    this.selectedQuestion,
    this.selectedGroup,
    this.selectedGroupQuestions = const <QuestionBankQuestionModel>[],
    this.generationShortages = const <String>[],
    this.selectedDraft,
    this.selectedExam,
    this.questionStatusFilter,
    this.questionTypeFilter,
    this.difficultyFilter,
    this.bloomFilter,
    this.examStatusFilter,
    this.searchQuery = '',
    this.hasAttachmentsFilter,
    this.currentQuestionsPage = 1,
    this.currentGroupsPage = 1,
    this.currentExamsPage = 1,
    this.currentDraftsPage = 1,
  });

  final bool isLoading;
  final bool isMutating;
  final String? errorMessage;
  final String? successMessage;
  final List<TeachingCourseModel> teachingCourses;
  final int? selectedCourseId;
  final List<CourseChapterModel> chapters;
  final PaginatedResponse<QuestionBankQuestionModel>? questions;
  final PaginatedResponse<QuestionBankGroupModel>? groups;
  final PaginatedResponse<ExamResponseModel>? exams;
  final PaginatedResponse<ExamDraftModel>? drafts;
  final QuestionBankQuestionModel? selectedQuestion;
  final QuestionBankGroupModel? selectedGroup;
  final List<QuestionBankQuestionModel> selectedGroupQuestions;
  final List<String> generationShortages;
  final ExamDraftModel? selectedDraft;
  final ExamResponseModel? selectedExam;
  final QuestionBankStatus? questionStatusFilter;
  final QuestionBankQuestionType? questionTypeFilter;
  final QuestionBankDifficulty? difficultyFilter;
  final QuestionBankBloomLevel? bloomFilter;
  final ExamStatus? examStatusFilter;
  final String searchQuery;
  final bool? hasAttachmentsFilter;
  final int currentQuestionsPage;
  final int currentGroupsPage;
  final int currentExamsPage;
  final int currentDraftsPage;

  List<QuestionBankQuestionModel> get questionItems {
    return questions?.data ?? const <QuestionBankQuestionModel>[];
  }

  List<QuestionBankGroupModel> get groupItems {
    return groups?.data ?? const <QuestionBankGroupModel>[];
  }

  List<ExamResponseModel> get examItems {
    return exams?.data ?? const <ExamResponseModel>[];
  }

  List<ExamDraftModel> get draftItems {
    return drafts?.data ?? const <ExamDraftModel>[];
  }

  int get approvedQuestionCount {
    return questionItems
        .where((item) => item.status == QuestionBankStatus.approved)
        .length;
  }

  int get draftQuestionCount {
    return questionItems
        .where((item) => item.status == QuestionBankStatus.draft)
        .length;
  }

  int get openDraftCount {
    return draftItems
        .where((item) => item.status == ExamDraftStatus.open)
        .length;
  }

  QuestionBankExamState copyWith({
    bool? isLoading,
    bool? isMutating,
    String? errorMessage,
    String? successMessage,
    List<TeachingCourseModel>? teachingCourses,
    int? selectedCourseId,
    List<CourseChapterModel>? chapters,
    PaginatedResponse<QuestionBankQuestionModel>? questions,
    PaginatedResponse<QuestionBankGroupModel>? groups,
    PaginatedResponse<ExamResponseModel>? exams,
    PaginatedResponse<ExamDraftModel>? drafts,
    QuestionBankQuestionModel? selectedQuestion,
    QuestionBankGroupModel? selectedGroup,
    List<QuestionBankQuestionModel>? selectedGroupQuestions,
    List<String>? generationShortages,
    ExamDraftModel? selectedDraft,
    ExamResponseModel? selectedExam,
    QuestionBankStatus? questionStatusFilter,
    QuestionBankQuestionType? questionTypeFilter,
    QuestionBankDifficulty? difficultyFilter,
    QuestionBankBloomLevel? bloomFilter,
    ExamStatus? examStatusFilter,
    String? searchQuery,
    bool? hasAttachmentsFilter,
    int? currentQuestionsPage,
    int? currentGroupsPage,
    int? currentExamsPage,
    int? currentDraftsPage,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearSelectedCourse = false,
    bool clearQuestions = false,
    bool clearGroups = false,
    bool clearExams = false,
    bool clearDrafts = false,
    bool clearSelectedQuestion = false,
    bool clearSelectedGroup = false,
    bool clearSelectedGroupQuestions = false,
    bool clearGenerationShortages = false,
    bool clearSelectedDraft = false,
    bool clearSelectedExam = false,
    bool clearQuestionStatusFilter = false,
    bool clearQuestionTypeFilter = false,
    bool clearDifficultyFilter = false,
    bool clearBloomFilter = false,
    bool clearExamStatusFilter = false,
    bool clearHasAttachmentsFilter = false,
  }) {
    return QuestionBankExamState(
      isLoading: isLoading ?? this.isLoading,
      isMutating: isMutating ?? this.isMutating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
      teachingCourses: teachingCourses ?? this.teachingCourses,
      selectedCourseId: clearSelectedCourse
          ? null
          : (selectedCourseId ?? this.selectedCourseId),
      chapters: chapters ?? this.chapters,
      questions: clearQuestions ? null : (questions ?? this.questions),
      groups: clearGroups ? null : (groups ?? this.groups),
      exams: clearExams ? null : (exams ?? this.exams),
      drafts: clearDrafts ? null : (drafts ?? this.drafts),
      selectedQuestion: clearSelectedQuestion
          ? null
          : (selectedQuestion ?? this.selectedQuestion),
      selectedGroup: clearSelectedGroup
          ? null
          : (selectedGroup ?? this.selectedGroup),
      selectedGroupQuestions: clearSelectedGroupQuestions
          ? const <QuestionBankQuestionModel>[]
          : (selectedGroupQuestions ?? this.selectedGroupQuestions),
      generationShortages: clearGenerationShortages
          ? const <String>[]
          : (generationShortages ?? this.generationShortages),
      selectedDraft: clearSelectedDraft
          ? null
          : (selectedDraft ?? this.selectedDraft),
      selectedExam: clearSelectedExam
          ? null
          : (selectedExam ?? this.selectedExam),
      questionStatusFilter: clearQuestionStatusFilter
          ? null
          : (questionStatusFilter ?? this.questionStatusFilter),
      questionTypeFilter: clearQuestionTypeFilter
          ? null
          : (questionTypeFilter ?? this.questionTypeFilter),
      difficultyFilter: clearDifficultyFilter
          ? null
          : (difficultyFilter ?? this.difficultyFilter),
      bloomFilter: clearBloomFilter ? null : (bloomFilter ?? this.bloomFilter),
      examStatusFilter: clearExamStatusFilter
          ? null
          : (examStatusFilter ?? this.examStatusFilter),
      searchQuery: searchQuery ?? this.searchQuery,
      hasAttachmentsFilter: clearHasAttachmentsFilter
          ? null
          : (hasAttachmentsFilter ?? this.hasAttachmentsFilter),
      currentQuestionsPage: currentQuestionsPage ?? this.currentQuestionsPage,
      currentGroupsPage: currentGroupsPage ?? this.currentGroupsPage,
      currentExamsPage: currentExamsPage ?? this.currentExamsPage,
      currentDraftsPage: currentDraftsPage ?? this.currentDraftsPage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    isLoading,
    isMutating,
    errorMessage,
    successMessage,
    teachingCourses,
    selectedCourseId,
    chapters,
    questions,
    groups,
    exams,
    drafts,
    selectedQuestion,
    selectedGroup,
    selectedGroupQuestions,
    generationShortages,
    selectedDraft,
    selectedExam,
    questionStatusFilter,
    questionTypeFilter,
    difficultyFilter,
    bloomFilter,
    examStatusFilter,
    searchQuery,
    hasAttachmentsFilter,
    currentQuestionsPage,
    currentGroupsPage,
    currentExamsPage,
    currentDraftsPage,
  ];
}
