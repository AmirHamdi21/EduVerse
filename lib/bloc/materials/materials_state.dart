import 'package:equatable/equatable.dart';

import '../../models/instructor/upload_materials_model.dart';
import '../../models/materials/course_material_model.dart';
import '../../models/materials/material_bundle_model.dart';

abstract class MaterialsState extends Equatable {
  const MaterialsState();

  @override
  List<Object?> get props => <Object?>[];
}

class MaterialsInitial extends MaterialsState {
  const MaterialsInitial();
}

class MaterialsLoading extends MaterialsState {
  const MaterialsLoading();
}

class MaterialsLoaded extends MaterialsState {
  final int courseId;
  final List<CourseMaterialModel> materials;
  final List<MaterialBundleModel> bundles;

  const MaterialsLoaded({
    required this.courseId,
    required this.materials,
    required this.bundles,
  });

  @override
  List<Object?> get props => <Object?>[courseId, materials, bundles];
}

class UploadProgress extends MaterialsState {
  final UploadProgressState progress;

  const UploadProgress(this.progress);

  @override
  List<Object?> get props => <Object?>[progress];
}

class MaterialsError extends MaterialsState {
  final String message;
  final List<String> failedMaterialIds;

  const MaterialsError(
    this.message, {
    this.failedMaterialIds = const <String>[],
  });

  @override
  List<Object?> get props => <Object?>[message, failedMaterialIds];
}
