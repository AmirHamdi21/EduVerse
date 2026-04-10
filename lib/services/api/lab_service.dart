import 'dart:io';

import 'package:dio/dio.dart';

import '../../common/retry_helper.dart';
import '../../common/service_error.dart';
import '../../models/core/drive_file_model.dart';
import '../../models/core/lab_attendance_model.dart';
import '../../models/core/lab_instruction_model.dart';
import '../../models/labs/lab_model.dart';
import '../../models/labs/lab_submission_model.dart';
import 'core_api_client.dart';

class LabService {
  final CoreApiClient _client;

  LabService({required CoreApiClient coreApiClient}) : _client = coreApiClient;

  Future<ServiceResult<List<LabModel>>> getAll({int? courseId}) {
    return RetryHelper.execute<List<LabModel>>(() async {
      final response = await _client.dio.get(
        '/labs',
        queryParameters: courseId == null
            ? null
            : <String, dynamic>{'courseId': courseId},
      );
      return _extractList(
        response.data,
      ).whereType<Map<String, dynamic>>().map(LabModel.fromJson).toList();
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
      final response = await _client.dio.patch('/labs/$id', data: data);
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

  Future<ServiceResult<DriveFileModel>> uploadInstructionFile(
    dynamic labId,
    File file, {
    String? title,
    int? orderIndex,
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
      );
      return DriveFileModel.fromJson(_extractMap(response.data));
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
      );
      return LabSubmissionModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to upload lab submission file');
  }

  Future<ServiceResult<LabSubmissionModel>> getMySubmission(dynamic labId) {
    return RetryHelper.execute<LabSubmissionModel>(() async {
      final response = await _client.dio.get('/labs/$labId/my-submission');
      return LabSubmissionModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to load your lab submission');
  }

  Future<ServiceResult<Map<String, dynamic>>> gradeSubmission(
    dynamic labId,
    dynamic submissionId,
    double score, {
    String? feedback,
  }) {
    return RetryHelper.execute<Map<String, dynamic>>(() async {
      final response = await _client.dio.patch(
        '/labs/$labId/submissions/$submissionId/grade',
        data: <String, dynamic>{
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
