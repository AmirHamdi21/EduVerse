import 'dart:io';

import 'package:dio/dio.dart';

import '../../common/retry_helper.dart';
import '../../common/service_error.dart';
import '../../models/core/drive_file_model.dart';
import '../../models/core/lab_attendance_model.dart';
import '../../models/core/lab_instruction_model.dart';
import '../../models/core/paginated_response.dart';
import '../../models/labs/lab_model.dart';
import '../../models/labs/lab_submission_model.dart';
import 'core_api_client.dart';

class LabService {
  final CoreApiClient _client;

  LabService({required CoreApiClient coreApiClient}) : _client = coreApiClient;
  Future<ServiceResult<List<LabModel>>> getAll({
    int? courseId,
    String? status,
    String? search,
    int page = 1,
    int limit = 50,
  }) async {
    final paginated = await getAllPaginated(
      courseId: courseId,
      status: status,
      search: search,
      page: page,
      limit: limit,
    );

    if (!paginated.isSuccess || paginated.data == null) {
      return ServiceResult<List<LabModel>>.failure(
        paginated.error ??
            const ServiceError(
              type: ServiceErrorType.server,
              message: 'Failed to load labs',
            ),
      );
    }

    return ServiceResult<List<LabModel>>.success(paginated.data!.data);
  }

  Future<ServiceResult<PaginatedResponse<LabModel>>> getAllPaginated({
    int? courseId,
    String? status,
    String? search,
    int page = 1,
    int limit = 50,
  }) {
    return RetryHelper.execute<PaginatedResponse<LabModel>>(() async {
      final query = <String, dynamic>{'page': page, 'limit': limit};
      if (courseId != null) {
        query['courseId'] = courseId;
      }
      if (status != null && status.trim().isNotEmpty) {
        query['status'] = status.trim();
      }
      if (search != null && search.trim().isNotEmpty) {
        query['search'] = search.trim();
      }

      final response = await _client.dio.get('/labs', queryParameters: query);

      final payload = _extractPaginatedPayload(response.data);
      return PaginatedResponse<LabModel>.fromJson(payload, LabModel.fromJson);
    }, fallbackMessage: 'Failed to load labs');
  }

