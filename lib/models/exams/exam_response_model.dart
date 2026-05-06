import 'exam_generator_enums.dart';

class ExamResponseModel {
  const ExamResponseModel({
    required this.id,
    required this.courseId,
    required this.title,
    this.totalMarks,
    required this.status,
    this.durationMinutes,
    this.instructions,
    this.headerText,
    this.footerText,
    this.publishedAt,
    this.archivedAt,
    this.itemCount,
    this.sectionCount,
  });

  final int id;
  final int courseId;
  final String title;
  final double? totalMarks;
  final ExamStatus status;
  final int? durationMinutes;
  final String? instructions;
  final String? headerText;
  final String? footerText;
  final DateTime? publishedAt;
  final DateTime? archivedAt;
  final int? itemCount;
  final int? sectionCount;

  factory ExamResponseModel.fromJson(Map<String, dynamic> json) {
    return ExamResponseModel(
      id: _toInt(json['id']),
      courseId: _toInt(json['courseId']),
      title: json['title']?.toString() ?? '',
      totalMarks: _nullableDouble(json['totalMarks']),
      status: ExamStatus.fromJson(json['status']),
      durationMinutes: _nullableInt(json['durationMinutes']),
      instructions: _nullableString(json['instructions']),
      headerText: _nullableString(json['headerText']),
      footerText: _nullableString(json['footerText']),
      publishedAt: _toDate(json['publishedAt']),
      archivedAt: _toDate(json['archivedAt']),
      itemCount: _nullableInt(json['itemCount']),
      sectionCount: _nullableInt(json['sectionCount']),
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
