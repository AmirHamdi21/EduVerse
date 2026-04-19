import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:edu_verse/bloc/courses/courses_bloc.dart';
import 'package:edu_verse/bloc/courses/courses_event.dart';
import 'package:edu_verse/bloc/courses/courses_state.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/course_service.dart';
import 'package:edu_verse/services/api/enrollment_service.dart';
import 'package:edu_verse/services/api/material_service.dart';
import 'package:edu_verse/services/api/communication_service.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A simple mock adapter that returns predefined responses.
class _MockAdapter implements HttpClientAdapter {
  final Map<String, dynamic> Function(RequestOptions) handler;

  _MockAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final result = handler(options);
    final statusCode = result['statusCode'] as int? ?? 200;
    final data = result['data'];

    return ResponseBody.fromString(
      data is String ? data : _encodeJson(data),
      statusCode,
      headers: {
        'content-type': ['application/json'],
      },
    );
  }

  String _encodeJson(dynamic data) {
    if (data is List) {
      return '[${data.map(_encodeValue).join(',')}]';
    }
    if (data is Map) {
      return _encodeMap(data);
    }
    return data.toString();
  }

  String _encodeValue(dynamic value) {
    if (value is String) return '"$value"';
    if (value is Map) return _encodeMap(value);
    if (value is List) return '[${value.map(_encodeValue).join(',')}]';
    if (value is bool) return '$value';
    return '$value';
  }

  String _encodeMap(dynamic map) {
    if (map is! Map) return _encodeValue(map);
    final entries = map.entries.map(
      (e) => '"${e.key}":${_encodeValue(e.value)}',
    );
    return '{${entries.join(',')}}';
  }

  @override
  void close({bool force = false}) {}
}

/// Helper to build a CoursesBloc wired to a mock adapter.
/// Uses CoreApiClient.test() to avoid FlutterSecureStorage platform channels.
CoursesBloc _buildBloc(Map<String, dynamic> Function(RequestOptions) handler) {
  final coreApiClient = CoreApiClient.test();
  coreApiClient.dio.httpClientAdapter = _MockAdapter(handler);

  return CoursesBloc(
    courseService: CourseService(coreApiClient: coreApiClient),
    enrollmentService: EnrollmentService(coreApiClient: coreApiClient),
    materialService: MaterialService(coreApiClient: coreApiClient),
    communicationService: CommunicationService(coreApiClient: coreApiClient),
  );
}

