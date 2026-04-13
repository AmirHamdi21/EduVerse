import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/instructor/instructor_assignments_cubit.dart';
import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/models/assignments/assignment_form_data.dart';
import 'package:edu_verse/models/assignments/assignment_model.dart';
import 'package:edu_verse/models/assignments/assignment_submission_model.dart';
import 'package:edu_verse/models/core/enums/assignment_enums.dart' as api;
import 'package:edu_verse/models/core/paginated_response.dart';
import 'package:edu_verse/models/core/shared_models.dart';
import 'package:edu_verse/models/instructor/teaching_course_model.dart';
import 'package:edu_verse/services/api/assignment_service.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/enrollment_service.dart';

class _FakeEnrollmentService extends EnrollmentService {
  _FakeEnrollmentService(this.courses)
    : super(coreApiClient: CoreApiClient.test());

  final List<TeachingCourseModel> courses;

  @override
  Future<ServiceResult<List<TeachingCourseModel>>> getTeachingCourses() async {
    return ServiceResult<List<TeachingCourseModel>>.success(courses);
  }
}

class _FakeAssignmentService extends AssignmentService {
  _FakeAssignmentService({
    required this.assignments,
    this.createdAssignment,
    this.statusUpdatedAssignment,
    this.submissions = const <AssignmentSubmissionModel>[],
  }) : super(coreApiClient: CoreApiClient.test());

  final List<AssignmentModel> assignments;
  final AssignmentModel? createdAssignment;
  final AssignmentModel? statusUpdatedAssignment;
  final List<AssignmentSubmissionModel> submissions;

  int? lastGradedAssignmentId;
  int? lastGradedSubmissionId;
  double? lastGradedScore;
  String? lastGradedFeedback;

  @override
  Future<ServiceResult<PaginatedResponse<AssignmentModel>>> getAll({
    int? courseId,
    int? sectionId,
    api.AssignmentStatus? status,
    String? search,
    int? page,
    int? limit,
    String? sortBy,
    String? sortOrder,
  }) async {
    return ServiceResult<PaginatedResponse<AssignmentModel>>.success(
      PaginatedResponse<AssignmentModel>(
        data: assignments,
        total: assignments.length,
        page: page ?? 1,
        limit: limit ?? assignments.length,
        totalPages: 1,
      ),
    );
  }

  @override
  Future<ServiceResult<AssignmentModel>> create(
    Map<String, dynamic> data,
  ) async {
    return ServiceResult<AssignmentModel>.success(
      createdAssignment ?? assignments.first,
    );
  }

  @override
  Future<ServiceResult<AssignmentModel>> updateStatus(
    dynamic id,
    api.AssignmentStatus status,
  ) async {
    return ServiceResult<AssignmentModel>.success(
      statusUpdatedAssignment ?? assignments.first,
    );
  }

  @override
  Future<ServiceResult<List<AssignmentSubmissionModel>>> getSubmissions(
    dynamic assignmentId,
  ) async {
    return ServiceResult<List<AssignmentSubmissionModel>>.success(submissions);
  }

  @override
  Future<ServiceResult<Map<String, dynamic>>> gradeSubmission(
    dynamic assignmentId,
    dynamic submissionId,
    double score, {
    String? feedback,
  }) async {
    lastGradedAssignmentId = assignmentId as int;
    lastGradedSubmissionId = submissionId as int;
    lastGradedScore = score;
    lastGradedFeedback = feedback;
    return ServiceResult<Map<String, dynamic>>.success(<String, dynamic>{
      'ok': true,
    });
  }
}

TeachingCourseModel _teachingCourse() {
  return TeachingCourseModel.fromJson(<String, dynamic>{
    'sectionId': 12,
    'userId': 2,
    'courseId': 99,
    'role': 'instructor',
    'course': <String, dynamic>{
      'id': 99,
      'departmentId': 1,
      'code': 'CS999',
      'name': 'Advanced Engineering',
      'credits': 3,
      'level': 'senior',
      'status': 'active',
    },
    'section': <String, dynamic>{
      'id': 12,
      'courseId': 99,
      'semesterId': 3,
      'sectionNumber': 'A',
      'maxCapacity': 30,
      'currentEnrollment': 25,
      'status': 'active',
    },
    'semester': <String, dynamic>{
      'id': 3,
      'name': 'Fall 2026',
      'term': 'fall',
      'year': 2026,
    },
  });
}

