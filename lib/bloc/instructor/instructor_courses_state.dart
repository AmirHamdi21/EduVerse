import 'package:equatable/equatable.dart';

import '../../models/instructor/instructor_course_model.dart';
import '../../models/instructor/teaching_course_model.dart';

abstract class InstructorCoursesState extends Equatable {
  const InstructorCoursesState();

  @override
  List<Object?> get props => <Object?>[];
}

class InstructorCoursesInitial extends InstructorCoursesState {
  const InstructorCoursesInitial();
}

class InstructorCoursesLoading extends InstructorCoursesState {
  const InstructorCoursesLoading();
}

class InstructorCoursesLoaded extends InstructorCoursesState {
  final List<TeachingCourseModel> courses;
  final int? selectedCourseId;
  final int? selectedSectionId;
  final List<DeadlineCardModel> deadlines;
  final List<SectionStudentModel> sectionStudents;
  final EngagementMetricsModel? engagementMetrics;

  const InstructorCoursesLoaded(
    this.courses, {
    this.selectedCourseId,
    this.selectedSectionId,
    this.deadlines = const <DeadlineCardModel>[],
    this.sectionStudents = const <SectionStudentModel>[],
    this.engagementMetrics,
  });

  @override
  List<Object?> get props => <Object?>[
    courses,
    selectedCourseId,
    selectedSectionId,
    deadlines,
    sectionStudents,
    engagementMetrics,
  ];
}

class DeadlinesLoaded extends InstructorCoursesState {
  final List<DeadlineCardModel> deadlines;

  const DeadlinesLoaded(this.deadlines);

  @override
  List<Object?> get props => <Object?>[deadlines];
}

class InstructorCoursesError extends InstructorCoursesState {
  final String message;

  const InstructorCoursesError(this.message);

  @override
  List<Object?> get props => <Object?>[message];
}
