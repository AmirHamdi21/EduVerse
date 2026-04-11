import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/assignments/assignment_bloc.dart';
import 'package:edu_verse/bloc/assignments/assignment_event.dart';
import 'package:edu_verse/bloc/assignments/assignment_state.dart';
import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/models/assignments/assignment_model.dart';
import 'package:edu_verse/models/assignments/assignment_submission_model.dart';
import 'package:edu_verse/models/core/enums/assignment_enums.dart' as api;
import 'package:edu_verse/models/core/paginated_response.dart';
import 'package:edu_verse/services/api/assignment_service.dart';
import 'package:edu_verse/services/api/core_api_client.dart';

class _FakeAssignmentService extends AssignmentService {
  _FakeAssignmentService({
    required this.assignments,
    this.submissions = const <int, AssignmentSubmissionModel>{},
  }) : super(coreApiClient: CoreApiClient.test());

  final List<AssignmentModel> assignments;
  final Map<int, AssignmentSubmissionModel> submissions;

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
        page: 1,
        limit: assignments.isEmpty ? 1 : assignments.length,
        totalPages: 1,
      ),
    );
  }

  @override
  Future<ServiceResult<AssignmentSubmissionModel>> getMySubmission(
    dynamic assignmentId,
  ) async {
    final id = assignmentId is int
        ? assignmentId
        : int.tryParse(assignmentId.toString()) ?? 0;

    final submission = submissions[id];
    if (submission == null) {
      return ServiceResult<AssignmentSubmissionModel>.failure(
        const ServiceError(
          type: ServiceErrorType.server,
          statusCode: 404,
          message: 'No submission found',
        ),
      );
    }

    return ServiceResult<AssignmentSubmissionModel>.success(submission);
  }

  @override
  Future<ServiceResult<AssignmentModel>> getById(dynamic id) async {
    final resolvedId = id is int ? id : int.tryParse(id.toString()) ?? 0;
    final assignment = assignments.firstWhere(
      (item) => item.assignmentId == resolvedId,
      orElse: () => assignments.first,
    );
    return ServiceResult<AssignmentModel>.success(assignment);
  }
}

AssignmentModel _assignment({
  required int id,
  required String title,
  required DateTime dueDate,
  api.AssignmentStatus apiStatus = api.AssignmentStatus.published,
}) {
  return AssignmentModel(
    id: id.toString(),
    assignmentId: id,
    courseId: 1,
    title: title,
    description: 'description for $title',
    courseName: 'Algorithms',
    courseCode: 'CS301',
    instructorName: 'Dr. Ahmed',
    type: AssignmentType.document,
    status: AssignmentStatus.pending,
    priority: AssignmentPriority.medium,
    dueDate: dueDate,
    maxGrade: 100,
    createdAt: DateTime(2026, 1, 1),
    apiStatus: apiStatus,
    submissionType: api.SubmissionType.text,
    lateSubmissionAllowed: true,
    maxFileSizeMb: 10,
  );
}

AssignmentSubmissionModel _submission({
  required int assignmentId,
  api.SubmissionStatus status = api.SubmissionStatus.submitted,
}) {
  return AssignmentSubmissionModel(
    id: assignmentId * 10,
    assignmentId: assignmentId,
    userId: 5,
    submissionStatus: status,
    isLate: false,
    attemptNumber: 1,
    submittedAt: DateTime.now(),
  );
}

Future<void> _flush() async {
  await Future<void>.delayed(const Duration(milliseconds: 1));
}

void main() {
  group('AssignmentBloc', () {
    test('fetch computes counters from backend and submission state', () async {
      final now = DateTime.now();
      final service = _FakeAssignmentService(
        assignments: <AssignmentModel>[
          _assignment(
            id: 1,
            title: 'Future Pending',
            dueDate: now.add(const Duration(days: 2)),
          ),
          _assignment(
            id: 2,
            title: 'Past Overdue',
            dueDate: now.subtract(const Duration(days: 1)),
          ),
          _assignment(
            id: 3,
            title: 'Submitted Work',
            dueDate: now.subtract(const Duration(days: 1)),
          ),
        ],
        submissions: <int, AssignmentSubmissionModel>{
          3: _submission(assignmentId: 3),
        },
      );

      final bloc = AssignmentBloc(assignmentService: service);

      bloc.add(const FetchAssignments());
      await _flush();
      await _flush();

      expect(bloc.state.totalCount, 3);
      expect(bloc.state.submittedCount, 1);
      expect(bloc.state.pendingCount, 1);
      expect(bloc.state.overdueCount, 1);

      await bloc.close();
    });

    test('status filter and search query update filtered list', () async {
      final now = DateTime.now();
      final service = _FakeAssignmentService(
        assignments: <AssignmentModel>[
          _assignment(
            id: 1,
            title: 'Future Pending',
            dueDate: now.add(const Duration(days: 2)),
          ),
          _assignment(
            id: 2,
            title: 'Submitted Work',
            dueDate: now.add(const Duration(days: 1)),
          ),
        ],
        submissions: <int, AssignmentSubmissionModel>{
          2: _submission(assignmentId: 2),
        },
      );

      final bloc = AssignmentBloc(assignmentService: service);

      bloc.add(const FetchAssignments());
      await _flush();
      await _flush();

      bloc.add(
        const SetAssignmentFilterStatus(
          filterStatus: AssignmentFilterStatus.submitted,
        ),
      );
      await _flush();

      expect(bloc.state.filteredAssignments.length, 1);
      expect(bloc.state.filteredAssignments.first.assignmentId, 2);

      bloc.add(
        const SetAssignmentFilterStatus(
          filterStatus: AssignmentFilterStatus.all,
        ),
      );
      bloc.add(const SetAssignmentSearchQuery(query: 'future'));
      await _flush();

      expect(bloc.state.filteredAssignments.length, 1);
      expect(bloc.state.filteredAssignments.first.title, contains('Future'));

      await bloc.close();
    });
  });
}