AssignmentModel _assignment({
  required int id,
  required String title,
  api.AssignmentStatus apiStatus = api.AssignmentStatus.draft,
}) {
  return AssignmentModel(
    id: id.toString(),
    assignmentId: id,
    courseId: 99,
    title: title,
    description: 'desc $title',
    courseName: 'Advanced Engineering',
    courseCode: 'CS999',
    instructorName: 'Dr. Test',
    type: AssignmentType.document,
    status: AssignmentStatus.pending,
    priority: AssignmentPriority.medium,
    dueDate: DateTime(2026, 6, 1),
    maxGrade: 100,
    createdAt: DateTime(2026, 1, 1),
    apiStatus: apiStatus,
    submissionType: api.SubmissionType.file,
    lateSubmissionAllowed: true,
    maxFileSizeMb: 10,
  );
}

AssignmentSubmissionModel _submission({
  required int id,
  required int assignmentId,
  api.SubmissionStatus status = api.SubmissionStatus.submitted,
  bool isLate = false,
  double? score,
  String? feedback,
  String? firstName,
  String? lastName,
}) {
  return AssignmentSubmissionModel(
    id: id,
    assignmentId: assignmentId,
    userId: id + 100,
    submissionStatus: status,
    isLate: isLate,
    attemptNumber: 1,
    submittedAt: DateTime(2026, 5, id),
    score: score,
    feedback: feedback,
    user: UserInfo(
      userId: id + 100,
      firstName: firstName ?? 'Student$id',
      lastName: lastName ?? 'User',
      email: 'student$id@example.com',
    ),
  );
}

