import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/instructor/instructor_assignments_cubit.dart';
import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/models/assignments/assignment_form_data.dart';
import 'package:edu_verse/models/assignments/assignment_model.dart';
import 'package:edu_verse/models/assignments/assignment_submission_model.dart';
import 'package:edu_verse/models/core/enums/assignment_enums.dart' as api;
import 'package:edu_verse/models/core/paginated_response.dart';
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
    required this.submissionsByAssignment,
  }) : super(coreApiClient: CoreApiClient.test());

  final List<AssignmentModel> assignments;
  final Map<int, List<AssignmentSubmissionModel>> submissionsByAssignment;

  int? gradedAssignmentId;
  int? gradedSubmissionId;
  double? gradedScore;

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
        data: List<AssignmentModel>.from(assignments),
        total: assignments.length,
        page: page ?? 1,
        limit: limit ?? 20,
        totalPages: 1,
      ),
    );
  }

  @override
  Future<ServiceResult<AssignmentModel>> create(
    Map<String, dynamic> data,
  ) async {
    final created = _assignment(
      id: assignments.length + 1,
      title: data['title']?.toString() ?? 'Untitled',
      apiStatus: api.AssignmentStatus.fromString(
        data['status']?.toString() ?? api.AssignmentStatus.draft.value,
      ),
    );
    assignments.insert(0, created);
    return ServiceResult<AssignmentModel>.success(created);
  }

  @override
  Future<ServiceResult<List<AssignmentSubmissionModel>>> getSubmissions(
    dynamic assignmentId,
  ) async {
    final id = assignmentId as int;
    return ServiceResult<List<AssignmentSubmissionModel>>.success(
      List<AssignmentSubmissionModel>.from(
        submissionsByAssignment[id] ?? const <AssignmentSubmissionModel>[],
      ),
    );
  }

  @override
  Future<ServiceResult<Map<String, dynamic>>> gradeSubmission(
    dynamic assignmentId,
    dynamic submissionId,
    double score, {
    String? feedback,
  }) async {
    gradedAssignmentId = assignmentId as int;
    gradedSubmissionId = submissionId as int;
    gradedScore = score;

    final list = submissionsByAssignment[gradedAssignmentId!];
    if (list != null) {
      final idx = list.indexWhere((item) => item.id == gradedSubmissionId);
      if (idx >= 0) {
        final old = list[idx];
        list[idx] = AssignmentSubmissionModel(
          id: old.id,
          assignmentId: old.assignmentId,
          userId: old.userId,
          submissionText: old.submissionText,
          submissionLink: old.submissionLink,
          fileId: old.fileId,
          submissionStatus: api.SubmissionStatus.graded,
          isLate: old.isLate,
          attemptNumber: old.attemptNumber,
          submittedAt: old.submittedAt,
          score: score,
          feedback: feedback,
          gradedBy: old.gradedBy,
          gradedAt: DateTime.now(),
          user: old.user,
          driveFile: old.driveFile,
        );
      }
    }

    return ServiceResult<Map<String, dynamic>>.success(<String, dynamic>{
      'ok': true,
    });
  }
}

TeachingCourseModel _teachingCourse() {
  return TeachingCourseModel.fromJson(<String, dynamic>{
    'sectionId': 1,
    'userId': 5,
    'courseId': 10,
    'role': 'instructor',
    'course': <String, dynamic>{
      'id': 10,
      'departmentId': 1,
      'code': 'CS410',
      'name': 'Distributed Systems',
      'credits': 3,
      'level': 'senior',
      'status': 'active',
    },
    'section': <String, dynamic>{
      'id': 1,
      'courseId': 10,
      'semesterId': 2,
      'sectionNumber': 'A',
      'maxCapacity': 35,
      'currentEnrollment': 29,
      'status': 'active',
    },
    'semester': <String, dynamic>{
      'id': 2,
      'name': 'Spring 2026',
      'term': 'spring',
      'year': 2026,
    },
  });
}

AssignmentModel _assignment({
  required int id,
  required String title,
  required api.AssignmentStatus apiStatus,
}) {
  return AssignmentModel(
    id: id.toString(),
    assignmentId: id,
    courseId: 10,
    title: title,
    description: 'desc $title',
    courseName: 'Distributed Systems',
    courseCode: 'CS410',
    instructorName: 'Dr. Integration',
    type: AssignmentType.document,
    status: AssignmentStatus.pending,
    priority: AssignmentPriority.medium,
    dueDate: DateTime(2026, 7, 1),
    maxGrade: 100,
    createdAt: DateTime(2026, 1, 1),
    apiStatus: apiStatus,
    submissionType: api.SubmissionType.file,
    lateSubmissionAllowed: true,
    maxFileSizeMb: 20,
  );
}

AssignmentSubmissionModel _submission({
  required int id,
  required int assignmentId,
}) {
  return AssignmentSubmissionModel(
    id: id,
    assignmentId: assignmentId,
    userId: 99,
    submissionStatus: api.SubmissionStatus.submitted,
    isLate: false,
    attemptNumber: 1,
    submittedAt: DateTime(2026, 7, 2),
  );
}

void main() {
  test(
    'phase6 flow: load courses, create assignment, load and grade submission',
    () async {
      final assignmentService = _FakeAssignmentService(
        assignments: <AssignmentModel>[
          _assignment(
            id: 1,
            title: 'Initial Assignment',
            apiStatus: api.AssignmentStatus.published,
          ),
        ],
        submissionsByAssignment: <int, List<AssignmentSubmissionModel>>{
          1: <AssignmentSubmissionModel>[
            _submission(id: 1001, assignmentId: 1),
          ],
        },
      );

      final cubit = InstructorAssignmentsCubit(
        assignmentService: assignmentService,
        enrollmentService: _FakeEnrollmentService(<TeachingCourseModel>[
          _teachingCourse(),
        ]),
      );

      final assignmentsStopwatch = Stopwatch()..start();
      await cubit.loadTeachingCourses();
      assignmentsStopwatch.stop();

      expect(cubit.state.teachingCourses.length, 1);
      expect(cubit.state.assignmentItems.length, 1);
      expect(assignmentsStopwatch.elapsedMilliseconds, lessThan(2000));

      await cubit.createAssignment(
        AssignmentFormData(
          title: 'New Assignment',
          maxScore: 100,
          submissionType: api.SubmissionType.file,
          status: api.AssignmentStatus.draft,
          courseId: 10,
        ),
      );

      expect(cubit.state.assignmentItems.length, 2);
      expect(cubit.state.assignmentItems.first.title, 'New Assignment');

      final submissionsStopwatch = Stopwatch()..start();
      await cubit.loadSubmissions(1, page: 1, limit: 20);
      submissionsStopwatch.stop();

      expect(cubit.state.submissions.length, 1);
      expect(submissionsStopwatch.elapsedMilliseconds, lessThan(2000));

      final gradingStopwatch = Stopwatch()..start();
      await cubit.gradeSubmission(1001, 94.0, 'Excellent work');
      gradingStopwatch.stop();

      expect(
        cubit.state.submissions.first.submissionStatus,
        api.SubmissionStatus.graded,
      );
      expect(cubit.state.submissions.first.score, 94.0);
      expect(assignmentService.gradedAssignmentId, 1);
      expect(assignmentService.gradedSubmissionId, 1001);
      expect(gradingStopwatch.elapsedMilliseconds, lessThan(1000));

      await cubit.close();
    },
  );
}
