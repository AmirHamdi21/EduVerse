import 'dart:io';

import 'package:dio/dio.dart';

import '../../common/service_error.dart';
import '../../models/core/paginated_response.dart';
import '../../models/instructor/question_bank_exam_models.dart';
import '../../models/question_bank/course_chapter_model.dart';
import '../../models/question_bank/question_bank_query.dart';
import '../../models/question_bank/question_form_data.dart';
import '../../models/question_bank/question_image_upload_response.dart';
import 'core_api_client.dart';
import 'question_bank_exam_service.dart';

export 'question_bank_exam_service.dart' show QuestionBankExamService;

class QuestionBankService {
  QuestionBankService({required CoreApiClient coreApiClient})
    : _delegate = QuestionBankExamService(coreApiClient: coreApiClient);

  final QuestionBankExamService _delegate;

  Future<ServiceResult<List<CourseChapterModel>>> getChapters(
    int courseId, {
    CancelToken? cancelToken,
  }) {
    return _delegate.getChapters(courseId, cancelToken: cancelToken);
  }

  Future<ServiceResult<CourseChapterModel>> createChapter(
    int courseId,
    CreateChapterRequest data, {
    CancelToken? cancelToken,
  }) {
    final json = data.toJson();
    return _delegate.createChapter(
      courseId: courseId,
      name: json['name'].toString(),
      chapterOrder: json['chapterOrder'] as int,
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<CourseChapterModel>> createChapterFromFields({
    required int courseId,
    required String name,
    required int chapterOrder,
    CancelToken? cancelToken,
  }) {
    return createChapter(
      courseId,
      CreateChapterRequest(name: name, chapterOrder: chapterOrder),
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<CourseChapterModel>> updateChapter(
    int courseId,
    int chapterId,
    UpdateChapterRequest data, {
    CancelToken? cancelToken,
  }) {
    final json = data.toJson();
    return _delegate.updateChapter(
      courseId: courseId,
      chapterId: chapterId,
      name: json['name']?.toString(),
      chapterOrder: json['chapterOrder'] as int?,
      isActive: json['isActive'] as int?,
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<CourseChapterModel>> updateChapterFromFields({
    required int courseId,
    required int chapterId,
    String? name,
    int? chapterOrder,
    int? isActive,
    CancelToken? cancelToken,
  }) {
    return updateChapter(
      courseId,
      chapterId,
      UpdateChapterRequest(
        name: name,
        chapterOrder: chapterOrder,
        isActive: isActive,
      ),
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<void>> deleteChapter(
    int courseId,
    int chapterId, {
    CancelToken? cancelToken,
  }) {
    return _delegate.deleteChapter(
      courseId: courseId,
      chapterId: chapterId,
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<PaginatedResponse<QuestionBankQuestionModel>>>
  listQuestions(QuestionBankQuery query, {CancelToken? cancelToken}) {
    return _delegate.getQuestions(
      courseId: query.courseId,
      chapterId: query.chapterId,
      groupId: query.groupId,
      questionType: query.questionType,
      difficulty: query.difficulty,
      bloomLevel: query.bloomLevel,
      status: query.status,
      search: query.search,
      hasAttachments: query.hasAttachments,
      page: query.page,
      limit: query.limit,
      cancelToken: cancelToken,
    );
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
    return _delegate.getQuestions(
      courseId: courseId,
      chapterId: chapterId,
      groupId: groupId,
      questionType: questionType,
      difficulty: difficulty,
      bloomLevel: bloomLevel,
      status: status,
      search: search,
      hasAttachments: hasAttachments,
      page: page,
      limit: limit,
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<QuestionBankQuestionModel>> getQuestion(
    int questionId, {
    CancelToken? cancelToken,
  }) {
    return _delegate.getQuestion(questionId, cancelToken: cancelToken);
  }

  Future<ServiceResult<QuestionBankQuestionModel>> createQuestion(
    Object data, {
    CancelToken? cancelToken,
  }) {
    return _delegate.createQuestion(
      questionFormDataToJson(data),
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<List<QuestionBankQuestionModel>>> bulkCreateQuestions({
    required int courseId,
    int? defaultChapterId,
    required List<Object> questions,
    CancelToken? cancelToken,
  }) {
    return _delegate.createQuestionsBatch(
      courseId: courseId,
      defaultChapterId: defaultChapterId,
      questions: questions.map(questionFormDataToJson).toList(growable: false),
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<List<QuestionBankQuestionModel>>> createQuestionsBatch({
    required int courseId,
    int? defaultChapterId,
    required List<Object> questions,
    CancelToken? cancelToken,
  }) {
    return bulkCreateQuestions(
      courseId: courseId,
      defaultChapterId: defaultChapterId,
      questions: questions,
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<QuestionBankQuestionModel>> updateQuestion(
    int questionId,
    Object data, {
    CancelToken? cancelToken,
  }) {
    return _delegate.updateQuestion(
      questionId,
      questionFormDataToJson(data),
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<QuestionBankAttachmentModel>> addAttachment(
    int questionId,
    QuestionAttachmentCreateRequest data, {
    CancelToken? cancelToken,
  }) {
    final json = data.toJson();
    return _delegate.addQuestionAttachment(
      questionId: questionId,
      fileId: json['fileId'] as int,
      attachmentType: json['attachmentType'].toString(),
      caption: json['caption']?.toString(),
      altText: json['altText']?.toString(),
      isPrimary: json['isPrimary'] == true,
      displayOrder: json['displayOrder'] as int?,
      cancelToken: cancelToken,
    );
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
    return _delegate.addQuestionAttachment(
      questionId: questionId,
      fileId: fileId,
      attachmentType: attachmentType,
      caption: caption,
      altText: altText,
      isPrimary: isPrimary,
      displayOrder: displayOrder,
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<QuestionBankAttachmentModel>> uploadAttachmentImage(
    int questionId,
    File image,
    QuestionAttachmentUploadMetadata metadata, {
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) {
    return _delegate.uploadQuestionAttachmentImage(
      questionId: questionId,
      image: image,
      caption: metadata.caption,
      altText: metadata.altText,
      isPrimary: metadata.isPrimary,
      displayOrder: metadata.displayOrder,
      onSendProgress: onSendProgress,
      cancelToken: cancelToken,
    );
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
    return _delegate.uploadQuestionAttachmentImage(
      questionId: questionId,
      image: image,
      caption: caption,
      altText: altText,
      isPrimary: isPrimary,
      displayOrder: displayOrder,
      onSendProgress: onSendProgress,
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<QuestionBankAttachmentModel>> updateAttachment(
    int questionId,
    int attachmentId,
    QuestionAttachmentUpdateRequest data, {
    CancelToken? cancelToken,
  }) {
    final json = data.toJson();
    return Function.apply(
          _delegate.updateQuestionAttachment,
          const <Object?>[],
          <Symbol, dynamic>{
            #questionId: questionId,
            #attachmentId: attachmentId,
            if (json.containsKey('caption')) #caption: json['caption'],
            if (json.containsKey('altText')) #altText: json['altText'],
            if (json.containsKey('isPrimary')) #isPrimary: json['isPrimary'],
            if (json.containsKey('displayOrder'))
              #displayOrder: json['displayOrder'],
            if (cancelToken != null) #cancelToken: cancelToken,
          },
        )
        as Future<ServiceResult<QuestionBankAttachmentModel>>;
  }

  Future<ServiceResult<QuestionBankAttachmentModel>> updateQuestionAttachment({
    required int questionId,
    required int attachmentId,
    Object? caption = _noChange,
    Object? altText = _noChange,
    bool? isPrimary,
    int? displayOrder,
    CancelToken? cancelToken,
  }) {
    return Function.apply(
          _delegate.updateQuestionAttachment,
          const <Object?>[],
          <Symbol, dynamic>{
            #questionId: questionId,
            #attachmentId: attachmentId,
            if (caption != _noChange) #caption: caption,
            if (altText != _noChange) #altText: altText,
            if (isPrimary != null) #isPrimary: isPrimary,
            if (displayOrder != null) #displayOrder: displayOrder,
            if (cancelToken != null) #cancelToken: cancelToken,
          },
        )
        as Future<ServiceResult<QuestionBankAttachmentModel>>;
  }

  Future<ServiceResult<void>> deleteAttachment(
    int questionId,
    int attachmentId, {
    CancelToken? cancelToken,
  }) {
    return _delegate.deleteQuestionAttachment(
      questionId: questionId,
      attachmentId: attachmentId,
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<void>> reorderAttachments(
    int questionId,
    List<QuestionAttachmentOrderItem> items, {
    CancelToken? cancelToken,
  }) {
    return _delegate.reorderQuestionAttachments(
      questionId: questionId,
      attachmentIds: items.map((item) => item.attachmentId).toList(),
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<void>> reorderQuestionAttachments({
    required int questionId,
    required List<int> attachmentIds,
    CancelToken? cancelToken,
  }) {
    return _delegate.reorderQuestionAttachments(
      questionId: questionId,
      attachmentIds: attachmentIds,
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<void>> deleteQuestionAttachment({
    required int questionId,
    required int attachmentId,
    CancelToken? cancelToken,
  }) {
    return _delegate.deleteQuestionAttachment(
      questionId: questionId,
      attachmentId: attachmentId,
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<void>> archiveQuestion(
    int questionId, {
    String? comment,
    CancelToken? cancelToken,
  }) {
    return _delegate.archiveQuestion(
      questionId,
      comment: comment,
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<void>> softDeleteQuestionByDelete(
    int questionId, {
    CancelToken? cancelToken,
  }) {
    return _delegate.softDeleteQuestionByDelete(
      questionId,
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<void>> approveQuestion(
    int questionId, {
    String? comment,
    CancelToken? cancelToken,
  }) {
    return _delegate.approveQuestion(
      questionId,
      comment: comment,
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<void>> rejectQuestion(
    int questionId, {
    String? comment,
    CancelToken? cancelToken,
  }) {
    return _delegate.rejectQuestion(
      questionId,
      comment: comment,
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<void>> submitForReview(
    int questionId, {
    String? comment,
    CancelToken? cancelToken,
  }) {
    return _delegate.submitQuestionForReview(
      questionId,
      comment: comment,
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<void>> submitQuestionForReview(
    int questionId, {
    String? comment,
    CancelToken? cancelToken,
  }) {
    return submitForReview(
      questionId,
      comment: comment,
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<void>> restoreQuestion(
    int questionId, {
    String? comment,
    CancelToken? cancelToken,
  }) {
    return _delegate.restoreQuestion(
      questionId,
      comment: comment,
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<QuestionImageUploadResponse>> uploadQuestionImage(
    File image, {
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    final result = await _delegate.uploadQuestionImage(
      image,
      onSendProgress: onSendProgress,
      cancelToken: cancelToken,
    );
    if (result.isFailure || result.data == null) {
      return ServiceResult<QuestionImageUploadResponse>.failure(
        result.error ??
            const ServiceError(
              type: ServiceErrorType.parsing,
              message: 'Failed to upload question image',
            ),
      );
    }
    return ServiceResult<QuestionImageUploadResponse>.success(
      QuestionImageUploadResponse.fromJson(result.data!),
    );
  }

  Future<ServiceResult<PaginatedResponse<QuestionBankGroupModel>>> listGroups(
    QuestionGroupQuery query, {
    CancelToken? cancelToken,
  }) {
    return _delegate.getGroups(
      courseId: query.courseId,
      chapterId: query.chapterId,
      page: query.page,
      limit: query.limit,
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<PaginatedResponse<QuestionBankGroupModel>>> getGroups({
    int? courseId,
    int? chapterId,
    int page = 1,
    int limit = 20,
    CancelToken? cancelToken,
  }) {
    return listGroups(
      QuestionGroupQuery(
        courseId: courseId,
        chapterId: chapterId,
        page: page,
        limit: limit,
      ),
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<QuestionBankGroupModel>> createGroup(
    Object data, {
    CancelToken? cancelToken,
  }) {
    return _delegate.createGroup(
      questionGroupFormDataToJson(data),
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<QuestionBankGroupModel>> getGroup(
    int groupId, {
    CancelToken? cancelToken,
  }) {
    return _delegate.getGroup(groupId, cancelToken: cancelToken);
  }

  Future<ServiceResult<QuestionBankGroupModel>> updateGroup(
    int groupId,
    Object data, {
    CancelToken? cancelToken,
  }) {
    return _delegate.updateGroup(
      groupId,
      questionGroupFormDataToJson(data),
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<void>> deleteGroup(
    int groupId, {
    CancelToken? cancelToken,
  }) {
    return _delegate.deleteGroup(groupId, cancelToken: cancelToken);
  }

  Future<ServiceResult<List<QuestionBankQuestionModel>>> addGroupedQuestions(
    int groupId,
    List<Object> questions, {
    CancelToken? cancelToken,
  }) {
    return _delegate.createGroupQuestionsBatch(
      groupId: groupId,
      questions: questions.map(questionFormDataToJson).toList(growable: false),
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<List<QuestionBankQuestionModel>>>
  createGroupQuestionsBatch({
    required int groupId,
    required List<Object> questions,
    CancelToken? cancelToken,
  }) {
    return addGroupedQuestions(groupId, questions, cancelToken: cancelToken);
  }

  Future<ServiceResult<void>> reorderGroupQuestions(
    int groupId,
    List<QuestionGroupOrderItem> items, {
    CancelToken? cancelToken,
  }) {
    return _delegate.reorderGroupQuestions(
      groupId: groupId,
      questionIds: items.map((item) => item.questionId).toList(growable: false),
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<void>> reorderGroupQuestionIds({
    required int groupId,
    required List<int> questionIds,
    CancelToken? cancelToken,
  }) {
    return _delegate.reorderGroupQuestions(
      groupId: groupId,
      questionIds: questionIds,
      cancelToken: cancelToken,
    );
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
    return QuestionBankExamService.buildQuestionPayload(
      courseId: courseId,
      chapterId: chapterId,
      questionType: questionType,
      difficulty: difficulty,
      bloomLevel: bloomLevel,
      questionText: questionText,
      expectedAnswerText: expectedAnswerText,
      hints: hints,
      explanation: explanation,
      defaultWeight: defaultWeight,
      questionFileId: questionFileId,
      options: options,
      fillBlanks: fillBlanks,
    );
  }

  static Map<String, dynamic> buildQuestionUpdatePayload({
    int? chapterId,
    QuestionBankQuestionType? questionType,
    QuestionBankDifficulty? difficulty,
    QuestionBankBloomLevel? bloomLevel,
    Object? questionText,
    Object? expectedAnswerText,
    Object? hints,
    Object? explanation,
    Object? questionFileId,
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
    if (questionFileId != null) data['questionFileId'] = questionFileId;
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
    return QuestionBankExamService.buildAttachmentPayload(
      fileId: fileId,
      attachmentType: attachmentType,
      caption: caption,
      altText: altText,
      isPrimary: isPrimary,
      displayOrder: displayOrder,
    );
  }

  static void _putNullableTrimmed(
    Map<String, dynamic> data,
    String key,
    Object? value,
  ) {
    if (value == null) return;
    final text = value.toString().trim();
    data[key] = text.isEmpty ? null : text;
  }
}

const Object _noChange = Object();