void main() {
  group('InstructorAssignmentsCubit', () {
    test('createAssignment prepends new assignment to loaded list', () async {
      final fakeAssignmentService = _FakeAssignmentService(
        assignments: <AssignmentModel>[_assignment(id: 1, title: 'A1')],
        createdAssignment: _assignment(
          id: 2,
          title: 'A2',
          apiStatus: api.AssignmentStatus.published,
        ),
      );

      final cubit = InstructorAssignmentsCubit(
        assignmentService: fakeAssignmentService,
        enrollmentService: _FakeEnrollmentService(<TeachingCourseModel>[
          _teachingCourse(),
        ]),
      );

      await cubit.loadTeachingCourses();
      await cubit.createAssignment(
        AssignmentFormData(
          title: 'A2',
          maxScore: 100,
          submissionType: api.SubmissionType.file,
          status: api.AssignmentStatus.published,
          courseId: 99,
        ),
      );

      final assignments = cubit.state.assignments!.data;
      expect(assignments.length, 2);
      expect(assignments.first.assignmentId, 2);
      expect(assignments.first.apiStatus, api.AssignmentStatus.published);

      await cubit.close();
    });

    test('updateStatus replaces matching assignment in state', () async {
      final fakeAssignmentService = _FakeAssignmentService(
        assignments: <AssignmentModel>[
          _assignment(
            id: 1,
            title: 'Draft',
            apiStatus: api.AssignmentStatus.draft,
          ),
        ],
        statusUpdatedAssignment: _assignment(
          id: 1,
          title: 'Draft',
          apiStatus: api.AssignmentStatus.published,
        ),
      );

      final cubit = InstructorAssignmentsCubit(
        assignmentService: fakeAssignmentService,
        enrollmentService: _FakeEnrollmentService(<TeachingCourseModel>[
          _teachingCourse(),
        ]),
      );

      await cubit.loadTeachingCourses();
      await cubit.updateStatus(1, api.AssignmentStatus.published);

      expect(
        cubit.state.assignments!.data.first.apiStatus,
        api.AssignmentStatus.published,
      );

      await cubit.close();
    });

    test('loadAssignments refresh replaces cached list', () async {
      final fakeAssignmentService = _FakeAssignmentService(
        assignments: <AssignmentModel>[_assignment(id: 1, title: 'A1')],
      );

      final cubit = InstructorAssignmentsCubit(
        assignmentService: fakeAssignmentService,
        enrollmentService: _FakeEnrollmentService(<TeachingCourseModel>[
          _teachingCourse(),
        ]),
      );

      await cubit.loadTeachingCourses();
      expect(cubit.state.assignments!.data.length, 1);

      await cubit.loadAssignments(page: 2, limit: 20, refresh: true);

      expect(cubit.state.assignments!.data.length, 1);
      expect(cubit.state.currentPage, 2);

      await cubit.close();
    });

    test(
      'loadSubmissions paginates list and tracks hasMoreSubmissions',
      () async {
        final submissions = List<AssignmentSubmissionModel>.generate(
          25,
          (index) => _submission(
            id: index + 1,
            assignmentId: 5,
            status: api.SubmissionStatus.submitted,
          ),
        );

        final fakeAssignmentService = _FakeAssignmentService(
          assignments: <AssignmentModel>[_assignment(id: 5, title: 'A5')],
          submissions: submissions,
        );

        final cubit = InstructorAssignmentsCubit(
          assignmentService: fakeAssignmentService,
          enrollmentService: _FakeEnrollmentService(
            const <TeachingCourseModel>[],
          ),
        );

        await cubit.loadSubmissions(5, page: 1, limit: 20);
        expect(cubit.state.submissions.length, 20);
        expect(cubit.state.hasMoreSubmissions, isTrue);
        expect(cubit.state.activeSubmissionsAssignmentId, 5);

        await cubit.loadSubmissions(5, page: 2, limit: 20);
        expect(cubit.state.submissions.length, 25);
        expect(cubit.state.hasMoreSubmissions, isFalse);

        await cubit.close();
      },
    );

    test(
      'gradeSubmission updates submission status and score locally',
      () async {
        final fakeAssignmentService = _FakeAssignmentService(
          assignments: <AssignmentModel>[_assignment(id: 8, title: 'A8')],
          submissions: <AssignmentSubmissionModel>[
            _submission(id: 88, assignmentId: 8),
          ],
        );

        final cubit = InstructorAssignmentsCubit(
          assignmentService: fakeAssignmentService,
          enrollmentService: _FakeEnrollmentService(
            const <TeachingCourseModel>[],
          ),
        );

        await cubit.loadSubmissions(8, page: 1, limit: 20);
        await cubit.gradeSubmission(88, 91.5, 'Strong work');

        final updated = cubit.state.submissions.first;
        expect(updated.submissionStatus, api.SubmissionStatus.graded);
        expect(updated.score, 91.5);
        expect(updated.feedback, 'Strong work');

        expect(fakeAssignmentService.lastGradedAssignmentId, 8);
        expect(fakeAssignmentService.lastGradedSubmissionId, 88);
        expect(fakeAssignmentService.lastGradedScore, 91.5);
        expect(fakeAssignmentService.lastGradedFeedback, 'Strong work');

        await cubit.close();
      },
    );

    test('filterSubmissions returns expected sets for each filter', () async {
      final fakeAssignmentService = _FakeAssignmentService(
        assignments: <AssignmentModel>[_assignment(id: 9, title: 'A9')],
      );

      final cubit = InstructorAssignmentsCubit(
        assignmentService: fakeAssignmentService,
        enrollmentService: _FakeEnrollmentService(
          const <TeachingCourseModel>[],
        ),
      );

      final items = <AssignmentSubmissionModel>[
        _submission(
          id: 1,
          assignmentId: 9,
          status: api.SubmissionStatus.submitted,
          firstName: 'Lina',
        ),
        _submission(
          id: 2,
          assignmentId: 9,
          status: api.SubmissionStatus.resubmit,
          firstName: 'Sara',
        ),
        _submission(
          id: 3,
          assignmentId: 9,
          status: api.SubmissionStatus.graded,
          score: 88,
          firstName: 'Omar',
        ),
        _submission(
          id: 4,
          assignmentId: 9,
          status: api.SubmissionStatus.returned,
          score: 80,
          firstName: 'Mina',
        ),
        _submission(
          id: 5,
          assignmentId: 9,
          status: api.SubmissionStatus.submitted,
          isLate: true,
          firstName: 'Late',
        ),
      ];

      final ungraded = cubit.filterSubmissions(items, filter: 'ungraded');
      expect(ungraded.map((item) => item.id).toSet(), equals(<int>{1, 2, 5}));

      final graded = cubit.filterSubmissions(items, filter: 'graded');
      expect(graded.map((item) => item.id).toSet(), equals(<int>{3, 4}));

      final late = cubit.filterSubmissions(items, filter: 'late');
      expect(late.map((item) => item.id).toSet(), equals(<int>{5}));

      final searched = cubit.filterSubmissions(
        items,
        filter: 'all',
        query: 'sara',
      );
      expect(searched.length, 1);
      expect(searched.first.id, 2);

      await cubit.close();
    });
  });
}
