import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/grades/grade_model.dart';
import '../../services/api/grades_normalizer.dart';
import '../../services/api/grades_service.dart';
import '../../services/api/student_stats_service.dart';
import '../../services/storage_service.dart';
import 'grades_state.dart';

class GradesCubit extends Cubit<GradesState> {
  final GradesService? _gradesService;
  final StudentStatsService? _studentStatsService;
  final StorageService? _storageService;
  final int? _studentId;

  GradesCubit({
    GradesService? gradesService,
    StudentStatsService? studentStatsService,
    StorageService? storageService,
    int? studentId,
  }) : _gradesService = gradesService,
       _studentStatsService = studentStatsService,
       _storageService = storageService,
       _studentId = studentId,
       super(const GradesState()) {
    loadGrades();
  }

  /// Load grades data
  Future<void> loadGrades() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final semesters = _generateDemoSemesters();
      var courses = await _loadCoursesFromApi();
      courses = courses.isEmpty ? _generateDemoCourses() : courses;

      var statistics = GradesNormalizer.computeStatistics(courses);
      final gradeTrend = _generateGradeTrend();

      final resolvedStudentId = await _resolveStudentId();
      final resolvedGpa = await _resolveStudentGpa(resolvedStudentId);
      if (resolvedGpa != null) {
        statistics = GradeStatistics(
          cumulativeGPA: resolvedGpa,
          semesterGPA: resolvedGpa,
          totalCredits: statistics.totalCredits,
          completedCredits: statistics.completedCredits,
          totalCourses: statistics.totalCourses,
          passedCourses: statistics.passedCourses,
          highestGrade: statistics.highestGrade,
          lowestGrade: statistics.lowestGrade,
          averagePercentage: statistics.averagePercentage,
          gradeDistribution: statistics.gradeDistribution,
        );
      }

      final selectedSemesterId = _resolveSelectedSemesterId(semesters, courses);

      emit(
        state.copyWith(
          courses: courses,
          semesters: semesters,
          selectedSemesterId: selectedSemesterId,
          statistics: statistics,
          gradeTrend: gradeTrend,
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load grades: $e',
        ),
      );
    }
  }

  /// Refresh grades data
  Future<void> refreshGrades() async {
    await loadGrades();
  }

  /// Set selected tab
  void setSelectedTab(int index) {
    emit(state.copyWith(selectedTabIndex: index));
  }

  /// Set selected semester
  void setSelectedSemester(String? semesterId) {
    emit(
      state.copyWith(
        selectedSemesterId: semesterId,
        clearSemester: semesterId == null,
      ),
    );
  }

  /// Set search query
  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  /// Set filter
  void setFilter(GradesFilter filter) {
    emit(state.copyWith(filter: filter));
  }

  /// Set sort
  void setSortBy(GradesSortBy sortBy) {
    if (state.sortBy == sortBy) {
      emit(state.copyWith(sortAscending: !state.sortAscending));
    } else {
      emit(state.copyWith(sortBy: sortBy, sortAscending: true));
    }
  }

  /// Set view mode
  void setViewMode(GradesViewMode mode) {
    emit(state.copyWith(viewMode: mode));
  }

  /// Clear error
  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  /// Set PDF generating state
  void setGeneratingPdf(bool generating) {
    emit(state.copyWith(isGeneratingPdf: generating));
  }

  /// Reset filters
  void resetFilters() {
    emit(
      state.copyWith(
        filter: GradesFilter.all,
        sortBy: GradesSortBy.name,
        sortAscending: true,
        searchQuery: '',
      ),
    );
  }

  /// Get course by ID
  CourseGrade? getCourseById(String id) {
    for (final course in state.courses) {
      if (course.id == id) {
        return course;
      }
    }
    return null;
  }

  Future<List<CourseGrade>> _loadCoursesFromApi() async {
    if (_gradesService == null) {
      return const <CourseGrade>[];
    }

    final result = await _gradesService!.getMyGrades();
    if (result.isSuccess && result.data != null) {
      return GradesNormalizer.groupByCourse(result.data!);
    }

    return const <CourseGrade>[];
  }

  String? _resolveSelectedSemesterId(
    List<SemesterModel> semesters,
    List<CourseGrade> courses,
  ) {
    if (semesters.isEmpty) {
      return null;
    }

    SemesterModel? selected;
    for (final semester in semesters) {
      if (semester.isCurrent) {
        selected = semester;
        break;
      }
    }

    selected ??= semesters.first;

    final hasCoursesForSelected = courses.any(
      (course) => course.semesterId == selected!.id,
    );

    if (hasCoursesForSelected) {
      return selected.id;
    }

    if (courses.isNotEmpty) {
      return courses.first.semesterId;
    }

    return selected.id;
  }

  Future<double?> _resolveStudentGpa(int? resolvedStudentId) async {
    if (resolvedStudentId == null || resolvedStudentId <= 0) {
      return null;
    }

    if (_gradesService != null) {
      final gpaResult = await _gradesService!.getStudentGpa(resolvedStudentId);
      if (gpaResult.isSuccess && gpaResult.data != null) {
        return gpaResult.data!.gpa;
      }
    }

    if (_studentStatsService != null) {
      try {
        final gpaModel = await _studentStatsService.getStudentGpa(
          resolvedStudentId,
        );
        return gpaModel.gpa;
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  // Demo data generation fallback
  List<SemesterModel> _generateDemoSemesters() {
    return [
      SemesterModel(
        id: 'fall_2025',
        name: 'Fall',
        year: '2025',
        isCurrent: true,
        startDate: DateTime(2025, 9, 1),
        endDate: DateTime(2025, 12, 20),
      ),
      SemesterModel(
        id: 'spring_2025',
        name: 'Spring',
        year: '2025',
        startDate: DateTime(2025, 1, 15),
        endDate: DateTime(2025, 5, 15),
      ),
      SemesterModel(
        id: 'fall_2024',
        name: 'Fall',
        year: '2024',
        startDate: DateTime(2024, 9, 1),
        endDate: DateTime(2024, 12, 20),
      ),
      SemesterModel(
        id: 'spring_2024',
        name: 'Spring',
        year: '2024',
        startDate: DateTime(2024, 1, 15),
        endDate: DateTime(2024, 5, 15),
      ),
    ];
  }

  List<CourseGrade> _generateDemoCourses() {
    return const <CourseGrade>[];
  }

  GradeStatistics _calculateStatistics(List<CourseGrade> courses) {
    return GradesNormalizer.computeStatistics(courses);
  }

  List<GradeTrendPoint> _generateGradeTrend() {
    return [
      const GradeTrendPoint(
        semesterName: 'Fall \'23',
        gpa: 3.2,
        creditHours: 15,
      ),
      const GradeTrendPoint(
        semesterName: 'Spring \'24',
        gpa: 3.4,
        creditHours: 16,
      ),
      const GradeTrendPoint(
        semesterName: 'Fall \'24',
        gpa: 3.5,
        creditHours: 17,
      ),
      const GradeTrendPoint(
        semesterName: 'Spring \'25',
        gpa: 3.6,
        creditHours: 15,
      ),
      const GradeTrendPoint(
        semesterName: 'Fall \'25',
        gpa: 3.55,
        creditHours: 17,
      ),
    ];
  }

  Future<int?> _resolveStudentId() async {
    final configuredStudentId = _studentId;
    if (configuredStudentId != null && configuredStudentId > 0) {
      return configuredStudentId;
    }

    if (_storageService == null) {
      return null;
    }

    final user = await _storageService.getUserData();
    if (user == null || user.userId <= 0) {
      return null;
    }

    return user.userId;
  }
}
