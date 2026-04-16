import 'package:equatable/equatable.dart';

/// Base class for all CoursesBloc events.
abstract class CoursesEvent extends Equatable {
  const CoursesEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch courses for a Student (enrolled courses).
class StudentCoursesFetched extends CoursesEvent {
  final int? semester;

  const StudentCoursesFetched({this.semester});

  @override
  List<Object?> get props => [semester];
}

/// Fetch courses for an Instructor (teaching assignments).
class InstructorCoursesFetched extends CoursesEvent {
  const InstructorCoursesFetched();
}

/// Fetch all available courses (catalog).
class AllCoursesFetched extends CoursesEvent {
  const AllCoursesFetched();
}

/// Fetch structure for a specific course.
class CourseStructureFetched extends CoursesEvent {
  final dynamic courseId;

  const CourseStructureFetched({required this.courseId});

  @override
  List<Object?> get props => [courseId];
}

/// Fetch materials for a specific course.
class CourseMaterialsFetched extends CoursesEvent {
  final dynamic courseId;
  final String? materialType;
  final int? weekNumber;

  const CourseMaterialsFetched({
    required this.courseId,
    this.materialType,
    this.weekNumber,
  });

  @override
  List<Object?> get props => [courseId, materialType, weekNumber];
}

/// Fetch announcements.
class AnnouncementsFetched extends CoursesEvent {
  const AnnouncementsFetched();
}

/// Fetch assignments.
class AssignmentsFetched extends CoursesEvent {
  const AssignmentsFetched();
}

/// Refresh courses from the network, bypassing cache.
class CoursesRefreshed extends CoursesEvent {
  const CoursesRefreshed();
}

/// Fetch courses for a Teaching Assistant (TA assignments).
class TACoursesFetched extends CoursesEvent {
  const TACoursesFetched();
}
