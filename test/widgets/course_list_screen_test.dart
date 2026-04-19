import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/services/storage_service.dart';
import 'package:edu_verse/widgets/student/courses/courses_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/student_courses_fixture.dart';

@Timeout(Duration(seconds: 30))
void main() {
  testWidgets('courses list view renders enrollment payload fields', (
    WidgetTester tester,
  ) async {
    final enrollments = StudentCoursesFixture.listWithMixedData();

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ThemeBloc>(
          create: (_) => ThemeBloc(storageService: StorageService()),
          child: Scaffold(body: CoursesListView(enrollments: enrollments)),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Programming Fundamentals'), findsOneWidget);
    expect(find.text('Linear Algebra'), findsOneWidget);
    expect(find.text('MATH200'), findsOneWidget);
    expect(find.text('Section A1'), findsOneWidget);
    expect(find.text('Fall 2026'), findsOneWidget);
    expect(find.text('No Semester'), findsOneWidget);
  });

  testWidgets('courses list view shows empty placeholder when list is empty', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
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
