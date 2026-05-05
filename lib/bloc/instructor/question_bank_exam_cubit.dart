import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/bloc/route_request_controller.dart';
import '../../models/core/paginated_response.dart';
import '../../models/instructor/question_bank_exam_models.dart';
import '../../services/api/enrollment_service.dart';
import '../../services/api/question_bank_exam_service.dart';
import 'question_bank_exam_state.dart';

class QuestionBankExamCubit extends Cubit<QuestionBankExamState>
    with SafeRouteCubitMixin<QuestionBankExamState> {
  QuestionBankExamCubit({
    required QuestionBankExamService service,
    required EnrollmentService enrollmentService,
  }) : _service = service,
       _enrollmentService = enrollmentService,
       super(const QuestionBankExamState());

  final QuestionBankExamService _service;
  final EnrollmentService _enrollmentService;

  late final RouteRequestController _loadRequest = trackRouteRequest(
    RouteRequestController(),
  );
  late final RouteRequestController _mutationRequest = trackRouteRequest(
    RouteRequestController(),
  );

  Future<void> loadInitial({int? preferredCourseId}) async {
    final requestId = _loadRequest.begin();
    emitIfOpen(
      state.copyWith(
        isLoading: true,
        clearError: true,
        clearSelectedQuestion: true,
        clearSelectedGroup: true,
        clearSelectedDraft: true,
        clearSelectedExam: true,
      ),
    );

    final coursesResult = await _enrollmentService.getTeachingCourses(
      cancelToken: _loadRequest.token,
    );
    if (!isRequestCurrent(_loadRequest, requestId)) return;

    if (!coursesResult.isSuccess || coursesResult.data == null) {
      emitIfOpen(
        state.copyWith(
          isLoading: false,
          errorMessage:
              coursesResult.error?.message ?? 'Failed to load teaching courses',
        ),
      );
      return;
    }

    final courses = coursesResult.data!;
    int? selectedCourseId = preferredCourseId;
    if (selectedCourseId == null ||
        !courses.any((item) => item.courseId == selectedCourseId)) {
      selectedCourseId = courses.isNotEmpty ? courses.first.courseId : null;
    }

    emitIfOpen(
      state.copyWith(
        teachingCourses: courses,
        selectedCourseId: selectedCourseId,
        isLoading: false,
        clearError: true,
      ),
    );

    if (selectedCourseId != null) {
      await refreshAll();
    }
  }

  Future<void> selectCourse(int? courseId) async {
    emitIfOpen(
      state.copyWith(
        selectedCourseId: courseId,
        chapters: const <CourseChapterModel>[],
        currentQuestionsPage: 1,
        currentGroupsPage: 1,
        currentExamsPage: 1,
        currentDraftsPage: 1,
        clearQuestions: true,
        clearGroups: true,
        clearExams: true,
        clearDrafts: true,
        clearSelectedQuestion: true,
        clearSelectedGroup: true,
        clearSelectedGroupQuestions: true,
        clearSelectedDraft: true,
        clearSelectedExam: true,
        clearError: true,
        clearSuccess: true,
      ),
    );
    await refreshAll();
  }

  Future<void> refreshAll() async {
    await Future.wait(<Future<void>>[
      loadChapters(),
      loadQuestions(page: 1),
      loadGroups(page: 1),
      loadExams(page: 1),
      loadDrafts(page: 1),
    ]);
  }

  Future<void> loadChapters() async {
    final courseId = state.selectedCourseId;
    if (courseId == null) return;
    final result = await _service.getChapters(
      courseId,
      cancelToken: _loadRequest.token,
    );
    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          errorMessage: result.error?.message ?? 'Failed to load chapters',
        ),
      );
      return;
    }
    emitIfOpen(state.copyWith(chapters: result.data!, clearError: true));
  }

  Future<void> loadQuestions({int page = 1, int limit = 20}) async {
    final courseId = state.selectedCourseId;
    emitIfOpen(state.copyWith(isLoading: true, clearError: true));
    final result = await _service.getQuestions(
      courseId: courseId,
      status: state.questionStatusFilter,
      questionType: state.questionTypeFilter,
      difficulty: state.difficultyFilter,
      bloomLevel: state.bloomFilter,
      search: state.searchQuery,
      hasAttachments: state.hasAttachmentsFilter,
      page: page,
      limit: limit,
      cancelToken: _loadRequest.token,
    );
    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          isLoading: false,
          errorMessage: result.error?.message ?? 'Failed to load questions',
        ),
      );
      return;
    }
    emitIfOpen(
      state.copyWith(
        questions: result.data!,
        currentQuestionsPage: page,
        isLoading: false,
        clearError: true,
      ),
    );
  }

  Future<void> loadGroups({int page = 1, int limit = 20}) async {
    final result = await _service.getGroups(
      courseId: state.selectedCourseId,
      page: page,
      limit: limit,
      cancelToken: _loadRequest.token,
    );
    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          errorMessage: result.error?.message ?? 'Failed to load groups',
        ),
      );
      return;
    }
    emitIfOpen(
      state.copyWith(
        groups: result.data!,
        currentGroupsPage: page,
        clearError: true,
      ),
    );
  }

  Future<void> loadQuestion(int questionId) async {
    emitIfOpen(
      state.copyWith(
        isLoading: true,
        clearError: true,
        clearSelectedQuestion: true,
      ),
    );
    final result = await _service.getQuestion(
      questionId,
      cancelToken: _loadRequest.token,
    );
    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          isLoading: false,
          errorMessage: result.error?.message ?? 'Failed to load question',
        ),
      );
      return;
    }
    emitIfOpen(
      state.copyWith(
        isLoading: false,
        selectedQuestion: result.data!,
        clearError: true,
      ),
    );
  }

  Future<bool> updateQuestion(int questionId, Map<String, dynamic> data) async {
    emitIfOpen(state.copyWith(isMutating: true, clearError: true));
    final result = await _service.updateQuestion(
      questionId,
      data,
      cancelToken: _mutationRequest.token,
    );
    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'Failed to update question',
        ),
      );
      return false;
    }
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        selectedQuestion: result.data!,
        successMessage: 'Question updated',
        clearError: true,
      ),
    );
    await loadQuestions(page: state.currentQuestionsPage);
    return true;
  }

  Future<void> loadGroup(int groupId) async {
    emitIfOpen(
      state.copyWith(
        isLoading: true,
        clearError: true,
        clearSelectedGroup: true,
        clearSelectedGroupQuestions: true,
      ),
    );
    final result = await _service.getGroup(
      groupId,
      cancelToken: _loadRequest.token,
    );
    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          isLoading: false,
          errorMessage: result.error?.message ?? 'Failed to load group',
        ),
      );
      return;
    }
    emitIfOpen(
      state.copyWith(
        isLoading: false,
        selectedGroup: result.data!,
        clearError: true,
      ),
    );
  }

  Future<void> loadGroupQuestions(int groupId) async {
    final result = await _service.getQuestions(
      courseId: state.selectedCourseId,
      groupId: groupId,
      page: 1,
      limit: 100,
      cancelToken: _loadRequest.token,
    );
    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          errorMessage:
              result.error?.message ?? 'Failed to load grouped questions',
        ),
      );
      return;
    }
    final questions = [...result.data!.data]
      ..sort(
        (a, b) =>
            (a.groupItemOrder ?? a.id).compareTo(b.groupItemOrder ?? b.id),
      );
    emitIfOpen(
      state.copyWith(selectedGroupQuestions: questions, clearError: true),
    );
  }

  Future<void> loadExams({int page = 1, int limit = 20}) async {
    final result = await _service.getExams(
      courseId: state.selectedCourseId,
      status: state.examStatusFilter,
      page: page,
      limit: limit,
      cancelToken: _loadRequest.token,
    );
    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          errorMessage: result.error?.message ?? 'Failed to load exams',
        ),
      );
      return;
    }
    emitIfOpen(
      state.copyWith(
        exams: result.data!,
        currentExamsPage: page,
        clearError: true,
      ),
    );
  }

  Future<void> loadExam(int examId) async {
    emitIfOpen(
      state.copyWith(
        isLoading: true,
        clearError: true,
        clearSelectedExam: true,
      ),
    );
    final result = await _service.getExam(
      examId,
      cancelToken: _loadRequest.token,
    );
    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          isLoading: false,
          errorMessage: result.error?.message ?? 'Failed to load exam',
        ),
      );
      return;
    }
    emitIfOpen(
      state.copyWith(
        isLoading: false,
        selectedExam: result.data!,
        clearError: true,
      ),
    );
  }

  Future<void> loadDrafts({int page = 1, int limit = 20}) async {
    final result = await _service.getDrafts(
      courseId: state.selectedCourseId,
      page: page,
      limit: limit,
      cancelToken: _loadRequest.token,
    );
    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          errorMessage: result.error?.message ?? 'Failed to load drafts',
        ),
      );
      return;
    }
    emitIfOpen(
      state.copyWith(
        drafts: result.data!,
        currentDraftsPage: page,
        clearError: true,
      ),
    );
  }

  Future<void> setQuestionFilters({
    QuestionBankStatus? status,
    QuestionBankQuestionType? questionType,
    QuestionBankDifficulty? difficulty,
    QuestionBankBloomLevel? bloomLevel,
    bool? hasAttachments,
    String? search,
    bool clearStatus = false,
    bool clearType = false,
    bool clearDifficulty = false,
    bool clearBloom = false,
    bool clearHasAttachments = false,
  }) async {
    emitIfOpen(
      state.copyWith(
        questionStatusFilter: status,
        questionTypeFilter: questionType,
        difficultyFilter: difficulty,
        bloomFilter: bloomLevel,
        hasAttachmentsFilter: hasAttachments,
        searchQuery: search,
        clearQuestionStatusFilter: clearStatus,
        clearQuestionTypeFilter: clearType,
        clearDifficultyFilter: clearDifficulty,
        clearBloomFilter: clearBloom,
        clearHasAttachmentsFilter: clearHasAttachments,
      ),
    );
    await loadQuestions(page: 1);
  }

  Future<void> setExamStatusFilter(ExamStatus? status) async {
    emitIfOpen(
      state.copyWith(
        examStatusFilter: status,
        clearExamStatusFilter: status == null,
      ),
    );
    await loadExams(page: 1);
  }

  Future<CourseChapterModel?> createChapter(String name) async {
    final courseId = state.selectedCourseId;
    if (courseId == null) return null;
    final nextOrder = state.chapters.isEmpty
        ? 1
        : state.chapters
                  .map((item) => item.chapterOrder)
                  .reduce((left, right) => left > right ? left : right) +
              1;
    emitIfOpen(state.copyWith(isMutating: true, clearError: true));
    final result = await _service.createChapter(
      courseId: courseId,
      name: name,
      chapterOrder: nextOrder,
      cancelToken: _mutationRequest.token,
    );
    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'Failed to create chapter',
        ),
      );
      return null;
    }
    final chapters = <CourseChapterModel>[...state.chapters, result.data!]
      ..sort((a, b) => a.chapterOrder.compareTo(b.chapterOrder));
    emitIfOpen(
      state.copyWith(
        chapters: chapters,
        isMutating: false,
        successMessage: 'Chapter created',
        clearError: true,
      ),
    );
    return result.data;
  }

  Future<CourseChapterModel?> updateChapter({
    required int chapterId,
    String? name,
    int? chapterOrder,
    int? isActive,
  }) async {
    final courseId = state.selectedCourseId;
    if (courseId == null) return null;
    emitIfOpen(state.copyWith(isMutating: true, clearError: true));
    final result = await _service.updateChapter(
      courseId: courseId,
      chapterId: chapterId,
      name: name,
      chapterOrder: chapterOrder,
      isActive: isActive,
      cancelToken: _mutationRequest.token,
    );
    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'Failed to update chapter',
        ),
      );
      return null;
    }
    final chapters =
        state.chapters
            .map((item) => item.id == chapterId ? result.data! : item)
            .toList()
          ..sort((a, b) => a.chapterOrder.compareTo(b.chapterOrder));
    emitIfOpen(
      state.copyWith(
        chapters: chapters,
        isMutating: false,
        successMessage: 'Chapter updated',
        clearError: true,
      ),
    );
    return result.data;
  }

  Future<bool> deleteChapter(int chapterId) async {
    final courseId = state.selectedCourseId;
    if (courseId == null) return false;
    emitIfOpen(state.copyWith(isMutating: true, clearError: true));
    final result = await _service.deleteChapter(
      courseId: courseId,
      chapterId: chapterId,
      cancelToken: _mutationRequest.token,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'Failed to delete chapter',
        ),
      );
      return false;
    }
    emitIfOpen(
      state.copyWith(
        chapters: state.chapters
            .where((item) => item.id != chapterId)
            .toList(growable: false),
        isMutating: false,
        successMessage: 'Chapter deleted',
        clearError: true,
      ),
    );
    return true;
  }

  Future<bool> createQuestion(Map<String, dynamic> data) async {
    emitIfOpen(state.copyWith(isMutating: true, clearError: true));
    final result = await _service.createQuestion(
      data,
      cancelToken: _mutationRequest.token,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'Failed to create question',
        ),
      );
      return false;
    }
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        successMessage: 'Question saved',
        clearError: true,
      ),
    );
    await loadQuestions(page: 1);
    return true;
  }

  Future<bool> createQuestionsBatch({
    int? defaultChapterId,
    required List<Map<String, dynamic>> questions,
  }) async {
    final courseId = state.selectedCourseId;
    if (courseId == null) return false;
    emitIfOpen(state.copyWith(isMutating: true, clearError: true));
    final result = await _service.createQuestionsBatch(
      courseId: courseId,
      defaultChapterId: defaultChapterId,
      questions: questions,
      cancelToken: _mutationRequest.token,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'Failed to create questions',
        ),
      );
      return false;
    }
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        successMessage: 'Questions saved',
        clearError: true,
      ),
    );
    await loadQuestions(page: 1);
    return true;
  }

  Future<bool> createGroup(Map<String, dynamic> data) async {
    emitIfOpen(state.copyWith(isMutating: true, clearError: true));
    final result = await _service.createGroup(
      data,
      cancelToken: _mutationRequest.token,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'Failed to create group',
        ),
      );
      return false;
    }
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        successMessage: 'Group created',
        clearError: true,
      ),
    );
    await loadGroups(page: 1);
    return true;
  }

  Future<bool> updateGroup(int groupId, Map<String, dynamic> data) async {
    emitIfOpen(state.copyWith(isMutating: true, clearError: true));
    final result = await _service.updateGroup(
      groupId,
      data,
      cancelToken: _mutationRequest.token,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'Failed to update group',
        ),
      );
      return false;
    }
    emitIfOpen(state.copyWith(isMutating: false, clearError: true));
    await loadGroups(page: state.currentGroupsPage);
    await loadGroup(groupId);
    return true;
  }

  Future<bool> deleteGroup(int groupId) async {
    emitIfOpen(state.copyWith(isMutating: true, clearError: true));
    final result = await _service.deleteGroup(
      groupId,
      cancelToken: _mutationRequest.token,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'Failed to delete group',
        ),
      );
      return false;
    }
    emitIfOpen(state.copyWith(isMutating: false, clearError: true));
    await loadGroups(page: 1);
    return true;
  }

  Future<bool> reorderGroupQuestions({
    required int groupId,
    required List<int> questionIds,
  }) async {
    emitIfOpen(state.copyWith(isMutating: true, clearError: true));
    final result = await _service.reorderGroupQuestions(
      groupId: groupId,
      questionIds: questionIds,
      cancelToken: _mutationRequest.token,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage:
              result.error?.message ?? 'Failed to reorder grouped questions',
        ),
      );
      return false;
    }
    emitIfOpen(state.copyWith(isMutating: false, clearError: true));
    await loadGroups(page: state.currentGroupsPage);
    await loadGroupQuestions(groupId);
    return true;
  }

  Future<int?> uploadQuestionImage(File image) async {
    emitIfOpen(state.copyWith(isMutating: true, clearError: true));
    final result = await _service.uploadQuestionImage(
      image,
      cancelToken: _mutationRequest.token,
    );
    final fileId = _readNullableInt(result.data, const <String>[
      'fileId',
      'id',
      'driveFileId',
    ]);
    if (!result.isSuccess || fileId == null) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage:
              result.error?.message ?? 'Failed to upload question image',
        ),
      );
      return null;
    }
    emitIfOpen(state.copyWith(isMutating: false, clearError: true));
    return fileId;
  }

  Future<bool> createGroupQuestionsBatch({
    required int groupId,
    required List<Map<String, dynamic>> questions,
  }) async {
    emitIfOpen(state.copyWith(isMutating: true, clearError: true));
    final result = await _service.createGroupQuestionsBatch(
      groupId: groupId,
      questions: questions,
      cancelToken: _mutationRequest.token,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage:
              result.error?.message ?? 'Failed to create grouped questions',
        ),
      );
      return false;
    }
    emitIfOpen(state.copyWith(isMutating: false, clearError: true));
    await Future.wait(<Future<void>>[
      loadGroups(page: state.currentGroupsPage),
      loadQuestions(page: 1),
    ]);
    return true;
  }

  Future<void> questionAction(
    QuestionBankQuestionModel question,
    String action,
  ) async {
    emitIfOpen(state.copyWith(isMutating: true, clearError: true));
    final result = switch (action) {
      'approve' => await _service.approveQuestion(question.id),
      'reject' => await _service.rejectQuestion(question.id),
      'submit' => await _service.submitQuestionForReview(question.id),
      'restore' => await _service.restoreQuestion(question.id),
      'archive' => await _service.archiveQuestion(question.id),
      _ => null,
    };
    if (result == null || !result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result?.error?.message ?? 'Failed to update question',
        ),
      );
      return;
    }
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        successMessage: 'Question updated',
        clearError: true,
      ),
    );
    await loadQuestions(page: state.currentQuestionsPage);
  }

  Future<bool> addQuestionAttachment({
    required int questionId,
    required int fileId,
    required String attachmentType,
    String? caption,
    String? altText,
    bool isPrimary = false,
  }) async {
    emitIfOpen(state.copyWith(isMutating: true, clearError: true));
    final result = await _service.addQuestionAttachment(
      questionId: questionId,
      fileId: fileId,
      attachmentType: attachmentType,
      caption: caption,
      altText: altText,
      isPrimary: isPrimary,
      cancelToken: _mutationRequest.token,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'Failed to add attachment',
        ),
      );
      return false;
    }
    emitIfOpen(state.copyWith(isMutating: false, clearError: true));
    await loadQuestions(page: state.currentQuestionsPage);
    return true;
  }

  Future<bool> uploadQuestionAttachmentImage({
    required int questionId,
    required File image,
    String? caption,
    String? altText,
    bool isPrimary = false,
  }) async {
    emitIfOpen(state.copyWith(isMutating: true, clearError: true));
    final result = await _service.uploadQuestionAttachmentImage(
      questionId: questionId,
      image: image,
      caption: caption,
      altText: altText,
      isPrimary: isPrimary,
      cancelToken: _mutationRequest.token,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage:
              result.error?.message ?? 'Failed to upload attachment image',
        ),
      );
      return false;
    }
    emitIfOpen(state.copyWith(isMutating: false, clearError: true));
    await loadQuestion(questionId);
    await loadQuestions(page: state.currentQuestionsPage);
    return true;
  }

  Future<bool> updateQuestionAttachment({
    required int questionId,
    required int attachmentId,
    String? caption,
    String? altText,
    bool? isPrimary,
  }) async {
    emitIfOpen(state.copyWith(isMutating: true, clearError: true));
    final result = await _service.updateQuestionAttachment(
      questionId: questionId,
      attachmentId: attachmentId,
      caption: caption,
      altText: altText,
      isPrimary: isPrimary,
      cancelToken: _mutationRequest.token,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'Failed to update attachment',
        ),
      );
      return false;
    }
    emitIfOpen(state.copyWith(isMutating: false, clearError: true));
    await loadQuestion(questionId);
    await loadQuestions(page: state.currentQuestionsPage);
    return true;
  }

  Future<bool> reorderQuestionAttachments({
    required int questionId,
    required List<int> attachmentIds,
  }) async {
    emitIfOpen(state.copyWith(isMutating: true, clearError: true));
    final result = await _service.reorderQuestionAttachments(
      questionId: questionId,
      attachmentIds: attachmentIds,
      cancelToken: _mutationRequest.token,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage:
              result.error?.message ?? 'Failed to reorder attachments',
        ),
      );
      return false;
    }
    emitIfOpen(state.copyWith(isMutating: false, clearError: true));
    await loadQuestion(questionId);
    await loadQuestions(page: state.currentQuestionsPage);
    return true;
  }

  Future<bool> deleteQuestionAttachment({
    required int questionId,
    required int attachmentId,
  }) async {
    emitIfOpen(state.copyWith(isMutating: true, clearError: true));
    final result = await _service.deleteQuestionAttachment(
      questionId: questionId,
      attachmentId: attachmentId,
      cancelToken: _mutationRequest.token,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'Failed to delete attachment',
        ),
      );
      return false;
    }
    emitIfOpen(state.copyWith(isMutating: false, clearError: true));
    await loadQuestions(page: state.currentQuestionsPage);
    return true;
  }

  Future<ExamDraftModel?> generateDraft(Map<String, dynamic> data) async {
    emitIfOpen(
      state.copyWith(
        isMutating: true,
        clearError: true,
        clearGenerationShortages: true,
      ),
    );
    final result = await _service.generatePreview(
      data,
      cancelToken: _mutationRequest.token,
    );
    if (!result.isSuccess || result.data == null) {
      final shortages = _readGenerationShortages(result.error?.originalError);
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'Failed to generate draft',
          generationShortages: shortages,
        ),
      );
      return null;
    }
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        selectedDraft: result.data!,
        successMessage: 'Draft generated',
        clearError: true,
        clearGenerationShortages: true,
      ),
    );
    await loadDrafts(page: 1);
    return result.data;
  }

  Future<void> loadDraft(int draftId) async {
    emitIfOpen(state.copyWith(isLoading: true, clearError: true));
    final result = await _service.getDraft(
      draftId,
      cancelToken: _loadRequest.token,
    );
    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          isLoading: false,
          errorMessage: result.error?.message ?? 'Failed to load draft',
        ),
      );
      return;
    }
    emitIfOpen(
      state.copyWith(
        selectedDraft: result.data!,
        isLoading: false,
        clearError: true,
      ),
    );
  }

  Future<bool> addDraftItem({
    required int draftId,
    required int questionId,
    int? draftSectionId,
    double? weightUnits,
    double? marks,
    String? overrideReason,
  }) async {
    emitIfOpen(state.copyWith(isMutating: true, clearError: true));
    final result = await _service.addDraftItem(
      draftId: draftId,
      questionId: questionId,
      draftSectionId: draftSectionId,
      weightUnits: weightUnits,
      marks: marks,
      overrideReason: overrideReason,
      cancelToken: _mutationRequest.token,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'Failed to add item',
        ),
      );
      return false;
    }
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        successMessage: 'Draft item added',
        clearError: true,
      ),
    );
    await loadDraft(draftId);
    return true;
  }

  Future<void> updateDraftItemMarks({
    required int draftId,
    required ExamDraftItemModel item,
    required double marks,
  }) async {
    emitIfOpen(state.copyWith(isMutating: true, clearError: true));
    final result = await _service.updateDraftItem(
      draftId: draftId,
      itemId: item.id,
      weight: marks,
      weightUnits: marks,
      marks: marks,
      cancelToken: _mutationRequest.token,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'Failed to update item',
        ),
      );
      return;
    }
    emitIfOpen(state.copyWith(isMutating: false, clearError: true));
    await loadDraft(draftId);
  }

  Future<bool> addDraftSection({
    required int draftId,
    required String title,
    String? instructions,
    double? totalMarks,
    ExamSectionAnswerPolicy answerPolicy = ExamSectionAnswerPolicy.answerAll,
    int? requiredAnswerCount,
  }) async {
    emitIfOpen(state.copyWith(isMutating: true, clearError: true));
    final result = await _service.addDraftSection(
      draftId: draftId,
      title: title,
      instructions: instructions,
      totalMarks: totalMarks,
      answerPolicy: answerPolicy,
      requiredAnswerCount: requiredAnswerCount,
      cancelToken: _mutationRequest.token,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'Failed to add draft section',
        ),
      );
      return false;
    }
    emitIfOpen(state.copyWith(isMutating: false, clearError: true));
    await loadDraft(draftId);
    return true;
  }

  Future<bool> updateDraftSection({
    required int draftId,
    required int sectionId,
    required String title,
    String? instructions,
    double? totalMarks,
    ExamSectionAnswerPolicy? answerPolicy,
    int? requiredAnswerCount,
  }) async {
    emitIfOpen(state.copyWith(isMutating: true, clearError: true));
    final result = await _service.updateDraftSection(
      draftId: draftId,
      sectionId: sectionId,
      title: title,
      instructions: instructions,
      totalMarks: totalMarks,
      answerPolicy: answerPolicy,
      requiredAnswerCount: requiredAnswerCount,
      cancelToken: _mutationRequest.token,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage:
              result.error?.message ?? 'Failed to update draft section',
        ),
      );
      return false;
    }
    emitIfOpen(state.copyWith(isMutating: false, clearError: true));
    await loadDraft(draftId);
    return true;
  }

  Future<bool> deleteDraftSection({
    required int draftId,
    required int sectionId,
  }) async {
    emitIfOpen(state.copyWith(isMutating: true, clearError: true));
    final result = await _service.deleteDraftSection(
      draftId: draftId,
      sectionId: sectionId,
      cancelToken: _mutationRequest.token,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage:
              result.error?.message ?? 'Failed to delete draft section',
        ),
      );
      return false;
    }
    emitIfOpen(state.copyWith(isMutating: false, clearError: true));
    await loadDraft(draftId);
    return true;
  }

  Future<bool> reorderDraftSections({
    required int draftId,
    required List<int> sectionIds,
  }) async {
    emitIfOpen(state.copyWith(isMutating: true, clearError: true));
    final result = await _service.reorderDraftSections(
      draftId: draftId,
      sectionIds: sectionIds,
      cancelToken: _mutationRequest.token,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage:
              result.error?.message ?? 'Failed to reorder draft sections',
        ),
      );
      return false;
    }
    emitIfOpen(state.copyWith(isMutating: false, clearError: true));
    await loadDraft(draftId);
    return true;
  }

  Future<bool> reorderDraftItems({
    required int draftId,
    required List<int> itemIds,
  }) async {
    emitIfOpen(state.copyWith(isMutating: true, clearError: true));
    final result = await _service.reorderDraftItems(
      draftId: draftId,
      itemIds: itemIds,
      cancelToken: _mutationRequest.token,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage:
              result.error?.message ?? 'Failed to reorder draft items',
        ),
      );
      return false;
    }
    emitIfOpen(state.copyWith(isMutating: false, clearError: true));
    await loadDraft(draftId);
    return true;
  }

  Future<bool> replaceDraftItem({
    required int draftId,
    required ExamDraftItemModel item,
    required int replacementQuestionId,
    String? overrideReason,
  }) async {
    emitIfOpen(state.copyWith(isMutating: true, clearError: true));
    final result = await _service.updateDraftItem(
      draftId: draftId,
      itemId: item.id,
      replacementQuestionId: replacementQuestionId,
      overrideReason: overrideReason,
      cancelToken: _mutationRequest.token,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'Failed to replace item',
        ),
      );
      return false;
    }
    emitIfOpen(state.copyWith(isMutating: false, clearError: true));
    await loadDraft(draftId);
    return true;
  }

  Future<void> removeDraftItem(int draftId, ExamDraftItemModel item) async {
    if ((state.selectedDraft?.items.length ?? 0) <= 1) {
      emitIfOpen(
        state.copyWith(errorMessage: 'A draft must keep at least one item'),
      );
      return;
    }
    emitIfOpen(state.copyWith(isMutating: true, clearError: true));
    final result = await _service.removeDraftItem(
      draftId,
      item.id,
      cancelToken: _mutationRequest.token,
    );
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'Failed to remove item',
        ),
      );
      return;
    }
    emitIfOpen(state.copyWith(isMutating: false, clearError: true));
    await loadDraft(draftId);
  }

  Future<ExamResponseModel?> saveDraft(int draftId) async {
    emitIfOpen(state.copyWith(isMutating: true, clearError: true));
    final result = await _service.saveDraft(
      draftId,
      cancelToken: _mutationRequest.token,
    );
    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'Failed to save draft',
        ),
      );
      return null;
    }
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        selectedExam: result.data!,
        successMessage: 'Exam saved',
        clearError: true,
      ),
    );
    await loadExams(page: 1);
    await loadDrafts(page: 1);
    return result.data;
  }

  Future<void> examLifecycle(ExamResponseModel exam, String action) async {
    emitIfOpen(state.copyWith(isMutating: true, clearError: true));
    final result = switch (action) {
      'publish' => await _service.publishExam(exam.id),
      'unpublish' => await _service.unpublishExam(exam.id),
      'archive' => await _service.archiveExam(exam.id),
      _ => null,
    };
    if (result == null || !result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result?.error?.message ?? 'Failed to update exam',
        ),
      );
      return;
    }
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        successMessage: 'Exam updated',
        clearError: true,
      ),
    );
    await loadExams(page: state.currentExamsPage);
  }

  Future<ExamExportModel?> exportWord(
    int examId, {
    bool includeAnswerKey = true,
  }) async {
    emitIfOpen(state.copyWith(isMutating: true, clearError: true));
    final result = await _service.exportWord(
      examId,
      includeAnswerKey: includeAnswerKey,
      cancelToken: _mutationRequest.token,
    );
    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          isMutating: false,
          errorMessage: result.error?.message ?? 'Failed to export exam',
        ),
      );
      return null;
    }
    emitIfOpen(
      state.copyWith(
        isMutating: false,
        successMessage: 'Export ready',
        clearError: true,
      ),
    );
    return result.data;
  }

  static PaginatedResponse<T> emptyPage<T>() {
    return PaginatedResponse<T>(
      data: <T>[],
      total: 0,
      page: 1,
      limit: 20,
      totalPages: 0,
    );
  }
}

