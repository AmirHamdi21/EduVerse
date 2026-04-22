import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/models/materials/course_material_model.dart';
import 'package:edu_verse/models/materials/material_bundle_model.dart';
import 'package:edu_verse/widgets/student/course_details/bundle_viewer.dart';

void main() {
  testWidgets(
    'BundleViewer renders bundle title and count',
    (tester) async {
      final video = CourseMaterialModel(
        materialId: '1',
        courseId: '1',
        materialType: 'video',
        title: 'Week 1 - Intro Video',
        isPublished: true,
        createdAt: DateTime(2026, 1, 1),
      );

      final doc = CourseMaterialModel(
        materialId: '2',
        courseId: '1',
        materialType: 'document',
        title: 'Week 1 - Intro Slides',
        isPublished: true,
        createdAt: DateTime(2026, 1, 1),
      );

      final bundle = MaterialBundleModel.fromMaterials([video, doc]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: BundleViewer(bundle: bundle, isDark: false)),
        ),
      );

      expect(find.text('Week 1'), findsOneWidget);
      expect(find.text('2 materials'), findsOneWidget);
      expect(find.textContaining('Primary video'), findsOneWidget);
    },
    timeout: const Timeout(Duration(seconds: 20)),
  );
}
