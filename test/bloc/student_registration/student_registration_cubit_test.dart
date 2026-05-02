import 'package:dio/dio.dart';
import 'package:edu_verse/bloc/student_registration/student_registration_cubit.dart';
import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/models/admin/admin_periods_models.dart';
import 'package:edu_verse/models/core/enrollment_model.dart';
import 'package:edu_verse/models/registration/registration_available_course_model.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/enrollment_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeEnrollmentService extends EnrollmentService {
  _FakeEnrollmentService() : super(coreApiClient: CoreApiClient.test());

  ServiceResult<List<CourseEnrollmentModel>> myEnrollmentsResult =
      ServiceResult.success(<CourseEnrollmentModel>[]);
  ServiceResult<List<RegistrationAvailableCourseModel>> availableCoursesResult =
      ServiceResult.success(<RegistrationAvailableCourseModel>[]);
  ServiceResult<List<EnrollmentPeriodModel>> periodsResult =
      ServiceResult.success(<EnrollmentPeriodModel>[]);
  ServiceResult<CourseEnrollmentModel> registerResult = ServiceResult.success(
    _sampleEnrollment(),
  );
  ServiceResult<void> dropResult = ServiceResult.success(null);

  int getMyEnrollmentsCalls = 0;
  int getAvailableCoursesCalls = 0;
  int getEnrollmentPeriodsCalls = 0;
  int registerCalls = 0;
  int dropCalls = 0;

  @override
  Future<ServiceResult<List<CourseEnrollmentModel>>> getMyEnrollments({
    int? semester,
    CancelToken? cancelToken,
  }) async {
    getMyEnrollmentsCalls += 1;
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
    getAvailableCoursesCalls += 1;
    return availableCoursesResult;
  }

  @override
  Future<ServiceResult<List<EnrollmentPeriodModel>>>
  getEnrollmentPeriods() async {
    getEnrollmentPeriodsCalls += 1;
    return periodsResult;
  }

  @override
  Future<ServiceResult<CourseEnrollmentModel>> registerForSection({
    required int sectionId,
  }) async {
    registerCalls += 1;
    return registerResult;
  }

  @override
  Future<ServiceResult<void>> dropEnrollment(dynamic id) async {
    dropCalls += 1;
    return dropResult;
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

RegistrationAvailableCourseModel _sampleAvailableCourse() {
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

void main() {
  group('StudentRegistrationCubit', () {
    test('load fetches enrolled, available, and periods', () async {
      final fakeService = _FakeEnrollmentService()
        ..myEnrollmentsResult = ServiceResult.success(<CourseEnrollmentModel>[
          _sampleEnrollment(),
        ])
        ..availableCoursesResult = ServiceResult.success(
          <RegistrationAvailableCourseModel>[_sampleAvailableCourse()],
        )
        ..periodsResult = ServiceResult.success(<EnrollmentPeriodModel>[
          _samplePeriod(),
        ]);
      final cubit = StudentRegistrationCubit(enrollmentService: fakeService);

      await cubit.load();

      expect(cubit.state.isInitialLoading, isFalse);
      expect(cubit.state.enrolledCourses.length, 1);
      expect(cubit.state.availableCourses.length, 1);
      expect(cubit.state.enrollmentPeriods.length, 1);
      expect(fakeService.getMyEnrollmentsCalls, 1);
      expect(fakeService.getAvailableCoursesCalls, 1);
      expect(fakeService.getEnrollmentPeriodsCalls, 1);
      await cubit.close();
    });

    test(
      'enrollSelectedSection refreshes lists after successful mutation',
      () async {
        final fakeService = _FakeEnrollmentService()
          ..myEnrollmentsResult = ServiceResult.success(<CourseEnrollmentModel>[
            _sampleEnrollment(),
          ])
          ..availableCoursesResult = ServiceResult.success(
            <RegistrationAvailableCourseModel>[_sampleAvailableCourse()],
          )
          ..periodsResult = ServiceResult.success(<EnrollmentPeriodModel>[
            _samplePeriod(),
          ])
          ..registerResult = ServiceResult.success(_sampleEnrollment());
        final cubit = StudentRegistrationCubit(enrollmentService: fakeService);

        await cubit.load();
        final int initialFetches = fakeService.getMyEnrollmentsCalls;

        cubit.selectCourse(77);
        cubit.selectSection(31);
        final success = await cubit.enrollSelectedSection();

        expect(success, isTrue);
        expect(fakeService.registerCalls, 1);
        expect(fakeService.getMyEnrollmentsCalls, greaterThan(initialFetches));
        expect(cubit.state.successMessage, contains('Successfully enrolled'));
        await cubit.close();
      },
    );

    test('dropEnrollment refreshes lists after successful mutation', () async {
      final fakeService = _FakeEnrollmentService()
        ..myEnrollmentsResult = ServiceResult.success(<CourseEnrollmentModel>[
          _sampleEnrollment(),
        ])
        ..availableCoursesResult = ServiceResult.success(
          <RegistrationAvailableCourseModel>[_sampleAvailableCourse()],
        )
        ..periodsResult = ServiceResult.success(<EnrollmentPeriodModel>[
          _samplePeriod(),
        ])
        ..dropResult = ServiceResult.success(null);
      final cubit = StudentRegistrationCubit(enrollmentService: fakeService);

      await cubit.load();
      final int initialFetches = fakeService.getMyEnrollmentsCalls;

      final success = await cubit.dropEnrollment('150');

      expect(success, isTrue);
      expect(fakeService.dropCalls, 1);
      expect(fakeService.getMyEnrollmentsCalls, greaterThan(initialFetches));
      expect(cubit.state.successMessage, contains('dropped'));
      await cubit.close();
    });

    test('surfaces backend mutation errors', () async {
      final fakeService = _FakeEnrollmentService()
        ..myEnrollmentsResult = ServiceResult.success(<CourseEnrollmentModel>[
          _sampleEnrollment(),
        ])
        ..availableCoursesResult = ServiceResult.success(
          <RegistrationAvailableCourseModel>[_sampleAvailableCourse()],
        )
        ..periodsResult = ServiceResult.success(<EnrollmentPeriodModel>[
          _samplePeriod(),
        ])
        ..registerResult = ServiceResult<CourseEnrollmentModel>.failure(
          const ServiceError(
            type: ServiceErrorType.server,
            message: 'Prerequisite course CS101 not completed',
            statusCode: 400,
          ),
        );
      final cubit = StudentRegistrationCubit(enrollmentService: fakeService);

      await cubit.load();
      cubit.selectCourse(77);
      cubit.selectSection(31);
      final success = await cubit.enrollSelectedSection();

      expect(success, isFalse);
      expect(cubit.state.errorMessage, contains('Prerequisite course CS101'));
      await cubit.close();
    });
  });
}
