import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/grades/grade_model.dart';
import '../../services/api/student_stats_service.dart';
import '../../services/storage_service.dart';
import 'grades_state.dart';

class GradesCubit extends Cubit<GradesState> {
  final StudentStatsService? _studentStatsService;
  final StorageService? _storageService;
  final int? _studentId;

  GradesCubit({
    StudentStatsService? studentStatsService,
    StorageService? storageService,
    int? studentId,
  }) : _studentStatsService = studentStatsService,
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
      final courses = _generateDemoCourses();
      var statistics = _calculateStatistics(courses);
      final gradeTrend = _generateGradeTrend();

      if (_studentStatsService != null) {
        final resolvedStudentId = await _resolveStudentId();
        if (resolvedStudentId != null && resolvedStudentId > 0) {
          try {
            final gpaModel = await _studentStatsService.getStudentGpa(
              resolvedStudentId,
            );

            statistics = GradeStatistics(
              cumulativeGPA: gpaModel.gpa,
              semesterGPA: gpaModel.gpa,
              totalCredits: statistics.totalCredits,
              completedCredits: statistics.completedCredits,
              totalCourses: statistics.totalCourses,
              passedCourses: statistics.passedCourses,
              highestGrade: statistics.highestGrade,
              lowestGrade: statistics.lowestGrade,
              averagePercentage: statistics.averagePercentage,
              gradeDistribution: statistics.gradeDistribution,
            );
          } catch (_) {
            // Keep demo-derived statistics when API GPA is unavailable.
          }
        }
      }

