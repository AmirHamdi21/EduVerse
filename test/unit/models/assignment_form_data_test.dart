import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/models/assignments/assignment_form_data.dart';
import 'package:edu_verse/models/core/enums/assignment_enums.dart';

void main() {
  group('AssignmentFormData', () {
    test('fromJson parses numeric strings and allowed file types JSON', () {
      final json = <String, dynamic>{
        'title': '  Capstone Project  ',
        'description': '  Build a compiler  ',
        'instructions': '  Upload report and source code  ',
        'dueDate': '2026-06-01T10:30:00.000Z',
        'maxScore': '120.5',
        'weight': '15.75',
        'submissionType': 'multiple',
        'maxFileSizeMb': '50',
        'allowedFileTypes': '["pdf", "zip", " dart "]',
        'latePenaltyPercent': '2.5',
        'status': 'published',
        'courseId': '91',
      };

      final model = AssignmentFormData.fromJson(json);

      expect(model.title, 'Capstone Project');
      expect(model.description, 'Build a compiler');
      expect(model.instructions, 'Upload report and source code');
      expect(model.dueDate, DateTime.parse('2026-06-01T10:30:00.000Z'));
      expect(model.maxScore, 120.5);
      expect(model.weight, 15.75);
      expect(model.submissionType, SubmissionType.multiple);
      expect(model.maxFileSizeMb, 50);
      expect(model.allowedFileTypes, <String>['pdf', 'zip', 'dart']);
      expect(model.latePenaltyPercent, 2.5);
      expect(model.status, AssignmentStatus.published);
      expect(model.courseId, 91);
    });

    test('toJson emits backend payload with encoded allowed file types', () {
      final model = AssignmentFormData(
        title: 'Essay 1',
        description: 'Write an essay',
        instructions: 'Use APA style',
        dueDate: DateTime.parse('2026-05-10T09:00:00.000Z'),
        maxScore: 100,
        weight: 20,
        submissionType: SubmissionType.file,
        maxFileSizeMb: 10,
        allowedFileTypes: const <String>['pdf', 'docx'],
        latePenaltyPercent: 5,
        status: AssignmentStatus.draft,
        courseId: 17,
      );

      final json = model.toJson();

      expect(json['title'], 'Essay 1');
      expect(json['description'], 'Write an essay');
      expect(json['instructions'], 'Use APA style');
      expect(json['dueDate'], '2026-05-10T09:00:00.000Z');
      expect(json['maxScore'], 100);
      expect(json['weight'], 20);
      expect(json['submissionType'], 'file');
      expect(json['maxFileSizeMb'], 10);
      expect(json['allowedFileTypes'], '["pdf","docx"]');
      expect(json['latePenaltyPercent'], 5);
      expect(json['status'], 'draft');
      expect(json['courseId'], 17);
    });
  });
}
