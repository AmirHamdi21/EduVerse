import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/models/materials/course_material_model.dart';
import 'package:edu_verse/utils/bundle_detector.dart';

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
  group('BundleDetector.groupMaterialsIntoBundles', () {
    test('normalizes suffixes and separates bundles by week', () {
      final bundles =
          BundleDetector.groupMaterialsIntoBundles(<CourseMaterialModel>[
            _material(
              id: '1',
              title: 'Week 1 - Video',
              type: 'video',
              weekNumber: 1,
            ),
            _material(
              id: '2',
              title: 'Week 1 - Slides',
              type: 'document',
              weekNumber: 1,
            ),
            _material(
              id: '3',
              title: 'Week 2 - Video',
              type: 'video',
              weekNumber: 2,
            ),
          ]);

      expect(bundles.length, 2);
      expect(bundles.first.baseTitle, 'Week 1');
      expect(bundles.first.weekNumber, 1);
      expect(bundles.last.weekNumber, 2);
    });

    test('returns empty list for empty input', () {
      final bundles = BundleDetector.groupMaterialsIntoBundles(
        const <CourseMaterialModel>[],
      );

      expect(bundles, isEmpty);
    });

    test('keeps a single item as a valid bundle bucket', () {
      final bundles = BundleDetector.groupMaterialsIntoBundles(
        <CourseMaterialModel>[
          _material(
            id: '10',
            title: 'Week 7 - Notes.pdf',
            type: 'document',
            weekNumber: 7,
          ),
        ],
      );

      expect(bundles.length, 1);
      expect(bundles.first.baseTitle, 'Week 7');
      expect(bundles.first.primaryVideo, isNull);
      expect(bundles.first.companionDocs.length, 1);
    });

    test('orders video first inside each grouped bundle', () {
      final bundles =
          BundleDetector.groupMaterialsIntoBundles(<CourseMaterialModel>[
            _material(
              id: '1',
              title: 'Week 4 - Slides',
              type: 'document',
              weekNumber: 4,
            ),
            _material(
              id: '2',
              title: 'Week 4 - Video',
              type: 'video',
              weekNumber: 4,
            ),
            _material(
              id: '3',
              title: 'Week 4 - Notes',
              type: 'document',
              weekNumber: 4,
            ),
          ]);

      expect(bundles.length, 1);
      expect(bundles.first.primaryVideo?.materialId, '2');
      expect(bundles.first.materials.first.materialId, '2');
    });
  });
}
