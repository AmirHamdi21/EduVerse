import '../../common/retry_helper.dart';
import '../../common/service_error.dart';
import '../../models/core/semester_model.dart';
import 'core_api_client.dart';

class SemesterService {
  final CoreApiClient _client;

  SemesterService({required CoreApiClient coreApiClient})
    : _client = coreApiClient;

  Future<ServiceResult<List<SemesterModel>>> getAll() {
    return RetryHelper.execute<List<SemesterModel>>(() async {
      final response = await _client.dio.get('/enrollments/periods');
      final data = _extractList(response.data);
      return data
          .whereType<Map<String, dynamic>>()
          .map(SemesterModel.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to fetch semesters');
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
