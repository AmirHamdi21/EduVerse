import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/models/assignments/assignment_form_data.dart';
import 'package:edu_verse/models/core/enums/assignment_enums.dart' as api;
import 'package:edu_verse/models/instructor/teaching_course_model.dart';
import 'package:edu_verse/services/api/assignment_service.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/widgets/instructor/assignments/assignment_create_form.dart';

class _FakeAssignmentService extends AssignmentService {
  _FakeAssignmentService() : super(coreApiClient: CoreApiClient.test());
}

TeachingCourseModel _course() {
  return TeachingCourseModel.fromJson(<String, dynamic>{
    'sectionId': 12,
    'userId': 2,
    'courseId': 99,
    'role': 'instructor',
    'course': <String, dynamic>{
      'id': 99,
      'departmentId': 1,
      'code': 'CS999',
      'name': 'Advanced Engineering',
      'credits': 3,
      'level': 'senior',
      'status': 'active',
    },
    'section': <String, dynamic>{
      'id': 12,
      'courseId': 99,
      'semesterId': 3,
      'sectionNumber': 'A',
      'maxCapacity': 30,
      'currentEnrollment': 25,
      'status': 'active',
    },
    'semester': <String, dynamic>{
      'id': 3,
      'name': 'Fall 2026',
      'term': 'fall',
      'year': 2026,
    },
  });
}

Widget _buildTestHost(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('rejects empty title', (WidgetTester tester) async {
    AssignmentFormData? submitted;

    await tester.pumpWidget(
      _buildTestHost(
        AssignmentCreateForm(
          courses: <TeachingCourseModel>[_course()],
          assignmentService: _FakeAssignmentService(),
          onSubmit: (data) => submitted = data,
        ),
      ),
    );

    final saveButton = find.text('Save Assignment');
    await tester.scrollUntilVisible(
      saveButton,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(submitted, isNull);
  });

  testWidgets('rejects save when due date is missing', (
    WidgetTester tester,
  ) async {
    AssignmentFormData? submitted;

    await tester.pumpWidget(
      _buildTestHost(
        AssignmentCreateForm(
          courses: <TeachingCourseModel>[_course()],
          assignmentService: _FakeAssignmentService(),
          onSubmit: (data) => submitted = data,
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, 'A1');
    final saveButton = find.text('Save Assignment');
    await tester.scrollUntilVisible(
      saveButton,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('Due date is required'), findsOneWidget);
    expect(submitted, isNull);
  });

  testWidgets('submits valid form data', (WidgetTester tester) async {
    AssignmentFormData? submitted;

    await tester.pumpWidget(
      _buildTestHost(
        AssignmentCreateForm(
          courses: <TeachingCourseModel>[_course()],
          assignmentService: _FakeAssignmentService(),
          initialData: AssignmentFormData(
            title: 'Existing title',
            dueDate: DateTime(2026, 12, 25, 10, 0),
            maxScore: 100,
            submissionType: api.SubmissionType.file,
            status: api.AssignmentStatus.draft,
            courseId: 99,
          ),
          onSubmit: (data) => submitted = data,
        ),
      ),
    );

    await tester.enterText(
      find.byType(TextFormField).first,
      'Compiler Assignment',
    );
    final saveButton = find.text('Save Assignment');
    await tester.scrollUntilVisible(
      saveButton,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(submitted, isNotNull);
    expect(submitted!.title, 'Compiler Assignment');
    expect(submitted!.courseId, 99);
  });
}
