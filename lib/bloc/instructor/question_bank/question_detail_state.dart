import 'package:equatable/equatable.dart';

import '../../../models/question_bank/question_bank_question_model.dart';

class QuestionDetailState extends Equatable {
  const QuestionDetailState({
    this.isLoading = false,
    this.isMutating = false,
    this.question,
    this.courseLabel,
    this.chapterLabel,
    this.errorMessage,
    this.actionMessage,
  });

  final bool isLoading;
  final bool isMutating;
  final QuestionBankQuestionModel? question;
  final String? courseLabel;
  final String? chapterLabel;
  final String? errorMessage;
  final String? actionMessage;

  QuestionDetailState copyWith({
    bool? isLoading,
    bool? isMutating,
    QuestionBankQuestionModel? question,
    String? courseLabel,
    String? chapterLabel,
    String? errorMessage,
    String? actionMessage,
    bool clearError = false,
    bool clearAction = false,
  }) {
    return QuestionDetailState(
      isLoading: isLoading ?? this.isLoading,
      isMutating: isMutating ?? this.isMutating,
      question: question ?? this.question,
      courseLabel: courseLabel ?? this.courseLabel,
      chapterLabel: chapterLabel ?? this.chapterLabel,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      actionMessage: clearAction ? null : actionMessage ?? this.actionMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isMutating,
    question,
    courseLabel,
    chapterLabel,
    errorMessage,
    actionMessage,
  ];
}
