import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/models/assignments/assignment_submission_model.dart';
import 'package:edu_verse/models/core/enums/assignment_enums.dart' as api;
import 'package:edu_verse/models/core/shared_models.dart';
import 'package:edu_verse/models/instructor/teaching_course_model.dart';
import 'package:edu_verse/screens/instructor/assignments/assignment_submissions_screen.dart';
import 'package:edu_verse/services/api/assignment_service.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/enrollment_service.dart';

class _FakeEnrollmentService extends EnrollmentService {
  _FakeEnrollmentService() : super(coreApiClient: CoreApiClient.test());

  @override
  Future<ServiceResult<List<TeachingCourseModel>>> getTeachingCourses({
    CancelToken? cancelToken,
  }) async {
    return ServiceResult<List<TeachingCourseModel>>.success(
      const <TeachingCourseModel>[],
    );
  }
}

class _FakeAssignmentService extends AssignmentService {
  _FakeAssignmentService(this.items)
    : super(coreApiClient: CoreApiClient.test());

  final List<AssignmentSubmissionModel> items;

  @override
  Future<ServiceResult<List<AssignmentSubmissionModel>>> getSubmissions(
    dynamic assignmentId, {
    CancelToken? cancelToken,
  }) async {
    return ServiceResult<List<AssignmentSubmissionModel>>.success(items);
  }
}

AssignmentSubmissionModel _submission({
  required int id,
  required String firstName,
  required String lastName,
  required api.SubmissionStatus status,
  bool isLate = false,
  double? score,
}) {
  return AssignmentSubmissionModel(
    id: id,
    assignmentId: 88,
    userId: id + 100,
    submissionStatus: status,
    isLate: isLate,
    attemptNumber: 1,
    submittedAt: DateTime(2026, 6, id),
    score: score,
    user: UserInfo(
      userId: id + 100,
      firstName: firstName,
      lastName: lastName,
      email: '$firstName@example.com',
    ),
  );
}

Widget _buildTestWidget(List<AssignmentSubmissionModel> submissions) {
  return MaterialApp(
    home: AssignmentSubmissionsScreen(
      assignmentId: 88,
      assignmentTitle: 'Final Project',
      assignmentService: _FakeAssignmentService(submissions),
      enrollmentService: _FakeEnrollmentService(),
    ),
  );
}

void main() {
  testWidgets('renders submissions list from cubit load', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildTestWidget(<AssignmentSubmissionModel>[
        _submission(
          id: 1,
          firstName: 'Lina',
          lastName: 'Hassan',
          status: api.SubmissionStatus.submitted,
        ),
        _submission(
          id: 2,
          firstName: 'Omar',
          lastName: 'Ali',
          status: api.SubmissionStatus.graded,
          score: 93,
        ),
      ]),
    );

    await tester.pumpAndSettle();

    expect(find.text('Lina Hassan'), findsOneWidget);
    expect(find.text('Omar Ali'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(2));
    expect(find.widgetWithText(ChoiceChip, 'Graded'), findsOneWidget);
  });

  testWidgets('applies graded filter and search query', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildTestWidget(<AssignmentSubmissionModel>[
        _submission(
          id: 1,
          firstName: 'Lina',
          lastName: 'Hassan',
          status: api.SubmissionStatus.submitted,
        ),
        _submission(
          id: 2,
          firstName: 'Omar',
          lastName: 'Ali',
          status: api.SubmissionStatus.graded,
          score: 91,
        ),
        _submission(
          id: 3,
          firstName: 'Sara',
          lastName: 'Nabil',
          status: api.SubmissionStatus.resubmit,
          isLate: true,
        ),
      ]),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Graded'));
    await tester.pumpAndSettle();

    expect(find.text('Omar Ali'), findsOneWidget);
    expect(find.text('Lina Hassan'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'All'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'sara');
    await tester.pumpAndSettle();

    expect(find.text('Sara Nabil'), findsOneWidget);
    expect(find.text('Omar Ali'), findsNothing);
  });
}
