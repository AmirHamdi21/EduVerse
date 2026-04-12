import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/course_structure/course_structure_bloc.dart';
import 'package:edu_verse/bloc/course_structure/course_structure_state.dart';
import 'package:edu_verse/bloc/courses/courses_bloc.dart';
import 'package:edu_verse/bloc/instructor/instructor_courses_bloc.dart';
import 'package:edu_verse/bloc/materials/materials_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/models/assignments/assignment_model.dart';
import 'package:edu_verse/models/auth_models.dart';
import 'package:edu_verse/models/core/course_structure_model.dart';
import 'package:edu_verse/models/core/enums/assignment_enums.dart'
    as assignment_api;
import 'package:edu_verse/models/core/paginated_response.dart';
import 'package:edu_verse/models/instructor/instructor_course_model.dart'
    hide AssignmentModel;
import 'package:edu_verse/models/instructor/teaching_course_model.dart';
import 'package:edu_verse/models/labs/lab_model.dart';
import 'package:edu_verse/models/materials/course_material_model.dart';
import 'package:edu_verse/screens/instructor/course_management/course_management_screen.dart';
import 'package:edu_verse/services/api/assignment_service.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/communication_service.dart';
import 'package:edu_verse/services/api/course_service.dart';
import 'package:edu_verse/services/api/enrollment_service.dart';
import 'package:edu_verse/services/api/lab_service.dart';
import 'package:edu_verse/services/api/material_service.dart';
import 'package:edu_verse/services/storage_service.dart';

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
  _FakeEnrollmentService() : super(coreApiClient: CoreApiClient.test());

  @override
  Future<ServiceResult<List<TeachingCourseModel>>> getTeachingCourses() async {
    return ServiceResult<List<TeachingCourseModel>>.success(
      const <TeachingCourseModel>[],
    );
  }
}

class _FakeAssignmentService extends AssignmentService {
  _FakeAssignmentService() : super(coreApiClient: CoreApiClient.test());

  @override
  Future<ServiceResult<PaginatedResponse<AssignmentModel>>> getAll({
    int? courseId,
    int? sectionId,
    assignment_api.AssignmentStatus? status,
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
  Future<ServiceResult<List<LabModel>>> getAll({int? courseId}) async {
    return ServiceResult<List<LabModel>>.success(const <LabModel>[]);
  }
}

class _FakeMaterialService extends MaterialService {
  _FakeMaterialService(
    this._materials, {
    this.delay = Duration.zero,
    this.failureMessage,
  }) : super(coreApiClient: CoreApiClient.test());

  final List<CourseMaterialModel> _materials;
  final Duration delay;
  final String? failureMessage;

  @override
  Future<List<CourseMaterialModel>> getMaterials(
    dynamic courseId, {
    String? materialType,
    int? weekNumber,
    String? search,
  }) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }

    if (failureMessage != null) {
      throw Exception(failureMessage!);
    }

    return List<CourseMaterialModel>.from(_materials);
  }
}

class _FakeCourseService extends CourseService {
  _FakeCourseService({
    this.items = const <CourseStructureModel>[],
    this.delay = Duration.zero,
    this.failureMessage,
  }) : super(coreApiClient: CoreApiClient.test());

  final List<CourseStructureModel> items;
  final Duration delay;
  final String? failureMessage;

  @override
  Future<List<CourseStructureModel>> getStructure(
    dynamic courseId, {
    bool forceRefresh = false,
  }) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }

    if (failureMessage != null) {
      throw Exception(failureMessage!);
    }

    return List<CourseStructureModel>.from(items);
  }
}

