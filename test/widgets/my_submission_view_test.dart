import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/models/assignments/assignment_submission_model.dart';
import 'package:edu_verse/models/core/enums/assignment_enums.dart';
import 'package:edu_verse/widgets/student/assignments/my_submission_view.dart';

AssignmentSubmissionModel _gradedLateSubmission() {
  return AssignmentSubmissionModel(
    id: 10,
    assignmentId: 1,
    userId: 5,
    submissionText: 'My final answer',
    submissionStatus: SubmissionStatus.graded,
    isLate: true,
    attemptNumber: 1,
    submittedAt: DateTime(2026, 4, 10, 9, 30),
    score: 88,
    feedback: 'Strong work with minor issues.',
    gradedAt: DateTime(2026, 4, 11, 11, 0),
  );
}

void main() {
  testWidgets('shows score, late badge, feedback and resubmit button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MySubmissionView(
            submission: _gradedLateSubmission(),
            maxScore: 100,
            isDark: false,
            onResubmit: () {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('My Submission'), findsOneWidget);
    expect(find.text('Late'), findsOneWidget);
    expect(find.textContaining('88.0 / 100.0'), findsOneWidget);
    expect(find.text('Instructor Feedback'), findsOneWidget);
    expect(find.text('Resubmit Assignment'), findsOneWidget);
  });
}
