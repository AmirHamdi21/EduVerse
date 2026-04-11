import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core_api_client.dart';
import '../../models/materials/course_material_model.dart';

/// Service for Course Material API endpoints.
///
/// Wraps all `/api/courses/{courseId}/materials` calls.
class MaterialService {
  final CoreApiClient _client;
  static const String _viewedPrefix = 'material_viewed_';

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
      options: _client.materialTimeoutOptions(),
    );
    final List data = response.data is List
        ? response.data as List
        : (response.data['data'] as List?) ?? [];
    final materials = data
        .map((e) => CourseMaterialModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return _applyViewedCache(materials);
  }

  /// POST /api/courses/{courseId}/materials
  Future<CourseMaterialModel> createMaterial(
    dynamic courseId,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.dio.post(
      '/courses/$courseId/materials',
      data: body,
    );
    final Map<String, dynamic> data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : (response.data['data'] as Map<String, dynamic>?) ?? {};
    return CourseMaterialModel.fromJson(data);
  }

  /// POST /api/courses/{courseId}/materials/bulk
  Future<List<CourseMaterialModel>> bulkCreateMaterials(
    dynamic courseId,
    List<Map<String, dynamic>> items,
  ) async {
    final response = await _client.dio.post(
      '/courses/$courseId/materials/bulk',
      data: items,
      options: _client.materialTimeoutOptions(),
    );
    final List data = response.data is List
        ? response.data as List
        : (response.data['data'] as List?) ?? [];
    return data
        .map((e) => CourseMaterialModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/courses/{courseId}/materials/{mId}
  Future<CourseMaterialModel> getMaterialById(
    dynamic courseId,
    dynamic materialId,
  ) async {
    final response = await _client.dio.get(
      '/courses/$courseId/materials/$materialId',
      options: _client.materialTimeoutOptions(),
    );
    final Map<String, dynamic> data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : (response.data['data'] as Map<String, dynamic>?) ?? {};
    return CourseMaterialModel.fromJson(data);
  }

  /// PUT /api/courses/{courseId}/materials/{mId}
  Future<CourseMaterialModel> updateMaterial(
    dynamic courseId,
    dynamic materialId,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.dio.put(
      '/courses/$courseId/materials/$materialId',
      data: body,
      options: _client.materialTimeoutOptions(),
    );
    final Map<String, dynamic> data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : (response.data['data'] as Map<String, dynamic>?) ?? {};
    return CourseMaterialModel.fromJson(data);
  }

  /// PATCH /api/courses/{courseId}/materials/{mId}/visibility
  Future<void> toggleVisibility(dynamic courseId, dynamic materialId) async {
    await _client.dio.patch(
      '/courses/$courseId/materials/$materialId/visibility',
      options: _client.materialTimeoutOptions(),
    );
  }

  /// POST /api/courses/{courseId}/materials/{mId}/view
  Future<void> recordView(dynamic courseId, dynamic materialId) async {
    try {
      await _client.dio.post(
        '/materials/$materialId/view',
        data: <String, dynamic>{'courseId': courseId},
        options: _client.materialTimeoutOptions(),
      );
      await _persistViewed(materialId);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 404 || statusCode == 405) {
        await _client.dio.post(
          '/courses/$courseId/materials/$materialId/view',
          options: _client.materialTimeoutOptions(),
        );
        await _persistViewed(materialId);
        return;
      }
      rethrow;
    }
  }

  /// GET /api/courses/{courseId}/materials/{mId}/embed
  Future<String> getEmbedUrl(dynamic courseId, dynamic materialId) async {
    final response = await _client.dio.get(
      '/courses/$courseId/materials/$materialId/embed',
      options: _client.materialTimeoutOptions(),
    );
    return response.data['embedUrl'] as String? ?? '';
  }

  /// GET /api/courses/{courseId}/materials/{mId}/download
  /// Returns the download response (binary stream).
  Future<Response> downloadMaterial(
    dynamic courseId,
    dynamic materialId,
  ) async {
    return await _client.dio.get(
      '/courses/$courseId/materials/$materialId/download',
      options: _client.materialTimeoutOptions(
        base: Options(responseType: ResponseType.bytes),
      ),
    );
  }

  /// DELETE /api/courses/{courseId}/materials/{mId}
  Future<void> deleteMaterial(dynamic courseId, dynamic materialId) async {
    await _client.dio.delete('/courses/$courseId/materials/$materialId');
  }

  Future<List<CourseMaterialModel>> _applyViewedCache(
    List<CourseMaterialModel> materials,
  ) async {
    if (materials.isEmpty) {
      return materials;
    }

    final prefs = await SharedPreferences.getInstance();

    return materials.map((material) {
      final viewedInCache =
          prefs.getBool('$_viewedPrefix${material.materialId}') ?? false;
      if (material.hasBeenViewed || viewedInCache) {
        return material.copyWith(hasBeenViewed: true);
      }
      return material;
    }).toList();
  }

  Future<void> _persistViewed(dynamic materialId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_viewedPrefix$materialId', true);
  }
}
