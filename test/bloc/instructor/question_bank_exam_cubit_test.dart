import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/instructor/question_bank_exam_cubit.dart';
import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/models/core/course_model.dart';
import 'package:edu_verse/models/core/enums/course_enums.dart';
import 'package:edu_verse/models/core/paginated_response.dart';
import 'package:edu_verse/models/core/section_model.dart';
import 'package:edu_verse/models/core/semester_model.dart';
import 'package:edu_verse/models/instructor/question_bank_exam_models.dart';
import 'package:edu_verse/models/instructor/teaching_course_model.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/enrollment_service.dart';
import 'package:edu_verse/services/api/question_bank_exam_service.dart';

void main() {
  group('QuestionBankExamCubit', () {
    test(
      'loads instructor course and sends question filters to backend',
      () async {
        final service = _FakeQuestionBankExamService();
        final cubit = _buildCubit(service);

        await cubit.loadInitial();
        service.questionRequests.clear();
        await cubit.setQuestionFilters(
          status: QuestionBankStatus.approved,
          hasAttachments: false,
          search: 'graphs',
        );

        expect(cubit.state.selectedCourseId, 10);
        expect(cubit.state.questionStatusFilter, QuestionBankStatus.approved);
        expect(cubit.state.hasAttachmentsFilter, isFalse);
        expect(service.questionRequests.single, <String, dynamic>{
          'courseId': 10,
          'status': QuestionBankStatus.approved,
          'questionType': null,
          'difficulty': null,
          'bloomLevel': null,
          'search': 'graphs',
          'hasAttachments': false,
          'page': 1,
          'limit': 20,
        });

        await cubit.close();
      },
    );

    test('preserves structured generation shortages in state', () async {
      final service = _FakeQuestionBankExamService()
        ..generateResult = ServiceResult<ExamDraftModel>.failure(
          ServiceError(
            type: ServiceErrorType.server,
            statusCode: 400,
            message: 'Failed to generate draft',
            originalError: DioException(
              requestOptions: RequestOptions(path: '/exams/generate-preview'),
              response: Response<Map<String, dynamic>>(
                requestOptions: RequestOptions(path: '/exams/generate-preview'),
                statusCode: 400,
                data: <String, dynamic>{
                  'message': <String, dynamic>{
                    'message': 'Insufficient question pool',
                    'shortages': <Map<String, dynamic>>[
                      <String, dynamic>{
                        'section': 'Part A',
                        'chapterId': 2,
                        'required': 5,
                        'available': 2,
                        'questionType': 'mcq',
                        'difficulty': 'easy',
                      },
                    ],
                  },
                },
              ),
            ),
          ),
        );
      final cubit = _buildCubit(service);

      final draft = await cubit.generateDraft(<String, dynamic>{});

      expect(draft, isNull);
      expect(cubit.state.generationShortages, hasLength(1));
      expect(cubit.state.generationShortages.single, contains('Part A'));
      expect(cubit.state.generationShortages.single, contains('2/5'));

      await cubit.close();
    });

    test(
      'successful create question refreshes list and reports success',
      () async {
        final service = _FakeQuestionBankExamService();
        final cubit = _buildCubit(service);
        await cubit.loadInitial();

        final payload = QuestionBankExamService.buildQuestionPayload(
          courseId: 10,
          chapterId: 2,
          questionType: QuestionBankQuestionType.written,
          difficulty: QuestionBankDifficulty.medium,
          bloomLevel: QuestionBankBloomLevel.understand,
          questionText: 'Define a graph.',
          expectedAnswerText: 'A set of vertices and edges.',
        );
        final saved = await cubit.createQuestion(payload);

        expect(saved, isTrue);
        expect(service.createdQuestionPayload, payload);
        expect(cubit.state.successMessage, 'Question saved');
        expect(service.questionRequests.last['page'], 1);

        await cubit.close();
      },
    );

    test('does not remove the last draft item locally', () async {
      final service = _FakeQuestionBankExamService()
        ..draftResult = ServiceResult<ExamDraftModel>.success(
          _draftWithItems(<ExamDraftItemModel>[_draftItem(1)]),
        );
      final cubit = _buildCubit(service);

      await cubit.loadDraft(44);
      await cubit.removeDraftItem(44, _draftItem(1));

      expect(service.removeDraftItemCalls, 0);
      expect(cubit.state.errorMessage, 'A draft must keep at least one item');

      await cubit.close();
    });
  });
}

QuestionBankExamCubit _buildCubit(_FakeQuestionBankExamService service) {
  return QuestionBankExamCubit(
    service: service,
    enrollmentService: _FakeEnrollmentService(),
  );
}

class _FakeEnrollmentService extends EnrollmentService {
  _FakeEnrollmentService() : super(coreApiClient: CoreApiClient.test());

  @override
  Future<ServiceResult<List<TeachingCourseModel>>> getTeachingCourses({
    CancelToken? cancelToken,
  }) async {
    return ServiceResult<List<TeachingCourseModel>>.success(
      <TeachingCourseModel>[_teachingCourse()],
    );
  }
}

class _FakeQuestionBankExamService extends QuestionBankExamService {
  _FakeQuestionBankExamService() : super(coreApiClient: CoreApiClient.test());

  final List<Map<String, dynamic>> questionRequests = <Map<String, dynamic>>[];
  Map<String, dynamic>? createdQuestionPayload;
  int removeDraftItemCalls = 0;

  ServiceResult<ExamDraftModel> generateResult =
      ServiceResult<ExamDraftModel>.success(
        _draftWithItems(<ExamDraftItemModel>[_draftItem(1), _draftItem(2)]),
      );
  ServiceResult<ExamDraftModel> draftResult =
      ServiceResult<ExamDraftModel>.success(
        _draftWithItems(<ExamDraftItemModel>[_draftItem(1), _draftItem(2)]),
      );

