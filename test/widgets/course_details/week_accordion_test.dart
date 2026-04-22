import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/models/materials/course_material_model.dart';
import 'package:edu_verse/widgets/student/course_details/week_accordion.dart';

void main() {
  testWidgets(
    'WeekAccordion expands and shows material title',
    (tester) async {
      final material = CourseMaterialModel(
        materialId: '1',
        courseId: '1',
        materialType: 'video',
        title: 'Week 1 Intro Video',
        isPublished: true,
        createdAt: DateTime(2026, 1, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeekAccordion(
              weekNumber: 1,
              title: 'Introduction',
              materials: [material],
              bundles: const [],
              isDark: false,
              initiallyExpanded: false,
            ),
          ),
        ),
      );

      expect(find.text('Week 1 Intro Video'), findsNothing);

      await tester.tap(find.textContaining('Week 1'));
      await tester.pumpAndSettle();

      expect(find.text('Week 1 Intro Video'), findsOneWidget);
    },
    timeout: const Timeout(Duration(seconds: 20)),
  );
}
