import 'package:dio/dio.dart';
import 'core_api_client.dart';
import '../../models/materials/course_material_model.dart';

/// Service for Course Material API endpoints.
///
/// Wraps all `/api/courses/{courseId}/materials` calls.
class MaterialService {
  final CoreApiClient _client;

  MaterialService({required CoreApiClient coreApiClient})
      : _client = coreApiClient;

  /// GET /api/courses/{courseId}/materials
  /// Supports query filters: materialType, weekNumber, search.
  Future<List<CourseMaterialModel>> getMaterials(
    dynamic courseId, {
    String? materialType,
    int? weekNumber,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{};
    if (materialType != null) queryParams['materialType'] = materialType;
    if (weekNumber != null) queryParams['weekNumber'] = weekNumber;
    if (search != null) queryParams['search'] = search;

    final response = await _client.dio.get(
      '/courses/$courseId/materials',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    final List data = response.data is List
        ? response.data as List
        : (response.data['data'] as List?) ?? [];
    return data
        .map((e) => CourseMaterialModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/courses/{courseId}/materials
  Future<CourseMaterialModel> createMaterial(
      dynamic courseId, Map<String, dynamic> body) async {
    final response =
        await _client.dio.post('/courses/$courseId/materials', data: body);
    final Map<String, dynamic> data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : (response.data['data'] as Map<String, dynamic>?) ?? {};
    return CourseMaterialModel.fromJson(data);
  }

  /// POST /api/courses/{courseId}/materials/bulk
  Future<List<CourseMaterialModel>> bulkCreateMaterials(
      dynamic courseId, List<Map<String, dynamic>> items) async {
    final response = await _client.dio
        .post('/courses/$courseId/materials/bulk', data: items);
    final List data = response.data is List
        ? response.data as List
        : (response.data['data'] as List?) ?? [];
    return data
        .map((e) => CourseMaterialModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/courses/{courseId}/materials/{mId}
  Future<CourseMaterialModel> getMaterialById(
      dynamic courseId, dynamic materialId) async {
    final response =
        await _client.dio.get('/courses/$courseId/materials/$materialId');
    final Map<String, dynamic> data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : (response.data['data'] as Map<String, dynamic>?) ?? {};
    return CourseMaterialModel.fromJson(data);
  }

  /// PUT /api/courses/{courseId}/materials/{mId}
  Future<CourseMaterialModel> updateMaterial(
      dynamic courseId, dynamic materialId, Map<String, dynamic> body) async {
    final response = await _client.dio
        .put('/courses/$courseId/materials/$materialId', data: body);
    final Map<String, dynamic> data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : (response.data['data'] as Map<String, dynamic>?) ?? {};
    return CourseMaterialModel.fromJson(data);
  }

  /// PATCH /api/courses/{courseId}/materials/{mId}/visibility
  Future<void> toggleVisibility(
      dynamic courseId, dynamic materialId) async {
    await _client.dio
        .patch('/courses/$courseId/materials/$materialId/visibility');
  }

  /// POST /api/courses/{courseId}/materials/{mId}/view
  Future<void> recordView(dynamic courseId, dynamic materialId) async {
    await _client.dio
        .post('/courses/$courseId/materials/$materialId/view');
  }

  /// GET /api/courses/{courseId}/materials/{mId}/embed
  Future<String> getEmbedUrl(dynamic courseId, dynamic materialId) async {
    final response = await _client.dio
        .get('/courses/$courseId/materials/$materialId/embed');
    return response.data['embedUrl'] as String? ?? '';
  }

  /// GET /api/courses/{courseId}/materials/{mId}/download
  /// Returns the download response (binary stream).
  Future<Response> downloadMaterial(
      dynamic courseId, dynamic materialId) async {
    return await _client.dio.get(
      '/courses/$courseId/materials/$materialId/download',
      options: Options(responseType: ResponseType.bytes),
    );
  }

  /// DELETE /api/courses/{courseId}/materials/{mId}
  Future<void> deleteMaterial(dynamic courseId, dynamic materialId) async {
    await _client.dio
        .delete('/courses/$courseId/materials/$materialId');
  }
}
