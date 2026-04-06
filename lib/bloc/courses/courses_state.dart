import 'package:equatable/equatable.dart';
import '../../models/core/course_model.dart';
import '../../models/core/enrollment_model.dart';
import '../../models/core/course_structure_model.dart';
import '../../models/materials/course_material_model.dart';
import '../../models/materials/announcement_model.dart';
import '../../models/materials/assignment_model.dart';
import '../../models/instructor/teaching_course_model.dart';

/// Base class for all CoursesBloc states.
abstract class CoursesState extends Equatable {
  const CoursesState();

  @override
  List<Object?> get props => [];
}

/// Initial idle state before any fetch.
class CoursesInitial extends CoursesState {
  const CoursesInitial();
}

/// Loading state with optional cached data for offline resilience.
class CoursesLoading extends CoursesState {
  /// Previously loaded data shown while new data loads (offline resilience).
  final List<dynamic> cachedData;

  const CoursesLoading({this.cachedData = const []});

  @override
  List<Object?> get props => [cachedData];
}

/// Successfully loaded enrolled courses (Student view).
class CoursesLoaded extends CoursesState {
  final List<CourseEnrollmentModel> enrollments;

  const CoursesLoaded({required this.enrollments});

  /// Convenience getter for the course objects.
  List<CourseModel> get courses =>
      enrollments.where((e) => e.course != null).map((e) => e.course!).toList();

  @override
  List<Object?> get props => [enrollments];
}

/// Successfully loaded all courses (Catalog view).
class AllCoursesLoaded extends CoursesState {
  final List<CourseModel> courses;

  const AllCoursesLoaded({required this.courses});

  @override
  List<Object?> get props => [courses];
}

/// Successfully loaded instructor/TA teaching assignments.
class InstructorCoursesLoaded extends CoursesState {
  final List<TeachingCourseModel> teachingCourses;

  const InstructorCoursesLoaded({required this.teachingCourses});

  /// Total enrolled students across all assigned sections.
  int get totalStudents => teachingCourses.fold<int>(
    0,
    (sum, tc) => sum + tc.section.currentEnrollment,
  );

  @override
  List<Object?> get props => [teachingCourses];
}

/// Successfully loaded TA teaching assignments.
/// Uses the same data shape as InstructorCoursesLoaded but provides
/// a distinct state type so BlocBuilder can differentiate TA vs Instructor.
class TACoursesLoaded extends CoursesState {
  final List<TeachingCourseModel> teachingCourses;

  const TACoursesLoaded({required this.teachingCourses});

  /// Total enrolled students across all assigned sections.
  int get totalStudents => teachingCourses.fold<int>(
    0,
    (sum, tc) => sum + tc.section.currentEnrollment,
  );

  @override
  List<Object?> get props => [teachingCourses];
}

/// Successfully loaded course structure.
class CourseStructureLoaded extends CoursesState {
  final List<CourseStructureModel> structure;

  const CourseStructureLoaded({required this.structure});

  @override
  List<Object?> get props => [structure];
}

/// Successfully loaded course materials.
class CourseMaterialsLoaded extends CoursesState {
  final List<CourseMaterialModel> materials;

  const CourseMaterialsLoaded({required this.materials});

  @override
  List<Object?> get props => [materials];
}

/// Successfully loaded announcements.
class AnnouncementsLoaded extends CoursesState {
  final List<AnnouncementModel> announcements;

  const AnnouncementsLoaded({required this.announcements});

  @override
  List<Object?> get props => [announcements];
}

/// Successfully loaded assignments.
class AssignmentsLoaded extends CoursesState {
  final List<AssignmentModel> assignments;

  const AssignmentsLoaded({required this.assignments});

  @override
  List<Object?> get props => [assignments];
}

/// Error state with a user-friendly message.
class CoursesError extends CoursesState {
  final String message;

  const CoursesError({required this.message});

  @override
  List<Object?> get props => [message];
}
