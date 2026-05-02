import 'dart:io';

import 'package:dio/dio.dart';

import '../../common/retry_helper.dart';
import '../../common/service_error.dart';
import '../../models/attendance/ai_processing_result_model.dart';
import '../../models/attendance/attendance_session_model.dart';
import '../../models/attendance/student_attendance_summary_model.dart';
import '../../models/attendance/student_face_reference_model.dart';
import 'core_api_client.dart';

/// Service for Attendance API endpoints.
///
/// **Important:** The backend attendance controller uses
/// `@Controller('attendance')` — without the `api/` prefix that most other
/// controllers use.  The web frontend mirrors this with its `~/` (rawBaseURL)
/// convention.  We therefore compute a [_base] URL that strips the trailing
/// `/api` from the Dio base URL and build absolute URLs so Dio does not
/// prepend `…/api/` to attendance paths.
class AttendanceService {
  final CoreApiClient _client;

  AttendanceService({required CoreApiClient coreApiClient})
    : _client = coreApiClient;

  /// Raw base URL **without** the `/api` suffix.
  ///
  /// Example: if `dio.options.baseUrl` is `http://10.0.2.2:8081/api`
  /// this returns `http://10.0.2.2:8081`.
  String get _base =>
      _client.dio.options.baseUrl.replaceAll(RegExp(r'/api/?$'), '');

  // ── Student Endpoints ──────────────────────────────────────────────────

