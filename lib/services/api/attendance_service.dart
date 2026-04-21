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
/// Wraps all `/api/attendance` calls.
class AttendanceService {
  final CoreApiClient _client;

  AttendanceService({required CoreApiClient coreApiClient})
    : _client = coreApiClient;

  // Student Endpoints

  Future<ServiceResult<List<StudentAttendanceSummaryModel>>> getMyAttendance() {
    return RetryHelper.execute<List<StudentAttendanceSummaryModel>>(() async {
      final response = await _client.dio.get('/attendance/my');
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
          list = <dynamic>[];
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
    int userId,
  ) {
    return RetryHelper.execute<List<StudentAttendanceSummaryModel>>(() async {
      final response = await _client.dio.get('/attendance/by-student/$userId');
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

  // Session Endpoints

  Future<ServiceResult<List<AttendanceSessionModel>>> getSessions({
    int? sectionId,
    int? courseId,
    String? status,
    int? limit,
    String? sortBy,
    String? sortOrder,
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
        '/attendance/sessions',
        queryParameters: params.isEmpty ? null : params,
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
  }) {
    return RetryHelper.execute<AttendanceSessionModel>(() async {
      final body = <String, dynamic>{
        'sectionId': sectionId,
        'sessionDate': sessionDate,
        'sessionType': sessionType,
      };
      if (totalMinutes != null) body['totalMinutes'] = totalMinutes;

      final response = await _client.dio.post(
        '/attendance/sessions',
        data: body,
      );
      return AttendanceSessionModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to create attendance session');
  }

  Future<ServiceResult<AttendanceSessionModel>> getSessionDetails(int id) {
    return RetryHelper.execute<AttendanceSessionModel>(() async {
      final response = await _client.dio.get('/attendance/sessions/$id');
      return AttendanceSessionModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to load session details');
  }

  Future<ServiceResult<AttendanceSessionModel>> updateSession(
    int id,
    Map<String, dynamic> data,
  ) {
    return RetryHelper.execute<AttendanceSessionModel>(() async {
      final response = await _client.dio.put(
        '/attendance/sessions/$id',
        data: data,
      );
      return AttendanceSessionModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to update session');
  }

  Future<ServiceResult<void>> deleteSession(int id) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.delete('/attendance/sessions/$id');
    }, fallbackMessage: 'Failed to delete session');
  }

  Future<ServiceResult<void>> closeSession(int id) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.patch('/attendance/sessions/$id/close');
    }, fallbackMessage: 'Failed to close session');
  }

  // Records Endpoints

  Future<ServiceResult<void>> markBatchAttendance({
    required int sessionId,
    required List<Map<String, dynamic>> records,
  }) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.post(
        '/attendance/records/batch',
        data: <String, dynamic>{'sessionId': sessionId, 'records': records},
      );
    }, fallbackMessage: 'Failed to save attendance');
  }

  Future<ServiceResult<Map<String, dynamic>>> getSectionSummary(int sectionId) {
    return RetryHelper.execute<Map<String, dynamic>>(() async {
      final response = await _client.dio.get('/attendance/summary/$sectionId');
      return _extractMap(response.data);
    }, fallbackMessage: 'Failed to load section summary');
  }

  // Face Reference Endpoints (Student)

  Future<ServiceResult<StudentFaceReferenceModel>> uploadMyFaceReference(
    File image,
  ) {
    return RetryHelper.execute<StudentFaceReferenceModel>(() async {
      final formData = FormData.fromMap(<String, dynamic>{
        'image': await MultipartFile.fromFile(
          image.path,
          filename: image.path.split(Platform.pathSeparator).last,
        ),
      });
      final response = await _client.dio.post(
        '/attendance/face-references/me',
        data: formData,
      );
      return StudentFaceReferenceModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to upload face reference');
  }

  Future<ServiceResult<List<StudentFaceReferenceModel>>>
  listMyFaceReferences() {
    return RetryHelper.execute<List<StudentFaceReferenceModel>>(() async {
      final response = await _client.dio.get('/attendance/face-references/me');
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(StudentFaceReferenceModel.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to load face references');
  }

  Future<ServiceResult<void>> deleteMyFaceReference(int id) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.delete('/attendance/face-references/me/$id');
    }, fallbackMessage: 'Failed to delete face reference');
  }

  // AI Attendance Endpoints

  Future<ServiceResult<AiProcessingResultModel>> uploadAiPhoto({
    required int sessionId,
    required File photo,
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
        '/attendance/ai-photo',
        data: formData,
      );
      return AiProcessingResultModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to upload AI attendance photo');
  }

  Future<ServiceResult<AiProcessingResultModel>> getAiProcessingResult(
    int processingId,
  ) {
    return RetryHelper.execute<AiProcessingResultModel>(() async {
      final response = await _client.dio.get(
        '/attendance/ai-photo/$processingId',
      );
      return AiProcessingResultModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to get AI processing result');
  }

  Future<ServiceResult<AiProcessingResultModel>> pollAiResult(
    int processingId, {
    Duration timeout = const Duration(seconds: 120),
    Duration interval = const Duration(milliseconds: 2500),
  }) {
    return RetryHelper.execute<AiProcessingResultModel>(() async {
      final deadline = DateTime.now().add(timeout);

      while (DateTime.now().isBefore(deadline)) {
        final response = await _client.dio.get(
          '/attendance/ai-photo/$processingId',
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

  // Helpers

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
