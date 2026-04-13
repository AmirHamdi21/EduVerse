import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'core_api_client.dart';
import '../../models/core/course_model.dart';
import '../../models/core/course_structure_model.dart';
import '../../models/materials/course_material_model.dart';

/// Service for Course and Course Structure API endpoints.
///
/// Wraps all `/api/courses` and `/api/courses/{courseId}/structure` calls.
class CourseService {
  final CoreApiClient _client;

  static const String _structureLatestPrefix = 'course_structure_latest_';
  static const String _structureIndexKey = 'course_structure_cache_index';
  static const int _maxCachedCourses = 10;
  static const Duration _cacheTtl = Duration(days: 7);

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
    dynamic courseId,
  ) async {
    final response = await _client.dio.get('/courses/$courseId/prerequisites');
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
    dynamic courseId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = await _loadCachedStructure(courseId);
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }
    }

    final response = await _client.dio.get('/courses/$courseId/structure');
    final structure = _extractStructureList(response.data, courseId);
    await _cacheStructure(courseId, response.data, structure);
    return structure;
  }

  /// Alias for Phase 5 task naming consistency.
  Future<List<CourseStructureModel>> getStructure(
    dynamic courseId, {
    bool forceRefresh = false,
  }) {
    return getCourseStructure(courseId, forceRefresh: forceRefresh);
  }

  /// GET /api/courses/{courseId}/structure/{id}
  Future<CourseStructureModel> getCourseStructureItem(
    dynamic courseId,
    dynamic itemId,
  ) async {
    final response = await _client.dio.get(
      '/courses/$courseId/structure/$itemId',
    );
    final Map<String, dynamic> data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : (response.data['data'] as Map<String, dynamic>?) ?? {};
    return CourseStructureModel.fromJson(data);
  }

  /// POST /api/courses/{courseId}/structure
  Future<CourseStructureModel> createStructureItem(
    dynamic courseId,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.dio.post(
      '/courses/$courseId/structure',
      data: body,
    );
    final Map<String, dynamic> data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : (response.data['data'] as Map<String, dynamic>?) ?? {};
    return CourseStructureModel.fromJson(data);
  }

  /// PUT /api/courses/{courseId}/structure/{id}
  Future<CourseStructureModel> updateStructureItem(
    dynamic courseId,
    dynamic itemId,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.dio.put(
      '/courses/$courseId/structure/$itemId',
      data: body,
    );
    final Map<String, dynamic> data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : (response.data['data'] as Map<String, dynamic>?) ?? {};
    return CourseStructureModel.fromJson(data);
  }

  /// PATCH /api/courses/{courseId}/structure/reorder
  Future<void> reorderStructure(
    dynamic courseId,
    List<Map<String, dynamic>> body,
  ) async {
    await _client.dio.patch(
      '/courses/$courseId/structure/reorder',
      data: <String, dynamic>{'itemIds': body.map((e) => e['id']).toList()},
    );
  }

  /// PATCH /api/courses/{courseId}/structure/reorder
  Future<void> reorderStructureItems(
    dynamic courseId,
    List<int> itemIds,
  ) async {
    await _client.dio.patch(
      '/courses/$courseId/structure/reorder',
      data: <String, dynamic>{'itemIds': itemIds},
    );
  }

  /// DELETE /api/courses/{courseId}/structure/{id}
  Future<void> deleteStructureItem(dynamic courseId, dynamic itemId) async {
    await _client.dio.delete('/courses/$courseId/structure/$itemId');
  }

  List<CourseStructureModel> _extractStructureList(
    dynamic payload,
    dynamic fallbackCourseId,
  ) {
    if (payload is List) {
      return payload
          .whereType<Map<String, dynamic>>()
          .map(CourseStructureModel.fromJson)
          .toList();
    }

    if (payload is! Map<String, dynamic>) {
      return <CourseStructureModel>[];
    }

    final directData = payload['data'];
    if (directData is List) {
      return directData
          .whereType<Map<String, dynamic>>()
          .map(CourseStructureModel.fromJson)
          .toList();
    }

    final byWeek = payload['byWeek'];
    if (byWeek is List) {
      final courseId = (payload['courseId'] ?? fallbackCourseId ?? '')
          .toString();

      final output = <CourseStructureModel>[];
      for (final week in byWeek.whereType<Map<String, dynamic>>()) {
        final weekNumber = week['weekNumber'] is int
            ? week['weekNumber'] as int
            : int.tryParse(week['weekNumber']?.toString() ?? '') ?? 0;
        final items = week['items'];
        if (items is! List) continue;

        for (final item in items.whereType<Map<String, dynamic>>()) {
          output.add(_createFromWeekItem(item, weekNumber, courseId));
        }
      }

      return output;
    }

    return <CourseStructureModel>[];
  }

  CourseStructureModel _createFromWeekItem(
    Map<String, dynamic> item,
    int weekNumber,
    String courseId,
  ) {
    final rawMaterial = item['material'];

    return CourseStructureModel(
      organizationId: item['id'] is int
          ? item['id'] as int
          : int.tryParse(item['id']?.toString() ?? '') ?? 0,
      courseId: courseId,
      materialId: item['materialId']?.toString(),
      material: rawMaterial is Map<String, dynamic>
          ? CourseMaterialModel.fromJson(rawMaterial)
          : null,
      organizationType:
          (item['contentType'] ?? item['organizationType'] ?? 'document')
              .toString(),
      title: (item['title'] ?? '').toString(),
      weekNumber: weekNumber,
      orderIndex: item['orderIndex'] is int
          ? item['orderIndex'] as int
          : int.tryParse(item['orderIndex']?.toString() ?? '') ?? 0,
      description: item['description']?.toString(),
      createdAt: null,
      updatedAt: null,
    );
  }

  Future<List<CourseStructureModel>?> _loadCachedStructure(
    dynamic courseId,
  ) async {
    final prefs = await _safePrefs();
    if (prefs == null) return null;

    final pointerKey = '$_structureLatestPrefix$courseId';
    final cacheKey = prefs.getString(pointerKey);
    if (cacheKey == null || cacheKey.isEmpty) {
      return null;
    }

    final raw = prefs.getString(cacheKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final cachedAt = DateTime.tryParse(decoded['cachedAt']?.toString() ?? '');
      if (cachedAt == null || DateTime.now().difference(cachedAt) > _cacheTtl) {
        return null;
      }

      final items = decoded['items'];
      if (items is! List) return null;

      return items
          .whereType<Map<String, dynamic>>()
          .map(CourseStructureModel.fromJson)
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> _cacheStructure(
    dynamic courseId,
    dynamic payload,
    List<CourseStructureModel> structure,
  ) async {
    final prefs = await _safePrefs();
    if (prefs == null) return;

    final updatedAt = payload is Map<String, dynamic>
        ? payload['updatedAt']?.toString()
        : null;
    final hash = (updatedAt ?? DateTime.now().toIso8601String()).hashCode
        .toString();
    final cacheKey = 'course_structure_${courseId}_$hash';
    final pointerKey = '$_structureLatestPrefix$courseId';

    final value = jsonEncode(<String, dynamic>{
      'cachedAt': DateTime.now().toIso8601String(),
      'hash': hash,
      'items': structure.map((item) => item.toJson()).toList(),
    });

    await prefs.setString(cacheKey, value);
    await prefs.setString(pointerKey, cacheKey);

    final index = prefs.getStringList(_structureIndexKey) ?? <String>[];
    index.remove(cacheKey);
    index.add(cacheKey);

    while (index.length > _maxCachedCourses) {
      final oldest = index.removeAt(0);
      await prefs.remove(oldest);
    }

    await prefs.setStringList(_structureIndexKey, index);
  }

  Future<SharedPreferences?> _safePrefs() async {
    try {
      return await SharedPreferences.getInstance();
    } catch (_) {
      return null;
    }
  }
}
