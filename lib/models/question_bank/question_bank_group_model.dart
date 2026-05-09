import 'question_bank_enums.dart';

class QuestionBankGroupSummaryModel {
  const QuestionBankGroupSummaryModel({
    required this.groupItemId,
    required this.groupId,
    required this.itemOrder,
    required this.courseId,
    this.courseCode,
    this.courseName,
    this.chapterId,
    this.title,
    this.sharedPrompt,
    this.sharedFileId,
    this.sharedImageUrl,
    this.sharedFileCaption,
    this.sharedFileAltText,
    required this.groupType,
  });

  final int groupItemId;
  final int groupId;
  final int itemOrder;
  final int courseId;
  final String? courseCode;
  final String? courseName;
  final int? chapterId;
  final String? title;
  final String? sharedPrompt;
  final int? sharedFileId;
  final String? sharedImageUrl;
  final String? sharedFileCaption;
  final String? sharedFileAltText;
  final QuestionGroupType groupType;

  factory QuestionBankGroupSummaryModel.fromJson(Map<String, dynamic> json) {
    return QuestionBankGroupSummaryModel(
      groupItemId: _toInt(json['groupItemId']),
      groupId: _toInt(json['groupId']),
      itemOrder: _toInt(json['itemOrder']),
      courseId: _toInt(json['courseId']),
      courseCode: _courseCode(json),
      courseName: _courseName(json),
      chapterId: _nullableInt(json['chapterId']),
      title: _nullableString(json['title']),
      sharedPrompt: _nullableString(json['sharedPrompt']),
      sharedFileId: _nullableInt(json['sharedFileId']),
      sharedImageUrl: _sharedImageUrl(json),
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
    final nestedQuestion = json['question'];
    final question = nestedQuestion is Map<String, dynamic>
        ? nestedQuestion
        : const <String, dynamic>{};
    return QuestionBankGroupItemModel(
      id: _toInt(json['id'] ?? json['groupItemId']),
      questionId: _toInt(
        json['questionId'] ??
            question['questionId'] ??
            question['id'] ??
            (json.containsKey('questionType') ? json['id'] : null),
      ),
      itemOrder: _toInt(json['itemOrder']),
    );
  }
}

class QuestionBankGroupModel {
  const QuestionBankGroupModel({
    required this.id,
    required this.courseId,
    this.courseCode,
    this.courseName,
    this.chapterId,
    this.title,
    this.sharedPrompt,
    this.sharedFileId,
    this.sharedImageUrl,
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
  final String? courseCode;
  final String? courseName;
  final int? chapterId;
  final String? title;
  final String? sharedPrompt;
  final int? sharedFileId;
  final String? sharedImageUrl;
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
      courseCode: _courseCode(json),
      courseName: _courseName(json),
      chapterId: _nullableInt(json['chapterId']),
      title: _nullableString(json['title']),
      sharedPrompt: _nullableString(json['sharedPrompt']),
      sharedFileId: _nullableInt(json['sharedFileId']),
      sharedImageUrl: _sharedImageUrl(json),
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
      items:
          _asList(
                json['items'] ??
                    json['groupItems'] ??
                    json['questionItems'] ??
                    json['questions'],
              )
              .whereType<Map<String, dynamic>>()
              .map(QuestionBankGroupItemModel.fromJson)
              .where((item) => item.questionId > 0)
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

Map<String, dynamic>? _nestedCourse(Map<String, dynamic> json) {
  final course = json['course'];
  return course is Map<String, dynamic> ? course : null;
}

String? _courseCode(Map<String, dynamic> json) {
  final course = _nestedCourse(json);
  return _nullableString(
    json['courseCode'] ??
        json['code'] ??
        course?['code'] ??
        course?['courseCode'],
  );
}

String? _courseName(Map<String, dynamic> json) {
  final course = _nestedCourse(json);
  return _nullableString(
    json['courseName'] ??
        json['name'] ??
        course?['name'] ??
        course?['courseName'],
  );
}

String? _sharedImageUrl(Map<String, dynamic> json) {
  final sharedFile = json['sharedFile'];
  final file = json['file'];
  final sharedFileMap = sharedFile is Map<String, dynamic> ? sharedFile : null;
  final fileMap = file is Map<String, dynamic> ? file : null;
  return _nullableString(
    json['sharedImageUrl'] ??
        json['sharedFileUrl'] ??
        json['sharedFileImageUrl'] ??
        json['imageUrl'] ??
        json['url'] ??
        sharedFileMap?['imageUrl'] ??
        sharedFileMap?['url'] ??
        sharedFileMap?['downloadUrl'] ??
        fileMap?['imageUrl'] ??
        fileMap?['url'] ??
        fileMap?['downloadUrl'],
  );
}
