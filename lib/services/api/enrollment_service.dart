import 'core_api_client.dart';
import '../../common/retry_helper.dart';
import '../../common/service_error.dart';
import '../../models/core/enrollment_model.dart';
import '../../models/instructor/teaching_course_model.dart';
import '../../models/ta/ta_assignment_model.dart';

/// Service for Enrollment API endpoints.
///
/// Wraps all `/api/enrollments` calls.
class EnrollmentService {
  final CoreApiClient _client;

  EnrollmentService({required CoreApiClient coreApiClient})
    : _client = coreApiClient;

  /// GET /api/enrollments/my-enrollments
  Future<ServiceResult<List<CourseEnrollmentModel>>> getMyEnrollments({
    int? semester,
  }) {
    return RetryHelper.execute<List<CourseEnrollmentModel>>(() async {
      final queryParams = semester != null
          ? <String, dynamic>{'semester': semester}
          : null;

      final response = await _client.dio.get(
        '/enrollments/my-enrollments',
        queryParameters: queryParams,
      );

      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(CourseEnrollmentModel.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to load your enrollments');
  }

  /// GET /api/enrollments/my-courses
  Future<ServiceResult<List<CourseEnrollmentModel>>> getMyCourses() {
    return RetryHelper.execute<List<CourseEnrollmentModel>>(() async {
      final response = await _client.dio.get('/enrollments/my-courses');
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(CourseEnrollmentModel.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to load your courses');
  }

  /// GET /api/enrollments/teaching
  Future<ServiceResult<List<TeachingCourseModel>>> getTeachingCourses() {
    return RetryHelper.execute<List<TeachingCourseModel>>(() async {
      final response = await _client.dio.get('/enrollments/teaching');
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(TeachingCourseModel.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to load teaching courses');
  }

  /// GET /api/enrollments/available
  Future<ServiceResult<List<CourseEnrollmentModel>>> getAvailableCourses() {
    return RetryHelper.execute<List<CourseEnrollmentModel>>(() async {
      final response = await _client.dio.get('/enrollments/available');
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(CourseEnrollmentModel.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to load available courses');
  }

  /// GET /api/enrollments/{enrollmentId}
  Future<ServiceResult<CourseEnrollmentModel>> getEnrollmentById(
    dynamic enrollmentId,
  ) {
    return RetryHelper.execute<CourseEnrollmentModel>(() async {
      final response = await _client.dio.get('/enrollments/$enrollmentId');
      return CourseEnrollmentModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to load enrollment details');
  }

  /// GET /api/enrollments/course/{courseId}/list
  Future<ServiceResult<List<CourseEnrollmentModel>>> getCourseEnrollments(
    dynamic courseId,
  ) {
    return RetryHelper.execute<List<CourseEnrollmentModel>>(() async {
      final response = await _client.dio.get(
        '/enrollments/course/$courseId/list',
      );
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(CourseEnrollmentModel.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to load course enrollments');
  }

  /// GET /api/enrollments/sections/:id/students
  Future<ServiceResult<List<CourseEnrollmentModel>>> getSectionStudents(
    dynamic sectionId,
  ) {
    return RetryHelper.execute<List<CourseEnrollmentModel>>(() async {
      final response = await _client.dio.get(
        '/enrollments/sections/$sectionId/students',
      );
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(CourseEnrollmentModel.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to load section students');
  }

  /// GET /api/enrollments/section/{sectionId}/waitlist
  Future<ServiceResult<List<CourseEnrollmentModel>>> getSectionWaitlist(
    dynamic sectionId,
  ) {
    return RetryHelper.execute<List<CourseEnrollmentModel>>(() async {
      final response = await _client.dio.get(
        '/enrollments/section/$sectionId/waitlist',
      );
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(CourseEnrollmentModel.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to load section waitlist');
  }

  /// GET /api/enrollments/sections/{sectionId}/tas
  Future<ServiceResult<List<TAAssignmentModel>>> getSectionTAs(
    dynamic sectionId,
  ) {
    return RetryHelper.execute<List<TAAssignmentModel>>(() async {
      final response = await _client.dio.get(
        '/enrollments/sections/$sectionId/tas',
      );
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(TAAssignmentModel.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to load section TAs');
  }

  /// GET /api/enrollments/sections/:id/instructors
  Future<ServiceResult<List<EnrollmentModel>>> getSectionInstructors(
    dynamic sectionId,
  ) {
    return RetryHelper.execute<List<EnrollmentModel>>(() async {
      final response = await _client.dio.get(
        '/enrollments/sections/$sectionId/instructors',
      );
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(EnrollmentModel.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to load section instructors');
  }

  /// POST /api/enrollments/register
  Future<ServiceResult<CourseEnrollmentModel>> register(
    dynamic sectionId,
    Map<String, dynamic> data,
  ) {
    return RetryHelper.execute<CourseEnrollmentModel>(() async {
      final body = <String, dynamic>{'sectionId': sectionId, ...data};
      final response = await _client.dio.post(
        '/enrollments/register',
        data: body,
      );
      return CourseEnrollmentModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to register enrollment');
  }

  /// DELETE /api/enrollments/:id
  Future<ServiceResult<void>> dropEnrollment(dynamic id) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.delete('/enrollments/$id');
    }, fallbackMessage: 'Failed to drop enrollment');
  }

  /// POST /api/enrollments/sections/:id/instructors
  Future<ServiceResult<void>> assignInstructor(dynamic sectionId, int userId) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.post(
        '/enrollments/sections/$sectionId/instructors',
        data: <String, dynamic>{'userId': userId},
      );
    }, fallbackMessage: 'Failed to assign instructor');
  }

  /// DELETE /api/enrollments/sections/:id/instructors/:enrollmentId
  Future<ServiceResult<void>> removeInstructor(
    dynamic sectionId,
    dynamic enrollmentId,
  ) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.delete(
        '/enrollments/sections/$sectionId/instructors/$enrollmentId',
      );
    }, fallbackMessage: 'Failed to remove instructor');
  }

  /// POST /api/enrollments/sections/:id/tas
  Future<ServiceResult<void>> assignTA(dynamic sectionId, int userId) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.post(
        '/enrollments/sections/$sectionId/tas',
        data: <String, dynamic>{'userId': userId},
      );
    }, fallbackMessage: 'Failed to assign TA');
  }

  /// DELETE /api/enrollments/sections/:id/tas/:enrollmentId
  Future<ServiceResult<void>> removeTA(
    dynamic sectionId,
    dynamic enrollmentId,
  ) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.delete(
        '/enrollments/sections/$sectionId/tas/$enrollmentId',
      );
    }, fallbackMessage: 'Failed to remove TA');
  }

  static Map<String, dynamic> _extractMap(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      return payload;
    }
    return <String, dynamic>{};
  }

  static List<dynamic> _extractList(dynamic payload) {
    if (payload is List) {
      return payload;
    }
    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is List) {
        return data;
      }

      for (final value in payload.values) {
        if (value is List) {
          return value;
        }
      }
    }
    return <dynamic>[];
  }
}