int? _readNullableInt(Map<String, dynamic>? source, List<String> keys) {
  if (source == null) return null;
  for (final key in keys) {
    final value = source[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
  }
  return null;
}

List<String> _readGenerationShortages(Object? originalError) {
  if (originalError is! DioException) return const <String>[];
  final data = originalError.response?.data;
  if (data is! Map<String, dynamic>) return const <String>[];
  final message = data['message'];
  final shortageSource = message is Map<String, dynamic>
      ? message['shortages']
      : data['shortages'];
  if (shortageSource is! List) return const <String>[];
  return shortageSource
      .whereType<Map>()
      .map((item) {
        final section = item['section']?.toString();
        final chapterId = item['chapterId']?.toString();
        final required = item['required']?.toString();
        final available = item['available']?.toString();
        final type = item['questionType']?.toString();
        final difficulty = item['difficulty']?.toString();
        final bloom = item['bloomLevel']?.toString();
        final parts = <String>[
          if (section != null && section.isNotEmpty) section,
          if (chapterId != null && chapterId.isNotEmpty) '#$chapterId',
          if (type != null && type.isNotEmpty) type,
          if (difficulty != null && difficulty.isNotEmpty) difficulty,
          if (bloom != null && bloom.isNotEmpty) bloom,
          if (required != null &&
              required.isNotEmpty &&
              available != null &&
              available.isNotEmpty)
            '$available/$required',
        ];
        return parts.join(' • ');
      })
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}
