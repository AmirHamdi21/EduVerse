import 'dart:io';

import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import '../../common/retry_helper.dart';
import '../../common/service_error.dart';
import '../../models/exams/exam_draft_item_model.dart';
import '../../models/exams/exam_draft_model.dart';
import '../../models/exams/exam_draft_section_model.dart';
import '../../models/exams/exam_draft_validation_model.dart';
import '../../models/exams/exam_availability_model.dart';
import '../../models/exams/exam_export_options_model.dart';
import '../../models/exams/exam_export_response_model.dart';
import '../../models/exams/exam_full_detail_model.dart';
import '../../models/exams/exam_generation_rule_model.dart';
import '../../models/exams/exam_generation_readiness_model.dart';
import '../../models/exams/exam_generation_section_model.dart';
import '../../models/exams/exam_generator_enums.dart';
import '../../models/exams/exam_page_model.dart';
import '../../models/exams/exam_paper_template_model.dart';
import '../../models/exams/exam_response_model.dart';
import '../../models/exams/exam_replacement_check_model.dart';
import '../../models/exams/exam_shortage_model.dart';
import '../../models/exams/exam_stats_model.dart';
import 'core_api_client.dart';

class ExamGeneratorService {
  ExamGeneratorService({required CoreApiClient coreApiClient})
    : _client = coreApiClient;

  final CoreApiClient _client;