Widget _buildScreen({
  int? courseId,
  List<CourseMaterialModel> materials = const <CourseMaterialModel>[],
  StorageService? storageService,
  CourseService? courseService,
  MaterialService? materialService,
}) {
  final resolvedStorageService = storageService ?? _FakeStorageService();
  final themeBloc = ThemeBloc(storageService: resolvedStorageService);
  final resolvedMaterialService =
      materialService ?? _FakeMaterialService(materials);
  final resolvedCourseService = courseService ?? _FakeCourseService();
  final enrollmentService = _FakeEnrollmentService();
  final communicationService = CommunicationService(
    coreApiClient: CoreApiClient.test(),
  );

  return MultiBlocProvider(
    providers: <BlocProvider<dynamic>>[
      BlocProvider<ThemeBloc>.value(value: themeBloc),
      BlocProvider<CoursesBloc>(
        create: (_) => CoursesBloc(
          courseService: resolvedCourseService,
          enrollmentService: enrollmentService,
          materialService: resolvedMaterialService,
          communicationService: communicationService,
        ),
      ),
      BlocProvider<InstructorCoursesBloc>(
        create: (_) => InstructorCoursesBloc(
          enrollmentService: enrollmentService,
          assignmentService: _FakeAssignmentService(),
          labService: _FakeLabService(),
          materialService: resolvedMaterialService,
        ),
      ),
      BlocProvider<MaterialsBloc>(
        create: (_) => MaterialsBloc(materialService: resolvedMaterialService),
      ),
      BlocProvider<CourseStructureBloc>(
        create: (_) =>
            CourseStructureBloc(courseService: resolvedCourseService),
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
      home: CourseManagementScreen(
        courseId: courseId,
        storageService: resolvedStorageService,
        course: InstructorCourseModel(
          id: (courseId ?? 0) > 0 ? '$courseId' : 'non-numeric',
          code: 'CS401',
          name: 'Compiler Design',
          totalStudents: 22,
          colorValue: 0xFF155CFB,
        ),
      ),
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

void _setViewport(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

void main() {
  testWidgets('shows five tabs and coming soon placeholders', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('Overview'), findsWidgets);
    expect(find.text('Lectures'), findsWidgets);
    expect(find.text('Assignments'), findsWidgets);
    expect(find.text('Grading'), findsWidgets);
    expect(find.text('Students'), findsWidgets);

    final lecturesTab = find.descendant(
      of: find.byType(TabBar),
      matching: find.text('Lectures'),
    );
    expect(lecturesTab, findsOneWidget);
    await tester.ensureVisible(lecturesTab);
    await tester.tap(lecturesTab);
    await tester.pumpAndSettle();
    expect(find.text('No materials yet'), findsOneWidget);

    final assignmentsTab = find.descendant(
      of: find.byType(TabBar),
      matching: find.text('Assignments'),
    );
    expect(assignmentsTab, findsOneWidget);
    await tester.ensureVisible(assignmentsTab);
    await tester.tap(assignmentsTab);
    await tester.pumpAndSettle();
    expect(find.text('Assignments management coming soon'), findsOneWidget);

    final gradingTab = find.descendant(
      of: find.byType(TabBar),
      matching: find.text('Grading'),
    );
    expect(gradingTab, findsOneWidget);
    await tester.ensureVisible(gradingTab);
    await tester.tap(gradingTab);
    await tester.pumpAndSettle();
    expect(find.text('Grading coming soon'), findsOneWidget);
  });

  testWidgets('teaching assistant cannot see delete action in settings', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildScreen(
        storageService: _FakeStorageService(
          user: _userWithRole('teaching_assistant'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('Delete'), findsNothing);
  });

  testWidgets('renders correctly across 375, 768, and 1024+ widths', (
    WidgetTester tester,
  ) async {
    const sizes = <Size>[Size(375, 812), Size(768, 1024), Size(1280, 800)];

    for (final size in sizes) {
      _setViewport(tester, size);

      await tester.pumpWidget(
        _buildScreen(
          courseId: 56,
          materials: <CourseMaterialModel>[
            CourseMaterialModel(
              materialId: 'm1',
              courseId: '56',
              materialType: 'video',
              title: 'Week 1 - Intro - Video',
              weekNumber: 1,
              isPublished: true,
              createdAt: DateTime(2026, 1, 1),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Overview'), findsWidgets);
      expect(find.text('Lectures'), findsWidgets);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('shows loading indicator in lectures tab while structure loads', (
    WidgetTester tester,
  ) async {
    _setViewport(tester, const Size(1280, 1200));

    await tester.pumpWidget(
      _buildScreen(
        courseId: 56,
        courseService: _FakeCourseService(delay: const Duration(seconds: 5)),
      ),
    );
    await tester.pump();

    final lecturesTab = find.descendant(
      of: find.byType(TabBar),
      matching: find.text('Lectures'),
    );
    await tester.ensureVisible(lecturesTab);
    await tester.tap(lecturesTab);
    await tester.pump();

    final structureState = BlocProvider.of<CourseStructureBloc>(
      tester.element(find.byType(CourseManagementScreen)),
    ).state;
    expect(structureState, isA<StructureLoading>());
    expect(tester.takeException(), isNull);

    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('shows structure error with retry action when load fails', (
    WidgetTester tester,
  ) async {
    _setViewport(tester, const Size(1280, 1200));

    await tester.pumpWidget(
      _buildScreen(
        courseId: 56,
        courseService: _FakeCourseService(failureMessage: 'structure failed'),
      ),
    );
    await tester.pumpAndSettle();

    final lecturesTab = find.descendant(
      of: find.byType(TabBar),
      matching: find.text('Lectures'),
    );
    await tester.ensureVisible(lecturesTab);
    await tester.tap(lecturesTab);
    await tester.pumpAndSettle();

    expect(find.text('Failed to load course structure'), findsOneWidget);
    expect(find.text('structure failed'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
