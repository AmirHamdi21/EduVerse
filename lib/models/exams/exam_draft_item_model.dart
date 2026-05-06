import '../question_bank/question_bank_enums.dart';
import '../question_bank/question_bank_question_model.dart';

class ExamDraftItemModel {
  const ExamDraftItemModel({
    required this.id,
    required this.draftId,
    required this.questionId,
    this.draftSectionId,
    required this.chapterId,
    required this.questionType,
    required this.difficulty,
    required this.bloomLevel,
    required this.weight,
    required this.weightUnits,
    this.marks,
    required this.itemOrder,
    this.sourceGroupId,
    this.sourceGroupItemOrder,
    this.overrideReason,
    this.sourceGroupTitle,
    this.sourceGroupPrompt,
    this.sourceGroupType,
    this.sourceGroupFileId,
    this.sourceGroupImagePreviewUrl,
    this.questionImagePreviewUrl,
    this.supportingAttachments = const <ExamDraftAttachmentPreviewModel>[],
    this.sourceQuestionStatus,
    this.sourceQuestionVersionId,
    this.originRule = const <String, dynamic>{},
    this.question,
  });

  final int id;
  final int draftId;
  final int questionId;
  final int? draftSectionId;
  final int chapterId;
  final QuestionBankType questionType;
  final QuestionBankDifficulty difficulty;
  final BloomLevel bloomLevel;
  final double weight;
  final double weightUnits;
  final double? marks;
  final int itemOrder;
  final int? sourceGroupId;
  final int? sourceGroupItemOrder;
  final String? overrideReason;
  final String? sourceGroupTitle;
  final String? sourceGroupPrompt;
  final String? sourceGroupType;
  final int? sourceGroupFileId;
  final String? sourceGroupImagePreviewUrl;
  final String? questionImagePreviewUrl;
  final List<ExamDraftAttachmentPreviewModel> supportingAttachments;
  final String? sourceQuestionStatus;
  final int? sourceQuestionVersionId;
  final Map<String, dynamic> originRule;
  final QuestionBankQuestionModel? question;

  factory ExamDraftItemModel.fromJson(Map<String, dynamic> json) {
    final rawQuestion = json['question'];
    return ExamDraftItemModel(
      id: _toInt(json['id'] ?? json['itemId']),
      draftId: _toInt(json['draftId']),
      questionId: _toInt(json['questionId']),
      draftSectionId: _nullableInt(json['draftSectionId']),
      chapterId: _toInt(json['chapterId']),
      questionType: QuestionBankType.fromJson(json['questionType']),
      difficulty: QuestionBankDifficulty.fromJson(json['difficulty']),
      bloomLevel: BloomLevel.fromJson(json['bloomLevel']),
      weight: _toDouble(json['weight']),
      weightUnits: _toDouble(json['weightUnits']),
      marks: _nullableDouble(json['marks']),
      itemOrder: _toInt(json['itemOrder']),
      sourceGroupId: _nullableInt(json['sourceGroupId']),
      sourceGroupItemOrder: _nullableInt(json['sourceGroupItemOrder']),
      overrideReason: _nullableString(json['overrideReason']),
      sourceGroupTitle: _nullableString(json['sourceGroupTitle']),
      sourceGroupPrompt: _nullableString(json['sourceGroupPrompt']),
      sourceGroupType: _nullableString(json['sourceGroupType']),
      sourceGroupFileId: _nullableInt(json['sourceGroupFileId']),
      sourceGroupImagePreviewUrl: _nullableString(json['sourceGroupImagePreviewUrl']),
      questionImagePreviewUrl: _nullableString(json['questionImagePreviewUrl']),
      supportingAttachments: _asList(json['supportingAttachments'])
          .whereType<Map<String, dynamic>>()
          .map(ExamDraftAttachmentPreviewModel.fromJson)
          .toList(),
      sourceQuestionStatus: _nullableString(json['sourceQuestionStatus']),
      sourceQuestionVersionId: _nullableInt(json['sourceQuestionVersionId']),
      originRule: _map(json['originRule'] ?? json['originRuleJson']),
      question: rawQuestion is Map<String, dynamic>
          ? QuestionBankQuestionModel.fromJson(rawQuestion)
          : null,
    );
  }
}

class ExamDraftAttachmentPreviewModel {
  const ExamDraftAttachmentPreviewModel({
    this.attachmentId,
    this.fileId,
    this.caption,
    this.altText,
    this.displayOrder = 0,
    this.previewUrl,
  });

  final int? attachmentId;
  final int? fileId;
  final String? caption;
  final String? altText;
  final int displayOrder;
  final String? previewUrl;

  factory ExamDraftAttachmentPreviewModel.fromJson(Map<String, dynamic> json) {
    return ExamDraftAttachmentPreviewModel(
      attachmentId: _nullableInt(json['attachmentId']),
      fileId: _nullableInt(json['fileId']),
      caption: _nullableString(json['caption']),
      altText: _nullableString(json['altText']),
      displayOrder: _toInt(json['displayOrder']),
      previewUrl: _nullableString(json['previewUrl']),
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

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

double? _nullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

String? _nullableString(dynamic value) {
  final text = value?.toString();
  return text == null || text.isEmpty ? null : text;
}

List<dynamic> _asList(dynamic value) => value is List ? value : const <dynamic>[];

Map<String, dynamic> _map(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const <String, dynamic>{};
}
