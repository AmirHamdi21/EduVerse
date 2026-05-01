import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:edu_verse/bloc/courses/courses_bloc.dart';
import 'package:edu_verse/bloc/courses/courses_state.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/common/utils/student_course_filters.dart';
import 'package:edu_verse/common/utils/student_courses_theme.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/screens/student/courses_screen.dart';
import 'package:edu_verse/models/core/enrollment_model.dart';
import 'package:edu_verse/services/api/communication_service.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/course_service.dart';
import 'package:edu_verse/services/api/enrollment_service.dart';
import 'package:edu_verse/services/api/material_service.dart';
import 'package:edu_verse/services/storage_service.dart';
import 'package:edu_verse/widgets/student/courses/course_search_bar.dart';
import 'package:edu_verse/widgets/student/courses/courses_header.dart';
import 'package:edu_verse/widgets/student/courses/filter_button.dart';
import 'package:edu_verse/widgets/student/courses/join_course_button.dart';
import 'package:edu_verse/widgets/student/courses/semester_filter_menu_button.dart';
import 'package:edu_verse/widgets/student/courses/sort_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/student_courses_fixture.dart';

class _MockAdapter implements HttpClientAdapter {
  final Future<Map<String, dynamic>> Function(RequestOptions options) handler;

  _MockAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final Map<String, dynamic> result = await handler(options);
    final int statusCode = result['statusCode'] as int? ?? 200;
    final dynamic data = result['data'];

