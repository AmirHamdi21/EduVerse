import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/models/assignments/assignment_submission_model.dart';
import 'package:edu_verse/models/core/enums/assignment_enums.dart' as api;
import 'package:edu_verse/models/core/shared_models.dart';
import 'package:edu_verse/widgets/instructor/assignments/submission_list_item.dart';

AssignmentSubmissionModel _submission({
  required int id,
  required api.SubmissionStatus status,
  bool isLate = false,
  double? score,
}) {
  return AssignmentSubmissionModel(
    id: id,
    assignmentId: 1,
    userId: 100 + id,
    submissionStatus: status,
    isLate: isLate,
    attemptNumber: 1,
    submittedAt: DateTime.now().subtract(const Duration(hours: 2)),
    score: score,
    user: UserInfo(
      userId: 100 + id,
      firstName: 'Student',
      lastName: '$id',
      email: 'student$id@example.com',
    ),
  );
}

void main() {
  testWidgets('renders submitted, graded and resubmit statuses', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: <Widget>[
              SubmissionListItem(
                submission: _submission(
                  id: 1,
                  status: api.SubmissionStatus.submitted,
                ),
                onTap: () {},
              ),
              SubmissionListItem(
                submission: _submission(
                  id: 2,
                  status: api.SubmissionStatus.graded,
                  score: 91,
                ),
                onTap: () {},
              ),
              SubmissionListItem(
                submission: _submission(
                  id: 3,
                  status: api.SubmissionStatus.resubmit,
                ),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Submitted'), findsOneWidget);
    expect(find.text('Graded'), findsOneWidget);
    expect(find.text('Resubmit'), findsOneWidget);
  });

  testWidgets('shows late badge when isLate is true', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SubmissionListItem(
            submission: _submission(
              id: 9,
              status: api.SubmissionStatus.submitted,
              isLate: true,
            ),
            onTap: () {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Late'), findsOneWidget);
  });
}
