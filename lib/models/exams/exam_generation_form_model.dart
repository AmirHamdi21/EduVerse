import 'exam_generation_rule_model.dart';
import 'exam_generation_section_model.dart';
import 'exam_generator_enums.dart';

enum ExamGenerationMode { flat, sectioned }

class ExamGenerationFormModel {
  const ExamGenerationFormModel({
    this.courseId,
    this.title = '',
    this.totalMarks,
    this.mode = ExamGenerationMode.flat,
    this.markDistributionMode = ExamMarkDistributionMode.weightNormalized,
    this.roundingPolicy = ExamRoundingPolicy.none,
    this.groupSelectionMode = ExamGroupSelectionMode.independent,
    this.seed = '',
    this.durationMinutes,
    this.instructions = '',
    this.headerText = '',
    this.footerText = '',
    this.rules = const <ExamGenerationRuleModel>[],
    this.sections = const <ExamGenerationSectionModel>[],
  });

  final int? courseId;
  final String title;
  final double? totalMarks;
  final ExamGenerationMode mode;
  final ExamMarkDistributionMode markDistributionMode;
  final ExamRoundingPolicy roundingPolicy;
  final ExamGroupSelectionMode groupSelectionMode;
  final String seed;
  final int? durationMinutes;
  final String instructions;
  final String headerText;
  final String footerText;
  final List<ExamGenerationRuleModel> rules;
  final List<ExamGenerationSectionModel> sections;

  String? validate() {
    if (courseId == null || courseId! <= 0) return 'Course is required';
    if (title.trim().isEmpty) return 'Title is required';
    if (totalMarks != null && totalMarks! <= 0) {
      return 'Total marks must be positive';
    }
    if (durationMinutes != null && durationMinutes! <= 0) {
      return 'Duration must be positive';
    }
    if (mode == ExamGenerationMode.flat) {
      if (rules.isEmpty) return 'Add at least one rule';
      for (final rule in rules) {
        final error = rule.validate();
        if (error != null) return error;
      }
    } else {
      if (sections.isEmpty) return 'Add at least one section';
      for (final section in sections) {
        final error = section.validate();
        if (error != null) return error;
      }
    }
    return null;
  }
}
