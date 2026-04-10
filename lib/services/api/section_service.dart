import '../../common/retry_helper.dart';
import '../../common/service_error.dart';
import '../../models/core/section_model.dart';
import 'core_api_client.dart';

class SectionService {
  final CoreApiClient _client;

  SectionService({required CoreApiClient coreApiClient})
    : _client = coreApiClient;

  Future<ServiceResult<List<SectionModel>>> getByCourse(
    dynamic courseId, {
    int? semesterId,
  }) {
    return RetryHelper.execute<List<SectionModel>>(() async {
      final queryParameters = <String, dynamic>{};
      if (semesterId != null) {
        queryParameters['semesterId'] = semesterId;
      }

      final response = await _client.dio.get(
        '/sections/course/$courseId',
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      );
      final data = _extractList(response.data);
      return data
          .whereType<Map<String, dynamic>>()
          .map(SectionModel.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to load course sections');
  }

  Future<ServiceResult<SectionModel>> getById(dynamic id) {
    return RetryHelper.execute<SectionModel>(() async {
      final response = await _client.dio.get('/sections/$id');
      final data = _extractMap(response.data);
      return SectionModel.fromJson(data);
    }, fallbackMessage: 'Failed to load section');
  }

  Future<ServiceResult<SectionModel>> create(Map<String, dynamic> data) {
    return RetryHelper.execute<SectionModel>(() async {
      final response = await _client.dio.post('/sections', data: data);
      final payload = _extractMap(response.data);
      return SectionModel.fromJson(payload);
    }, fallbackMessage: 'Failed to create section');
  }

  Future<ServiceResult<SectionModel>> update(
    dynamic id,
    Map<String, dynamic> data,
  ) {
    return RetryHelper.execute<SectionModel>(() async {
      final response = await _client.dio.patch('/sections/$id', data: data);
      final payload = _extractMap(response.data);
      return SectionModel.fromJson(payload);
    }, fallbackMessage: 'Failed to update section');
  }

  Future<ServiceResult<SectionModel>> updateEnrollment(dynamic id, int count) {
    return RetryHelper.execute<SectionModel>(() async {
      final response = await _client.dio.patch(
        '/sections/$id/enrollment',
        data: <String, dynamic>{'currentEnrollment': count},
      );
      final payload = _extractMap(response.data);
      return SectionModel.fromJson(payload);
    }, fallbackMessage: 'Failed to update section enrollment');
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
