import 'question_bank_enums.dart';
import 'question_bank_fill_blank_model.dart';
import 'question_bank_form_payload.dart';
import 'question_bank_option_model.dart';
import 'question_attachment_payload.dart';

class QuestionBulkRowModel {
  const QuestionBulkRowModel({
    required this.localId,
    this.chapterId,
    this.questionType = QuestionBankType.mcq,
    this.difficulty = QuestionBankDifficulty.medium,
    this.bloomLevel = BloomLevel.understanding,
    this.questionText = '',
    this.questionFileId,
    this.questionImageUrl,
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
    this.error,
  });

  final int localId;
  final int? chapterId;
  final QuestionBankType questionType;
  final QuestionBankDifficulty difficulty;
  final BloomLevel bloomLevel;
  final String questionText;
  final int? questionFileId;
  final String? questionImageUrl;
  final String questionFileCaption;
  final String questionFileAltText;
  final String expectedAnswerText;
  final String hints;
  final List<QuestionBankOptionModel> options;
  final List<QuestionBankFillBlankModel> fillBlanks;
  final List<QuestionAttachmentPayload> attachments;
  final String? error;

  QuestionBulkRowModel copyWith({
    int? chapterId,
    bool clearChapter = false,
    QuestionBankType? questionType,
    QuestionBankDifficulty? difficulty,
    BloomLevel? bloomLevel,
    String? questionText,
    int? questionFileId,
    String? questionImageUrl,
    bool clearQuestionFile = false,
    String? questionFileCaption,
    String? questionFileAltText,
    String? expectedAnswerText,
    String? hints,
    List<QuestionBankOptionModel>? options,
    List<QuestionBankFillBlankModel>? fillBlanks,
    List<QuestionAttachmentPayload>? attachments,
    String? error,
    bool clearError = false,
  }) {
    return QuestionBulkRowModel(
      localId: localId,
      chapterId: clearChapter ? null : chapterId ?? this.chapterId,
      questionType: questionType ?? this.questionType,
      difficulty: difficulty ?? this.difficulty,
      bloomLevel: bloomLevel ?? this.bloomLevel,
      questionText: questionText ?? this.questionText,
      questionFileId: clearQuestionFile
          ? null
          : questionFileId ?? this.questionFileId,
      questionImageUrl: clearQuestionFile
          ? null
          : questionImageUrl ?? this.questionImageUrl,
      questionFileCaption: questionFileCaption ?? this.questionFileCaption,
      questionFileAltText: questionFileAltText ?? this.questionFileAltText,
      expectedAnswerText: expectedAnswerText ?? this.expectedAnswerText,
      hints: hints ?? this.hints,
      options: options ?? this.options,
      fillBlanks: fillBlanks ?? this.fillBlanks,
      attachments: attachments ?? this.attachments,
      error: clearError ? null : error ?? this.error,
    );
  }

  QuestionBankFormPayload toPayload({
    required int courseId,
    int? defaultChapterId,
  }) {
    return QuestionBankFormPayload(
      courseId: courseId,
      chapterId: chapterId ?? defaultChapterId,
      questionType: questionType,
      difficulty: difficulty,
      bloomLevel: bloomLevel,
      questionText: questionText,
      questionFileId: questionFileId,
      questionFileCaption: questionFileCaption,
      questionFileAltText: questionFileAltText,
      expectedAnswerText: expectedAnswerText,
      hints: hints,
      options: options,
      fillBlanks: fillBlanks,
      attachments: attachments,
    );
  }
}
