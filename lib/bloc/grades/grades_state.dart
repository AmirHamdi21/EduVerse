import 'package:equatable/equatable.dart';
import '../../models/grades/grade_model.dart';

/// Filter options for grades
enum GradesFilter { all, excellent, good, average, poor }

extension GradesFilterExtension on GradesFilter {
  String get label {
    switch (this) {
      case GradesFilter.all: return 'All';
      case GradesFilter.excellent: return 'Excellent (A)';
      case GradesFilter.good: return 'Good (B)';
      case GradesFilter.average: return 'Average (C)';
      case GradesFilter.poor: return 'Below Average';
    }
  }

  bool matches(CourseGrade course) {
    switch (this) {
      case GradesFilter.all:
        return true;
      case GradesFilter.excellent:
        return course.currentPercentage >= 90;
      case GradesFilter.good:
        return course.currentPercentage >= 80 && course.currentPercentage < 90;
      case GradesFilter.average:
        return course.currentPercentage >= 70 && course.currentPercentage < 80;
      case GradesFilter.poor:
        return course.currentPercentage < 70;
    }
  }
}

/// Sort options for grades
enum GradesSortBy { name, grade, credits, recent }

extension GradesSortByExtension on GradesSortBy {
  String get label {
    switch (this) {
      case GradesSortBy.name: return 'Name';
      case GradesSortBy.grade: return 'Grade';
      case GradesSortBy.credits: return 'Credits';
      case GradesSortBy.recent: return 'Recent';
    }
  }
}

/// View mode for grades screen
enum GradesViewMode { list, grid, compact }

/// Grades state
class GradesState extends Equatable {
  final List<CourseGrade> courses;
  final List<SemesterModel> semesters;
  final String? selectedSemesterId;
  final GradesFilter filter;
  final GradesSortBy sortBy;
  final bool sortAscending;
  final GradesViewMode viewMode;
  final String searchQuery;
  final bool isLoading;
  final String? errorMessage;
  final GradeStatistics? statistics;
  final List<GradeTrendPoint> gradeTrend;
  final int selectedTabIndex;
  final bool isGeneratingPdf;

  const GradesState({
    this.courses = const [],
    this.semesters = const [],
    this.selectedSemesterId,
    this.filter = GradesFilter.all,
    this.sortBy = GradesSortBy.name,
    this.sortAscending = true,
    this.viewMode = GradesViewMode.list,
    this.searchQuery = '',
    this.isLoading = false,
    this.errorMessage,
    this.statistics,
    this.gradeTrend = const [],
    this.selectedTabIndex = 0,
    this.isGeneratingPdf = false,
  });

  /// Get filtered and sorted courses
  List<CourseGrade> get filteredCourses {
    var result = courses.toList();

    // Filter by semester
    if (selectedSemesterId != null) {
      result = result.where((c) => c.semesterId == selectedSemesterId).toList();
    }

    // Apply tab filter (0=All, 1=In Progress, 2=Completed, 3=Need Attention)
    switch (selectedTabIndex) {
      case 1: // In Progress
        result = result.where((c) => c.pendingCount > 0).toList();
        break;
      case 2: // Completed
        result = result.where((c) => c.pendingCount == 0).toList();
        break;
      case 3: // Need Attention
        result = result.where((c) => c.currentPercentage < 70).toList();
        break;
    }

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result.where((c) =>
          c.courseName.toLowerCase().contains(query) ||
          c.courseCode.toLowerCase().contains(query) ||
          c.instructor.toLowerCase().contains(query)).toList();
    }

    // Apply grade filter
    result = result.where((c) => filter.matches(c)).toList();

    // Apply sorting
    result.sort((a, b) {
      int comparison;
      switch (sortBy) {
        case GradesSortBy.name:
          comparison = a.courseName.compareTo(b.courseName);
          break;
        case GradesSortBy.grade:
          comparison = b.currentPercentage.compareTo(a.currentPercentage);
          break;
        case GradesSortBy.credits:
          comparison = b.creditHours.compareTo(a.creditHours);
          break;
        case GradesSortBy.recent:
          final aDate = a.assessments.isNotEmpty && a.assessments.last.gradedDate != null
              ? a.assessments.last.gradedDate!
              : DateTime(2000);
          final bDate = b.assessments.isNotEmpty && b.assessments.last.gradedDate != null
              ? b.assessments.last.gradedDate!
              : DateTime(2000);
          comparison = bDate.compareTo(aDate);
          break;
      }
      return sortAscending ? comparison : -comparison;
    });

    return result;
  }

  /// Get current semester
  SemesterModel? get currentSemester =>
      semesters.where((s) => s.isCurrent).firstOrNull;

  /// Get selected semester
  SemesterModel? get selectedSemester => selectedSemesterId != null
      ? semesters.where((s) => s.id == selectedSemesterId).firstOrNull
      : currentSemester;

  /// Get counts for tabs
  int get allCount => courses.length;
  int get inProgressCount => courses.where((c) => c.pendingCount > 0).length;
  int get completedCount => courses.where((c) => c.pendingCount == 0).length;
  int get needAttentionCount => courses.where((c) => c.currentPercentage < 70).length;

  /// Calculate GPA for selected semester
  double get semesterGPA {
    final semesterCourses = selectedSemesterId != null
        ? courses.where((c) => c.semesterId == selectedSemesterId).toList()
        : courses;
    
    if (semesterCourses.isEmpty) return 0;
    
    double totalPoints = 0;
    int totalCredits = 0;
    
    for (final course in semesterCourses) {
      if (course.gradedCount > 0) {
        totalPoints += course.currentGrade.gpa * course.creditHours;
        totalCredits += course.creditHours;
      }
    }
    
    return totalCredits > 0 ? totalPoints / totalCredits : 0;
  }

  GradesState copyWith({
    List<CourseGrade>? courses,
    List<SemesterModel>? semesters,
    String? selectedSemesterId,
    GradesFilter? filter,
    GradesSortBy? sortBy,
    bool? sortAscending,
    GradesViewMode? viewMode,
    String? searchQuery,
    bool? isLoading,
    String? errorMessage,
    GradeStatistics? statistics,
    List<GradeTrendPoint>? gradeTrend,
    int? selectedTabIndex,
    bool? isGeneratingPdf,
    bool clearError = false,
    bool clearSemester = false,
  }) {
    return GradesState(
      courses: courses ?? this.courses,
      semesters: semesters ?? this.semesters,
      selectedSemesterId: clearSemester ? null : (selectedSemesterId ?? this.selectedSemesterId),
      filter: filter ?? this.filter,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      viewMode: viewMode ?? this.viewMode,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      statistics: statistics ?? this.statistics,
      gradeTrend: gradeTrend ?? this.gradeTrend,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      isGeneratingPdf: isGeneratingPdf ?? this.isGeneratingPdf,
    );
  }

  @override
  List<Object?> get props => [
        courses,
        semesters,
        selectedSemesterId,
        filter,
        sortBy,
        sortAscending,
        viewMode,
        searchQuery,
        isLoading,
        errorMessage,
        statistics,
        gradeTrend,
        selectedTabIndex,
        isGeneratingPdf,
      ];
}
