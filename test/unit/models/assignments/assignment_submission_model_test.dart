import 'package:flutter_test/flutter_test.dart';
import 'package:edu_verse/models/assignments/assignment_submission_model.dart';

/// T027: Unit test for AssignmentSubmissionModel._parseBoolFromIntLike
void main() {
  group('AssignmentSubmissionModel.fromJson isLate parsing', () {
    Map<String, dynamic> _baseJson({dynamic isLate}) => <String, dynamic>{
          'id': 1,
          'assignmentId': 10,
          'userId': 100,
          'submissionStatus': 'submitted',
          'isLate': isLate,
          'attemptNumber': 1,
          'submittedAt': '2025-10-01T10:00:00Z',
        };

    test('parses int 0 as false', () {
      final model = AssignmentSubmissionModel.fromJson(_baseJson(isLate: 0));
      expect(model.isLate, isFalse);
    });

    test('parses int 1 as true', () {
      final model = AssignmentSubmissionModel.fromJson(_baseJson(isLate: 1));
      expect(model.isLate, isTrue);
    });

    test('parses bool false as false', () {
      final model =
          AssignmentSubmissionModel.fromJson(_baseJson(isLate: false));
      expect(model.isLate, isFalse);
    });

    test('parses bool true as true', () {
      final model = AssignmentSubmissionModel.fromJson(_baseJson(isLate: true));
      expect(model.isLate, isTrue);
    });

    test('parses string "0" as false', () {
      final model = AssignmentSubmissionModel.fromJson(_baseJson(isLate: '0'));
      expect(model.isLate, isFalse);
    });

    test('parses string "1" as true', () {
      final model = AssignmentSubmissionModel.fromJson(_baseJson(isLate: '1'));
      expect(model.isLate, isTrue);
    });

    test('parses null as false', () {
      final model = AssignmentSubmissionModel.fromJson(_baseJson(isLate: null));
      expect(model.isLate, isFalse);
    });
  });
}
