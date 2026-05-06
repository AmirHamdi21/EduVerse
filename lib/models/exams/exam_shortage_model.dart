class ExamShortageModel {
  const ExamShortageModel({
    this.section,
    required this.chapterId,
    required this.required,
    required this.available,
    this.questionType,
    this.difficulty,
    this.bloomLevel,
  });

  final String? section;
  final int chapterId;
  final int required;
  final int available;
  final String? questionType;
  final String? difficulty;
  final String? bloomLevel;

  factory ExamShortageModel.fromJson(Map<String, dynamic> json) {
    return ExamShortageModel(
      section: _nullableString(json['section']),
      chapterId: _toInt(json['chapterId']),
      required: _toInt(json['required']),
      available: _toInt(json['available']),
      questionType: _nullableString(json['questionType']),
      difficulty: _nullableString(json['difficulty']),
      bloomLevel: _nullableString(json['bloomLevel']),
    );
  }
}

class ExamShortageException implements Exception {
  const ExamShortageException(this.message, this.shortages);

  final String message;
  final List<ExamShortageModel> shortages;

  @override
  String toString() => message;
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String? _nullableString(dynamic value) {
  final text = value?.toString();
  return text == null || text.isEmpty ? null : text;
}
