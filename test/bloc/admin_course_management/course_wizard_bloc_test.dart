import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/admin_course_management/course_wizard_bloc.dart';
import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/models/core/course_model.dart';
import 'package:edu_verse/models/core/enums/course_enums.dart';
import 'package:edu_verse/models/core/section_model.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/course_service.dart';
import 'package:edu_verse/services/api/enrollment_service.dart';
import 'package:edu_verse/services/api/schedule_service.dart';
import 'package:edu_verse/services/api/section_service.dart';

class _FakeCourseService extends CourseService {
  _FakeCourseService() : super(coreApiClient: CoreApiClient.test());

  dynamic lastUpdatedCourseId;
  Map<String, dynamic>? lastUpdatedBody;

  @override
  Future<ServiceResult<CourseModel>> createCourseAdmin(
    Map<String, dynamic> body,
  ) async {
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

class _FakeScheduleService extends ScheduleService {
  _FakeScheduleService() : super(coreApiClient: CoreApiClient.test());
}

class _FakeEnrollmentService extends EnrollmentService {
  _FakeEnrollmentService() : super(coreApiClient: CoreApiClient.test());
}

CourseModel _buildCourse({required int id, required CourseStatus status}) {
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
  );
}

Future<void> _flush() async {
  await Future<void>.delayed(const Duration(milliseconds: 1));
  await Future<void>.delayed(const Duration(milliseconds: 1));
}

void main() {
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
}
