import 'package:equatable/equatable.dart';

import '../../models/instructor/instructor_course_model.dart';
import '../../models/instructor/teaching_course_model.dart';

enum RosterStatus { initial, loading, loaded, error }

enum RosterSortField { studentId, enrollmentDate, status }

enum RosterSortDirection { asc, desc }

enum RosterViewMode { overview, detailedGrades }

class RosterState extends Equatable {
  final List<TeachingCourseModel> courses;
  final int? selectedSectionId;
  final List<SectionStudentModel> students;
  final String searchQuery;
  final RosterStatus coursesStatus;
  final RosterStatus studentsStatus;
  final String? errorMessage;
  final RosterSortField sortField;
  final RosterSortDirection sortDirection;
  final RosterViewMode viewMode;
  final Map<String, String> notesByKey;
  final String? instructorName;
  final String? instructorEmail;

  const RosterState({
    this.courses = const <TeachingCourseModel>[],
    this.selectedSectionId,
    this.students = const <SectionStudentModel>[],
    this.searchQuery = '',
    this.coursesStatus = RosterStatus.initial,
    this.studentsStatus = RosterStatus.initial,
    this.errorMessage,
    this.sortField = RosterSortField.studentId,
    this.sortDirection = RosterSortDirection.asc,
    this.viewMode = RosterViewMode.overview,
    this.notesByKey = const <String, String>{},
    this.instructorName,
    this.instructorEmail,
  });

  TeachingCourseModel? get selectedCourse {
    if (selectedSectionId == null) {
      return null;
    }
    try {
      return courses.firstWhere((c) => c.sectionId == selectedSectionId);
    } catch (_) {
      return null;
    }
  }

  int get totalStudents {
    return courses.fold<int>(0, (sum, course) => sum + course.enrolledCount);
  }

  List<SectionStudentModel> get filteredStudents {
    final query = searchQuery.trim().toLowerCase();
    final filtered = query.isEmpty
        ? students
        : students.where((student) {
            return student.displayName.toLowerCase().contains(query) ||
                student.resolvedEmail.toLowerCase().contains(query) ||
                student.studentIdLabel.toLowerCase().contains(query) ||
                student.userId.toString().contains(query) ||
                student.status.toLowerCase().contains(query);
          }).toList();

    filtered.sort((a, b) {
      final int comparison = switch (sortField) {
        RosterSortField.studentId => a.userId.compareTo(b.userId),
        RosterSortField.enrollmentDate => _compareDates(
          a.enrollmentDate,
          b.enrollmentDate,
        ),
        RosterSortField.status => a.status.toLowerCase().compareTo(
          b.status.toLowerCase(),
        ),
      };

      if (comparison != 0) {
        return sortDirection == RosterSortDirection.asc
            ? comparison
            : -comparison;
      }

      return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
    });

    return filtered;
  }

  String? noteForStudent(int userId) {
    final sectionId = selectedSectionId;
    if (sectionId == null) {
      return null;
    }
    return notesByKey[_noteKey(sectionId, userId)];
  }

  static String noteKeyFor(int sectionId, int userId) => _noteKey(sectionId, userId);

  static String _noteKey(int sectionId, int userId) => '$sectionId:$userId';

  static int _compareDates(DateTime? left, DateTime? right) {
    if (left == null && right == null) {
      return 0;
    }
    if (left == null) {
      return 1;
    }
    if (right == null) {
      return -1;
    }
    return left.compareTo(right);
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
    bool clearError = false,
    RosterSortField? sortField,
    RosterSortDirection? sortDirection,
    RosterViewMode? viewMode,
    Map<String, String>? notesByKey,
    String? instructorName,
    bool clearInstructorName = false,
    String? instructorEmail,
    bool clearInstructorEmail = false,
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
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      sortField: sortField ?? this.sortField,
      sortDirection: sortDirection ?? this.sortDirection,
      viewMode: viewMode ?? this.viewMode,
      notesByKey: notesByKey ?? this.notesByKey,
      instructorName: clearInstructorName
          ? null
          : (instructorName ?? this.instructorName),
      instructorEmail: clearInstructorEmail
          ? null
          : (instructorEmail ?? this.instructorEmail),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    courses,
    selectedSectionId,
    students,
    searchQuery,
    coursesStatus,
    studentsStatus,
    errorMessage,
    sortField,
    sortDirection,
    viewMode,
    notesByKey,
    instructorName,
    instructorEmail,
  ];
}
