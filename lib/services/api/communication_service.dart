import 'core_api_client.dart';
import '../../models/materials/announcement_model.dart';
import '../../models/materials/assignment_model.dart';
import '../../models/materials/discussion_thread_model.dart';

/// Service for Announcements, Assignments, and Discussions API endpoints.
///
/// Wraps `/api/announcements`, `/api/assignments`, and `/api/discussions`.
class CommunicationService {
  final CoreApiClient _client;

  CommunicationService({required CoreApiClient coreApiClient})
    : _client = coreApiClient;

  // ── Announcements ─────────────────────────────────────────────────────

  /// GET /api/announcements
  Future<List<AnnouncementModel>> getAnnouncements() async {
    final response = await _client.dio.get('/announcements');
    final List data = _extractList(response.data);
    return data
        .map((e) => AnnouncementModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/announcements?courseId={id}
  Future<List<AnnouncementModel>> getAnnouncementsByCourseId(
    dynamic courseId,
  ) async {
    final response = await _client.dio.get(
      '/announcements',
      queryParameters: <String, dynamic>{'courseId': courseId},
    );

    final List data = _extractList(response.data);

    return data
        .map((e) => AnnouncementModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/announcements
  Future<AnnouncementModel> createAnnouncement(
    Map<String, dynamic> body,
  ) async {
    final response = await _client.dio.post('/announcements', data: body);
    return AnnouncementModel.fromJson(_extractMap(response.data));
  }

  /// GET /api/announcements/{id}
  Future<AnnouncementModel> getAnnouncementById(dynamic id) async {
    final response = await _client.dio.get('/announcements/$id');
    return AnnouncementModel.fromJson(_extractMap(response.data));
  }

  /// PUT /api/announcements/{id}
  Future<AnnouncementModel> updateAnnouncement(
    dynamic id,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.dio.put('/announcements/$id', data: body);
    return AnnouncementModel.fromJson(_extractMap(response.data));
  }

  /// DELETE /api/announcements/{id}
  Future<void> deleteAnnouncement(dynamic id) async {
    await _client.dio.delete('/announcements/$id');
  }

  /// PATCH /api/announcements/{id}/publish
  Future<void> publishAnnouncement(dynamic id) async {
    await _client.dio.patch('/announcements/$id/publish');
  }

  /// PATCH /api/announcements/{id}/schedule
  Future<void> scheduleAnnouncement(dynamic id, DateTime scheduledAt) async {
    await _client.dio.patch(
      '/announcements/$id/schedule',
      data: {'scheduledAt': scheduledAt.toIso8601String()},
    );
  }

  /// PATCH /api/announcements/{id}/pin
  Future<void> pinAnnouncement(dynamic id, {bool? isPinned}) async {
    await _client.dio.patch(
      '/announcements/$id/pin',
      data: isPinned != null ? {'isPinned': isPinned} : null,
    );
  }

  /// GET /api/announcements/{id}/analytics
  Future<Map<String, dynamic>> getAnnouncementAnalytics(dynamic id) async {
    final response = await _client.dio.get('/announcements/$id/analytics');
    return _extractMap(response.data);
  }

  // ── Assignments ───────────────────────────────────────────────────────

  /// GET /api/assignments
  Future<List<AssignmentModel>> getAssignments() async {
    final response = await _client.dio.get('/assignments');
    final List data = response.data is List
        ? response.data as List
        : (response.data['data'] as List?) ?? [];
    return data
        .map((e) => AssignmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/assignments/{id}
  Future<AssignmentModel> getAssignmentById(dynamic id) async {
    final response = await _client.dio.get('/assignments/$id');
    final Map<String, dynamic> data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : (response.data['data'] as Map<String, dynamic>?) ?? {};
    return AssignmentModel.fromJson(data);
  }

  /// POST /api/assignments
  Future<AssignmentModel> createAssignment(Map<String, dynamic> body) async {
    final response = await _client.dio.post('/assignments', data: body);
    final Map<String, dynamic> data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : (response.data['data'] as Map<String, dynamic>?) ?? {};
    return AssignmentModel.fromJson(data);
  }

  /// PATCH /api/assignments/{id}
  Future<AssignmentModel> updateAssignment(
    dynamic id,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.dio.patch('/assignments/$id', data: body);
    final Map<String, dynamic> data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : (response.data['data'] as Map<String, dynamic>?) ?? {};
    return AssignmentModel.fromJson(data);
  }

  /// GET /api/assignments/{id}/submissions/my
  Future<Map<String, dynamic>> getMySubmission(dynamic id) async {
    final response = await _client.dio.get('/assignments/$id/submissions/my');
    return response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : (response.data['data'] as Map<String, dynamic>?) ?? {};
  }

  /// GET /api/assignments/{id}/submissions
  Future<List<Map<String, dynamic>>> getAllSubmissions(dynamic id) async {
    final response = await _client.dio.get('/assignments/$id/submissions');
    final List data = response.data is List
        ? response.data as List
        : (response.data['data'] as List?) ?? [];
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // ── Discussions ───────────────────────────────────────────────────────

  /// GET /api/discussions
  Future<List<DiscussionThreadModel>> getDiscussions() async {
    final response = await _client.dio.get('/discussions');
    final List data = response.data is List
        ? response.data as List
        : (response.data['data'] as List?) ?? [];
    return data
        .map((e) => DiscussionThreadModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/discussions
  Future<DiscussionThreadModel> createDiscussion(
    Map<String, dynamic> body,
  ) async {
    final response = await _client.dio.post('/discussions', data: body);
    final Map<String, dynamic> data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : (response.data['data'] as Map<String, dynamic>?) ?? {};
    return DiscussionThreadModel.fromJson(data);
  }

  /// GET /api/discussions/{id}
  Future<DiscussionThreadModel> getDiscussionById(dynamic id) async {
    final response = await _client.dio.get('/discussions/$id');
    final Map<String, dynamic> data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : (response.data['data'] as Map<String, dynamic>?) ?? {};
    return DiscussionThreadModel.fromJson(data);
  }

  /// PUT /api/discussions/{id}
  Future<DiscussionThreadModel> updateDiscussion(
    dynamic id,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.dio.put('/discussions/$id', data: body);
    final Map<String, dynamic> data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : (response.data['data'] as Map<String, dynamic>?) ?? {};
    return DiscussionThreadModel.fromJson(data);
  }

  /// POST /api/discussions/{id}/reply
  Future<Map<String, dynamic>> replyToDiscussion(
    dynamic id,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.dio.post(
      '/discussions/$id/reply',
      data: body,
    );
    return response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : (response.data['data'] as Map<String, dynamic>?) ?? {};
  }

  /// PATCH /api/discussions/{id}/pin
  Future<void> pinDiscussion(dynamic id) async {
    await _client.dio.patch('/discussions/$id/pin');
  }

  /// PATCH /api/discussions/{id}/lock
  Future<void> lockDiscussion(dynamic id) async {
    await _client.dio.patch('/discussions/$id/lock');
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
