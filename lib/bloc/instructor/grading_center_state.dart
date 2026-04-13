import 'package:equatable/equatable.dart';
import '../../models/assignments/assignment_submission_model.dart';
import '../../models/core/enums/assignment_enums.dart' as api;
import '../../models/instructor/grading_model.dart';
import '../../models/instructor/instructor_course_model.dart';

/// Grading center state
class GradingCenterState extends Equatable {
  final List<AssignmentSubmissionModel> submissions;
  final List<InstructorCourseModel> courses;
  final GradingFilter filter;
  final bool isLoading;
  final String? errorMessage;
  final GradingStatistics statistics;
  final int selectedTabIndex;
  final AssignmentSubmissionModel? selectedSubmission;
  final bool isGrading;
  final String searchQuery;
  final String? selectedCourseId;

  const GradingCenterState({
    this.submissions = const [],
    this.courses = const [],
    this.filter = const GradingFilter(),
    this.isLoading = false,
    this.errorMessage,
    this.statistics = const GradingStatistics(),
    this.selectedTabIndex = 0,
    this.selectedSubmission,
    this.isGrading = false,
    this.searchQuery = '',
    this.selectedCourseId,
  });

  List<AssignmentSubmissionModel> get filteredSubmissions {
    var result = submissions.toList();

    // Apply tab filter
    switch (selectedTabIndex) {
      case 0: // All
        break;
      case 1: // Ungraded
        result = result
            .where(
              (s) =>
                  s.submissionStatus == api.SubmissionStatus.submitted ||
                  s.submissionStatus == api.SubmissionStatus.resubmit,
            )
            .toList();
        break;
      case 2: // Graded
        result = result
            .where((s) => s.submissionStatus == api.SubmissionStatus.graded)
            .toList();
        break;
      case 3: // Late
        result = result.where((s) => s.isLate).toList();
        break;
    }

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result.where((s) {
        final firstName = s.user?.firstName ?? '';
        final lastName = s.user?.lastName ?? '';
        final email = s.user?.email ?? '';
        final fullName = '$firstName $lastName'.trim().toLowerCase();
        return fullName.contains(query) || email.toLowerCase().contains(query);
      }).toList();
    }

    return result;
  }

  int get allCount => submissions.length;
  int get pendingCount => submissions
      .where(
        (s) =>
            s.submissionStatus == api.SubmissionStatus.submitted ||
            s.submissionStatus == api.SubmissionStatus.resubmit,
      )
      .length;
  int get gradedCount => submissions
      .where((s) => s.submissionStatus == api.SubmissionStatus.graded)
      .length;
  int get lateCount => submissions.where((s) => s.isLate).length;

  GradingCenterState copyWith({
    List<AssignmentSubmissionModel>? submissions,
    List<InstructorCourseModel>? courses,
    GradingFilter? filter,
    bool? isLoading,
    String? errorMessage,
    GradingStatistics? statistics,
    int? selectedTabIndex,
    AssignmentSubmissionModel? selectedSubmission,
    bool? isGrading,
    String? searchQuery,
    String? selectedCourseId,
    bool clearError = false,
    bool clearSelection = false,
    bool clearCourse = false,
  }) {
    return GradingCenterState(
      submissions: submissions ?? this.submissions,
      courses: courses ?? this.courses,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      statistics: statistics ?? this.statistics,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      selectedSubmission: clearSelection
          ? null
          : (selectedSubmission ?? this.selectedSubmission),
      isGrading: isGrading ?? this.isGrading,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCourseId: clearCourse
          ? null
          : (selectedCourseId ?? this.selectedCourseId),
    );
  }

  @override
  List<Object?> get props => [
    submissions,
    courses,
    filter,
    isLoading,
    errorMessage,
    statistics,
    selectedTabIndex,
    selectedSubmission,
    isGrading,
    searchQuery,
    selectedCourseId,
  ];
}
