import 'package:equatable/equatable.dart';

import '../../models/core/course_structure_model.dart';

abstract class CourseStructureState extends Equatable {
  const CourseStructureState();

  @override
  List<Object?> get props => <Object?>[];
}

class CourseStructureInitial extends CourseStructureState {
  const CourseStructureInitial();
}

class StructureLoading extends CourseStructureState {
  const StructureLoading();
}

class StructureLoaded extends CourseStructureState {
  final int courseId;
  final List<CourseStructureModel> items;

  const StructureLoaded({required this.courseId, required this.items});

  @override
  List<Object?> get props => <Object?>[courseId, items];
}

class StructureError extends CourseStructureState {
  final String message;

  const StructureError(this.message);

  @override
  List<Object?> get props => <Object?>[message];
}
