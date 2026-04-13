import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/course_structure/course_structure_bloc.dart';
import 'package:edu_verse/bloc/instructor/instructor_courses_bloc.dart';
import 'package:edu_verse/bloc/materials/materials_bloc.dart';
import 'package:edu_verse/bloc/materials/materials_state.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/models/assignments/assignment_model.dart';
import 'package:edu_verse/models/auth_models.dart';
import 'package:edu_verse/models/core/course_structure_model.dart';
import 'package:edu_verse/models/core/paginated_response.dart';
import 'package:edu_verse/models/instructor/teaching_course_model.dart';
import 'package:edu_verse/models/labs/lab_model.dart';
import 'package:edu_verse/models/materials/course_material_model.dart';
import 'package:edu_verse/screens/instructor/upload_materials/upload_materials_screen.dart';
import 'package:edu_verse/services/api/assignment_service.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
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
  _FakeEnrollmentService({required this.courses})
    : super(coreApiClient: CoreApiClient.test());

  final List<TeachingCourseModel> courses;

  @override
  Future<ServiceResult<List<TeachingCourseModel>>> getTeachingCourses() async {
    return ServiceResult<List<TeachingCourseModel>>.success(courses);
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
      PaginatedResponse<AssignmentModel>(
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

class _FakeMaterialService extends MaterialService {
  _FakeMaterialService({
    this.materials = const <CourseMaterialModel>[],
    this.delay = Duration.zero,
    this.failureMessage,
  }) : super(coreApiClient: CoreApiClient.test());

  final List<CourseMaterialModel> materials;
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

    return List<CourseMaterialModel>.from(materials);
  }
}

class _FakeCourseService extends CourseService {
  _FakeCourseService({required this.items})
    : super(coreApiClient: CoreApiClient.test());

  final List<CourseStructureModel> items;

  @override
  Future<List<CourseStructureModel>> getStructure(
    dynamic courseId, {
    bool forceRefresh = false,
  }) async {
    return items;
  }
}

TeachingCourseModel _teachingCourse() {
  return TeachingCourseModel.fromJson(<String, dynamic>{
    'sectionId': 12,
    'userId': 7,
    'courseId': 56,
    'role': 'instructor',
    'enrolledCount': 22,
    'capacity': 30,
    'course': <String, dynamic>{
      'id': 56,
      'departmentId': 1,
      'code': 'CS401',
      'name': 'Compiler Design',
      'credits': 3,
      'level': 'senior',
      'status': 'active',
    },
    'section': <String, dynamic>{
      'id': 12,
      'courseId': 56,
      'semesterId': 1,
      'sectionNumber': 'A',
      'maxCapacity': 30,
      'currentEnrollment': 22,
      'status': 'active',
    },
    'semester': <String, dynamic>{
      'id': 1,
      'name': 'Spring 2026',
      'term': 'spring',
      'year': 2026,
    },
  });
}

Widget _buildScreen({
  StorageService? storageService,
  MaterialService? materialService,
}) {
  final resolvedStorageService = storageService ?? _FakeStorageService();
  final resolvedMaterialService = materialService ?? _FakeMaterialService();

  final themeBloc = ThemeBloc(storageService: resolvedStorageService);
  final instructorBloc = InstructorCoursesBloc(
    enrollmentService: _FakeEnrollmentService(
      courses: <TeachingCourseModel>[_teachingCourse()],
    ),
    assignmentService: _FakeAssignmentService(),
    labService: _FakeLabService(),
    materialService: resolvedMaterialService,
  );
  final materialsBloc = MaterialsBloc(materialService: resolvedMaterialService);
  final structureBloc = CourseStructureBloc(
    courseService: _FakeCourseService(
      items: <CourseStructureModel>[
        const CourseStructureModel(
          organizationId: 1,
          courseId: '56',
          organizationType: 'lecture',
          title: 'Week 1 Intro',
          weekNumber: 1,
          orderIndex: 1,
        ),
      ],
    ),
  );

  return MultiBlocProvider(
    providers: <BlocProvider<dynamic>>[
      BlocProvider<ThemeBloc>.value(value: themeBloc),
      BlocProvider<InstructorCoursesBloc>.value(value: instructorBloc),
      BlocProvider<MaterialsBloc>.value(value: materialsBloc),
      BlocProvider<CourseStructureBloc>.value(value: structureBloc),
    ],
    child: MaterialApp(
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[Locale('en'), Locale('ar')],
      home: UploadMaterialsScreen(storageService: resolvedStorageService),
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
  testWidgets('shows week selector and all upload option paths', (
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

    expect(find.text('No Week (Course Level)'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Upload Files'), findsWidgets);
    expect(find.text('Upload Folder'), findsWidgets);
    expect(find.text('Add Link'), findsWidgets);
  });

  testWidgets('blocks student role from upload materials screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildScreen(
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
          storageService: _FakeStorageService(
            user: _userWithRole('teaching_assistant'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Week (Course Level)'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('maintains minimum 48x48 touch targets for upload actions', (
    WidgetTester tester,
  ) async {
    _setViewport(tester, const Size(375, 812));

    await tester.pumpWidget(
      _buildScreen(
        storageService: _FakeStorageService(
          user: _userWithRole('teaching_assistant'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final selectVideoButton = find.byKey(
      const ValueKey<String>('video-select-button'),
    );
    final pickBundleButton = find.byKey(
      const ValueKey<String>('bundle-pick-files-button'),
    );

    expect(selectVideoButton, findsOneWidget);
    expect(pickBundleButton, findsOneWidget);

    final videoSize = tester.getSize(selectVideoButton);
    final bundleSize = tester.getSize(pickBundleButton);

    expect(videoSize.height >= 48, isTrue);
    expect(bundleSize.height >= 48, isTrue);
  });

  testWidgets('keeps materials tab responsive while MaterialsBloc is loading', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildScreen(
        storageService: _FakeStorageService(
          user: _userWithRole('teaching_assistant'),
        ),
        materialService: _FakeMaterialService(
          delay: const Duration(seconds: 5),
        ),
      ),
    );
    await tester.pump();

    final materialsState = BlocProvider.of<MaterialsBloc>(
      tester.element(find.byType(UploadMaterialsScreen)),
    ).state;
    expect(materialsState, isA<MaterialsLoading>());

    final materialsTab = find.descendant(
      of: find.byType(TabBar),
      matching: find.text('Materials'),
    );
    await tester.ensureVisible(materialsTab);
    await tester.tap(materialsTab);
    await tester.pump(const Duration(milliseconds: 350));

    final stateAfterTabSwitch = BlocProvider.of<MaterialsBloc>(
      tester.element(find.byType(UploadMaterialsScreen)),
    ).state;
    expect(stateAfterTabSwitch, isA<MaterialsLoading>());
    expect(tester.takeException(), isNull);

    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('shows error state feedback when MaterialsBloc emits error', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildScreen(
        storageService: _FakeStorageService(
          user: _userWithRole('teaching_assistant'),
        ),
        materialService: _FakeMaterialService(
          failureMessage: 'materials load failed',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('materials load failed'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Upload Files'), findsWidgets);
  });

  testWidgets(
    'shows empty materials state when loaded materials list is empty',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildScreen(
          storageService: _FakeStorageService(
            user: _userWithRole('teaching_assistant'),
          ),
          materialService: _FakeMaterialService(
            materials: const <CourseMaterialModel>[],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Materials').first);
      await tester.pumpAndSettle();

      expect(find.text('No Materials Yet'), findsOneWidget);
    },
  );
}
