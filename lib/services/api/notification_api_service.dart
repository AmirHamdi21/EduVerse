import '../../common/retry_helper.dart';
import '../../common/service_error.dart';
import 'core_api_client.dart';

/// API service for notification operations.
///
/// Maps to the backend NestJS `NotificationsController` endpoints:
///   - GET    /api/notifications          – list (paginated)
///   - GET    /api/notifications/unread-count
///   - PATCH  /api/notifications/:id/read – mark single as read
///   - PATCH  /api/notifications/read-all – mark all as read
///   - DELETE /api/notifications/clear-read
///   - DELETE /api/notifications/:id
class NotificationApiService {
  final CoreApiClient _client;

  NotificationApiService({required CoreApiClient coreApiClient})
      : _client = coreApiClient;

  // ── Helpers ────────────────────────────────────────────────────

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      // Backend may wrap in { data: [...] } or { notifications: [...] }
      if (data['data'] is List) return data['data'] as List;
      if (data['notifications'] is List) return data['notifications'] as List;
      if (data['items'] is List) return data['items'] as List;
    }
    return <dynamic>[];
  }

  Map<String, dynamic> _extractMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    return <String, dynamic>{};
  }

  // ── Read operations ────────────────────────────────────────────

  /// GET /api/notifications
  ///
  /// Returns the raw list of notification JSON maps from the backend.
  /// Callers should normalize these into their role-specific models.
  Future<ServiceResult<List<Map<String, dynamic>>>> getAll({
    int? limit,
    int? offset,
    String? type,
  }) {
    return RetryHelper.execute<List<Map<String, dynamic>>>(() async {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;
      if (type != null && type.isNotEmpty) queryParams['type'] = type;

      final response = await _client.dio.get(
        '/notifications',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .toList();
    }, fallbackMessage: 'Failed to load notifications');
  }

  /// GET /api/notifications/unread-count
  Future<ServiceResult<int>> getUnreadCount() {
    return RetryHelper.execute<int>(() async {
      final response = await _client.dio.get('/notifications/unread-count');
      final payload = _extractMap(response.data);
      // Backend may return { count: N } or { unreadCount: N }
      return (payload['count'] as int?) ??
          (payload['unreadCount'] as int?) ??
          0;
    }, fallbackMessage: 'Failed to get unread count');
  }

  // ── Write operations ───────────────────────────────────────────

  /// PATCH /api/notifications/:id/read
  Future<ServiceResult<void>> markAsRead(dynamic id) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.patch('/notifications/$id/read');
    }, fallbackMessage: 'Failed to mark notification as read');
  }

  /// PATCH /api/notifications/read-all
  Future<ServiceResult<void>> markAllAsRead() {
    return RetryHelper.executeVoid(() async {
      await _client.dio.patch('/notifications/read-all');
    }, fallbackMessage: 'Failed to mark all notifications as read');
  }

  /// DELETE /api/notifications/clear-read
  ///
  /// Returns the number of deleted notifications on success.
  Future<ServiceResult<int>> clearRead() {
    return RetryHelper.execute<int>(() async {
      final response = await _client.dio.delete('/notifications/clear-read');
      final payload = _extractMap(response.data);
      return (payload['affected'] as int?) ??
          (payload['count'] as int?) ??
          0;
    }, fallbackMessage: 'Failed to clear read notifications');
  }

  /// DELETE /api/notifications/:id
  Future<ServiceResult<void>> deleteNotification(dynamic id) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.delete('/notifications/$id');
    }, fallbackMessage: 'Failed to delete notification');
  }
}