  Future<ServiceResult<List<StudentAttendanceSummaryModel>>> getMyAttendance({
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<List<StudentAttendanceSummaryModel>>(() async {
      final response = await _client.dio.get(
        '$_base/attendance/my',
        cancelToken: cancelToken,
      );
      final payload = response.data;

      List<dynamic> list;
      if (payload is List) {
        list = payload;
      } else if (payload is Map<String, dynamic>) {
        if (payload['summary'] is List) {
          list = payload['summary'] as List;
        } else if (payload['data'] is List) {
          list = payload['data'] as List;
        } else {
          // The backend /attendance/my returns a single flat summary object
          // (totalSessions, totalPresent, etc.) — not an array. Wrap it so
          // downstream parsing can handle it uniformly.
          list = <dynamic>[payload];
        }
      } else {
        list = <dynamic>[];
      }

      return list
          .whereType<Map<String, dynamic>>()
          .map(StudentAttendanceSummaryModel.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to load your attendance');
  }

  Future<ServiceResult<List<StudentAttendanceSummaryModel>>> getByStudent(
    int userId, {
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<List<StudentAttendanceSummaryModel>>(() async {
      final response = await _client.dio.get(
        '$_base/attendance/by-student/$userId',
        cancelToken: cancelToken,
      );
      final payload = response.data;

      List<dynamic> list;
      if (payload is Map<String, dynamic> && payload['summary'] is List) {
        list = payload['summary'] as List;
      } else {
        list = _extractList(payload);
      }

      return list
          .whereType<Map<String, dynamic>>()
          .map(StudentAttendanceSummaryModel.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to load student attendance');
  }

  // ── Session Endpoints ──────────────────────────────────────────────────

  Future<ServiceResult<List<AttendanceSessionModel>>> getSessions({
    int? sectionId,
    int? courseId,
    String? status,
    int? limit,
    String? sortBy,
    String? sortOrder,
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<List<AttendanceSessionModel>>(() async {
      final params = <String, dynamic>{};
      if (sectionId != null) params['sectionId'] = sectionId;
      if (courseId != null) params['courseId'] = courseId;
      if (status != null) params['status'] = status;
      if (limit != null) params['limit'] = limit;
      if (sortBy != null) params['sortBy'] = sortBy;
      if (sortOrder != null) params['sortOrder'] = sortOrder;

      final response = await _client.dio.get(
        '$_base/attendance/sessions',
        queryParameters: params.isEmpty ? null : params,
        cancelToken: cancelToken,
      );

      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(AttendanceSessionModel.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to load attendance sessions');
  }

  Future<ServiceResult<AttendanceSessionModel>> createSession({
    required int sectionId,
    required String sessionDate,
    required String sessionType,
    int? totalMinutes,
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<AttendanceSessionModel>(() async {
      final body = <String, dynamic>{
        'sectionId': sectionId,
        'sessionDate': sessionDate,
        'sessionType': sessionType,
      };
      if (totalMinutes != null) body['totalMinutes'] = totalMinutes;

      final response = await _client.dio.post(
        '$_base/attendance/sessions',
        data: body,
        cancelToken: cancelToken,
      );
      return AttendanceSessionModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to create attendance session');
  }

  Future<ServiceResult<AttendanceSessionModel>> getSessionDetails(
    int id, {
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<AttendanceSessionModel>(() async {
      final response = await _client.dio.get(
        '$_base/attendance/sessions/$id',
        cancelToken: cancelToken,
      );
      return AttendanceSessionModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to load session details');
  }

  Future<ServiceResult<AttendanceSessionModel>> updateSession(
    int id,
    Map<String, dynamic> data, {
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<AttendanceSessionModel>(() async {
      final response = await _client.dio.put(
        '$_base/attendance/sessions/$id',
        data: data,
        cancelToken: cancelToken,
      );
      return AttendanceSessionModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to update session');
  }

  Future<ServiceResult<void>> deleteSession(
    int id, {
    CancelToken? cancelToken,
  }) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.delete(
        '$_base/attendance/sessions/$id',
        cancelToken: cancelToken,
      );
    }, fallbackMessage: 'Failed to delete session');
  }

  Future<ServiceResult<void>> closeSession(int id, {CancelToken? cancelToken}) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.patch(
        '$_base/attendance/sessions/$id/close',
        cancelToken: cancelToken,
      );
    }, fallbackMessage: 'Failed to close session');
  }

  // ── Records Endpoints ──────────────────────────────────────────────────

  Future<ServiceResult<void>> markBatchAttendance({
    required int sessionId,
    required List<Map<String, dynamic>> records,
    CancelToken? cancelToken,
  }) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.post(
        '$_base/attendance/records/batch',
        data: <String, dynamic>{'sessionId': sessionId, 'records': records},
        cancelToken: cancelToken,
      );
    }, fallbackMessage: 'Failed to save attendance');
  }

  Future<ServiceResult<Map<String, dynamic>>> getSectionSummary(
    int sectionId, {
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<Map<String, dynamic>>(() async {
      final response = await _client.dio.get(
        '$_base/attendance/summary/$sectionId',
        cancelToken: cancelToken,
      );
      return _extractMap(response.data);
    }, fallbackMessage: 'Failed to load section summary');
  }

  // ── Face Reference Endpoints (Student) ─────────────────────────────────

  Future<ServiceResult<StudentFaceReferenceModel>> uploadMyFaceReference(
    File image, {
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<StudentFaceReferenceModel>(() async {
      final formData = FormData.fromMap(<String, dynamic>{
        'image': await MultipartFile.fromFile(
          image.path,
          filename: image.path.split(Platform.pathSeparator).last,
        ),
      });
      final response = await _client.dio.post(
        '$_base/attendance/face-references/me',
        data: formData,
        cancelToken: cancelToken,
      );
      return StudentFaceReferenceModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to upload face reference');
  }

  Future<ServiceResult<List<StudentFaceReferenceModel>>> listMyFaceReferences({
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<List<StudentFaceReferenceModel>>(() async {
      final response = await _client.dio.get(
        '$_base/attendance/face-references/me',
        cancelToken: cancelToken,
      );
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(StudentFaceReferenceModel.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to load face references');
  }

  Future<ServiceResult<void>> deleteMyFaceReference(
    int id, {
    CancelToken? cancelToken,
  }) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.delete(
        '$_base/attendance/face-references/me/$id',
        cancelToken: cancelToken,
      );
    }, fallbackMessage: 'Failed to delete face reference');
  }

  // ── AI Attendance Endpoints ────────────────────────────────────────────

  Future<ServiceResult<AiProcessingResultModel>> uploadAiPhoto({
    required int sessionId,
    required File photo,
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<AiProcessingResultModel>(() async {
      final formData = FormData.fromMap(<String, dynamic>{
        'photo': await MultipartFile.fromFile(
          photo.path,
          filename: photo.path.split(Platform.pathSeparator).last,
        ),
        'sessionId': sessionId.toString(),
      });

      final response = await _client.dio.post(
        '$_base/attendance/ai-photo',
        data: formData,
        cancelToken: cancelToken,
      );
      return AiProcessingResultModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to upload AI attendance photo');
  }

  Future<ServiceResult<AiProcessingResultModel>> getAiProcessingResult(
    int processingId, {
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<AiProcessingResultModel>(() async {
      final response = await _client.dio.get(
        '$_base/attendance/ai-photo/$processingId',
        cancelToken: cancelToken,
      );
      return AiProcessingResultModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to get AI processing result');
  }

  Future<ServiceResult<AiProcessingResultModel>> pollAiResult(
    int processingId, {
    Duration timeout = const Duration(seconds: 120),
    Duration interval = const Duration(milliseconds: 2500),
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<AiProcessingResultModel>(() async {
      final deadline = DateTime.now().add(timeout);

      while (DateTime.now().isBefore(deadline)) {
        final response = await _client.dio.get(
          '$_base/attendance/ai-photo/$processingId',
          cancelToken: cancelToken,
        );
        final model = AiProcessingResultModel.fromJson(
          _extractMap(response.data),
        );

        if (model.isCompleted || model.isFailed || model.needsManualReview) {
          return model;
        }

        await Future<void>.delayed(interval);
      }

      throw Exception(
        'AI processing timed out after ${timeout.inSeconds}s. '
        'Try again or check backend logs.',
      );
    }, fallbackMessage: 'AI processing polling failed');
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  static Map<String, dynamic> _extractMap(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is Map<String, dynamic>) return data;
      return payload;
    }
    return <String, dynamic>{};
  }

  static List<dynamic> _extractList(dynamic payload) {
    if (payload is List) return payload;
    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is List) return data;
      for (final value in payload.values) {
        if (value is List) return value;
      }
    }
    return <dynamic>[];
  }
}
