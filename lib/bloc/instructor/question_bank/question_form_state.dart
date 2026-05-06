import 'package:equatable/equatable.dart';

import '../../../models/question_bank/course_chapter_model.dart';
import '../../../models/question_bank/question_attachment_payload.dart';
import '../../../models/question_bank/question_bank_enums.dart';
import '../../../models/question_bank/question_bank_fill_blank_model.dart';
import '../../../models/question_bank/question_bank_option_model.dart';
import '../../../models/question_bank/question_bank_question_model.dart';

class QuestionFormState extends Equatable {
  const QuestionFormState({
    this.isLoading = false,
    this.isSaving = false,
    this.isUploading = false,
    this.errorMessage,
    this.successMessage,
    this.originalQuestion,
    this.savedQuestion,
    this.chapters = const <CourseChapterModel>[],
    this.courseId,
    this.chapterId,
    this.questionType = QuestionBankType.mcq,
    this.difficulty = QuestionBankDifficulty.medium,
    this.bloomLevel = BloomLevel.understanding,
    this.questionText = '',
    this.questionFileId,
    this.questionFileCaption = '',
    this.questionFileAltText = '',
    this.expectedAnswerText = '',
    this.hints = '',
    this.options = const <QuestionBankOptionModel>[
      QuestionBankOptionModel(optionText: '', isCorrect: true),
      QuestionBankOptionModel(optionText: '', isCorrect: false),
    ],
    this.fillBlanks = const <QuestionBankFillBlankModel>[],
    this.attachments = const <QuestionAttachmentPayload>[],
    this.validationError,
  });

  final bool isLoading;
  final bool isSaving;
  final bool isUploading;
  final String? errorMessage;
  final String? successMessage;
  final QuestionBankQuestionModel? originalQuestion;
  final QuestionBankQuestionModel? savedQuestion;
  final List<CourseChapterModel> chapters;
  final int? courseId;
  final int? chapterId;
  final QuestionBankType questionType;
  final QuestionBankDifficulty difficulty;
  final BloomLevel bloomLevel;
  final String questionText;
  final int? questionFileId;
  final String questionFileCaption;
  final String questionFileAltText;
  final String expectedAnswerText;
  final String hints;
  final List<QuestionBankOptionModel> options;
  final List<QuestionBankFillBlankModel> fillBlanks;
  final List<QuestionAttachmentPayload> attachments;
  final String? validationError;

  QuestionFormState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? isUploading,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    QuestionBankQuestionModel? originalQuestion,
    QuestionBankQuestionModel? savedQuestion,
    List<CourseChapterModel>? chapters,
    int? courseId,
    bool clearCourse = false,
    int? chapterId,
    bool clearChapter = false,
    QuestionBankType? questionType,
    QuestionBankDifficulty? difficulty,
    BloomLevel? bloomLevel,
    String? questionText,
    int? questionFileId,
    bool clearQuestionFile = false,
    String? questionFileCaption,
    String? questionFileAltText,
    String? expectedAnswerText,
    String? hints,
    List<QuestionBankOptionModel>? options,
    List<QuestionBankFillBlankModel>? fillBlanks,
    List<QuestionAttachmentPayload>? attachments,
    String? validationError,
    bool clearValidation = false,
  }) {
    return QuestionFormState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isUploading: isUploading ?? this.isUploading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage: clearSuccess
          ? null
          : successMessage ?? this.successMessage,
      originalQuestion: originalQuestion ?? this.originalQuestion,
      savedQuestion: savedQuestion ?? this.savedQuestion,
      chapters: chapters ?? this.chapters,
      courseId: clearCourse ? null : courseId ?? this.courseId,
      chapterId: clearChapter ? null : chapterId ?? this.chapterId,
      questionType: questionType ?? this.questionType,
      difficulty: difficulty ?? this.difficulty,
      bloomLevel: bloomLevel ?? this.bloomLevel,
      questionText: questionText ?? this.questionText,
      questionFileId: clearQuestionFile
          ? null
          : questionFileId ?? this.questionFileId,
      questionFileCaption: questionFileCaption ?? this.questionFileCaption,
      questionFileAltText: questionFileAltText ?? this.questionFileAltText,
      expectedAnswerText: expectedAnswerText ?? this.expectedAnswerText,
      hints: hints ?? this.hints,
      options: options ?? this.options,
      fillBlanks: fillBlanks ?? this.fillBlanks,
      attachments: attachments ?? this.attachments,
      validationError: clearValidation
          ? null
          : validationError ?? this.validationError,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isSaving,
    isUploading,
    errorMessage,
    successMessage,
    originalQuestion,
    savedQuestion,
    chapters,
    courseId,
    chapterId,
    questionType,
    difficulty,
    bloomLevel,
    questionText,
    questionFileId,
    questionFileCaption,
    questionFileAltText,
    expectedAnswerText,
    hints,
    options,
    fillBlanks,
    attachments,
    validationError,
  ];
}
