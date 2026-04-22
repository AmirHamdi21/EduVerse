import 'core_api_client.dart';
import '../../models/admin/admin_periods_models.dart';

class OfficeHoursService {
  final CoreApiClient _client;

  OfficeHoursService({required CoreApiClient coreApiClient})
    : _client = coreApiClient;

  Future<PaginatedResult<OfficeHourSlotModel>> getSlots({
    int page = 1,
    int limit = 10,
    int? instructorId,
    String? dayOfWeek,
  }) async {
    final query = <String, dynamic>{'page': page, 'limit': limit};
    if (instructorId != null) {
      query['instructorId'] = instructorId;
    }
    if (dayOfWeek != null && dayOfWeek.trim().isNotEmpty) {
      query['dayOfWeek'] = dayOfWeek.trim();
    }

    final response = await _client.dio.get(
      '/office-hours/slots',
      queryParameters: query,
    );

    return _extractPaginated(
      response.data,
      OfficeHourSlotModel.fromJson,
      primaryListKeys: const <String>['data', 'slots', 'items'],
    );
  }

  Future<List<OfficeHourAppointmentModel>> getMyAppointments() async {
    final response = await _client.dio.get('/office-hours/my-appointments');
    final data = _extractList(response.data);

    return data
        .whereType<Map<String, dynamic>>()
        .map(OfficeHourAppointmentModel.fromJson)
        .toList();
  }

  Future<OfficeHourAppointmentModel> bookAppointment({
    required int slotId,
    required String appointmentDate,
    String? topic,
    String? notes,
  }) async {
    final payload = <String, dynamic>{
      'slotId': slotId,
      'appointmentDate': appointmentDate,
    };

    if (topic != null && topic.trim().isNotEmpty) {
      payload['topic'] = topic.trim();
    }
    if (notes != null && notes.trim().isNotEmpty) {
      payload['notes'] = notes.trim();
    }

    final response = await _client.dio.post(
      '/office-hours/appointments',
      data: payload,
    );

    final data = _extractMap(response.data);
    final source = data['data'] is Map<String, dynamic>
        ? data['data'] as Map<String, dynamic>
        : data;
    return OfficeHourAppointmentModel.fromJson(source);
  }

  PaginatedResult<T> _extractPaginated<T>(
    dynamic payload,
    T Function(Map<String, dynamic> json) mapper, {
    List<String> primaryListKeys = const <String>['data'],
  }) {
    final rows = <dynamic>[];
    Map<String, dynamic> metaMap = const <String, dynamic>{};

    if (payload is List) {
      rows.addAll(payload);
    } else if (payload is Map<String, dynamic>) {
      final directMeta = payload['meta'];
      if (directMeta is Map<String, dynamic>) {
        metaMap = directMeta;
      }

      dynamic listCandidate;
      for (final key in primaryListKeys) {
        final value = payload[key];
        if (value is List) {
          listCandidate = value;
          break;
        }
        if (value is Map<String, dynamic>) {
          final nested = value['data'] ?? value['items'] ?? value['results'];
          if (nested is List) {
            listCandidate = nested;
            if (metaMap.isEmpty && value['meta'] is Map<String, dynamic>) {
              metaMap = value['meta'] as Map<String, dynamic>;
            }
            break;
          }
        }
      }

      listCandidate ??= payload['items'] ?? payload['results'];

      if (listCandidate is List) {
        rows.addAll(listCandidate);
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

  List<dynamic> _extractList(dynamic payload) {
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
      final appointments = payload['appointments'];
      if (appointments is List) {
        return appointments;
      }
    }
    return const <dynamic>[];
  }

  Map<String, dynamic> _extractMap(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      return payload;
    }
    return const <String, dynamic>{};
  }
}
