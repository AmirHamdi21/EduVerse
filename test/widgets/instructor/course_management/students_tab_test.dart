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
  testWidgets('renders students list with grade and attendance', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildStudentsTab(const <SectionStudentModel>[
        SectionStudentModel(
          userId: 1,
          firstName: 'Hana',
          lastName: 'Nour',
          email: 'hana@example.com',
          enrollmentStatus: 'enrolled',
          grade: 92.5,
          attendanceRate: 97.0,
        ),
      ]),
    );

    await tester.pumpAndSettle();

    expect(find.text('Hana Nour'), findsOneWidget);
    expect(find.text('hana@example.com'), findsOneWidget);
    expect(find.textContaining('Grade:'), findsOneWidget);
    expect(find.textContaining('Attendance:'), findsOneWidget);
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
        SectionStudentModel(
          userId: 2,
          firstName: 'Lina',
          lastName: 'Hassan',
          email: 'lina@example.com',
          enrollmentStatus: 'enrolled',
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Failed to load course structure'), findsNothing);
    expect(find.text('Retry'), findsNothing);
  });
}
