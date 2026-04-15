import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/models/instructor/instructor_course_model.dart';
import 'package:edu_verse/widgets/instructor/course_management/students_tab.dart';

Widget _buildStudentsTab(List<SectionStudentModel> students) {
  return MaterialApp(
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const <Locale>[Locale('en'), Locale('ar')],
    home: Builder(
      builder: (context) {
        return Scaffold(
          body: StudentsTab(
            students: students,
            isDark: false,
            l10n: AppLocalizations.of(context),
          ),
        );
      },
    ),
  );
}

void main() {
  testWidgets('renders students list with grade and score', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildStudentsTab(const <SectionStudentModel>[
        SectionStudentModel(
          userId: 1,
          status: 'enrolled',
          grade: 92.5,
          finalScore: 97.0,
          courseCode: 'CS101',
          sectionId: 6,
        ),
      ]),
    );

    await tester.pumpAndSettle();

    expect(find.text('Student #1'), findsOneWidget);
    expect(find.text('No email'), findsOneWidget);
    expect(find.textContaining('Grade:'), findsOneWidget);
    expect(find.textContaining('Score:'), findsOneWidget);
    expect(find.text('enrolled'), findsOneWidget);
  });

  testWidgets('renders empty state when there are no students', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildStudentsTab(const <SectionStudentModel>[]));
    await tester.pumpAndSettle();

    expect(find.text('No students enrolled yet'), findsOneWidget);
  });

  testWidgets('does not expose loading or retry controls in static tab', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildStudentsTab(const <SectionStudentModel>[
        SectionStudentModel(userId: 2, status: 'enrolled'),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Failed to load course structure'), findsNothing);
    expect(find.text('Retry'), findsNothing);
  });
}
