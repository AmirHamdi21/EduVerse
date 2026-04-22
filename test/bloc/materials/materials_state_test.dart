import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/materials/materials_state.dart';
import 'package:edu_verse/models/instructor/upload_materials_model.dart';
import 'package:edu_verse/models/materials/course_material_model.dart';
import 'package:edu_verse/models/materials/material_bundle_model.dart';

CourseMaterialModel _material({
  required String id,
  required String title,
  required String type,
}) {
  return CourseMaterialModel(
    materialId: id,
    courseId: '56',
    materialType: type,
    title: title,
    weekNumber: 1,
    isPublished: true,
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  group('MaterialsState', () {
    test('MaterialsLoaded supports value equality', () {
      final materials = <CourseMaterialModel>[
        _material(id: '1', title: 'Week 1 - Video', type: 'video'),
        _material(id: '2', title: 'Week 1 - Slides', type: 'document'),
      ];

      final bundles = <MaterialBundleModel>[
        MaterialBundleModel.fromMaterials(materials),
      ];

      final first = MaterialsLoaded(
        courseId: 56,
        materials: materials,
        bundles: bundles,
      );
      final second = MaterialsLoaded(
        courseId: 56,
        materials: materials,
        bundles: bundles,
      );

      expect(first, second);
    });

    test('UploadProgress wraps progress state in props', () {
      final progress = UploadProgressState(
        uploadId: 'up-3',
        fileName: 'lecture.mp4',
        fileSize: 200,
        bytesSent: 100,
        totalBytes: 200,
        status: UploadProgressStatus.uploading,
        stepLabel: 'Uploading video',
        startedAt: DateTime(2026, 1, 1),
      );

      final state = UploadProgress(progress);

      expect(state.props, equals(<Object?>[progress]));
    });

    test('MaterialsError includes failed material ids', () {
      const state = MaterialsError(
        'partial failure',
        failedMaterialIds: <String>['m2', 'm4'],
      );

      expect(state.failedMaterialIds, const <String>['m2', 'm4']);
      expect(state.props, contains('partial failure'));
    });
  });
}
