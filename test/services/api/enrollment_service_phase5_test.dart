import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/enrollment_service.dart';

class _QueueAdapter implements HttpClientAdapter {
  _QueueAdapter(this.responses);

  final List<Map<String, dynamic>> responses;
  final List<RequestOptions> requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);

    final next = responses.isNotEmpty
        ? responses.removeAt(0)
        : <String, dynamic>{'statusCode': 200, 'data': <String, dynamic>{}};

    return ResponseBody.fromString(
      jsonEncode(next['data'] ?? <String, dynamic>{}),
      next['statusCode'] as int? ?? 200,
      headers: <String, List<String>>{
        'content-type': <String>['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('EnrollmentService phase5 parsing', () {
    test('parses teaching courses and section students', () async {
      final client = CoreApiClient.test();
      final adapter = _QueueAdapter(<Map<String, dynamic>>[
        <String, dynamic>{
          'statusCode': 200,
          'data': <String, dynamic>{
            'data': <Map<String, dynamic>>[
              <String, dynamic>{
                'sectionId': 15,
                'userId': 9,
                'courseId': 77,
                'role': 'instructor',
                'enrolledCount': 28,
                'capacity': 40,
                'averageGrade': '84.5',
                'attendanceRate': '90.1',
                'course': <String, dynamic>{
                  'id': 77,
                  'departmentId': 1,
                  'code': 'CS500',
                  'name': 'Advanced Topics',
                  'credits': 3,
                  'level': 'senior',
                  'status': 'active',
                },
                'section': <String, dynamic>{
                  'id': 15,
                  'courseId': 77,
                  'semesterId': 2,
                  'sectionNumber': 'B',
                  'maxCapacity': 40,
                  'currentEnrollment': 28,
                  'status': 'active',
                },
                'semester': <String, dynamic>{
                  'id': 2,
                  'name': 'Fall 2026',
                  'term': 'fall',
                  'year': 2026,
                },
              },
            ],
          },
        },
        <String, dynamic>{
          'statusCode': 200,
          'data': <String, dynamic>{
            'data': <Map<String, dynamic>>[
              <String, dynamic>{
                'userId': 101,
                'firstName': 'Mina',
                'lastName': 'Youssef',
                'email': 'mina@example.com',
                'enrollmentStatus': 'enrolled',
                'grade': '88.5',
                'attendanceRate': '95.0',
              },
            ],
          },
        },
      ]);
      client.dio.httpClientAdapter = adapter;

      final service = EnrollmentService(coreApiClient: client);

      final teaching = await service.getTeachingCourses();
      final students = await service.getSectionStudentsLite(15);

      expect(teaching.isSuccess, isTrue);
      expect(teaching.data, isNotNull);
      expect(teaching.data!.length, 1);
      expect(teaching.data!.first.course.courseCode, 'CS500');
      expect(teaching.data!.first.section.sectionNumber, 'B');
      expect(teaching.data!.first.semester.name, 'Fall 2026');
      expect(teaching.data!.first.enrolledCount, 28);

      expect(students.isSuccess, isTrue);
      expect(students.data, isNotNull);
      expect(students.data!.length, 1);
      expect(students.data!.first.fullName, 'Mina Youssef');
      expect(students.data!.first.grade, 88.5);
      expect(students.data!.first.attendanceRate, 95.0);

      expect(adapter.requests[0].path, '/enrollments/teaching');
      expect(adapter.requests[1].path, '/sections/15/students');
    });
  });
}
