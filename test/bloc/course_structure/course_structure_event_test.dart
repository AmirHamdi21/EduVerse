import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/course_structure/course_structure_event.dart';

@Timeout(Duration(seconds: 30))
void main() {
  group('CourseStructureEvent', () {
    test('LoadStructure supports value equality', () {
      expect(const LoadStructure(56), const LoadStructure(56));
      expect(const LoadStructure(56), isNot(const LoadStructure(57)));
    });

    test('CreateStructureItem stores optional description', () {
      const event = CreateStructureItem(
        courseId: 56,
        title: 'Week 2',
        organizationType: 'lecture',
        weekNumber: 2,
        description: 'Sorting',
      );

      expect(
        event.props,
        equals(const <Object?>[56, 'Week 2', 'lecture', 2, 'Sorting']),
      );
    });

    test('ReorderStructureItems supports value equality', () {
      const first = ReorderStructureItems(
        courseId: 56,
        itemIds: <int>[1, 3, 2],
      );
      const second = ReorderStructureItems(
        courseId: 56,
        itemIds: <int>[1, 3, 2],
      );

      expect(first, second);
    });
  });
}