  Future<ServiceResult<ExamPageModel<ExamDraftModel>>> getDrafts({
    int? courseId,
    ExamDraftStatus? status,
    DateTime? dateFrom,
    DateTime? dateTo,
    int page = 1,
    int limit = 20,
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<ExamPageModel<ExamDraftModel>>(() async {
      final response = await _client.dio.get(
        '/exams/drafts',
        queryParameters: _query(
          courseId: courseId,
          status: status?.value,
          dateFrom: dateFrom,
          dateTo: dateTo,
          page: page,
          limit: limit,
        ),
        cancelToken: cancelToken,
      );
      return ExamPageModel<ExamDraftModel>.fromJson(
        _map(response.data),
        ExamDraftModel.fromJson,
      );
    }, fallbackMessage: 'Failed to load exam drafts');
  }

  Future<ServiceResult<ExamPageModel<ExamResponseModel>>> getExams({
    int? courseId,
    ExamStatus? status,
    DateTime? dateFrom,
    DateTime? dateTo,
    int page = 1,
    int limit = 20,
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<ExamPageModel<ExamResponseModel>>(() async {
      final response = await _client.dio.get(
        '/exams',
        queryParameters: _query(
          courseId: courseId,
          status: status?.value,
          dateFrom: dateFrom,
          dateTo: dateTo,
          page: page,
          limit: limit,
        ),
        cancelToken: cancelToken,
      );
      return ExamPageModel<ExamResponseModel>.fromJson(
        _map(response.data),
        ExamResponseModel.fromJson,
      );
    }, fallbackMessage: 'Failed to load exams');
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
      return ExamDraftModel.fromJson(_map(response.data));
    }, fallbackMessage: 'Failed to load draft');
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
      return ExamResponseModel.fromJson(_map(response.data));
    }, fallbackMessage: 'Failed to load exam');
  }

  Future<ServiceResult<ExamFullDetailModel>> getFullExam(
    int examId, {
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<ExamFullDetailModel>(() async {
      final response = await _client.dio.get(
        '/exams/$examId/full',
        cancelToken: cancelToken,
      );
      return ExamFullDetailModel.fromJson(_map(response.data));
    }, fallbackMessage: 'Failed to load full exam');
  }

  Future<ServiceResult<List<ExamPaperTemplateModel>>> getPaperTemplates({
    int? courseId,
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<List<ExamPaperTemplateModel>>(() async {
      final response = await _client.dio.get(
        '/exams/paper-templates',
        queryParameters: <String, dynamic>{
          if (courseId != null) 'courseId': courseId,
        },
        cancelToken: cancelToken,
      );
      final data = response.data;
      final list = data is List ? data : const <dynamic>[];
      return list
          .whereType<Map>()
          .map((item) => ExamPaperTemplateModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }, fallbackMessage: 'Failed to load paper templates');
  }

  Future<ServiceResult<ExamPaperTemplateModel>> createPaperTemplate(
    ExamPaperTemplateModel template,
  ) {
    return RetryHelper.execute<ExamPaperTemplateModel>(() async {
      final response = await _client.dio.post(
        '/exams/paper-templates',
        data: template.toJson(),
      );
      return ExamPaperTemplateModel.fromJson(_map(response.data));
    }, fallbackMessage: 'Failed to save paper template');
  }

  Future<ServiceResult<ExamPaperTemplateModel>> updatePaperTemplate(
    ExamPaperTemplateModel template,
  ) {
    return RetryHelper.execute<ExamPaperTemplateModel>(() async {
      final response = await _client.dio.patch(
        '/exams/paper-templates/${template.id}',
        data: template.toJson(),
      );
      return ExamPaperTemplateModel.fromJson(_map(response.data));
    }, fallbackMessage: 'Failed to update paper template');
  }

  Future<ServiceResult<Map<String, dynamic>>> applyPaperTemplate({
    required int examId,
    required ExamPaperTemplateModel template,
  }) {
    return RetryHelper.execute<Map<String, dynamic>>(() async {
      final response = await _client.dio.patch(
        '/exams/$examId/paper-template',
        data: <String, dynamic>{
          if (template.id != null) 'paperTemplateId': template.id,
          'paperTemplateSnapshot': template.toSnapshot(),
        },
      );
      return _map(response.data);
    }, fallbackMessage: 'Failed to apply paper template');
  }

  Future<ServiceResult<ExamStatsModel>> getStats({
    int? courseId,
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<ExamStatsModel>(() async {
      final response = await _client.dio.get(
        '/exams/stats',
        queryParameters: <String, dynamic>{
          if (courseId != null) 'courseId': courseId,
        },
        cancelToken: cancelToken,
      );
      return ExamStatsModel.fromJson(_map(response.data));
    }, fallbackMessage: 'Failed to load exam stats');
  }

  Future<ServiceResult<ExamGenerationReadinessModel>> getGenerationReadiness({
    required int courseId,
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<ExamGenerationReadinessModel>(() async {
      final response = await _client.dio.get(
        '/exams/generation-readiness',
        queryParameters: <String, dynamic>{'courseId': courseId},
        cancelToken: cancelToken,
      );
      return ExamGenerationReadinessModel.fromJson(_map(response.data));
    }, fallbackMessage: 'Failed to load generation readiness');
  }

  Future<ServiceResult<ExamDraftModel>> generatePreview({
    required int courseId,
    required String title,
    List<ExamGenerationRuleModel> rules = const <ExamGenerationRuleModel>[],
    List<ExamGenerationSectionModel> sections =
        const <ExamGenerationSectionModel>[],
    double? totalMarks,
    ExamMarkDistributionMode markDistributionMode =
        ExamMarkDistributionMode.weightNormalized,
    ExamRoundingPolicy roundingPolicy = ExamRoundingPolicy.none,
    ExamGroupSelectionMode groupSelectionMode =
        ExamGroupSelectionMode.independent,
    String? seed,
    int? durationMinutes,
    String? instructions,
    String? headerText,
    String? footerText,
  }) async {
    try {
      final response = await _client.dio.post(
        '/exams/generate-preview',
        data: <String, dynamic>{
          'courseId': courseId,
          'title': title.trim(),
          if (rules.isNotEmpty)
            'rules': rules.map((rule) => rule.toJson()).toList(),
          if (sections.isNotEmpty)
            'sections': sections.map((section) => section.toJson()).toList(),
          if (totalMarks != null) 'totalMarks': totalMarks,
          'markDistributionMode': markDistributionMode.value,
          'roundingPolicy': roundingPolicy.value,
          'groupSelectionMode': groupSelectionMode.value,
          if (seed != null && seed.trim().isNotEmpty) 'seed': seed.trim(),
          if (durationMinutes != null) 'durationMinutes': durationMinutes,
          if (instructions != null && instructions.trim().isNotEmpty)
            'instructions': instructions.trim(),
          if (headerText != null && headerText.trim().isNotEmpty)
            'headerText': headerText.trim(),
          if (footerText != null && footerText.trim().isNotEmpty)
            'footerText': footerText.trim(),
        },
      );
      final data = _map(response.data);
      return ServiceResult<ExamDraftModel>.success(
        ExamDraftModel.fromJson(<String, dynamic>{
          'id': data['draftId'],
          'courseId': courseId,
          'title': title,
          'seed': data['seed'],
          'totalMarks': data['totalMarks'],
          'markDistributionMode': markDistributionMode.value,
          'roundingPolicy': roundingPolicy.value,
          'durationMinutes': durationMinutes,
          'instructions': instructions,
          'headerText': headerText,
          'footerText': footerText,
          'status': ExamDraftStatus.open.value,
          'expiresAt': DateTime.now()
              .add(const Duration(hours: 24))
              .toIso8601String(),
          'sections': data['sections'],
          'items': data['items'],
        }),
      );
    } catch (error) {
      final shortage = _tryShortage(error);
      if (shortage != null) {
        return ServiceResult<ExamDraftModel>.failure(
          ServiceError(
            type: ServiceErrorType.server,
            message: shortage.message,
            originalError: shortage,
          ),
        );
      }
      return ServiceResult<ExamDraftModel>.failure(
        RetryHelper.mapToServiceError(
          error,
          fallbackMessage: 'Failed to generate exam draft',
        ),
      );
    }
  }

  Future<ServiceResult<ExamAvailabilityModel>> checkGenerationAvailability({
    required int courseId,
    required String title,
    List<ExamGenerationRuleModel> rules = const <ExamGenerationRuleModel>[],
    List<ExamGenerationSectionModel> sections =
        const <ExamGenerationSectionModel>[],
    double? totalMarks,
    ExamMarkDistributionMode markDistributionMode =
        ExamMarkDistributionMode.weightNormalized,
    ExamRoundingPolicy roundingPolicy = ExamRoundingPolicy.none,
    ExamGroupSelectionMode groupSelectionMode =
        ExamGroupSelectionMode.independent,
    String? seed,
    int? durationMinutes,
    String? instructions,
    String? headerText,
    String? footerText,
  }) {
    return RetryHelper.execute<ExamAvailabilityModel>(() async {
      final response = await _client.dio.post(
        '/exams/generation-availability',
        data: <String, dynamic>{
          'courseId': courseId,
          'title': title.trim().isEmpty ? 'Availability check' : title.trim(),
          if (rules.isNotEmpty)
            'rules': rules.map((rule) => rule.toJson()).toList(),
          if (sections.isNotEmpty)
            'sections': sections.map((section) => section.toJson()).toList(),
          if (totalMarks != null) 'totalMarks': totalMarks,
          'markDistributionMode': markDistributionMode.value,
          'roundingPolicy': roundingPolicy.value,
          'groupSelectionMode': groupSelectionMode.value,
          if (seed != null && seed.trim().isNotEmpty) 'seed': seed.trim(),
          if (durationMinutes != null) 'durationMinutes': durationMinutes,
          if (instructions != null && instructions.trim().isNotEmpty)
            'instructions': instructions.trim(),
          if (headerText != null && headerText.trim().isNotEmpty)
            'headerText': headerText.trim(),
          if (footerText != null && footerText.trim().isNotEmpty)
            'footerText': footerText.trim(),
        },
      );
      return ExamAvailabilityModel.fromJson(_map(response.data));
    }, fallbackMessage: 'Failed to check generation availability');
  }

  Future<ServiceResult<ExamDraftSectionModel>> createSection({
    required int draftId,
    required String title,
    String? instructions,
    double? totalMarks,
    ExamSectionAnswerPolicy? answerPolicy,
    int? requiredAnswerCount,
  }) {
    return RetryHelper.execute<ExamDraftSectionModel>(() async {
      final response = await _client.dio.post(
        '/exams/drafts/$draftId/sections',
        data: <String, dynamic>{
          'title': title.trim(),
          if (instructions != null) 'instructions': instructions.trim(),
          if (totalMarks != null) 'totalMarks': totalMarks,
          if (answerPolicy != null) 'answerPolicy': answerPolicy.value,
          if (requiredAnswerCount != null)
            'requiredAnswerCount': requiredAnswerCount,
        },
      );
      return ExamDraftSectionModel.fromJson(_map(response.data));
    }, fallbackMessage: 'Failed to create section');
  }

  Future<ServiceResult<void>> reorderSections({
    required int draftId,
    required List<Map<String, int>> items,
  }) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.patch(
        '/exams/drafts/$draftId/sections/reorder',
        data: <String, dynamic>{'items': items},
      );
    }, fallbackMessage: 'Failed to reorder sections');
  }

  Future<ServiceResult<ExamDraftSectionModel>> updateSection({
    required int draftId,
    required int sectionId,
    String? title,
    String? instructions,
    double? totalMarks,
    ExamSectionAnswerPolicy? answerPolicy,
    int? requiredAnswerCount,
  }) {
    return RetryHelper.execute<ExamDraftSectionModel>(() async {
      final response = await _client.dio.patch(
        '/exams/drafts/$draftId/sections/$sectionId',
        data: <String, dynamic>{
          if (title != null) 'title': title.trim(),
          if (instructions != null) 'instructions': instructions.trim(),
          if (totalMarks != null) 'totalMarks': totalMarks,
          if (answerPolicy != null) 'answerPolicy': answerPolicy.value,
          if (requiredAnswerCount != null)
            'requiredAnswerCount': requiredAnswerCount,
        },
      );
      return ExamDraftSectionModel.fromJson(_map(response.data));
    }, fallbackMessage: 'Failed to update section');
  }

  Future<ServiceResult<void>> deleteSection({
    required int draftId,
    required int sectionId,
  }) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.delete('/exams/drafts/$draftId/sections/$sectionId');
    }, fallbackMessage: 'Failed to delete section');
  }

  Future<ServiceResult<ExamDraftItemModel>> addItem({
    required int draftId,
    required int questionId,
    int? draftSectionId,
    double? weightUnits,
    double? marks,
    String? overrideReason,
  }) {
    return RetryHelper.execute<ExamDraftItemModel>(() async {
      final response = await _client.dio.post(
        '/exams/drafts/$draftId/items',
        data: <String, dynamic>{
          'questionId': questionId,
          if (draftSectionId != null) 'draftSectionId': draftSectionId,
          if (weightUnits != null) 'weightUnits': weightUnits,
          if (marks != null) 'marks': marks,
          if (overrideReason != null && overrideReason.trim().isNotEmpty)
            'overrideReason': overrideReason.trim(),
        },
      );
      return ExamDraftItemModel.fromJson(_map(response.data));
    }, fallbackMessage: 'Failed to add draft item');
  }

  Future<ServiceResult<void>> updateItem({
    required int draftId,
    required int itemId,
    int? replacementQuestionId,
    int? draftSectionId,
    double? weight,
    double? weightUnits,
    double? marks,
    int? itemOrder,
    String? overrideReason,
  }) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.patch(
        '/exams/drafts/$draftId/items/$itemId',
        data: <String, dynamic>{
          if (replacementQuestionId != null)
            'replacementQuestionId': replacementQuestionId,
          if (draftSectionId != null) 'draftSectionId': draftSectionId,
          if (weight != null) 'weight': weight,
          if (weightUnits != null) 'weightUnits': weightUnits,
          if (marks != null) 'marks': marks,
          if (itemOrder != null) 'itemOrder': itemOrder,
          if (overrideReason != null && overrideReason.trim().isNotEmpty)
            'overrideReason': overrideReason.trim(),
        },
      );
    }, fallbackMessage: 'Failed to update draft item');
  }

  Future<ServiceResult<ExamReplacementCheckModel>> checkReplacement({
    required int draftId,
    required int itemId,
    required int replacementQuestionId,
  }) {
    return RetryHelper.execute<ExamReplacementCheckModel>(() async {
      final response = await _client.dio.post(
        '/exams/drafts/$draftId/items/$itemId/replacement-check',
        data: <String, dynamic>{'replacementQuestionId': replacementQuestionId},
      );
      return ExamReplacementCheckModel.fromJson(_map(response.data));
    }, fallbackMessage: 'Failed to check replacement');
  }

  Future<ServiceResult<void>> removeItem({
    required int draftId,
    required int itemId,
  }) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.delete('/exams/drafts/$draftId/items/$itemId');
    }, fallbackMessage: 'Failed to remove draft item');
  }

  Future<ServiceResult<void>> reorderItems({
    required int draftId,
    required List<Map<String, int>> items,
  }) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.patch(
        '/exams/drafts/$draftId/items/reorder',
        data: <String, dynamic>{'items': items},
      );
    }, fallbackMessage: 'Failed to reorder items');
  }

  Future<ServiceResult<ExamResponseModel>> saveDraft(int draftId) {
    return RetryHelper.execute<ExamResponseModel>(() async {
      final response = await _client.dio.post('/exams/drafts/$draftId/save');
      return ExamResponseModel.fromJson(_map(response.data));
    }, fallbackMessage: 'Failed to save draft');
  }

  Future<ServiceResult<ExamDraftValidationModel>> validateDraft(int draftId) {
    return RetryHelper.execute<ExamDraftValidationModel>(() async {
      final response = await _client.dio.get(
        '/exams/drafts/$draftId/validation',
      );
      return ExamDraftValidationModel.fromJson(_map(response.data));
    }, fallbackMessage: 'Failed to validate draft');
  }

  Future<ServiceResult<ExamDraftModel>> regenerateDraft({
    required int draftId,
    String? seed,
    bool keepManualEdits = false,
  }) {
    return RetryHelper.execute<ExamDraftModel>(() async {
      final response = await _client.dio.post(
        '/exams/drafts/$draftId/regenerate',
        data: <String, dynamic>{
          if (seed != null && seed.trim().isNotEmpty) 'seed': seed.trim(),
          'keepManualEdits': keepManualEdits,
        },
      );
      final data = _map(response.data);
      final newDraftId = _toInt(data['draftId'] ?? data['id']);
      final draft = await getDraft(newDraftId);
      if (draft.isSuccess && draft.data != null) {
        return draft.data!;
      }
      return ExamDraftModel.fromJson(data);
    }, fallbackMessage: 'Failed to regenerate draft');
  }

  Future<ServiceResult<ExamDraftModel>> duplicateDraft({
    required int draftId,
    String? title,
    String? seed,
    bool regenerate = false,
  }) {
    return RetryHelper.execute<ExamDraftModel>(() async {
      final response = await _client.dio.post(
        '/exams/drafts/$draftId/duplicate',
        data: <String, dynamic>{
          if (title != null && title.trim().isNotEmpty) 'title': title.trim(),
          if (seed != null && seed.trim().isNotEmpty) 'seed': seed.trim(),
          'regenerate': regenerate,
        },
      );
      return ExamDraftModel.fromJson(_map(response.data));
    }, fallbackMessage: 'Failed to duplicate draft');
  }

  Future<ServiceResult<ExamDraftModel>> reshuffleSection({
    required int draftId,
    required int sectionId,
    String? seed,
    bool keepManualEdits = true,
  }) {
    return RetryHelper.execute<ExamDraftModel>(() async {
      final response = await _client.dio.post(
        '/exams/drafts/$draftId/sections/$sectionId/reshuffle',
        data: <String, dynamic>{
          if (seed != null && seed.trim().isNotEmpty) 'seed': seed.trim(),
          'keepManualEdits': keepManualEdits,
        },
      );
      return ExamDraftModel.fromJson(_map(response.data));
    }, fallbackMessage: 'Failed to reshuffle section');
  }

  Future<ServiceResult<void>> normalizeSectionMarks({
    required int draftId,
    required int sectionId,
    double? totalMarks,
  }) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.post(
        '/exams/drafts/$draftId/sections/$sectionId/normalize-marks',
        data: <String, dynamic>{
          if (totalMarks != null) 'totalMarks': totalMarks,
        },
      );
    }, fallbackMessage: 'Failed to normalize section marks');
  }

  Future<ServiceResult<ExamResponseModel>> lifecycle({
    required int examId,
    required String action,
    String? reason,
  }) {
    return RetryHelper.execute<ExamResponseModel>(() async {
      final response = await _client.dio.post(
        '/exams/$examId/$action',
        data: <String, dynamic>{
          if (reason != null && reason.trim().isNotEmpty)
            'reason': reason.trim(),
        },
      );
      return ExamResponseModel.fromJson(_map(response.data));
    }, fallbackMessage: 'Failed to update exam');
  }

  Future<ServiceResult<ExamExportResponseModel>> exportExam({
    required int examId,
    bool includeAnswerKey = false,
    ExamExportOptionsModel options = const ExamExportOptionsModel(),
  }) {
    return RetryHelper.execute<ExamExportResponseModel>(() async {
      final response = await _client.dio.post(
        '/exams/$examId/export-word',
        data: <String, dynamic>{
          ...options.toJson(),
          if (includeAnswerKey) 'includeAnswerKey': true,
        },
      );
      return ExamExportResponseModel.fromJson(_map(response.data));
    }, fallbackMessage: 'Failed to export exam');
  }

  Future<ServiceResult<String>> saveAndOpenExport(
    ExamExportResponseModel export,
  ) {
    return RetryHelper.execute<String>(() async {
      final filePath = await _saveExportFile(export);
      await OpenFile.open(filePath);
      return filePath;
    }, fallbackMessage: 'Failed to save exported exam');
  }

  Future<ServiceResult<String>> saveExportFile(ExamExportResponseModel export) {
    return RetryHelper.execute<String>(() async {
      return _saveExportFile(export);
    }, fallbackMessage: 'Failed to save exported exam');
  }

  Future<ServiceResult<String>> openExportFile(String filePath) {
    return RetryHelper.execute<String>(() async {
      await OpenFile.open(filePath);
      return filePath;
    }, fallbackMessage: 'Failed to open exported exam');
  }

  Future<String> _saveExportFile(ExamExportResponseModel export) async {
    final directory = await getTemporaryDirectory();
    final file = File(
      '${directory.path}${Platform.pathSeparator}${export.fileName}',
    );
    await file.writeAsBytes(export.decodedBytes, flush: true);
      return file.path;
  }

  Map<String, dynamic> _query({
    int? courseId,
    String? status,
    DateTime? dateFrom,
    DateTime? dateTo,
    required int page,
    required int limit,
  }) {
    return <String, dynamic>{
      'page': page,
      'limit': limit,
      if (courseId != null) 'courseId': courseId,
      if (status != null) 'status': status,
      if (dateFrom != null) 'dateFrom': dateFrom.toIso8601String(),
      if (dateTo != null) 'dateTo': dateTo.toIso8601String(),
    };
  }

  ExamShortageException? _tryShortage(Object error) {
    if (error is! DioException) return null;
    final data = error.response?.data;
    if (data is! Map) return null;
    final message = data['message'];
    final body = message is Map ? message : data;
    final shortages = body['shortages'];
    if (shortages is! List) return null;
    return ExamShortageException(
      body['message']?.toString() ?? 'Insufficient question pool',
      shortages
          .whereType<Map>()
          .map(
            (item) =>
                ExamShortageModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
    );
  }

  Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
