import 'package:edu_verse/bloc/student_registration/student_registration_cubit.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/models/admin/admin_periods_models.dart';
import 'package:edu_verse/models/core/enrollment_model.dart';
import 'package:edu_verse/models/registration/registration_available_course_model.dart';
import 'package:edu_verse/screens/student/student_registration_screen.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/enrollment_service.dart';
import 'package:edu_verse/services/storage_service.dart';
import 'package:edu_verse/widgets/student/registration/registration_loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeEnrollmentService extends EnrollmentService {
  _FakeEnrollmentService() : super(coreApiClient: CoreApiClient.test());

  ServiceResult<List<CourseEnrollmentModel>> myEnrollmentsResult =
      ServiceResult.success(<CourseEnrollmentModel>[]);
  ServiceResult<List<RegistrationAvailableCourseModel>> availableCoursesResult =
      ServiceResult.success(<RegistrationAvailableCourseModel>[]);
  ServiceResult<List<EnrollmentPeriodModel>> periodsResult =
      ServiceResult.success(<EnrollmentPeriodModel>[]);

  Duration delay = Duration.zero;

  @override
  Future<ServiceResult<List<CourseEnrollmentModel>>> getMyEnrollments({
    int? semester,
  }) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    return myEnrollmentsResult;
  }

  @override
  Future<ServiceResult<List<RegistrationAvailableCourseModel>>>
  getAvailableCourses({
    int? departmentId,
    int? semesterId,
    String? search,
    String? level,
    int page = 1,
    int limit = 20,
  }) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    return availableCoursesResult;
  }

  @override
  Future<ServiceResult<List<EnrollmentPeriodModel>>>
  getEnrollmentPeriods() async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    return periodsResult;
  }
}

CourseEnrollmentModel _sampleEnrollment() {
  return CourseEnrollmentModel.fromJson(<String, dynamic>{
    'id': 150,
    'userId': 42,
    'sectionId': 31,
    'status': 'enrolled',
    'enrollmentDate': '2026-08-15T10:00:00.000Z',
    'canDrop': true,
    'course': <String, dynamic>{
      'id': 77,
      'name': 'Data Structures',
      'code': 'CS201',
      'description': 'Core data structures and analysis',
      'credits': 3,
      'level': 'sophomore',
    },
    'section': <String, dynamic>{
      'id': 31,
      'sectionNumber': 'A',
      'maxCapacity': 40,
      'currentEnrollment': 32,
      'location': 'B-201',
    },
    'semester': <String, dynamic>{
      'id': 2,
      'name': 'Fall 2026',
      'startDate': '2026-08-15T00:00:00.000Z',
      'endDate': '2026-12-20T00:00:00.000Z',
    },
  });
}

RegistrationAvailableCourseModel _sampleAvailableCourse({
  bool withMultipleSections = false,
}) {
  return RegistrationAvailableCourseModel.fromJson(<String, dynamic>{
    'id': 77,
    'name': 'Data Structures',
    'code': 'CS201',
    'description': 'Core data structures and analysis',
    'credits': 3,
    'level': 'sophomore',
    'departmentId': 1,
    'departmentName': 'Computer Science',
    'canEnroll': true,
    'enrollmentStatus': null,
    'prerequisites': <dynamic>[],
    'sections': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 31,
        'sectionNumber': 'A',
        'maxCapacity': 40,
        'currentEnrollment': 32,
        'availableSeats': 8,
        'location': 'B-201',
        'semesterId': 2,
        'semesterName': 'Fall 2026',
      },
      if (withMultipleSections)
        <String, dynamic>{
          'id': 32,
          'sectionNumber': 'B',
          'maxCapacity': 40,
          'currentEnrollment': 30,
          'availableSeats': 10,
          'location': 'B-203',
          'semesterId': 2,
          'semesterName': 'Fall 2026',
        },
    ],
  });
}

