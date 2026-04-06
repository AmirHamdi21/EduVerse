import 'core_api_client.dart';
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
  /// Returns the current student's enrollments.
  Future<List<CourseEnrollmentModel>> getMyEnrollments({int? semester}) async {
    final queryParams = semester != null ? {'semester': semester} : null;
    final response = await _client.dio.get(
      '/enrollments/my-enrollments',
      queryParameters: queryParams,
    );

    List data = [];
    if (response.data is List) {
      data = response.data;
    } else if (response.data is Map) {
      final map = response.data as Map<String, dynamic>;
      if (map.containsKey('data') && map['data'] is List) {
        data = map['data'];
      } else {
        for (var value in map.values) {
          if (value is List) {
            data = value;
            break;
          }
        }
      }
    }

    return data
        .map((e) => CourseEnrollmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/enrollments/my-courses
  /// Returns the authenticated student's enrolled courses.
  Future<List<CourseEnrollmentModel>> getMyCourses() async {
    final response = await _client.dio.get('/enrollments/my-courses');
    final List data = response.data is List
        ? response.data as List
        : (response.data['data'] as List?) ?? [];
    return data
        .map((e) => CourseEnrollmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/enrollments/teaching
  /// Returns sections assigned to the current instructor or TA.
  Future<List<TeachingCourseModel>> getTeachingCourses() async {
    final response = await _client.dio.get('/enrollments/teaching');
    List data = [];

    if (response.data is List) {
      data = response.data;
    } else if (response.data is Map) {
      final map = response.data as Map<String, dynamic>;
      if (map.containsKey('data') && map['data'] is List) {
        data = map['data'];
      } else {
        // Find any value that is a List
        for (var value in map.values) {
          if (value is List) {
            data = value;
            break;
          }
        }
      }
    }

    return data
        .map((e) => TeachingCourseModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/enrollments/available
  /// Returns available courses for enrollment.
  Future<List<CourseEnrollmentModel>> getAvailableCourses() async {
    final response = await _client.dio.get('/enrollments/available');
    final List data = response.data is List
        ? response.data as List
        : (response.data['data'] as List?) ?? [];
    return data
        .map((e) => CourseEnrollmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/enrollments/{enrollmentId}
  /// Returns details for a specific enrollment.
  Future<CourseEnrollmentModel> getEnrollmentById(dynamic enrollmentId) async {
    final response = await _client.dio.get('/enrollments/$enrollmentId');
    final Map<String, dynamic> data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : (response.data['data'] as Map<String, dynamic>?) ?? {};
    return CourseEnrollmentModel.fromJson(data);
  }

  /// GET /api/enrollments/course/{courseId}/list
  /// Instructor view of all enrollments in a course.
  Future<List<CourseEnrollmentModel>> getCourseEnrollments(
    dynamic courseId,
  ) async {
    final response = await _client.dio.get(
      '/enrollments/course/$courseId/list',
    );
    final List data = response.data is List
        ? response.data as List
        : (response.data['data'] as List?) ?? [];
    return data
        .map((e) => CourseEnrollmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/enrollments/section/{sectionId}/students
  /// Returns students in a specific section.
  Future<List<CourseEnrollmentModel>> getSectionStudents(
    dynamic sectionId,
  ) async {
    final response = await _client.dio.get(
      '/enrollments/section/$sectionId/students',
    );
    final List data = response.data is List
        ? response.data as List
        : (response.data['data'] as List?) ?? [];
    return data
        .map((e) => CourseEnrollmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/enrollments/section/{sectionId}/waitlist
  /// Instructor view of section waitlist.
  Future<List<CourseEnrollmentModel>> getSectionWaitlist(
    dynamic sectionId,
  ) async {
    final response = await _client.dio.get(
      '/enrollments/section/$sectionId/waitlist',
    );
    final List data = response.data is List
        ? response.data as List
        : (response.data['data'] as List?) ?? [];
    return data
        .map((e) => CourseEnrollmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/enrollments/sections/{sectionId}/tas
  /// Returns TAs assigned to a specific section.
  Future<List<TAAssignmentModel>> getSectionTAs(dynamic sectionId) async {
    final response = await _client.dio.get(
      '/enrollments/sections/$sectionId/tas',
    );
    final List data = response.data is List
        ? response.data as List
        : (response.data['data'] as List?) ?? [];
    return data
        .map((e) => TAAssignmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
