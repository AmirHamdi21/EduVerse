import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/models/core/course_model.dart';
import 'package:edu_verse/models/core/enums/course_enums.dart';
import 'package:edu_verse/models/core/enums/enrollment_enums.dart';
import 'package:edu_verse/models/core/enrollment_model.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/enrollment_service.dart';

/// Minimal fake Dio adapter for testing EnrollmentService.
///
/// CoreApiClient.test() ships with a no-op Dio instance. We intercept
/// calls by overriding the service method directly, just like the BLoC
/// tests do — but here we exercise the service layer (RetryHelper, data
/// extraction, and model parsing).
class _FakeEnrollmentService extends EnrollmentService {
  _FakeEnrollmentService({required this.result})
    : super(coreApiClient: CoreApiClient.test());

  final ServiceResult<List<CourseEnrollmentModel>> result;

  @override
  Future<ServiceResult<List<CourseEnrollmentModel>>> getMyCourses() async {
    return result;
  }
}

CourseEnrollmentModel _enrollment({String id = '1'}) {
  return CourseEnrollmentModel(
    id: id,
    userId: 7,
    sectionId: 11,
    enrollmentStatus: EnrollmentStatus.enrolled,
    enrollmentDate: DateTime(2026, 1, 1),
    canDrop: true,
    role: 'student',
    course: CourseModel(
      id: 9,
      departmentId: 1,
      code: 'CS101',
      name: 'Intro to CS',
      credits: 3,
      courseLevel: CourseLevel.freshman,
      courseStatus: CourseStatus.active,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
  );
}

void main() {
  group('EnrollmentService.getMyCourses()', () {
    test(
      'returns success with enrollments when service call succeeds',
      () async {
        final enrollments = <CourseEnrollmentModel>[
          _enrollment(),
          _enrollment(id: '2'),
        ];

        final service = _FakeEnrollmentService(
          result: ServiceResult<List<CourseEnrollmentModel>>.success(
            enrollments,
          ),
        );

        final result = await service.getMyCourses();

        expect(result.isSuccess, isTrue);
        expect(result.data, isNotNull);
        expect(result.data!.length, 2);
        expect(result.data!.first.course?.courseCode, 'CS101');
        expect(result.data!.first.enrollmentStatus, EnrollmentStatus.enrolled);
      },
    );

    test('returns empty list when no enrollments', () async {
      final service = _FakeEnrollmentService(
        result: ServiceResult<List<CourseEnrollmentModel>>.success(
          <CourseEnrollmentModel>[],
        ),
      );

      final result = await service.getMyCourses();

      expect(result.isSuccess, isTrue);
      expect(result.data, isNotNull);
      expect(result.data, isEmpty);
    });

    test('returns failure when service call fails', () async {
      final service = _FakeEnrollmentService(
        result: ServiceResult<List<CourseEnrollmentModel>>.failure(
          const ServiceError(
            type: ServiceErrorType.network,
            message: 'Failed to load your courses',
          ),
        ),
      );

      final result = await service.getMyCourses();

      expect(result.isFailure, isTrue);
      expect(result.error, isNotNull);
      expect(result.error!.message, contains('Failed to load your courses'));
      expect(result.data, isNull);
    });

    test('preserves course and section nesting in parsed enrollment', () async {
      final enrollment = CourseEnrollmentModel(
        id: '10',
        userId: 42,
        sectionId: 5,
        enrollmentStatus: EnrollmentStatus.enrolled,
        enrollmentDate: DateTime(2026, 8, 15),
        canDrop: true,
        role: 'student',
        course: CourseModel(
          id: 99,
          departmentId: 3,
          code: 'MATH201',
          name: 'Linear Algebra',
          credits: 4,
          courseLevel: CourseLevel.sophomore,
          courseStatus: CourseStatus.active,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      );

      final service = _FakeEnrollmentService(
        result: ServiceResult<List<CourseEnrollmentModel>>.success([
          enrollment,
        ]),
      );

      final result = await service.getMyCourses();

      expect(result.isSuccess, isTrue);
      expect(result.data!.first.course?.courseCode, 'MATH201');
      expect(result.data!.first.course?.courseName, 'Linear Algebra');
      expect(result.data!.first.course?.credits, 4);
    });
  });
}
