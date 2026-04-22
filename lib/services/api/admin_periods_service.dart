import 'package:dio/dio.dart';

import '../../common/retry_helper.dart';
import '../../common/service_error.dart';
import '../../models/admin/admin_periods_models.dart';
import 'core_api_client.dart';

class AdminPeriodsService {
  final CoreApiClient _client;

  AdminPeriodsService({required CoreApiClient coreApiClient})
    : _client = coreApiClient;

  Future<ServiceResult<List<EnrollmentPeriodModel>>> getEnrollmentPeriods() {
    return RetryHelper.execute<List<EnrollmentPeriodModel>>(() async {
      final response = await _client.dio.get('/semesters');
      final rows = _extractList(response.data);
      return rows
          .whereType<Map<String, dynamic>>()
          .map(EnrollmentPeriodModel.fromSemesterJson)
          .toList();
    }, fallbackMessage: 'Failed to load enrollment periods');
  }

  Future<ServiceResult<PaginatedResult<CampusEventModel>>> getCampusEvents({
    int page = 1,
    int limit = 10,
    String? search,
    String? eventType,
    String? status,
    String? fromDate,
    String? toDate,
    int? scopeId,
  }) {
    return RetryHelper.execute<PaginatedResult<CampusEventModel>>(() async {
      final query = <String, dynamic>{'page': page, 'limit': limit};
      if (search != null && search.trim().isNotEmpty) {
        query['search'] = search.trim();
      }
      if (eventType != null && eventType.trim().isNotEmpty) {
        query['eventType'] = eventType.trim();
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
      if (scopeId != null) {
        query['scopeId'] = scopeId;
      }

      final response = await _client.dio.get(
        '/campus-events',
        queryParameters: query,
      );
      return _extractPaginated(
        response.data,
        CampusEventModel.fromJson,
        primaryListKeys: const <String>['data', 'items', 'events'],
      );
    }, fallbackMessage: 'Failed to load campus events');
  }

  Future<ServiceResult<CampusEventModel>> createCampusEvent(
    Map<String, dynamic> payload,
  ) {
    return RetryHelper.execute<CampusEventModel>(() async {
      final response = await _client.dio.post('/campus-events', data: payload);
      return CampusEventModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to create campus event');
  }

  Future<ServiceResult<CampusEventModel>> updateCampusEvent(
    int eventId,
    Map<String, dynamic> payload,
  ) {
    return RetryHelper.execute<CampusEventModel>(() async {
      final response = await _client.dio.put(
        '/campus-events/$eventId',
        data: payload,
      );
      return CampusEventModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to update campus event');
  }

  Future<ServiceResult<void>> deleteCampusEvent(int eventId) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.delete('/campus-events/$eventId');
    }, fallbackMessage: 'Failed to delete campus event');
  }

  Future<ServiceResult<List<CampusEventRegistrationModel>>>
  getCampusEventRegistrations(int eventId) {
    return RetryHelper.execute<List<CampusEventRegistrationModel>>(() async {
      final response = await _client.dio.get(
        '/campus-events/$eventId/registrations',
      );

      final payload = response.data;
      if (payload is Map<String, dynamic>) {
        final rows = payload['registrations'] ?? payload['data'];
        if (rows is List) {
          return rows
              .whereType<Map<String, dynamic>>()
              .map(CampusEventRegistrationModel.fromJson)
              .toList();
        }
      }

      final rows = _extractList(payload);
      return rows
          .whereType<Map<String, dynamic>>()
          .map(CampusEventRegistrationModel.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to load event registrations');
  }

  Future<ServiceResult<PaginatedResult<ScheduleTemplateModel>>>
  getScheduleTemplates({
    int page = 1,
    int limit = 10,
    String? search,
    String? scheduleType,
    int? departmentId,
    bool? isActive,
  }) {
    return RetryHelper.execute<PaginatedResult<ScheduleTemplateModel>>(
      () async {
        final query = <String, dynamic>{'page': page, 'limit': limit};
        if (search != null && search.trim().isNotEmpty) {
          query['search'] = search.trim();
        }
        if (scheduleType != null && scheduleType.trim().isNotEmpty) {
          query['scheduleType'] = scheduleType.trim();
        }
        if (departmentId != null) {
          query['departmentId'] = departmentId;
        }
        if (isActive != null) {
          query['isActive'] = isActive;
        }

        final response = await _client.dio.get(
          '/schedule-templates',
          queryParameters: query,
        );
        return _extractPaginated(
          response.data,
          ScheduleTemplateModel.fromJson,
          primaryListKeys: const <String>['data', 'items', 'templates'],
        );
      },
      fallbackMessage: 'Failed to load schedule templates',
    );
  }

  Future<ServiceResult<ScheduleTemplateModel>> createScheduleTemplate(
    Map<String, dynamic> payload,
  ) {
    return RetryHelper.execute<ScheduleTemplateModel>(() async {
      final response = await _client.dio.post(
        '/schedule-templates',
        data: payload,
      );
      return ScheduleTemplateModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to create schedule template');
  }

  Future<ServiceResult<ScheduleTemplateModel>> updateScheduleTemplate(
    int templateId,
    Map<String, dynamic> payload,
  ) {
    return RetryHelper.execute<ScheduleTemplateModel>(() async {
      final response = await _client.dio.put(
        '/schedule-templates/$templateId',
        data: payload,
      );
      return ScheduleTemplateModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to update schedule template');
  }

  Future<ServiceResult<void>> deleteScheduleTemplate(int templateId) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.delete('/schedule-templates/$templateId');
    }, fallbackMessage: 'Failed to delete schedule template');
  }

  Future<ServiceResult<Map<String, dynamic>>> applyTemplate({
    required int templateId,
    required int sectionId,
    String? building,
    String? room,
  }) {
    return RetryHelper.execute<Map<String, dynamic>>(() async {
      final payload = <String, dynamic>{
        'templateId': templateId,
        'sectionId': sectionId,
      };
      if (building != null && building.trim().isNotEmpty) {
        payload['building'] = building.trim();
      }
      if (room != null && room.trim().isNotEmpty) {
        payload['room'] = room.trim();
      }

      final response = await _client.dio.post(
        '/schedule-templates/apply',
        data: payload,
      );
      return _extractMap(response.data);
    }, fallbackMessage: 'Failed to apply template');
  }

  Future<ServiceResult<Map<String, dynamic>>> bulkApplyTemplate({
    required int templateId,
    required List<int> sectionIds,
    String? building,
    String? room,
  }) {
    return RetryHelper.execute<Map<String, dynamic>>(() async {
      final payload = <String, dynamic>{
        'templateId': templateId,
        'sectionIds': sectionIds,
      };
      if (building != null && building.trim().isNotEmpty) {
        payload['building'] = building.trim();
      }
      if (room != null && room.trim().isNotEmpty) {
        payload['room'] = room.trim();
      }

      final response = await _client.dio.post(
        '/schedule-templates/apply/bulk',
        data: payload,
      );
      return _extractMap(response.data);
    }, fallbackMessage: 'Failed to bulk apply template');
  }

  Future<ServiceResult<PaginatedResult<OfficeHourSlotModel>>> getOfficeHours({
    int page = 1,
    int limit = 10,
    int? instructorId,
    String? dayOfWeek,
  }) {
    return RetryHelper.execute<PaginatedResult<OfficeHourSlotModel>>(() async {
      final query = <String, dynamic>{'page': page, 'limit': limit};
      if (instructorId != null) {
        query['instructorId'] = instructorId;
      }
      if (dayOfWeek != null && dayOfWeek.trim().isNotEmpty) {
        query['dayOfWeek'] = dayOfWeek.trim();
      }

      Response<dynamic> response;
      try {
        response = await _client.dio.get(
          '/office-hours',
          queryParameters: query,
        );
      } on DioException {
        response = await _client.dio.get(
          '/office-hours/slots',
          queryParameters: query,
        );
      }

      return _extractPaginated(
        response.data,
        OfficeHourSlotModel.fromJson,
        primaryListKeys: const <String>['data', 'slots', 'items'],
      );
    }, fallbackMessage: 'Failed to load office hours');
  }

  Future<ServiceResult<OfficeHourSlotModel>> createOfficeHour(
    Map<String, dynamic> payload,
  ) {
    return RetryHelper.execute<OfficeHourSlotModel>(() async {
      Response<dynamic> response;
      try {
        response = await _client.dio.post('/office-hours', data: payload);
      } on DioException {
        response = await _client.dio.post('/office-hours/slots', data: payload);
      }
      return OfficeHourSlotModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to create office hour');
  }

  Future<ServiceResult<OfficeHourSlotModel>> updateOfficeHour(
    int slotId,
    Map<String, dynamic> payload,
  ) {
    return RetryHelper.execute<OfficeHourSlotModel>(() async {
      Response<dynamic> response;
      try {
        response = await _client.dio.put(
          '/office-hours/$slotId',
          data: payload,
        );
      } on DioException {
        response = await _client.dio.put(
          '/office-hours/slots/$slotId',
          data: payload,
        );
      }
      return OfficeHourSlotModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to update office hour');
  }

  Future<ServiceResult<void>> deleteOfficeHour(int slotId) {
    return RetryHelper.executeVoid(() async {
      try {
        await _client.dio.delete('/office-hours/$slotId');
      } on DioException {
        await _client.dio.delete('/office-hours/slots/$slotId');
      }
    }, fallbackMessage: 'Failed to delete office hour');
  }

  Future<ServiceResult<PaginatedResult<OfficeHourAppointmentModel>>>
  getOfficeHourAppointments({
    required int slotId,
    int page = 1,
    int limit = 10,
  }) {
    return RetryHelper.execute<PaginatedResult<OfficeHourAppointmentModel>>(
      () async {
        final response = await _client.dio.get(
          '/office-hours/appointments',
          queryParameters: <String, dynamic>{
            'slotId': slotId,
            'page': page,
            'limit': limit,
          },
        );
        return _extractPaginated(
          response.data,
          OfficeHourAppointmentModel.fromJson,
          primaryListKeys: const <String>['data', 'appointments', 'items'],
        );
      },
      fallbackMessage: 'Failed to load office hour appointments',
    );
  }

  Future<ServiceResult<List<AdminStaffSummaryModel>>> getStaffMembers() {
    return RetryHelper.execute<List<AdminStaffSummaryModel>>(() async {
      const roleFilters = <String>['instructor', 'teaching_assistant'];
      final byId = <int, AdminStaffSummaryModel>{};

      for (final role in roleFilters) {
        final response = await _client.dio.get(
          '/admin/users',
          queryParameters: <String, dynamic>{
            'page': 1,
            'size': 100,
            'role': role,
            'status': 'active',
          },
        );

        final rows = _extractUsersList(response.data);
        for (final row in rows.whereType<Map<String, dynamic>>()) {
          final user = AdminStaffSummaryModel.fromJson(row);
          if (user.userId > 0) {
            byId[user.userId] = user;
          }
        }
      }

      final users = byId.values.toList()
        ..sort((a, b) => a.fullName.compareTo(b.fullName));
      return users;
    }, fallbackMessage: 'Failed to load instructors and TAs');
  }

  List<dynamic> _extractUsersList(dynamic payload) {
    final rows = _extractList(payload);
    if (rows.isNotEmpty) {
      return rows;
    }

    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is Map<String, dynamic>) {
        final nested = data['users'] ?? data['results'];
        if (nested is List) {
          return nested;
        }
      }

      final users = payload['users'];
      if (users is List) {
        return users;
      }
    }

    return const <dynamic>[];
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
            final nestedMeta = value['meta'];
            if (nestedMeta is Map<String, dynamic>) {
              metaMap = nestedMeta;
            }
            break;
          }
        }
      }

      if (listCandidate is List) {
        rows.addAll(listCandidate);
      } else {
        rows.addAll(_extractList(payload));
      }

      if (metaMap.isEmpty) {
        final pagination = payload['pagination'];
        if (pagination is Map<String, dynamic>) {
          metaMap = pagination;
        }
      }
    }

    final items = rows.whereType<Map<String, dynamic>>().map(mapper).toList();

    final fallbackTotal = items.length;
    final meta = PaginationMeta.fromJson(<String, dynamic>{
      'page': metaMap['page'] ?? 1,
      'limit': metaMap['limit'] ?? items.length,
      'total': metaMap['total'] ?? fallbackTotal,
      'totalPages': metaMap['totalPages'] ?? 1,
    });

    return PaginatedResult<T>(items: items, meta: meta);
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

  List<dynamic> _extractList(dynamic payload) {
    if (payload is List) {
      return payload;
    }

    if (payload is! Map<String, dynamic>) {
      return const <dynamic>[];
    }

    final keys = <String>['data', 'items', 'results', 'rows'];
    for (final key in keys) {
      final value = payload[key];
      if (value is List) {
        return value;
      }
      if (value is Map<String, dynamic>) {
        final nested = value['data'] ?? value['items'] ?? value['results'];
        if (nested is List) {
          return nested;
        }
      }
    }

    for (final value in payload.values) {
      if (value is List) {
        return value;
      }
    }

    return const <dynamic>[];
  }
}
