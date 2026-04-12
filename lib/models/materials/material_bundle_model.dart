import 'package:equatable/equatable.dart';

import 'course_material_model.dart';

class MaterialBundleModel extends Equatable {
  final String id;
  final String baseTitle;
  final int? weekNumber;
  final List<CourseMaterialModel> materials;
  final CourseMaterialModel? primaryVideo;
  final List<CourseMaterialModel> companionDocs;

  const MaterialBundleModel({
    required this.id,
    required this.baseTitle,
    this.weekNumber,
    required this.materials,
    required this.primaryVideo,
    required this.companionDocs,
  });

  int get totalMaterials => materials.length;

  CourseMaterialModel? get videoMaterial => primaryVideo;

  List<CourseMaterialModel> get companionMaterials => companionDocs;

  List<CourseMaterialModel> get allMaterials => materials;

  static String normalizeTitle(String title) {
    final trimmed = title.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (trimmed.isEmpty) {
      return trimmed;
    }

    var normalized = trimmed;

    // Remove trailing parenthesized or bracketed suffixes.
    while (true) {
      final stripped = normalized.replaceAll(
        RegExp(r'\s*(\([^)]*\)|\[[^\]]*\])\s*$'),
        '',
      );
      if (stripped == normalized) {
        break;
      }
      normalized = stripped.trim();
    }

    // Keep the base title before the first separator segment.
    final separatorIndex = normalized.indexOf(' - ');
    if (separatorIndex > 0) {
      normalized = normalized.substring(0, separatorIndex).trim();
    }

    return normalized;
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
      weekNumber: safeMaterials.first.weekNumber,
      materials: safeMaterials,
      primaryVideo: videos.isEmpty ? null : videos.first,
      companionDocs: docs,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    baseTitle,
    weekNumber,
    materials,
    primaryVideo,
    companionDocs,
  ];
}
