import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/materials/materials_event.dart';

void main() {
  group('MaterialsEvent', () {
    test('LoadMaterials supports value equality', () {
      expect(const LoadMaterials(44), const LoadMaterials(44));
      expect(const LoadMaterials(44), isNot(const LoadMaterials(45)));
    });

    test('UploadMaterial identifies bundle uploads', () {
      const event = UploadMaterial(
        courseId: 44,
        uploadId: 'up-1',
        title: 'Week 2 Bundle',
        materialType: 'bundle',
        bundleVideoPath: '/tmp/video.mp4',
        bundleDocumentPaths: <String>['/tmp/slides.pdf'],
      );

      expect(event.isBundle, isTrue);
      expect(event.props, contains('/tmp/video.mp4'));
      expect(
        event.bundleDocumentPaths,
        equals(const <String>['/tmp/slides.pdf']),
      );
    });

    test('ToggleMaterialVisibility supports value equality', () {
      const first = ToggleMaterialVisibility(
        courseId: 1,
        materialId: 'm1',
        isPublished: false,
      );
      const second = ToggleMaterialVisibility(
        courseId: 1,
        materialId: 'm1',
        isPublished: false,
      );

      expect(first, second);
    });
  });
}
