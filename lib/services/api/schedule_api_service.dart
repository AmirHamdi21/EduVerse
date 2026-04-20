import '../../common/retry_helper.dart';
import '../../common/service_error.dart';
import '../../models/admin/admin_periods_models.dart';
import '../../models/schedule/schedule_models.dart';
import 'core_api_client.dart';

class ScheduleApiService {
  final CoreApiClient _client;

  ScheduleApiService({required CoreApiClient coreApiClient})
    : _client = coreApiClient;

  Future<ServiceResult<DailyScheduleResponse>> getDailySchedule({
    String? date,
  }) {
    return RetryHelper.execute<DailyScheduleResponse>(() async {
      final query = <String, dynamic>{};
      if (date != null && date.trim().isNotEmpty) {
        query['date'] = date.trim();
      }

      final response = await _client.dio.get(
        '/schedule/my/daily',
        queryParameters: query,
      );
      final data = _extractMap(response.data);
      return DailyScheduleResponse.fromJson(data);
    }, fallbackMessage: 'Failed to load daily schedule');
  }

  Future<ServiceResult<WeeklyScheduleResponse>> getWeeklySchedule({
    String? startDate,
  }) {
    return RetryHelper.execute<WeeklyScheduleResponse>(() async {
      final query = <String, dynamic>{};
      if (startDate != null && startDate.trim().isNotEmpty) {
        query['startDate'] = startDate.trim();
      }

      final response = await _client.dio.get(
        '/schedule/my/weekly',
        queryParameters: query,
      );
      final data = _extractMap(response.data);
      return WeeklyScheduleResponse.fromJson(data);
    }, fallbackMessage: 'Failed to load weekly schedule');
  }

  Future<ServiceResult<List<DailyScheduleResponse>>> getMonthSchedule(
    DateTime referenceDate,
  ) {
    return RetryHelper.execute<List<DailyScheduleResponse>>(() async {
      final weekStarts = monthWeekStartDates(referenceDate);

      final weeklyResponses = await Future.wait(
        weekStarts.map((startDate) async {
          final response = await _client.dio.get(
            '/schedule/my/weekly',
            queryParameters: <String, dynamic>{'startDate': startDate},
          );
          return WeeklyScheduleResponse.fromJson(_extractMap(response.data));
        }),
      );

      final byDate = <String, DailyScheduleResponse>{};
      for (final weekly in weeklyResponses) {
        for (final day in weekly.days) {
          if (day.date.trim().isNotEmpty) {
            byDate[day.date] = day;
          }
        }
      }

      final monthStart = startOfMonth(referenceDate);
      final monthEnd = endOfMonth(referenceDate);

      final days =
          byDate.values
              .where((day) {
                final parsed = DateTime.tryParse(day.date);
                if (parsed == null) {
                  return false;
                }
                final normalized = DateTime(
                  parsed.year,
                  parsed.month,
                  parsed.day,
                );
                return !normalized.isBefore(monthStart) &&
                    !normalized.isAfter(monthEnd);
              })
              .toList(growable: false)
            ..sort((a, b) => a.date.compareTo(b.date));

      return days;
    }, fallbackMessage: 'Failed to load month schedule');
  }

  Future<ServiceResult<PersonalEventItem>> createCalendarEvent(
    Map<String, dynamic> data,
  ) {
    return RetryHelper.execute<PersonalEventItem>(() async {
      final response = await _client.dio.post('/calendar/events', data: data);
      final payload = _extractMap(response.data);
      return PersonalEventItem.fromJson(payload);
    }, fallbackMessage: 'Failed to create event');
  }

  Future<ServiceResult<PersonalEventItem>> updateCalendarEvent(
    int eventId,
    Map<String, dynamic> data,
  ) {
    return RetryHelper.execute<PersonalEventItem>(() async {
      final response = await _client.dio.put(
        '/calendar/events/$eventId',
        data: data,
      );
      final payload = _extractMap(response.data);
      return PersonalEventItem.fromJson(payload);
    }, fallbackMessage: 'Failed to update event');
  }

