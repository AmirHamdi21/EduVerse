import 'package:dio/dio.dart';

import '../../common/retry_helper.dart';
import '../../common/service_error.dart';
import '../../models/question_bank/course_chapter_model.dart';
import '../../models/question_bank/question_bank_attachment_model.dart';
import '../../models/question_bank/question_bank_enums.dart';
import '../../models/question_bank/question_bank_form_payload.dart';
import '../../models/question_bank/question_bank_group_model.dart';
import '../../models/question_bank/question_bank_page_model.dart';
import '../../models/question_bank/question_bank_question_model.dart';
import '../../models/question_bank/question_bank_stats_model.dart';
import '../../models/question_bank/question_bank_upload_response.dart';
import '../../models/question_bank/question_bulk_create_result_model.dart';
import 'core_api_client.dart';

class QuestionBankService {
  QuestionBankService({required CoreApiClient coreApiClient})
    : _client = coreApiClient;

  final CoreApiClient _client;

  Future<ServiceResult<List<CourseChapterModel>>> getChapters(
    int courseId, {
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<List<CourseChapterModel>>(() async {
      final response = await _client.dio.get(
        '/courses/$courseId/chapters',
        cancelToken: cancelToken,
      );
      return _list(response.data)
          .whereType<Map<String, dynamic>>()
          .map(CourseChapterModel.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to load chapters');
  }

  Future<ServiceResult<CourseChapterModel>> createChapter({
    required int courseId,
    required String name,
    int? chapterOrder,
  }) {
    return RetryHelper.execute<CourseChapterModel>(() async {
      final response = await _client.dio.post(
        '/courses/$courseId/chapters',
        data: <String, dynamic>{
          'name': name,
          if (chapterOrder != null) 'chapterOrder': chapterOrder,
        },
      );
      return CourseChapterModel.fromJson(_map(response.data));
    }, fallbackMessage: 'Failed to create chapter');
  }

  Future<ServiceResult<CourseChapterModel>> updateChapter({
    required int courseId,
    required int chapterId,
    String? name,
    int? chapterOrder,
    bool? isActive,
  }) {
    return RetryHelper.execute<CourseChapterModel>(() async {
      final response = await _client.dio.patch(
        '/courses/$courseId/chapters/$chapterId',
        data: <String, dynamic>{
          if (name != null) 'name': name.trim(),
          if (chapterOrder != null) 'chapterOrder': chapterOrder,
          if (isActive != null) 'isActive': isActive ? 1 : 0,
        },
      );
      return CourseChapterModel.fromJson(_map(response.data));
    }, fallbackMessage: 'Failed to update chapter');
  }

  Future<ServiceResult<void>> deleteChapter({
    required int courseId,
    required int chapterId,
  }) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.delete('/courses/$courseId/chapters/$chapterId');
    }, fallbackMessage: 'Failed to delete chapter');
  }

  Future<ServiceResult<QuestionBankPageModel>> getQuestions({
    int? courseId,
    int? chapterId,
    QuestionBankType? questionType,
    QuestionBankDifficulty? difficulty,
    BloomLevel? bloomLevel,
    QuestionBankStatus? status,
    String? search,
    bool? hasAttachments,
    int? groupId,
    int page = 1,
    int limit = 20,
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<QuestionBankPageModel>(() async {
      final query = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (courseId != null) 'courseId': courseId,
        if (chapterId != null) 'chapterId': chapterId,
        if (questionType != null) 'questionType': questionType.value,
        if (difficulty != null) 'difficulty': difficulty.value,
        if (bloomLevel != null) 'bloomLevel': bloomLevel.value,
        if (status != null) 'status': status.value,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (hasAttachments != null) 'hasAttachments': hasAttachments,
        if (groupId != null) ...{
          'groupId': groupId,
          'questionGroupId': groupId,
          'groupIds': groupId,
        },
      };
      final response = await _client.dio.get(
        '/question-bank/questions',
        queryParameters: query,
        cancelToken: cancelToken,
      );
      return QuestionBankPageModel.fromJson(
        _map(response.data),
        page: page,
        limit: limit,
      );
    }, fallbackMessage: 'Failed to load questions');
  }

  Future<ServiceResult<QuestionBankStatsModel>> getQuestionStats({
    int? courseId,
    int? chapterId,
    QuestionBankType? questionType,
    QuestionBankDifficulty? difficulty,
    BloomLevel? bloomLevel,
    QuestionBankStatus? status,
    String? search,
    bool? hasAttachments,
    int? groupId,
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<QuestionBankStatsModel>(() async {
      final response = await _client.dio.get(
        '/question-bank/questions/stats',
        queryParameters: <String, dynamic>{
          if (courseId != null) 'courseId': courseId,
          if (chapterId != null) 'chapterId': chapterId,
          if (questionType != null) 'questionType': questionType.value,
          if (difficulty != null) 'difficulty': difficulty.value,
          if (bloomLevel != null) 'bloomLevel': bloomLevel.value,
          if (status != null) 'status': status.value,
          if (search != null && search.trim().isNotEmpty)
            'search': search.trim(),
          if (hasAttachments != null) 'hasAttachments': hasAttachments,
          if (groupId != null) ...{
            'groupId': groupId,
            'questionGroupId': groupId,
            'groupIds': groupId,
          },
        },
        cancelToken: cancelToken,
      );
      return QuestionBankStatsModel.fromJson(_map(response.data));
    }, fallbackMessage: 'Failed to load question stats');
  }

  Future<ServiceResult<QuestionBankQuestionModel>> getQuestion(
    int questionId, {
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<QuestionBankQuestionModel>(() async {
      final response = await _client.dio.get(
        '/question-bank/questions/$questionId',
        cancelToken: cancelToken,
      );
      return QuestionBankQuestionModel.fromJson(_map(response.data));
    }, fallbackMessage: 'Failed to load question');
  }

  Future<ServiceResult<QuestionBankQuestionModel>> createQuestion(
    QuestionBankFormPayload payload,
  ) {
    return RetryHelper.execute<QuestionBankQuestionModel>(() async {
      final response = await _client.dio.post(
        '/question-bank/questions',
        data: payload.toCreateJson(),
      );
      return QuestionBankQuestionModel.fromJson(_map(response.data));
    }, fallbackMessage: 'Failed to create question');
  }

  Future<ServiceResult<QuestionBankQuestionModel>> updateQuestion({
    required int questionId,
    required Map<String, dynamic> dirtyPayload,
  }) {
    return RetryHelper.execute<QuestionBankQuestionModel>(() async {
      final response = await _client.dio.patch(
        '/question-bank/questions/$questionId',
        data: dirtyPayload,
      );
      return QuestionBankQuestionModel.fromJson(_map(response.data));
    }, fallbackMessage: 'Failed to update question');
  }

  Future<ServiceResult<void>> deleteQuestion(int questionId) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.delete('/question-bank/questions/$questionId');
    }, fallbackMessage: 'Failed to delete question');
  }

