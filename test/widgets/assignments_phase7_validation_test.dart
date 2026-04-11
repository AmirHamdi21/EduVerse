import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:edu_verse/screens/student/assignments_screen.dart';
import 'package:edu_verse/services/api/assignment_service.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/storage_service.dart';
import 'package:edu_verse/widgets/student/assignments/assignment_card.dart';

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

class _Phase7FakeAssignmentService extends AssignmentService {
  _Phase7FakeAssignmentService({
    required this.assignments,
    this.delay = Duration.zero,
    this.submissions = const <int, AssignmentSubmissionModel>{},
  }) : super(coreApiClient: CoreApiClient.test());

  final List<AssignmentModel> assignments;
  final Duration delay;
  final Map<int, AssignmentSubmissionModel> submissions;

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
    dynamic assignmentId,
  ) async {
    final id = assignmentId is int
        ? assignmentId
        : int.tryParse(assignmentId.toString()) ?? 0;

    final submission = submissions[id];
    if (submission == null) {
      return ServiceResult<AssignmentSubmissionModel>.failure(
        const ServiceError(
          type: ServiceErrorType.server,
          statusCode: 404,
          message: 'No submission found',
        ),
      );
    }

    return ServiceResult<AssignmentSubmissionModel>.success(submission);
  }
}

AssignmentModel _assignment({
  required String title,
  required DateTime dueDate,
}) {
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
    dueDate: dueDate,
    maxGrade: 100,
    createdAt: DateTime(2026, 1, 1),
    apiStatus: api.AssignmentStatus.published,
    submissionType: api.SubmissionType.text,
    lateSubmissionAllowed: true,
    maxFileSizeMb: 10,
  );
}

Widget _buildAssignmentsScreen(AssignmentService assignmentService) {
  final themeBloc = ThemeBloc(storageService: _FakeStorageService());
  final assignmentBloc = AssignmentBloc(assignmentService: assignmentService);

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

Future<void> _pumpForWidth(WidgetTester tester, Size size, String title) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() async {
    await tester.binding.setSurfaceSize(null);
  });

  final service = _Phase7FakeAssignmentService(
    assignments: <AssignmentModel>[
      _assignment(
        title: title,
        dueDate: DateTime.now().add(const Duration(days: 2)),
      ),
    ],
  );

  await tester.pumpWidget(_buildAssignmentsScreen(service));
  await tester.pumpAndSettle();
}

void _expectMinTouchTarget(WidgetTester tester, Finder finder, String label) {
  final size = tester.getSize(finder);
  expect(size.width, greaterThanOrEqualTo(48), reason: '$label width < 48');
  expect(size.height, greaterThanOrEqualTo(48), reason: '$label height < 48');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/url_launcher'),
          (MethodCall methodCall) async {
            return true;
          },
        );
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/url_launcher'),
          null,
        );
  });

  testWidgets('T075: screen renders correctly at 375px width', (
    WidgetTester tester,
  ) async {
    await _pumpForWidth(tester, const Size(375, 812), 'Assignment 375');

    expect(find.text('Assignment 375'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('T076: screen renders correctly at 768px width', (
    WidgetTester tester,
  ) async {
    await _pumpForWidth(tester, const Size(768, 1024), 'Assignment 768');

    expect(find.text('Assignment 768'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('T077: screen renders correctly at 1024px+ width', (
    WidgetTester tester,
  ) async {
    await _pumpForWidth(tester, const Size(1200, 900), 'Assignment 1024');

    expect(find.text('Assignment 1024'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('T078: interactive controls meet 48x48 touch target minimum', (
    WidgetTester tester,
  ) async {
    await _pumpForWidth(
      tester,
      const Size(375, 812),
      'Touch Target Assignment',
    );

    final backTarget = find
        .ancestor(
          of: find.byIcon(Icons.arrow_back_ios_rounded),
          matching: find.byType(InkWell),
        )
        .first;
    final searchTarget = find
        .ancestor(
          of: find.byIcon(Icons.search_rounded),
          matching: find.byType(InkWell),
        )
        .first;
    final filterTarget = find
        .ancestor(
          of: find.byIcon(Icons.tune_rounded),
          matching: find.byType(InkWell),
        )
        .first;
    final cardTarget = find
        .descendant(
          of: find.byType(AssignmentCard),
          matching: find.byType(InkWell),
        )
        .first;

    _expectMinTouchTarget(tester, backTarget, 'Back button');
    _expectMinTouchTarget(tester, searchTarget, 'Search button');
    _expectMinTouchTarget(tester, filterTarget, 'Filter button');
    _expectMinTouchTarget(tester, cardTarget, 'Assignment card tap area');

    final tabBarSize = tester.getSize(find.byType(TabBar));
    expect(tabBarSize.height, greaterThanOrEqualTo(48));
  });

  testWidgets('T079: assignment list first render is below 3 seconds', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(375, 812));

    final service = _Phase7FakeAssignmentService(
      delay: const Duration(milliseconds: 250),
      assignments: <AssignmentModel>[
        _assignment(
          title: 'Performance Assignment',
          dueDate: DateTime.now().add(const Duration(days: 3)),
        ),
      ],
    );

    final stopwatch = Stopwatch()..start();
    await tester.pumpWidget(_buildAssignmentsScreen(service));

    while (find.text('Performance Assignment').evaluate().isEmpty &&
        stopwatch.elapsed < const Duration(seconds: 3)) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    stopwatch.stop();

    expect(find.text('Performance Assignment'), findsOneWidget);
    expect(stopwatch.elapsed, lessThan(const Duration(seconds: 3)));

    // ignore: avoid_print
    print('T079 measured_load_ms=${stopwatch.elapsedMilliseconds}');
  });
}
