import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/models/materials/course_material_model.dart';
import 'package:edu_verse/models/materials/material_bundle_model.dart';

CourseMaterialModel _material({
  required String id,
  required String title,
  required String type,
}) {
  return CourseMaterialModel(
    materialId: id,
    courseId: '1',
    materialType: type,
    title: title,
    isPublished: true,
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  group('MaterialBundleModel', () {
    test('normalizeTitle strips suffix after separators', () {
      expect(
        MaterialBundleModel.normalizeTitle('Week 1 - Intro Video'),
        'Week 1',
      );
      expect(
        MaterialBundleModel.normalizeTitle('Lecture 2 (Slides)'),
        'Lecture 2',
      );
      expect(MaterialBundleModel.normalizeTitle('Module [Notes]'), 'Module');
    });

    test('detectBundles groups materials with shared prefix', () {
      final materials = <CourseMaterialModel>[
        _material(id: 'm1', title: 'Week 1 - Intro Video', type: 'video'),
        _material(id: 'm2', title: 'Week 1 - Intro Slides', type: 'document'),
        _material(id: 'm3', title: 'Week 2 - Reading', type: 'document'),
      ];

      final bundles = MaterialBundleModel.detectBundles(materials);

      expect(bundles.length, 1);
      expect(bundles.containsKey('Week 1'), isTrue);
      expect(bundles['Week 1']!.totalMaterials, 2);
      expect(bundles['Week 1']!.primaryVideo, isNotNull);
      expect(bundles['Week 1']!.companionDocs.length, 1);
    });
  });
}
