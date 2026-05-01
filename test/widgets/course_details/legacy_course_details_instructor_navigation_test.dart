import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:edu_verse/bloc/courses/courses_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/models/admin/admin_periods_models.dart';
import 'package:edu_verse/models/core/course_structure_model.dart';
import 'package:edu_verse/models/core/enrollment_model.dart';
import 'package:edu_verse/models/courses/instructor_assignment_model.dart';
import 'package:edu_verse/models/materials/announcement_model.dart';
import 'package:edu_verse/models/materials/course_material_model.dart';
import 'package:edu_verse/models/ta/ta_assignment_model.dart';
import 'package:edu_verse/screens/student/course_details_screen.dart';
import 'package:edu_verse/services/api/communication_service.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/course_service.dart';
import 'package:edu_verse/services/api/enrollment_service.dart';
import 'package:edu_verse/services/api/material_service.dart';
import 'package:edu_verse/services/api/office_hours_service.dart';
import 'package:edu_verse/services/api/public_profile_service.dart';
import 'package:edu_verse/services/storage_service.dart';

class _StubCourseService extends CourseService {
  _StubCourseService() : super(coreApiClient: CoreApiClient.test());

  @override
  Future<List<CourseStructureModel>> getCourseStructure(
    dynamic courseId, {
    bool forceRefresh = false,
  }) async {
    return const <CourseStructureModel>[];
  }
}

class _StubMaterialService extends MaterialService {
  _StubMaterialService() : super(coreApiClient: CoreApiClient.test());

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

class _StubEnrollmentService extends EnrollmentService {
  _StubEnrollmentService() : super(coreApiClient: CoreApiClient.test());

  @override
  Future<ServiceResult<List<InstructorAssignmentModel>>> getSectionInstructors(
    dynamic sectionId,
  ) async {
    return ServiceResult<List<InstructorAssignmentModel>>.success(
      const <InstructorAssignmentModel>[
        InstructorAssignmentModel(
          id: 1,
          sectionId: 11,
          userId: 7,
          role: 'primary',
          firstName: 'Lina',
          lastName: 'Ali',
          email: 'lina@eduverse.test',
        ),
      ],
    );
  }

  @override
  Future<ServiceResult<List<TAAssignmentModel>>> getSectionTAs(
    dynamic sectionId,
  ) async {
    return ServiceResult<List<TAAssignmentModel>>.success(
      const <TAAssignmentModel>[],
    );
  }
}

class _StubCommunicationService extends CommunicationService {
  _StubCommunicationService() : super(coreApiClient: CoreApiClient.test());

  @override
  Future<List<AnnouncementModel>> getAnnouncementsByCourseId(
    dynamic courseId,
  ) async {
    return const <AnnouncementModel>[];
  }
}

class _StubPublicProfileService extends PublicProfileService {
  _StubPublicProfileService() : super(coreApiClient: CoreApiClient.test());
}

class _StubOfficeHoursService extends OfficeHoursService {
  _StubOfficeHoursService() : super(coreApiClient: CoreApiClient.test());

  @override
  Future<List<OfficeHourAppointmentModel>> getMyAppointments() async {
    return const <OfficeHourAppointmentModel>[];
  }
}

CourseEnrollmentModel _sampleEnrollment({int sectionId = 11}) {
  return CourseEnrollmentModel.fromJson(<String, dynamic>{
    'id': 1,
    'userId': 42,
    'sectionId': sectionId,
    'status': 'enrolled',
    'enrollmentDate': '2026-04-01T00:00:00.000Z',
    'course': <String, dynamic>{
      'id': 101,
      'departmentId': 1,
      'code': 'CS101',
      'name': 'Introduction to CS',
      'credits': 3,
      'level': 'beginner',
      'status': 'active',
      'instructorId': 7,
      'department': <String, dynamic>{'name': 'Computer Science'},
    },
    'section': <String, dynamic>{
      'id': 11,
      'courseId': 101,
      'semesterId': 2,
      'sectionNumber': 'A',
      'maxCapacity': 35,
      'currentEnrollment': 24,
      'status': 'active',
    },
    'semester': <String, dynamic>{'id': 2, 'name': 'Spring 2026'},
  });
}

void main() {
  testWidgets(
    'legacy course details opens instructor info route',
    (WidgetTester tester) async {
      final themeBloc = ThemeBloc(storageService: StorageService());
      final coursesBloc = CoursesBloc(
        courseService: _StubCourseService(),
        enrollmentService: _StubEnrollmentService(),
        materialService: _StubMaterialService(),
        communicationService: _StubCommunicationService(),
        publicProfileService: _StubPublicProfileService(),
        officeHoursService: _StubOfficeHoursService(),
      );
      Map<String, dynamic>? instructorPayload;

      final router = GoRouter(
        initialLocation: '/details',
        routes: <RouteBase>[
          GoRoute(
            path: '/details',
            builder: (context, state) {
              return MultiBlocProvider(
                providers: <BlocProvider<dynamic>>[
                  BlocProvider<ThemeBloc>.value(value: themeBloc),
                  BlocProvider<CoursesBloc>.value(value: coursesBloc),
                ],
                child: CourseDetailsScreen(
                  enrollment: _sampleEnrollment(sectionId: 77),
                  initialTab: 0,
                ),
              );
            },
          ),
          GoRoute(
            path: '/course-instructor-info',
            builder: (context, state) {
              instructorPayload = (state.extra as Map<dynamic, dynamic>)
                  .cast<String, dynamic>();
              return const Scaffold(
                body: Center(child: Text('Instructor Route Hit')),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Overview'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Open profile & booking'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open profile & booking'));
      await tester.pumpAndSettle();

      expect(find.text('Instructor Route Hit'), findsOneWidget);
      expect(instructorPayload, isNotNull);
      expect(instructorPayload!['instructorId'], 7);
      expect(instructorPayload!['instructorName'], 'Lina Ali');
      expect(instructorPayload!['courseId'], 101);
      expect(instructorPayload!['sectionId'], 11);
      expect(instructorPayload!['staffRole'], 'instructor');

      coursesBloc.close();
      themeBloc.close();
    },
    timeout: const Timeout(Duration(seconds: 20)),
  );
}
