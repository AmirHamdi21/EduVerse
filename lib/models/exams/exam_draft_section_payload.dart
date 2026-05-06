import 'exam_generator_enums.dart';

class ExamDraftSectionPayload {
  const ExamDraftSectionPayload({
    required this.title,
    this.instructions,
    this.totalMarks,
    this.answerPolicy = ExamSectionAnswerPolicy.answerAll,
    this.requiredAnswerCount,
  });

  final String title;
  final String? instructions;
  final double? totalMarks;
  final ExamSectionAnswerPolicy answerPolicy;
  final int? requiredAnswerCount;

  String? validate() {
    if (title.trim().isEmpty) return 'Section title is required';
    if (totalMarks != null && totalMarks! < 0) {
      return 'Section marks cannot be negative';
    }
    if (requiredAnswerCount != null && requiredAnswerCount! <= 0) {
      return 'Required answer count must be positive';
    }
    return null;
  }
}
