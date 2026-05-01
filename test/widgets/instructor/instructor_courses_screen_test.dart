import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/instructor/instructor_courses_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/models/assignments/assignment_model.dart';
import 'package:edu_verse/models/auth_models.dart';
import 'package:edu_verse/models/core/paginated_response.dart';
import 'package:edu_verse/models/instructor/teaching_course_model.dart';
import 'package:edu_verse/models/labs/lab_model.dart';
import 'package:edu_verse/screens/instructor/courses/instructor_courses_screen.dart';
import 'package:edu_verse/services/api/assignment_service.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/enrollment_service.dart';
import 'package:edu_verse/services/api/lab_service.dart';
import 'package:edu_verse/services/storage_service.dart';
import 'package:edu_verse/widgets/instructor/courses/course_skeleton_card.dart';

class _FakeStorageService extends StorageService {
  _FakeStorageService({this.user});

  final UserDto? user;

  @override
  Future<bool> getDarkMode() async => false;

  @override
  Future<int> getFontSize() async => 1;

  @override
  Future<void> setDarkMode(bool isDark) async {}

  @override
  Future<void> setFontSize(int sizeIndex) async {}

  @override
  Future<UserDto?> getUserData() async => user;
}

class _FakeEnrollmentService extends EnrollmentService {
  _FakeEnrollmentService({required this.loader})
    : super(coreApiClient: CoreApiClient.test());

  final Future<ServiceResult<List<TeachingCourseModel>>> Function() loader;

  @override
  Future<ServiceResult<List<TeachingCourseModel>>> getTeachingCourses() {
    return loader();
  }
}

class _FakeAssignmentService extends AssignmentService {
  _FakeAssignmentService() : super(coreApiClient: CoreApiClient.test());

  @override
  Future<ServiceResult<PaginatedResponse<AssignmentModel>>> getAll({
    int? courseId,
    int? sectionId,
    dynamic status,
    String? search,
    int? page,
    int? limit,
    String? sortBy,
    String? sortOrder,
  }) async {
    return ServiceResult<PaginatedResponse<AssignmentModel>>.success(
      const PaginatedResponse<AssignmentModel>(
        data: <AssignmentModel>[],
        total: 0,
        page: 1,
        limit: 1,
        totalPages: 1,
      ),
    );
  }
}

class _FakeLabService extends LabService {
  _FakeLabService() : super(coreApiClient: CoreApiClient.test());

  @override
  Future<ServiceResult<List<LabModel>>> getAll({
    int? courseId,
    String? status,
    String? search,
    int page = 1,
    int limit = 50,
  }) async {
    return ServiceResult<List<LabModel>>.success(const <LabModel>[]);
  }
}

TeachingCourseModel _teachingCourse() {
  return TeachingCourseModel.fromJson(<String, dynamic>{
    'sectionId': 12,
    'userId': 9,
    'courseId': 77,
    'role': 'instructor',
    'enrolledCount': 28,
    'capacity': 40,
    'course': <String, dynamic>{
      'id': 77,
      'departmentId': 1,
      'code': 'CS500',
      'name': 'Advanced Topics',
      'credits': 3,
      'level': 'senior',
      'status': 'active',
    },
    'section': <String, dynamic>{
      'id': 12,
      'courseId': 77,
      'semesterId': 2,
      'sectionNumber': 'B',
      'maxCapacity': 40,
      'currentEnrollment': 28,
      'status': 'active',
    },
    'semester': <String, dynamic>{
      'id': 2,
      'name': 'Fall 2026',
      'term': 'fall',
      'year': 2026,
    },
  });
}

