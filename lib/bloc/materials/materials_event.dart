import 'package:equatable/equatable.dart';

abstract class MaterialsEvent extends Equatable {
  const MaterialsEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class LoadMaterials extends MaterialsEvent {
  final int courseId;

  const LoadMaterials(this.courseId);

  @override
  List<Object?> get props => <Object?>[courseId];
}

class UploadMaterial extends MaterialsEvent {
  final int courseId;
  final String uploadId;
  final String title;
  final String materialType;
  final String? filePath;
  final String? linkUrl;
  final int? weekNumber;
  final bool isPublished;
  final String? bundleVideoPath;
  final List<String> bundleDocumentPaths;

  const UploadMaterial({
    required this.courseId,
    required this.uploadId,
    required this.title,
    required this.materialType,
    this.filePath,
    this.linkUrl,
    this.weekNumber,
    this.isPublished = true,
    this.bundleVideoPath,
    this.bundleDocumentPaths = const <String>[],
  });

  bool get isBundle => materialType.toLowerCase() == 'bundle';

  @override
  List<Object?> get props => <Object?>[
    courseId,
    uploadId,
    title,
    materialType,
    filePath,
    linkUrl,
    weekNumber,
    isPublished,
    bundleVideoPath,
    bundleDocumentPaths,
  ];
}

class UpdateMaterial extends MaterialsEvent {
  final int courseId;
  final String materialId;
  final Map<String, dynamic> payload;

  const UpdateMaterial({
    required this.courseId,
    required this.materialId,
    required this.payload,
  });

  @override
  List<Object?> get props => <Object?>[courseId, materialId, payload];
}

class DeleteMaterial extends MaterialsEvent {
  final int courseId;
  final List<String> materialIds;

  const DeleteMaterial({required this.courseId, required this.materialIds});

  @override
  List<Object?> get props => <Object?>[courseId, materialIds];
}

class ToggleMaterialVisibility extends MaterialsEvent {
  final int courseId;
  final String materialId;
  final bool isPublished;

  const ToggleMaterialVisibility({
    required this.courseId,
    required this.materialId,
    required this.isPublished,
  });

  @override
  List<Object?> get props => <Object?>[courseId, materialId, isPublished];
}