  @override
  Future<ServiceResult<List<CourseChapterModel>>> getChapters(
    int courseId, {
    CancelToken? cancelToken,
  }) async {
    return ServiceResult<List<CourseChapterModel>>.success(
      const <CourseChapterModel>[
        CourseChapterModel(
          id: 2,
          courseId: 10,
          name: 'Graphs',
          chapterOrder: 1,
        ),
      ],
    );
  }

  @override
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
  }) async {
    questionRequests.add(<String, dynamic>{
      'courseId': courseId,
      'status': status,
      'questionType': questionType,
      'difficulty': difficulty,
      'bloomLevel': bloomLevel,
      'search': search,
      'hasAttachments': hasAttachments,
      'page': page,
      'limit': limit,
    });
    return ServiceResult<PaginatedResponse<QuestionBankQuestionModel>>.success(
      PaginatedResponse<QuestionBankQuestionModel>(
        data: <QuestionBankQuestionModel>[_question()],
        total: 1,
        page: page,
        limit: limit,
        totalPages: 1,
      ),
    );
  }

  @override
  Future<ServiceResult<QuestionBankQuestionModel>> createQuestion(
    Map<String, dynamic> data, {
    CancelToken? cancelToken,
  }) async {
    createdQuestionPayload = data;
    return ServiceResult<QuestionBankQuestionModel>.success(_question(id: 77));
  }

  @override
  Future<ServiceResult<PaginatedResponse<QuestionBankGroupModel>>> getGroups({
    int? courseId,
    int? chapterId,
    int page = 1,
    int limit = 20,
    CancelToken? cancelToken,
  }) async {
    return ServiceResult<PaginatedResponse<QuestionBankGroupModel>>.success(
      PaginatedResponse<QuestionBankGroupModel>(
        data: const <QuestionBankGroupModel>[],
        total: 0,
        page: page,
        limit: limit,
        totalPages: 0,
      ),
    );
  }

  @override
  Future<ServiceResult<PaginatedResponse<ExamResponseModel>>> getExams({
    int? courseId,
    ExamStatus? status,
    int page = 1,
    int limit = 20,
    CancelToken? cancelToken,
  }) async {
    return ServiceResult<PaginatedResponse<ExamResponseModel>>.success(
      PaginatedResponse<ExamResponseModel>(
        data: const <ExamResponseModel>[],
        total: 0,
        page: page,
        limit: limit,
        totalPages: 0,
      ),
    );
  }

  @override
  Future<ServiceResult<PaginatedResponse<ExamDraftModel>>> getDrafts({
    int? courseId,
    ExamDraftStatus? status,
    int page = 1,
    int limit = 20,
    CancelToken? cancelToken,
  }) async {
    return ServiceResult<PaginatedResponse<ExamDraftModel>>.success(
      PaginatedResponse<ExamDraftModel>(
        data: const <ExamDraftModel>[],
        total: 0,
        page: page,
        limit: limit,
        totalPages: 0,
      ),
    );
  }

  @override
  Future<ServiceResult<ExamDraftModel>> generatePreview(
    Map<String, dynamic> data, {
    CancelToken? cancelToken,
  }) async {
    return generateResult;
  }

  @override
  Future<ServiceResult<ExamDraftModel>> getDraft(
    int draftId, {
    CancelToken? cancelToken,
  }) async {
    return draftResult;
  }

  @override
  Future<ServiceResult<void>> removeDraftItem(
    int draftId,
    int itemId, {
    CancelToken? cancelToken,
  }) async {
    removeDraftItemCalls += 1;
    return ServiceResult<void>.success(null);
  }
}

TeachingCourseModel _teachingCourse() {
  return const TeachingCourseModel(
    sectionId: 30,
    courseId: 10,
    course: CourseModel(
      id: 10,
      departmentId: 1,
      code: 'CS101',
      name: 'Data Structures',
      credits: 3,
      courseLevel: CourseLevel.freshman,
      courseStatus: CourseStatus.active,
    ),
    section: SectionModel(
      id: 30,
      courseId: 10,
      semesterId: 1,
      sectionNumber: 'A',
      maxCapacity: 40,
      currentEnrollment: 20,
      sectionStatus: SectionStatus.open,
    ),
    semester: SemesterModel(id: 1, name: 'Spring'),
  );
}

QuestionBankQuestionModel _question({int id = 1}) {
  return QuestionBankQuestionModel(
    id: id,
    courseId: 10,
    chapterId: 2,
    questionType: QuestionBankQuestionType.written,
    difficulty: QuestionBankDifficulty.medium,
    bloomLevel: QuestionBankBloomLevel.understand,
    status: QuestionBankStatus.approved,
    questionText: 'Define a graph.',
    expectedAnswerText: 'A set of vertices and edges.',
  );
}

ExamDraftModel _draftWithItems(List<ExamDraftItemModel> items) {
  return ExamDraftModel(
    id: 44,
    courseId: 10,
    title: 'Midterm',
    status: ExamDraftStatus.open,
    items: items,
  );
}

ExamDraftItemModel _draftItem(int id) {
  return ExamDraftItemModel(
    id: id,
    questionId: id + 100,
    chapterId: 2,
    questionType: QuestionBankQuestionType.written,
    difficulty: QuestionBankDifficulty.medium,
    bloomLevel: QuestionBankBloomLevel.understand,
    weight: 1,
    weightUnits: 1,
    itemOrder: id - 1,
  );
}
