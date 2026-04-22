import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/models/assignments/assignment_model.dart';

Map<String, dynamic> _json({
  required dynamic lateSubmissionAllowed,
  dynamic allowedFileTypes = '["pdf","zip"]',
  DateTime? dueDate,
}) {
  return <String, dynamic>{
    'id': 1,
    'courseId': 9,
    'title': 'Homework 1',
    'description': 'Desc',
    'instructions': 'Read and solve',
    'maxScore': 100,
    'weight': 20,
    'dueDate': (dueDate ?? DateTime.now().add(const Duration(days: 2)))
        .toUtc()
        .toIso8601String(),
    'availableFrom': DateTime.now().toUtc().toIso8601String(),
    'lateSubmissionAllowed': lateSubmissionAllowed,
    'latePenaltyPercent': 10,
    'submissionType': 'text',
    'maxFileSizeMb': 15,
    'allowedFileTypes': allowedFileTypes,
    'status': 'published',
    'createdBy': 2,
    'createdAt': DateTime.now().toUtc().toIso8601String(),
    'course': <String, dynamic>{'id': 9, 'name': 'Algorithms', 'code': 'CS301'},
  };
}

void main() {
  group('AssignmentModel.fromJson', () {
    test('parses lateSubmissionAllowed from tinyint value == 1', () {
      final allowLate = AssignmentModel.fromJson(
        _json(lateSubmissionAllowed: 1),
      );
      final disallowLate = AssignmentModel.fromJson(
        _json(lateSubmissionAllowed: 0),
      );

      expect(allowLate.lateSubmissionAllowed, isTrue);
      expect(disallowLate.lateSubmissionAllowed, isFalse);
    });

    test('parses allowedFileTypes from JSON string', () {
      final model = AssignmentModel.fromJson(
        _json(lateSubmissionAllowed: 1, allowedFileTypes: '["pdf","docx"]'),
      );

      expect(model.allowedFileTypes, <String>['pdf', 'docx']);
    });
  });

  group('AssignmentModel computed properties', () {
    test('hasSubmission is true only when submission exists', () {
      final base = AssignmentModel.fromJson(_json(lateSubmissionAllowed: 1));
      final withSubmission = base.copyWith(
        submission: SubmissionModel(
          id: 's1',
          submittedAt: DateTime.now(),
          attachments: const <AssignmentAttachment>[],
        ),
      );

      expect(base.hasSubmission, isFalse);
      expect(withSubmission.hasSubmission, isTrue);
    });

    test('submissionFilterStatus resolves submitted/pending/overdue', () {
      final submitted =
          AssignmentModel.fromJson(_json(lateSubmissionAllowed: 1)).copyWith(
            submission: SubmissionModel(
              id: 's2',
              submittedAt: DateTime.now(),
              attachments: const <AssignmentAttachment>[],
            ),
          );

      final pending = AssignmentModel.fromJson(
        _json(
          lateSubmissionAllowed: 1,
          dueDate: DateTime.now().add(const Duration(days: 3)),
        ),
      );

      final overdue = AssignmentModel.fromJson(
        _json(
          lateSubmissionAllowed: 1,
          dueDate: DateTime.now().subtract(const Duration(days: 1)),
        ),
      );

      expect(submitted.submissionFilterStatus, 'submitted');
      expect(pending.submissionFilterStatus, 'pending');
      expect(overdue.submissionFilterStatus, 'overdue');
    });
  });
}
