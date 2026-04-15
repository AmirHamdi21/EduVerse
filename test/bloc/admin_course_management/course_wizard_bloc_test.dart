import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/admin_course_management/course_wizard_bloc.dart';
import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/models/core/course_model.dart';
import 'package:edu_verse/models/core/enrollment_model.dart';
import 'package:edu_verse/models/core/enums/course_enums.dart';
import 'package:edu_verse/models/core/enums/enrollment_enums.dart';
import 'package:edu_verse/models/core/section_model.dart';
import 'package:edu_verse/models/ta/ta_assignment_model.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/course_service.dart';
import 'package:edu_verse/services/api/enrollment_service.dart';
import 'package:edu_verse/services/api/schedule_service.dart';
import 'package:edu_verse/services/api/section_service.dart';

class _FakeCourseService extends CourseService {
  _FakeCourseService() : super(coreApiClient: CoreApiClient.test());

  int createCalls = 0;
  Map<String, dynamic>? lastCreatedBody;
  dynamic lastUpdatedCourseId;
  Map<String, dynamic>? lastUpdatedBody;

  @override
  Future<ServiceResult<CourseModel>> createCourseAdmin(
    Map<String, dynamic> body,
  ) async {
    createCalls += 1;
    lastCreatedBody = Map<String, dynamic>.from(body);

    return ServiceResult<CourseModel>.success(
      _buildCourse(id: 101, status: CourseStatus.active),
    );
  }

  @override
  Future<ServiceResult<CourseModel>> updateCourseAdmin(
    dynamic courseId,
    Map<String, dynamic> body,
  ) async {
    lastUpdatedCourseId = courseId;
    lastUpdatedBody = Map<String, dynamic>.from(body);

    final isInactive =
        body['status']?.toString().toUpperCase() == CourseStatus.inactive.value;

    return ServiceResult<CourseModel>.success(
      _buildCourse(
        id: int.tryParse(courseId.toString()) ?? 0,
        status: isInactive ? CourseStatus.inactive : CourseStatus.active,
      ),
    );
  }
}

class _FailingSectionService extends SectionService {
  _FailingSectionService() : super(coreApiClient: CoreApiClient.test());

  @override
  Future<ServiceResult<SectionModel>> create(Map<String, dynamic> data) async {
    return ServiceResult<SectionModel>.failure(
      const ServiceError(
        type: ServiceErrorType.server,
        message: 'section save failed',
      ),
    );
  }
}

class _TrackingSectionService extends SectionService {
  _TrackingSectionService() : super(coreApiClient: CoreApiClient.test());

  int createCalls = 0;
  Map<String, dynamic>? lastCreatedBody;
  dynamic lastUpdatedSectionId;
  Map<String, dynamic>? lastUpdatedBody;

  @override
  Future<ServiceResult<SectionModel>> create(Map<String, dynamic> data) async {
    createCalls += 1;
    lastCreatedBody = Map<String, dynamic>.from(data);

    return ServiceResult<SectionModel>.success(
      SectionModel(
        id: 77,
        courseId: data['courseId'] as int? ?? 101,
        semesterId: data['semesterId'] as int? ?? 1,
        sectionNumber: '1',
        maxCapacity: data['maxCapacity'] as int? ?? 30,
        currentEnrollment: 0,
        location: data['location']?.toString(),
        sectionStatus: SectionStatus.open,
      ),
    );
  }

  @override
  Future<ServiceResult<SectionModel>> update(
    dynamic id,
    Map<String, dynamic> data,
  ) async {
    lastUpdatedSectionId = id;
    lastUpdatedBody = Map<String, dynamic>.from(data);

    final statusRaw = data['status']?.toString().toUpperCase();
    final sectionStatus = statusRaw == SectionStatus.closed.value
        ? SectionStatus.closed
        : SectionStatus.open;

    return ServiceResult<SectionModel>.success(
      SectionModel(
        id: int.tryParse(id.toString()) ?? 0,
        courseId: 101,
        semesterId: 1,
        sectionNumber: '1',
        maxCapacity: 30,
        currentEnrollment: 0,
        sectionStatus: sectionStatus,
      ),
    );
  }
}

