import 'dart:io';

import 'package:dio/dio.dart';

import '../../common/retry_helper.dart';
import '../../common/service_error.dart';
import '../../models/assignments/assignment_model.dart';
import '../../models/assignments/assignment_submission_model.dart';
import '../../models/core/drive_file_model.dart';
import '../../models/core/enums/assignment_enums.dart' as api;
import '../../models/core/paginated_response.dart';
import 'core_api_client.dart';

class AssignmentService {
  final CoreApiClient _client;

  AssignmentService({required CoreApiClient coreApiClient})
    : _client = coreApiClient;

  Future<ServiceResult<PaginatedResponse<AssignmentModel>>> getAll({
    int? courseId,
    int? sectionId,
    api.AssignmentStatus? status,
    String? search,
    int? page,
    int? limit,
    String? sortBy,
    String? sortOrder,
  }) {
    return RetryHelper.execute<PaginatedResponse<AssignmentModel>>(() async {
      final query = <String, dynamic>{};
      if (courseId != null) query['courseId'] = courseId;
      if (sectionId != null) query['sectionId'] = sectionId;
      if (status != null) query['status'] = status.toJson();
      if (search != null && search.isNotEmpty) query['search'] = search;
      if (page != null) query['page'] = page;
      if (limit != null) query['limit'] = limit;
      if (sortBy != null && sortBy.isNotEmpty) query['sortBy'] = sortBy;
      if (sortOrder != null && sortOrder.isNotEmpty) {
        query['sortOrder'] = sortOrder;
      }

      final response = await _client.dio.get(
        '/assignments',
        queryParameters: query.isEmpty ? null : query,
      );

      final payload = _extractPaginatedPayload(response.data);
      return PaginatedResponse<AssignmentModel>.fromJson(
        payload,
        AssignmentModel.fromJson,
      );
    }, fallbackMessage: 'Failed to load assignments');
  }

  Future<ServiceResult<AssignmentModel>> getById(dynamic id) {
    return RetryHelper.execute<AssignmentModel>(() async {
      final response = await _client.dio.get('/assignments/$id');
      return AssignmentModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to load assignment');
  }

  Future<ServiceResult<AssignmentModel>> create(Map<String, dynamic> data) {
    return RetryHelper.execute<AssignmentModel>(() async {
      final response = await _client.dio.post('/assignments', data: data);
      return AssignmentModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to create assignment');
  }

  Future<ServiceResult<AssignmentModel>> update(
    dynamic id,
    Map<String, dynamic> data,
  ) {
    return RetryHelper.execute<AssignmentModel>(() async {
      final response = await _client.dio.patch('/assignments/$id', data: data);
      return AssignmentModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to update assignment');
  }

  Future<ServiceResult<void>> delete(dynamic id) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.delete('/assignments/$id');
    }, fallbackMessage: 'Failed to delete assignment');
  }

  Future<ServiceResult<AssignmentModel>> updateStatus(
    dynamic id,
    api.AssignmentStatus status,
  ) {
    return RetryHelper.execute<AssignmentModel>(() async {
      final response = await _client.dio.patch(
        '/assignments/$id/status',
        data: <String, dynamic>{'status': status.toJson()},
      );
      return AssignmentModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to update assignment status');
  }

  Future<ServiceResult<List<AssignmentSubmissionModel>>> getSubmissions(
    dynamic assignmentId,
  ) {
    return RetryHelper.execute<List<AssignmentSubmissionModel>>(() async {
      final response = await _client.dio.get(
        '/assignments/$assignmentId/submissions',
      );
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(AssignmentSubmissionModel.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to load assignment submissions');
  }

  Future<ServiceResult<AssignmentSubmissionModel>> submit(
    dynamic assignmentId, {
    String? submissionText,
    String? submissionLink,
  }) {
    return RetryHelper.execute<AssignmentSubmissionModel>(() async {
      final body = <String, dynamic>{};
      if (submissionText != null) body['submissionText'] = submissionText;
      if (submissionLink != null) body['submissionLink'] = submissionLink;

      final response = await _client.dio.post(
        '/assignments/$assignmentId/submit',
        data: body,
      );
      return AssignmentSubmissionModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to submit assignment');
  }

  Future<ServiceResult<AssignmentSubmissionModel>> submitFile(
    dynamic assignmentId,
    File file, {
    String? submissionText,
    String? submissionLink,
    ProgressCallback? onSendProgress,
  }) {
    return RetryHelper.execute<AssignmentSubmissionModel>(() async {
      final formData = FormData.fromMap(<String, dynamic>{
        'file': await MultipartFile.fromFile(
          file.path,
          filename: _fileName(file),
        ),
        if (submissionText != null) 'submissionText': submissionText,
        if (submissionLink != null) 'submissionLink': submissionLink,
      });

      final response = await _client.dio.post(
        '/assignments/$assignmentId/submissions/upload',
        data: formData,
        onSendProgress: onSendProgress,
      );
      return AssignmentSubmissionModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to upload assignment submission file');
  }

  Future<ServiceResult<AssignmentSubmissionModel>> getMySubmission(
    dynamic assignmentId,
  ) {
    return RetryHelper.execute<AssignmentSubmissionModel>(() async {
      final response = await _client.dio.get(
        '/assignments/$assignmentId/submissions/my',
      );
      return AssignmentSubmissionModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to load your assignment submission');
  }

  Future<ServiceResult<Map<String, dynamic>>> gradeSubmission(
    dynamic assignmentId,
    dynamic submissionId,
    double score, {
    String? feedback,
  }) {
    return RetryHelper.execute<Map<String, dynamic>>(() async {
      final response = await _client.dio.patch(
        '/assignments/$assignmentId/submissions/$submissionId/grade',
        data: <String, dynamic>{
          'score': score,
          if (feedback != null) 'feedback': feedback,
        },
      );
      return _extractMap(response.data);
    }, fallbackMessage: 'Failed to grade assignment submission');
  }

  Future<ServiceResult<DriveFileModel>> uploadInstructionFile(
    dynamic assignmentId,
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
        '/assignments/$assignmentId/instructions/upload',
        data: formData,
        onSendProgress: onSendProgress,
      );
      final payload = _extractMap(response.data);
      final driveFileData = payload['driveFile'];
      if (driveFileData is Map<String, dynamic>) {
        // Keep top-level IDs (e.g. fileId/id) when backend wraps drive file details.
        return DriveFileModel.fromJson(<String, dynamic>{
          ...payload,
          ...driveFileData,
        });
      }
      return DriveFileModel.fromJson(payload);
    }, fallbackMessage: 'Failed to upload assignment instruction file');
  }

  Future<ServiceResult<void>> deleteInstructionFile(
    int assignmentId,
    String driveId,
  ) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.delete(
        '/assignments/$assignmentId/instructions/$driveId',
      );
    }, fallbackMessage: 'Failed to delete instruction file');
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
