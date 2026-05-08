import 'exam_response_model.dart';

class ExamSnapshotItemModel {
  const ExamSnapshotItemModel({
    required this.id,
    required this.itemOrder,
    this.sectionId,
    this.questionText = '',
    this.questionFileId,
    this.questionFileCaption,
    this.questionFileAltText,
    this.questionImagePreviewUrl,
    this.sourceGroupId,
    this.sourceGroupTitle,
    this.sourceGroupPrompt,
    this.sourceGroupFileId,
    this.sourceGroupImagePreviewUrl,
    this.sourceQuestionVersionId,
    this.snapshotCreatedAt,
    this.marks,
    this.raw = const <String, dynamic>{},
  });

  final int id;
  final int itemOrder;
  final int? sectionId;
  final String questionText;
  final int? questionFileId;
  final String? questionFileCaption;
  final String? questionFileAltText;
  final String? questionImagePreviewUrl;
  final int? sourceGroupId;
  final String? sourceGroupTitle;
  final String? sourceGroupPrompt;
  final int? sourceGroupFileId;
  final String? sourceGroupImagePreviewUrl;
  final int? sourceQuestionVersionId;
  final DateTime? snapshotCreatedAt;
  final double? marks;
  final Map<String, dynamic> raw;

  factory ExamSnapshotItemModel.fromJson(Map<String, dynamic> json) {
    final snapshot = _map(json['snapshot']).isNotEmpty
        ? _map(json['snapshot'])
        : json;
    return ExamSnapshotItemModel(
      id: _toInt(json['id'] ?? json['itemId'] ?? snapshot['id']),
      itemOrder: _toInt(json['itemOrder'] ?? snapshot['itemOrder']),
      sectionId: _nullableInt(json['sectionId'] ?? json['draftSectionId']),
      questionText:
          (snapshot['questionText'] ?? snapshot['text'] ?? json['questionText'])
              ?.toString() ??
          '',
      questionFileId: _nullableInt(snapshot['questionFileId']),
      questionFileCaption: _nullableString(snapshot['questionFileCaption']),
      questionFileAltText: _nullableString(snapshot['questionFileAltText']),
      questionImagePreviewUrl: _nullableString(
        snapshot['questionImagePreviewUrl'],
      ),
      sourceGroupId: _nullableInt(snapshot['sourceGroupId']),
      sourceGroupTitle: _nullableString(snapshot['sourceGroupTitle']),
      sourceGroupPrompt: _nullableString(snapshot['sourceGroupPrompt']),
      sourceGroupFileId: _nullableInt(snapshot['sourceGroupFileId']),
      sourceGroupImagePreviewUrl: _nullableString(
        snapshot['sourceGroupImagePreviewUrl'],
      ),
      sourceQuestionVersionId: _nullableInt(
        snapshot['sourceQuestionVersionId'],
      ),
      snapshotCreatedAt: _nullableDate(
        snapshot['snapshotCreatedAt'] ?? snapshot['createdAt'],
      ),
      marks: _nullableDouble(json['marks'] ?? snapshot['marks']),
      raw: json,
    );
  }
}

DateTime? _nullableDate(dynamic value) {
  final text = value?.toString();
  if (text == null || text.isEmpty) return null;
  return DateTime.tryParse(text);
}

class ExamFullSectionModel {
  const ExamFullSectionModel({
    required this.id,
    required this.title,
    this.instructions,
    this.totalMarks,
    this.items = const <ExamSnapshotItemModel>[],
    this.raw = const <String, dynamic>{},
  });

  final int id;
  final String title;
  final String? instructions;
  final double? totalMarks;
  final List<ExamSnapshotItemModel> items;
  final Map<String, dynamic> raw;

  factory ExamFullSectionModel.fromJson(
    Map<String, dynamic> json, {
    List<ExamSnapshotItemModel>? fallbackItems,
  }) {
    return ExamFullSectionModel(
      id: _toInt(json['id'] ?? json['sectionId']),
      title: json['title']?.toString() ?? '',
      instructions: _nullableString(json['instructions']),
      totalMarks: _nullableDouble(json['totalMarks']),
      items:
          fallbackItems ??
          _asList(json['items'])
              .whereType<Map<String, dynamic>>()
              .map(ExamSnapshotItemModel.fromJson)
              .toList(),
      raw: json,
    );
  }
}

