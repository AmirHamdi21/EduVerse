import 'package:equatable/equatable.dart';
import '../../models/instructor/instructor_course_model.dart';
import '../../models/instructor/teaching_course_model.dart';

enum RosterStatus { initial, loading, loaded, error }

class RosterState extends Equatable {
  final List<TeachingCourseModel> courses;
  final int? selectedSectionId;
  final List<SectionStudentModel> students;
  final String searchQuery;
  final RosterStatus coursesStatus;
  final RosterStatus studentsStatus;
  final String? errorMessage;

  const RosterState({
    this.courses = const [],
    this.selectedSectionId,
    this.students = const [],
    this.searchQuery = '',
    this.coursesStatus = RosterStatus.initial,
    this.studentsStatus = RosterStatus.initial,
    this.errorMessage,
  });

  /// Filtered students based on search query
  List<SectionStudentModel> get filteredStudents {
    if (searchQuery.isEmpty) return students;
    final query = searchQuery.toLowerCase();
    return students.where((s) {
      return s.displayName.toLowerCase().contains(query) ||
          (s.email?.toLowerCase().contains(query) ?? false) ||
          s.status.toLowerCase().contains(query);
    }).toList();
  }

  /// Total students across all courses
  int get totalStudents {
    return courses.fold(0, (sum, c) => sum + c.enrolledCount);
  }

  /// Currently selected course (for UI display)
  TeachingCourseModel? get selectedCourse {
    if (selectedSectionId == null) return null;
    try {
      return courses.firstWhere((c) => c.sectionId == selectedSectionId);
    } catch (_) {
      return null;
    }
  }

  RosterState copyWith({
    List<TeachingCourseModel>? courses,
    int? selectedSectionId,
    bool clearSelectedSection = false,
    List<SectionStudentModel>? students,
    String? searchQuery,
    RosterStatus? coursesStatus,
    RosterStatus? studentsStatus,
    String? errorMessage,
  }) {
    return RosterState(
      courses: courses ?? this.courses,
      selectedSectionId: clearSelectedSection
          ? null
          : (selectedSectionId ?? this.selectedSectionId),
      students: students ?? this.students,
      searchQuery: searchQuery ?? this.searchQuery,
      coursesStatus: coursesStatus ?? this.coursesStatus,
      studentsStatus: studentsStatus ?? this.studentsStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    courses,
    selectedSectionId,
    students,
    searchQuery,
    coursesStatus,
    studentsStatus,
    errorMessage,
  ];
}