void main() {
  // Initialize SharedPreferences with empty values for tests.
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CoursesBloc', () {
    test('initial state is CoursesInitial', () {
      final bloc = _buildBloc((_) => {'data': []});
      expect(bloc.state, isA<CoursesInitial>());
      bloc.close();
    });

    test(
      'StudentCoursesFetched emits [CoursesLoading, CoursesLoaded] on success',
      () async {
        final bloc = _buildBloc((options) {
          if (options.path.contains('/enrollments/my-courses')) {
            return {
              'statusCode': 200,
              'data': [
                {
                  'id': '1',
                  'courseId': '1',
                  'userId': 42,
                  'enrollmentDate': '2026-01-15T00:00:00.000Z',
                  'role': 'student',
                  'status': 'active',
                  'createdAt': '2026-01-15T00:00:00.000Z',
                  'updatedAt': '2026-01-15T00:00:00.000Z',
                },
              ],
            };
          }
          return {'data': []};
        });

        bloc.add(const StudentCoursesFetched());

        await expectLater(
          bloc.stream,
          emitsInOrder([isA<CoursesLoading>(), isA<CoursesLoaded>()]),
        );

        final loaded = bloc.state as CoursesLoaded;
        expect(loaded.enrollments.length, 1);
        expect(loaded.enrollments.first.role, 'student');

        await bloc.close();
      },
    );

    test('StudentCoursesFetched forwards optional semester payload', () async {
      int? observedSemester;

      final bloc = _buildBloc((options) {
        if (options.path.contains('/enrollments/my-courses')) {
          observedSemester = options.queryParameters['semester'] as int?;
          return {
            'statusCode': 200,
            'data': [
              {
                'id': '11',
                'userId': 42,
                'sectionId': 7,
                'status': 'enrolled',
                'enrollmentDate': '2026-01-15T00:00:00.000Z',
                'course': {
                  'id': 1,
                  'code': 'CS101',
                  'name': 'Intro',
                  'credits': 3,
                  'level': 'freshman',
                },
                'semester': {'id': 3, 'name': 'Fall 2026'},
              },
            ],
          };
        }
        return {'data': []};
      });

      bloc.add(const StudentCoursesFetched(semester: 3));

      await expectLater(
        bloc.stream,
        emitsInOrder([isA<CoursesLoading>(), isA<CoursesLoaded>()]),
      );

      expect(observedSemester, 3);
      await bloc.close();
    });

    test(
      'AllCoursesFetched emits [CoursesLoading, AllCoursesLoaded] on success',
      () async {
        final bloc = _buildBloc((options) {
          if (options.path.contains('/courses') &&
              !options.path.contains('/enrollments')) {
            return {
              'statusCode': 200,
              'data': [
                {
                  'courseId': 1,
                  'courseCode': 'CS101',
                  'courseName': 'Intro',
                  'credits': 3,
                },
              ],
            };
          }
          return {'data': []};
        });

        bloc.add(const AllCoursesFetched());

        await expectLater(
          bloc.stream,
          emitsInOrder([isA<CoursesLoading>(), isA<AllCoursesLoaded>()]),
        );

        final loaded = bloc.state as AllCoursesLoaded;
        expect(loaded.courses.length, 1);
        expect(loaded.courses.first.courseCode, 'CS101');

        await bloc.close();
      },
    );

    test('AnnouncementsFetched forwards optional courseId query', () async {
      dynamic observedCourseId;

      final bloc = _buildBloc((options) {
        if (options.path.contains('/announcements')) {
          observedCourseId = options.queryParameters['courseId'];
          return {
            'statusCode': 200,
            'data': [
              {
                'id': 'a-1',
                'courseId': '22',
                'title': 'Announcement',
                'content': 'Scoped announcement',
                'createdBy': 7,
                'priority': 'high',
                'publishedAt': '2026-04-01T00:00:00.000Z',
                'createdAt': '2026-04-01T00:00:00.000Z',
                'updatedAt': '2026-04-01T00:00:00.000Z',
              },
            ],
          };
        }
        return {'statusCode': 200, 'data': []};
      });

      bloc.add(const AnnouncementsFetched(courseId: 22));

      await expectLater(
        bloc.stream,
        emitsInOrder([isA<CoursesLoading>(), isA<AnnouncementsLoaded>()]),
      );

      expect(observedCourseId, 22);

      await bloc.close();
    });

    test(
      'StudentCoursesFetched emits CoursesError when network fails and no cache',
      () async {
        final bloc = _buildBloc((options) {
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionTimeout,
            message: 'Connection timeout',
          );
        });

        bloc.add(const StudentCoursesFetched());

        await expectLater(
          bloc.stream,
          emitsInOrder([isA<CoursesLoading>(), isA<CoursesError>()]),
        );

        final errorState = bloc.state as CoursesError;
        expect(errorState.message, isNotEmpty);

        await bloc.close();
      },
    );

    test(
      'StudentCoursesFetched falls back to cached enrollments when network fails',
      () async {
        SharedPreferences.setMockInitialValues({
          'courses_cache_enrollments': jsonEncode([
            {
              'id': 'cached-1',
              'userId': 42,
              'sectionId': 7,
              'status': 'enrolled',
              'enrollmentDate': '2026-01-15T00:00:00.000Z',
              'course': {
                'id': 101,
                'code': 'CS101',
                'name': 'Intro to Programming',
                'credits': 3,
                'level': 'freshman',
              },
              'section': {
                'id': 7,
                'sectionNumber': 'A',
                'maxCapacity': 30,
                'currentEnrollment': 28,
              },
              'semester': {'id': 1, 'name': 'Fall 2026'},
            },
          ]),
        });

        final bloc = _buildBloc((options) {
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
            message: 'Offline',
          );
        });

        bloc.add(const StudentCoursesFetched());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            isA<CoursesLoading>().having(
              (state) => state.cachedData.length,
              'cachedData length',
              greaterThan(0),
            ),
            isA<CoursesLoaded>(),
          ]),
        );

        final loaded = bloc.state as CoursesLoaded;
        expect(loaded.enrollments.length, 1);
        expect(loaded.enrollments.first.course?.courseCode, 'CS101');

        await bloc.close();
      },
    );

    test(
      'StudentCoursesFetched emits auth/session state on unauthorized response',
      () async {
        final bloc = _buildBloc((options) {
          if (options.path.contains('/enrollments/my-courses')) {
            return {
              'statusCode': 401,
              'data': {'message': 'Unauthorized'},
            };
          }
          return {'data': []};
        });

        bloc.add(const StudentCoursesFetched());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            isA<CoursesLoading>(),
            isA<CoursesAuthSessionRequired>(),
          ]),
        );

        final state = bloc.state as CoursesAuthSessionRequired;
        expect(state.statusCode, 401);

        await bloc.close();
      },
    );

    test(
      'StudentCoursesFetched emits auth/session state on forbidden response',
      () async {
        final bloc = _buildBloc((options) {
          if (options.path.contains('/enrollments/my-courses')) {
            return {
              'statusCode': 403,
              'data': {'message': 'Forbidden'},
            };
          }
          return {'data': []};
        });

        bloc.add(const StudentCoursesFetched());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            isA<CoursesLoading>(),
            isA<CoursesAuthSessionRequired>(),
          ]),
        );

        final state = bloc.state as CoursesAuthSessionRequired;
        expect(state.statusCode, 403);

        await bloc.close();
      },
    );

    test(
      'StudentCoursesFetched handles null nested enrollment payload fields',
      () async {
        final bloc = _buildBloc((options) {
          if (options.path.contains('/enrollments/my-courses')) {
            return {
              'statusCode': 200,
              'data': [
                {
                  'id': 'null-nested-1',
                  'userId': 42,
                  'sectionId': 7,
                  'status': 'enrolled',
                  'enrollmentDate': '2026-01-15T00:00:00.000Z',
                  'course': null,
                  'section': null,
                  'semester': null,
                  'instructor': null,
                  'prerequisites': null,
                },
              ],
            };
          }
          return {'data': []};
        });

        bloc.add(const StudentCoursesFetched());

        await expectLater(
          bloc.stream,
          emitsInOrder([isA<CoursesLoading>(), isA<CoursesLoaded>()]),
        );

        final loaded = bloc.state as CoursesLoaded;
        expect(loaded.enrollments.length, 1);
        expect(loaded.enrollments.first.course, isNull);
        expect(loaded.enrollments.first.section, isNull);
        expect(loaded.enrollments.first.semester, isNull);

        await bloc.close();
      },
    );

    test(
      'rapid semester fetch events settle on latest response data',
      () async {
        final bloc = _buildBloc((options) {
          if (options.path.contains('/enrollments/my-courses')) {
            final semester = options.queryParameters['semester'] as int?;
            if (semester == 1) {
              return {
                'statusCode': 200,
                'data': [
                  {
                    'id': 'rapid-1',
                    'userId': 42,
                    'sectionId': 1,
                    'status': 'enrolled',
                    'enrollmentDate': '2026-01-15T00:00:00.000Z',
                    'course': {
                      'id': 11,
                      'code': 'CS101',
                      'name': 'Intro',
                      'credits': 3,
                      'level': 'freshman',
                    },
                    'semester': {'id': 1, 'name': 'Fall 2026'},
                  },
                ],
              };
            }
            if (semester == 2) {
              return {
                'statusCode': 200,
                'data': [
                  {
                    'id': 'rapid-2',
                    'userId': 42,
                    'sectionId': 2,
                    'status': 'enrolled',
                    'enrollmentDate': '2026-01-16T00:00:00.000Z',
                    'course': {
                      'id': 22,
                      'code': 'CS202',
                      'name': 'Data Structures',
                      'credits': 4,
                      'level': 'sophomore',
                    },
                    'semester': {'id': 2, 'name': 'Spring 2027'},
                  },
                ],
              };
            }
          }
          return {'data': []};
        });

        bloc.add(const StudentCoursesFetched(semester: 1));
        bloc.add(const StudentCoursesFetched(semester: 2));

        await expectLater(bloc.stream, emitsThrough(isA<CoursesLoaded>()));

        await Future<void>.delayed(const Duration(milliseconds: 20));

        final loaded = bloc.state as CoursesLoaded;
        expect(loaded.enrollments.length, 1);
        expect(loaded.enrollments.first.course?.courseCode, 'CS202');
        expect(loaded.enrollments.first.semester?.id, 2);

        await bloc.close();
      },
    );

    test('AnnouncementsFetched emits AnnouncementsLoaded on success', () async {
      final bloc = _buildBloc((options) {
        if (options.path.contains('/announcements')) {
          return {
            'statusCode': 200,
            'data': [
              {
                'id': 'ann-1',
                'courseId': '1',
                'title': 'Test Announcement',
                'content': 'Hello',
                'createdBy': 5,
                'priority': 'high',
                'publishedAt': '2026-01-10T00:00:00.000Z',
                'createdAt': '2026-01-10T00:00:00.000Z',
                'updatedAt': '2026-01-10T00:00:00.000Z',
              },
            ],
          };
        }
        return {'data': []};
      });

      bloc.add(const AnnouncementsFetched());

      await expectLater(
        bloc.stream,
        emitsInOrder([isA<CoursesLoading>(), isA<AnnouncementsLoaded>()]),
      );

      final loaded = bloc.state as AnnouncementsLoaded;
      expect(loaded.announcements.length, 1);

      await bloc.close();
    });

    test('AssignmentsFetched emits AssignmentsLoaded on success', () async {
      final bloc = _buildBloc((options) {
        if (options.path.contains('/assignments')) {
          return {
            'statusCode': 200,
            'data': [
              {
                'id': 'asgn-1',
                'courseId': '1',
                'title': 'HW1',
                'maxScore': '100',
                'weight': '10',
                'status': 'published',
                'submissionType': 'file',
                'createdAt': '2026-01-20T08:00:00.000Z',
                'updatedAt': '2026-01-20T08:00:00.000Z',
              },
            ],
          };
        }
        return {'data': []};
      });

      bloc.add(const AssignmentsFetched());

      await expectLater(
        bloc.stream,
        emitsInOrder([isA<CoursesLoading>(), isA<AssignmentsLoaded>()]),
      );

      final loaded = bloc.state as AssignmentsLoaded;
      expect(loaded.assignments.length, 1);
      expect(loaded.assignments.first.title, 'HW1');

      await bloc.close();
    });
  });
}
