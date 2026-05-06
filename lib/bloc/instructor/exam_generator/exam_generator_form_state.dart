import 'package:equatable/equatable.dart';

import '../../../models/exams/exam_generation_form_model.dart';
import '../../../models/exams/exam_generation_rule_model.dart';
import '../../../models/exams/exam_generation_section_model.dart';
import '../../../models/exams/exam_generator_enums.dart';
import '../../../models/exams/exam_availability_model.dart';
import '../../../models/exams/exam_shortage_model.dart';
import '../../../models/instructor/teaching_course_model.dart';
import '../../../models/question_bank/course_chapter_model.dart';
import '../../../models/question_bank/question_bank_group_model.dart';

class ExamGeneratorFormState extends Equatable {
  const ExamGeneratorFormState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.isCheckingAvailability = false,
    this.courses = const <TeachingCourseModel>[],
    this.chapters = const <CourseChapterModel>[],
    this.groups = const <QuestionBankGroupModel>[],
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
    this.availability,
    this.shortages = const <ExamShortageModel>[],
    this.errorMessage,
    this.createdDraftId,
  });

  final bool isLoading;
  final bool isSubmitting;
  final bool isCheckingAvailability;
  final List<TeachingCourseModel> courses;
  final List<CourseChapterModel> chapters;
  final List<QuestionBankGroupModel> groups;
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
  final ExamAvailabilityModel? availability;
  final List<ExamShortageModel> shortages;
  final String? errorMessage;
  final int? createdDraftId;

  ExamGeneratorFormState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    bool? isCheckingAvailability,
    List<TeachingCourseModel>? courses,
    List<CourseChapterModel>? chapters,
    List<QuestionBankGroupModel>? groups,
    int? courseId,
    bool clearCourse = false,
    String? title,
    double? totalMarks,
    bool clearTotalMarks = false,
    ExamGenerationMode? mode,
    ExamMarkDistributionMode? markDistributionMode,
    ExamRoundingPolicy? roundingPolicy,
    ExamGroupSelectionMode? groupSelectionMode,
    String? seed,
    int? durationMinutes,
    bool clearDuration = false,
    String? instructions,
    String? headerText,
    String? footerText,
    List<ExamGenerationRuleModel>? rules,
    List<ExamGenerationSectionModel>? sections,
    ExamAvailabilityModel? availability,
    bool clearAvailability = false,
    List<ExamShortageModel>? shortages,
    String? errorMessage,
    int? createdDraftId,
    bool clearError = false,
    bool clearShortages = false,
    bool clearDraft = false,
  }) {
    return ExamGeneratorFormState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isCheckingAvailability:
          isCheckingAvailability ?? this.isCheckingAvailability,
      courses: courses ?? this.courses,
      chapters: chapters ?? this.chapters,
      groups: groups ?? this.groups,
      courseId: clearCourse ? null : courseId ?? this.courseId,
      title: title ?? this.title,
      totalMarks: clearTotalMarks ? null : totalMarks ?? this.totalMarks,
      mode: mode ?? this.mode,
      markDistributionMode: markDistributionMode ?? this.markDistributionMode,
      roundingPolicy: roundingPolicy ?? this.roundingPolicy,
      groupSelectionMode: groupSelectionMode ?? this.groupSelectionMode,
      seed: seed ?? this.seed,
      durationMinutes: clearDuration
          ? null
          : durationMinutes ?? this.durationMinutes,
      instructions: instructions ?? this.instructions,
      headerText: headerText ?? this.headerText,
      footerText: footerText ?? this.footerText,
      rules: rules ?? this.rules,
      sections: sections ?? this.sections,
      availability: clearAvailability
          ? null
          : availability ?? this.availability,
      shortages: clearShortages ? const [] : shortages ?? this.shortages,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      createdDraftId: clearDraft ? null : createdDraftId ?? this.createdDraftId,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isSubmitting,
    isCheckingAvailability,
    courses,
    chapters,
    groups,
    courseId,
    title,
    totalMarks,
    mode,
    markDistributionMode,
    roundingPolicy,
    groupSelectionMode,
    seed,
    durationMinutes,
    instructions,
    headerText,
    footerText,
    rules,
    sections,
    availability,
    shortages,
    errorMessage,
    createdDraftId,
  ];
}
