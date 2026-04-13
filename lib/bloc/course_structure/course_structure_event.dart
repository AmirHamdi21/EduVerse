import 'package:equatable/equatable.dart';

abstract class CourseStructureEvent extends Equatable {
  const CourseStructureEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class LoadStructure extends CourseStructureEvent {
  final int courseId;

  const LoadStructure(this.courseId);

  @override
  List<Object?> get props => <Object?>[courseId];
}

class CreateStructureItem extends CourseStructureEvent {
  final int courseId;
  final String title;
  final String organizationType;
  final int weekNumber;
  final String? description;

  const CreateStructureItem({
    required this.courseId,
    required this.title,
    required this.organizationType,
    required this.weekNumber,
    this.description,
  });

  @override
  List<Object?> get props => <Object?>[
    courseId,
    title,
    organizationType,
    weekNumber,
    description,
  ];
}

class UpdateStructureItem extends CourseStructureEvent {
  final int courseId;
  final int itemId;
  final Map<String, dynamic> payload;

  const UpdateStructureItem({
    required this.courseId,
    required this.itemId,
    required this.payload,
  });

  @override
  List<Object?> get props => <Object?>[courseId, itemId, payload];
}

class DeleteStructureItem extends CourseStructureEvent {
  final int courseId;
  final int itemId;

  const DeleteStructureItem({required this.courseId, required this.itemId});

  @override
  List<Object?> get props => <Object?>[courseId, itemId];
}

class ReorderStructureItems extends CourseStructureEvent {
  final int courseId;
  final List<int> itemIds;

  const ReorderStructureItems({required this.courseId, required this.itemIds});

  @override
  List<Object?> get props => <Object?>[courseId, itemIds];
}
