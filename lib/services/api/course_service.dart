import 'core_api_client.dart';
import '../../models/core/course_model.dart';
import '../../models/core/course_structure_model.dart';

/// Service for Course and Course Structure API endpoints.
///
/// Wraps all `/api/courses` and `/api/courses/{courseId}/structure` calls.
class CourseService {
  final CoreApiClient _client;

  CourseService({required CoreApiClient coreApiClient})
      : _client = coreApiClient;

  // ── Course Endpoints ──────────────────────────────────────────────────

  /// GET /api/courses
  Future<List<CourseModel>> getAllCourses() async {
    final response = await _client.dio.get('/courses');
    final List data = response.data is List
        ? response.data as List
        : (response.data['data'] as List?) ?? [];
    return data
        .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/courses/{courseId}
  Future<CourseModel> getCourseById(dynamic courseId) async {
    final response = await _client.dio.get('/courses/$courseId');
    final Map<String, dynamic> data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : (response.data['data'] as Map<String, dynamic>?) ?? {};
    return CourseModel.fromJson(data);
  }

  /// GET /api/courses/department/{deptId}
  Future<List<CourseModel>> getCoursesByDepartment(dynamic deptId) async {
    final response = await _client.dio.get('/courses/department/$deptId');
    final List data = response.data is List
        ? response.data as List
        : (response.data['data'] as List?) ?? [];
    return data
        .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/courses/{courseId}/prerequisites
  Future<List<Map<String, dynamic>>> getCoursePrerequisites(
      dynamic courseId) async {
    final response =
        await _client.dio.get('/courses/$courseId/prerequisites');
    final List data = response.data is List
        ? response.data as List
        : (response.data['data'] as List?) ?? [];
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// POST /api/courses
  Future<CourseModel> createCourse(Map<String, dynamic> body) async {
    final response = await _client.dio.post('/courses', data: body);
    final Map<String, dynamic> data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : (response.data['data'] as Map<String, dynamic>?) ?? {};
    return CourseModel.fromJson(data);
  }

  // ── Course Structure Endpoints ────────────────────────────────────────

  /// GET /api/courses/{courseId}/structure
  Future<List<CourseStructureModel>> getCourseStructure(
      dynamic courseId) async {
    final response =
        await _client.dio.get('/courses/$courseId/structure');
    final List data = response.data is List
        ? response.data as List
        : (response.data['data'] as List?) ?? [];
    return data
        .map((e) => CourseStructureModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/courses/{courseId}/structure/{id}
  Future<CourseStructureModel> getCourseStructureItem(
      dynamic courseId, dynamic itemId) async {
    final response =
        await _client.dio.get('/courses/$courseId/structure/$itemId');
    final Map<String, dynamic> data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : (response.data['data'] as Map<String, dynamic>?) ?? {};
    return CourseStructureModel.fromJson(data);
  }

  /// POST /api/courses/{courseId}/structure
  Future<CourseStructureModel> createStructureItem(
      dynamic courseId, Map<String, dynamic> body) async {
    final response =
        await _client.dio.post('/courses/$courseId/structure', data: body);
    final Map<String, dynamic> data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : (response.data['data'] as Map<String, dynamic>?) ?? {};
    return CourseStructureModel.fromJson(data);
  }

  /// PUT /api/courses/{courseId}/structure/{id}
  Future<CourseStructureModel> updateStructureItem(
      dynamic courseId, dynamic itemId, Map<String, dynamic> body) async {
    final response = await _client.dio
        .put('/courses/$courseId/structure/$itemId', data: body);
    final Map<String, dynamic> data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : (response.data['data'] as Map<String, dynamic>?) ?? {};
    return CourseStructureModel.fromJson(data);
  }

  /// PATCH /api/courses/{courseId}/structure/reorder
  Future<void> reorderStructure(
      dynamic courseId, List<Map<String, dynamic>> body) async {
    await _client.dio
        .patch('/courses/$courseId/structure/reorder', data: body);
  }

  /// DELETE /api/courses/{courseId}/structure/{id}
  Future<void> deleteStructureItem(dynamic courseId, dynamic itemId) async {
    await _client.dio.delete('/courses/$courseId/structure/$itemId');
  }
}