class _FakeScheduleService extends ScheduleService {
  _FakeScheduleService() : super(coreApiClient: CoreApiClient.test());
}

class _FakeEnrollmentService extends EnrollmentService {
  _FakeEnrollmentService() : super(coreApiClient: CoreApiClient.test());
}

class _AddFailsBeforeRemovalEnrollmentService extends EnrollmentService {
  _AddFailsBeforeRemovalEnrollmentService()
    : super(coreApiClient: CoreApiClient.test());

  int assignInstructorCalls = 0;
  int removeInstructorCalls = 0;

  @override
  Future<ServiceResult<List<EnrollmentModel>>> getSectionInstructors(
    dynamic sectionId,
  ) async {
    return ServiceResult<List<EnrollmentModel>>.success(<EnrollmentModel>[
      EnrollmentModel(
        id: 401,
        userId: 10,
        sectionId: 77,
        enrollmentStatus: EnrollmentStatus.enrolled,
        role: 'primary',
        user: const UserLite(
          userId: 10,
          firstName: 'Existing',
          lastName: 'Instructor',
          email: 'existing@eduverse.dev',
        ),
      ),
    ]);
  }

  @override
  Future<ServiceResult<List<TAAssignmentModel>>> getSectionTAs(
    dynamic sectionId,
  ) async {
    return ServiceResult<List<TAAssignmentModel>>.success(
      const <TAAssignmentModel>[],
    );
  }

  @override
  Future<ServiceResult<void>> assignInstructorWithDetails(
    dynamic sectionId,
    int userId, {
    String? role,
  }) async {
    assignInstructorCalls += 1;
    return ServiceResult<void>.failure(
      const ServiceError(
        type: ServiceErrorType.server,
        message: 'assign failed',
      ),
    );
  }

  @override
  Future<ServiceResult<void>> removeInstructor(
    dynamic sectionId,
    dynamic enrollmentId,
  ) async {
    removeInstructorCalls += 1;
    return ServiceResult<void>.success(null);
  }
}

class _RoleUpdateEnrollmentService extends EnrollmentService {
  _RoleUpdateEnrollmentService() : super(coreApiClient: CoreApiClient.test());

  int assignInstructorCalls = 0;
  int removeInstructorCalls = 0;
  String? lastAssignedRole;

  @override
  Future<ServiceResult<List<EnrollmentModel>>> getSectionInstructors(
    dynamic sectionId,
  ) async {
    return ServiceResult<List<EnrollmentModel>>.success(<EnrollmentModel>[
      EnrollmentModel(
        id: 401,
        userId: 10,
        sectionId: 77,
        enrollmentStatus: EnrollmentStatus.enrolled,
        role: 'primary',
        user: const UserLite(
          userId: 10,
          firstName: 'Existing',
          lastName: 'Instructor',
          email: 'existing@eduverse.dev',
        ),
      ),
    ]);
  }

  @override
  Future<ServiceResult<List<TAAssignmentModel>>> getSectionTAs(
    dynamic sectionId,
  ) async {
    return ServiceResult<List<TAAssignmentModel>>.success(
      const <TAAssignmentModel>[],
    );
  }

  @override
  Future<ServiceResult<void>> assignInstructorWithDetails(
    dynamic sectionId,
    int userId, {
    String? role,
  }) async {
    assignInstructorCalls += 1;
    lastAssignedRole = role;
    return ServiceResult<void>.success(null);
  }

  @override
  Future<ServiceResult<void>> removeInstructor(
    dynamic sectionId,
    dynamic enrollmentId,
  ) async {
    removeInstructorCalls += 1;
    return ServiceResult<void>.success(null);
  }

