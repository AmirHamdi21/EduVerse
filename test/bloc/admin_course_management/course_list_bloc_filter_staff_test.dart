import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/admin_course_management/course_list_bloc.dart';
import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/models/core/enrollment_model.dart';
import 'package:edu_verse/models/core/enums/course_enums.dart';
import 'package:edu_verse/models/core/enums/enrollment_enums.dart';
import 'package:edu_verse/models/core/course_model.dart';
import 'package:edu_verse/models/core/section_model.dart';
import 'package:edu_verse/models/core/schedule_model.dart';
import 'package:edu_verse/models/ta/ta_assignment_model.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/course_service.dart';
import 'package:edu_verse/services/api/enrollment_service.dart';
import 'package:edu_verse/services/api/schedule_service.dart';
import 'package:edu_verse/services/api/section_service.dart';

class _FakeCourseService extends CourseService {
  _FakeCourseService() : super(coreApiClient: CoreApiClient.test());

  @override
  Future<List<CourseModel>> getAllCourses() async {
    return <CourseModel>[
      CourseModel(
        id: 1,
        departmentId: 1,
        code: 'CS101',
        name: 'Intro to CS',
        credits: 3,
        courseLevel: CourseLevel.freshman,
        // Legacy fields are intentionally empty to validate staffByCourse logic.
        instructorId: null,
        taIds: const <int>[],
        courseStatus: CourseStatus.active,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    ];
  }
}

class _FakeSectionService extends SectionService {
  _FakeSectionService() : super(coreApiClient: CoreApiClient.test());

  @override
  Future<ServiceResult<List<SectionModel>>> getByCourse(
    dynamic courseId, {
    int? semesterId,
  }) async {
    return ServiceResult<List<SectionModel>>.success(<SectionModel>[
      SectionModel(
        id: 11,
        courseId: 1,
        semesterId: 1,
        sectionNumber: '1',
        maxCapacity: 30,
        currentEnrollment: 0,
        sectionStatus: SectionStatus.open,
      ),
    ]);
  }
}

class _FakeScheduleService extends ScheduleService {
  _FakeScheduleService() : super(coreApiClient: CoreApiClient.test());

  @override
  Future<ServiceResult<List<ScheduleModel>>> getBySection(dynamic sectionId) {
    return Future<ServiceResult<List<ScheduleModel>>>.value(
      ServiceResult<List<ScheduleModel>>.success(const <ScheduleModel>[]),
    );
  }
}

class _FakeEnrollmentService extends EnrollmentService {
  _FakeEnrollmentService() : super(coreApiClient: CoreApiClient.test());

  @override
  Future<ServiceResult<List<EnrollmentModel>>> getSectionInstructors(
    dynamic sectionId,
  ) {
    return Future<ServiceResult<List<EnrollmentModel>>>.value(
      ServiceResult<List<EnrollmentModel>>.success(<EnrollmentModel>[
        EnrollmentModel(
          id: 501,
          userId: 71,
          sectionId: 11,
          enrollmentStatus: EnrollmentStatus.enrolled,
          role: 'primary',
          user: const UserLite(
            userId: 71,
            firstName: 'Alaa',
            lastName: 'Instructor',
            email: 'alaa@example.com',
          ),
        ),
      ]),
    );
  }

  @override
  Future<ServiceResult<List<TAAssignmentModel>>> getSectionTAs(
    dynamic sectionId,
  ) {
    return Future<ServiceResult<List<TAAssignmentModel>>>.value(
      ServiceResult<List<TAAssignmentModel>>.success(<TAAssignmentModel>[
        TAAssignmentModel(
          id: 601,
          sectionId: 11,
          userId: 81,
          assignedAt: DateTime(2026, 1, 10),
          firstName: 'Mona',
          lastName: 'Assistant',
          email: 'mona@example.com',
        ),
      ]),
    );
  }
}

Future<void> _drainBloc() async {
  for (var i = 0; i < 6; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
}

void main() {
  group('CourseListBloc staff-based filters', () {
    test(
      'needs_instructor and needs_ta use staffByCourse when available',
      () async {
        final bloc = CourseListBloc(
          courseService: _FakeCourseService(),
          sectionService: _FakeSectionService(),
          scheduleService: _FakeScheduleService(),
          enrollmentService: _FakeEnrollmentService(),
        );

        bloc.add(const LoadCourses());
        await _drainBloc();

        bloc.add(const LoadCourseDetails(1, forceRefresh: true));
        await _drainBloc();

        bloc.add(const FilterCourses(selectedFilter: 'needs_instructor'));
        await _drainBloc();
        expect(bloc.state.filteredCourses, isEmpty);

        bloc.add(const FilterCourses(selectedFilter: 'needs_ta'));
        await _drainBloc();
        expect(bloc.state.filteredCourses, isEmpty);

        await bloc.close();
      },
    );
  });
}
