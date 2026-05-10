import 'exam_draft_item_model.dart';
import 'exam_draft_section_model.dart';
import 'exam_generator_enums.dart';

class ExamDraftModel {
  const ExamDraftModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.seed,
    this.totalMarks,
    required this.markDistributionMode,
    required this.roundingPolicy,
    required this.status,
    this.durationMinutes,
    this.instructions,
    this.headerText,
    this.footerText,
    this.finalizedExamId,
    this.finalizedAt,
    this.failureReason,
    required this.expiresAt,
    this.createdAt,
    this.updatedAt,
    this.itemCount,
    this.sectionCount,
    this.sections = const <ExamDraftSectionModel>[],
    this.items = const <ExamDraftItemModel>[],
  });

  final int id;
  final int courseId;
  final String title;
  final String seed;
  final double? totalMarks;
  final ExamMarkDistributionMode markDistributionMode;
  final ExamRoundingPolicy roundingPolicy;
  final ExamDraftStatus status;
  final int? durationMinutes;
  final String? instructions;
  final String? headerText;
  final String? footerText;
  final int? finalizedExamId;
  final DateTime? finalizedAt;
  final String? failureReason;
  final DateTime expiresAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? itemCount;
  final int? sectionCount;
  final List<ExamDraftSectionModel> sections;
  final List<ExamDraftItemModel> items;

  bool get isExpired => expiresAt.isBefore(DateTime.now());
  bool get isEditable => status == ExamDraftStatus.open && !isExpired;

  factory ExamDraftModel.fromJson(Map<String, dynamic> json) {
    return ExamDraftModel(
      id: _toInt(json['id'] ?? json['draftId']),
      courseId: _toInt(json['courseId']),
      title: json['title']?.toString() ?? '',
      seed: json['seed']?.toString() ?? '',
      totalMarks: _nullableDouble(json['totalMarks']),
      markDistributionMode: _markMode(json['markDistributionMode']),
      roundingPolicy: _rounding(json['roundingPolicy']),
      status: ExamDraftStatus.fromJson(json['status']),
      durationMinutes: _nullableInt(json['durationMinutes']),
      instructions: _nullableString(json['instructions']),
      headerText: _nullableString(json['headerText']),
      footerText: _nullableString(json['footerText']),
      finalizedExamId: _nullableInt(json['finalizedExamId']),
      finalizedAt: _toDate(json['finalizedAt']),
      failureReason: _nullableString(json['failureReason']),
      expiresAt: _toDate(json['expiresAt']) ?? DateTime.now(),
      createdAt: _toDate(json['createdAt']),
      updatedAt: _toDate(json['updatedAt']),
      itemCount: _nullableInt(json['itemCount']),
      sectionCount: _nullableInt(json['sectionCount']),
      sections: _asList(json['sections'])
          .whereType<Map<String, dynamic>>()
          .map(ExamDraftSectionModel.fromJson)
          .toList(),
      items: _asList(json['items'])
          .whereType<Map<String, dynamic>>()
          .map(ExamDraftItemModel.fromJson)
          .toList(),
    );
  }
}

ExamMarkDistributionMode _markMode(dynamic value) {
  return ExamMarkDistributionMode.values.firstWhere(
    (mode) => mode.value == value?.toString(),
    orElse: () => ExamMarkDistributionMode.weightNormalized,
  );
}

ExamRoundingPolicy _rounding(dynamic value) {
  return ExamRoundingPolicy.values.firstWhere(
    (policy) => policy.value == value?.toString(),
    orElse: () => ExamRoundingPolicy.none,
  );
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

DateTime? _toDate(dynamic value) {
  if (value is DateTime) return value;
  return DateTime.tryParse(value?.toString() ?? '');
}

String? _nullableString(dynamic value) {
  final text = value?.toString();
  return text == null || text.isEmpty ? null : text;
}

List<dynamic> _asList(dynamic value) {
  return value is List ? value : const <dynamic>[];
}