      emit(
        state.copyWith(
          courses: courses,
          semesters: semesters,
          selectedSemesterId: semesters.firstWhere((s) => s.isCurrent).id,
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
    return state.courses.where((c) => c.id == id).firstOrNull;
  }

  // Demo data generation
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
    return [
      CourseGrade(
        id: '1',
        courseCode: 'CS301',
        courseName: 'Data Structures & Algorithms',
        instructor: 'Dr. Ahmed Hassan',
        creditHours: 4,
        semesterId: 'fall_2025',
        courseColor: const Color(0xFF6366F1),
        assessments: [
          AssessmentGrade(
            id: '1_1',
            name: 'Midterm Exam',
            type: AssessmentType.midterm,
            score: 42,
            maxScore: 50,
            weight: 20,
            gradedDate: DateTime(2025, 10, 15),
            feedback: 'Good understanding of core concepts',
          ),
          AssessmentGrade(
            id: '1_2',
            name: 'Quiz 1: Arrays',
            type: AssessmentType.quiz,
            score: 9,
            maxScore: 10,
            weight: 5,
            gradedDate: DateTime(2025, 9, 20),
          ),
          AssessmentGrade(
            id: '1_3',
            name: 'Quiz 2: Linked Lists',
            type: AssessmentType.quiz,
            score: 8,
            maxScore: 10,
            weight: 5,
            gradedDate: DateTime(2025, 10, 5),
          ),
          AssessmentGrade(
            id: '1_4',
            name: 'Project: Graph Algorithms',
            type: AssessmentType.project,
            score: 45,
            maxScore: 50,
            weight: 25,
            gradedDate: DateTime(2025, 11, 20),
            feedback: 'Excellent implementation of Dijkstra\'s algorithm',
          ),
          AssessmentGrade(
            id: '1_5',
            name: 'Lab Work',
            type: AssessmentType.lab,
            score: 18,
            maxScore: 20,
            weight: 15,
            gradedDate: DateTime(2025, 11, 25),
          ),
          AssessmentGrade(
            id: '1_6',
            name: 'Final Exam',
            type: AssessmentType.finalExam,
            score: 0,
            maxScore: 100,
            weight: 30,
            isGraded: false,
          ),
        ],
      ),
      CourseGrade(
        id: '2',
        courseCode: 'CS302',
        courseName: 'Database Management Systems',
        instructor: 'Dr. Fatima Ali',
        creditHours: 3,
        semesterId: 'fall_2025',
        courseColor: const Color(0xFF10B981),
        assessments: [
          AssessmentGrade(
            id: '2_1',
            name: 'Midterm Exam',
            type: AssessmentType.midterm,
            score: 38,
            maxScore: 40,
            weight: 25,
            gradedDate: DateTime(2025, 10, 18),
            feedback: 'Excellent SQL knowledge',
          ),
          AssessmentGrade(
            id: '2_2',
            name: 'Assignment 1: ER Diagrams',
            type: AssessmentType.assignment,
            score: 19,
            maxScore: 20,
            weight: 10,
            gradedDate: DateTime(2025, 9, 25),
          ),
          AssessmentGrade(
            id: '2_3',
            name: 'Assignment 2: Normalization',
            type: AssessmentType.assignment,
            score: 18,
            maxScore: 20,
            weight: 10,
            gradedDate: DateTime(2025, 10, 30),
          ),
          AssessmentGrade(
            id: '2_4',
            name: 'Project: E-Commerce Database',
            type: AssessmentType.project,
            score: 28,
            maxScore: 30,
            weight: 25,
            gradedDate: DateTime(2025, 11, 15),
          ),
          AssessmentGrade(
            id: '2_5',
            name: 'Final Exam',
            type: AssessmentType.finalExam,
            score: 0,
            maxScore: 100,
            weight: 30,
            isGraded: false,
          ),
        ],
      ),
      CourseGrade(
        id: '3',
        courseCode: 'MATH201',
        courseName: 'Linear Algebra',
        instructor: 'Prof. Mohamed Salem',
        creditHours: 3,
        semesterId: 'fall_2025',
        courseColor: const Color(0xFFF59E0B),
        assessments: [
          AssessmentGrade(
            id: '3_1',
            name: 'Midterm Exam',
            type: AssessmentType.midterm,
            score: 35,
            maxScore: 50,
            weight: 30,
            gradedDate: DateTime(2025, 10, 12),
            feedback: 'Need more practice on matrix operations',
          ),
          AssessmentGrade(
            id: '3_2',
            name: 'Quiz 1',
            type: AssessmentType.quiz,
            score: 7,
            maxScore: 10,
            weight: 5,
            gradedDate: DateTime(2025, 9, 18),
          ),
          AssessmentGrade(
            id: '3_3',
            name: 'Quiz 2',
            type: AssessmentType.quiz,
            score: 8,
            maxScore: 10,
            weight: 5,
            gradedDate: DateTime(2025, 10, 2),
          ),
          AssessmentGrade(
            id: '3_4',
            name: 'Homework Assignments',
            type: AssessmentType.assignment,
            score: 22,
            maxScore: 30,
            weight: 20,
            gradedDate: DateTime(2025, 11, 10),
          ),
          AssessmentGrade(
            id: '3_5',
            name: 'Final Exam',
            type: AssessmentType.finalExam,
            score: 0,
            maxScore: 100,
            weight: 40,
            isGraded: false,
          ),
        ],
      ),
      CourseGrade(
        id: '4',
        courseCode: 'CS303',
        courseName: 'Software Engineering',
        instructor: 'Dr. Sarah Johnson',
        creditHours: 3,
        semesterId: 'fall_2025',
        courseColor: const Color(0xFF8B5CF6),
        assessments: [
          AssessmentGrade(
            id: '4_1',
            name: 'Midterm Exam',
            type: AssessmentType.midterm,
            score: 43,
            maxScore: 50,
            weight: 20,
            gradedDate: DateTime(2025, 10, 20),
          ),
          AssessmentGrade(
            id: '4_2',
            name: 'Team Project: Agile Sprint 1',
            type: AssessmentType.project,
            score: 27,
            maxScore: 30,
            weight: 15,
            gradedDate: DateTime(2025, 10, 1),
            feedback: 'Good teamwork and communication',
          ),
          AssessmentGrade(
            id: '4_3',
            name: 'Team Project: Agile Sprint 2',
            type: AssessmentType.project,
            score: 28,
            maxScore: 30,
            weight: 15,
            gradedDate: DateTime(2025, 11, 1),
          ),
          AssessmentGrade(
            id: '4_4',
            name: 'Presentation: Design Patterns',
            type: AssessmentType.presentation,
            score: 18,
            maxScore: 20,
            weight: 10,
            gradedDate: DateTime(2025, 11, 15),
          ),
          AssessmentGrade(
            id: '4_5',
            name: 'Final Project',
            type: AssessmentType.project,
            score: 0,
            maxScore: 100,
            weight: 40,
            isGraded: false,
          ),
        ],
      ),
      CourseGrade(
        id: '5',
        courseCode: 'CS205',
        courseName: 'Operating Systems',
        instructor: 'Dr. Omar Khalid',
        creditHours: 4,
        semesterId: 'fall_2025',
        courseColor: const Color(0xFFEF4444),
        assessments: [
          AssessmentGrade(
            id: '5_1',
            name: 'Midterm Exam',
            type: AssessmentType.midterm,
            score: 28,
            maxScore: 50,
            weight: 25,
            gradedDate: DateTime(2025, 10, 22),
            feedback: 'Review process scheduling concepts',
          ),
          AssessmentGrade(
            id: '5_2',
            name: 'Lab 1: Process Management',
            type: AssessmentType.lab,
            score: 14,
            maxScore: 20,
            weight: 10,
            gradedDate: DateTime(2025, 9, 28),
          ),
          AssessmentGrade(
            id: '5_3',
            name: 'Lab 2: Memory Management',
            type: AssessmentType.lab,
            score: 12,
            maxScore: 20,
            weight: 10,
            gradedDate: DateTime(2025, 10, 28),
          ),
          AssessmentGrade(
            id: '5_4',
            name: 'Assignment: Shell Implementation',
            type: AssessmentType.assignment,
            score: 16,
            maxScore: 25,
            weight: 15,
            gradedDate: DateTime(2025, 11, 5),
          ),
          AssessmentGrade(
            id: '5_5',
            name: 'Final Exam',
            type: AssessmentType.finalExam,
            score: 0,
            maxScore: 100,
            weight: 40,
            isGraded: false,
          ),
        ],
      ),
      // Previous semester courses
      CourseGrade(
        id: '6',
        courseCode: 'CS201',
        courseName: 'Object-Oriented Programming',
        instructor: 'Dr. Ahmed Hassan',
        creditHours: 4,
        semesterId: 'spring_2025',
        courseColor: const Color(0xFF3B82F6),
        assessments: [
          AssessmentGrade(
            id: '6_1',
            name: 'Midterm Exam',
            type: AssessmentType.midterm,
            score: 45,
            maxScore: 50,
            weight: 25,
            gradedDate: DateTime(2025, 3, 15),
          ),
          AssessmentGrade(
            id: '6_2',
            name: 'Final Exam',
            type: AssessmentType.finalExam,
            score: 88,
            maxScore: 100,
            weight: 35,
            gradedDate: DateTime(2025, 5, 10),
          ),
          AssessmentGrade(
            id: '6_3',
            name: 'Projects',
            type: AssessmentType.project,
            score: 38,
            maxScore: 40,
            weight: 30,
            gradedDate: DateTime(2025, 4, 25),
          ),
          AssessmentGrade(
            id: '6_4',
            name: 'Participation',
            type: AssessmentType.participation,
            score: 9,
            maxScore: 10,
            weight: 10,
            gradedDate: DateTime(2025, 5, 1),
          ),
        ],
      ),
      CourseGrade(
        id: '7',
        courseCode: 'CS202',
        courseName: 'Computer Architecture',
        instructor: 'Prof. Layla Abbas',
        creditHours: 3,
        semesterId: 'spring_2025',
        courseColor: const Color(0xFF14B8A6),
        assessments: [
          AssessmentGrade(
            id: '7_1',
            name: 'Midterm Exam',
            type: AssessmentType.midterm,
            score: 40,
            maxScore: 50,
            weight: 30,
            gradedDate: DateTime(2025, 3, 18),
          ),
          AssessmentGrade(
            id: '7_2',
            name: 'Final Exam',
            type: AssessmentType.finalExam,
            score: 82,
            maxScore: 100,
            weight: 40,
            gradedDate: DateTime(2025, 5, 12),
          ),
          AssessmentGrade(
            id: '7_3',
            name: 'Lab Work',
            type: AssessmentType.lab,
            score: 27,
            maxScore: 30,
            weight: 30,
            gradedDate: DateTime(2025, 4, 28),
          ),
        ],
      ),
    ];
  }

