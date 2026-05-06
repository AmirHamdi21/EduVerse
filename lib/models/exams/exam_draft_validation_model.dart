class ExamDraftSectionValidationModel {
  const ExamDraftSectionValidationModel({
    required this.sectionId,
    required this.title,
    required this.itemCount,
    this.sectionMarks,
    required this.itemMarksTotal,
    required this.answerPolicy,
    this.requiredAnswerCount,
  });

  final int sectionId;
  final String title;
  final int itemCount;
  final double? sectionMarks;
  final double itemMarksTotal;
  final String answerPolicy;
  final int? requiredAnswerCount;

  factory ExamDraftSectionValidationModel.fromJson(Map<String, dynamic> json) {
    return ExamDraftSectionValidationModel(
      sectionId: _toInt(json['sectionId']),
      title: json['title']?.toString() ?? '',
      itemCount: _toInt(json['itemCount']),
      sectionMarks: _nullableDouble(json['sectionMarks']),
      itemMarksTotal: _toDouble(json['itemMarksTotal']),
      answerPolicy: json['answerPolicy']?.toString() ?? '',
      requiredAnswerCount: _nullableInt(json['requiredAnswerCount']),
    );
  }
}

class ExamDraftValidationModel {
  const ExamDraftValidationModel({
    required this.canSave,
    this.warnings = const <String>[],
    this.errors = const <String>[],
    this.checklist = const <ExamDraftChecklistItemModel>[],
    required this.totalQuestions,
    this.totalMarks,
    this.sectionSummaries = const <ExamDraftSectionValidationModel>[],
  });

  final bool canSave;
  final List<String> warnings;
  final List<String> errors;
  final List<ExamDraftChecklistItemModel> checklist;
  final int totalQuestions;
  final double? totalMarks;
  final List<ExamDraftSectionValidationModel> sectionSummaries;

  factory ExamDraftValidationModel.fromJson(Map<String, dynamic> json) {
    return ExamDraftValidationModel(
      canSave: json['canSave'] == true,
      warnings: _stringList(json['warnings']),
      errors: _stringList(json['errors']),
      checklist: _asList(json['checklist'])
          .whereType<Map<String, dynamic>>()
          .map(ExamDraftChecklistItemModel.fromJson)
          .toList(),
      totalQuestions: _toInt(json['totalQuestions']),
      totalMarks: _nullableDouble(json['totalMarks']),
      sectionSummaries: _asList(json['sectionSummaries'])
          .whereType<Map<String, dynamic>>()
          .map(ExamDraftSectionValidationModel.fromJson)
          .toList(),
    );
  }
}

class ExamDraftChecklistItemModel {
  const ExamDraftChecklistItemModel({
    required this.key,
    required this.status,
    required this.message,
    this.action,
  });

  final String key;
  final String status;
  final String message;
  final String? action;

  bool get isOk => status == 'ok';
  bool get isWarning => status == 'warning';
  bool get isError => status == 'error';

  factory ExamDraftChecklistItemModel.fromJson(Map<String, dynamic> json) {
    return ExamDraftChecklistItemModel(
      key: json['key']?.toString() ?? '',
      status: json['status']?.toString() ?? 'ok',
      message: json['message']?.toString() ?? '',
      action: _nullableString(json['action']),
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

List<dynamic> _asList(dynamic value) => value is List ? value : const <dynamic>[];

String? _nullableString(dynamic value) {
  final text = value?.toString();
  return text == null || text.isEmpty ? null : text;
}

List<String> _stringList(dynamic value) {
  return _asList(value).map((item) => item.toString()).toList();
}
