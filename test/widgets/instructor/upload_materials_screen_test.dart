import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/course_structure/course_structure_bloc.dart';
import 'package:edu_verse/bloc/instructor/instructor_courses_bloc.dart';
import 'package:edu_verse/bloc/materials/materials_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/models/assignments/assignment_model.dart';
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

Widget _buildScreen() {
  final materialService = _FakeMaterialService();

  final themeBloc = ThemeBloc(storageService: _FakeStorageService());
  final instructorBloc = InstructorCoursesBloc(
    enrollmentService: _FakeEnrollmentService(
      courses: <TeachingCourseModel>[_teachingCourse()],
    ),
    assignmentService: _FakeAssignmentService(),
    labService: _FakeLabService(),
    materialService: materialService,
  );
  final materialsBloc = MaterialsBloc(materialService: materialService);
  final structureBloc = CourseStructureBloc(
    courseService: _FakeCourseService(
      items: <CourseStructureModel>[
        const CourseStructureModel(
          organizationId: '1',
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
      home: const UploadMaterialsScreen(),
    ),
  );
}

void main() {
  testWidgets('shows week selector and all upload option paths', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('No Week (Course Level)'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Upload Files'), findsWidgets);
    expect(find.text('Upload Folder'), findsWidgets);
    expect(find.text('Add Link'), findsWidgets);
  });
}
