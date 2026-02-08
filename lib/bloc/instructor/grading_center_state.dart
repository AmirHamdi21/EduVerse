import 'package:equatable/equatable.dart';
import '../../models/instructor/grading_model.dart';
import '../../models/instructor/instructor_course_model.dart';

/// Grading center state
class GradingCenterState extends Equatable {
  final List<StudentSubmission> submissions;
  final List<InstructorCourseModel> courses;
  final GradingFilter filter;
  final bool isLoading;
  final String? errorMessage;
  final GradingStatistics statistics;
  final int selectedTabIndex;
  final StudentSubmission? selectedSubmission;
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

  List<StudentSubmission> get filteredSubmissions {
    var result = submissions.toList();

    // Apply course filter
    if (selectedCourseId != null) {
      result = result.where((s) => s.courseId == selectedCourseId).toList();
    }

    // Apply tab filter
    switch (selectedTabIndex) {
      case 0: // All
        break;
      case 1: // Pending
        result = result.where((s) => s.status == 'pending').toList();
        break;
      case 2: // Graded
        result = result.where((s) => s.status == 'graded').toList();
        break;
      case 3: // Late
        result = result.where((s) => s.status == 'late').toList();
        break;
    }

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result.where((s) =>
          s.studentName.toLowerCase().contains(query) ||
          s.assignmentTitle.toLowerCase().contains(query)).toList();
    }

    return result;
  }

  int get allCount => submissions.length;
  int get pendingCount => submissions.where((s) => s.status == 'pending').length;
  int get gradedCount => submissions.where((s) => s.status == 'graded').length;
  int get lateCount => submissions.where((s) => s.status == 'late').length;

  GradingCenterState copyWith({
    List<StudentSubmission>? submissions,
    List<InstructorCourseModel>? courses,
    GradingFilter? filter,
    bool? isLoading,
    String? errorMessage,
    GradingStatistics? statistics,
    int? selectedTabIndex,
    StudentSubmission? selectedSubmission,
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
      selectedSubmission: clearSelection ? null : (selectedSubmission ?? this.selectedSubmission),
      isGrading: isGrading ?? this.isGrading,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCourseId: clearCourse ? null : (selectedCourseId ?? this.selectedCourseId),
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