class ExamFullDetailModel {
  const ExamFullDetailModel({
    required this.exam,
    this.durationMinutes,
    this.instructions,
    this.headerText,
    this.footerText,
    this.paperTemplateId,
    this.paperTemplateSnapshot,
    this.seed,
    this.generatedAt,
    this.savedAt,
    this.courseCode,
    this.courseName,
    this.sections = const <ExamFullSectionModel>[],
    this.unsectionedItems = const <ExamSnapshotItemModel>[],
    this.raw = const <String, dynamic>{},
  });

  final ExamResponseModel exam;
  final int? durationMinutes;
  final String? instructions;
  final String? headerText;
  final String? footerText;
  final int? paperTemplateId;
  final Map<String, dynamic>? paperTemplateSnapshot;
  final String? seed;
  final DateTime? generatedAt;
  final DateTime? savedAt;
  final String? courseCode;
  final String? courseName;
  final List<ExamFullSectionModel> sections;
  final List<ExamSnapshotItemModel> unsectionedItems;
  final Map<String, dynamic> raw;

  factory ExamFullDetailModel.fromJson(Map<String, dynamic> json) {
    final examJson = _map(json['exam']).isNotEmpty ? _map(json['exam']) : json;
    final topLevelItems = _asList(json['items'])
        .whereType<Map<String, dynamic>>()
        .map(ExamSnapshotItemModel.fromJson)
        .toList();
    final sectionJsonList = _asList(
      json['sections'],
    ).whereType<Map<String, dynamic>>().toList();
    final sections = sectionJsonList.map((sectionJson) {
      final sectionId = _toInt(sectionJson['id'] ?? sectionJson['sectionId']);
      final hasEmbeddedItems = _asList(sectionJson['items']).isNotEmpty;
      return ExamFullSectionModel.fromJson(
        sectionJson,
        fallbackItems: hasEmbeddedItems
            ? null
            : topLevelItems
                  .where((item) => item.sectionId == sectionId)
                  .toList(),
      );
    }).toList();
    final sectionIds = sections.map((section) => section.id).toSet();
    return ExamFullDetailModel(
      exam: ExamResponseModel.fromJson(examJson),
      durationMinutes: _nullableInt(
        json['durationMinutes'] ?? examJson['durationMinutes'],
      ),
      instructions: _nullableString(
        json['instructions'] ?? examJson['instructions'],
      ),
      headerText: _nullableString(json['headerText'] ?? examJson['headerText']),
      footerText: _nullableString(json['footerText'] ?? examJson['footerText']),
      paperTemplateId: _nullableInt(
        json['paperTemplateId'] ?? examJson['paperTemplateId'],
      ),
      paperTemplateSnapshot:
          _map(
            json['paperTemplateSnapshot'] ?? examJson['paperTemplateSnapshot'],
          ).isEmpty
          ? null
          : _map(
              json['paperTemplateSnapshot'] ??
                  examJson['paperTemplateSnapshot'],
            ),
      seed: _nullableString(
        json['seed'] ?? examJson['seed'] ?? _map(json['snapshot'])['seed'],
      ),
      generatedAt: _nullableDate(
        json['generatedAt'] ??
            examJson['generatedAt'] ??
            _map(json['snapshot'])['generatedAt'],
      ),
      savedAt: _nullableDate(
        json['savedAt'] ??
            examJson['savedAt'] ??
            _map(json['snapshot'])['savedAt'],
      ),
      courseCode: _nullableString(_map(json['course'])['code']),
      courseName: _nullableString(_map(json['course'])['name']),
      sections: sections,
      unsectionedItems: topLevelItems
          .where(
            (item) =>
                item.sectionId == null || !sectionIds.contains(item.sectionId),
          )
          .toList(),
      raw: json,
    );
  }
}

Map<String, dynamic> _map(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
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

double? _nullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

String? _nullableString(dynamic value) {
  final text = value?.toString();
  return text == null || text.isEmpty ? null : text;
}

List<dynamic> _asList(dynamic value) =>
    value is List ? value : const <dynamic>[];
