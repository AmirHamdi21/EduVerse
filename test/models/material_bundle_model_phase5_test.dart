import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/models/materials/course_material_model.dart';
import 'package:edu_verse/models/materials/material_bundle_model.dart';

CourseMaterialModel _material({
  required String id,
  required String title,
  required String type,
  int? weekNumber,
}) {
  return CourseMaterialModel(
    materialId: id,
    courseId: '1',
    materialType: type,
    title: title,
    weekNumber: weekNumber,
    isPublished: true,
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  group('MaterialBundleModel phase5', () {
    test('fromMaterials sets base title, primary video and companions', () {
      final materials = <CourseMaterialModel>[
        _material(
          id: '1',
          title: 'Week 2 - Data Structures Video',
          type: 'video',
          weekNumber: 2,
        ),
        _material(
          id: '2',
          title: 'Week 2 - Data Structures Slides',
          type: 'document',
          weekNumber: 2,
        ),
      ];

      final bundle = MaterialBundleModel.fromMaterials(materials);

      expect(bundle.baseTitle, 'Week 2');
      expect(bundle.weekNumber, 2);
      expect(bundle.primaryVideo?.materialId, '1');
      expect(bundle.companionDocs.length, 1);
      expect(bundle.totalMaterials, 2);
      expect(bundle.videoMaterial, isNotNull);
      expect(bundle.companionMaterials.length, 1);
      expect(bundle.allMaterials.length, 2);
    });

    test('detectBundles groups only keys with two or more materials', () {
      final materials = <CourseMaterialModel>[
        _material(id: '1', title: 'Week 1 - Intro Video', type: 'video'),
        _material(id: '2', title: 'Week 1 - Intro Slides', type: 'document'),
        _material(id: '3', title: 'Week 9 - Single Item', type: 'document'),
      ];

      final bundles = MaterialBundleModel.detectBundles(materials);

      expect(bundles.length, 1);
      expect(bundles.containsKey('Week 1'), isTrue);
      expect(bundles['Week 1']!.materials.length, 2);
      expect(bundles.containsKey('Week 9'), isFalse);
    });
  });
}