EnrollmentPeriodModel _samplePeriod() {
  return EnrollmentPeriodModel.fromSemesterJson(<String, dynamic>{
    'id': 2,
    'semesterName': 'Fall 2026',
    'registrationStart': '2026-07-20',
    'registrationEnd': '2026-08-10',
    'status': 'upcoming',
  });
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required _FakeEnrollmentService service,
}) async {
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<ThemeBloc>(
          create: (_) => ThemeBloc(storageService: StorageService()),
        ),
        BlocProvider<StudentRegistrationCubit>(
          create: (_) => StudentRegistrationCubit(enrollmentService: service),
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
        home: const StudentRegistrationScreen(),
      ),
    ),
  );
}

void main() {
  group('StudentRegistrationScreen', () {
    testWidgets('renders loading state before API completes', (tester) async {
      final service = _FakeEnrollmentService()
        ..delay = const Duration(milliseconds: 600)
        ..periodsResult = ServiceResult.success(<EnrollmentPeriodModel>[
          _samplePeriod(),
        ]);

      await _pumpScreen(tester, service: service);
      await tester.pump();

      expect(find.byType(StudentRegistrationScreen), findsOneWidget);
      expect(find.byType(RegistrationLoadingView), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();
    });

    testWidgets('renders empty states with no courses', (tester) async {
      final service = _FakeEnrollmentService()
        ..myEnrollmentsResult = ServiceResult.success(<CourseEnrollmentModel>[])
        ..availableCoursesResult = ServiceResult.success(
          <RegistrationAvailableCourseModel>[],
        )
        ..periodsResult = ServiceResult.success(<EnrollmentPeriodModel>[
          _samplePeriod(),
        ]);

      await _pumpScreen(tester, service: service);
      await tester.pumpAndSettle();

      expect(find.text('No available courses found'), findsOneWidget);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(find.text('No registered courses yet'), findsOneWidget);
    });

    testWidgets('renders available and registered course content', (
      tester,
    ) async {
      final service = _FakeEnrollmentService()
        ..myEnrollmentsResult = ServiceResult.success(<CourseEnrollmentModel>[
          _sampleEnrollment(),
        ])
        ..availableCoursesResult = ServiceResult.success(
          <RegistrationAvailableCourseModel>[_sampleAvailableCourse()],
        )
        ..periodsResult = ServiceResult.success(<EnrollmentPeriodModel>[
          _samplePeriod(),
        ]);

      await _pumpScreen(tester, service: service);
      await tester.pumpAndSettle();

      expect(find.text('Data Structures'), findsWidgets);
      expect(find.text('CS201'), findsWidgets);
      expect(find.text('Enroll Now'), findsOneWidget);
    });

    testWidgets('opens section selection sheet for multi-section course', (
      tester,
    ) async {
      final service = _FakeEnrollmentService()
        ..myEnrollmentsResult = ServiceResult.success(<CourseEnrollmentModel>[])
        ..availableCoursesResult = ServiceResult.success(
          <RegistrationAvailableCourseModel>[
            _sampleAvailableCourse(withMultipleSections: true),
          ],
        )
        ..periodsResult = ServiceResult.success(<EnrollmentPeriodModel>[
          _samplePeriod(),
        ]);

      await _pumpScreen(tester, service: service);
      await tester.pumpAndSettle();

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -420));
      await tester.pumpAndSettle();
      final enrollButton = find.byIcon(Icons.app_registration_rounded).first;
      await tester.ensureVisible(enrollButton);
      await tester.tap(enrollButton);
      await tester.pumpAndSettle();

      expect(find.text('Select section'), findsOneWidget);
      expect(find.text('Section B'), findsWidgets);
    });

    testWidgets('shows backend error message on load failure', (tester) async {
      final service = _FakeEnrollmentService()
        ..myEnrollmentsResult = ServiceResult.success(<CourseEnrollmentModel>[])
        ..availableCoursesResult =
            ServiceResult<List<RegistrationAvailableCourseModel>>.failure(
              const ServiceError(
                type: ServiceErrorType.server,
                statusCode: 400,
                message: 'Schedule conflict with existing enrollment',
              ),
            )
        ..periodsResult = ServiceResult.success(<EnrollmentPeriodModel>[
          _samplePeriod(),
        ]);

      await _pumpScreen(tester, service: service);
      await tester.pumpAndSettle();

      expect(
        find.text('Schedule conflict with existing enrollment'),
        findsOneWidget,
      );
    });
  });
}
