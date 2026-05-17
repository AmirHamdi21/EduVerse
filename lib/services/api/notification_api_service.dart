import '../../common/retry_helper.dart';
import '../../common/service_error.dart';
import '../../models/notifications/notification_preference_model.dart';
import 'core_api_client.dart';

/// API service for backend notification operations.
class NotificationApiService {
  final CoreApiClient _client;

  NotificationApiService({required CoreApiClient coreApiClient})
    : _client = coreApiClient;

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
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

  Future<ServiceResult<List<Map<String, dynamic>>>> getAll({
    int? page,
    int? limit,
    String? type,
    String? priority,
    bool? isRead,
  }) {
    return RetryHelper.execute<List<Map<String, dynamic>>>(() async {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (type != null && type.isNotEmpty) queryParams['type'] = type;
      if (priority != null && priority.isNotEmpty) {
        queryParams['priority'] = priority;
      }
      if (isRead != null) queryParams['isRead'] = isRead;

      final response = await _client.dio.get(
        '/notifications',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      return _extractList(
        response.data,
      ).whereType<Map<String, dynamic>>().toList();
    }, fallbackMessage: 'Failed to load notifications');
  }

  Future<ServiceResult<int>> getUnreadCount() {
    return RetryHelper.execute<int>(() async {
      final response = await _client.dio.get('/notifications/unread-count');
      final payload = _extractMap(response.data);
      return _parseInt(payload['count']) ??
          _parseInt(payload['unreadCount']) ??
          0;
    }, fallbackMessage: 'Failed to get unread count');
  }

  Future<ServiceResult<NotificationPreferenceModel>> getPreferences() {
    return RetryHelper.execute<NotificationPreferenceModel>(() async {
      final response = await _client.dio.get('/notifications/preferences');
      return NotificationPreferenceModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to load notification preferences');
  }

  Future<ServiceResult<NotificationPreferenceModel>> updatePreferences(
    NotificationPreferenceModel preferences,
  ) {
    return RetryHelper.execute<NotificationPreferenceModel>(() async {
      final response = await _client.dio.put(
        '/notifications/preferences',
        data: preferences.toJson(),
      );
      return NotificationPreferenceModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to save notification preferences');
  }

  Future<ServiceResult<Map<String, dynamic>>> registerDeviceToken({
    required String token,
    String platform = 'android',
    String? deviceId,
    String? deviceName,
    String? appVersion,
    String? locale,
  }) {
    return RetryHelper.execute<Map<String, dynamic>>(() async {
      final payload = <String, dynamic>{
        'token': token,
        'platform': platform,
        if (deviceId != null && deviceId.trim().isNotEmpty)
          'deviceId': deviceId,
        if (deviceName != null && deviceName.trim().isNotEmpty)
          'deviceName': deviceName,
        if (appVersion != null && appVersion.trim().isNotEmpty)
          'appVersion': appVersion,
        if (locale != null && locale.trim().isNotEmpty) 'locale': locale,
      };

      final response = await _client.dio.post(
        '/notifications/device-tokens',
        data: payload,
      );
      return _extractMap(response.data);
    }, fallbackMessage: 'Failed to register notification device');
  }

  Future<ServiceResult<void>> unregisterDeviceToken(String token) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.post(
        '/notifications/device-tokens/unregister',
        data: {'token': token},
      );
    }, fallbackMessage: 'Failed to unregister notification device');
  }

  Future<ServiceResult<void>> markAsRead(dynamic id) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.patch('/notifications/$id/read');
    }, fallbackMessage: 'Failed to mark notification as read');
  }

  Future<ServiceResult<void>> markAllAsRead() {
    return RetryHelper.executeVoid(() async {
      await _client.dio.patch('/notifications/read-all');
    }, fallbackMessage: 'Failed to mark all notifications as read');
  }

  Future<ServiceResult<int>> clearAll() {
    return RetryHelper.execute<int>(() async {
      final response = await _client.dio.delete('/notifications/clear-all');
      final payload = _extractMap(response.data);
      return _parseInt(payload['affected']) ?? _parseInt(payload['count']) ?? 0;
    }, fallbackMessage: 'Failed to clear all notifications');
  }

  Future<ServiceResult<int>> clearRead() {
    return RetryHelper.execute<int>(() async {
      final response = await _client.dio.delete('/notifications/clear-read');
      final payload = _extractMap(response.data);
      return _parseInt(payload['affected']) ?? _parseInt(payload['count']) ?? 0;
    }, fallbackMessage: 'Failed to clear read notifications');
  }

  Future<ServiceResult<void>> deleteNotification(dynamic id) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.delete('/notifications/$id');
    }, fallbackMessage: 'Failed to delete notification');
  }
}

int? _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}