  GradeStatistics _calculateStatistics(List<CourseGrade> courses) {
    if (courses.isEmpty) {
      return const GradeStatistics(
        cumulativeGPA: 0,
        semesterGPA: 0,
        totalCredits: 0,
        completedCredits: 0,
        totalCourses: 0,
        passedCourses: 0,
        highestGrade: GradeLetter.pending,
        lowestGrade: GradeLetter.pending,
        averagePercentage: 0,
        gradeDistribution: {},
      );
    }

    double totalGpaPoints = 0;
    int totalCredits = 0;
    int completedCredits = 0;
    int passedCourses = 0;
    GradeLetter? highest;
    GradeLetter? lowest;
    double totalPercentage = 0;
    final Map<GradeLetter, int> distribution = {};

    for (final course in courses) {
      if (course.gradedCount > 0) {
        final grade = course.currentGrade;
        totalGpaPoints += grade.gpa * course.creditHours;
        totalCredits += course.creditHours;

        if (course.pendingCount == 0) {
          completedCredits += course.creditHours;
        }

        if (course.currentPercentage >= 60) {
          passedCourses++;
        }

        totalPercentage += course.currentPercentage;

        distribution[grade] = (distribution[grade] ?? 0) + 1;

        if (highest == null || grade.gpa > highest.gpa) {
          highest = grade;
        }
        if (lowest == null || grade.gpa < lowest.gpa) {
          lowest = grade;
        }
      }
    }

    return GradeStatistics(
      cumulativeGPA: totalCredits > 0 ? totalGpaPoints / totalCredits : 0,
      semesterGPA: totalCredits > 0 ? totalGpaPoints / totalCredits : 0,
      totalCredits: totalCredits,
      completedCredits: completedCredits,
      totalCourses: courses.length,
      passedCourses: passedCourses,
      highestGrade: highest ?? GradeLetter.pending,
      lowestGrade: lowest ?? GradeLetter.pending,
      averagePercentage: courses.isNotEmpty
          ? totalPercentage / courses.length
          : 0,
      gradeDistribution: distribution,
    );
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