  Future<ServiceResult<List<QuestionBankQuestionModel>>> bulkCreateQuestions({
    required int courseId,
    int? defaultChapterId,
    required List<QuestionBankFormPayload> questions,
  }) {
    return RetryHelper.execute<List<QuestionBankQuestionModel>>(() async {
      final response = await _client.dio.post(
        '/question-bank/questions/batch',
        data: <String, dynamic>{
          'courseId': courseId,
          if (defaultChapterId != null) 'defaultChapterId': defaultChapterId,
          'questions': questions
              .map((question) => question.toCreateJson())
              .toList(),
        },
      );
      final created = _list(_map(response.data)['created']);
      return created
          .whereType<Map<String, dynamic>>()
          .map(QuestionBankQuestionModel.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to create questions');
  }

  Future<ServiceResult<QuestionBulkCreateResultModel>>
  bulkCreateQuestionsDetailed({
    required int courseId,
    int? defaultChapterId,
    required List<QuestionBankFormPayload> questions,
  }) {
    return RetryHelper.execute<QuestionBulkCreateResultModel>(() async {
      final response = await _client.dio.post(
        '/question-bank/questions/batch',
        data: <String, dynamic>{
          'courseId': courseId,
          if (defaultChapterId != null) 'defaultChapterId': defaultChapterId,
          'questions': questions
              .map((question) => question.toCreateJson())
              .toList(),
        },
      );
      return QuestionBulkCreateResultModel.fromJson(_map(response.data));
    }, fallbackMessage: 'Failed to create questions');
  }

  Future<ServiceResult<Map<int, int>>> getChapterQuestionCounts(int courseId) {
    return RetryHelper.execute<Map<int, int>>(() async {
      final response = await _client.dio.get(
        '/question-bank/questions/chapter-counts',
        queryParameters: {'courseId': courseId},
      );
      return {
        for (final item in _list(
          response.data,
        ).whereType<Map<String, dynamic>>())
          _int(item['chapterId']): _int(item['total']),
      };
    }, fallbackMessage: 'Failed to load chapter counts');
  }

  Future<ServiceResult<QuestionBankUploadResponse>> uploadQuestionImage(
    String path,
  ) {
    return RetryHelper.execute<QuestionBankUploadResponse>(() async {
      final response = await _client.dio.post(
        '/question-bank/questions/upload-image',
        data: FormData.fromMap(<String, dynamic>{
          'image': await MultipartFile.fromFile(path),
        }),
        options: Options(contentType: 'multipart/form-data'),
      );
      return QuestionBankUploadResponse.fromJson(_map(response.data));
    }, fallbackMessage: 'Failed to upload question image');
  }

  Future<ServiceResult<void>> deleteUploadedFile(int fileId) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.delete('/files/$fileId');
    }, fallbackMessage: 'Failed to delete uploaded file');
  }

