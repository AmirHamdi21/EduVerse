import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:edu_verse/bloc/courses/courses_bloc.dart';
import 'package:edu_verse/bloc/courses/courses_state.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/screens/student/courses_screen.dart';
import 'package:edu_verse/services/api/communication_service.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/course_service.dart';
import 'package:edu_verse/services/api/enrollment_service.dart';
import 'package:edu_verse/services/api/material_service.dart';
import 'package:edu_verse/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/student_courses_fixture.dart';

class _MockAdapter implements HttpClientAdapter {
  final Map<String, dynamic> Function(RequestOptions) handler;

  _MockAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final result = handler(options);
    final statusCode = result['statusCode'] as int? ?? 200;
    final data = result['data'];

    return ResponseBody.fromString(
      data is String ? data : jsonEncode(data),
      statusCode,
      headers: {
        'content-type': ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

CoursesBloc _buildCoursesBloc(
  Map<String, dynamic> Function(RequestOptions) handler,
) {
  final coreApiClient = CoreApiClient.test();
  coreApiClient.dio.httpClientAdapter = _MockAdapter(handler);

  return CoursesBloc(
    courseService: CourseService(coreApiClient: coreApiClient),
    enrollmentService: EnrollmentService(coreApiClient: coreApiClient),
    materialService: MaterialService(coreApiClient: coreApiClient),
    communicationService: CommunicationService(coreApiClient: coreApiClient),
  );
}

Future<void> _pumpCoursesScreen(WidgetTester tester, CoursesBloc bloc) async {
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<CoursesBloc>.value(value: bloc),
        BlocProvider<ThemeBloc>(
          create: (_) => ThemeBloc(storageService: StorageService()),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const CoursesScreen(),
      ),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CoursesScreen Phase 1 scaffold', () {
    test('fixture helper returns mixed enrollment list', () {
      final data = StudentCoursesFixture.listWithMixedData();
      expect(data.length, 3);
      expect(data.first.course?.courseCode, 'CS100');
    });

    testWidgets('renders loaded enrollments in redesigned shell', (
      tester,
    ) async {
      final bloc = _buildCoursesBloc((options) {
        if (options.path.contains('/enrollments/my-courses')) {
          return {
            'statusCode': 200,
            'data': [
              {
                'id': 1,
                'userId': 42,
                'sectionId': 3,
                'status': 'enrolled',
                'enrollmentDate': '2026-08-15T10:00:00.000Z',
                'course': {
                  'id': 12,
                  'name': 'Discrete Mathematics',
                  'code': 'MATH201',
                  'credits': 3,
                  'level': 'freshman',
                },
                'section': {
                  'id': 3,
                  'sectionNumber': 'A',
                  'maxCapacity': 30,
                  'currentEnrollment': 20,
                },
                'semester': {'id': 5, 'name': 'Fall 2026'},
              },
            ],
          };
        }
        return {'data': []};
      });

      await _pumpCoursesScreen(tester, bloc);

      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Discrete Mathematics'), findsOneWidget);
      expect(find.text('MATH201'), findsOneWidget);
      await bloc.close();
    });

    testWidgets('renders empty state when enrollment list is empty', (
      tester,
    ) async {
      final bloc = _buildCoursesBloc((options) {
        if (options.path.contains('/enrollments/my-courses')) {
          return {'statusCode': 200, 'data': []};
        }
        return {'data': []};
      });

      await _pumpCoursesScreen(tester, bloc);
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('No Courses Found'), findsOneWidget);
      await bloc.close();
    });

    testWidgets('renders auth/session-required state on 401', (tester) async {
      final bloc = _buildCoursesBloc((options) {
        if (options.path.contains('/enrollments/my-courses')) {
          return {
            'statusCode': 401,
            'data': {'message': 'Unauthorized'},
          };
        }
        return {'data': []};
      });

      await _pumpCoursesScreen(tester, bloc);
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Session Required'), findsOneWidget);
      expect(find.text('Re-authenticate'), findsOneWidget);
      await bloc.close();
    });

    test('auth/session state is distinct from generic error state', () {
      const CoursesState authState = CoursesAuthSessionRequired(
        message: 'Authentication required',
        statusCode: 401,
      );
      const CoursesState errorState = CoursesError(message: 'Network failed');

      expect(authState, isNot(equals(errorState)));
      expect(authState, isA<CoursesAuthSessionRequired>());
    });

    test('courses screen type remains available', () {
      const CoursesScreen screen = CoursesScreen();
      expect(screen, isA<CoursesScreen>());
    });
  });
}
