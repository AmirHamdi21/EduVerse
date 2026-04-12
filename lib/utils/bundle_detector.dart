import '../models/materials/course_material_model.dart';
import '../models/materials/material_bundle_model.dart';

class BundleDetector {
  const BundleDetector._();

  static List<MaterialBundleModel> groupMaterialsIntoBundles(
    List<CourseMaterialModel> materials,
  ) {
    if (materials.isEmpty) {
      return const <MaterialBundleModel>[];
    }

    final grouped = <String, List<CourseMaterialModel>>{};

    for (final material in materials) {
      final normalizedTitle = _normalizeBaseTitle(material.title);
      final weekKey = material.weekNumber?.toString() ?? 'none';
      final key = '$weekKey::${normalizedTitle.toLowerCase()}';
      grouped.putIfAbsent(key, () => <CourseMaterialModel>[]).add(material);
    }

    final bundles = <MaterialBundleModel>[];

    grouped.forEach((_, group) {
      final sorted = List<CourseMaterialModel>.from(group)
        ..sort((a, b) {
          final aIsVideo = a.type == MaterialType.video ? 0 : 1;
          final bIsVideo = b.type == MaterialType.video ? 0 : 1;
          if (aIsVideo != bIsVideo) {
            return aIsVideo.compareTo(bIsVideo);
          }
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        });

      final baseTitle = _normalizeBaseTitle(sorted.first.title);
      final video = sorted
          .where((item) => item.type == MaterialType.video)
          .firstOrNull;
      final companions = sorted
          .where((item) => item.materialId != video?.materialId)
          .toList(growable: false);

      bundles.add(
        MaterialBundleModel(
          id: '${sorted.first.weekNumber ?? 0}_${baseTitle.toLowerCase().replaceAll(' ', '_')}',
          baseTitle: baseTitle,
          weekNumber: sorted.first.weekNumber,
          materials: sorted,
          primaryVideo: video,
          companionDocs: companions,
        ),
      );
    });

    bundles.sort((a, b) {
      final aWeek = a.weekNumber ?? 0;
      final bWeek = b.weekNumber ?? 0;
      if (aWeek != bWeek) {
        return aWeek.compareTo(bWeek);
      }
      return a.baseTitle.toLowerCase().compareTo(b.baseTitle.toLowerCase());
    });

    return bundles;
  }

  static String _normalizeBaseTitle(String title) {
    var value = title.trim().replaceAll(RegExp(r'\s+'), ' ');

    value = value.replaceAll(
      RegExp(r'\s*-\s*(video|slides|notes)\s*$', caseSensitive: false),
      '',
    );

    value = value.replaceAll(
      RegExp(r'\s*-\s*[^-]+\.[A-Za-z0-9]{1,6}\s*$', caseSensitive: false),
      '',
    );

    return value.trim();
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
