import 'package:equatable/equatable.dart';

import '../../../models/question_bank/course_chapter_model.dart';
import '../../../models/question_bank/question_bank_group_model.dart';
import '../../../models/question_bank/question_bank_question_model.dart';

class QuestionGroupState extends Equatable {
  const QuestionGroupState({
    this.isLoading = false,
    this.isMutating = false,
    this.group,
    this.chapters = const <CourseChapterModel>[],
    this.questions = const <QuestionBankQuestionModel>[],
    this.createdQuestions = const <QuestionBankQuestionModel>[],
    this.errorMessage,
    this.actionMessage,
  });

  final bool isLoading;
  final bool isMutating;
  final QuestionBankGroupModel? group;
  final List<CourseChapterModel> chapters;
  final List<QuestionBankQuestionModel> questions;
  final List<QuestionBankQuestionModel> createdQuestions;
  final String? errorMessage;
  final String? actionMessage;

  QuestionGroupState copyWith({
    bool? isLoading,
    bool? isMutating,
    QuestionBankGroupModel? group,
    List<CourseChapterModel>? chapters,
    List<QuestionBankQuestionModel>? questions,
    List<QuestionBankQuestionModel>? createdQuestions,
    bool clearCreatedQuestions = false,
    String? errorMessage,
    String? actionMessage,
    bool clearError = false,
    bool clearAction = false,
  }) {
    return QuestionGroupState(
      isLoading: isLoading ?? this.isLoading,
      isMutating: isMutating ?? this.isMutating,
      group: group ?? this.group,
      chapters: chapters ?? this.chapters,
      questions: questions ?? this.questions,
      createdQuestions: clearCreatedQuestions
          ? const <QuestionBankQuestionModel>[]
          : createdQuestions ?? this.createdQuestions,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      actionMessage: clearAction ? null : actionMessage ?? this.actionMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isMutating,
    group,
    chapters,
    questions,
    createdQuestions,
    errorMessage,
    actionMessage,
  ];
}
