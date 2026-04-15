import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:edu_verse/services/api/course_service.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/models/core/course_model.dart';

/// Mock adapter that captures and returns pre-defined responses.
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
      data is String ? data : _encodeJson(data),
      statusCode,
      headers: {
        'content-type': ['application/json'],
      },
    );
  }

  String _encodeJson(dynamic data) {
    if (data is List) {
      return '[${data.map((e) => _encodeMap(e)).join(',')}]';
    }
    if (data is Map) {
      return _encodeMap(data);
    }
    return data.toString();
  }

  String _encodeMap(dynamic map) {
    if (map is! Map) return map.toString();
    final entries = map.entries.map((e) {
      final value = e.value;
      final valueStr = value is String
          ? '"$value"'
          : value is Map
          ? _encodeMap(value)
          : value is List
          ? '[${value.map((v) => v is String
                ? '"$v"'
                : v is Map
                ? _encodeMap(v)
                : v).join(',')}]'
          : '$value';
      return '"${e.key}":$valueStr';
    });
    return '{${entries.join(',')}}';
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late CoreApiClient coreApiClient;
  late CourseService courseService;

  group('CourseService - Parameter Serialization', () {
    test('getAllCourses sends GET to /courses', () async {
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
              'courseCode': 'CS101',
              'courseName': 'Intro',
              'credits': 3,
            },
          ],
        };
      });

      courseService = CourseService(coreApiClient: coreApiClient);
      final result = await courseService.getAllCourses();

      expect(capturedMethod, 'GET');
      expect(capturedPath, contains('/courses'));
      expect(result.length, 1);
      expect(result.first, isA<CourseModel>());
      expect(result.first.courseCode, 'CS101');
    });

    test('getCourseById sends GET with courseId in path', () async {
      String? capturedPath;

      coreApiClient = CoreApiClient.test();
      coreApiClient.dio.httpClientAdapter = _MockAdapter((options) {
        capturedPath = options.path;
        return {
          'statusCode': 200,
          'data': {
            'courseId': 42,
            'courseCode': 'MATH200',
            'courseName': 'Linear Algebra',
            'credits': 4,
          },
        };
      });

      courseService = CourseService(coreApiClient: coreApiClient);
      final result = await courseService.getCourseById(42);

      expect(capturedPath, contains('/courses/42'));
      expect(result.courseId, 42);
    });

    test('getCoursesByDepartment sends GET with deptId', () async {
      String? capturedPath;

      coreApiClient = CoreApiClient.test();
      coreApiClient.dio.httpClientAdapter = _MockAdapter((options) {
        capturedPath = options.path;
        return {'statusCode': 200, 'data': <Map<String, dynamic>>[]};
      });

      courseService = CourseService(coreApiClient: coreApiClient);
      final result = await courseService.getCoursesByDepartment(5);

      expect(capturedPath, contains('/courses/department/5'));
      expect(result, isEmpty);
    });

    test('createCourse sends POST with body', () async {
      String? capturedMethod;
      dynamic capturedData;

      coreApiClient = CoreApiClient.test();
      coreApiClient.dio.httpClientAdapter = _MockAdapter((options) {
        capturedMethod = options.method;
        capturedData = options.data;
        return {
          'statusCode': 201,
          'data': {
            'courseId': 99,
            'courseCode': 'NEW101',
            'courseName': 'New Course',
            'credits': 3,
          },
        };
      });

      courseService = CourseService(coreApiClient: coreApiClient);
      final body = {
        'courseCode': 'NEW101',
        'courseName': 'New Course',
        'credits': 3,
      };
      final result = await courseService.createCourse(body);

      expect(capturedMethod, 'POST');
      expect(capturedData, isNotNull);
      expect(result.courseCode, 'NEW101');
    });

    test('getCourseStructure sends GET to /courses/{id}/structure', () async {
      String? capturedPath;

      coreApiClient = CoreApiClient.test();
      coreApiClient.dio.httpClientAdapter = _MockAdapter((options) {
        capturedPath = options.path;
        return {'statusCode': 200, 'data': <Map<String, dynamic>>[]};
      });

      courseService = CourseService(coreApiClient: coreApiClient);
      final result = await courseService.getCourseStructure(1);

      expect(capturedPath, contains('/courses/1/structure'));
      expect(result, isEmpty);
    });
  });
}
