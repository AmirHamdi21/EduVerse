import 'exam_generation_rule_model.dart';
import 'exam_generator_enums.dart';

class ExamGenerationSectionModel {
  const ExamGenerationSectionModel({
    required this.title,
    this.instructions,
    required this.totalMarks,
    this.answerPolicy = ExamSectionAnswerPolicy.answerAll,
    this.requiredAnswerCount,
    required this.rules,
  });

  final String title;
  final String? instructions;
  final double totalMarks;
  final ExamSectionAnswerPolicy answerPolicy;
  final int? requiredAnswerCount;
  final List<ExamGenerationRuleModel> rules;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title.trim(),
      if (instructions != null && instructions!.trim().isNotEmpty)
        'instructions': instructions!.trim(),
      'totalMarks': totalMarks,
      'answerPolicy': answerPolicy.value,
      if (requiredAnswerCount != null) 'requiredAnswerCount': requiredAnswerCount,
      'rules': rules.map((rule) => rule.toJson()).toList(),
    };
  }

  String? validate() {
    if (title.trim().isEmpty) return 'Section title is required';
    if (totalMarks <= 0) return 'Section marks must be greater than zero';
    if (rules.isEmpty) return 'Add at least one rule';
    for (final rule in rules) {
      final error = rule.validate();
      if (error != null) return error;
    }
    return null;
  }
}
