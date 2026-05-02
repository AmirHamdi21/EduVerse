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
import 'package:edu_verse/models/core/enums/assignment_enums.dart' as api;
import 'package:edu_verse/models/core/paginated_response.dart';
import 'package:edu_verse/screens/student/assignment_detail_screen.dart';
import 'package:edu_verse/services/api/assignment_service.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
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

class _FakeAssignmentService extends AssignmentService {
  _FakeAssignmentService({required this.assignment})
    : super(coreApiClient: CoreApiClient.test());

  final AssignmentModel assignment;

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
    return ServiceResult<PaginatedResponse<AssignmentModel>>.success(
      PaginatedResponse<AssignmentModel>(
        data: <AssignmentModel>[assignment],
        total: 1,
        page: 1,
        limit: 1,
        totalPages: 1,
      ),
    );
  }

  @override
  Future<ServiceResult<AssignmentModel>> getById(
    dynamic id, {
    CancelToken? cancelToken,
  }) async {
    return ServiceResult<AssignmentModel>.success(assignment);
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

AssignmentModel _assignment() {
  return AssignmentModel(
    id: '1',
    assignmentId: 1,
    courseId: 1,
    title: 'Binary Search Homework',
    description: 'Implement binary search.',
    instructionsText: '# Steps\n- Implement\n- Test',
    courseName: 'Algorithms',
    courseCode: 'CS301',
    instructorName: 'Dr. Ahmed',
    type: AssignmentType.document,
    status: AssignmentStatus.pending,
    priority: AssignmentPriority.medium,
    dueDate: DateTime.now().add(const Duration(days: 1)),
    maxGrade: 100,
    createdAt: DateTime(2026, 1, 1),
    apiStatus: api.AssignmentStatus.published,
    submissionType: api.SubmissionType.text,
    lateSubmissionAllowed: true,
    maxFileSizeMb: 10,
  );
}

void main() {
  testWidgets('renders assignment detail content and submit action', (
    WidgetTester tester,
  ) async {
    final assignment = _assignment();

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<ThemeBloc>(
            create: (_) => ThemeBloc(storageService: _FakeStorageService()),
          ),
          BlocProvider<AssignmentBloc>(
            create: (_) => AssignmentBloc(
              assignmentService: _FakeAssignmentService(assignment: assignment),
            ),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('ar')],
          home: AssignmentDetailScreen(assignment: assignment),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Assignment Details'), findsOneWidget);
    expect(find.text('Binary Search Homework'), findsOneWidget);
    expect(find.text('Instructions'), findsOneWidget);
    expect(find.text('Submit Assignment'), findsOneWidget);
  });
}