  @override
  Future<ServiceResult<void>> assignTAWithDetails(
    dynamic sectionId,
    int userId, {
    String? responsibilities,
  }) async {
    return ServiceResult<void>.success(null);
  }

  @override
  Future<ServiceResult<void>> removeTA(
    dynamic sectionId,
    dynamic enrollmentId,
  ) async {
    return ServiceResult<void>.success(null);
  }
}

CourseModel _buildCourse({
  required int id,
  required CourseStatus status,
  List<SectionModel>? sections,
}) {
  return CourseModel(
    id: id,
    departmentId: 1,
    code: 'CS101',
    name: 'Intro Course',
    credits: 3,
    courseLevel: CourseLevel.freshman,
    courseStatus: status,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    sections: sections,
  );
}

Future<void> _flush() async {
  await Future<void>.delayed(const Duration(milliseconds: 1));
  await Future<void>.delayed(const Duration(milliseconds: 1));
}

void main() {
  group('CourseWizardBloc create contract safety', () {
    test(
      'strips course status on create and applies INACTIVE via patch',
      () async {
        final courseService = _FakeCourseService();

        final bloc = CourseWizardBloc(
          courseService: courseService,
          sectionService: _FailingSectionService(),
          scheduleService: _FakeScheduleService(),
          enrollmentService: _FakeEnrollmentService(),
        );

        bloc.add(
          const SubmitStep1(<String, dynamic>{
            'name': 'Intro Course',
            'code': 'CS101',
            'departmentId': 1,
            'credits': 3,
            'level': 'FRESHMAN',
            'status': 'INACTIVE',
          }, desiredStatus: 'INACTIVE'),
        );
        await _flush();

        expect(courseService.createCalls, 1);
        expect(courseService.lastCreatedBody, isNot(contains('status')));
        expect(courseService.lastUpdatedCourseId, 101);
        expect(
          courseService.lastUpdatedBody,
          containsPair('status', CourseStatus.inactive.value),
        );
        expect(bloc.state.status, CourseWizardStatus.stepSaved);

        await bloc.close();
      },
    );

    test(
      'strips section status on create and applies CLOSED via patch',
      () async {
        final courseService = _FakeCourseService();
        final sectionService = _TrackingSectionService();

        final bloc = CourseWizardBloc(
          courseService: courseService,
          sectionService: sectionService,
          scheduleService: _FakeScheduleService(),
          enrollmentService: _FakeEnrollmentService(),
        );

        bloc.add(
          const SubmitStep1(<String, dynamic>{
            'name': 'Intro Course',
            'code': 'CS101',
            'departmentId': 1,
            'credits': 3,
            'level': 'FRESHMAN',
            'status': 'ACTIVE',
          }),
        );
        await _flush();

        bloc.add(
          const SubmitStep2(
            sectionPayload: <String, dynamic>{
              'semesterId': 1,
              'sectionNumber': 1,
              'maxCapacity': 30,
              'status': 'CLOSED',
            },
            schedulesPayload: <Map<String, dynamic>>[],
            desiredStatus: 'CLOSED',
          ),
        );
        await _flush();

        expect(sectionService.createCalls, 1);
        expect(sectionService.lastCreatedBody, isNot(contains('status')));
        expect(sectionService.lastUpdatedSectionId, 77);
        expect(
          sectionService.lastUpdatedBody,
          containsPair('status', SectionStatus.closed.value),
        );
        expect(bloc.state.status, CourseWizardStatus.stepSaved);

        await bloc.close();
      },
    );
  });

  group('CourseWizardBloc step-2 failure fallback', () {
    test(
      'marks draft course INACTIVE when step 2 section save fails',
      () async {
        final courseService = _FakeCourseService();

        final bloc = CourseWizardBloc(
          courseService: courseService,
          sectionService: _FailingSectionService(),
          scheduleService: _FakeScheduleService(),
          enrollmentService: _FakeEnrollmentService(),
        );

        bloc.add(
          const SubmitStep1(<String, dynamic>{
            'name': 'Intro Course',
            'code': 'CS101',
            'departmentId': 1,
            'credits': 3,
            'level': 'FRESHMAN',
            'status': 'ACTIVE',
          }),
        );
        await _flush();

        expect(bloc.state.draftCourseId, 101);

        bloc.add(
          const SubmitStep2(
            sectionPayload: <String, dynamic>{
              'semesterId': 1,
              'sectionNumber': 1,
              'maxCapacity': 30,
              'status': 'OPEN',
            },
            schedulesPayload: <Map<String, dynamic>>[],
          ),
        );
        await _flush();

        expect(bloc.state.status, CourseWizardStatus.inactiveSaved);
        expect(bloc.state.errorMessage, 'section save failed');
        expect(courseService.lastUpdatedCourseId, 101);
        expect(
          courseService.lastUpdatedBody,
          containsPair('status', 'INACTIVE'),
        );

        await bloc.close();
      },
    );
  });

  group('CourseWizardBloc edit-mode staff replacement safety', () {
    test('does not remove existing instructors before add succeeds', () async {
      final courseService = _FakeCourseService();
      final enrollmentService = _AddFailsBeforeRemovalEnrollmentService();

      final bloc = CourseWizardBloc(
        courseService: courseService,
        sectionService: _FailingSectionService(),
        scheduleService: _FakeScheduleService(),
        enrollmentService: enrollmentService,
      );

      final editableCourse = _buildCourse(
        id: 50,
        status: CourseStatus.active,
        sections: <SectionModel>[
          SectionModel(
            id: 77,
            courseId: 50,
            semesterId: 1,
            sectionNumber: '1',
            maxCapacity: 30,
            currentEnrollment: 0,
            sectionStatus: SectionStatus.open,
          ),
        ],
      );

      bloc.add(InitializeWizard(course: editableCourse));
      await _flush();

      expect(bloc.state.isEditMode, isTrue);
      expect(bloc.state.draftSectionId, 77);

      bloc.add(
        const SubmitStep3(<WizardInstructorAssignment>[
          WizardInstructorAssignment(userId: 99, role: 'primary'),
        ]),
      );
      await _flush();

      expect(enrollmentService.assignInstructorCalls, 1);
      expect(enrollmentService.removeInstructorCalls, 0);
      expect(bloc.state.status, CourseWizardStatus.inactiveSaved);

      await bloc.close();
    });

    test('replaces instructor assignment when only role changes', () async {
      final courseService = _FakeCourseService();
      final enrollmentService = _RoleUpdateEnrollmentService();

      final bloc = CourseWizardBloc(
        courseService: courseService,
        sectionService: _FailingSectionService(),
        scheduleService: _FakeScheduleService(),
        enrollmentService: enrollmentService,
      );

      final editableCourse = _buildCourse(
        id: 50,
        status: CourseStatus.active,
        sections: <SectionModel>[
          SectionModel(
            id: 77,
            courseId: 50,
            semesterId: 1,
            sectionNumber: '1',
            maxCapacity: 30,
            currentEnrollment: 0,
            sectionStatus: SectionStatus.open,
          ),
        ],
      );

      bloc.add(InitializeWizard(course: editableCourse));
      await _flush();

      bloc.add(
        const SubmitStep3(<WizardInstructorAssignment>[
          WizardInstructorAssignment(userId: 10, role: 'guest'),
        ]),
      );
      await _flush();

      expect(enrollmentService.removeInstructorCalls, 1);
      expect(enrollmentService.assignInstructorCalls, 1);
      expect(enrollmentService.lastAssignedRole, 'guest');
      expect(bloc.state.status, CourseWizardStatus.completed);

      await bloc.close();
    });
  });
}
