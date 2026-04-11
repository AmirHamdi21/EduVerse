import 'package:equatable/equatable.dart';

class LoadCourseDetail extends CourseDetailEvent {
  final dynamic courseId;
  final int initialTabIndex;

  const LoadCourseDetail({required this.courseId, this.initialTabIndex = 0});

  @override
  List<Object?> get props => <Object?>[courseId, initialTabIndex];
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

abstract class CourseDetailEvent extends Equatable {
  const CourseDetailEvent();

  @override
  List<Object?> get props => <Object?>[];
}
