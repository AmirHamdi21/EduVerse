import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/models/core/course_structure_model.dart';

void main() {
  group('CourseStructureModel', () {
    test('fromJson reads sortOrder into orderIndex', () {
      final model = CourseStructureModel.fromJson(<String, dynamic>{
        'id': 71,
        'courseId': 56,
        'organizationType': 'lecture',
        'title': 'Week 3: Trees',
        'weekNumber': 3,
        'sortOrder': 7,
      });

      expect(model.organizationId, '71');
      expect(model.orderIndex, 7);
      expect(model.sortOrder, 7);
      expect(model.id, 71);
    });

    test('toJson writes both orderIndex and sortOrder', () {
      const model = CourseStructureModel(
        organizationId: '88',
        courseId: '56',
        organizationType: 'lab',
        title: 'Week 8 Lab',
        weekNumber: 8,
        orderIndex: 3,
      );

      final json = model.toJson();

      expect(json['organizationId'], '88');
      expect(json['orderIndex'], 3);
      expect(json['sortOrder'], 3);
      expect(json['id'], '88');
    });

    test('fromJson handles contentType fallback', () {
      final model = CourseStructureModel.fromJson(<String, dynamic>{
        'id': '42',
        'courseId': '56',
        'contentType': 'tutorial',
        'title': 'Week 2 Tutorial',
        'weekNumber': '2',
        'orderIndex': '5',
      });

      expect(model.organizationType, 'tutorial');
      expect(model.weekNumber, 2);
      expect(model.orderIndex, 5);
    });
  });
}
