import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/services/storage_service.dart';
import 'package:edu_verse/widgets/student/courses/course_card.dart';
import 'package:edu_verse/widgets/student/courses/courses_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/student_courses_fixture.dart';

void main() {
  testWidgets('courses list view renders enrollment payload fields', (
    WidgetTester tester,
  ) async {
    final enrollments = StudentCoursesFixture.listWithMixedData();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const <Locale>[Locale('en'), Locale('ar')],
        home: BlocProvider<ThemeBloc>(
          create: (_) => ThemeBloc(storageService: StorageService()),
          child: Scaffold(body: CoursesListView(enrollments: enrollments)),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(CourseCard), findsOneWidget);
    expect(find.text('Programming Fundamentals'), findsWidgets);
    expect(find.text('Section A1'), findsOneWidget);
    expect(find.text('Fall 2026'), findsOneWidget);
  });

  testWidgets('courses list view shows empty placeholder when list is empty', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const <Locale>[Locale('en'), Locale('ar')],
        home: BlocProvider<ThemeBloc>(
          create: (_) => ThemeBloc(storageService: StorageService()),
          child: const Scaffold(body: CoursesListView(enrollments: [])),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No enrolled courses yet'), findsOneWidget);
  });
}