  Future<ServiceResult<QuestionBankUploadResponse>> uploadGroupImage(
    String path,
  ) {
    return RetryHelper.execute<QuestionBankUploadResponse>(() async {
      final response = await _client.dio.post(
        '/question-bank/groups/upload-image',
        data: FormData.fromMap(<String, dynamic>{
          'image': await MultipartFile.fromFile(path),
        }),
        options: Options(contentType: 'multipart/form-data'),
      );
      return QuestionBankUploadResponse.fromJson(_map(response.data));
    }, fallbackMessage: 'Failed to upload group image');
  }

  Future<ServiceResult<QuestionBankAttachmentModel>> uploadAttachmentImage({
    required int questionId,
    required String path,
    String? caption,
    String? altText,
    int? displayOrder,
    bool? isPrimary,
  }) {
    return RetryHelper.execute<QuestionBankAttachmentModel>(() async {
      final response = await _client.dio.post(
        '/question-bank/questions/$questionId/attachments/upload-image',
        data: FormData.fromMap(<String, dynamic>{
          'image': await MultipartFile.fromFile(path),
          if (caption != null) 'caption': caption,
          if (altText != null) 'altText': altText,
          if (displayOrder != null) 'displayOrder': displayOrder,
          if (isPrimary != null) 'isPrimary': isPrimary,
        }),
        options: Options(contentType: 'multipart/form-data'),
      );
      return QuestionBankAttachmentModel.fromJson(_map(response.data));
    }, fallbackMessage: 'Failed to upload attachment');
  }

  Future<ServiceResult<QuestionBankAttachmentModel>> addAttachment({
    required int questionId,
    required int fileId,
    QuestionAttachmentType attachmentType = QuestionAttachmentType.image,
    String? caption,
    String? altText,
    int? displayOrder,
    bool? isPrimary,
  }) {
    return RetryHelper.execute<QuestionBankAttachmentModel>(() async {
      final response = await _client.dio.post(
        '/question-bank/questions/$questionId/attachments',
        data: <String, dynamic>{
          'fileId': fileId,
          'attachmentType': attachmentType.value,
          if (caption != null) 'caption': caption,
          if (altText != null) 'altText': altText,
          if (displayOrder != null) 'displayOrder': displayOrder,
          if (isPrimary != null) 'isPrimary': isPrimary,
        },
      );
      return QuestionBankAttachmentModel.fromJson(_map(response.data));
    }, fallbackMessage: 'Failed to add attachment');
  }

