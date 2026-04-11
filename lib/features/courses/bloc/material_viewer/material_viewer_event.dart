import 'package:equatable/equatable.dart';

import '../../../../models/materials/course_material_model.dart';

abstract class MaterialViewerEvent extends Equatable {
  const MaterialViewerEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class PlayVideo extends MaterialViewerEvent {
  final dynamic courseId;
  final CourseMaterialModel material;

  const PlayVideo({required this.courseId, required this.material});

  @override
  List<Object?> get props => <Object?>[courseId, material];
}

class RecordView extends MaterialViewerEvent {
  final dynamic courseId;
  final CourseMaterialModel material;

  const RecordView({required this.courseId, required this.material});

  @override
  List<Object?> get props => <Object?>[courseId, material];
}

class DownloadMaterial extends MaterialViewerEvent {
  final dynamic courseId;
  final CourseMaterialModel material;

  const DownloadMaterial({required this.courseId, required this.material});

  @override
  List<Object?> get props => <Object?>[courseId, material];
}
