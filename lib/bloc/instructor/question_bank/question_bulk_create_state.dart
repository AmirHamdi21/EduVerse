import 'package:equatable/equatable.dart';

import '../../../models/instructor/teaching_course_model.dart';
import '../../../models/question_bank/course_chapter_model.dart';
import '../../../models/question_bank/question_bulk_row_model.dart';
import '../../../models/question_bank/question_bank_question_model.dart';

class QuestionBulkCreateState extends Equatable {
  const QuestionBulkCreateState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.isLoadingChapters = false,
    this.courses = const <TeachingCourseModel>[],
    this.chapters = const <CourseChapterModel>[],
    this.courseId,
    this.defaultChapterId,
    this.rows = const <QuestionBulkRowModel>[QuestionBulkRowModel(localId: 1)],
    this.errorMessage,
    this.successMessage,
    this.createdQuestions = const <QuestionBankQuestionModel>[],
    this.failedRows = const <QuestionBulkRowModel>[],
    this.failureReportMessage,
  });

  final bool isLoading;
  final bool isSubmitting;
  final bool isLoadingChapters;
  final List<TeachingCourseModel> courses;
  final List<CourseChapterModel> chapters;
  final int? courseId;
  final int? defaultChapterId;
  final List<QuestionBulkRowModel> rows;
  final String? errorMessage;
  final String? successMessage;
  final List<QuestionBankQuestionModel> createdQuestions;
  final List<QuestionBulkRowModel> failedRows;
  final String? failureReportMessage;

  QuestionBulkCreateState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    bool? isLoadingChapters,
    List<TeachingCourseModel>? courses,
    List<CourseChapterModel>? chapters,
    int? courseId,
    bool clearCourse = false,
    int? defaultChapterId,
    bool clearDefaultChapter = false,
    List<QuestionBulkRowModel>? rows,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    List<QuestionBankQuestionModel>? createdQuestions,
    bool clearCreatedQuestions = false,
    List<QuestionBulkRowModel>? failedRows,
    String? failureReportMessage,
    bool clearFailureReport = false,
  }) {
    return QuestionBulkCreateState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isLoadingChapters: isLoadingChapters ?? this.isLoadingChapters,
      courses: courses ?? this.courses,
      chapters: chapters ?? this.chapters,
      courseId: clearCourse ? null : courseId ?? this.courseId,
      defaultChapterId: clearDefaultChapter
          ? null
          : defaultChapterId ?? this.defaultChapterId,
      rows: rows ?? this.rows,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage: clearSuccess
          ? null
          : successMessage ?? this.successMessage,
      createdQuestions: clearCreatedQuestions
          ? const <QuestionBankQuestionModel>[]
          : createdQuestions ?? this.createdQuestions,
      failedRows: clearFailureReport
          ? const <QuestionBulkRowModel>[]
          : failedRows ?? this.failedRows,
      failureReportMessage: clearFailureReport
          ? null
          : failureReportMessage ?? this.failureReportMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isSubmitting,
    isLoadingChapters,
    courses,
    chapters,
    courseId,
    defaultChapterId,
    rows,
    errorMessage,
    successMessage,
    createdQuestions,
    failedRows,
    failureReportMessage,
  ];
}