  Future<ServiceResult<void>> reorderAttachments({
    required int questionId,
    required List<Map<String, int>> items,
  }) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.patch(
        '/question-bank/questions/$questionId/attachments/reorder',
        data: <String, dynamic>{'items': items},
      );
    }, fallbackMessage: 'Failed to reorder attachments');
  }

  Future<ServiceResult<QuestionBankAttachmentModel>> updateAttachment({
    required int questionId,
    required int attachmentId,
    String? caption,
    String? altText,
    int? displayOrder,
    bool? isPrimary,
    bool clearCaption = false,
    bool clearAltText = false,
  }) {
    return RetryHelper.execute<QuestionBankAttachmentModel>(() async {
      final response = await _client.dio.patch(
        '/question-bank/questions/$questionId/attachments/$attachmentId',
        data: <String, dynamic>{
          if (clearCaption)
            'caption': null
          else if (caption != null)
            'caption': caption.trim(),
          if (clearAltText)
            'altText': null
          else if (altText != null)
            'altText': altText.trim(),
          if (displayOrder != null) 'displayOrder': displayOrder,
          if (isPrimary != null) 'isPrimary': isPrimary,
        },
      );
      return QuestionBankAttachmentModel.fromJson(_map(response.data));
    }, fallbackMessage: 'Failed to update attachment');
  }

  Future<ServiceResult<void>> removeAttachment({
    required int questionId,
    required int attachmentId,
  }) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.delete(
        '/question-bank/questions/$questionId/attachments/$attachmentId',
      );
    }, fallbackMessage: 'Failed to remove attachment');
  }

  Future<ServiceResult<QuestionBankQuestionModel>> statusAction({
    required int questionId,
    required String action,
    String? comment,
  }) {
    return RetryHelper.execute<QuestionBankQuestionModel>(() async {
      final response = await _client.dio.post(
        '/question-bank/questions/$questionId/$action',
        data: <String, dynamic>{
          if (comment != null && comment.trim().isNotEmpty)
            'comment': comment.trim(),
        },
      );
      return QuestionBankQuestionModel.fromJson(_map(response.data));
    }, fallbackMessage: 'Failed to update question status');
  }

  Future<ServiceResult<List<QuestionBankQuestionModel>>> batchStatusAction({
    required List<int> questionIds,
    required String action,
    String? comment,
  }) {
    return RetryHelper.execute<List<QuestionBankQuestionModel>>(() async {
      final response = await _client.dio.post(
        '/question-bank/questions/status/batch',
        data: <String, dynamic>{
          'questionIds': questionIds,
          'action': action,
          if (comment != null && comment.trim().isNotEmpty)
            'comment': comment.trim(),
        },
      );
      return _list(_map(response.data)['updated'])
          .whereType<Map<String, dynamic>>()
          .map(QuestionBankQuestionModel.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to update selected questions');
  }

  Future<ServiceResult<List<QuestionBankGroupModel>>> getGroups({
    int? courseId,
    int? chapterId,
    int page = 1,
    int limit = 50,
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<List<QuestionBankGroupModel>>(() async {
      final response = await _client.dio.get(
        '/question-bank/groups',
        queryParameters: <String, dynamic>{
          'page': page,
          'limit': limit,
          if (courseId != null) 'courseId': courseId,
          if (chapterId != null) 'chapterId': chapterId,
        },
        cancelToken: cancelToken,
      );
      return _list(_map(response.data)['data'])
          .whereType<Map<String, dynamic>>()
          .map(QuestionBankGroupModel.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to load groups');
  }

  Future<ServiceResult<QuestionBankGroupModel>> getGroup(int groupId) {
    return RetryHelper.execute<QuestionBankGroupModel>(() async {
      final response = await _client.dio.get('/question-bank/groups/$groupId');
      return QuestionBankGroupModel.fromJson(_map(response.data));
    }, fallbackMessage: 'Failed to load group');
  }

  Future<ServiceResult<QuestionBankGroupModel>> createGroup({
    required int courseId,
    String? title,
    String? sharedPrompt,
    int? sharedFileId,
    String? sharedFileCaption,
    String? sharedFileAltText,
    QuestionGroupType groupType = QuestionGroupType.other,
  }) {
    return RetryHelper.execute<QuestionBankGroupModel>(() async {
      final response = await _client.dio.post(
        '/question-bank/groups',
        data: <String, dynamic>{
          'courseId': courseId,
          if (title != null && title.trim().isNotEmpty) 'title': title.trim(),
          if (sharedPrompt != null && sharedPrompt.trim().isNotEmpty)
            'sharedPrompt': sharedPrompt.trim(),
          if (sharedFileId != null) 'sharedFileId': sharedFileId,
          if (sharedFileCaption != null && sharedFileCaption.trim().isNotEmpty)
            'sharedFileCaption': sharedFileCaption.trim(),
          if (sharedFileAltText != null && sharedFileAltText.trim().isNotEmpty)
            'sharedFileAltText': sharedFileAltText.trim(),
          'groupType': groupType.value,
        },
      );
      return QuestionBankGroupModel.fromJson(_map(response.data));
    }, fallbackMessage: 'Failed to create group');
  }

  Future<ServiceResult<QuestionBankGroupModel>> updateGroup({
    required int groupId,
    String? title,
    String? sharedPrompt,
    int? sharedFileId,
    String? sharedFileCaption,
    String? sharedFileAltText,
    QuestionGroupType? groupType,
    bool clearTitle = false,
    bool clearSharedPrompt = false,
    bool clearSharedFile = false,
  }) {
    return RetryHelper.execute<QuestionBankGroupModel>(() async {
      final response = await _client.dio.patch(
        '/question-bank/groups/$groupId',
        data: <String, dynamic>{
          if (clearTitle)
            'title': null
          else if (title != null)
            'title': title.trim(),
          if (clearSharedPrompt)
            'sharedPrompt': null
          else if (sharedPrompt != null)
            'sharedPrompt': sharedPrompt.trim(),
          if (clearSharedFile)
            'sharedFileId': null
          else if (sharedFileId != null)
            'sharedFileId': sharedFileId,
          if (clearSharedFile)
            'sharedFileCaption': null
          else if (sharedFileCaption != null)
            'sharedFileCaption': sharedFileCaption.trim(),
          if (clearSharedFile)
            'sharedFileAltText': null
          else if (sharedFileAltText != null)
            'sharedFileAltText': sharedFileAltText.trim(),
          if (groupType != null) 'groupType': groupType.value,
        },
      );
      return QuestionBankGroupModel.fromJson(_map(response.data));
    }, fallbackMessage: 'Failed to update group');
  }

  Future<ServiceResult<List<QuestionBankQuestionModel>>> addGroupedQuestions({
    required int groupId,
    required List<QuestionBankFormPayload> questions,
  }) {
    return RetryHelper.execute<List<QuestionBankQuestionModel>>(() async {
      final response = await _client.dio.post(
        '/question-bank/groups/$groupId/questions/batch',
        data: <String, dynamic>{
          'questions': questions
              .map((question) => question.toCreateJson())
              .toList(),
        },
      );
      final data = _map(response.data);
      return _list(data['questions'])
          .whereType<Map<String, dynamic>>()
          .map(QuestionBankQuestionModel.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to add grouped questions');
  }

  Future<ServiceResult<List<QuestionBankQuestionModel>>> linkGroupQuestions({
    required int groupId,
    required List<int> questionIds,
  }) {
    return RetryHelper.execute<List<QuestionBankQuestionModel>>(() async {
      final response = await _client.dio.post(
        '/question-bank/groups/$groupId/questions/link',
        data: <String, dynamic>{'questionIds': questionIds},
      );
      return _list(_map(response.data)['questions'])
          .whereType<Map<String, dynamic>>()
          .map(QuestionBankQuestionModel.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to add existing questions');
  }

  Future<ServiceResult<void>> unlinkGroupQuestion({
    required int groupId,
    required int questionId,
  }) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.delete(
        '/question-bank/groups/$groupId/questions/$questionId',
      );
    }, fallbackMessage: 'Failed to remove question from group');
  }

  Future<ServiceResult<void>> reorderGroupQuestions({
    required int groupId,
    required List<Map<String, int>> items,
  }) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.patch(
        '/question-bank/groups/$groupId/questions/reorder',
        data: <String, dynamic>{'items': items},
      );
    }, fallbackMessage: 'Failed to reorder group questions');
  }

  Future<ServiceResult<void>> deleteGroup(int groupId) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.delete('/question-bank/groups/$groupId');
    }, fallbackMessage: 'Failed to delete group');
  }

  Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  List<dynamic> _list(dynamic value) {
    if (value is List) return value;
    if (value is Map<String, dynamic> && value['data'] is List) {
      return value['data'] as List;
    }
    return const <dynamic>[];
  }

  int _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
