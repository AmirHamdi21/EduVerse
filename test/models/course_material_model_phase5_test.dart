import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/models/materials/course_material_model.dart';

@Timeout(Duration(seconds: 30))
void main() {
  group('CourseMaterialModel.fromJson phase5 parsing', () {
    test(
      'parses enum, urls, counters and published flag from numeric payloads',
      () {
        final model = CourseMaterialModel.fromJson(<String, dynamic>{
          'materialId': '44',
          'courseId': '7',
          'materialType': 'video',
          'title': 'Week 4 Lecture',
          'description': 'Recorded lecture',
          'url': 'https://cdn.example.com/video.mp4',
          'externalUrl': 'https://youtu.be/abcdefghijk',
          'weekNumber': '4',
          'viewCount': '11',
          'downloadCount': '5',
          'isPublished': 1,
          'createdAt': '2026-04-12T10:00:00.000Z',
        });

        expect(model.materialId, '44');
        expect(model.courseId, '7');
        expect(model.type, MaterialType.video);
        expect(model.url, 'https://cdn.example.com/video.mp4');
        expect(model.externalUrl, 'https://youtu.be/abcdefghijk');
        expect(model.weekNumber, 4);
        expect(model.viewCount, 11);
        expect(model.downloadCount, 5);
        expect(model.isPublished, isTrue);
        expect(model.createdAt, DateTime.parse('2026-04-12T10:00:00.000Z'));
      },
    );

    test('maps unknown type to MaterialType.other', () {
      final model = CourseMaterialModel.fromJson(<String, dynamic>{
        'materialId': '10',
        'courseId': '2',
        'materialType': 'something-else',
        'title': 'Unknown type item',
        'isPublished': true,
        'createdAt': '2026-04-12T10:00:00.000Z',
      });

      expect(model.type, MaterialType.other);
    });

    test('handles null url fields and false published values', () {
      final model = CourseMaterialModel.fromJson(<String, dynamic>{
        'materialId': 1,
        'courseId': 2,
        'type': 'document',
        'title': 'Handout',
        'isPublished': 0,
        'createdAt': '2026-01-01T00:00:00.000Z',
      });

      expect(model.type, MaterialType.document);
      expect(model.url, isNull);
      expect(model.externalUrl, isNull);
      expect(model.isPublished, isFalse);
    });
  });
}