    return ResponseBody.fromString(
      data is String ? data : jsonEncode(data),
      statusCode,
      headers: const <String, List<String>>{
        'content-type': <String>['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

CoursesBloc _buildCoursesBloc(
  Future<Map<String, dynamic>> Function(RequestOptions options) handler,
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
      providers: <BlocProvider<dynamic>>[
        BlocProvider<CoursesBloc>.value(value: bloc),
        BlocProvider<ThemeBloc>(
          create: (_) => ThemeBloc(storageService: StorageService()),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const <Locale>[Locale('en'), Locale('ar')],
        home: const TickerMode(enabled: false, child: CoursesScreen()),
      ),
    ),
  );
}

void main() {
  group('CoursesScreen Phase 1 scaffold', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('fixture helper returns mixed enrollment list', () {
      final data = StudentCoursesFixture.listWithMixedData();
      expect(data.length, 3);
      expect(data.first.course?.courseCode, 'CS100');
      expect(data.first.semester?.name, 'Fall 2026');
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

    test('loaded state keeps enrollment payload available', () {
      final enrollments = StudentCoursesFixture.listWithMixedData();
      final state = CoursesLoaded(enrollments: enrollments);

      expect(state.enrollments.length, 3);
      expect(state.courses.length, 3);
      expect(state.courses.first.courseName, 'Programming Fundamentals');
    });

    testWidgets('courses header renders redesign copy', (tester) async {
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
            child: const Scaffold(
              body: CoursesHeader(
                title: 'My Courses',
                subtitle: 'All enrolled courses this semester',
                tabBar: SizedBox.shrink(),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('My Courses'), findsOneWidget);
      expect(find.text('All enrolled courses this semester'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    });

    testWidgets('courses header uses light-mode shell gradient tokens', (
      tester,
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
            child: const Scaffold(
              body: CoursesHeader(
                title: 'My Courses',
                subtitle: 'All enrolled courses this semester',
                tabBar: SizedBox.shrink(),
              ),
            ),
          ),
        ),
      );

      final Container outerContainer = tester.widget<Container>(
        find.byWidgetPredicate((widget) {
          if (widget is! Container) {
            return false;
          }
          final decoration = widget.decoration;
          return decoration is BoxDecoration &&
              decoration.gradient == StudentCoursesTheme.heroGradientLight;
        }).first,
      );
      final BoxDecoration decoration =
          outerContainer.decoration! as BoxDecoration;
      final LinearGradient gradient = decoration.gradient! as LinearGradient;

      expect(gradient.colors, StudentCoursesTheme.heroGradientLight.colors);
    });

    test('student courses theme exposes dark shell token palette', () {
      expect(StudentCoursesTheme.headerGradientDark.colors, hasLength(2));
      expect(
        StudentCoursesTheme.scaffoldBackground(true),
        StudentCoursesTheme.darkScaffold,
      );
      expect(
        StudentCoursesTheme.cardBackground(true),
        StudentCoursesTheme.darkSurface,
      );
    });

    testWidgets('search bar preserves expected shell control dimensions', (
      tester,
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
            child: const Scaffold(
              body: CourseSearchBar(onSearchChanged: _noop),
            ),
          ),
        ),
      );

      final Container searchContainer = tester.widget<Container>(
        find.byType(Container).first,
      );
      final Size searchContainerSize = tester.getSize(
        find.byType(Container).first,
      );
      final BoxDecoration decoration =
          searchContainer.decoration! as BoxDecoration;
      final BorderRadius borderRadius =
          decoration.borderRadius! as BorderRadius;

      expect(searchContainerSize.height, 56);
      expect(borderRadius.topLeft.x, 999);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('semester filter button shows shell labels', (tester) async {
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
            child: Scaffold(
              body: SemesterFilterMenuButton(
                selectedSemesterId: null,
                semesterOptions: const <SemesterFilterOption>[
                  SemesterFilterOption(id: 1, label: 'Fall 2026'),
                ],
                onSemesterChanged: _noopSemester,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Semester'), findsOneWidget);
      expect(find.text('All Semesters'), findsOneWidget);
    });

    testWidgets('search bar emits query changes and clear action', (
      tester,
    ) async {
      String latestQuery = '';

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
            child: Scaffold(
              body: CourseSearchBar(
                onSearchChanged: (String value) {
                  latestQuery = value;
                },
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'math');
      await tester.pump();
      expect(latestQuery, 'math');

      final clearButton = find.byIcon(Icons.close_rounded);
      expect(clearButton, findsOneWidget);
      await tester.tap(clearButton);
      await tester.pump();
      expect(latestQuery, isEmpty);
    });

    testWidgets('filter button emits status callback from popup selection', (
      tester,
    ) async {
      String selectedFilter = 'all';

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
            child: Scaffold(
              body: Row(
                children: [
                  FilterButton(
                    selectedFilter: 'all',
                    selectedSemesterId: null,
                    semesterOptions: const <SemesterFilterOption>[
                      SemesterFilterOption(id: 1, label: 'Fall 2026'),
                    ],
                    onFilterChanged: (String value) {
                      selectedFilter = value;
                    },
                    onSemesterChanged: _noopSemester,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.tune_rounded));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Completed'));
      await tester.tap(find.text('Completed'));
      await tester.pumpAndSettle();

      expect(selectedFilter, 'completed');
    });

    testWidgets('semester menu button emits selected semester', (tester) async {
      int? selectedSemester;

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
            child: Scaffold(
              body: Row(
                children: [
                  SemesterFilterMenuButton(
                    selectedSemesterId: null,
                    semesterOptions: const <SemesterFilterOption>[
                      SemesterFilterOption(id: 1, label: 'Fall 2026'),
                    ],
                    onSemesterChanged: (int? value) {
                      selectedSemester = value;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.school_rounded));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Fall 2026'));
      await tester.tap(find.text('Fall 2026'));
      await tester.pumpAndSettle();

      expect(selectedSemester, 1);
    });

    testWidgets('sort button emits selected sort key from sheet option', (
      tester,
    ) async {
      String selectedSort = 'title_asc';

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
            child: Scaffold(
              body: Row(
                children: [
                  SortButton(
                    selectedSort: selectedSort,
                    onSortChanged: (String value) {
                      selectedSort = value;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.swap_vert_rounded));
      await tester.pumpAndSettle();

      final ascendingCreditsOption = find.byWidgetPredicate((widget) {
        return widget is Text && (widget.data?.contains('↑') ?? false);
      });
      expect(ascendingCreditsOption, findsWidgets);
      await tester.tap(ascendingCreditsOption.first);
      await tester.pumpAndSettle();

      expect(selectedSort, 'credits_asc');
    });

    testWidgets('join course button navigates to registration route', (
      tester,
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
          routes: <String, WidgetBuilder>{
            '/': (_) => BlocProvider<ThemeBloc>(
              create: (_) => ThemeBloc(storageService: StorageService()),
              child: const Scaffold(body: JoinCourseButton()),
            ),
            '/registration': (_) =>
                const Scaffold(body: Text('Registration Route')),
          },
        ),
      );

      await tester.tap(find.text('Join Course'));
      await tester.pumpAndSettle();

      expect(find.text('Registration Route'), findsOneWidget);
    });

    testWidgets(
      'screen shows loading shell state before slow fetch resolves',
      (tester) async {
        final CoursesBloc bloc = _buildCoursesBloc((RequestOptions options) {
          if (options.path.contains('/enrollments/my-courses')) {
            return Future<Map<String, dynamic>>.delayed(
              const Duration(milliseconds: 800),
              () => <String, dynamic>{'statusCode': 200, 'data': <dynamic>[]},
            );
          }
          return Future<Map<String, dynamic>>.value(<String, dynamic>{
            'statusCode': 200,
            'data': <dynamic>[],
          });
        });

        await _pumpCoursesScreen(tester, bloc);
        await tester.pump();

        expect(
          find.byKey(const Key('courses_shell_loading_state')),
          findsOneWidget,
        );

        await tester.pump(const Duration(milliseconds: 900));
        for (var i = 0; i < 6; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        bloc.close();
        await tester.pump(const Duration(milliseconds: 100));
      },
      timeout: const Timeout(Duration(seconds: 15)),
    );

    testWidgets(
      'screen shows loaded course list state when backend returns data',
      (tester) async {
        final CoursesBloc bloc = _buildCoursesBloc((RequestOptions options) {
          if (options.path.contains('/enrollments/my-courses')) {
            return Future<Map<String, dynamic>>.delayed(
              const Duration(milliseconds: 500),
              () => <String, dynamic>{
                'statusCode': 200,
                'data': <Map<String, dynamic>>[
                  <String, dynamic>{
                    'id': 1,
                    'userId': 42,
                    'sectionId': 3,
                    'status': 'enrolled',
                    'enrollmentDate': '2026-08-15T10:00:00.000Z',
                    'course': <String, dynamic>{
                      'id': 12,
                      'name': 'Discrete Mathematics',
                      'code': 'MATH201',
                      'credits': 3,
                      'level': 'freshman',
                    },
                    'section': <String, dynamic>{
                      'id': 3,
                      'sectionNumber': 'A',
                      'maxCapacity': 30,
                      'currentEnrollment': 20,
                    },
                    'semester': <String, dynamic>{'id': 5, 'name': 'Fall 2026'},
                  },
                ],
              },
            );
          }
          return Future<Map<String, dynamic>>.value(<String, dynamic>{
            'statusCode': 200,
            'data': <dynamic>[],
          });
        });

        await _pumpCoursesScreen(tester, bloc);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 700));
        for (var i = 0; i < 4; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }

        expect(find.text('Discrete Mathematics'), findsWidgets);
        expect(find.text('MATH201'), findsWidgets);

        bloc.close();
        await tester.pump(const Duration(milliseconds: 100));
      },
      timeout: const Timeout(Duration(seconds: 15)),
    );

    testWidgets(
      'screen shows empty state when backend returns no enrollments',
      (tester) async {
        final CoursesBloc bloc = _buildCoursesBloc((RequestOptions options) {
          if (options.path.contains('/enrollments/my-courses')) {
            return Future<Map<String, dynamic>>.delayed(
              const Duration(milliseconds: 500),
              () => <String, dynamic>{'statusCode': 200, 'data': <dynamic>[]},
            );
          }
          return Future<Map<String, dynamic>>.value(<String, dynamic>{
            'statusCode': 200,
            'data': <dynamic>[],
          });
        });

        await _pumpCoursesScreen(tester, bloc);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 700));
        for (var i = 0; i < 4; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }

        expect(
          find.byKey(const Key('courses_shell_empty_state')),
          findsOneWidget,
        );
        expect(find.text('No Courses Found'), findsOneWidget);

        bloc.close();
        await tester.pump(const Duration(milliseconds: 100));
      },
      timeout: const Timeout(Duration(seconds: 15)),
    );

    testWidgets(
      'screen shows generic error state on network failure',
      (tester) async {
        final CoursesBloc bloc = _buildCoursesBloc((RequestOptions options) {
          throw Exception('synthetic test failure');
        });

        await _pumpCoursesScreen(tester, bloc);
        await tester.pump();

        var errorStateVisible = false;
        for (var i = 0; i < 12; i++) {
          await tester.pump(const Duration(milliseconds: 100));
          if (find
              .byKey(const Key('courses_shell_error_state'))
              .evaluate()
              .isNotEmpty) {
            errorStateVisible = true;
            break;
          }
        }

        expect(errorStateVisible, isTrue);

        expect(
          find.byKey(const Key('courses_shell_error_state')),
          findsOneWidget,
        );
        expect(find.text('Connection Error'), findsOneWidget);
        expect(find.text('Try Again'), findsOneWidget);

        bloc.close();
        await tester.pump(const Duration(milliseconds: 100));
      },
      timeout: const Timeout(Duration(seconds: 15)),
    );

    testWidgets(
      'screen shows auth/session recovery state on unauthorized',
      (tester) async {
        final CoursesBloc bloc = _buildCoursesBloc((RequestOptions options) {
          if (options.path.contains('/enrollments/my-courses')) {
            return Future<Map<String, dynamic>>.delayed(
              const Duration(milliseconds: 500),
              () => <String, dynamic>{
                'statusCode': 401,
                'data': <String, dynamic>{'message': 'Unauthorized'},
              },
            );
          }
          return Future<Map<String, dynamic>>.value(<String, dynamic>{
            'statusCode': 200,
            'data': <dynamic>[],
          });
        });

        await _pumpCoursesScreen(tester, bloc);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 700));
        for (var i = 0; i < 4; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }

        expect(
          find.byKey(const Key('courses_shell_auth_state')),
          findsOneWidget,
        );
        expect(find.text('Session Required'), findsOneWidget);
        expect(find.text('Re-authenticate'), findsOneWidget);

        bloc.close();
        await tester.pump(const Duration(milliseconds: 100));
      },
      timeout: const Timeout(Duration(seconds: 15)),
    );

    testWidgets(
      'screen applies RBAC restricted UI on forbidden response',
      (tester) async {
        final CoursesBloc bloc = _buildCoursesBloc((RequestOptions options) {
          if (options.path.contains('/enrollments/my-courses')) {
            return Future<Map<String, dynamic>>.delayed(
              const Duration(milliseconds: 500),
              () => <String, dynamic>{
                'statusCode': 403,
                'data': <String, dynamic>{'message': 'Forbidden'},
              },
            );
          }
          return Future<Map<String, dynamic>>.value(<String, dynamic>{
            'statusCode': 200,
            'data': <dynamic>[],
          });
        });

        await _pumpCoursesScreen(tester, bloc);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 700));
        for (var i = 0; i < 4; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }

        expect(
          find.byKey(const Key('courses_shell_auth_state')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('courses_shell_restricted_controls_notice')),
          findsOneWidget,
        );
        expect(find.text('Access Restricted'), findsOneWidget);
        expect(find.text('Refresh'), findsOneWidget);
        expect(find.byType(CourseSearchBar), findsNothing);
        expect(find.text('Join Course'), findsNothing);

        bloc.close();
        await tester.pump(const Duration(milliseconds: 100));
      },
      timeout: const Timeout(Duration(seconds: 15)),
    );

    test(
      'semester-empty result can be distinguished from global-empty result',
      () {
        final enrollments = StudentCoursesFixture.listWithMixedData();

        final global = StudentCourseFilters.applyCourseFiltersAndSort(
          enrollments: enrollments,
          query: '',
          selectedStatus: 'all',
          sortKey: 'title_asc',
          selectedSemesterId: null,
        );

        final semesterOnly = StudentCourseFilters.applyCourseFiltersAndSort(
          enrollments: enrollments,
          query: '',
          selectedStatus: 'all',
          sortKey: 'title_asc',
          selectedSemesterId: 999,
        );

        expect(global, isNotEmpty);
        expect(semesterOnly, isEmpty);
      },
      timeout: const Timeout(Duration(seconds: 10)),
    );

    test(
      'rapid helper interactions remain stable with null nested fields',
      () {
        final CourseEnrollmentModel nullNested =
            CourseEnrollmentModel.fromJson(<String, dynamic>{
              'id': 'null-nested',
              'userId': 42,
              'sectionId': 7,
              'status': 'enrolled',
              'enrollmentDate': '2026-01-15T00:00:00.000Z',
              'course': null,
              'section': null,
              'semester': null,
              'instructor': null,
              'prerequisites': null,
            });

        final List<CourseEnrollmentModel> source = <CourseEnrollmentModel>[
          ...StudentCoursesFixture.listWithMixedData(),
          nullNested,
        ];

        const List<String> queries = <String>[
          '',
          'cs',
          'fall',
          'instructor',
          'zzz-no-match',
        ];
        const List<String> statuses = <String>[
          'all',
          'active',
          'completed',
          'dropped',
        ];
        const List<String> sorts = <String>[
          'title_asc',
          'title_desc',
          'credits_asc',
          'credits_desc',
          'date',
        ];

        for (final String query in queries) {
          for (final String status in statuses) {
            for (final String sort in sorts) {
              final List<CourseEnrollmentModel> result =
                  StudentCourseFilters.applyCourseFiltersAndSort(
                    enrollments: source,
                    query: query,
                    selectedStatus: status,
                    sortKey: sort,
                    selectedSemesterId: null,
                  );
              expect(result, isA<List<CourseEnrollmentModel>>());
            }
          }
        }
      },
      timeout: const Timeout(Duration(seconds: 10)),
    );
  });
}

void _noop(String _) {}

void _noopSemester(int? _) {}
