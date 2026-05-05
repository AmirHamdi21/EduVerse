import 'dart:io';

import 'package:dio/dio.dart';

import '../../common/retry_helper.dart';
import '../../common/service_error.dart';
import '../../models/core/paginated_response.dart';
import '../../models/instructor/question_bank_exam_models.dart';
import 'core_api_client.dart';

class QuestionBankExamService {
  QuestionBankExamService({required CoreApiClient coreApiClient})
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
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(CourseChapterModel.fromJson)
          .toList(growable: false);
    }, fallbackMessage: 'Failed to load chapters');
  }

  Future<ServiceResult<CourseChapterModel>> createChapter({
    required int courseId,
    required String name,
    required int chapterOrder,
    String? description,
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<CourseChapterModel>(() async {
      final response = await _client.dio.post(
        '/courses/$courseId/chapters',
        data: <String, dynamic>{
          'name': name.trim(),
          'chapterOrder': chapterOrder,
        },
        cancelToken: cancelToken,
      );
      return CourseChapterModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to create chapter');
  }

  Future<ServiceResult<CourseChapterModel>> updateChapter({
    required int courseId,
    required int chapterId,
    String? name,
    int? chapterOrder,
    String? description,
    int? isActive,
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<CourseChapterModel>(() async {
      final data = <String, dynamic>{};
      _putTrimmed(data, 'name', name);
      if (chapterOrder != null) data['chapterOrder'] = chapterOrder;
      if (isActive != null) data['isActive'] = isActive;
      final response = await _client.dio.patch(
        '/courses/$courseId/chapters/$chapterId',
        data: data,
        cancelToken: cancelToken,
      );
      return CourseChapterModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to update chapter');
  }

  Future<ServiceResult<void>> deleteChapter({
    required int courseId,
    required int chapterId,
    CancelToken? cancelToken,
  }) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.delete(
        '/courses/$courseId/chapters/$chapterId',
        cancelToken: cancelToken,
      );
    }, fallbackMessage: 'Failed to delete chapter');
  }

  Future<ServiceResult<PaginatedResponse<QuestionBankQuestionModel>>>
  getQuestions({
    int? courseId,
    int? chapterId,
    int? groupId,
    QuestionBankQuestionType? questionType,
    QuestionBankDifficulty? difficulty,
    QuestionBankBloomLevel? bloomLevel,
    QuestionBankStatus? status,
    String? search,
    bool? hasAttachments,
    int page = 1,
    int limit = 20,
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<PaginatedResponse<QuestionBankQuestionModel>>(
      () async {
        final safePage = _clampPage(page);
        final safeLimit = _clampLimit(limit);
        final query = <String, dynamic>{'page': safePage, 'limit': safeLimit};
        if (courseId != null) query['courseId'] = courseId;
        if (chapterId != null) query['chapterId'] = chapterId;
        if (groupId != null) query['groupId'] = groupId;
        if (questionType != null) query['questionType'] = questionType.toJson();
        if (difficulty != null) query['difficulty'] = difficulty.toJson();
        if (bloomLevel != null) query['bloomLevel'] = bloomLevel.toJson();
        if (status != null) query['status'] = status.toJson();
        if (search != null && search.trim().isNotEmpty) {
          query['search'] = search.trim();
        }
        if (hasAttachments != null) {
          query['hasAttachments'] = hasAttachments;
        }

        final response = await _client.dio.get(
          '/question-bank/questions',
          queryParameters: query,
          cancelToken: cancelToken,
        );
        final payload = _extractMap(response.data);
        final data = _extractList(payload['data'])
            .whereType<Map<String, dynamic>>()
            .map(QuestionBankQuestionModel.fromJson)
            .toList(growable: false);
        final total = _toInt(payload['total'], fallback: data.length);
        return PaginatedResponse<QuestionBankQuestionModel>(
          data: data,
          total: total,
          page: safePage,
          limit: safeLimit,
          totalPages: total == 0 ? 0 : ((total + safeLimit - 1) ~/ safeLimit),
        );
      },
      fallbackMessage: 'Failed to load question bank',
    );
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
      return QuestionBankQuestionModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to load question');
  }

  Future<ServiceResult<QuestionBankQuestionModel>> createQuestion(
    Map<String, dynamic> data, {
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<QuestionBankQuestionModel>(() async {
      final response = await _client.dio.post(
        '/question-bank/questions',
        data: data,
        cancelToken: cancelToken,
      );
      return QuestionBankQuestionModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to create question');
  }

  Future<ServiceResult<List<QuestionBankQuestionModel>>> createQuestionsBatch({
    required int courseId,
    int? defaultChapterId,
    required List<Map<String, dynamic>> questions,
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<List<QuestionBankQuestionModel>>(() async {
      final response = await _client.dio.post(
        '/question-bank/questions/batch',
        data: buildQuestionsBatchPayload(
          courseId: courseId,
          defaultChapterId: defaultChapterId,
          questions: questions,
        ),
        cancelToken: cancelToken,
      );
      return _extractNamedList(response.data, 'questions')
          .whereType<Map<String, dynamic>>()
          .map(QuestionBankQuestionModel.fromJson)
          .toList(growable: false);
    }, fallbackMessage: 'Failed to create questions');
  }

  Future<ServiceResult<QuestionBankQuestionModel>> updateQuestion(
    int questionId,
    Map<String, dynamic> data, {
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<QuestionBankQuestionModel>(() async {
      final response = await _client.dio.patch(
        '/question-bank/questions/$questionId',
        data: data,
        cancelToken: cancelToken,
      );
      return QuestionBankQuestionModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to update question');
  }

  Future<ServiceResult<QuestionBankAttachmentModel>> addQuestionAttachment({
    required int questionId,
    required int fileId,
    required String attachmentType,
    String? caption,
    String? altText,
    bool isPrimary = false,
    int? displayOrder,
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<QuestionBankAttachmentModel>(() async {
      final response = await _client.dio.post(
        '/question-bank/questions/$questionId/attachments',
        data: buildAttachmentPayload(
          fileId: fileId,
          attachmentType: attachmentType,
          caption: caption,
          altText: altText,
          isPrimary: isPrimary,
          displayOrder: displayOrder,
        ),
        cancelToken: cancelToken,
      );
      return QuestionBankAttachmentModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to add attachment');
  }

  Future<ServiceResult<QuestionBankAttachmentModel>>
  uploadQuestionAttachmentImage({
    required int questionId,
    required File image,
    String? caption,
    String? altText,
    bool isPrimary = false,
    int? displayOrder,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<QuestionBankAttachmentModel>(() async {
      final formData = FormData.fromMap(<String, dynamic>{
        'image': await MultipartFile.fromFile(
          image.path,
          filename: _fileName(image),
        ),
        if (caption != null && caption.trim().isNotEmpty)
          'caption': caption.trim(),
        if (altText != null && altText.trim().isNotEmpty)
          'altText': altText.trim(),
        if (isPrimary) 'isPrimary': true,
        if (displayOrder != null) 'displayOrder': displayOrder,
      });
      final response = await _client.dio.post(
        '/question-bank/questions/$questionId/attachments/upload-image',
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
      return QuestionBankAttachmentModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to upload attachment image');
  }

  Future<ServiceResult<QuestionBankAttachmentModel>> updateQuestionAttachment({
    required int questionId,
    required int attachmentId,
    Object? caption = _absent,
    Object? altText = _absent,
    bool? isPrimary,
    int? displayOrder,
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<QuestionBankAttachmentModel>(() async {
      final data = <String, dynamic>{};
      _putNullableTrimmed(data, 'caption', caption);
      _putNullableTrimmed(data, 'altText', altText);
      if (isPrimary != null) data['isPrimary'] = isPrimary;
      if (displayOrder != null) data['displayOrder'] = displayOrder;
      final response = await _client.dio.patch(
        '/question-bank/questions/$questionId/attachments/$attachmentId',
        data: data,
        cancelToken: cancelToken,
      );
      return QuestionBankAttachmentModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to update attachment');
  }

  Future<ServiceResult<void>> reorderQuestionAttachments({
    required int questionId,
    required List<int> attachmentIds,
    CancelToken? cancelToken,
  }) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.patch(
        '/question-bank/questions/$questionId/attachments/reorder',
        data: <String, dynamic>{
          'items': attachmentIds
              .asMap()
              .entries
              .map(
                (entry) => <String, dynamic>{
                  'attachmentId': entry.value,
                  'displayOrder': entry.key,
                },
              )
              .toList(growable: false),
        },
        cancelToken: cancelToken,
      );
    }, fallbackMessage: 'Failed to reorder attachments');
  }

  Future<ServiceResult<void>> deleteQuestionAttachment({
    required int questionId,
    required int attachmentId,
    CancelToken? cancelToken,
  }) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.delete(
        '/question-bank/questions/$questionId/attachments/$attachmentId',
        cancelToken: cancelToken,
      );
    }, fallbackMessage: 'Failed to delete attachment');
  }

  Future<ServiceResult<void>> archiveQuestion(
    int questionId, {
    String? comment,
    CancelToken? cancelToken,
  }) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.post(
        '/question-bank/questions/$questionId/archive',
        data: <String, dynamic>{
          if (comment != null && comment.trim().isNotEmpty)
            'comment': comment.trim(),
        },
        cancelToken: cancelToken,
      );
    }, fallbackMessage: 'Failed to archive question');
  }

  Future<ServiceResult<void>> softDeleteQuestionByDelete(
    int questionId, {
    CancelToken? cancelToken,
  }) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.delete(
        '/question-bank/questions/$questionId',
        cancelToken: cancelToken,
      );
    }, fallbackMessage: 'Failed to delete question');
  }

  Future<ServiceResult<void>> approveQuestion(
    int questionId, {
    String? comment,
    CancelToken? cancelToken,
  }) {
    return _reviewAction(
      questionId,
      'approve',
      comment: comment,
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<void>> rejectQuestion(
    int questionId, {
    String? comment,
    CancelToken? cancelToken,
  }) {
    return _reviewAction(
      questionId,
      'reject',
      comment: comment,
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<void>> submitQuestionForReview(
    int questionId, {
    String? comment,
    CancelToken? cancelToken,
  }) {
    return _reviewAction(
      questionId,
      'submit-for-review',
      comment: comment,
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<void>> restoreQuestion(
    int questionId, {
    String? comment,
    CancelToken? cancelToken,
  }) {
    return _reviewAction(
      questionId,
      'restore',
      comment: comment,
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<Map<String, dynamic>>> uploadQuestionImage(
    File image, {
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<Map<String, dynamic>>(() async {
      final response = await _client.dio.post(
        '/question-bank/questions/upload-image',
        data: FormData.fromMap(<String, dynamic>{
          'image': await MultipartFile.fromFile(
            image.path,
            filename: _fileName(image),
          ),
        }),
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
      return _extractMap(response.data);
    }, fallbackMessage: 'Failed to upload question image');
  }

  Future<ServiceResult<PaginatedResponse<QuestionBankGroupModel>>> getGroups({
    int? courseId,
    int? chapterId,
    int page = 1,
    int limit = 20,
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<PaginatedResponse<QuestionBankGroupModel>>(
      () async {
        final safePage = _clampPage(page);
        final safeLimit = _clampLimit(limit);
        final query = <String, dynamic>{'page': safePage, 'limit': safeLimit};
        if (courseId != null) query['courseId'] = courseId;
        if (chapterId != null) query['chapterId'] = chapterId;

        final response = await _client.dio.get(
          '/question-bank/groups',
          queryParameters: query,
          cancelToken: cancelToken,
        );
        final payload = _extractMap(response.data);
        final data = _extractList(payload['data'])
            .whereType<Map<String, dynamic>>()
            .map(QuestionBankGroupModel.fromJson)
            .toList(growable: false);
        final total = _toInt(payload['total'], fallback: data.length);
        return PaginatedResponse<QuestionBankGroupModel>(
          data: data,
          total: total,
          page: safePage,
          limit: safeLimit,
          totalPages: total == 0 ? 0 : ((total + safeLimit - 1) ~/ safeLimit),
        );
      },
      fallbackMessage: 'Failed to load question groups',
    );
  }

  Future<ServiceResult<QuestionBankGroupModel>> createGroup(
    Map<String, dynamic> data, {
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<QuestionBankGroupModel>(() async {
      final response = await _client.dio.post(
        '/question-bank/groups',
        data: data,
        cancelToken: cancelToken,
      );
      return QuestionBankGroupModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to create question group');
  }

  Future<ServiceResult<QuestionBankGroupModel>> getGroup(
    int groupId, {
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<QuestionBankGroupModel>(() async {
      final response = await _client.dio.get(
        '/question-bank/groups/$groupId',
        cancelToken: cancelToken,
      );
      return QuestionBankGroupModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to load question group');
  }

  Future<ServiceResult<QuestionBankGroupModel>> updateGroup(
    int groupId,
    Map<String, dynamic> data, {
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<QuestionBankGroupModel>(() async {
      final response = await _client.dio.patch(
        '/question-bank/groups/$groupId',
        data: data,
        cancelToken: cancelToken,
      );
      return QuestionBankGroupModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to update question group');
  }

  Future<ServiceResult<void>> deleteGroup(
    int groupId, {
    CancelToken? cancelToken,
  }) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.delete(
        '/question-bank/groups/$groupId',
        cancelToken: cancelToken,
      );
    }, fallbackMessage: 'Failed to delete question group');
  }

  Future<ServiceResult<List<QuestionBankQuestionModel>>>
  createGroupQuestionsBatch({
    required int groupId,
    required List<Map<String, dynamic>> questions,
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<List<QuestionBankQuestionModel>>(() async {
      final response = await _client.dio.post(
        '/question-bank/groups/$groupId/questions/batch',
        data: <String, dynamic>{'questions': questions},
        cancelToken: cancelToken,
      );
      return _extractNamedList(response.data, 'questions')
          .whereType<Map<String, dynamic>>()
          .map(QuestionBankQuestionModel.fromJson)
          .toList(growable: false);
    }, fallbackMessage: 'Failed to create grouped questions');
  }

  Future<ServiceResult<void>> reorderGroupQuestions({
    required int groupId,
    required List<int> questionIds,
    CancelToken? cancelToken,
  }) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.patch(
        '/question-bank/groups/$groupId/questions/reorder',
        data: <String, dynamic>{
          'items': questionIds
              .asMap()
              .entries
              .map(
                (entry) => <String, dynamic>{
                  'questionId': entry.value,
                  'itemOrder': entry.key,
                },
              )
              .toList(growable: false),
        },
        cancelToken: cancelToken,
      );
    }, fallbackMessage: 'Failed to reorder grouped questions');
  }

  Future<ServiceResult<PaginatedResponse<ExamResponseModel>>> getExams({
    int? courseId,
    ExamStatus? status,
    int page = 1,
    int limit = 20,
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<PaginatedResponse<ExamResponseModel>>(() async {
      final safePage = _clampPage(page);
      final safeLimit = _clampLimit(limit);
      final query = <String, dynamic>{'page': safePage, 'limit': safeLimit};
      if (courseId != null) query['courseId'] = courseId;
      if (status != null) query['status'] = status.toJson();
      final response = await _client.dio.get(
        '/exams',
        queryParameters: query,
        cancelToken: cancelToken,
      );
      return _parsePaginated(
        response.data,
        ExamResponseModel.fromJson,
        safePage,
        safeLimit,
      );
    }, fallbackMessage: 'Failed to load exams');
  }

  Future<ServiceResult<PaginatedResponse<ExamDraftModel>>> getDrafts({
    int? courseId,
    ExamDraftStatus? status,
    int page = 1,
    int limit = 20,
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<PaginatedResponse<ExamDraftModel>>(() async {
      final safePage = _clampPage(page);
      final safeLimit = _clampLimit(limit);
      final query = <String, dynamic>{'page': safePage, 'limit': safeLimit};
      if (courseId != null) query['courseId'] = courseId;
      if (status != null) query['status'] = status.toJson();
      final response = await _client.dio.get(
        '/exams/drafts',
        queryParameters: query,
        cancelToken: cancelToken,
      );
      return _parsePaginated(
        response.data,
        ExamDraftModel.fromJson,
        safePage,
        safeLimit,
      );
    }, fallbackMessage: 'Failed to load exam drafts');
  }

  Future<ServiceResult<ExamDraftModel>> getDraft(
    int draftId, {
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<ExamDraftModel>(() async {
      final response = await _client.dio.get(
        '/exams/drafts/$draftId',
        cancelToken: cancelToken,
      );
      return ExamDraftModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to load draft');
  }

  Future<ServiceResult<ExamDraftModel>> generatePreview(
    Map<String, dynamic> data, {
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<ExamDraftModel>(() async {
      final response = await _client.dio.post(
        '/exams/generate-preview',
        data: data,
        cancelToken: cancelToken,
      );
      return ExamDraftModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to generate exam draft');
  }

  Future<ServiceResult<ExamDraftItemModel>> addDraftItem({
    required int draftId,
    required int questionId,
    int? draftSectionId,
    double? weightUnits,
    double? marks,
    String? overrideReason,
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<ExamDraftItemModel>(() async {
      final response = await _client.dio.post(
        '/exams/drafts/$draftId/items',
        data: buildAddDraftItemPayload(
          questionId: questionId,
          draftSectionId: draftSectionId,
          weightUnits: weightUnits,
          marks: marks,
          overrideReason: overrideReason,
        ),
        cancelToken: cancelToken,
      );
      return ExamDraftItemModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to add draft item');
  }

  Future<ServiceResult<ExamDraftSectionModel>> addDraftSection({
    required int draftId,
    required String title,
    String? instructions,
    double? totalMarks,
    ExamSectionAnswerPolicy answerPolicy = ExamSectionAnswerPolicy.answerAll,
    int? requiredAnswerCount,
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<ExamDraftSectionModel>(() async {
      final response = await _client.dio.post(
        '/exams/drafts/$draftId/sections',
        data: buildDraftSectionPayload(
          title: title,
          instructions: instructions,
          totalMarks: totalMarks,
          answerPolicy: answerPolicy,
          requiredAnswerCount: requiredAnswerCount,
        ),
        cancelToken: cancelToken,
      );
      return ExamDraftSectionModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to add draft section');
  }

  Future<ServiceResult<ExamDraftSectionModel>> updateDraftSection({
    required int draftId,
    required int sectionId,
    String? title,
    Object? instructions = _absent,
    Object? totalMarks = _absent,
    ExamSectionAnswerPolicy? answerPolicy,
    Object? requiredAnswerCount = _absent,
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<ExamDraftSectionModel>(() async {
      final data = <String, dynamic>{};
      _putTrimmed(data, 'title', title);
      _putNullableTrimmed(data, 'instructions', instructions);
      if (totalMarks != _absent) data['totalMarks'] = totalMarks;
      if (answerPolicy != null) data['answerPolicy'] = answerPolicy.toJson();
      if (requiredAnswerCount != _absent) {
        data['requiredAnswerCount'] = requiredAnswerCount;
      }
      final response = await _client.dio.patch(
        '/exams/drafts/$draftId/sections/$sectionId',
        data: data,
        cancelToken: cancelToken,
      );
      return ExamDraftSectionModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to update draft section');
  }

  Future<ServiceResult<void>> reorderDraftSections({
    required int draftId,
    required List<int> sectionIds,
    CancelToken? cancelToken,
  }) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.patch(
        '/exams/drafts/$draftId/sections/reorder',
        data: <String, dynamic>{
          'items': sectionIds
              .asMap()
              .entries
              .map(
                (entry) => <String, dynamic>{
                  'sectionId': entry.value,
                  'sectionOrder': entry.key,
                },
              )
              .toList(growable: false),
        },
        cancelToken: cancelToken,
      );
    }, fallbackMessage: 'Failed to reorder draft sections');
  }

  Future<ServiceResult<void>> deleteDraftSection({
    required int draftId,
    required int sectionId,
    CancelToken? cancelToken,
  }) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.delete(
        '/exams/drafts/$draftId/sections/$sectionId',
        cancelToken: cancelToken,
      );
    }, fallbackMessage: 'Failed to delete draft section');
  }

  Future<ServiceResult<ExamDraftItemModel>> updateDraftItem({
    required int draftId,
    required int itemId,
    int? replacementQuestionId,
    int? draftSectionId,
    bool clearDraftSection = false,
    double? weight,
    double? weightUnits,
    double? marks,
    int? itemOrder,
    String? overrideReason,
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<ExamDraftItemModel>(() async {
      final data = <String, dynamic>{
        if (replacementQuestionId != null)
          'replacementQuestionId': replacementQuestionId,
        if (clearDraftSection) 'draftSectionId': null,
        if (!clearDraftSection && draftSectionId != null)
          'draftSectionId': draftSectionId,
        if (weight != null) 'weight': weight,
        if (weightUnits != null) 'weightUnits': weightUnits,
        if (marks != null) 'marks': marks,
        if (itemOrder != null) 'itemOrder': itemOrder,
        if (overrideReason != null && overrideReason.trim().isNotEmpty)
          'overrideReason': overrideReason.trim(),
      };
      final response = await _client.dio.patch(
        '/exams/drafts/$draftId/items/$itemId',
        data: data,
        cancelToken: cancelToken,
      );
      return ExamDraftItemModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to update draft item');
  }

  Future<ServiceResult<void>> reorderDraftItems({
    required int draftId,
    required List<int> itemIds,
    CancelToken? cancelToken,
  }) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.patch(
        '/exams/drafts/$draftId/items/reorder',
        data: <String, dynamic>{
          'items': itemIds
              .asMap()
              .entries
              .map(
                (entry) => <String, dynamic>{
                  'itemId': entry.value,
                  'itemOrder': entry.key,
                },
              )
              .toList(growable: false),
        },
        cancelToken: cancelToken,
      );
    }, fallbackMessage: 'Failed to reorder draft items');
  }

  Future<ServiceResult<void>> removeDraftItem(
    int draftId,
    int itemId, {
    CancelToken? cancelToken,
  }) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.delete(
        '/exams/drafts/$draftId/items/$itemId',
        cancelToken: cancelToken,
      );
    }, fallbackMessage: 'Failed to remove draft item');
  }

  Future<ServiceResult<ExamResponseModel>> saveDraft(
    int draftId, {
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<ExamResponseModel>(() async {
      final response = await _client.dio.post(
        '/exams/drafts/$draftId/save',
        cancelToken: cancelToken,
      );
      return ExamResponseModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to save exam draft');
  }

  Future<ServiceResult<ExamResponseModel>> getExam(
    int examId, {
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<ExamResponseModel>(() async {
      final response = await _client.dio.get(
        '/exams/$examId',
        cancelToken: cancelToken,
      );
      return ExamResponseModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to load exam');
  }

  Future<ServiceResult<ExamResponseModel>> publishExam(
    int examId, {
    String? reason,
    CancelToken? cancelToken,
  }) {
    return _examLifecycleAction(
      examId,
      'publish',
      reason: reason,
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<ExamResponseModel>> unpublishExam(
    int examId, {
    String? reason,
    CancelToken? cancelToken,
  }) {
    return _examLifecycleAction(
      examId,
      'unpublish',
      reason: reason,
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<ExamResponseModel>> archiveExam(
    int examId, {
    String? reason,
    CancelToken? cancelToken,
  }) {
    return _examLifecycleAction(
      examId,
      'archive',
      reason: reason,
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<ExamExportModel>> exportWord(
    int examId, {
    bool includeAnswerKey = true,
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<ExamExportModel>(() async {
      final response = await _client.dio.post(
        '/exams/$examId/export-word',
        data: <String, dynamic>{
          'format': 'html_doc',
          'includeAnswerKey': includeAnswerKey,
        },
        cancelToken: cancelToken,
      );
      return ExamExportModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to export exam');
  }

  static Map<String, dynamic> buildQuestionPayload({
    required int courseId,
    required int chapterId,
    required QuestionBankQuestionType questionType,
    required QuestionBankDifficulty difficulty,
    required QuestionBankBloomLevel bloomLevel,
    String? questionText,
    String? expectedAnswerText,
    String? hints,
    String? explanation,
    double? defaultWeight,
    int? questionFileId,
    List<QuestionBankOptionModel>? options,
    List<QuestionBankFillBlankModel>? fillBlanks,
  }) {
    final data = <String, dynamic>{
      'courseId': courseId,
      'chapterId': chapterId,
      'questionType': questionType.toJson(),
      'difficulty': difficulty.toJson(),
      'bloomLevel': bloomLevel.toJson(),
    };
    _putTrimmed(data, 'questionText', questionText);
    _putTrimmed(data, 'expectedAnswerText', expectedAnswerText);
    _putTrimmed(data, 'hints', hints);
    _putTrimmed(data, 'explanation', explanation);
    if (defaultWeight != null) data['defaultWeight'] = defaultWeight;
    if (questionFileId != null) data['questionFileId'] = questionFileId;
    if (options != null && options.isNotEmpty) {
      data['options'] = options.map((item) => item.toRequestJson()).toList();
    }
    if (fillBlanks != null && fillBlanks.isNotEmpty) {
      data['fillBlanks'] = fillBlanks
          .map((item) => item.toRequestJson())
          .toList();
    }
    return data;
  }

  static Map<String, dynamic> buildQuestionsBatchPayload({
    required int courseId,
    int? defaultChapterId,
    required List<Map<String, dynamic>> questions,
  }) {
    final normalizedQuestions = questions
        .map((question) {
          final data = Map<String, dynamic>.from(question);
          data['courseId'] = _toInt(data['courseId'], fallback: courseId);
          if (!data.containsKey('chapterId') && defaultChapterId != null) {
            data['chapterId'] = defaultChapterId;
          }
          return data;
        })
        .toList(growable: false);

    return <String, dynamic>{
      'courseId': courseId,
      if (defaultChapterId != null) 'defaultChapterId': defaultChapterId,
      'questions': normalizedQuestions,
    };
  }

  static Map<String, dynamic> buildQuestionUpdatePayload({
    int? chapterId,
    QuestionBankQuestionType? questionType,
    QuestionBankDifficulty? difficulty,
    QuestionBankBloomLevel? bloomLevel,
    Object? questionText = _absent,
    Object? expectedAnswerText = _absent,
    Object? hints = _absent,
    Object? explanation = _absent,
    Object? questionFileId = _absent,
    double? defaultWeight,
    List<QuestionBankOptionModel>? options,
    List<QuestionBankFillBlankModel>? fillBlanks,
  }) {
    final data = <String, dynamic>{};
    if (chapterId != null) data['chapterId'] = chapterId;
    if (questionType != null) data['questionType'] = questionType.toJson();
    if (difficulty != null) data['difficulty'] = difficulty.toJson();
    if (bloomLevel != null) data['bloomLevel'] = bloomLevel.toJson();
    _putNullableTrimmed(data, 'questionText', questionText);
    _putNullableTrimmed(data, 'expectedAnswerText', expectedAnswerText);
    _putNullableTrimmed(data, 'hints', hints);
    _putNullableTrimmed(data, 'explanation', explanation);
    if (questionFileId != _absent) data['questionFileId'] = questionFileId;
    if (defaultWeight != null) data['defaultWeight'] = defaultWeight;
    if (options != null) {
      data['options'] = options.map((item) => item.toRequestJson()).toList();
    }
    if (fillBlanks != null) {
      data['fillBlanks'] = fillBlanks
          .map((item) => item.toRequestJson())
          .toList();
    }
    return data;
  }

  static Map<String, dynamic> buildAttachmentPayload({
    required int fileId,
    required String attachmentType,
    String? caption,
    String? altText,
    bool isPrimary = false,
    int? displayOrder,
  }) {
    final data = <String, dynamic>{
      'fileId': fileId,
      'attachmentType': attachmentType,
    };
    _putTrimmed(data, 'caption', caption);
    _putTrimmed(data, 'altText', altText);
    if (isPrimary) data['isPrimary'] = true;
    if (displayOrder != null) data['displayOrder'] = displayOrder;
    return data;
  }

  static Map<String, dynamic> buildGenerateExamPayload({
    required int courseId,
    required String title,
    String? instructions,
    double? totalMarks,
    ExamMarkDistributionMode markDistributionMode =
        ExamMarkDistributionMode.manual,
    ExamRoundingPolicy roundingPolicy = ExamRoundingPolicy.nearest05,
    List<ExamGenerationRuleModel> rules = const <ExamGenerationRuleModel>[],
    List<ExamGenerationSectionModel> sections =
        const <ExamGenerationSectionModel>[],
    String? seed,
  }) {
    final data = <String, dynamic>{
      'courseId': courseId,
      'title': title.trim(),
      'markDistributionMode': markDistributionMode.toJson(),
      'roundingPolicy': roundingPolicy.toJson(),
      'groupSelectionMode': 'independent',
    };
    _putTrimmed(data, 'instructions', instructions);
    if (totalMarks != null) data['totalMarks'] = totalMarks;
    if (rules.isNotEmpty) {
      data['rules'] = rules.map((item) => item.toJson()).toList();
    }
    if (sections.isNotEmpty) {
      data['sections'] = sections.map((item) => item.toJson()).toList();
    }
    _putTrimmed(data, 'seed', seed);
    return data;
  }

  static Map<String, dynamic> buildDraftSectionPayload({
    required String title,
    String? instructions,
    double? totalMarks,
    ExamSectionAnswerPolicy answerPolicy = ExamSectionAnswerPolicy.answerAll,
    int? requiredAnswerCount,
  }) {
    final data = <String, dynamic>{
      'title': title.trim(),
      'answerPolicy': answerPolicy.toJson(),
    };
    _putTrimmed(data, 'instructions', instructions);
    if (totalMarks != null) data['totalMarks'] = totalMarks;
    if (requiredAnswerCount != null) {
      data['requiredAnswerCount'] = requiredAnswerCount;
    }
    return data;
  }

  static Map<String, dynamic> buildAddDraftItemPayload({
    required int questionId,
    int? draftSectionId,
    double? weightUnits,
    double? marks,
    String? overrideReason,
  }) {
    final data = <String, dynamic>{'questionId': questionId};
    if (draftSectionId != null) data['draftSectionId'] = draftSectionId;
    if (weightUnits != null) data['weightUnits'] = weightUnits;
    if (marks != null) data['marks'] = marks;
    _putTrimmed(data, 'overrideReason', overrideReason);
    return data;
  }

  Future<ServiceResult<void>> _reviewAction(
    int questionId,
    String action, {
    String? comment,
    CancelToken? cancelToken,
  }) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.post(
        '/question-bank/questions/$questionId/$action',
        data: <String, dynamic>{
          if (comment != null && comment.trim().isNotEmpty)
            'comment': comment.trim(),
        },
        cancelToken: cancelToken,
      );
    }, fallbackMessage: 'Failed to update question status');
  }

  Future<ServiceResult<ExamResponseModel>> _examLifecycleAction(
    int examId,
    String action, {
    String? reason,
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<ExamResponseModel>(() async {
      final response = await _client.dio.post(
        '/exams/$examId/$action',
        data: <String, dynamic>{
          if (reason != null && reason.trim().isNotEmpty)
            'reason': reason.trim(),
        },
        cancelToken: cancelToken,
      );
      return ExamResponseModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to update exam');
  }

  static PaginatedResponse<T> _parsePaginated<T>(
    dynamic payload,
    T Function(Map<String, dynamic>) fromJson,
    int fallbackPage,
    int fallbackLimit,
  ) {
    final map = _extractMap(payload);
    if (map['meta'] is Map<String, dynamic>) {
      return PaginatedResponse<T>.fromJson(map, fromJson);
    }
    final data = _extractList(
      map['data'],
    ).whereType<Map<String, dynamic>>().map(fromJson).toList(growable: false);
    final total = _toInt(map['total'], fallback: data.length);
    final page = _toInt(map['page'], fallback: fallbackPage);
    final limit = _toInt(map['limit'], fallback: fallbackLimit);
    return PaginatedResponse<T>(
      data: data,
      total: total,
      page: page,
      limit: limit,
      totalPages: total == 0 ? 0 : ((total + limit - 1) ~/ limit),
    );
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
    if (payload is List) return payload;
    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is List) return data;
    }
    return const <dynamic>[];
  }

  static List<dynamic> _extractNamedList(dynamic payload, String key) {
    if (payload is List) return payload;
    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is List) return data;
      if (data is Map<String, dynamic> && data[key] is List) {
        return data[key] as List<dynamic>;
      }
      if (payload[key] is List) return payload[key] as List<dynamic>;
    }
    return const <dynamic>[];
  }

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static int _clampPage(int page) => page < 1 ? 1 : page;

  static int _clampLimit(int limit) {
    if (limit < 1) return 1;
    if (limit > 100) return 100;
    return limit;
  }

  static void _putTrimmed(
    Map<String, dynamic> data,
    String key,
    String? value,
  ) {
    if (value != null && value.trim().isNotEmpty) {
      data[key] = value.trim();
    }
  }

  static void _putNullableTrimmed(
    Map<String, dynamic> data,
    String key,
    Object? value,
  ) {
    if (value == _absent) return;
    if (value == null) {
      data[key] = null;
      return;
    }
    final text = value.toString().trim();
    data[key] = text.isEmpty ? null : text;
  }

  static String _fileName(File file) {
    if (file.uri.pathSegments.isNotEmpty) {
      return file.uri.pathSegments.last;
    }
    return 'question-image';
  }
}

const Object _absent = Object();
