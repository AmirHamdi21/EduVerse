import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/question_bank/question_bank_enums.dart';
import '../../../models/question_bank/question_bank_fill_blank_model.dart';
import '../../../models/question_bank/question_bank_option_model.dart';
import '../../../models/question_bank/question_attachment_payload.dart';
import '../../../models/question_bank/question_bulk_row_model.dart';
import '../../../services/api/enrollment_service.dart';
import '../../../services/api/question_bank_service.dart';
import 'question_bulk_create_state.dart';

class QuestionBulkCreateCubit extends Cubit<QuestionBulkCreateState> {
  QuestionBulkCreateCubit({
    required QuestionBankService questionBankService,
    required EnrollmentService enrollmentService,
  }) : _questionBankService = questionBankService,
       _enrollmentService = enrollmentService,
       super(const QuestionBulkCreateState());

  final QuestionBankService _questionBankService;
  final EnrollmentService _enrollmentService;

  Future<void> initialize() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final coursesResult = await _enrollmentService.getTeachingCourses();
    final courses = coursesResult.data ?? const [];
    final courseId = courses.isNotEmpty ? courses.first.courseId : null;
    emit(
      state.copyWith(
        isLoading: false,
        courses: courses,
        courseId: courseId,
        clearError: true,
      ),
    );
    if (courseId != null) await selectCourse(courseId);
  }

  Future<void> selectCourse(int? courseId) async {
    emit(
      state.copyWith(
        courseId: courseId,
        clearCourse: courseId == null,
        clearDefaultChapter: true,
        chapters: const [],
        rows: state.rows
            .map((row) => row.copyWith(clearChapter: true))
            .toList(),
      ),
    );
    if (courseId == null) return;
    final result = await _questionBankService.getChapters(courseId);
    final chapters = result.data ?? const [];
    emit(
      state.copyWith(
        chapters: chapters,
        defaultChapterId: chapters.isNotEmpty ? chapters.first.id : null,
      ),
    );
  }

  Future<void> createChapter({
    required String name,
    required int chapterOrder,
  }) async {
    final courseId = state.courseId;
    if (courseId == null || courseId <= 0) {
      emit(state.copyWith(errorMessage: 'courseRequired'));
      return;
    }
    emit(
      state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true),
    );
    final result = await _questionBankService.createChapter(
      courseId: courseId,
      name: name,
      chapterOrder: chapterOrder,
    );
    if (!result.isSuccess || result.data == null) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: result.error?.message ?? 'chapterCreateFailed',
        ),
      );
      return;
    }
    final chapters = await _questionBankService.getChapters(courseId);
    emit(
      state.copyWith(
        isSubmitting: false,
        chapters: chapters.data ?? state.chapters,
        successMessage: 'chapterCreated',
      ),
    );
  }

  void selectDefaultChapter(int? chapterId) {
    emit(
      state.copyWith(
        defaultChapterId: chapterId,
        clearDefaultChapter: chapterId == null,
      ),
    );
  }

  void addRow() {
    if (state.rows.length >= 50) {
      emit(state.copyWith(errorMessage: 'bulkMaxRows'));
      return;
    }
    final nextId =
        state.rows.map((row) => row.localId).fold(0, (a, b) => a > b ? a : b) +
        1;
    emit(
      state.copyWith(
        rows: [
          ...state.rows,
          QuestionBulkRowModel(localId: nextId),
        ],
      ),
    );
  }

  void removeRow(int localId) {
    if (state.rows.length <= 1) return;
    emit(
      state.copyWith(
        rows: state.rows.where((row) => row.localId != localId).toList(),
      ),
    );
  }

  void updateRow(QuestionBulkRowModel row) {
    emit(
      state.copyWith(
        rows: state.rows
            .map((item) => item.localId == row.localId ? row : item)
            .toList(),
        clearError: true,
        clearFailureReport: true,
      ),
    );
  }

  void updateRowType(int localId, QuestionBankType type) {
    final row = state.rows.firstWhere((item) => item.localId == localId);
    updateRow(
      row.copyWith(
        questionType: type,
        options: _optionsForType(type, row.options),
        fillBlanks: type == QuestionBankType.fillBlanks
            ? (row.fillBlanks.isEmpty
                  ? const [
                      QuestionBankFillBlankModel(
                        blankKey: 'blank1',
                        acceptableAnswer: '',
                      ),
                    ]
                  : row.fillBlanks)
            : const [],
        expectedAnswerText:
            (type == QuestionBankType.written || type == QuestionBankType.essay)
            ? row.expectedAnswerText
            : '',
      ),
    );
  }

  Future<void> uploadRowQuestionImage({
    required int localId,
    required String path,
  }) async {
    emit(
      state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true),
    );
    final result = await _questionBankService.uploadQuestionImage(path);
    if (!result.isSuccess || result.data == null) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: result.error?.message ?? 'questionImageUploadFailed',
        ),
      );
      return;
    }
    final rows = state.rows.map((row) {
      if (row.localId != localId) return row;
      return row.copyWith(questionFileId: result.data!.fileId);
    }).toList();
    emit(
      state.copyWith(
        isSubmitting: false,
        rows: rows,
        successMessage: 'questionImageUploaded',
      ),
    );
  }

  Future<void> removeRowQuestionImage(int localId) async {
    final row = state.rows.firstWhere(
      (item) => item.localId == localId,
      orElse: () => QuestionBulkRowModel(localId: localId),
    );
    emit(
      state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true),
    );
    if (row.questionFileId != null) {
      await _questionBankService.deleteUploadedFile(row.questionFileId!);
    }
    emit(
      state.copyWith(
        isSubmitting: false,
        rows: state.rows
            .map(
              (item) => item.localId == localId
                  ? item.copyWith(
                      clearQuestionFile: true,
                      questionFileCaption: '',
                      questionFileAltText: '',
                      clearError: true,
                    )
                  : item,
            )
            .toList(),
        successMessage: 'questionImageRemoved',
      ),
    );
  }

  Future<void> uploadRowAttachments({
    required int localId,
    required List<String> paths,
  }) async {
    if (paths.isEmpty) return;
    emit(
      state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true),
    );
    final uploaded = <QuestionAttachmentPayload>[];
    for (final path in paths) {
      final result = await _questionBankService.uploadQuestionImage(path);
      if (!result.isSuccess || result.data == null) {
        emit(
          state.copyWith(
            isSubmitting: false,
            errorMessage: result.error?.message ?? 'attachmentUploadFailed',
          ),
        );
        return;
      }
      uploaded.add(
        QuestionAttachmentPayload(
          fileId: result.data!.fileId,
          fileName: result.data!.fileName,
          imageUrl: result.data!.imageUrl,
        ),
      );
    }
    emit(
      state.copyWith(
        isSubmitting: false,
        rows: state.rows
            .map(
              (row) => row.localId == localId
                  ? row.copyWith(
                      attachments: _normalizeAttachments([
                        ...row.attachments,
                        ...uploaded,
                      ]),
                    )
                  : row,
            )
            .toList(),
        successMessage: 'questionImageUploaded',
      ),
    );
  }

  Future<void> removeRowAttachment({
    required int localId,
    required int fileId,
  }) async {
    await _questionBankService.deleteUploadedFile(fileId);
    emit(
      state.copyWith(
        rows: state.rows
            .map(
              (row) => row.localId == localId
                  ? row.copyWith(
                      attachments: row.attachments
                          .where((attachment) => attachment.fileId != fileId)
                          .toList(),
                    )
                  : row,
            )
            .toList(),
        successMessage: 'questionImageRemoved',
      ),
    );
  }

  void updateRowAttachment({
    required int localId,
    required QuestionAttachmentPayload attachment,
  }) {
    emit(
      state.copyWith(
        rows: state.rows
            .map(
              (row) => row.localId == localId
                  ? row.copyWith(
                      attachments: row.attachments
                          .map(
                            (item) => item.fileId == attachment.fileId
                                ? attachment
                                : item,
                          )
                          .toList(),
                    )
                  : row,
            )
            .toList(),
      ),
    );
  }

  void reorderRowAttachments({
    required int localId,
    required List<int> orderedFileIds,
  }) {
    final row = state.rows.firstWhere((item) => item.localId == localId);
    final byId = {
      for (final attachment in row.attachments)
        if (attachment.fileId != null) attachment.fileId!: attachment,
    };
    updateRow(
      row.copyWith(
        attachments: _normalizeAttachments([
          for (final fileId in orderedFileIds)
            if (byId[fileId] != null) byId[fileId]!,
        ]),
      ),
    );
  }

  List<QuestionAttachmentPayload> _normalizeAttachments(
    List<QuestionAttachmentPayload> attachments,
  ) {
    return [
      for (var i = 0; i < attachments.length; i++)
        attachments[i].copyWith(displayOrder: i, isPrimary: i == 0),
    ];
  }

  List<QuestionBankOptionModel> _optionsForType(
    QuestionBankType type,
    List<QuestionBankOptionModel> existing,
  ) {
    switch (type) {
      case QuestionBankType.mcq:
        return const [
          QuestionBankOptionModel(optionText: '', isCorrect: true),
          QuestionBankOptionModel(optionText: '', isCorrect: false),
        ];
      case QuestionBankType.trueFalse:
        return const [
          QuestionBankOptionModel(optionText: 'True', isCorrect: true),
          QuestionBankOptionModel(optionText: 'False', isCorrect: false),
        ];
      case QuestionBankType.fillBlanks:
      case QuestionBankType.written:
      case QuestionBankType.essay:
        return const [];
    }
  }

  Future<bool> submit() async {
    final courseId = state.courseId;
    if (courseId == null || courseId <= 0) {
      emit(state.copyWith(errorMessage: 'courseRequired'));
      return false;
    }
    if (state.rows.length > 50) {
      emit(state.copyWith(errorMessage: 'bulkMaxRows'));
      return false;
    }
    final rows = <QuestionBulkRowModel>[];
    var hasError = false;
    for (final row in state.rows) {
      final payload = row.toPayload(courseId: courseId);
      final error = payload.validate();
      rows.add(row.copyWith(error: error, clearError: error == null));
      hasError = hasError || error != null;
    }
    if (hasError) {
      emit(
        state.copyWith(
          rows: rows,
          errorMessage: 'bulkRowsInvalid',
          failedRows: rows.where((row) => row.error != null).toList(),
          failureReportMessage: 'bulkRowsInvalid',
        ),
      );
      return false;
    }
    emit(
      state.copyWith(
        isSubmitting: true,
        rows: rows,
        clearError: true,
        clearFailureReport: true,
      ),
    );
    final result = await _questionBankService.bulkCreateQuestionsDetailed(
      courseId: courseId,
      questions: rows.map((row) => row.toPayload(courseId: courseId)).toList(),
    );
    if (!result.isSuccess) {
      final message = result.error?.message ?? 'bulkCreateFailed';
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: message,
          failedRows: rows,
          failureReportMessage: message,
        ),
      );
      return false;
    }
    final detailed = result.data;
    final failureByRow = {
      for (final failure in detailed?.failed ?? const [])
        failure.rowIndex: failure.message,
    };
    final rowsWithBackendFailures = [
      for (var i = 0; i < rows.length; i++)
        rows[i].copyWith(
          error: failureByRow[i],
          clearError: failureByRow[i] == null,
        ),
    ];
    final failedRows = rowsWithBackendFailures
        .where((row) => row.error != null)
        .toList();
    final allCreated = [...state.createdQuestions, ...?detailed?.created];
    emit(
      state.copyWith(
        isSubmitting: false,
        successMessage: detailed?.hasFailures == true
            ? 'bulkCreatePartialSuccess'
            : 'bulkCreateSuccess',
        createdQuestions: allCreated,
        rows: detailed?.hasFailures == true
            ? failedRows
            : const [QuestionBulkRowModel(localId: 1)],
        failedRows: failedRows,
        failureReportMessage: detailed?.hasFailures == true
            ? 'bulkCreatePartialSuccess'
            : null,
        clearFailureReport: detailed?.hasFailures != true,
      ),
    );
    return true;
  }

  Future<void> resetAfterSuccess() async {
    emit(
      state.copyWith(
        rows: const [QuestionBulkRowModel(localId: 1)],
        clearCreatedQuestions: true,
        clearFailureReport: true,
        clearError: true,
        clearSuccess: true,
      ),
    );
  }

  Future<void> discardPendingUploads() async {
    if (state.createdQuestions.isNotEmpty) return;
    final fileIds = <int>{};
    for (final row in state.rows) {
      final questionFileId = row.questionFileId;
      if (questionFileId != null) fileIds.add(questionFileId);
      for (final attachment in row.attachments) {
        final fileId = attachment.fileId;
        if (fileId != null) fileIds.add(fileId);
      }
    }
    for (final fileId in fileIds) {
      await _questionBankService.deleteUploadedFile(fileId);
    }
  }

  Future<bool> statusCreatedQuestions(String action) async {
    if (state.createdQuestions.isEmpty) return false;
    emit(state.copyWith(isSubmitting: true, clearError: true));
    final result = await _questionBankService.batchStatusAction(
      questionIds: state.createdQuestions
          .map((question) => question.id)
          .toList(),
      action: action,
    );
    if (!result.isSuccess) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: result.error?.message ?? 'bulkStatusFailed',
        ),
      );
      return false;
    }
    emit(
      state.copyWith(
        isSubmitting: false,
        createdQuestions: result.data ?? state.createdQuestions,
        successMessage: 'questionsBatchUpdated',
      ),
    );
    return true;
  }
}
