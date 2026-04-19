import 'package:equatable/equatable.dart';

import '../../../../models/assignments/assignment_model.dart';
import '../../../../models/core/enrollment_model.dart';
import '../../../../models/labs/lab_model.dart';

class LoadCourseDetail extends CourseDetailEvent {
  final dynamic courseId;
  final int? sectionId;
  final List<EnrollmentPrerequisite>? prerequisites;
  final int initialTabIndex;

  const LoadCourseDetail({
    required this.courseId,
    this.sectionId,
    this.prerequisites,
    this.initialTabIndex = 0,
  });

  @override
  List<Object?> get props => <Object?>[
    courseId,
    sectionId,
    prerequisites,
    initialTabIndex,
  ];
}

class LoadStructure extends CourseDetailEvent {
  final dynamic courseId;

  const LoadStructure({required this.courseId});

  @override
  List<Object?> get props => <Object?>[courseId];
}

class LoadMaterials extends CourseDetailEvent {
  final dynamic courseId;
  final int? weekNumber;

  const LoadMaterials({required this.courseId, this.weekNumber});

  @override
  List<Object?> get props => <Object?>[courseId, weekNumber];
}

class LoadAssignments extends CourseDetailEvent {
  final dynamic courseId;

  const LoadAssignments({required this.courseId});

  @override
  List<Object?> get props => <Object?>[courseId];
}

class LoadLabs extends CourseDetailEvent {
  final dynamic courseId;

  const LoadLabs({required this.courseId});

  @override
  List<Object?> get props => <Object?>[courseId];
}

class LoadAssignmentSubmissions extends CourseDetailEvent {
  final List<AssignmentModel> assignments;

  const LoadAssignmentSubmissions({required this.assignments});

  @override
  List<Object?> get props => <Object?>[assignments];
}

class LoadLabSubmissions extends CourseDetailEvent {
  final List<LabModel> labs;

  const LoadLabSubmissions({required this.labs});

  @override
  List<Object?> get props => <Object?>[labs];
}

class LoadPrerequisites extends CourseDetailEvent {
  final List<EnrollmentPrerequisite> prerequisites;

  const LoadPrerequisites({required this.prerequisites});

  @override
  List<Object?> get props => <Object?>[prerequisites];
}

class ExpandWeek extends CourseDetailEvent {
  final int weekIndex;

  const ExpandWeek({required this.weekIndex});

  @override
  List<Object?> get props => <Object?>[weekIndex];
}

class SwitchTab extends CourseDetailEvent {
  final int tabIndex;

  const SwitchTab({required this.tabIndex});

  @override
  List<Object?> get props => <Object?>[tabIndex];
}

class LoadAnnouncements extends CourseDetailEvent {
  final dynamic courseId;

  const LoadAnnouncements({required this.courseId});

  @override
  List<Object?> get props => <Object?>[courseId];
}

class LoadSectionStaff extends CourseDetailEvent {
  final dynamic sectionId;

  const LoadSectionStaff({required this.sectionId});

  @override
  List<Object?> get props => <Object?>[sectionId];
}

class LoadInstructorProfile extends CourseDetailEvent {
  final int userId;

  const LoadInstructorProfile({required this.userId});

  @override
  List<Object?> get props => <Object?>[userId];
}

class LoadOfficeHourSlots extends CourseDetailEvent {
  final int instructorId;

  const LoadOfficeHourSlots({required this.instructorId});

  @override
  List<Object?> get props => <Object?>[instructorId];
}

class LoadMyAppointments extends CourseDetailEvent {
  const LoadMyAppointments();
}

class BookOfficeHourAppointment extends CourseDetailEvent {
  final int slotId;
  final String appointmentDate;
  final int? instructorId;
  final String? topic;
  final String? notes;

  const BookOfficeHourAppointment({
    required this.slotId,
    required this.appointmentDate,
    this.instructorId,
    this.topic,
    this.notes,
  });

  @override
  List<Object?> get props => <Object?>[
    slotId,
    appointmentDate,
    instructorId,
    topic,
    notes,
  ];
}

abstract class CourseDetailEvent extends Equatable {
  const CourseDetailEvent();

  @override
  List<Object?> get props => <Object?>[];
}
