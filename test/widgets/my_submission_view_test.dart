import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/models/assignments/assignment_submission_model.dart';
import 'package:edu_verse/models/core/drive_file_model.dart';
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

AssignmentSubmissionModel _fileSubmissionWithNote() {
  return AssignmentSubmissionModel(
    id: 12,
    assignmentId: 2,
    userId: 5,
    submissionText: 'Please check the attached PDF.',
    submissionStatus: SubmissionStatus.submitted,
    isLate: false,
    attemptNumber: 1,
    submittedAt: DateTime(2026, 4, 10, 9, 30),
    driveFile: const DriveFileModel(
      driveFileId: 90,
      driveId: 'abc123',
      fileName: 'submission.pdf',
      webViewLink: 'https://drive.google.com/file/d/abc123/view',
      downloadUrl: 'https://drive.google.com/uc?id=abc123&export=download',
      iframeUrl: 'https://drive.google.com/file/d/abc123/preview',
    ),
  );
}

AssignmentSubmissionModel _fileSubmissionWithoutNote() {
  return AssignmentSubmissionModel(
    id: 13,
    assignmentId: 3,
    userId: 5,
    submissionStatus: SubmissionStatus.submitted,
    isLate: false,
    attemptNumber: 1,
    submittedAt: DateTime(2026, 4, 10, 9, 30),
    driveFile: const DriveFileModel(
      driveFileId: 91,
      driveId: 'xyz789',
      fileName: 'report.docx',
      webViewLink: 'https://drive.google.com/file/d/xyz789/view',
      downloadUrl: 'https://drive.google.com/uc?id=xyz789&export=download',
      iframeUrl: 'https://drive.google.com/file/d/xyz789/preview',
    ),
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

  testWidgets(
    'shows note plus Open in Drive and Download for file submission',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MySubmissionView(
              submission: _fileSubmissionWithNote(),
              maxScore: 100,
              isDark: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Note'), findsOneWidget);
      expect(find.text('Please check the attached PDF.'), findsOneWidget);
      expect(find.text('submission.pdf'), findsOneWidget);
      expect(find.text('Open in Drive'), findsOneWidget);
      expect(find.text('Download'), findsOneWidget);
    },
  );

  testWidgets(
    'shows Open in Drive and Download for file submission without note',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MySubmissionView(
              submission: _fileSubmissionWithoutNote(),
              maxScore: 100,
              isDark: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('report.docx'), findsOneWidget);
      expect(find.text('Open in Drive'), findsOneWidget);
      expect(find.text('Download'), findsOneWidget);
    },
  );
}
