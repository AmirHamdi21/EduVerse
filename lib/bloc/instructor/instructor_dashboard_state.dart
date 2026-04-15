import 'package:equatable/equatable.dart';
import '../../models/instructor/instructor_course_model.dart';

/// Dashboard filter options
enum DashboardFilter { all, active, completed }

/// Dashboard state
class InstructorDashboardState extends Equatable {
  final List<InstructorCourseModel> courses;
  final DashboardFilter filter;
  final String searchQuery;
  final bool isLoading;
  final String? errorMessage;
  final int totalStudents;
  final int pendingAssignments;
  final int pendingQuizzes;
  final int unreadMessages;
  final double overallProgress;

  const InstructorDashboardState({
    this.courses = const [],
    this.filter = DashboardFilter.all,
    this.searchQuery = '',
    this.isLoading = false,
    this.errorMessage,
    this.totalStudents = 0,
    this.pendingAssignments = 0,
    this.pendingQuizzes = 0,
    this.unreadMessages = 0,
    this.overallProgress = 0,
  });

  List<InstructorCourseModel> get filteredCourses {
    var result = courses.toList();

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result
          .where(
            (c) =>
                c.name.toLowerCase().contains(query) ||
                c.code.toLowerCase().contains(query),
          )
          .toList();
    }

    // Apply status filter
    switch (filter) {
      case DashboardFilter.active:
        result = result.where((c) => c.isActive).toList();
        break;
      case DashboardFilter.completed:
        result = result.where((c) => !c.isActive).toList();
        break;
      case DashboardFilter.all:
        break;
    }

    return result;
  }

  InstructorDashboardState copyWith({
    List<InstructorCourseModel>? courses,
    DashboardFilter? filter,
    String? searchQuery,
    bool? isLoading,
    String? errorMessage,
    int? totalStudents,
    int? pendingAssignments,
    int? pendingQuizzes,
    int? unreadMessages,
    double? overallProgress,
    bool clearError = false,
  }) {
    return InstructorDashboardState(
      courses: courses ?? this.courses,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      totalStudents: totalStudents ?? this.totalStudents,
      pendingAssignments: pendingAssignments ?? this.pendingAssignments,
      pendingQuizzes: pendingQuizzes ?? this.pendingQuizzes,
      unreadMessages: unreadMessages ?? this.unreadMessages,
      overallProgress: overallProgress ?? this.overallProgress,
    );
  }

  @override
  List<Object?> get props => [
    courses,
    filter,
    searchQuery,
    isLoading,
    errorMessage,
    totalStudents,
    pendingAssignments,
    pendingQuizzes,
    unreadMessages,
    overallProgress,
  ];
}