  Future<ServiceResult<LabModel>> getById(dynamic id) {
    return RetryHelper.execute<LabModel>(() async {
      final response = await _client.dio.get('/labs/$id');
      return LabModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to load lab');
  }

  Future<ServiceResult<LabModel>> create(Map<String, dynamic> data) {
    return RetryHelper.execute<LabModel>(() async {
      final response = await _client.dio.post('/labs', data: data);
      return LabModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to create lab');
  }

  Future<ServiceResult<LabModel>> update(
    dynamic id,
    Map<String, dynamic> data,
  ) {
    return RetryHelper.execute<LabModel>(() async {
      final response = await _client.dio.put('/labs/$id', data: data);
      return LabModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to update lab');
  }

  Future<ServiceResult<void>> delete(dynamic id) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.delete('/labs/$id');
    }, fallbackMessage: 'Failed to delete lab');
  }

  Future<ServiceResult<List<LabInstructionModel>>> getInstructions(
    dynamic labId,
  ) {
    return RetryHelper.execute<List<LabInstructionModel>>(() async {
      final response = await _client.dio.get('/labs/$labId/instructions');
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(LabInstructionModel.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to load lab instructions');
  }

  Future<ServiceResult<LabInstructionModel>> addInstruction(
    dynamic labId,
    Map<String, dynamic> data,
  ) {
    return RetryHelper.execute<LabInstructionModel>(() async {
      final response = await _client.dio.post(
        '/labs/$labId/instructions',
        data: data,
      );
      return LabInstructionModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to add lab instruction');
  }

  Future<ServiceResult<LabInstructionModel>> updateInstruction(
    dynamic labId,
    dynamic instructionId,
    Map<String, dynamic> data,
  ) {
    return RetryHelper.execute<LabInstructionModel>(() async {
      final response = await _client.dio.patch(
        '/labs/$labId/instructions/$instructionId',
        data: data,
      );
      return LabInstructionModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to update lab instruction');
  }

  Future<ServiceResult<void>> deleteInstruction(
    dynamic labId,
    dynamic instructionId,
  ) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.delete('/labs/$labId/instructions/$instructionId');
    }, fallbackMessage: 'Failed to delete lab instruction');
  }

  Future<ServiceResult<DriveFileModel>> uploadInstructionFile(
    dynamic labId,
    File file, {
    String? title,
    int? orderIndex,
    ProgressCallback? onSendProgress,
  }) {
    return RetryHelper.execute<DriveFileModel>(() async {
      final formData = FormData.fromMap(<String, dynamic>{
        'file': await MultipartFile.fromFile(
          file.path,
          filename: _fileName(file),
        ),
        if (title != null) 'title': title,
        if (orderIndex != null) 'orderIndex': orderIndex,
      });

      final response = await _client.dio.post(
        '/labs/$labId/instructions/upload',
        data: formData,
        onSendProgress: onSendProgress,
      );
      final payload = _extractMap(response.data);
      final fileData = payload['file'];
      if (fileData is Map<String, dynamic>) {
        return DriveFileModel.fromJson(<String, dynamic>{
          ...payload,
          ...fileData,
        });
      }
      return DriveFileModel.fromJson(payload);
    }, fallbackMessage: 'Failed to upload lab instruction file');
  }

  Future<ServiceResult<List<LabSubmissionModel>>> getSubmissions(
    dynamic labId,
  ) {
    return RetryHelper.execute<List<LabSubmissionModel>>(() async {
      final response = await _client.dio.get('/labs/$labId/submissions');
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(LabSubmissionModel.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to load lab submissions');
  }

  Future<ServiceResult<LabSubmissionModel>> submit(
    dynamic labId, {
    String? submissionText,
    String? submissionLink,
  }) {
    return RetryHelper.execute<LabSubmissionModel>(() async {
      final body = <String, dynamic>{};
      if (submissionText != null) body['submissionText'] = submissionText;
      if (submissionLink != null) body['submissionLink'] = submissionLink;

      final response = await _client.dio.post(
        '/labs/$labId/submit',
        data: body,
      );
      return LabSubmissionModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to submit lab');
  }

  Future<ServiceResult<LabSubmissionModel>> submitFile(
    dynamic labId,
    File file, {
    String? submissionText,
    ProgressCallback? onSendProgress,
  }) {
    return RetryHelper.execute<LabSubmissionModel>(() async {
      final formData = FormData.fromMap(<String, dynamic>{
        'file': await MultipartFile.fromFile(
          file.path,
          filename: _fileName(file),
        ),
        if (submissionText != null) 'submissionText': submissionText,
      });

      final response = await _client.dio.post(
        '/labs/$labId/submissions/upload',
        data: formData,
        onSendProgress: onSendProgress,
      );
      return LabSubmissionModel.fromJson(
        _extractSubmissionPayload(response.data),
      );
    }, fallbackMessage: 'Failed to upload lab submission file');
  }

  Future<ServiceResult<List<LabSubmissionModel>>> getMySubmission(
    dynamic labId,
  ) {
    return RetryHelper.execute<List<LabSubmissionModel>>(() async {
      final response = await _client.dio.get('/labs/$labId/submissions/my');

      final listPayload = _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(LabSubmissionModel.fromJson)
          .toList();

      if (listPayload.isNotEmpty) {
        return listPayload;
      }

      final mapPayload = _extractMap(response.data);
      if (mapPayload.isEmpty) {
        return const <LabSubmissionModel>[];
      }

      return <LabSubmissionModel>[LabSubmissionModel.fromJson(mapPayload)];
    }, fallbackMessage: 'Failed to load your lab submissions');
  }

  Future<ServiceResult<Map<String, dynamic>>> gradeSubmission(
    dynamic labId,
    dynamic submissionId,
    double score, {
    String status = 'graded',
    String? feedback,
  }) {
    return RetryHelper.execute<Map<String, dynamic>>(() async {
      final response = await _client.dio.patch(
        '/labs/$labId/submissions/$submissionId/grade',
        data: <String, dynamic>{
          'status': status,
          'score': score,
          if (feedback != null) 'feedback': feedback,
        },
      );
      return _extractMap(response.data);
    }, fallbackMessage: 'Failed to grade lab submission');
  }

  Future<ServiceResult<List<LabAttendanceModel>>> getAttendance(dynamic labId) {
    return RetryHelper.execute<List<LabAttendanceModel>>(() async {
      final response = await _client.dio.get('/labs/$labId/attendance');
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(LabAttendanceModel.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to load lab attendance');
  }

  Future<ServiceResult<LabAttendanceModel>> markAttendance(
    dynamic labId,
    Map<String, dynamic> data,
  ) {
    return RetryHelper.execute<LabAttendanceModel>(() async {
      final response = await _client.dio.post(
        '/labs/$labId/attendance',
        data: data,
      );
      return LabAttendanceModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to mark lab attendance');
  }

  Future<ServiceResult<List<LabAttendanceModel>>> markAttendanceBulk(
    dynamic labId,
    List<Map<String, dynamic>> data,
  ) {
    return RetryHelper.execute<List<LabAttendanceModel>>(() async {
      final response = await _client.dio.post(
        '/labs/$labId/attendance',
        data: data,
      );
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(LabAttendanceModel.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to mark lab attendance');
  }

  Future<ServiceResult<DriveFileModel>> uploadTaMaterial(
    dynamic labId,
    File file,
  ) {
    return RetryHelper.execute<DriveFileModel>(() async {
      final formData = FormData.fromMap(<String, dynamic>{
        'file': await MultipartFile.fromFile(
          file.path,
          filename: _fileName(file),
        ),
      });

      final response = await _client.dio.post(
        '/labs/$labId/ta-materials/upload',
        data: formData,
      );
      return DriveFileModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to upload TA material');
  }

  static String _fileName(File file) {
    if (file.uri.pathSegments.isNotEmpty) {
      return file.uri.pathSegments.last;
    }
    return 'upload.bin';
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

  static Map<String, dynamic> _extractSubmissionPayload(dynamic payload) {
    final data = _extractMap(payload);
    final submission = data['submission'];
    if (submission is Map<String, dynamic>) {
      return submission;
    }
    return data;
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

  static Map<String, dynamic> _extractPaginatedPayload(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      final meta = payload['meta'];
      if (data is List && meta is Map<String, dynamic>) {
        return payload;
      }
      if (data is List) {
        return <String, dynamic>{
          'data': data,
          'meta': <String, dynamic>{
            'total': data.length,
            'page': 1,
            'limit': data.isEmpty ? 1 : data.length,
            'totalPages': 1,
          },
        };
      }
    }

    if (payload is List) {
      return <String, dynamic>{
        'data': payload,
        'meta': <String, dynamic>{
          'total': payload.length,
          'page': 1,
          'limit': payload.isEmpty ? 1 : payload.length,
          'totalPages': 1,
        },
      };
    }

    return <String, dynamic>{
      'data': <dynamic>[],
      'meta': <String, dynamic>{
        'total': 0,
        'page': 1,
        'limit': 1,
        'totalPages': 1,
      },
    };
  }
}
