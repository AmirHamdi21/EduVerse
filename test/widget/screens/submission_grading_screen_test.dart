import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/models/assignments/assignment_submission_model.dart';
import 'package:edu_verse/models/core/enums/assignment_enums.dart' as api;
import 'package:edu_verse/models/core/shared_models.dart';
import 'package:edu_verse/models/instructor/teaching_course_model.dart';
import 'package:edu_verse/screens/instructor/assignments/submission_grading_screen.dart';
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
  _FakeAssignmentService({required this.submissions, this.failGrade = false})
    : super(coreApiClient: CoreApiClient.test());

  final List<AssignmentSubmissionModel> submissions;
  final bool failGrade;

  int? gradedAssignmentId;
  int? gradedSubmissionId;
  double? gradedScore;
  String? gradedFeedback;

  @override
  Future<ServiceResult<List<AssignmentSubmissionModel>>> getSubmissions(
    dynamic assignmentId, {
    CancelToken? cancelToken,
  }) async {
    return ServiceResult<List<AssignmentSubmissionModel>>.success(submissions);
  }

  @override
  Future<ServiceResult<Map<String, dynamic>>> gradeSubmission(
    dynamic assignmentId,
    dynamic submissionId,
    double score, {
    String? feedback,
    CancelToken? cancelToken,
  }) async {
    gradedAssignmentId = assignmentId as int;
    gradedSubmissionId = submissionId as int;
    gradedScore = score;
    gradedFeedback = feedback;

    if (failGrade) {
      return ServiceResult<Map<String, dynamic>>.failure(
        const ServiceError(
          type: ServiceErrorType.server,
          statusCode: 500,
          message: 'save failed',
        ),
      );
    }

    return ServiceResult<Map<String, dynamic>>.success(<String, dynamic>{
      'ok': true,
    });
  }
}

AssignmentSubmissionModel _submission() {
  return AssignmentSubmissionModel(
    id: 44,
    assignmentId: 77,
    userId: 9,
    submissionStatus: api.SubmissionStatus.submitted,
    isLate: true,
    attemptNumber: 1,
    submittedAt: DateTime(2026, 6, 4),
    submissionText: 'Final answer text',
    submissionLink: 'https://example.com/submission/44',
    user: const UserInfo(
      userId: 9,
      firstName: 'Nour',
      lastName: 'Khaled',
      email: 'nour@example.com',
    ),
  );
}

Widget _buildTestWidget(_FakeAssignmentService assignmentService) {
  return MaterialApp(
    home: SubmissionGradingScreen(
      assignmentId: 77,
      submissionId: 44,
      assignmentTitle: 'Compiler Project',
      maxScore: 100,
      assignmentDueDate: DateTime(2026, 6, 1),
      latePenaltyPercent: 10,
      assignmentService: assignmentService,
      enrollmentService: _FakeEnrollmentService(),
    ),
  );
}

void main() {
  testWidgets('submits entered score/feedback and keeps values on failure', (
    WidgetTester tester,
  ) async {
    final assignmentService = _FakeAssignmentService(
      submissions: <AssignmentSubmissionModel>[_submission()],
      failGrade: true,
    );

    await tester.pumpWidget(_buildTestWidget(assignmentService));
    await tester.pumpAndSettle();

    expect(find.text('Nour Khaled'), findsWidgets);
    expect(find.textContaining('Late Penalty:'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), '85.5');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Clear explanation',
    );
    final saveButtonFinder = find.text('Save Grade');
    await tester.scrollUntilVisible(
      saveButtonFinder,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(saveButtonFinder);
    await tester.pumpAndSettle();

    expect(assignmentService.gradedAssignmentId, 77);
    expect(assignmentService.gradedSubmissionId, 44);
    expect(assignmentService.gradedScore, 85.5);
    expect(assignmentService.gradedFeedback, 'Clear explanation');

    expect(find.text('save failed'), findsWidgets);
    expect(find.text('85.5'), findsOneWidget);
    expect(find.text('Clear explanation'), findsOneWidget);
  });
}
