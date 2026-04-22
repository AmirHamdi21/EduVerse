import '../../common/retry_helper.dart';
import '../../common/service_error.dart';
import '../../models/grades/api_grade_response.dart';
import '../../models/grades/api_transcript_response.dart';
import '../../models/student/grade_gpa_model.dart';
import 'core_api_client.dart';

class GradesService {
  final CoreApiClient _client;

  GradesService({required CoreApiClient coreApiClient})
    : _client = coreApiClient;

  Future<ServiceResult<List<ApiGradeResponse>>> getMyGrades() {
    return RetryHelper.execute<List<ApiGradeResponse>>(() async {
      final response = await _client.dio.get('/grades/my');
      final list = _extractList(response.data);
      return list
          .whereType<Map<String, dynamic>>()
          .map(ApiGradeResponse.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to load grades');
  }

  Future<ServiceResult<GradeGpaModel>> getStudentGpa(int studentId) {
    return RetryHelper.execute<GradeGpaModel>(() async {
      final response = await _client.dio.get('/grades/gpa/$studentId');
      final payload = _extractMap(response.data);

      payload['studentId'] ??= studentId;
      payload['gpa'] ??=
          payload['cumulativeGpa'] ??
          payload['semesterGpa'] ??
          payload['cumulativeGPA'];

      return GradeGpaModel.fromJson(payload);
    }, fallbackMessage: 'Failed to load GPA');
  }

  Future<ServiceResult<ApiTranscriptResponse>> getTranscript(int studentId) {
    return RetryHelper.execute<ApiTranscriptResponse>(() async {
      final response = await _client.dio.get('/grades/transcript/$studentId');
      final payload = _extractMap(response.data);
      return ApiTranscriptResponse.fromJson(payload);
    }, fallbackMessage: 'Failed to load transcript');
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

  static Map<String, dynamic> _extractMap(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      return Map<String, dynamic>.from(payload);
    }
    return <String, dynamic>{};
  }
}
