import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/models/core/enums/lab_enums.dart' as api;
import 'package:edu_verse/models/labs/lab_model.dart';
import 'package:edu_verse/widgets/student/labs/lab_submission_sheet.dart';

LabModel _lab({required DateTime dueDate}) {
  return LabModel(
    id: 'lab-1',
    labId: 1,
    courseId: 1,
    title: 'Submission Lab',
    dueDate: dueDate,
    maxScore: 100,
    status: api.LabStatus.published,
  );
}

Widget _wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  testWidgets('renders text input, file picker section and submit button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        LabSubmissionSheet(
          lab: _lab(dueDate: DateTime.now().add(const Duration(days: 1))),
          isDark: false,
          isSubmitting: false,
          submitProgress: 0,
          onSubmitText: (_) async => true,
          onSubmitFile: (_, __) async => true,
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('File Upload'));
    await tester.pumpAndSettle();

    expect(find.text('Submit Work'), findsOneWidget);
    expect(find.text('Text Submission'), findsOneWidget);
    expect(find.text('File Upload'), findsOneWidget);
    expect(find.text('Choose File'), findsOneWidget);
    expect(find.text('Submit'), findsOneWidget);
  });

  testWidgets('submit button is disabled when no text and no file selected', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        LabSubmissionSheet(
          lab: _lab(dueDate: DateTime.now().add(const Duration(days: 1))),
          isDark: false,
          isSubmitting: false,
          submitProgress: 0,
          onSubmitText: (_) async => true,
          onSubmitFile: (_, __) async => true,
        ),
      ),
    );

    await tester.pumpAndSettle();

    final submitButtonFinder = find.byWidgetPredicate((widget) {
      final typeName = widget.runtimeType.toString().toLowerCase();
      return typeName.contains('elevatedbutton') ||
          typeName.contains('filledbutton');
    }, skipOffstage: false);
    expect(submitButtonFinder, findsWidgets);
    final submitButton = tester.widget<ButtonStyleButton>(
      submitButtonFinder.first,
    );
    expect(submitButton.onPressed, isNull);
  });

  testWidgets('shows late warning banner when lab due date has passed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        LabSubmissionSheet(
          lab: _lab(dueDate: DateTime.now().subtract(const Duration(days: 1))),
          isDark: false,
          isSubmitting: false,
          submitProgress: 0,
          onSubmitText: (_) async => true,
          onSubmitFile: (_, __) async => true,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.text(
        'This lab is past the due date. Your submission will be marked as late.',
      ),
      findsOneWidget,
    );
  });
}
