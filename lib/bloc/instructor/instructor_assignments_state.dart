import 'package:equatable/equatable.dart';

import '../../models/assignments/assignment_model.dart';
import '../../models/assignments/assignment_submission_model.dart';
import '../../models/core/enums/assignment_enums.dart' as api;
import '../../models/core/paginated_response.dart';
import '../../models/instructor/teaching_course_model.dart';

class InstructorAssignmentsState extends Equatable {
  final bool isLoading;
  final bool submissionsLoading;
  final String? errorMessage;
  final List<TeachingCourseModel> teachingCourses;
  final int? selectedCourseId;
  final PaginatedResponse<AssignmentModel>? assignments;
  final api.AssignmentStatus? statusFilter;
  final String searchQuery;
  final int currentPage;
  final bool hasMorePages;
  final List<AssignmentSubmissionModel> submissions;
  final AssignmentSubmissionModel? selectedSubmission;
  final int submissionsPage;
  final bool hasMoreSubmissions;
  final int? activeSubmissionsAssignmentId;

  const InstructorAssignmentsState({
    this.isLoading = false,
    this.submissionsLoading = false,
    this.errorMessage,
    this.teachingCourses = const <TeachingCourseModel>[],
    this.selectedCourseId,
    this.assignments,
    this.statusFilter,
    this.searchQuery = '',
    this.currentPage = 1,
    this.hasMorePages = false,
    this.submissions = const <AssignmentSubmissionModel>[],
    this.selectedSubmission,
    this.submissionsPage = 1,
    this.hasMoreSubmissions = false,
    this.activeSubmissionsAssignmentId,
  });

  List<AssignmentModel> get assignmentItems {
    final base = assignments?.data ?? const <AssignmentModel>[];

    final statusFiltered = statusFilter == null
        ? base
        : base.where((item) => item.apiStatus == statusFilter).toList();

    if (searchQuery.trim().isEmpty) {
      return statusFiltered;
    }

    final query = searchQuery.toLowerCase();
    return statusFiltered
        .where(
          (item) =>
              item.title.toLowerCase().contains(query) ||
              (item.description?.toLowerCase().contains(query) ?? false),
        )
        .toList();
  }

  InstructorAssignmentsState copyWith({
    bool? isLoading,
    bool? submissionsLoading,
    String? errorMessage,
    List<TeachingCourseModel>? teachingCourses,
    int? selectedCourseId,
    PaginatedResponse<AssignmentModel>? assignments,
    api.AssignmentStatus? statusFilter,
    String? searchQuery,
    int? currentPage,
    bool? hasMorePages,
    List<AssignmentSubmissionModel>? submissions,
    AssignmentSubmissionModel? selectedSubmission,
    int? submissionsPage,
    bool? hasMoreSubmissions,
    int? activeSubmissionsAssignmentId,
    bool clearError = false,
    bool clearSelectedCourse = false,
    bool clearSelectedSubmission = false,
    bool clearAssignments = false,
    bool clearSubmissions = false,
    bool clearActiveSubmissionsAssignment = false,
    bool clearStatusFilter = false,
  }) {
    return InstructorAssignmentsState(
      isLoading: isLoading ?? this.isLoading,
      submissionsLoading: submissionsLoading ?? this.submissionsLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      teachingCourses: teachingCourses ?? this.teachingCourses,
      selectedCourseId: clearSelectedCourse
          ? null
          : (selectedCourseId ?? this.selectedCourseId),
      assignments: clearAssignments ? null : (assignments ?? this.assignments),
      statusFilter: clearStatusFilter
          ? null
          : (statusFilter ?? this.statusFilter),
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      submissions: clearSubmissions
          ? const <AssignmentSubmissionModel>[]
          : (submissions ?? this.submissions),
      selectedSubmission: clearSelectedSubmission
          ? null
          : (selectedSubmission ?? this.selectedSubmission),
      submissionsPage: submissionsPage ?? this.submissionsPage,
      hasMoreSubmissions: hasMoreSubmissions ?? this.hasMoreSubmissions,
      activeSubmissionsAssignmentId: clearActiveSubmissionsAssignment
          ? null
          : (activeSubmissionsAssignmentId ??
                this.activeSubmissionsAssignmentId),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    isLoading,
    submissionsLoading,
    errorMessage,
    teachingCourses,
    selectedCourseId,
    assignments,
    statusFilter,
    searchQuery,
    currentPage,
    hasMorePages,
    submissions,
    selectedSubmission,
    submissionsPage,
    hasMoreSubmissions,
    activeSubmissionsAssignmentId,
  ];
}
