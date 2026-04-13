import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/labs/labs_cubit.dart';
import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/models/core/course_model.dart';
import 'package:edu_verse/models/core/enrollment_model.dart';
import 'package:edu_verse/models/core/enums/course_enums.dart';
import 'package:edu_verse/models/core/enums/enrollment_enums.dart';
import 'package:edu_verse/models/core/enums/lab_enums.dart' as api;
import 'package:edu_verse/models/core/shared_models.dart';
import 'package:edu_verse/models/labs/lab_model.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/enrollment_service.dart';
import 'package:edu_verse/services/api/lab_service.dart';

class _FakeEnrollmentService extends EnrollmentService {
  _FakeEnrollmentService(this.result)
    : super(coreApiClient: CoreApiClient.test());

  ServiceResult<List<CourseEnrollmentModel>> result;
  bool called = false;

  @override
  Future<ServiceResult<List<CourseEnrollmentModel>>> getMyCourses() async {
    called = true;
    return result;
  }
}

class _FakeLabService extends LabService {
  _FakeLabService(this.result) : super(coreApiClient: CoreApiClient.test());

  ServiceResult<List<LabModel>> result;
  int? lastCourseId;

  @override
  Future<ServiceResult<List<LabModel>>> getAll({
    int? courseId,
    String? status,
    String? search,
    int page = 1,
    int limit = 50,
  }) async {
    lastCourseId = courseId;
    return result;
  }
}

CourseModel _course(int id, String code, String name) {
  return CourseModel(
    id: id,
    departmentId: 1,
    code: code,
    name: name,
    credits: 3,
    courseLevel: CourseLevel.freshman,
    courseStatus: CourseStatus.active,
  );
}

CourseEnrollmentModel _enrollment(CourseModel course) {
  return CourseEnrollmentModel(
    id: '${course.id}',
    userId: 9,
    sectionId: 11,
    enrollmentStatus: EnrollmentStatus.enrolled,
    enrollmentDate: DateTime(2026, 1, 1),
    course: course,
  );
}

LabModel _lab({required int courseId, required String title}) {
  return LabModel(
    id: '$courseId-$title',
    labId: courseId,
    courseId: courseId,
    title: title,
    dueDate: DateTime.now().add(const Duration(days: 1)),
    maxScore: 100,
    status: api.LabStatus.published,
    course: CourseInfo(
      id: courseId,
      name: 'Course $courseId',
      code: 'CS$courseId',
    ),
  );
}

void main() {
  group('LabsCubit', () {
    test(
      'loadEnrolledCourses fetches courses and auto-selects first course',
      () async {
        final course1 = _course(1, 'CS101', 'Algorithms');
        final course2 = _course(2, 'CS102', 'Data Structures');

        final enrollmentService = _FakeEnrollmentService(
          ServiceResult<List<CourseEnrollmentModel>>.success(
            <CourseEnrollmentModel>[_enrollment(course1), _enrollment(course2)],
          ),
        );
        final labService = _FakeLabService(
          ServiceResult<List<LabModel>>.success(<LabModel>[
            _lab(courseId: 1, title: 'Lab A'),
          ]),
        );

        final cubit = LabsCubit(
          enrollmentService: enrollmentService,
          labService: labService,
        );

        await cubit.loadEnrolledCourses();

        expect(enrollmentService.called, isTrue);
        expect(cubit.state.enrolledCourses.length, 2);
        expect(cubit.state.selectedCourseId, 1);
        expect(labService.lastCourseId, 1);
        expect(cubit.state.labs.length, 1);

        await cubit.close();
      },
    );

    test('selectCourse requests labs for selected course id', () async {
      final course1 = _course(1, 'CS101', 'Algorithms');
      final course2 = _course(2, 'CS102', 'Data Structures');

      final enrollmentService = _FakeEnrollmentService(
        ServiceResult<List<CourseEnrollmentModel>>.success(
          <CourseEnrollmentModel>[_enrollment(course1), _enrollment(course2)],
        ),
      );
      final labService = _FakeLabService(
        ServiceResult<List<LabModel>>.success(<LabModel>[
          _lab(courseId: 1, title: 'Lab A'),
        ]),
      );

      final cubit = LabsCubit(
        enrollmentService: enrollmentService,
        labService: labService,
      );

      await cubit.loadEnrolledCourses();

      labService.result = ServiceResult<List<LabModel>>.success(<LabModel>[
        _lab(courseId: 2, title: 'Lab B'),
      ]);
      await cubit.selectCourse(2);

      expect(labService.lastCourseId, 2);
      expect(cubit.state.selectedCourseId, 2);
      expect(cubit.state.labs.first.courseId, 2);

      await cubit.close();
    });

    test('emits error state when loading labs fails', () async {
      final course1 = _course(1, 'CS101', 'Algorithms');

      final enrollmentService = _FakeEnrollmentService(
        ServiceResult<List<CourseEnrollmentModel>>.success(
          <CourseEnrollmentModel>[_enrollment(course1)],
        ),
      );
      final labService = _FakeLabService(
        ServiceResult<List<LabModel>>.failure(
          const ServiceError(
            type: ServiceErrorType.server,
            message: 'Failed to load labs',
          ),
        ),
      );

      final cubit = LabsCubit(
        enrollmentService: enrollmentService,
        labService: labService,
      );

      await cubit.loadEnrolledCourses();

      expect(cubit.state.error, contains('Failed to load labs'));
      expect(cubit.state.isLoading, isFalse);

      await cubit.close();
    });
  });
}
