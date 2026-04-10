import 'package:flutter_test/flutter_test.dart';
import 'package:edu_verse/models/assignments/assignment_model.dart';
import 'package:edu_verse/models/assignments/assignment_submission_model.dart';
import 'package:edu_verse/models/core/enums/assignment_enums.dart'
    as assignment_enums;
import 'package:edu_verse/models/core/enums/course_enums.dart' as course_enums;
import 'package:edu_verse/models/core/enums/enrollment_enums.dart'
    as enrollment_enums;
import 'package:edu_verse/models/core/enums/lab_enums.dart' as lab_enums;
import 'package:edu_verse/models/core/enums/schedule_enums.dart'
    as schedule_enums;
import 'package:edu_verse/models/core/paginated_response.dart';
import 'package:edu_verse/models/labs/lab_submission_model.dart';

Map<String, dynamic> _assignmentJson({
  dynamic allowedFileTypes,
  dynamic maxScore = '100',
  dynamic weight = '20.5',
}) {
  return <String, dynamic>{
    'id': 1,
    'courseId': 10,
    'title': 'Homework 1',
    'description': 'Description',
    'instructions': 'Read and solve.',
    'maxScore': maxScore,
    'weight': weight,
    'dueDate': '2026-01-10T00:00:00.000Z',
    'availableFrom': '2026-01-01T00:00:00.000Z',
    'lateSubmissionAllowed': 1,
    'latePenaltyPercent': '10',
    'submissionType': 'file',
    'maxFileSizeMb': 25,
    'allowedFileTypes': allowedFileTypes,
    'status': 'draft',
    'createdBy': 99,
    'createdAt': '2026-01-01T00:00:00.000Z',
  };
}

