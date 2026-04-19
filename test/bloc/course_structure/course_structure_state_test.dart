import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/course_structure/course_structure_state.dart';
import 'package:edu_verse/models/core/course_structure_model.dart';

@Timeout(Duration(seconds: 30))
void main() {
  group('CourseStructureState', () {
    test('StructureLoaded supports value equality', () {
      const items = <CourseStructureModel>[
        CourseStructureModel(
          organizationId: 11,
          courseId: '56',
          organizationType: 'lecture',
          title: 'Week 1',
          weekNumber: 1,
          orderIndex: 1,
        ),
      ];

      const first = StructureLoaded(courseId: 56, items: items);
      const second = StructureLoaded(courseId: 56, items: items);

      expect(first, second);
    });

    test('StructureError stores message in props', () {
      const state = StructureError('failed');

      expect(state.message, 'failed');
      expect(state.props, equals(const <Object?>['failed']));
    });
  });
}