  Future<ServiceResult<void>> deleteCalendarEvent(int eventId) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.delete('/calendar/events/$eventId');
    }, fallbackMessage: 'Failed to delete event');
  }

  Future<ServiceResult<PaginatedResult<CampusEventModel>>> getCampusEvents({
    String? eventType,
    int? scopeId,
    String? status,
    String? fromDate,
    String? toDate,
    String? tag,
    String? search,
    int page = 1,
    int limit = 10,
  }) {
    return RetryHelper.execute<PaginatedResult<CampusEventModel>>(() async {
      final query = <String, dynamic>{'page': page, 'limit': limit};

      if (eventType != null && eventType.trim().isNotEmpty) {
        query['eventType'] = eventType.trim();
      }
      if (scopeId != null) {
        query['scopeId'] = scopeId;
      }
      if (status != null && status.trim().isNotEmpty) {
        query['status'] = status.trim();
      }
      if (fromDate != null && fromDate.trim().isNotEmpty) {
        query['fromDate'] = fromDate.trim();
      }
      if (toDate != null && toDate.trim().isNotEmpty) {
        query['toDate'] = toDate.trim();
      }
      if (tag != null && tag.trim().isNotEmpty) {
        query['tag'] = tag.trim();
      }
      if (search != null && search.trim().isNotEmpty) {
        query['search'] = search.trim();
      }

      final response = await _client.dio.get(
        '/campus-events',
        queryParameters: query,
      );

      return _extractPaginated(response.data, CampusEventModel.fromJson);
    }, fallbackMessage: 'Failed to load campus events');
  }

  Future<ServiceResult<PaginatedResult<CampusEventModel>>> getMyCampusEvents({
    int page = 1,
    int limit = 10,
  }) {
    return RetryHelper.execute<PaginatedResult<CampusEventModel>>(() async {
      final response = await _client.dio.get(
        '/campus-events/my',
        queryParameters: <String, dynamic>{'page': page, 'limit': limit},
      );

      return _extractPaginated(response.data, CampusEventModel.fromJson);
    }, fallbackMessage: 'Failed to load my campus events');
  }

  Future<ServiceResult<void>> registerForCampusEvent(
    int eventId, {
    String? notes,
  }) {
    return RetryHelper.executeVoid(() async {
      final payload = <String, dynamic>{};
      if (notes != null && notes.trim().isNotEmpty) {
        payload['notes'] = notes.trim();
      }

      await _client.dio.post('/campus-events/$eventId/register', data: payload);
    }, fallbackMessage: 'Failed to register for campus event');
  }

  Future<ServiceResult<void>> unregisterFromCampusEvent(int eventId) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.delete('/campus-events/$eventId/register');
    }, fallbackMessage: 'Failed to unregister from campus event');
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

      final items = payload['items'];
      if (items is List) {
        return items;
      }

      final results = payload['results'];
      if (results is List) {
        return results;
      }
    }

    return const <dynamic>[];
  }

  static PaginatedResult<T> _extractPaginated<T>(
    dynamic payload,
    T Function(Map<String, dynamic> json) mapper,
  ) {
    final rows = _extractList(payload);
    var metaMap = const <String, dynamic>{};

    if (payload is Map<String, dynamic>) {
      final meta = payload['meta'];
      if (meta is Map<String, dynamic>) {
        metaMap = meta;
      }

      final nestedData = payload['data'];
      if (nestedData is Map<String, dynamic>) {
        final nestedMeta = nestedData['meta'];
        if (nestedMeta is Map<String, dynamic>) {
          metaMap = nestedMeta;
        }
      }
    }

    final items = rows
        .whereType<Map<String, dynamic>>()
        .map(mapper)
        .toList(growable: false);

    return PaginatedResult<T>(
      items: items,
      meta: PaginationMeta.fromJson(metaMap),
    );
  }
}
