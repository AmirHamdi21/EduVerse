import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/assignments/assignment_bloc.dart';
import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/models/assignments/assignment_model.dart';
import 'package:edu_verse/models/assignments/assignment_submission_model.dart';
import 'package:edu_verse/models/core/enums/assignment_enums.dart' as api;
import 'package:edu_verse/models/core/paginated_response.dart';
import 'package:edu_verse/services/api/assignment_service.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/widgets/student/assignments/submission_form_sheet.dart';

class _FakeAssignmentService extends AssignmentService {
  _FakeAssignmentService({required this.assignments})
    : super(coreApiClient: CoreApiClient.test());

  final List<AssignmentModel> assignments;

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
    return ServiceResult<AssignmentSubmissionModel>.failure(
      const ServiceError(
        type: ServiceErrorType.server,
        statusCode: 404,
        message: 'No submission found',
      ),
    );
  }
}

AssignmentModel _overdueNoLateAssignment() {
  return AssignmentModel(
    id: '2',
    assignmentId: 2,
    courseId: 1,
    title: 'Overdue Assignment',
    description: 'Late blocked validation',
    courseName: 'Algorithms',
    courseCode: 'CS301',
    instructorName: 'Dr. Ahmed',
    type: AssignmentType.document,
    status: AssignmentStatus.overdue,
    priority: AssignmentPriority.high,
    dueDate: DateTime.now().subtract(const Duration(days: 1)),
    maxGrade: 100,
    createdAt: DateTime(2026, 1, 1),
    apiStatus: api.AssignmentStatus.published,
    submissionType: api.SubmissionType.text,
    lateSubmissionAllowed: false,
    maxFileSizeMb: 10,
  );
}

void main() {
  testWidgets(
    'T082: overdue filter result opens blocked submission form when late not allowed',
    (WidgetTester tester) async {
      final service = _FakeAssignmentService(
        assignments: <AssignmentModel>[_overdueNoLateAssignment()],
      );
      final bloc = AssignmentBloc(assignmentService: service);
      addTearDown(() async {
        await bloc.close();
      });

      await tester.pumpWidget(
        BlocProvider<AssignmentBloc>.value(
          value: bloc,
          child: MaterialApp(
            home: Scaffold(
              body: SubmissionFormSheet(
                assignment: _overdueNoLateAssignment(),
                isDark: false,
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 50));

      expect(
        find.textContaining('late submissions are not accepted'),
        findsOneWidget,
      );

      final submitButtons = find.byWidgetPredicate(
        (widget) => widget is ElevatedButton,
      );
      expect(submitButtons, findsOneWidget);
      final submitButton = tester.widget<ElevatedButton>(submitButtons.first);
      expect(submitButton.onPressed, isNull);
    },
  );
}
