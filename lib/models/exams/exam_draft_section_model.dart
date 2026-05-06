import 'exam_generator_enums.dart';

class ExamDraftSectionModel {
  const ExamDraftSectionModel({
    required this.id,
    required this.draftId,
    required this.title,
    this.instructions,
    required this.sectionOrder,
    this.totalMarks,
    required this.answerPolicy,
    this.requiredAnswerCount,
  });

  final int id;
  final int draftId;
  final String title;
  final String? instructions;
  final int sectionOrder;
  final double? totalMarks;
  final ExamSectionAnswerPolicy answerPolicy;
  final int? requiredAnswerCount;

  factory ExamDraftSectionModel.fromJson(Map<String, dynamic> json) {
    return ExamDraftSectionModel(
      id: _toInt(json['id']),
      draftId: _toInt(json['draftId']),
      title: json['title']?.toString() ?? '',
      instructions: _nullableString(json['instructions']),
      sectionOrder: _toInt(json['sectionOrder']),
      totalMarks: _nullableDouble(json['totalMarks']),
      answerPolicy: ExamSectionAnswerPolicy.fromJson(json['answerPolicy']),
      requiredAnswerCount: _nullableInt(json['requiredAnswerCount']),
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

String? _nullableString(dynamic value) {
  final text = value?.toString();
  return text == null || text.isEmpty ? null : text;
}
