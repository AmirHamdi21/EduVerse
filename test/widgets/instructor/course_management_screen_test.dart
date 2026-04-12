import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/instructor/instructor_courses_bloc.dart';
import 'package:edu_verse/bloc/materials/materials_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/models/assignments/assignment_model.dart';
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
import 'package:edu_verse/services/api/enrollment_service.dart';
import 'package:edu_verse/services/api/lab_service.dart';
import 'package:edu_verse/services/api/material_service.dart';
import 'package:edu_verse/services/storage_service.dart';

class _FakeStorageService extends StorageService {
  @override
  Future<bool> getDarkMode() async => false;

  @override
  Future<int> getFontSize() async => 1;

  @override
  Future<void> setDarkMode(bool isDark) async {}

  @override
  Future<void> setFontSize(int sizeIndex) async {}
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
  _FakeMaterialService() : super(coreApiClient: CoreApiClient.test());

  @override
  Future<List<CourseMaterialModel>> getMaterials(
    dynamic courseId, {
    String? materialType,
    int? weekNumber,
    String? search,
  }) async {
    return const <CourseMaterialModel>[];
  }
}

Widget _buildScreen() {
  final themeBloc = ThemeBloc(storageService: _FakeStorageService());
  final materialService = _FakeMaterialService();

  return MultiBlocProvider(
    providers: <BlocProvider<dynamic>>[
      BlocProvider<ThemeBloc>.value(value: themeBloc),
      BlocProvider<InstructorCoursesBloc>(
        create: (_) => InstructorCoursesBloc(
          enrollmentService: _FakeEnrollmentService(),
          assignmentService: _FakeAssignmentService(),
          labService: _FakeLabService(),
          materialService: materialService,
        ),
      ),
      BlocProvider<MaterialsBloc>(
        create: (_) => MaterialsBloc(materialService: materialService),
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
      home: const CourseManagementScreen(
        course: InstructorCourseModel(
          id: 'non-numeric',
          code: 'CS401',
          name: 'Compiler Design',
          totalStudents: 22,
          colorValue: 0xFF155CFB,
        ),
      ),
    ),
  );
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
}
