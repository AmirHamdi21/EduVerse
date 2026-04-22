import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/models/core/drive_file_model.dart';
import 'package:edu_verse/models/core/enums/assignment_enums.dart' as api;
import 'package:edu_verse/models/labs/lab_submission_model.dart';
import 'package:edu_verse/widgets/student/labs/submission_history_view.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

LabSubmissionModel _submission({
  required int id,
  required DateTime submittedAt,
  required api.SubmissionStatus status,
  bool isLate = false,
  double? score,
  String? feedback,
  String? text,
  DriveFileModel? file,
}) {
  return LabSubmissionModel(
    id: id,
    labId: 1,
    userId: 7,
    submissionStatus: status,
    isLate: isLate,
    submittedAt: submittedAt,
    score: score,
    feedback: feedback,
    submissionText: text,
    driveFile: file,
  );
}

void main() {
  testWidgets('renders graded, pending, late indicators and attempts list', (
    WidgetTester tester,
  ) async {
    final submissions = <LabSubmissionModel>[
      _submission(
        id: 1,
        submittedAt: DateTime.now().subtract(const Duration(days: 2)),
        status: api.SubmissionStatus.graded,
        score: 85,
        feedback: 'Strong solution.',
        text: 'Attempt one',
      ),
      _submission(
        id: 2,
        submittedAt: DateTime.now().subtract(const Duration(days: 1)),
        status: api.SubmissionStatus.submitted,
        isLate: true,
        text: 'Attempt two',
        file: const DriveFileModel(
          driveFileId: 9,
          driveId: 'abc',
          fileName: 'answer.pdf',
          webViewLink: 'https://drive.google.com/file/d/abc/view',
          downloadUrl: 'https://drive.google.com/uc?id=abc&export=download',
          iframeUrl: 'https://drive.google.com/file/d/abc/preview',
        ),
      ),
    ];

    await tester.pumpWidget(
      _wrap(
        SubmissionHistoryView(
          submissions: submissions,
          maxScore: 100,
          isDark: false,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Graded'), findsOneWidget);
    expect(find.text('Submitted'), findsOneWidget);
    expect(find.text('Late'), findsOneWidget);
    expect(find.text('85.0 / 100'), findsOneWidget);
    expect(find.text('Strong solution.'), findsOneWidget);
    expect(find.text('Attempt one'), findsOneWidget);
    expect(find.text('Attempt two'), findsOneWidget);
    expect(find.text('answer.pdf'), findsOneWidget);
  });

  testWidgets('shows empty state when there are no submissions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const SubmissionHistoryView(
          submissions: <LabSubmissionModel>[],
          maxScore: 100,
          isDark: false,
        ),
      ),
    );

    expect(find.text('No submissions yet'), findsOneWidget);
  });
}
