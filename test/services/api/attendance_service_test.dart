import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/services/api/attendance_service.dart';
import 'package:edu_verse/services/api/core_api_client.dart';

/// Mock adapter that captures requests and returns pre-defined responses.
class _MockAdapter implements HttpClientAdapter {
  final Map<String, dynamic> Function(RequestOptions) _handler;

  _MockAdapter(this._handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final result = _handler(options);
    final statusCode = result['statusCode'] as int? ?? 200;
    final data = result['data'];

    return ResponseBody.fromString(
      data is String ? data : jsonEncode(data),
      statusCode,
      headers: {
        'content-type': ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late CoreApiClient coreApiClient;
  late AttendanceService service;

  group('AttendanceService — Student Endpoints', () {
    test('getMyAttendance sends GET /attendance/my and parses list', () async {
      String? capturedPath;
      String? capturedMethod;

      coreApiClient = CoreApiClient.test();
      coreApiClient.dio.httpClientAdapter = _MockAdapter((options) {
        capturedPath = options.path;
        capturedMethod = options.method;
        return {
          'statusCode': 200,
          'data': [
            {
              'courseId': 1,
              'courseName': 'Intro to CS',
              'courseCode': 'CS101',
              'totalClasses': 30,
              'attended': 25,
              'absent': 3,
              'late': 1,
              'excused': 1,
              'percentage': 86.7,
            },
          ],
        };
      });

      service = AttendanceService(coreApiClient: coreApiClient);
      final result = await service.getMyAttendance();

      expect(capturedMethod, 'GET');
      expect(capturedPath, contains('/attendance/my'));
      expect(result.isSuccess, isTrue);
      expect(result.data, isNotNull);
      expect(result.data!.length, 1);
      expect(result.data!.first.courseName, 'Intro to CS');
    });

    test('getMyAttendance handles {summary: [...]} wrapper', () async {
      coreApiClient = CoreApiClient.test();
      coreApiClient.dio.httpClientAdapter = _MockAdapter((_) {
        return {
          'statusCode': 200,
          'data': {
            'summary': [
              {
                'courseId': 2,
                'courseName': 'Math',
                'courseCode': 'MATH200',
                'totalClasses': 20,
                'attended': 18,
                'percentage': 90.0,
              },
            ],
          },
        };
      });

      service = AttendanceService(coreApiClient: coreApiClient);
      final result = await service.getMyAttendance();

      expect(result.isSuccess, isTrue);
      expect(result.data!.first.courseCode, 'MATH200');
    });

    test('getMyAttendance handles {data: [...]} wrapper', () async {
      coreApiClient = CoreApiClient.test();
      coreApiClient.dio.httpClientAdapter = _MockAdapter((_) {
        return {
          'statusCode': 200,
          'data': {
            'data': [
              {
                'courseId': 3,
                'courseName': 'Physics',
                'courseCode': 'PHY100',
                'totalClasses': 15,
                'attended': 12,
                'percentage': 80.0,
              },
            ],
          },
        };
      });

      service = AttendanceService(coreApiClient: coreApiClient);
      final result = await service.getMyAttendance();

      expect(result.isSuccess, isTrue);
      expect(result.data!.first.courseCode, 'PHY100');
    });

    test('getByStudent sends correct path', () async {
      String? capturedPath;

      coreApiClient = CoreApiClient.test();
      coreApiClient.dio.httpClientAdapter = _MockAdapter((options) {
        capturedPath = options.path;
        return {
          'statusCode': 200,
          'data': <Map<String, dynamic>>[],
        };
      });

      service = AttendanceService(coreApiClient: coreApiClient);
      final result = await service.getByStudent(42);

      expect(capturedPath, contains('/attendance/by-student/42'));
      expect(result.isSuccess, isTrue);
      expect(result.data, isEmpty);
    });
  });

  group('AttendanceService — Session Endpoints', () {
    test('getSessions sends query params correctly', () async {
      Map<String, dynamic>? capturedParams;

      coreApiClient = CoreApiClient.test();
      coreApiClient.dio.httpClientAdapter = _MockAdapter((options) {
        capturedParams = options.queryParameters;
        return {
          'statusCode': 200,
          'data': <Map<String, dynamic>>[],
        };
      });

      service = AttendanceService(coreApiClient: coreApiClient);
      await service.getSessions(
        sectionId: 10,
        limit: 30,
        sortBy: 'sessionDate',
        sortOrder: 'DESC',
      );

      expect(capturedParams, isNotNull);
      expect(capturedParams!['sectionId'], 10);
      expect(capturedParams!['limit'], 30);
      expect(capturedParams!['sortBy'], 'sessionDate');
      expect(capturedParams!['sortOrder'], 'DESC');
    });

    test('createSession sends POST with correct body', () async {
      String? capturedMethod;
      dynamic capturedData;

      coreApiClient = CoreApiClient.test();
      coreApiClient.dio.httpClientAdapter = _MockAdapter((options) {
        capturedMethod = options.method;
        capturedData = options.data;
        return {
          'statusCode': 201,
          'data': {
            'id': 99,
            'sectionId': 10,
            'sessionDate': '2026-04-21',
            'sessionType': 'lecture',
            'status': 'scheduled',
          },
        };
      });

      service = AttendanceService(coreApiClient: coreApiClient);
      final result = await service.createSession(
        sectionId: 10,
        sessionDate: '2026-04-21',
        sessionType: 'lecture',
      );

      expect(capturedMethod, 'POST');
      expect(capturedData, isNotNull);
      expect(result.isSuccess, isTrue);
      expect(result.data!.id, 99);
      expect(result.data!.status, 'scheduled');
    });

    test('getSessionDetails sends GET with session id', () async {
      String? capturedPath;

      coreApiClient = CoreApiClient.test();
      coreApiClient.dio.httpClientAdapter = _MockAdapter((options) {
        capturedPath = options.path;
        return {
          'statusCode': 200,
          'data': {
            'id': 5,
            'sectionId': 10,
            'sessionDate': '2026-04-20',
            'status': 'in_progress',
            'records': [
              {
                'userId': 42,
                'attendanceStatus': 'present',
                'markedBy': 'ai',
                'confidenceScore': 0.92,
              },
            ],
          },
        };
      });

      service = AttendanceService(coreApiClient: coreApiClient);
      final result = await service.getSessionDetails(5);

      expect(capturedPath, contains('/attendance/sessions/5'));
      expect(result.isSuccess, isTrue);
      expect(result.data!.records.length, 1);
      expect(result.data!.records.first.markedBy, 'ai');
    });

    test('deleteSession sends DELETE', () async {
      String? capturedMethod;
      String? capturedPath;

      coreApiClient = CoreApiClient.test();
      coreApiClient.dio.httpClientAdapter = _MockAdapter((options) {
        capturedMethod = options.method;
        capturedPath = options.path;
        return {'statusCode': 204, 'data': ''};
      });

      service = AttendanceService(coreApiClient: coreApiClient);
      final result = await service.deleteSession(7);

      expect(capturedMethod, 'DELETE');
      expect(capturedPath, contains('/attendance/sessions/7'));
      expect(result.isSuccess, isTrue);
    });

    test('closeSession sends PATCH (not PUT)', () async {
      String? capturedMethod;
      String? capturedPath;

      coreApiClient = CoreApiClient.test();
      coreApiClient.dio.httpClientAdapter = _MockAdapter((options) {
        capturedMethod = options.method;
        capturedPath = options.path;
        return {'statusCode': 200, 'data': ''};
      });

      service = AttendanceService(coreApiClient: coreApiClient);
      final result = await service.closeSession(8);

      expect(capturedMethod, 'PATCH');
      expect(capturedPath, contains('/attendance/sessions/8/close'));
      expect(result.isSuccess, isTrue);
    });
  });

  group('AttendanceService — Records Endpoints', () {
    test('markBatchAttendance sends POST with records payload', () async {
      String? capturedMethod;
      String? capturedPath;
      dynamic capturedData;

      coreApiClient = CoreApiClient.test();
      coreApiClient.dio.httpClientAdapter = _MockAdapter((options) {
        capturedMethod = options.method;
        capturedPath = options.path;
        capturedData = options.data;
        return {'statusCode': 200, 'data': ''};
      });

      service = AttendanceService(coreApiClient: coreApiClient);
      final result = await service.markBatchAttendance(
        sessionId: 5,
        records: [
          {'userId': 1, 'attendanceStatus': 'present'},
          {'userId': 2, 'attendanceStatus': 'absent'},
        ],
      );

      expect(capturedMethod, 'POST');
      expect(capturedPath, contains('/attendance/records/batch'));
      expect(capturedData['sessionId'], 5);
      expect(capturedData['records'], hasLength(2));
      expect(result.isSuccess, isTrue);
    });

    test('getSectionSummary sends GET with sectionId', () async {
      String? capturedPath;

      coreApiClient = CoreApiClient.test();
      coreApiClient.dio.httpClientAdapter = _MockAdapter((options) {
        capturedPath = options.path;
        return {
          'statusCode': 200,
          'data': {'totalSessions': 10, 'averageAttendance': 85.5},
        };
      });

      service = AttendanceService(coreApiClient: coreApiClient);
      final result = await service.getSectionSummary(15);

      expect(capturedPath, contains('/attendance/summary/15'));
      expect(result.isSuccess, isTrue);
      expect(result.data!['totalSessions'], 10);
    });
  });

  group('AttendanceService — Face Reference Endpoints', () {
    test('listMyFaceReferences sends GET to /face-references/me', () async {
      String? capturedPath;

      coreApiClient = CoreApiClient.test();
      coreApiClient.dio.httpClientAdapter = _MockAdapter((options) {
        capturedPath = options.path;
        return {
          'statusCode': 200,
          'data': [
            {
              'id': 1,
              'userId': 42,
              'storagePath': '/faces/42/photo1.jpg',
              'isPrimary': true,
            },
          ],
        };
      });

      service = AttendanceService(coreApiClient: coreApiClient);
      final result = await service.listMyFaceReferences();

      expect(capturedPath, contains('/attendance/face-references/me'));
      expect(result.isSuccess, isTrue);
      expect(result.data!.length, 1);
      expect(result.data!.first.isPrimary, isTrue);
    });

    test('deleteMyFaceReference sends DELETE with id', () async {
      String? capturedMethod;
      String? capturedPath;

      coreApiClient = CoreApiClient.test();
      coreApiClient.dio.httpClientAdapter = _MockAdapter((options) {
        capturedMethod = options.method;
        capturedPath = options.path;
        return {'statusCode': 204, 'data': ''};
      });

      service = AttendanceService(coreApiClient: coreApiClient);
      final result = await service.deleteMyFaceReference(3);

      expect(capturedMethod, 'DELETE');
      expect(capturedPath, contains('/attendance/face-references/me/3'));
      expect(result.isSuccess, isTrue);
    });
  });

  group('AttendanceService — AI Endpoints', () {
    test('getAiProcessingResult sends GET with processingId', () async {
      String? capturedPath;

      coreApiClient = CoreApiClient.test();
      coreApiClient.dio.httpClientAdapter = _MockAdapter((options) {
        capturedPath = options.path;
        return {
          'statusCode': 200,
          'data': {
            'processingId': 99,
            'status': 'completed',
            'detectedFacesCount': 20,
            'matchedStudentsCount': 18,
            'unmatchedFacesCount': 2,
            'processingTimeMs': 5000,
          },
        };
      });

      service = AttendanceService(coreApiClient: coreApiClient);
      final result = await service.getAiProcessingResult(99);

      expect(capturedPath, contains('/attendance/ai-photo/99'));
      expect(result.isSuccess, isTrue);
      expect(result.data!.isCompleted, isTrue);
      expect(result.data!.matchedStudentsCount, 18);
    });
  });
}
