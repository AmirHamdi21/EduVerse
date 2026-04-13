import '../core/enums/assignment_enums.dart' as api;

/// Model for grading statistics
class GradingStatistics {
  final int totalSubmissions;
  final int pendingSubmissions;
  final int gradedSubmissions;
  final int lateSubmissions;
  final double averageGrade;
  final double completionRate;

  const GradingStatistics({
    this.totalSubmissions = 0,
    this.pendingSubmissions = 0,
    this.gradedSubmissions = 0,
    this.lateSubmissions = 0,
    this.averageGrade = 0,
    this.completionRate = 0,
  });

  double get gradingProgress =>
      totalSubmissions > 0 ? gradedSubmissions / totalSubmissions : 0;
}

/// Assignment filter model
class GradingFilter {
  final int? courseId;
  final int? assignmentId;
  final api.SubmissionStatus? status;
  final String searchQuery;
  final GradingSortBy sortBy;
  final bool sortAscending;

  const GradingFilter({
    this.courseId,
    this.assignmentId,
    this.status,
    this.searchQuery = '',
    this.sortBy = GradingSortBy.submittedAt,
    this.sortAscending = false,
  });

  GradingFilter copyWith({
    int? courseId,
    int? assignmentId,
    api.SubmissionStatus? status,
    String? searchQuery,
    GradingSortBy? sortBy,
    bool? sortAscending,
    bool clearCourse = false,
    bool clearAssignment = false,
    bool clearStatus = false,
  }) {
    return GradingFilter(
      courseId: clearCourse ? null : (courseId ?? this.courseId),
      assignmentId: clearAssignment
          ? null
          : (assignmentId ?? this.assignmentId),
      status: clearStatus ? null : (status ?? this.status),
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }
}

enum GradingSortBy { studentName, submittedAt, score, status }
