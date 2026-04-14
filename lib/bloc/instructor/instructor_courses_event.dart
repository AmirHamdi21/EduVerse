import 'package:equatable/equatable.dart';

abstract class InstructorCoursesEvent extends Equatable {
  const InstructorCoursesEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class LoadTeachingCourses extends InstructorCoursesEvent {
  const LoadTeachingCourses();
}

class SelectCourse extends InstructorCoursesEvent {
  final int courseId;

  const SelectCourse(this.courseId);

  @override
  List<Object?> get props => <Object?>[courseId];
}

class LoadDeadlines extends InstructorCoursesEvent {
  final int courseId;

  const LoadDeadlines(this.courseId);

  @override
  List<Object?> get props => <Object?>[courseId];
}

class LoadSectionStudents extends InstructorCoursesEvent {
  final int sectionId;

  const LoadSectionStudents(this.sectionId);

  @override
  List<Object?> get props => <Object?>[sectionId];
}

class LoadCourseStudents extends InstructorCoursesEvent {
  final int courseId;

  const LoadCourseStudents(this.courseId);

  @override
  List<Object?> get props => <Object?>[courseId];
}

class LoadEngagementMetrics extends InstructorCoursesEvent {
  final int courseId;
  final int totalEnrolledStudents;

  const LoadEngagementMetrics({
    required this.courseId,
    required this.totalEnrolledStudents,
  });

  @override
  List<Object?> get props => <Object?>[courseId, totalEnrolledStudents];
}
