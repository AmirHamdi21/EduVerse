import 'package:flutter_test/flutter_test.dart';
import 'package:edu_verse/models/labs/lab_submission_model.dart';

/// T038: Unit test for LabSubmissionModel.isLate deserialization
void main() {
  group('LabSubmissionModel.fromJson isLate parsing', () {
    Map<String, dynamic> _baseJson({dynamic isLate}) => <String, dynamic>{
          'id': 1,
          'labId': 10,
          'userId': 100,
          'submissionStatus': 'submitted',
          'isLate': isLate,
          'submittedAt': '2025-10-01T10:00:00Z',
        };

    test('parses boolean true correctly', () {
      final model = LabSubmissionModel.fromJson(_baseJson(isLate: true));
      expect(model.isLate, isTrue);
    });

    test('parses boolean false correctly', () {
      final model = LabSubmissionModel.fromJson(_baseJson(isLate: false));
      expect(model.isLate, isFalse);
    });

    test('parses int 1 as true', () {
      final model = LabSubmissionModel.fromJson(_baseJson(isLate: 1));
      expect(model.isLate, isTrue);
    });

    test('parses int 0 as false', () {
      final model = LabSubmissionModel.fromJson(_baseJson(isLate: 0));
      expect(model.isLate, isFalse);
    });

    test('parses string "1" as true', () {
      final model = LabSubmissionModel.fromJson(_baseJson(isLate: '1'));
      expect(model.isLate, isTrue);
    });

    test('parses string "0" as false', () {
      final model = LabSubmissionModel.fromJson(_baseJson(isLate: '0'));
      expect(model.isLate, isFalse);
    });

    test('parses null as false', () {
      final model = LabSubmissionModel.fromJson(_baseJson(isLate: null));
      expect(model.isLate, isFalse);
    });
  });
}
