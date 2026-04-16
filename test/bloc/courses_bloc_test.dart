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
