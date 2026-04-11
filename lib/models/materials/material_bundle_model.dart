import 'package:equatable/equatable.dart';

import 'course_material_model.dart';

class MaterialBundleModel extends Equatable {
  final String id;
  final String baseTitle;
  final List<CourseMaterialModel> materials;
  final CourseMaterialModel? primaryVideo;
  final List<CourseMaterialModel> companionDocs;

  const MaterialBundleModel({
    required this.id,
    required this.baseTitle,
    required this.materials,
    required this.primaryVideo,
    required this.companionDocs,
  });

  int get totalMaterials => materials.length;

  static String normalizeTitle(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      return trimmed;
    }

    final match = RegExp(r'^[^()\[\]-]+').firstMatch(trimmed);
    return (match?.group(0) ?? trimmed).trim();
  }

  static Map<String, MaterialBundleModel> detectBundles(
    List<CourseMaterialModel> materials,
  ) {
    final grouped = <String, List<CourseMaterialModel>>{};

    for (final material in materials) {
      final key = normalizeTitle(material.title);
      grouped.putIfAbsent(key, () => <CourseMaterialModel>[]).add(material);
    }

    final bundles = <String, MaterialBundleModel>{};

    grouped.forEach((key, group) {
      if (group.length < 2) {
        return;
      }

      bundles[key] = MaterialBundleModel.fromMaterials(group);
    });

    return bundles;
  }

  factory MaterialBundleModel.fromMaterials(
    List<CourseMaterialModel> materials,
  ) {
    final safeMaterials = List<CourseMaterialModel>.from(materials);
    final videos = safeMaterials
        .where((m) => m.materialType.toLowerCase() == 'video')
        .toList();
    final docs = safeMaterials
        .where((m) => m.materialType.toLowerCase() != 'video')
        .toList();

    return MaterialBundleModel(
      id: '${normalizeTitle(safeMaterials.first.title)}_${safeMaterials.length}',
      baseTitle: normalizeTitle(safeMaterials.first.title),
      materials: safeMaterials,
      primaryVideo: videos.isEmpty ? null : videos.first,
      companionDocs: docs,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    baseTitle,
    materials,
    primaryVideo,
    companionDocs,
  ];
}
