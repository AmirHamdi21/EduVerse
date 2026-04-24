import 'package:flutter_test/flutter_test.dart';
import 'package:edu_verse/models/attendance/attendance_session_model.dart';
import 'package:edu_verse/models/attendance/attendance_record_model.dart';
import 'package:edu_verse/models/attendance/student_attendance_summary_model.dart';
import 'package:edu_verse/models/attendance/ai_processing_result_model.dart';
import 'package:edu_verse/models/attendance/student_face_reference_model.dart';

void main() {
  group('AttendanceSessionModel', () {
    test('fromJson parses complete session payload', () {
      final json = <String, dynamic>{
        'id': 1,
        'sectionId': 10,
        'sessionDate': '2026-04-20',
        'sessionType': 'lecture',
        'status': 'in_progress',
        'presentCount': 20,
        'absentCount': 5,
        'lateCount': 3,
        'excusedCount': 2,
        'totalMinutes': 90,
        'records': <Map<String, dynamic>>[
          {'userId': 42, 'attendanceStatus': 'present', 'markedBy': 'manual'},
        ],
      };

      final model = AttendanceSessionModel.fromJson(json);

      expect(model.id, 1);
      expect(model.sectionId, 10);
      expect(model.sessionDate, '2026-04-20');
      expect(model.sessionType, 'lecture');
      expect(model.status, 'in_progress');
      expect(model.presentCount, 20);
      expect(model.absentCount, 5);
      expect(model.lateCount, 3);
      expect(model.excusedCount, 2);
      expect(model.totalMinutes, 90);
      expect(model.records.length, 1);
      expect(model.records.first.userId, 42);
    });

    test('fromJson handles missing optional fields', () {
      final json = <String, dynamic>{
        'id': 2,
        'sectionId': 5,
        'status': 'scheduled',
      };

      final model = AttendanceSessionModel.fromJson(json);

      expect(model.id, 2);
      expect(model.sessionDate, '');
      expect(model.sessionType, isNull);
      expect(model.totalMinutes, isNull);
      expect(model.records, isEmpty);
      expect(model.presentCount, 0);
    });

    test('isOpen returns true for scheduled and in_progress', () {
      expect(
        AttendanceSessionModel.fromJson(<String, dynamic>{
          'id': 1,
          'sectionId': 1,
          'status': 'scheduled',
        }).isOpen,
        isTrue,
      );
      expect(
        AttendanceSessionModel.fromJson(<String, dynamic>{
          'id': 1,
          'sectionId': 1,
          'status': 'in_progress',
        }).isOpen,
        isTrue,
      );
    });

    test('isClosed returns true for completed and cancelled', () {
      expect(
        AttendanceSessionModel.fromJson(<String, dynamic>{
          'id': 1,
          'sectionId': 1,
          'status': 'completed',
        }).isClosed,
        isTrue,
      );
      expect(
        AttendanceSessionModel.fromJson(<String, dynamic>{
          'id': 1,
          'sectionId': 1,
          'status': 'cancelled',
        }).isClosed,
        isTrue,
      );
    });

    test('copyWith produces updated model', () {
      final original = AttendanceSessionModel.fromJson(<String, dynamic>{
        'id': 1,
        'sectionId': 1,
        'status': 'scheduled',
        'presentCount': 10,
      });
      final updated = original.copyWith(status: 'completed', presentCount: 25);

      expect(updated.status, 'completed');
      expect(updated.presentCount, 25);
      expect(updated.id, 1);
    });

    test('toJson produces correct map', () {
      final model = AttendanceSessionModel.fromJson(<String, dynamic>{
        'id': 3,
        'sectionId': 7,
        'sessionDate': '2026-04-21',
        'sessionType': 'lab',
        'status': 'scheduled',
        'totalMinutes': 120,
      });
      final json = model.toJson();

      expect(json['id'], 3);
      expect(json['sectionId'], 7);
      expect(json['sessionDate'], '2026-04-21');
      expect(json['sessionType'], 'lab');
      expect(json['totalMinutes'], 120);
    });

    test('Equatable equality works', () {
      final a = AttendanceSessionModel.fromJson(<String, dynamic>{
        'id': 1,
        'sectionId': 1,
        'status': 'scheduled',
      });
      final b = AttendanceSessionModel.fromJson(<String, dynamic>{
        'id': 1,
        'sectionId': 1,
        'status': 'scheduled',
      });
      expect(a, equals(b));
    });
  });

  group('AttendanceRecordModel', () {
    test('fromJson parses flat fields', () {
      final json = <String, dynamic>{
        'userId': 42,
        'attendanceStatus': 'present',
        'markedBy': 'manual',
        'confidenceScore': 0.95,
        'notes': 'On time',
        'checkinTime': '2026-04-20T09:00:00Z',
        'firstName': 'John',
        'lastName': 'Doe',
        'email': 'john@example.com',
      };

      final model = AttendanceRecordModel.fromJson(json);

      expect(model.userId, 42);
      expect(model.attendanceStatus, 'present');
      expect(model.markedBy, 'manual');
      expect(model.confidenceScore, 0.95);
      expect(model.notes, 'On time');
      expect(model.firstName, 'John');
      expect(model.lastName, 'Doe');
      expect(model.email, 'john@example.com');
    });

    test('fromJson handles nested user object', () {
      final json = <String, dynamic>{
        'userId': 43,
        'attendanceStatus': 'late',
        'user': <String, dynamic>{
          'fullName': 'Jane Smith',
          'firstName': 'Jane',
          'lastName': 'Smith',
          'email': 'jane@example.com',
        },
      };

      final model = AttendanceRecordModel.fromJson(json);

      expect(model.fullName, 'Jane Smith');
      expect(model.firstName, 'Jane');
      expect(model.lastName, 'Smith');
      expect(model.email, 'jane@example.com');
      expect(model.displayName, 'Jane Smith');
    });

    test('displayName falls back to email then Student #id', () {
      final withName = AttendanceRecordModel.fromJson(<String, dynamic>{
        'userId': 1,
        'attendanceStatus': 'present',
        'firstName': 'Alice',
        'lastName': 'Wonder',
      });
      expect(withName.displayName, 'Alice Wonder');

      final withEmail = AttendanceRecordModel.fromJson(<String, dynamic>{
        'userId': 2,
        'attendanceStatus': 'present',
        'email': 'bob@example.com',
      });
      expect(withEmail.displayName, 'bob@example.com');

      final fallback = AttendanceRecordModel.fromJson(<String, dynamic>{
        'userId': 3,
        'attendanceStatus': 'absent',
      });
      expect(fallback.displayName, 'Student #3');
    });

    test('normalizeStatus handles valid and invalid values', () {
      expect(AttendanceRecordModel.normalizeStatus('Present'), 'present');
      expect(AttendanceRecordModel.normalizeStatus('ABSENT'), 'absent');
      expect(AttendanceRecordModel.normalizeStatus('late'), 'late');
      expect(AttendanceRecordModel.normalizeStatus('excused'), 'excused');
      expect(AttendanceRecordModel.normalizeStatus('unknown'), 'absent');
      expect(AttendanceRecordModel.normalizeStatus(null), 'absent');
    });
  });

  group('StudentAttendanceSummaryModel', () {
    test('fromJson parses complete payload', () {
      final json = <String, dynamic>{
        'courseId': 1,
        'courseName': 'Intro to CS',
        'courseCode': 'CS101',
        'totalClasses': 30,
        'attended': 25,
        'absent': 3,
        'late': 1,
        'excused': 1,
        'percentage': 86.7,
        'lastClassDate': '2026-04-19',
      };

      final model = StudentAttendanceSummaryModel.fromJson(json);

      expect(model.courseId, 1);
      expect(model.courseName, 'Intro to CS');
      expect(model.courseCode, 'CS101');
      expect(model.totalClasses, 30);
      expect(model.attended, 25);
      expect(model.absent, 3);
      expect(model.lateCount, 1);
      expect(model.excused, 1);
      expect(model.percentage, 86.7);
      expect(model.lastClassDate, '2026-04-19');
    });

    test('fromJson computes percentage when missing', () {
      final json = <String, dynamic>{
        'courseId': 2,
        'courseName': 'Math',
        'courseCode': 'MATH200',
        'totalClasses': 20,
        'attended': 18,
      };

      final model = StudentAttendanceSummaryModel.fromJson(json);

      expect(model.percentage, closeTo(90.0, 0.1));
    });

    test('fromJson handles zero totalClasses', () {
      final json = <String, dynamic>{
        'courseId': 3,
        'courseName': 'New Course',
        'courseCode': 'NEW100',
        'totalClasses': 0,
        'attended': 0,
      };

      final model = StudentAttendanceSummaryModel.fromJson(json);
      expect(model.percentage, 0);
    });

    test('statusLabel returns correct labels', () {
      expect(
        StudentAttendanceSummaryModel.fromJson(<String, dynamic>{
          'courseId': 1,
          'courseName': '',
          'courseCode': '',
          'totalClasses': 10,
          'attended': 10,
          'percentage': 95.0,
        }).statusLabel,
        'excellent',
      );

      expect(
        StudentAttendanceSummaryModel.fromJson(<String, dynamic>{
          'courseId': 1,
          'courseName': '',
          'courseCode': '',
          'totalClasses': 10,
          'attended': 8,
          'percentage': 85.0,
        }).statusLabel,
        'good',
      );

      expect(
        StudentAttendanceSummaryModel.fromJson(<String, dynamic>{
          'courseId': 1,
          'courseName': '',
          'courseCode': '',
          'totalClasses': 10,
          'attended': 5,
          'percentage': 50.0,
        }).statusLabel,
        'warning',
      );
    });
  });

  group('AiProcessingResultModel', () {
    test('fromJson parses complete payload', () {
      final json = <String, dynamic>{
        'processingId': 42,
        'status': 'completed',
        'detectedFacesCount': 25,
        'matchedStudentsCount': 22,
        'unmatchedFacesCount': 3,
        'errorMessage': null,
        'processingTimeMs': 4500,
      };

      final model = AiProcessingResultModel.fromJson(json);

      expect(model.processingId, 42);
      expect(model.status, 'completed');
      expect(model.detectedFacesCount, 25);
      expect(model.matchedStudentsCount, 22);
      expect(model.unmatchedFacesCount, 3);
      expect(model.errorMessage, isNull);
      expect(model.processingTimeMs, 4500);
    });

    test('status checks work correctly', () {
      final completed = AiProcessingResultModel.fromJson(<String, dynamic>{
        'processingId': 1,
        'status': 'completed',
      });
      expect(completed.isCompleted, isTrue);
      expect(completed.isFailed, isFalse);
      expect(completed.isProcessing, isFalse);

      final failed = AiProcessingResultModel.fromJson(<String, dynamic>{
        'processingId': 2,
        'status': 'failed',
      });
      expect(failed.isFailed, isTrue);
      expect(failed.isProcessing, isFalse);

      final pending = AiProcessingResultModel.fromJson(<String, dynamic>{
        'processingId': 3,
        'status': 'pending',
      });
      expect(pending.isProcessing, isTrue);
      expect(pending.isCompleted, isFalse);

      final manualReview = AiProcessingResultModel.fromJson(<String, dynamic>{
        'processingId': 4,
        'status': 'manual_review',
      });
      expect(manualReview.needsManualReview, isTrue);
      expect(manualReview.isProcessing, isFalse);
    });

    test('fromJson handles missing optional fields', () {
      final json = <String, dynamic>{'processingId': 5, 'status': 'processing'};

      final model = AiProcessingResultModel.fromJson(json);

      expect(model.detectedFacesCount, isNull);
      expect(model.matchedStudentsCount, isNull);
      expect(model.unmatchedFacesCount, isNull);
      expect(model.errorMessage, isNull);
      expect(model.processingTimeMs, isNull);
    });
  });

  group('StudentFaceReferenceModel', () {
    test('fromJson parses complete payload', () {
      final json = <String, dynamic>{
        'id': 1,
        'userId': 42,
        'storagePath': '/faces/42/photo1.jpg',
        'mimeType': 'image/jpeg',
        'fileSize': 102400,
        'isPrimary': true,
        'createdAt': '2026-04-15T10:00:00Z',
        'signedUrl': 'https://s3.example.com/faces/42/photo1.jpg?token=abc',
      };

      final model = StudentFaceReferenceModel.fromJson(json);

      expect(model.id, 1);
      expect(model.userId, 42);
      expect(model.storagePath, '/faces/42/photo1.jpg');
      expect(model.mimeType, 'image/jpeg');
      expect(model.fileSize, 102400);
      expect(model.isPrimary, isTrue);
      expect(model.createdAt, '2026-04-15T10:00:00Z');
      expect(model.signedUrl, contains('s3.example.com'));
    });

    test('fromJson handles missing optional fields', () {
      final json = <String, dynamic>{
        'id': 2,
        'userId': 43,
        'storagePath': '/faces/43/photo2.jpg',
      };

      final model = StudentFaceReferenceModel.fromJson(json);

      expect(model.mimeType, isNull);
      expect(model.fileSize, isNull);
      expect(model.isPrimary, isFalse);
      expect(model.signedUrl, isNull);
    });

    test('Equatable equality works', () {
      final a = StudentFaceReferenceModel.fromJson(<String, dynamic>{
        'id': 1,
        'userId': 42,
        'storagePath': '/path',
        'isPrimary': true,
      });
      final b = StudentFaceReferenceModel.fromJson(<String, dynamic>{
        'id': 1,
        'userId': 42,
        'storagePath': '/path',
        'isPrimary': true,
      });
      expect(a, equals(b));
    });
  });
}
