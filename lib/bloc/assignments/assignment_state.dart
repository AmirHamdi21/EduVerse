import 'package:equatable/equatable.dart';

import '../../models/assignments/assignment_model.dart';
import '../../models/assignments/assignment_submission_model.dart';
import '../../models/core/course_model.dart';

enum AssignmentFilterStatus { all, submitted, pending, overdue }

class AssignmentState extends Equatable {
  final List<CourseModel> enrolledCourses;
  final int? selectedCourseId;
  final CourseModel? selectedCourse;
  final List<AssignmentModel> assignments;
  final AssignmentModel? selectedAssignment;
  final AssignmentSubmissionModel? mySubmission;
  final bool isSubmitting;
  final double submitProgress;
  final String? submitError;
  final bool isListLoading;
  final bool isDetailLoading;
  final String? error;
  final AssignmentFilterStatus filterStatus;
  final String searchQuery;
  final int totalCount;
  final int submittedCount;
  final int pendingCount;
  final int overdueCount;

  const AssignmentState({
    this.enrolledCourses = const <CourseModel>[],
    this.selectedCourseId,
    this.selectedCourse,
    this.assignments = const <AssignmentModel>[],
    this.selectedAssignment,
    this.mySubmission,
    this.isSubmitting = false,
    this.submitProgress = 0,
    this.submitError,
    this.isListLoading = false,
    this.isDetailLoading = false,
    this.error,
    this.filterStatus = AssignmentFilterStatus.all,
    this.searchQuery = '',
    this.totalCount = 0,
    this.submittedCount = 0,
    this.pendingCount = 0,
    this.overdueCount = 0,
  });

  bool get isLoading => isListLoading || isDetailLoading;

  AssignmentState copyWith({
    List<CourseModel>? enrolledCourses,
    int? selectedCourseId,
    CourseModel? selectedCourse,
    List<AssignmentModel>? assignments,
    AssignmentModel? selectedAssignment,
    AssignmentSubmissionModel? mySubmission,
    bool? isSubmitting,
    double? submitProgress,
    String? submitError,
    bool? isListLoading,
    bool? isDetailLoading,
    String? error,
    AssignmentFilterStatus? filterStatus,
    String? searchQuery,
    int? totalCount,
    int? submittedCount,
    int? pendingCount,
    int? overdueCount,
    bool clearError = false,
    bool clearSubmitError = false,
    bool clearSelectedAssignment = false,
    bool clearSubmission = false,
    bool clearSelectedCourseId = false,
    bool clearSelectedCourse = false,
  }) {
    return AssignmentState(
      enrolledCourses: enrolledCourses ?? this.enrolledCourses,
      selectedCourseId: clearSelectedCourseId
          ? null
          : (selectedCourseId ?? this.selectedCourseId),
      selectedCourse: clearSelectedCourse
          ? null
          : (selectedCourse ?? this.selectedCourse),
      assignments: assignments ?? this.assignments,
      selectedAssignment: clearSelectedAssignment
          ? null
          : (selectedAssignment ?? this.selectedAssignment),
      mySubmission: clearSubmission
          ? null
          : (mySubmission ?? this.mySubmission),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitProgress: submitProgress ?? this.submitProgress,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
      isListLoading: isListLoading ?? this.isListLoading,
      isDetailLoading: isDetailLoading ?? this.isDetailLoading,
      error: clearError ? null : (error ?? this.error),
      filterStatus: filterStatus ?? this.filterStatus,
      searchQuery: searchQuery ?? this.searchQuery,
      totalCount: totalCount ?? this.totalCount,
      submittedCount: submittedCount ?? this.submittedCount,
      pendingCount: pendingCount ?? this.pendingCount,
      overdueCount: overdueCount ?? this.overdueCount,
    );
  }

  List<AssignmentModel> get filteredAssignments {
    var filtered = List<AssignmentModel>.from(assignments);

    if (searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      filtered = filtered.where((assignment) {
        return assignment.title.toLowerCase().contains(query) ||
            (assignment.description?.toLowerCase().contains(query) ?? false) ||
            assignment.courseName.toLowerCase().contains(query) ||
            assignment.courseCode.toLowerCase().contains(query);
      }).toList();
    }

    switch (filterStatus) {
      case AssignmentFilterStatus.all:
        break;
      case AssignmentFilterStatus.submitted:
        filtered = filtered
            .where(
              (assignment) => assignment.submissionFilterStatus == 'submitted',
            )
            .toList();
        break;
      case AssignmentFilterStatus.pending:
        filtered = filtered
            .where(
              (assignment) => assignment.submissionFilterStatus == 'pending',
            )
            .toList();
        break;
      case AssignmentFilterStatus.overdue:
        filtered = filtered
            .where(
              (assignment) => assignment.submissionFilterStatus == 'overdue',
            )
            .toList();
        break;
    }

    filtered.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return filtered;
  }

  @override
  List<Object?> get props => <Object?>[
    enrolledCourses,
    selectedCourseId,
    selectedCourse,
    assignments,
    selectedAssignment,
    mySubmission,
    isSubmitting,
    submitProgress,
    submitError,
    isListLoading,
    isDetailLoading,
    error,
    filterStatus,
    searchQuery,
    totalCount,
    submittedCount,
    pendingCount,
    overdueCount,
  ];
}
