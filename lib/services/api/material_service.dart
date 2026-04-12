import 'dart:io';

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

  /// POST /api/courses/{courseId}/materials/document
  Future<CourseMaterialModel> uploadDocument(
    dynamic courseId, {
    required File file,
    required String title,
    int? weekNumber,
    bool isPublished = true,
    ProgressCallback? onSendProgress,
  }) async {
    final formData = FormData.fromMap(<String, dynamic>{
      'document': await MultipartFile.fromFile(
        file.path,
        filename: _fileName(file),
      ),
      'title': title,
      if (weekNumber != null) 'weekNumber': weekNumber,
      'isPublished': isPublished,
    });

    final response = await _client.dio.post(
      '/courses/$courseId/materials/document',
      data: formData,
      onSendProgress: onSendProgress,
      options: _client.materialTimeoutOptions(),
    );

    return CourseMaterialModel.fromJson(_extractMap(response.data));
  }

  /// POST /api/courses/{courseId}/materials/video
  Future<CourseMaterialModel> uploadVideo(
    dynamic courseId, {
    required File file,
    required String title,
    int? weekNumber,
    bool isPublished = true,
    ProgressCallback? onSendProgress,
  }) async {
    final formData = FormData.fromMap(<String, dynamic>{
      'video': await MultipartFile.fromFile(
        file.path,
        filename: _fileName(file),
      ),
      'title': title,
      if (weekNumber != null) 'weekNumber': weekNumber,
      'isPublished': isPublished,
    });

    final response = await _client.dio.post(
      '/courses/$courseId/materials/video',
      data: formData,
      onSendProgress: onSendProgress,
      options: _client.materialTimeoutOptions(),
    );

    return CourseMaterialModel.fromJson(_extractMap(response.data));
  }

  /// POST /api/courses/{courseId}/materials
  Future<CourseMaterialModel> uploadTextLink(
    dynamic courseId, {
    required String title,
    required String url,
    required String type,
    int? weekNumber,
    bool isPublished = true,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'type': type,
      'url': url,
      if (weekNumber != null) 'weekNumber': weekNumber,
      'isPublished': isPublished,
    };

    final response = await _client.dio.post(
      '/courses/$courseId/materials',
      data: body,
      options: _client.materialTimeoutOptions(),
    );

    return CourseMaterialModel.fromJson(_extractMap(response.data));
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

  /// PUT /api/courses/{courseId}/materials/{materialId}
  /// Alias retained for newer call sites.
  Future<CourseMaterialModel> updateMaterialDetails(
    dynamic courseId,
    dynamic materialId,
    Map<String, dynamic> body,
  ) {
    return updateMaterial(courseId, materialId, body);
  }

  /// PATCH /api/courses/{courseId}/materials/{mId}/visibility
  Future<CourseMaterialModel> toggleVisibility(
    dynamic courseId,
    dynamic materialId, {
    required bool isPublished,
  }) async {
    final response = await _client.dio.patch(
      '/courses/$courseId/materials/$materialId/visibility',
      data: <String, dynamic>{'isPublished': isPublished},
      options: _client.materialTimeoutOptions(),
    );

    return CourseMaterialModel.fromJson(_extractMap(response.data));
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

  String _fileName(File file) {
    if (file.uri.pathSegments.isNotEmpty) {
      return file.uri.pathSegments.last;
    }
    return 'upload.bin';
  }

  Map<String, dynamic> _extractMap(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      return payload;
    }
    return <String, dynamic>{};
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
