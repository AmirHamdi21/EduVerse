import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/bloc/route_request_controller.dart';

import '../../../models/question_bank/question_bank_enums.dart';
import '../../../models/question_bank/question_bank_fill_blank_model.dart';
import '../../../models/question_bank/question_bank_option_model.dart';
import '../../../models/question_bank/question_attachment_payload.dart';
import '../../../models/question_bank/question_bulk_row_model.dart';
import '../../../services/api/enrollment_service.dart';
import '../../../services/api/question_bank_service.dart';
import 'question_bulk_create_state.dart';

class QuestionBulkCreateCubit extends Cubit<QuestionBulkCreateState>
    with SafeRouteCubitMixin<QuestionBulkCreateState> {
  QuestionBulkCreateCubit({
    required QuestionBankService questionBankService,
    required EnrollmentService enrollmentService,
  }) : _questionBankService = questionBankService,
       _enrollmentService = enrollmentService,
       super(const QuestionBulkCreateState());

  final QuestionBankService _questionBankService;
  final EnrollmentService _enrollmentService;
  int _courseRequestVersion = 0;
  int _pendingFileSeed = -1;

  Future<void> initialize() async {
    emitIfOpen(state.copyWith(isLoading: true, clearError: true));
    final coursesResult = await _enrollmentService.getTeachingCourses();
    final courses = coursesResult.data ?? const [];
    final courseId = courses.isNotEmpty ? courses.first.courseId : null;
    if (courseId == null) {
      emitIfOpen(
        state.copyWith(
          isLoading: false,
          courses: courses,
          clearCourse: true,
          clearDefaultChapter: true,
          clearError: true,
        ),
      );
      return;
    }
    final chaptersResult = await _questionBankService.getChapters(courseId);
    final chapters = chaptersResult.data ?? const [];
    final defaultChapterId = chapters.isNotEmpty ? chapters.first.id : null;
    emitIfOpen(
      state.copyWith(
        isLoading: false,
        courses: courses,
        courseId: courseId,
        chapters: chapters,
        defaultChapterId: defaultChapterId,
        rows: _applyDefaultChapter(state.rows, defaultChapterId),
        clearError: true,
      ),
    );
  }

  Future<void> selectCourse(int? courseId) async {
    final requestVersion = ++_courseRequestVersion;
    emitIfOpen(
      state.copyWith(
        courseId: courseId,
        clearCourse: courseId == null,
        clearDefaultChapter: true,
        isLoadingChapters: courseId != null,
        chapters: const [],
        rows: state.rows
            .map((row) => row.copyWith(clearChapter: true))
            .toList(),
      ),
    );
    if (courseId == null) {
      emitIfOpen(state.copyWith(isLoadingChapters: false));
      return;
    }
    final result = await _questionBankService.getChapters(courseId);
    if (requestVersion != _courseRequestVersion || state.courseId != courseId) {
      return;
    }
    final chapters = result.data ?? const [];
    final defaultChapterId = chapters.isNotEmpty ? chapters.first.id : null;
    emitIfOpen(
      state.copyWith(
        isLoadingChapters: false,
        chapters: chapters,
        defaultChapterId: defaultChapterId,
        rows: _applyDefaultChapter(state.rows, defaultChapterId),
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
      state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true),
    );
    final result = await _questionBankService.createChapter(
      courseId: courseId,
      name: name,
      chapterOrder: chapterOrder,
    );
    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          isSubmitting: false,
          errorMessage: result.error?.message ?? 'chapterCreateFailed',
        ),
      );
      return;
    }
    final chapters = await _questionBankService.getChapters(courseId);
    emitIfOpen(
      state.copyWith(
        isSubmitting: false,
        chapters: chapters.data ?? state.chapters,
        defaultChapterId: result.data!.id,
        rows: _applyDefaultChapter(state.rows, result.data!.id),
        successMessage: 'chapterCreated',
      ),
    );
  }

  void selectDefaultChapter(int? chapterId) {
    emitIfOpen(
      state.copyWith(
        defaultChapterId: chapterId,
        clearDefaultChapter: chapterId == null,
      ),
    );
  }

  void addRow() {
    if (state.rows.length >= 50) {
      emitIfOpen(state.copyWith(errorMessage: 'bulkMaxRows'));
      return;
    }
    final nextId =
        state.rows.map((row) => row.localId).fold(0, (a, b) => a > b ? a : b) +
        1;
    emitIfOpen(
      state.copyWith(
        rows: [
          ...state.rows,
          QuestionBulkRowModel(
            localId: nextId,
            chapterId: state.defaultChapterId,
          ),
        ],
      ),
    );
  }

  void removeRow(int localId) {
    if (state.rows.length <= 1) return;
    emitIfOpen(
      state.copyWith(
        rows: state.rows.where((row) => row.localId != localId).toList(),
      ),
    );
  }

  void updateRow(QuestionBulkRowModel row) {
    emitIfOpen(
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
    final rows = state.rows.map((row) {
      if (row.localId != localId) return row;
      return row.copyWith(
        questionFileId: _nextPendingFileId(),
        questionImageLocalPath: path,
        questionImageUrl: null,
      );
    }).toList();
    emitIfOpen(
      state.copyWith(rows: rows, clearError: true, clearSuccess: true),
    );
  }

  Future<void> removeRowQuestionImage(int localId) async {
    final row = state.rows.firstWhere(
      (item) => item.localId == localId,
      orElse: () => QuestionBulkRowModel(localId: localId),
    );
    emitIfOpen(
      state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true),
    );
    if (row.questionFileId != null && row.questionFileId! > 0) {
      await _questionBankService.deleteUploadedFile(row.questionFileId!);
    }
    emitIfOpen(
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
    final uploaded = <QuestionAttachmentPayload>[];
    for (final path in paths) {
      uploaded.add(
        QuestionAttachmentPayload(
          fileId: _nextPendingFileId(),
          fileName: _fileNameFromPath(path),
          localPath: path,
        ),
      );
    }
    emitIfOpen(
      state.copyWith(
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
        clearError: true,
        clearSuccess: true,
      ),
    );
  }

  Future<void> removeRowAttachment({
    required int localId,
    required int fileId,
  }) async {
    if (fileId > 0) {
      await _questionBankService.deleteUploadedFile(fileId);
    }
    emitIfOpen(
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
    emitIfOpen(
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
      emitIfOpen(state.copyWith(errorMessage: 'courseRequired'));
      return false;
    }
    if (state.rows.length > 50) {
      emitIfOpen(state.copyWith(errorMessage: 'bulkMaxRows'));
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
      emitIfOpen(
        state.copyWith(
          rows: rows,
          errorMessage: 'bulkRowsInvalid',
          failedRows: rows.where((row) => row.error != null).toList(),
          failureReportMessage: 'bulkRowsInvalid',
        ),
      );
      return false;
    }
    emitIfOpen(
      state.copyWith(
        isSubmitting: true,
        rows: rows,
        clearError: true,
        clearFailureReport: true,
      ),
    );
    final uploadedByRowIndex = <int, List<int>>{};
    final preparedRows = await _uploadPendingRowsMedia(
      rows,
      uploadedByRowIndex,
    );
    if (preparedRows == null) {
      await _discardUploadedFiles(
        uploadedByRowIndex.values.expand((ids) => ids),
      );
      return false;
    }
    final result = await _questionBankService.bulkCreateQuestionsDetailed(
      courseId: courseId,
      questions: preparedRows
          .map((row) => row.toPayload(courseId: courseId))
          .toList(),
    );
    if (!result.isSuccess) {
      await _discardUploadedFiles(
        uploadedByRowIndex.values.expand((ids) => ids),
      );
      final message = result.error?.message ?? 'bulkCreateFailed';
      emitIfOpen(
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
    final failedIndexes = failureByRow.keys.toSet();
    await _discardUploadedFiles(
      failedIndexes.expand((index) => uploadedByRowIndex[index] ?? const []),
    );
    final allCreated = [...state.createdQuestions, ...?detailed?.created];
    emitIfOpen(
      state.copyWith(
        isSubmitting: false,
        successMessage: detailed?.hasFailures == true
            ? 'bulkCreatePartialSuccess'
            : 'bulkCreateSuccess',
        createdQuestions: allCreated,
        rows: detailed?.hasFailures == true
            ? failedRows
            : [
                QuestionBulkRowModel(
                  localId: 1,
                  chapterId: state.defaultChapterId,
                ),
              ],
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
    emitIfOpen(
      state.copyWith(
        rows: [
          QuestionBulkRowModel(localId: 1, chapterId: state.defaultChapterId),
        ],
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
      if (questionFileId != null && questionFileId > 0) {
        fileIds.add(questionFileId);
      }
      for (final attachment in row.attachments) {
        final fileId = attachment.fileId;
        if (fileId != null && fileId > 0) fileIds.add(fileId);
      }
    }
    for (final fileId in fileIds) {
      await _questionBankService.deleteUploadedFile(fileId);
    }
  }

  Future<bool> statusCreatedQuestions(String action) async {
    if (state.createdQuestions.isEmpty) return false;
    emitIfOpen(state.copyWith(isSubmitting: true, clearError: true));
    final result = await _questionBankService.batchStatusAction(
      questionIds: state.createdQuestions
          .map((question) => question.id)
          .toList(),
      action: action,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isSubmitting: false,
          errorMessage: result.error?.message ?? 'bulkStatusFailed',
        ),
      );
      return false;
    }
    emitIfOpen(
      state.copyWith(
        isSubmitting: false,
        createdQuestions: result.data ?? state.createdQuestions,
        successMessage: 'questionsBatchUpdated',
      ),
    );
    return true;
  }

  Future<bool> statusCreatedQuestion({
    required int questionId,
    required String action,
  }) async {
    emitIfOpen(state.copyWith(isSubmitting: true, clearError: true));
    final result = await _questionBankService.statusAction(
      questionId: questionId,
      action: action,
    );
    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          isSubmitting: false,
          errorMessage: result.error?.message ?? 'Failed to update question',
        ),
      );
      return false;
    }
    emitIfOpen(
      state.copyWith(
        isSubmitting: false,
        createdQuestions: state.createdQuestions
            .map(
              (question) => question.id == questionId ? result.data! : question,
            )
            .toList(),
        successMessage: 'Question saved',
      ),
    );
    return true;
  }

  List<QuestionBulkRowModel> _applyDefaultChapter(
    List<QuestionBulkRowModel> rows,
    int? chapterId,
  ) {
    if (chapterId == null) {
      return rows.map((row) => row.copyWith(clearChapter: true)).toList();
    }
    return rows.map((row) => row.copyWith(chapterId: chapterId)).toList();
  }

  Future<List<QuestionBulkRowModel>?> _uploadPendingRowsMedia(
    List<QuestionBulkRowModel> rows,
    Map<int, List<int>> uploadedByRowIndex,
  ) async {
    final preparedRows = <QuestionBulkRowModel>[];
    for (var index = 0; index < rows.length; index++) {
      final uploadedForRow = uploadedByRowIndex.putIfAbsent(
        index,
        () => <int>[],
      );
      final prepared = await _uploadPendingRowMedia(
        rows[index],
        uploadedForRow,
      );
      if (prepared == null) return null;
      preparedRows.add(prepared);
    }
    return preparedRows;
  }

  Future<QuestionBulkRowModel?> _uploadPendingRowMedia(
    QuestionBulkRowModel row,
    List<int> uploadedFileIds,
  ) async {
    var prepared = row;
    final questionLocalPath = row.questionImageLocalPath;
    if ((row.questionFileId == null || row.questionFileId! <= 0) &&
        questionLocalPath != null &&
        questionLocalPath.trim().isNotEmpty) {
      final result = await _questionBankService.uploadQuestionImage(
        questionLocalPath,
      );
      if (!result.isSuccess || result.data == null) {
        emitIfOpen(
          state.copyWith(
            isSubmitting: false,
            errorMessage: result.error?.message ?? 'questionImageUploadFailed',
          ),
        );
        return null;
      }
      final fileId = result.data!.fileId;
      uploadedFileIds.add(fileId);
      prepared = prepared.copyWith(questionFileId: fileId);
    }

    final attachments = <QuestionAttachmentPayload>[];
    for (final attachment in row.attachments) {
      var fileId = attachment.fileId;
      final localPath = attachment.localPath;
      if ((fileId == null || fileId <= 0) &&
          localPath != null &&
          localPath.trim().isNotEmpty) {
        final result = await _questionBankService.uploadQuestionImage(
          localPath,
        );
        if (!result.isSuccess || result.data == null) {
          emitIfOpen(
            state.copyWith(
              isSubmitting: false,
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
    return prepared.copyWith(attachments: attachments);
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
}
