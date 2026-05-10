import 'package:equatable/equatable.dart';

import '../../../models/exams/exam_draft_model.dart';
import '../../../models/exams/exam_draft_validation_model.dart';
import '../../../models/exams/exam_response_model.dart';
import '../../../models/question_bank/course_chapter_model.dart';
import '../../../models/question_bank/question_bank_enums.dart';
import '../../../models/question_bank/question_bank_group_model.dart';
import '../../../models/question_bank/question_bank_question_model.dart';

class ExamDraftEditorState extends Equatable {
  const ExamDraftEditorState({
    this.isLoading = false,
    this.isMutating = false,
    this.activeMutationAction,
    this.errorMessage,
    this.actionMessage,
    this.draft,
    this.savedExam,
    this.validation,
    this.candidateQuestions = const <QuestionBankQuestionModel>[],
    this.candidateChapters = const <CourseChapterModel>[],
    this.candidateGroups = const <QuestionBankGroupModel>[],
    this.candidateChapterId,
    this.candidateGroupId,
    this.candidateQuestionType,
    this.candidateDifficulty,
    this.candidateBloomLevel,
    this.candidateSearch,
    this.candidatePage = 1,
    this.candidateHasMore = false,
    this.isLoadingCandidates = false,
  });

  final bool isLoading;
  final bool isMutating;
  final String? activeMutationAction;
  final String? errorMessage;
  final String? actionMessage;
  final ExamDraftModel? draft;
  final ExamResponseModel? savedExam;
  final ExamDraftValidationModel? validation;
  final List<QuestionBankQuestionModel> candidateQuestions;
  final List<CourseChapterModel> candidateChapters;
  final List<QuestionBankGroupModel> candidateGroups;
  final int? candidateChapterId;
  final int? candidateGroupId;
  final QuestionBankType? candidateQuestionType;
  final QuestionBankDifficulty? candidateDifficulty;
  final BloomLevel? candidateBloomLevel;
  final String? candidateSearch;
  final int candidatePage;
  final bool candidateHasMore;
  final bool isLoadingCandidates;

  bool get canEdit => draft?.isEditable ?? false;

  ExamDraftEditorState copyWith({
    bool? isLoading,
    bool? isMutating,
    String? activeMutationAction,
    String? errorMessage,
    String? actionMessage,
    bool clearError = false,
    bool clearAction = false,
    bool clearMutationAction = false,
    ExamDraftModel? draft,
    ExamResponseModel? savedExam,
    ExamDraftValidationModel? validation,
    List<QuestionBankQuestionModel>? candidateQuestions,
    List<CourseChapterModel>? candidateChapters,
    List<QuestionBankGroupModel>? candidateGroups,
    int? candidateChapterId,
    int? candidateGroupId,
    QuestionBankType? candidateQuestionType,
    QuestionBankDifficulty? candidateDifficulty,
    BloomLevel? candidateBloomLevel,
    String? candidateSearch,
    int? candidatePage,
    bool? candidateHasMore,
    bool? isLoadingCandidates,
    bool clearCandidateChapter = false,
    bool clearCandidateGroup = false,
    bool clearCandidateType = false,
    bool clearCandidateDifficulty = false,
    bool clearCandidateBloom = false,
    bool clearCandidateSearch = false,
  }) {
    return ExamDraftEditorState(
      isLoading: isLoading ?? this.isLoading,
      isMutating: isMutating ?? this.isMutating,
      activeMutationAction: clearMutationAction
          ? null
          : activeMutationAction ?? this.activeMutationAction,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      actionMessage: clearAction ? null : actionMessage ?? this.actionMessage,
      draft: draft ?? this.draft,
      savedExam: savedExam ?? this.savedExam,
      validation: validation ?? this.validation,
      candidateQuestions: candidateQuestions ?? this.candidateQuestions,
      candidateChapters: candidateChapters ?? this.candidateChapters,
      candidateGroups: candidateGroups ?? this.candidateGroups,
      candidateChapterId: clearCandidateChapter
          ? null
          : candidateChapterId ?? this.candidateChapterId,
      candidateGroupId: clearCandidateGroup
          ? null
          : candidateGroupId ?? this.candidateGroupId,
      candidateQuestionType: clearCandidateType
          ? null
          : candidateQuestionType ?? this.candidateQuestionType,
      candidateDifficulty: clearCandidateDifficulty
          ? null
          : candidateDifficulty ?? this.candidateDifficulty,
      candidateBloomLevel: clearCandidateBloom
          ? null
          : candidateBloomLevel ?? this.candidateBloomLevel,
      candidateSearch: clearCandidateSearch
          ? null
          : candidateSearch ?? this.candidateSearch,
      candidatePage: candidatePage ?? this.candidatePage,
      candidateHasMore: candidateHasMore ?? this.candidateHasMore,
      isLoadingCandidates: isLoadingCandidates ?? this.isLoadingCandidates,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isMutating,
    activeMutationAction,
    errorMessage,
    actionMessage,
    draft,
    savedExam,
    validation,
    candidateQuestions,
    candidateChapters,
    candidateGroups,
    candidateChapterId,
    candidateGroupId,
    candidateQuestionType,
    candidateDifficulty,
    candidateBloomLevel,
    candidateSearch,
    candidatePage,
    candidateHasMore,
    isLoadingCandidates,
  ];
}
