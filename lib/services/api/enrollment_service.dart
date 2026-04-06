import 'core_api_client.dart';
import '../../models/core/enrollment_model.dart';
import '../../models/instructor/teaching_course_model.dart';

/// Service for Enrollment API endpoints.
///
/// Wraps all `/api/enrollments` calls.
class EnrollmentService {
  final CoreApiClient _client;

  EnrollmentService({required CoreApiClient coreApiClient})
    : _client = coreApiClient;

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
    final List data = response.data is List
        ? response.data as List
        : (response.data['data'] as List?) ?? [];
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
}
