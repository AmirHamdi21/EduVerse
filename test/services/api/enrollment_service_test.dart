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

  group('EnrollmentService registration catalog contracts', () {
    test('parses available courses using registration model shape', () async {
      final EnrollmentService service = _buildService((RequestOptions options) {
        if (options.path.contains('/enrollments/available')) {
          return <String, dynamic>{
            'statusCode': 200,
            'data': <Map<String, dynamic>>[
              <String, dynamic>{
                'id': 77,
                'name': 'Data Structures',
                'code': 'CS201',
                'description': 'Core data structures and analysis',
                'credits': 3,
                'level': 'sophomore',
                'departmentId': 1,
                'departmentName': 'Computer Science',
                'canEnroll': true,
                'enrollmentStatus': null,
                'prerequisites': <Map<String, dynamic>>[
                  <String, dynamic>{
                    'id': 4,
                    'courseId': 77,
                    'prerequisiteCourseId': 12,
                    'courseCode': 'CS101',
                    'courseName': 'Programming Fundamentals',
                    'isMandatory': true,
                  },
                ],
                'sections': <Map<String, dynamic>>[
                  <String, dynamic>{
                    'id': 31,
                    'sectionNumber': 'A',
                    'maxCapacity': 40,
                    'currentEnrollment': 32,
                    'availableSeats': 8,
                    'location': 'B-201',
                    'semesterId': 2,
                    'semesterName': 'Fall 2026',
                  },
                ],
              },
            ],
          };
        }
        return <String, dynamic>{
          'statusCode': 404,
          'data': <String, dynamic>{},
        };
      });

      final result = await service.getAvailableCourses();

      expect(result.isSuccess, isTrue);
      expect(result.data, isNotNull);
      expect(result.data!.length, 1);
      expect(result.data!.first.code, 'CS201');
      expect(result.data!.first.sections.first.availableSeats, 8);
      expect(result.data!.first.prerequisites.first.courseCode, 'CS101');
    });

    test(
      'missing enrollmentStatus is normalized to not_enrolled safely',
      () async {
        final EnrollmentService service = _buildService((
          RequestOptions options,
        ) {
          if (options.path.contains('/enrollments/available')) {
            return <String, dynamic>{
              'statusCode': 200,
              'data': <Map<String, dynamic>>[
                <String, dynamic>{
                  'id': 88,
                  'name': 'Algorithms',
                  'code': 'CS301',
                  'description': '',
                  'credits': 3,
                  'level': 'junior',
                  'departmentId': 1,
                  'departmentName': 'Unknown',
                  'canEnroll': false,
                  'sections': <Map<String, dynamic>>[],
                  'prerequisites': <Map<String, dynamic>>[],
                },
              ],
            };
          }
          return <String, dynamic>{
            'statusCode': 404,
            'data': <String, dynamic>{},
          };
        });

        final result = await service.getAvailableCourses();

        expect(result.isSuccess, isTrue);
        expect(result.data, isNotNull);
        expect(result.data!.first.enrollmentStatus, isNull);
        expect(result.data!.first.normalizedEnrollmentStatus, 'not_enrolled');
        expect(result.data!.first.isAlreadyEnrolled, isFalse);
      },
    );

    test('passes registration filters as query parameters', () async {
      Map<String, dynamic>? observedQuery;

      final EnrollmentService service = _buildService((RequestOptions options) {
        if (options.path.contains('/enrollments/available')) {
          observedQuery = options.queryParameters;
          return <String, dynamic>{'statusCode': 200, 'data': <dynamic>[]};
        }
        return <String, dynamic>{
          'statusCode': 404,
          'data': <String, dynamic>{},
        };
      });

      final result = await service.getAvailableCourses(
        departmentId: 3,
        semesterId: 2,
        search: 'data',
        level: 'sophomore',
        page: 2,
        limit: 10,
      );

      expect(result.isSuccess, isTrue);
      expect(observedQuery, isNotNull);
      expect(observedQuery!['departmentId'], 3);
      expect(observedQuery!['semesterId'], 2);
      expect(observedQuery!['search'], 'data');
      expect(observedQuery!['level'], 'sophomore');
      expect(observedQuery!['page'], 2);
      expect(observedQuery!['limit'], 10);
    });
  });

  group('EnrollmentService enrollment periods', () {
    test('loads periods from /enrollments/periods', () async {
      final EnrollmentService service = _buildService((RequestOptions options) {
        if (options.path.contains('/enrollments/periods')) {
          return <String, dynamic>{
            'statusCode': 200,
            'data': <Map<String, dynamic>>[
              <String, dynamic>{
                'id': 2,
                'semesterName': 'Fall 2026',
                'semesterCode': 'FALL2026',
                'registrationStart': '2026-07-20',
                'registrationEnd': '2026-08-10',
                'semesterStart': '2026-08-15',
                'semesterEnd': '2026-12-20',
                'status': 'upcoming',
              },
            ],
          };
        }
        return <String, dynamic>{
          'statusCode': 404,
          'data': <String, dynamic>{},
        };
      });

      final result = await service.getEnrollmentPeriods();

      expect(result.isSuccess, isTrue);
      expect(result.data, isNotNull);
      expect(result.data!.length, 1);
      expect(result.data!.first.id, 2);
      expect(result.data!.first.semester, 'Fall 2026');
      expect(result.data!.first.status, 'upcoming');
      expect(result.data!.first.registrationStart, isNotNull);
    });
  });

  group('EnrollmentService register parity', () {
    test('registerForSection sends section-only payload', () async {
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

      final result = await service.registerForSection(sectionId: 5);

      expect(result.isSuccess, isTrue);
      expect(sentBody, isNotNull);
      expect(sentBody, <String, dynamic>{'sectionId': 5});
    });

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

  group('EnrollmentService section staff endpoint compatibility', () {
    test('getSectionTAs falls back to singular section path', () async {
      final observedPaths = <String>[];

      final EnrollmentService service = _buildService((RequestOptions options) {
        observedPaths.add(options.path);

        if (options.path == '/enrollments/sections/5/tas') {
          throw DioException(
            requestOptions: options,
            response: Response<dynamic>(
              requestOptions: options,
              statusCode: 404,
            ),
            type: DioExceptionType.badResponse,
          );
        }

        if (options.path == '/enrollments/section/5/tas') {
          return <String, dynamic>{
            'statusCode': 200,
            'data': <Map<String, dynamic>>[
              <String, dynamic>{
                'id': 1,
                'sectionId': 5,
                'userId': 90,
                'firstName': 'Nora',
                'lastName': 'Ibrahim',
                'email': 'nora@eduverse.test',
                'assignedAt': '2026-04-01T10:00:00.000Z',
              },
            ],
          };
        }

        return <String, dynamic>{
          'statusCode': 404,
          'data': <String, dynamic>{},
        };
      });

      final result = await service.getSectionTAs(5);

      expect(result.isSuccess, isTrue);
      expect(result.data, isNotNull);
      expect(result.data!.length, 1);
      expect(observedPaths, <String>[
        '/enrollments/sections/5/tas',
        '/enrollments/section/5/tas',
      ]);
    });

    test(
      'getSectionInstructors falls back to singular instructor path',
      () async {
        final observedPaths = <String>[];

        final EnrollmentService service = _buildService((
          RequestOptions options,
        ) {
          observedPaths.add(options.path);

          if (options.path == '/enrollments/sections/8/instructors') {
            throw DioException(
              requestOptions: options,
              response: Response<dynamic>(
                requestOptions: options,
                statusCode: 404,
              ),
              type: DioExceptionType.badResponse,
            );
          }

          if (options.path == '/enrollments/section/8/instructor') {
            return <String, dynamic>{
              'statusCode': 200,
              'data': <Map<String, dynamic>>[
                <String, dynamic>{
                  'id': 4,
                  'sectionId': 8,
                  'userId': 12,
                  'firstName': 'Adam',
                  'lastName': 'Mostafa',
                  'email': 'adam@eduverse.test',
                  'role': 'primary',
                },
              ],
            };
          }

          return <String, dynamic>{
            'statusCode': 404,
            'data': <String, dynamic>{},
          };
        });

        final result = await service.getSectionInstructors(8);

        expect(result.isSuccess, isTrue);
        expect(result.data, isNotNull);
        expect(result.data!.length, 1);
        expect(result.data!.first.userId, 12);
        expect(observedPaths, <String>[
          '/enrollments/sections/8/instructors',
          '/enrollments/section/8/instructor',
        ]);
      },
    );

    test('getSectionInstructors parses singular object payloads', () async {
      final EnrollmentService service = _buildService((RequestOptions options) {
        if (options.path == '/enrollments/sections/9/instructors') {
          return <String, dynamic>{
            'statusCode': 200,
            'data': <String, dynamic>{
              'id': 6,
              'sectionId': 9,
              'userId': 44,
              'role': 'primary',
              'firstName': 'Laila',
              'lastName': 'Hassan',
              'email': 'laila@eduverse.test',
            },
          };
        }

        return <String, dynamic>{
          'statusCode': 404,
          'data': <String, dynamic>{},
        };
      });

      final result = await service.getSectionInstructors(9);

      expect(result.isSuccess, isTrue);
      expect(result.data, isNotNull);
      expect(result.data!.length, 1);
      expect(result.data!.first.userId, 44);
      expect(result.data!.first.fullName, 'Laila Hassan');
    });
  });
}
