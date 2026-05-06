import 'question_bank_enums.dart';

class QuestionBankGroupSummaryModel {
  const QuestionBankGroupSummaryModel({
    required this.groupItemId,
    required this.groupId,
    required this.itemOrder,
    required this.courseId,
    this.chapterId,
    this.title,
    this.sharedPrompt,
    this.sharedFileId,
    this.sharedFileCaption,
    this.sharedFileAltText,
    required this.groupType,
  });

  final int groupItemId;
  final int groupId;
  final int itemOrder;
  final int courseId;
  final int? chapterId;
  final String? title;
  final String? sharedPrompt;
  final int? sharedFileId;
  final String? sharedFileCaption;
  final String? sharedFileAltText;
  final QuestionGroupType groupType;

  factory QuestionBankGroupSummaryModel.fromJson(Map<String, dynamic> json) {
    return QuestionBankGroupSummaryModel(
      groupItemId: _toInt(json['groupItemId']),
      groupId: _toInt(json['groupId']),
      itemOrder: _toInt(json['itemOrder']),
      courseId: _toInt(json['courseId']),
      chapterId: _nullableInt(json['chapterId']),
      title: _nullableString(json['title']),
      sharedPrompt: _nullableString(json['sharedPrompt']),
      sharedFileId: _nullableInt(json['sharedFileId']),
      sharedFileCaption: _nullableString(json['sharedFileCaption']),
      sharedFileAltText: _nullableString(json['sharedFileAltText']),
      groupType: QuestionGroupType.fromJson(json['groupType']),
    );
  }
}

class QuestionBankGroupItemModel {
  const QuestionBankGroupItemModel({
    required this.id,
    required this.questionId,
    required this.itemOrder,
  });

  final int id;
  final int questionId;
  final int itemOrder;

  factory QuestionBankGroupItemModel.fromJson(Map<String, dynamic> json) {
    return QuestionBankGroupItemModel(
      id: _toInt(json['id'] ?? json['groupItemId']),
      questionId: _toInt(json['questionId']),
      itemOrder: _toInt(json['itemOrder']),
    );
  }
}

class QuestionBankGroupModel {
  const QuestionBankGroupModel({
    required this.id,
    required this.courseId,
    this.chapterId,
    this.title,
    this.sharedPrompt,
    this.sharedFileId,
    this.sharedFileCaption,
    this.sharedFileAltText,
    required this.groupType,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.totalQuestions = 0,
    this.approvedQuestions = 0,
    this.draftQuestions = 0,
    this.underReviewQuestions = 0,
    this.rejectedQuestions = 0,
    this.archivedQuestions = 0,
    this.items = const <QuestionBankGroupItemModel>[],
  });

  final int id;
  final int courseId;
  final int? chapterId;
  final String? title;
  final String? sharedPrompt;
  final int? sharedFileId;
  final String? sharedFileCaption;
  final String? sharedFileAltText;
  final QuestionGroupType groupType;
  final int? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final int totalQuestions;
  final int approvedQuestions;
  final int draftQuestions;
  final int underReviewQuestions;
  final int rejectedQuestions;
  final int archivedQuestions;
  final List<QuestionBankGroupItemModel> items;

  factory QuestionBankGroupModel.fromJson(Map<String, dynamic> json) {
    return QuestionBankGroupModel(
      id: _toInt(json['id'] ?? json['groupId']),
      courseId: _toInt(json['courseId']),
      chapterId: _nullableInt(json['chapterId']),
      title: _nullableString(json['title']),
      sharedPrompt: _nullableString(json['sharedPrompt']),
      sharedFileId: _nullableInt(json['sharedFileId']),
      sharedFileCaption: _nullableString(json['sharedFileCaption']),
      sharedFileAltText: _nullableString(json['sharedFileAltText']),
      groupType: QuestionGroupType.fromJson(json['groupType']),
      createdBy: _nullableInt(json['createdBy']),
      createdAt: _toDate(json['createdAt']),
      updatedAt: _toDate(json['updatedAt']),
      deletedAt: _toDate(json['deletedAt']),
      totalQuestions: _toInt(json['totalQuestions']),
      approvedQuestions: _toInt(json['approvedQuestions']),
      draftQuestions: _toInt(json['draftQuestions']),
      underReviewQuestions: _toInt(json['underReviewQuestions']),
      rejectedQuestions: _toInt(json['rejectedQuestions']),
      archivedQuestions: _toInt(json['archivedQuestions']),
      items: _asList(json['items'])
          .whereType<Map<String, dynamic>>()
          .map(QuestionBankGroupItemModel.fromJson)
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

DateTime? _toDate(dynamic value) {
  if (value is DateTime) return value;
  return DateTime.tryParse(value?.toString() ?? '');
}

List<dynamic> _asList(dynamic value) {
  return value is List ? value : const <dynamic>[];
}
