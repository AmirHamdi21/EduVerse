import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/assignments/assignment_bloc.dart';
import 'package:edu_verse/models/assignments/assignment_model.dart';
import 'package:edu_verse/models/core/enums/assignment_enums.dart' as api;
import 'package:edu_verse/services/api/assignment_service.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/widgets/student/assignments/submission_form_sheet.dart';

class _FakeAssignmentService extends AssignmentService {
  _FakeAssignmentService() : super(coreApiClient: CoreApiClient.test());
}

AssignmentModel _textAssignment() {
  return AssignmentModel(
    id: '1',
    assignmentId: 1,
    courseId: 1,
    title: 'Text Assignment',
    description: 'Write your answer',
    courseName: 'Algorithms',
    courseCode: 'CS301',
    instructorName: 'Dr. Ahmed',
    type: AssignmentType.document,
    status: AssignmentStatus.pending,
    priority: AssignmentPriority.medium,
    dueDate: DateTime.now().add(const Duration(days: 1)),
    maxGrade: 100,
    createdAt: DateTime(2026, 1, 1),
    apiStatus: api.AssignmentStatus.published,
    submissionType: api.SubmissionType.text,
    lateSubmissionAllowed: true,
    maxFileSizeMb: 10,
  );
}

void main() {
  testWidgets('validates empty text submission before dispatch', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      BlocProvider<AssignmentBloc>(
        create: (_) =>
            AssignmentBloc(assignmentService: _FakeAssignmentService()),
        child: MaterialApp(
          home: Scaffold(
            body: SubmissionFormSheet(
              assignment: _textAssignment(),
              isDark: false,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pump();

    expect(find.text('Please enter your submission text'), findsOneWidget);
  });
}
