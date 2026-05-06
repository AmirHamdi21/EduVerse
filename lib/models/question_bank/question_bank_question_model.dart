import 'question_bank_attachment_model.dart';
import 'question_bank_enums.dart';
import 'question_bank_fill_blank_model.dart';
import 'question_bank_group_model.dart';
import 'question_bank_option_model.dart';

class QuestionBankQuestionModel {
  const QuestionBankQuestionModel({
    required this.id,
    required this.questionId,
    required this.courseId,
    required this.chapterId,
    required this.questionType,
    required this.difficulty,
    required this.bloomLevel,
    required this.status,
    this.questionText,
    this.questionFileId,
    this.questionImageUrl,
    this.questionFileCaption,
    this.questionFileAltText,
    this.expectedAnswerText,
    this.hints,
    this.options = const <QuestionBankOptionModel>[],
    this.fillBlanks = const <QuestionBankFillBlankModel>[],
    this.attachments = const <QuestionBankAttachmentModel>[],
    this.groups = const <QuestionBankGroupSummaryModel>[],
  });

  final int id;
  final int questionId;
  final int courseId;
  final int chapterId;
  final QuestionBankType questionType;
  final QuestionBankDifficulty difficulty;
  final BloomLevel bloomLevel;
  final QuestionBankStatus status;
  final String? questionText;
  final int? questionFileId;
  final String? questionImageUrl;
  final String? questionFileCaption;
  final String? questionFileAltText;
  final String? expectedAnswerText;
  final String? hints;
  final List<QuestionBankOptionModel> options;
  final List<QuestionBankFillBlankModel> fillBlanks;
  final List<QuestionBankAttachmentModel> attachments;
  final List<QuestionBankGroupSummaryModel> groups;

  bool get hasAttachments => attachments.isNotEmpty;
  bool get isGrouped => groups.isNotEmpty;

  factory QuestionBankQuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionBankQuestionModel(
      id: _toInt(json['id'] ?? json['questionId']),
      questionId: _toInt(json['questionId'] ?? json['id']),
      courseId: _toInt(json['courseId']),
      chapterId: _toInt(json['chapterId']),
      questionType: QuestionBankType.fromJson(json['questionType']),
      difficulty: QuestionBankDifficulty.fromJson(json['difficulty']),
      bloomLevel: BloomLevel.fromJson(json['bloomLevel']),
      status: QuestionBankStatus.fromJson(json['status']),
      questionText: _nullableString(json['questionText']),
      questionFileId: _nullableInt(json['questionFileId']),
      questionImageUrl: _nullableString(json['questionImageUrl']),
      questionFileCaption: _nullableString(json['questionFileCaption']),
      questionFileAltText: _nullableString(json['questionFileAltText']),
      expectedAnswerText: _nullableString(json['expectedAnswerText']),
      hints: _nullableString(json['hints']),
      options: _asList(json['options'])
          .whereType<Map<String, dynamic>>()
          .map(QuestionBankOptionModel.fromJson)
          .toList(),
      fillBlanks: _asList(json['fillBlanks'])
          .whereType<Map<String, dynamic>>()
          .map(QuestionBankFillBlankModel.fromJson)
          .toList(),
      attachments: _asList(json['attachments'])
          .whereType<Map<String, dynamic>>()
          .map(QuestionBankAttachmentModel.fromJson)
          .toList(),
      groups: _asList(json['groups'])
          .whereType<Map<String, dynamic>>()
          .map(QuestionBankGroupSummaryModel.fromJson)
          .toList(),
    );
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int? _nullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

String? _nullableString(dynamic value) {
  final text = value?.toString();
  return text == null || text.isEmpty ? null : text;
}

List<dynamic> _asList(dynamic value) {
  return value is List ? value : const <dynamic>[];
}
