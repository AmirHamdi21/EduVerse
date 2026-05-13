import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/bloc/route_request_controller.dart';

import '../../../models/question_bank/question_bank_enums.dart';
import '../../../models/question_bank/question_bank_fill_blank_model.dart';
import '../../../models/question_bank/question_bank_form_payload.dart';
import '../../../models/question_bank/question_bank_option_model.dart';
import '../../../models/question_bank/question_attachment_payload.dart';
import '../../../models/question_bank/question_bank_question_model.dart';
import '../../../services/api/question_bank_service.dart';
import 'question_form_state.dart';

class QuestionFormCubit extends Cubit<QuestionFormState>
    with SafeRouteCubitMixin<QuestionFormState> {
  QuestionFormCubit({required QuestionBankService questionBankService})
    : _questionBankService = questionBankService,
      super(const QuestionFormState());

  final QuestionBankService _questionBankService;
  int _pendingFileSeed = -1;

  Future<void> initializeCreate({int? courseId}) async {
    emitIfOpen(
      state.copyWith(courseId: courseId, isLoading: true, clearError: true),
    );
    if (courseId != null) {
      final chapters = await _questionBankService.getChapters(courseId);
      emitIfOpen(
        state.copyWith(
          chapters: chapters.data ?? const [],
          chapterId: chapters.data?.isNotEmpty == true
              ? chapters.data!.first.id
              : null,
          isLoading: false,
        ),
      );
    } else {
      emitIfOpen(state.copyWith(isLoading: false));
    }
  }

  Future<void> initializeEdit(int questionId) async {
    emitIfOpen(state.copyWith(isLoading: true, clearError: true));
    final result = await _questionBankService.getQuestion(questionId);
    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          isLoading: false,
          errorMessage: result.error?.message ?? 'Failed to load question',
        ),
      );
      return;
    }
    final question = result.data!;
    final chapters = await _questionBankService.getChapters(question.courseId);
    emitIfOpen(
      state.copyWith(
        isLoading: false,
        originalQuestion: question,
        courseId: question.courseId,
        chapterId: question.chapterId,
        questionType: question.questionType,
        difficulty: question.difficulty,
        bloomLevel: question.bloomLevel,
        questionText: question.questionText ?? '',
        questionFileId: question.questionFileId,
        questionImageUrl: question.questionImageUrl,
        questionFileCaption: question.questionFileCaption ?? '',
        questionFileAltText: question.questionFileAltText ?? '',
        expectedAnswerText: question.expectedAnswerText ?? '',
        hints: question.hints ?? '',
        options: question.options,
        fillBlanks: question.fillBlanks,
        chapters: chapters.data ?? const [],
      ),
    );
  }

  Future<void> selectCourse(int? courseId) async {
    emitIfOpen(
      state.copyWith(
        courseId: courseId,
        clearCourse: courseId == null,
        clearChapter: true,
        isLoading: true,
      ),
    );
    if (courseId == null) {
      emitIfOpen(state.copyWith(chapters: const [], isLoading: false));
      return;
    }
    final chapters = await _questionBankService.getChapters(courseId);
    emitIfOpen(
      state.copyWith(
        chapters: chapters.data ?? const [],
        chapterId: chapters.data?.isNotEmpty == true
            ? chapters.data!.first.id
            : null,
        isLoading: false,
      ),
    );
  }

  Future<void> createChapter({
    required String name,
    required int chapterOrder,
  }) async {
    final courseId = state.courseId;
    if (courseId == null || courseId <= 0) {
      emitIfOpen(state.copyWith(errorMessage: 'courseRequired'));
      return;
    }
    emitIfOpen(
      state.copyWith(isLoading: true, clearError: true, clearSuccess: true),
    );
    final result = await _questionBankService.createChapter(
      courseId: courseId,
      name: name,
      chapterOrder: chapterOrder,
    );
    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          isLoading: false,
          errorMessage: result.error?.message ?? 'chapterCreateFailed',
        ),
      );
      return;
    }
    final chapters = await _questionBankService.getChapters(courseId);
    emitIfOpen(
      state.copyWith(
        isLoading: false,
        chapters: chapters.data ?? const [],
        chapterId: result.data!.id,
        successMessage: 'chapterCreated',
      ),
    );
  }

  void updateCore({
    int? chapterId,
    QuestionBankType? questionType,
    QuestionBankDifficulty? difficulty,
    BloomLevel? bloomLevel,
    String? questionText,
    String? questionFileCaption,
    String? questionFileAltText,
    String? expectedAnswerText,
    String? hints,
  }) {
    var nextOptions = state.options;
    var nextBlanks = state.fillBlanks;
    if (questionType != null && questionType != state.questionType) {
      nextOptions = _defaultOptions(questionType);
      nextBlanks = questionType == QuestionBankType.fillBlanks
          ? const <QuestionBankFillBlankModel>[
              QuestionBankFillBlankModel(
                blankKey: 'blank1',
                acceptableAnswer: '',
              ),
            ]
          : const <QuestionBankFillBlankModel>[];
    }
    emitIfOpen(
      state.copyWith(
        chapterId: chapterId,
        questionType: questionType,
        difficulty: difficulty,
        bloomLevel: bloomLevel,
        questionText: questionText,
        questionFileCaption: questionFileCaption,
        questionFileAltText: questionFileAltText,
        expectedAnswerText: expectedAnswerText,
        hints: hints,
        options: nextOptions,
        fillBlanks: nextBlanks,
        clearValidation: true,
      ),
    );
  }

  void updateOptions(List<QuestionBankOptionModel> options) {
    emitIfOpen(state.copyWith(options: options, clearValidation: true));
  }

  void updateFillBlanks(List<QuestionBankFillBlankModel> blanks) {
    emitIfOpen(state.copyWith(fillBlanks: blanks, clearValidation: true));
  }

  Future<void> uploadQuestionImage(String path) async {
    emitIfOpen(
      state.copyWith(
        questionFileId: _nextPendingFileId(),
        questionImageLocalPath: path,
        clearQuestionImageUrl: true,
        clearError: true,
        clearSuccess: true,
      ),
    );
  }

  Future<void> removeQuestionImage() async {
    final fileId = state.questionFileId;
    emitIfOpen(
      state.copyWith(isUploading: true, clearError: true, clearSuccess: true),
    );
    if (fileId != null && fileId > 0 && state.originalQuestion == null) {
      await _questionBankService.deleteUploadedFile(fileId);
    }
    emitIfOpen(
      state.copyWith(
        isUploading: false,
        clearQuestionFile: true,
        questionFileCaption: '',
        questionFileAltText: '',
        successMessage: 'questionImageRemoved',
      ),
    );
  }

  Future<void> uploadCreateAttachments(List<String> paths) async {
    if (paths.isEmpty) return;
    final next = [...state.attachments];
    for (final path in paths) {
      next.add(
        QuestionAttachmentPayload(
          fileId: _nextPendingFileId(),
          displayOrder: next.length,
          isPrimary: next.isEmpty,
          fileName: _fileNameFromPath(path),
          localPath: path,
        ),
      );
    }
    emitIfOpen(
      state.copyWith(
        attachments: _normalizeAttachmentOrders(next),
        clearError: true,
        clearSuccess: true,
      ),
    );
  }

  Future<void> removeCreateAttachment(int fileId) async {
    emitIfOpen(
      state.copyWith(isUploading: true, clearError: true, clearSuccess: true),
    );
    if (fileId > 0) {
      await _questionBankService.deleteUploadedFile(fileId);
    }
    emitIfOpen(
      state.copyWith(
        isUploading: false,
        attachments: _normalizeAttachmentOrders(
          state.attachments
              .where((attachment) => attachment.fileId != fileId)
              .toList(),
        ),
        successMessage: 'attachmentRemoved',
      ),
    );
  }

  void updateCreateAttachment(QuestionAttachmentPayload updated) {
    emitIfOpen(
      state.copyWith(
        attachments: _normalizeAttachmentOrders(
          state.attachments
              .map((item) => item.fileId == updated.fileId ? updated : item)
              .toList(),
        ),
        clearValidation: true,
      ),
    );
  }

  void reorderCreateAttachments(List<int> orderedFileIds) {
    final byId = {
      for (final attachment in state.attachments)
        if (attachment.fileId != null) attachment.fileId!: attachment,
    };
    emitIfOpen(
      state.copyWith(
        attachments: _normalizeAttachmentOrders([
          for (final fileId in orderedFileIds)
            if (byId[fileId] != null) byId[fileId]!,
        ]),
      ),
    );
  }

  Future<bool> submit() async {
    final payload = _payload();
    final validation = payload.validate();
    if (validation != null) {
      emitIfOpen(state.copyWith(validationError: validation));
      return false;
    }
    emitIfOpen(
      state.copyWith(
        isSaving: true,
        clearError: true,
        clearSuccess: true,
        clearValidation: true,
      ),
    );
    final uploadedFileIds = <int>[];
    final preparedPayload = await _uploadPendingMedia(payload, uploadedFileIds);
    if (preparedPayload == null) {
      await _discardUploadedFiles(uploadedFileIds);
      return false;
    }

    final original = state.originalQuestion;
    final result = original == null
        ? await _questionBankService.createQuestion(preparedPayload)
        : await _questionBankService.updateQuestion(
            questionId: original.id,
            dirtyPayload: preparedPayload.toDirtyUpdateJson(original),
          );
    if (!result.isSuccess || result.data == null) {
      await _discardUploadedFiles(uploadedFileIds);
      emitIfOpen(
        state.copyWith(
          isSaving: false,
          errorMessage: result.error?.message ?? 'Failed to save question',
        ),
      );
      return false;
    }
    emitIfOpen(
      state.copyWith(
        isSaving: false,
        savedQuestion: result.data,
        successMessage: original == null ? 'draftSaved' : 'questionSaved',
      ),
    );
    return true;
  }

  Future<bool> statusSavedQuestion(String action) async {
    final question = state.savedQuestion;
    if (question == null) return false;
    emitIfOpen(
      state.copyWith(isSaving: true, clearError: true, clearSuccess: true),
    );
    final result = await _questionBankService.statusAction(
      questionId: question.id,
      action: action,
    );
    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          isSaving: false,
          errorMessage: result.error?.message ?? 'Failed to update question',
        ),
      );
      return false;
    }
    final confirmed = await _confirmStatus(result.data!, action);
    if (confirmed == null) {
      emitIfOpen(
        state.copyWith(
          isSaving: false,
          errorMessage: 'questionStatusNotConfirmed',
        ),
      );
      return false;
    }
    emitIfOpen(
      state.copyWith(
        isSaving: false,
        savedQuestion: confirmed,
        successMessage: 'questionStatusUpdated:${confirmed.status.value}',
      ),
    );
    return true;
  }

  Future<QuestionBankQuestionModel?> _confirmStatus(
    QuestionBankQuestionModel actionResponse,
    String action,
  ) async {
    final expected = _expectedStatus(action);
    if (expected == null) return actionResponse;

    var latest = actionResponse;
    for (var attempt = 0; attempt < 3; attempt++) {
      final result = await _questionBankService.getQuestion(actionResponse.id);
      if (result.isSuccess && result.data != null) {
        latest = result.data!;
        if (latest.status == expected) return latest;
      }
      if (attempt < 2) {
        await Future<void>.delayed(const Duration(milliseconds: 350));
      }
    }
    return latest.status == expected ? latest : null;
  }

  QuestionBankStatus? _expectedStatus(String action) {
    switch (action) {
      case 'submit-for-review':
        return QuestionBankStatus.underReview;
      case 'approve':
        return QuestionBankStatus.approved;
      case 'reject':
        return QuestionBankStatus.rejected;
      case 'archive':
        return QuestionBankStatus.archived;
      case 'restore':
        return QuestionBankStatus.draft;
      default:
        return null;
    }
  }

  bool get hasDiscardableUploads {
    if (state.originalQuestion != null || state.savedQuestion != null) {
      return false;
    }
    return state.questionFileId != null || state.attachments.isNotEmpty;
  }

  Future<void> discardPendingUploads() async {
    if (!hasDiscardableUploads) return;
    final fileIds = <int>{};
    final questionFileId = state.questionFileId;
    if (questionFileId != null && questionFileId > 0) {
      fileIds.add(questionFileId);
    }
    for (final attachment in state.attachments) {
      final fileId = attachment.fileId;
      if (fileId != null && fileId > 0) fileIds.add(fileId);
    }
    for (final fileId in fileIds) {
      await _questionBankService.deleteUploadedFile(fileId);
    }
    emitIfOpen(
      state.copyWith(
        clearQuestionFile: true,
        questionFileCaption: '',
        questionFileAltText: '',
        attachments: const <QuestionAttachmentPayload>[],
        clearSuccess: true,
        clearError: true,
      ),
    );
  }

  QuestionBankFormPayload _payload() {
    return QuestionBankFormPayload(
      courseId: state.courseId,
      chapterId: state.chapterId,
      questionType: state.questionType,
      difficulty: state.difficulty,
      bloomLevel: state.bloomLevel,
      questionText: state.questionText,
      questionFileId: state.questionFileId,
      questionImageLocalPath: state.questionImageLocalPath,
      questionFileCaption: state.questionFileCaption,
      questionFileAltText: state.questionFileAltText,
      expectedAnswerText: state.expectedAnswerText,
      hints: state.hints,
      options: state.options,
      fillBlanks: state.fillBlanks,
      attachments: state.originalQuestion == null
          ? state.attachments
          : const <QuestionAttachmentPayload>[],
    );
  }

  Future<QuestionBankFormPayload?> _uploadPendingMedia(
    QuestionBankFormPayload payload,
    List<int> uploadedFileIds,
  ) async {
    var questionFileId = payload.questionFileId;
    if ((questionFileId == null || questionFileId <= 0) &&
        payload.questionImageLocalPath != null) {
      final result = await _questionBankService.uploadQuestionImage(
        payload.questionImageLocalPath!,
      );
      if (!result.isSuccess || result.data == null) {
        emitIfOpen(
          state.copyWith(
            isSaving: false,
            errorMessage: result.error?.message ?? 'questionImageUploadFailed',
          ),
        );
        return null;
      }
      questionFileId = result.data!.fileId;
      uploadedFileIds.add(questionFileId);
    }

    final attachments = <QuestionAttachmentPayload>[];
    for (final attachment in payload.attachments) {
      var fileId = attachment.fileId;
      if ((fileId == null || fileId <= 0) && attachment.localPath != null) {
        final result = await _questionBankService.uploadQuestionImage(
          attachment.localPath!,
        );
        if (!result.isSuccess || result.data == null) {
          emitIfOpen(
            state.copyWith(
              isSaving: false,
              errorMessage: result.error?.message ?? 'attachmentUploadFailed',
            ),
          );
          return null;
        }
        fileId = result.data!.fileId;
        uploadedFileIds.add(fileId);
      }
      attachments.add(attachment.copyWith(fileId: fileId));
    }

    return QuestionBankFormPayload(
      courseId: payload.courseId,
      chapterId: payload.chapterId,
      questionType: payload.questionType,
      difficulty: payload.difficulty,
      bloomLevel: payload.bloomLevel,
      questionText: payload.questionText,
      questionFileId: questionFileId,
      questionFileCaption: payload.questionFileCaption,
      questionFileAltText: payload.questionFileAltText,
      expectedAnswerText: payload.expectedAnswerText,
      hints: payload.hints,
      status: payload.status,
      options: payload.options,
      fillBlanks: payload.fillBlanks,
      attachments: attachments,
    );
  }

  Future<void> _discardUploadedFiles(Iterable<int> fileIds) async {
    for (final fileId in fileIds.toSet()) {
      if (fileId > 0) {
        await _questionBankService.deleteUploadedFile(fileId);
      }
    }
  }

  int _nextPendingFileId() => _pendingFileSeed--;

  String _fileNameFromPath(String path) {
    final parts = path.split(RegExp(r'[\\/]'));
    return parts.isEmpty ? path : parts.last;
  }

  List<QuestionAttachmentPayload> _normalizeAttachmentOrders(
    List<QuestionAttachmentPayload> attachments,
  ) {
    return [
      for (var i = 0; i < attachments.length; i++)
        attachments[i].copyWith(displayOrder: i, isPrimary: i == 0),
    ];
  }

  List<QuestionBankOptionModel> _defaultOptions(QuestionBankType type) {
    if (type == QuestionBankType.trueFalse) {
      return const <QuestionBankOptionModel>[
        QuestionBankOptionModel(optionText: 'True', isCorrect: true),
        QuestionBankOptionModel(optionText: 'False', isCorrect: false),
      ];
    }
    if (type == QuestionBankType.mcq) {
      return const <QuestionBankOptionModel>[
        QuestionBankOptionModel(optionText: '', isCorrect: true),
        QuestionBankOptionModel(optionText: '', isCorrect: false),
      ];
    }
    return const <QuestionBankOptionModel>[];
  }
}
