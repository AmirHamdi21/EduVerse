import '../../common/retry_helper.dart';
import '../../common/service_error.dart';
import '../../models/core/schedule_model.dart';
import 'core_api_client.dart';

class ScheduleService {
  final CoreApiClient _client;

  ScheduleService({required CoreApiClient coreApiClient})
    : _client = coreApiClient;

  Future<ServiceResult<List<ScheduleModel>>> getBySection(dynamic sectionId) {
    return RetryHelper.execute<List<ScheduleModel>>(() async {
      final response = await _client.dio.get('/schedules/section/$sectionId');
      final data = _extractList(response.data);
      return data
          .whereType<Map<String, dynamic>>()
          .map(ScheduleModel.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to load section schedules');
  }

  Future<ServiceResult<ScheduleModel>> getById(dynamic id) {
    return RetryHelper.execute<ScheduleModel>(() async {
      final response = await _client.dio.get('/schedules/$id');
      final data = _extractMap(response.data);
      return ScheduleModel.fromJson(data);
    }, fallbackMessage: 'Failed to load schedule');
  }

  Future<ServiceResult<ScheduleModel>> create(
    dynamic sectionId,
    Map<String, dynamic> data,
  ) {
    return RetryHelper.execute<ScheduleModel>(() async {
      final response = await _client.dio.post(
        '/schedules/section/$sectionId',
        data: data,
      );
      final payload = _extractMap(response.data);
      return ScheduleModel.fromJson(payload);
    }, fallbackMessage: 'Failed to create schedule');
  }

  Future<ServiceResult<ScheduleModel>> update(
    dynamic id,
    Map<String, dynamic> data,
  ) {
    return RetryHelper.execute<ScheduleModel>(() async {
      final response = await _client.dio.put('/schedules/$id', data: data);
      final payload = _extractMap(response.data);
      return ScheduleModel.fromJson(payload);
    }, fallbackMessage: 'Failed to update schedule');
  }

  Future<ServiceResult<void>> delete(dynamic id) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.delete('/schedules/$id');
    }, fallbackMessage: 'Failed to delete schedule');
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
    }
    return <dynamic>[];
  }
}