void main() {
  group('Phase 1 model parsing', () {
    test('parses assignment submission isLate from integer 0/1', () {
      final lateSubmission =
          AssignmentSubmissionModel.fromJson(<String, dynamic>{
            'id': 1,
            'assignmentId': 50,
            'userId': 77,
            'submissionStatus': 'submitted',
            'isLate': 1,
            'attemptNumber': 1,
            'submittedAt': '2026-01-02T00:00:00.000Z',
          });

      final onTimeSubmission =
          AssignmentSubmissionModel.fromJson(<String, dynamic>{
            'id': 2,
            'assignmentId': 50,
            'userId': 77,
            'submissionStatus': 'submitted',
            'isLate': 0,
            'attemptNumber': 1,
            'submittedAt': '2026-01-02T00:00:00.000Z',
          });

      expect(lateSubmission.isLate, isTrue);
      expect(onTimeSubmission.isLate, isFalse);
    });

    test('parses lab submission isLate from boolean values', () {
      final lateSubmission = LabSubmissionModel.fromJson(<String, dynamic>{
        'id': 1,
        'labId': 99,
        'userId': 77,
        'submissionStatus': 'submitted',
        'isLate': true,
        'submittedAt': '2026-01-03T00:00:00.000Z',
      });

      final onTimeSubmission = LabSubmissionModel.fromJson(<String, dynamic>{
        'id': 2,
        'labId': 99,
        'userId': 77,
        'submissionStatus': 'submitted',
        'isLate': false,
        'submittedAt': '2026-01-03T00:00:00.000Z',
      });

      expect(lateSubmission.isLate, isTrue);
      expect(onTimeSubmission.isLate, isFalse);
    });

    test('decodes allowedFileTypes JSON string correctly', () {
      final populated = AssignmentModel.fromJson(
        _assignmentJson(allowedFileTypes: '["pdf","zip"]'),
      );
      final empty = AssignmentModel.fromJson(
        _assignmentJson(allowedFileTypes: '[]'),
      );
      final absent = AssignmentModel.fromJson(_assignmentJson());

      expect(populated.allowedFileTypes, <String>['pdf', 'zip']);
      expect(empty.allowedFileTypes, isEmpty);
      expect(absent.allowedFileTypes, isNull);
    });

    test('parses decimal fields from string and numeric values', () {
      final fromString = AssignmentModel.fromJson(
        _assignmentJson(maxScore: '100', weight: '15.75'),
      );
      final fromNumber = AssignmentModel.fromJson(
        _assignmentJson(maxScore: 88.5, weight: 12.25),
      );

      expect(fromString.maxGrade, 100.0);
      expect(fromString.weight, 15.75);
      expect(fromNumber.maxGrade, 88.5);
      expect(fromNumber.weight, 12.25);
    });

    test('computes pagination edges correctly', () {
      final singlePage = PaginatedResponse<int>.fromJson(<String, dynamic>{
        'data': <Map<String, dynamic>>[
          <String, dynamic>{'value': 1},
        ],
        'meta': <String, dynamic>{
          'total': 1,
          'page': 1,
          'limit': 10,
          'totalPages': 1,
        },
      }, (json) => json['value'] as int);

      final emptyPage = PaginatedResponse<int>.fromJson(<String, dynamic>{
        'data': <Map<String, dynamic>>[],
        'meta': <String, dynamic>{
          'total': 0,
          'page': 1,
          'limit': 10,
          'totalPages': 1,
        },
      }, (json) => json['value'] as int);

      final lastPage = PaginatedResponse<int>.fromJson(<String, dynamic>{
        'data': <Map<String, dynamic>>[
          <String, dynamic>{'value': 2},
        ],
        'meta': <String, dynamic>{
          'total': 20,
          'page': 2,
          'limit': 10,
          'totalPages': 2,
        },
      }, (json) => json['value'] as int);

      expect(singlePage.hasPreviousPage, isFalse);
      expect(singlePage.hasNextPage, isFalse);

      expect(emptyPage.data, isEmpty);
      expect(emptyPage.total, 0);
      expect(emptyPage.hasPreviousPage, isFalse);
      expect(emptyPage.hasNextPage, isFalse);

      expect(lastPage.hasPreviousPage, isTrue);
      expect(lastPage.hasNextPage, isFalse);
    });
  });

  group('Phase 1 enum parsing and serialization', () {
    test('course enums handle valid and unknown values', () {
      expect(
        course_enums.CourseLevel.fromString('FRESHMAN'),
        course_enums.CourseLevel.freshman,
      );
      expect(
        course_enums.CourseLevel.fromString('unexpected'),
        course_enums.CourseLevel.unknown,
      );
      expect(course_enums.CourseStatus.active.toJson(), 'ACTIVE');
      expect(
        course_enums.SectionStatus.fromString('missing'),
        course_enums.SectionStatus.unknown,
      );
    });

    test('schedule enums handle valid and unknown values', () {
      expect(
        schedule_enums.ScheduleType.fromString('LECTURE'),
        schedule_enums.ScheduleType.lecture,
      );
      expect(
        schedule_enums.ScheduleType.fromString('x'),
        schedule_enums.ScheduleType.unknown,
      );
      expect(schedule_enums.DayOfWeek.monday.toJson(), 'MONDAY');
      expect(
        schedule_enums.DayOfWeek.fromString('noday'),
        schedule_enums.DayOfWeek.unknown,
      );
    });

    test('assignment enums handle valid and unknown values', () {
      expect(
        assignment_enums.AssignmentStatus.fromString('published'),
        assignment_enums.AssignmentStatus.published,
      );
      expect(
        assignment_enums.AssignmentStatus.fromString('bad'),
        assignment_enums.AssignmentStatus.unknown,
      );
      expect(
        assignment_enums.SubmissionType.fromString('file'),
        assignment_enums.SubmissionType.file,
      );
      expect(
        assignment_enums.SubmissionType.fromString('bad'),
        assignment_enums.SubmissionType.unknown,
      );
      expect(
        assignment_enums.SubmissionStatus.fromString('graded'),
        assignment_enums.SubmissionStatus.graded,
      );
      expect(
        assignment_enums.SubmissionStatus.fromString('bad'),
        assignment_enums.SubmissionStatus.unknown,
      );
      expect(assignment_enums.AssignmentStatus.closed.toJson(), 'closed');
    });

    test('lab enums handle valid and unknown values', () {
      expect(
        lab_enums.LabStatus.fromString('published'),
        lab_enums.LabStatus.published,
      );
      expect(
        lab_enums.LabStatus.fromString('bad'),
        lab_enums.LabStatus.unknown,
      );
      expect(
        lab_enums.LabAttendanceStatus.fromString('present'),
        lab_enums.LabAttendanceStatus.present,
      );
      expect(
        lab_enums.LabAttendanceStatus.fromString('bad'),
        lab_enums.LabAttendanceStatus.unknown,
      );
      expect(lab_enums.LabStatus.archived.toJson(), 'archived');
    });

    test('enrollment enums handle valid and unknown values', () {
      expect(
        enrollment_enums.EnrollmentStatus.fromString('enrolled'),
        enrollment_enums.EnrollmentStatus.enrolled,
      );
      expect(
        enrollment_enums.EnrollmentStatus.fromString('bad'),
        enrollment_enums.EnrollmentStatus.unknown,
      );
      expect(
        enrollment_enums.DropReason.fromString('schedule_conflict'),
        enrollment_enums.DropReason.scheduleConflict,
      );
      expect(
        enrollment_enums.DropReason.fromString('bad'),
        enrollment_enums.DropReason.unknown,
      );
      expect(enrollment_enums.EnrollmentStatus.completed.toJson(), 'completed');
    });
  });
}
