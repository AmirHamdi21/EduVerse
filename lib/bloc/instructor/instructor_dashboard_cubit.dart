import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/instructor/instructor_course_model.dart';
import 'instructor_dashboard_state.dart';

class InstructorDashboardCubit extends Cubit<InstructorDashboardState> {
  InstructorDashboardCubit() : super(const InstructorDashboardState()) {
    loadDashboardData();
  }

  /// Load dashboard data
  Future<void> loadDashboardData() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final courses = _generateDemoCourses();
      final stats = _calculateStats(courses);

      emit(
        state.copyWith(
          courses: courses,
          isLoading: false,
          totalStudents: stats['totalStudents'] as int,
          pendingAssignments: stats['pendingAssignments'] as int,
          pendingQuizzes: stats['pendingQuizzes'] as int,
          unreadMessages: stats['unreadMessages'] as int,
          overallProgress: stats['overallProgress'] as double,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load dashboard: $e',
        ),
      );
    }
  }

  /// Refresh dashboard data
  Future<void> refreshDashboard() async {
    await loadDashboardData();
  }

  /// Set filter
  void setFilter(DashboardFilter filter) {
    emit(state.copyWith(filter: filter));
  }

  /// Set search query
  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  /// Clear error
  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  /// Get course by ID
  InstructorCourseModel? getCourseById(String id) {
    return state.courses.where((c) => c.id == id).firstOrNull;
  }

  // Demo data generation
  List<InstructorCourseModel> _generateDemoCourses() {
    return [
      InstructorCourseModel(
        id: '1',
        code: 'CS101',
        name: 'Operating Systems',
        description: 'Introduction to operating system concepts and design',
        totalStudents: 45,
        progress: 67,
        colorValue: 0xFF6366F1,
        courseIcon: Icons.computer,
        newItems: 3,
        activeQuizzes: 2,
        unreadMessages: 5,
        semester: 'Fall 2025',
        isActive: true,
        nextClass: DateTime.now().add(const Duration(hours: 2)),
        nextClassLocation: 'Room 301, Building A',
      ),
      InstructorCourseModel(
        id: '2',
        code: 'CS202',
        name: 'Data Structures & Algorithms',
        description: 'Fundamental data structures and algorithmic techniques',
        totalStudents: 38,
        progress: 72,
        colorValue: 0xFF10B981,
        courseIcon: Icons.account_tree,
        newItems: 1,
        activeQuizzes: 1,
        unreadMessages: 2,
        semester: 'Fall 2025',
        isActive: true,
        nextClass: DateTime.now().add(const Duration(days: 1)),
        nextClassLocation: 'Room 205, Building B',
      ),
      InstructorCourseModel(
        id: '3',
        code: 'CS305',
        name: 'Database Management Systems',
        description: 'Database design, SQL, and management systems',
        totalStudents: 52,
        progress: 55,
        colorValue: 0xFFF59E0B,
        courseIcon: Icons.storage,
        newItems: 2,
        activeQuizzes: 3,
        unreadMessages: 8,
        semester: 'Fall 2025',
        isActive: true,
        nextClass: DateTime.now().add(const Duration(days: 2)),
        nextClassLocation: 'Lab 102',
      ),
      InstructorCourseModel(
        id: '4',
        code: 'CS410',
        name: 'Machine Learning Fundamentals',
        description:
            'Introduction to machine learning algorithms and applications',
        totalStudents: 29,
        progress: 81,
        colorValue: 0xFF8B5CF6,
        courseIcon: Icons.psychology,
        newItems: 0,
        activeQuizzes: 0,
        unreadMessages: 1,
        semester: 'Fall 2025',
        isActive: false,
        nextClass: DateTime.now().add(const Duration(days: 3)),
        nextClassLocation: 'Room 401, Building C',
      ),
    ];
  }

  Map<String, dynamic> _calculateStats(List<InstructorCourseModel> courses) {
    int totalStudents = 0;
    int pendingAssignments = 0;
    int pendingQuizzes = 0;
    int unreadMessages = 0;
    int totalProgress = 0;

    for (final course in courses) {
      totalStudents += course.totalStudents;
      pendingAssignments += course.assignments.where((a) => !a.isGraded).length;
      pendingQuizzes += course.activeQuizzes;
      unreadMessages += course.unreadMessages;
      totalProgress += course.progress;
    }

    return {
      'totalStudents': totalStudents,
      'pendingAssignments': pendingAssignments,
      'pendingQuizzes': pendingQuizzes,
      'unreadMessages': unreadMessages,
      'overallProgress': courses.isNotEmpty
          ? totalProgress / courses.length
          : 0.0,
    };
  }
}
