import 'package:equatable/equatable.dart';

class LoadCourseDetail extends CourseDetailEvent {
  final dynamic courseId;
  final int? sectionId;
  final int initialTabIndex;

  const LoadCourseDetail({
    required this.courseId,
    this.sectionId,
    this.initialTabIndex = 0,
  });

  @override
  List<Object?> get props => <Object?>[courseId, sectionId, initialTabIndex];
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