Widget _buildScreen({
  required Future<ServiceResult<List<TeachingCourseModel>>> Function() loader,
  StorageService? storageService,
}) {
  final resolvedStorageService = storageService ?? _FakeStorageService();

  return MultiBlocProvider(
    providers: <BlocProvider<dynamic>>[
      BlocProvider<ThemeBloc>(
        create: (_) => ThemeBloc(storageService: resolvedStorageService),
      ),
      BlocProvider<InstructorCoursesBloc>(
        create: (_) => InstructorCoursesBloc(
          enrollmentService: _FakeEnrollmentService(loader: loader),
          assignmentService: _FakeAssignmentService(),
          labService: _FakeLabService(),
        ),
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
      home: InstructorCoursesScreen(storageService: resolvedStorageService),
    ),
  );
}

UserDto _userWithRole(String roleName) {
  return UserDto(
    userId: 1,
    email: 'role@example.com',
    firstName: 'Role',
    lastName: 'User',
    roles: <RoleModel>[RoleModel(roleId: 1, roleName: roleName)],
  );
}

void _setLargeViewport(WidgetTester tester) {
  _setViewport(tester, const Size(1400, 2600));
}

void _setViewport(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

@Timeout(Duration(seconds: 30))
void main() {
  testWidgets('shows loading skeleton while teaching courses load', (
    WidgetTester tester,
  ) async {
    _setLargeViewport(tester);

    final completer = Completer<ServiceResult<List<TeachingCourseModel>>>();

    await tester.pumpWidget(_buildScreen(loader: () => completer.future));

    await tester.pump();

    expect(find.byType(CourseSkeletonCard), findsWidgets);

    completer.complete(
      ServiceResult<List<TeachingCourseModel>>.success(
        const <TeachingCourseModel>[],
      ),
    );
    await tester.pumpAndSettle();
  });

  testWidgets('shows loaded state with live course data', (
    WidgetTester tester,
  ) async {
    _setLargeViewport(tester);

    await tester.pumpWidget(
      _buildScreen(
        loader: () async => ServiceResult<List<TeachingCourseModel>>.success(
          <TeachingCourseModel>[_teachingCourse()],
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Advanced Topics'), findsWidgets);
    expect(find.textContaining('CS500'), findsWidgets);
  });

  testWidgets('shows empty state when instructor has no courses', (
    WidgetTester tester,
  ) async {
    _setLargeViewport(tester);

    await tester.pumpWidget(
      _buildScreen(
        loader: () async => ServiceResult<List<TeachingCourseModel>>.success(
          const <TeachingCourseModel>[],
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No courses assigned yet'), findsOneWidget);
  });

  testWidgets('shows error state with retry when request fails', (
    WidgetTester tester,
  ) async {
    _setLargeViewport(tester);

    await tester.pumpWidget(
      _buildScreen(
        loader: () async => ServiceResult<List<TeachingCourseModel>>.failure(
          const ServiceError(
            type: ServiceErrorType.network,
            message: 'network down',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Unable to load courses'), findsOneWidget);
    expect(find.text('network down'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('blocks student role from instructor courses screen', (
    WidgetTester tester,
  ) async {
    _setLargeViewport(tester);

    await tester.pumpWidget(
      _buildScreen(
        loader: () async => ServiceResult<List<TeachingCourseModel>>.success(
          <TeachingCourseModel>[_teachingCourse()],
        ),
        storageService: _FakeStorageService(user: _userWithRole('student')),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Access Denied'), findsOneWidget);
  });

  testWidgets('renders correctly across 375, 768, and 1024+ widths', (
    WidgetTester tester,
  ) async {
    const sizes = <Size>[Size(375, 812), Size(768, 1024), Size(1280, 800)];

    for (final size in sizes) {
      _setViewport(tester, size);

      await tester.pumpWidget(
        _buildScreen(
          loader: () async => ServiceResult<List<TeachingCourseModel>>.success(
            <TeachingCourseModel>[_teachingCourse()],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Advanced Topics'), findsWidgets);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('maintains minimum 48x48 touch targets for top controls', (
    WidgetTester tester,
  ) async {
    _setViewport(tester, const Size(375, 812));

    await tester.pumpWidget(
      _buildScreen(
        loader: () async => ServiceResult<List<TeachingCourseModel>>.success(
          <TeachingCourseModel>[_teachingCourse()],
        ),
      ),
    );
    await tester.pumpAndSettle();

    final toggleKeys = <String>[
      'view-toggle-grid',
      'view-toggle-list',
      'view-toggle-compact',
    ];

    for (final key in toggleKeys) {
      final size = tester.getSize(find.byKey(ValueKey<String>(key)));
      expect(size.width >= 48, isTrue);
      expect(size.height >= 48, isTrue);
    }

    final fabSize = tester.getSize(find.byType(FloatingActionButton));
    expect(fabSize.width >= 48, isTrue);
    expect(fabSize.height >= 48, isTrue);
  });
}
