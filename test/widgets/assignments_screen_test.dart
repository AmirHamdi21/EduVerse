import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/assignments/assignment_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/models/assignments/assignment_model.dart';
import 'package:edu_verse/models/assignments/assignment_submission_model.dart';
import 'package:edu_verse/models/core/course_model.dart';
import 'package:edu_verse/models/core/enums/assignment_enums.dart' as api;
import 'package:edu_verse/models/core/enums/course_enums.dart';
import 'package:edu_verse/models/core/enums/enrollment_enums.dart';
import 'package:edu_verse/models/core/enrollment_model.dart';
import 'package:edu_verse/models/core/paginated_response.dart';
import 'package:edu_verse/screens/student/assignments_screen.dart';
import 'package:edu_verse/services/api/assignment_service.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/enrollment_service.dart';
import 'package:edu_verse/services/storage_service.dart';
import 'package:edu_verse/widgets/student/academic/academic_list_skeleton.dart';

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

class _FakeAssignmentService extends AssignmentService {
  _FakeAssignmentService({
    required this.assignments,
    this.delay = Duration.zero,
  }) : super(coreApiClient: CoreApiClient.test());

  final List<AssignmentModel> assignments;
  final Duration delay;

  @override
  Future<ServiceResult<PaginatedResponse<AssignmentModel>>> getAll({
    int? courseId,
    int? sectionId,
    api.AssignmentStatus? status,
    String? search,
    int? page,
    int? limit,
    String? sortBy,
    String? sortOrder,
    CancelToken? cancelToken,
  }) async {
    if (delay != Duration.zero) {
      await Future<void>.delayed(delay);
    }

    return ServiceResult<PaginatedResponse<AssignmentModel>>.success(
      PaginatedResponse<AssignmentModel>(
        data: assignments,
        total: assignments.length,
        page: 1,
        limit: assignments.isEmpty ? 1 : assignments.length,
        totalPages: 1,
      ),
    );
  }

  @override
  Future<ServiceResult<AssignmentSubmissionModel>> getMySubmission(
    dynamic assignmentId, {
    CancelToken? cancelToken,
  }) async {
    return ServiceResult<AssignmentSubmissionModel>.failure(
      const ServiceError(
        type: ServiceErrorType.server,
        statusCode: 404,
        message: 'No submission found',
      ),
    );
  }
}

class _FakeEnrollmentService extends EnrollmentService {
  _FakeEnrollmentService() : super(coreApiClient: CoreApiClient.test());

  @override
  Future<ServiceResult<List<CourseEnrollmentModel>>> getMyCourses({
    int? semester,
    CancelToken? cancelToken,
  }) async {
    return ServiceResult<List<CourseEnrollmentModel>>.success(
      <CourseEnrollmentModel>[
        CourseEnrollmentModel(
          id: '1',
          userId: 7,
          sectionId: 11,
          enrollmentStatus: EnrollmentStatus.enrolled,
          enrollmentDate: DateTime(2026, 1, 1),
          course: CourseModel(
            id: 1,
            departmentId: 1,
            code: 'CS301',
            name: 'Algorithms',
            credits: 3,
            courseLevel: CourseLevel.freshman,
            courseStatus: CourseStatus.active,
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
          ),
        ),
      ],
    );
  }
}

AssignmentModel _assignment({required String title}) {
  return AssignmentModel(
    id: '1',
    assignmentId: 1,
    courseId: 1,
    title: title,
    description: 'description',
    courseName: 'Algorithms',
    courseCode: 'CS301',
    instructorName: 'Dr. Ahmed',
    type: AssignmentType.document,
    status: AssignmentStatus.pending,
    priority: AssignmentPriority.medium,
    dueDate: DateTime.now().add(const Duration(days: 2)),
    maxGrade: 100,
    createdAt: DateTime(2026, 1, 1),
    apiStatus: api.AssignmentStatus.published,
    submissionType: api.SubmissionType.text,
    lateSubmissionAllowed: true,
    maxFileSizeMb: 10,
  );
}

Widget _buildScreen(AssignmentService assignmentService) {
  final themeBloc = ThemeBloc(storageService: _FakeStorageService());
  final assignmentBloc = AssignmentBloc(
    assignmentService: assignmentService,
    enrollmentService: _FakeEnrollmentService(),
  );

  return MultiBlocProvider(
    providers: [
      BlocProvider<ThemeBloc>.value(value: themeBloc),
      BlocProvider<AssignmentBloc>.value(value: assignmentBloc),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ar')],
      home: const AssignmentsScreen(),
    ),
  );
}

void main() {
  testWidgets('shows empty state when assignments list is empty', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildScreen(
        _FakeAssignmentService(assignments: const <AssignmentModel>[]),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.text(
        'No assignments are available yet. Enroll in a course to get started.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows loading then renders assignments list', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildScreen(
        _FakeAssignmentService(
          assignments: <AssignmentModel>[_assignment(title: 'Real Assignment')],
          delay: const Duration(milliseconds: 150),
        ),
      ),
    );

    await tester.pump();
    expect(find.byType(AcademicListSkeleton), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('Real Assignment'), findsOneWidget);
  });
}
