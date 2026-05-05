import 'package:dio/dio.dart';

import '../../common/service_error.dart';
import '../../models/core/paginated_response.dart';
import '../../models/exams/exam_generation_form_data.dart';
import '../../models/exams/exam_query.dart';
import '../../models/instructor/question_bank_exam_models.dart';
import 'core_api_client.dart';
import 'question_bank_exam_service.dart';

export 'question_bank_exam_service.dart' show QuestionBankExamService;

class ExamGeneratorService {
  ExamGeneratorService({required CoreApiClient coreApiClient})
    : _delegate = QuestionBankExamService(coreApiClient: coreApiClient);

  final QuestionBankExamService _delegate;

  Future<ServiceResult<PaginatedResponse<ExamResponseModel>>> listExams(
    ExamQuery query, {
    CancelToken? cancelToken,
  }) {
    return _delegate.getExams(
      courseId: query.courseId,
      status: query.status,
      page: query.page,
      limit: query.limit,
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<PaginatedResponse<ExamResponseModel>>> getExams({
    int? courseId,
    ExamStatus? status,
    int page = 1,
    int limit = 20,
    CancelToken? cancelToken,
  }) {
    return _delegate.getExams(
      courseId: courseId,
      status: status,
      page: page,
      limit: limit,
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<PaginatedResponse<ExamDraftModel>>> listDrafts(
    ExamDraftQuery query, {
    CancelToken? cancelToken,
  }) {
    return _delegate.getDrafts(
      courseId: query.courseId,
      status: query.status,
      page: query.page,
      limit: query.limit,
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<PaginatedResponse<ExamDraftModel>>> getDrafts({
    int? courseId,
    ExamDraftStatus? status,
    int page = 1,
    int limit = 20,
    CancelToken? cancelToken,
  }) {
    return _delegate.getDrafts(
      courseId: courseId,
      status: status,
      page: page,
      limit: limit,
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<ExamDraftModel>> getDraft(
    int draftId, {
    CancelToken? cancelToken,
  }) {
    return _delegate.getDraft(draftId, cancelToken: cancelToken);
  }

  Future<ServiceResult<ExamDraftModel>> generatePreview(
    Object data, {
    CancelToken? cancelToken,
  }) {
    return _delegate.generatePreview(
      examGenerationFormDataToJson(data),
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<ExamDraftSectionModel>> createDraftSection(
    int draftId,
    DraftSectionFormData data, {
    CancelToken? cancelToken,
  }) {
    return createDraftSectionFromFields(
      draftId: draftId,
      title: data.title,
      instructions: data.instructions,
      totalMarks: data.totalMarks,
      answerPolicy: data.answerPolicy,
      requiredAnswerCount: data.requiredAnswerCount,
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<ExamDraftSectionModel>> createDraftSectionFromFields({
    required int draftId,
    required String title,
    String? instructions,
    double? totalMarks,
    ExamSectionAnswerPolicy answerPolicy = ExamSectionAnswerPolicy.answerAll,
    int? requiredAnswerCount,
    CancelToken? cancelToken,
  }) {
    return _delegate.addDraftSection(
      draftId: draftId,
      title: title,
      instructions: instructions,
      totalMarks: totalMarks,
      answerPolicy: answerPolicy,
      requiredAnswerCount: requiredAnswerCount,
      cancelToken: cancelToken,
    );
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
    return createDraftSectionFromFields(
      draftId: draftId,
      title: title,
      instructions: instructions,
      totalMarks: totalMarks,
      answerPolicy: answerPolicy,
      requiredAnswerCount: requiredAnswerCount,
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<ExamDraftSectionModel>> updateDraftSection(
    int draftId,
    int sectionId,
    DraftSectionFormData data, {
    CancelToken? cancelToken,
  }) {
    return updateDraftSectionFromFields(
      draftId: draftId,
      sectionId: sectionId,
      title: data.title,
      instructions: data.instructions,
      totalMarks: data.totalMarks,
      answerPolicy: data.answerPolicy,
      requiredAnswerCount: data.requiredAnswerCount,
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<ExamDraftSectionModel>> updateDraftSectionFromFields({
    required int draftId,
    required int sectionId,
    String? title,
    Object? instructions = _noChange,
    Object? totalMarks = _noChange,
    ExamSectionAnswerPolicy? answerPolicy,
    Object? requiredAnswerCount = _noChange,
    CancelToken? cancelToken,
  }) {
    return Function.apply(
          _delegate.updateDraftSection,
          const <Object?>[],
          <Symbol, dynamic>{
            #draftId: draftId,
            #sectionId: sectionId,
            if (title != null) #title: title,
            if (instructions != _noChange) #instructions: instructions,
            if (totalMarks != _noChange) #totalMarks: totalMarks,
            if (answerPolicy != null) #answerPolicy: answerPolicy,
            if (requiredAnswerCount != _noChange)
              #requiredAnswerCount: requiredAnswerCount,
            if (cancelToken != null) #cancelToken: cancelToken,
          },
        )
        as Future<ServiceResult<ExamDraftSectionModel>>;
  }

  Future<ServiceResult<void>> deleteDraftSection(
    int draftId,
    int sectionId, {
    CancelToken? cancelToken,
  }) {
    return _delegate.deleteDraftSection(
      draftId: draftId,
      sectionId: sectionId,
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<void>> deleteDraftSectionByIds({
    required int draftId,
    required int sectionId,
    CancelToken? cancelToken,
  }) {
    return deleteDraftSection(draftId, sectionId, cancelToken: cancelToken);
  }

  Future<ServiceResult<void>> reorderDraftSections(
    int draftId,
    List<DraftSectionOrderItem> items, {
    CancelToken? cancelToken,
  }) {
    return _delegate.reorderDraftSections(
      draftId: draftId,
      sectionIds: items.map((item) => item.sectionId).toList(growable: false),
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<void>> reorderDraftSectionIds({
    required int draftId,
    required List<int> sectionIds,
    CancelToken? cancelToken,
  }) {
    return _delegate.reorderDraftSections(
      draftId: draftId,
      sectionIds: sectionIds,
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<ExamDraftItemModel>> addDraftItem(
    int draftId,
    DraftItemFormData data, {
    CancelToken? cancelToken,
  }) {
    return _delegate.addDraftItem(
      draftId: draftId,
      questionId: data.questionId,
      draftSectionId: data.draftSectionId,
      weightUnits: data.weightUnits,
      marks: data.marks,
      overrideReason: data.overrideReason,
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<ExamDraftItemModel>> updateDraftItem(
    int draftId,
    int itemId,
    DraftItemUpdateFormData data, {
    CancelToken? cancelToken,
  }) {
    return _delegate.updateDraftItem(
      draftId: draftId,
      itemId: itemId,
      replacementQuestionId: data.replacementQuestionId,
      draftSectionId: data.draftSectionId,
      clearDraftSection: data.clearDraftSection,
      weight: data.weight,
      weightUnits: data.weightUnits,
      marks: data.marks,
      itemOrder: data.itemOrder,
      overrideReason: data.overrideReason,
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<void>> reorderDraftItems(
    int draftId,
    List<DraftItemOrderItem> items, {
    CancelToken? cancelToken,
  }) {
    return _delegate.reorderDraftItems(
      draftId: draftId,
      itemIds: items.map((item) => item.itemId).toList(growable: false),
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<void>> reorderDraftItemIds({
    required int draftId,
    required List<int> itemIds,
    CancelToken? cancelToken,
  }) {
    return _delegate.reorderDraftItems(
      draftId: draftId,
      itemIds: itemIds,
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<void>> removeDraftItem(
    int draftId,
    int itemId, {
    CancelToken? cancelToken,
  }) {
    return _delegate.removeDraftItem(draftId, itemId, cancelToken: cancelToken);
  }

  Future<ServiceResult<ExamResponseModel>> saveDraft(
    int draftId, {
    CancelToken? cancelToken,
  }) {
    return _delegate.saveDraft(draftId, cancelToken: cancelToken);
  }

  Future<ServiceResult<ExamResponseModel>> getExam(
    int examId, {
    CancelToken? cancelToken,
  }) {
    return _delegate.getExam(examId, cancelToken: cancelToken);
  }

  Future<ServiceResult<ExamResponseModel>> publishExam(
    int examId, {
    String? reason,
    CancelToken? cancelToken,
  }) {
    return _delegate.publishExam(
      examId,
      reason: reason,
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<ExamResponseModel>> unpublishExam(
    int examId, {
    String? reason,
    CancelToken? cancelToken,
  }) {
    return _delegate.unpublishExam(
      examId,
      reason: reason,
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<ExamResponseModel>> archiveExam(
    int examId, {
    String? reason,
    CancelToken? cancelToken,
  }) {
    return _delegate.archiveExam(
      examId,
      reason: reason,
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<ExamExportModel>> exportWord(
    int examId, {
    bool includeAnswerKey = true,
    CancelToken? cancelToken,
  }) {
    return _delegate.exportWord(
      examId,
      includeAnswerKey: includeAnswerKey,
      cancelToken: cancelToken,
    );
  }

  Future<ServiceResult<ExamExportModel>> exportExam({
    required int examId,
    ExamExportFormat format = ExamExportFormat.htmlDoc,
    bool includeAnswerKey = true,
    CancelToken? cancelToken,
  }) {
    if (format != ExamExportFormat.htmlDoc) {
      return Future.value(
        ServiceResult<ExamExportModel>.failure(
          ServiceError(
            type: ServiceErrorType.parsing,
            message: '${format.toJson()} export is not supported by backend',
          ),
        ),
      );
    }
    return exportWord(
      examId,
      includeAnswerKey: includeAnswerKey,
      cancelToken: cancelToken,
    );
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
    return QuestionBankExamService.buildGenerateExamPayload(
      courseId: courseId,
      title: title,
      instructions: instructions,
      totalMarks: totalMarks,
      markDistributionMode: markDistributionMode,
      roundingPolicy: roundingPolicy,
      rules: rules,
      sections: sections,
      seed: seed,
    );
  }

  static Map<String, dynamic> buildDraftSectionPayload({
    required String title,
    String? instructions,
    double? totalMarks,
    ExamSectionAnswerPolicy answerPolicy = ExamSectionAnswerPolicy.answerAll,
    int? requiredAnswerCount,
  }) {
    return QuestionBankExamService.buildDraftSectionPayload(
      title: title,
      instructions: instructions,
      totalMarks: totalMarks,
      answerPolicy: answerPolicy,
      requiredAnswerCount: requiredAnswerCount,
    );
  }

  static Map<String, dynamic> buildAddDraftItemPayload({
    required int questionId,
    int? draftSectionId,
    double? weightUnits,
    double? marks,
    String? overrideReason,
  }) {
    return QuestionBankExamService.buildAddDraftItemPayload(
      questionId: questionId,
      draftSectionId: draftSectionId,
      weightUnits: weightUnits,
      marks: marks,
      overrideReason: overrideReason,
    );
  }
}

const Object _noChange = Object();
