import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/enrollment_service.dart';

class _MockAdapter implements HttpClientAdapter {
  final Map<String, dynamic> Function(RequestOptions options) handler;

  _MockAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final Map<String, dynamic> result = handler(options);
    final int statusCode = result['statusCode'] as int? ?? 200;
    final dynamic data = result['data'];

    return ResponseBody.fromString(
      data is String ? data : jsonEncode(data),
      statusCode,
      headers: <String, List<String>>{
        'content-type': <String>['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

EnrollmentService _buildService(
  Map<String, dynamic> Function(RequestOptions options) handler,
) {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://eduverse.test',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
  dio.httpClientAdapter = _MockAdapter(handler);

  return EnrollmentService(coreApiClient: CoreApiClient.test(dioOverride: dio));
}

Map<String, dynamic> _sampleEnrollmentJson({
  int semesterId = 2,
  String semesterName = 'Spring 2027',
}) {
  return <String, dynamic>{
    'id': 150,
    'userId': 42,
    'sectionId': 5,
    'status': 'enrolled',
    'grade': null,
    'finalScore': null,
    'enrollmentDate': '2026-08-15T10:00:00.000Z',
    'canDrop': true,
    'dropDeadline': '2026-09-01T23:59:59.000Z',
    'course': <String, dynamic>{
      'id': 12,
      'name': 'Discrete Mathematics',
      'code': 'MATH201',
      'description': 'Introductory discrete math',
      'credits': 3,
      'level': 'freshman',
    },
    'section': <String, dynamic>{
      'id': 5,
      'sectionNumber': 'A',
      'maxCapacity': 30,
      'currentEnrollment': 26,
      'location': 'C-305',
    },
    'semester': <String, dynamic>{
      'id': semesterId,
      'name': semesterName,
      'startDate': '2026-08-15T00:00:00.000Z',
      'endDate': '2026-12-20T00:00:00.000Z',
    },
  };
}

void main() {
  group('EnrollmentService semester-aware my-courses', () {
    test('serializes semester query for getMyEnrollments', () async {
      int? observedSemester;

      final EnrollmentService service = _buildService((RequestOptions options) {
        if (options.path.contains('/enrollments/my-courses')) {
          observedSemester = options.queryParameters['semester'] as int?;
          return <String, dynamic>{
            'statusCode': 200,
            'data': <Map<String, dynamic>>[_sampleEnrollmentJson()],
          };
        }
        return <String, dynamic>{
          'statusCode': 404,
          'data': <String, dynamic>{},
        };
      });

      final result = await service.getMyEnrollments(semester: 2);

      expect(result.isSuccess, isTrue);
      expect(result.data, isNotNull);
      expect(result.data!.length, 1);
      expect(result.data!.first.semester?.id, 2);
      expect(observedSemester, 2);
    });

    test('omits semester query when no filter is provided', () async {
      bool hasSemesterQuery = false;

      final EnrollmentService service = _buildService((RequestOptions options) {
        if (options.path.contains('/enrollments/my-courses')) {
          hasSemesterQuery = options.queryParameters.containsKey('semester');
          return <String, dynamic>{
            'statusCode': 200,
            'data': <Map<String, dynamic>>[
              _sampleEnrollmentJson(semesterId: 4, semesterName: 'Fall 2027'),
            ],
          };
        }
        return <String, dynamic>{
          'statusCode': 404,
          'data': <String, dynamic>{},
        };
      });

      final result = await service.getMyEnrollments();

      expect(result.isSuccess, isTrue);
      expect(hasSemesterQuery, isFalse);
      expect(result.data!.first.course?.courseCode, 'MATH201');
    });

    test('getMyCourses delegates to semester-aware endpoint', () async {
      int? observedSemester;

      final EnrollmentService service = _buildService((RequestOptions options) {
        if (options.path.contains('/enrollments/my-courses')) {
          observedSemester = options.queryParameters['semester'] as int?;
          return <String, dynamic>{
            'statusCode': 200,
            'data': <Map<String, dynamic>>[_sampleEnrollmentJson()],
          };
        }
        return <String, dynamic>{
          'statusCode': 404,
          'data': <String, dynamic>{},
        };
      });

      final result = await service.getMyCourses(semester: 2);

      expect(result.isSuccess, isTrue);
      expect(observedSemester, 2);
    });
  });

  group('EnrollmentService register parity', () {
    test('register preserves sectionId and extra payload keys', () async {
      Map<String, dynamic>? sentBody;

      final EnrollmentService service = _buildService((RequestOptions options) {
        if (options.path.contains('/enrollments/register')) {
          sentBody = Map<String, dynamic>.from(options.data as Map);
          return <String, dynamic>{
            'statusCode': 201,
            'data': _sampleEnrollmentJson(),
          };
        }
        return <String, dynamic>{
          'statusCode': 404,
          'data': <String, dynamic>{},
        };
      });

      final result = await service.register(5, <String, dynamic>{
        'source': 'join_button',
      });

      expect(result.isSuccess, isTrue);
      expect(sentBody, isNotNull);
      expect(sentBody!['sectionId'], 5);
      expect(sentBody!['source'], 'join_button');
    });

    test('register surfaces representative backend conflict failure', () async {
      final EnrollmentService service = _buildService((RequestOptions options) {
        if (options.path.contains('/enrollments/register')) {
          return <String, dynamic>{
            'statusCode': 409,
            'data': <String, dynamic>{
              'message': 'Already enrolled in this course',
            },
          };
        }
        return <String, dynamic>{
          'statusCode': 404,
          'data': <String, dynamic>{},
        };
      });

      final result = await service.register(5, <String, dynamic>{});

      expect(result.isFailure, isTrue);
      expect(result.error?.statusCode, 409);
      expect(result.error?.message, contains('Already enrolled'));
    });
  });
}
