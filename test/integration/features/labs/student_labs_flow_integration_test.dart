import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/lab_detail/lab_detail_cubit.dart';
import 'package:edu_verse/bloc/lab_detail/lab_detail_state.dart';
import 'package:edu_verse/bloc/labs/labs_cubit.dart';
import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/models/core/course_model.dart';
import 'package:edu_verse/models/core/enrollment_model.dart';
import 'package:edu_verse/models/core/enums/assignment_enums.dart'
    as assignment_api;
import 'package:edu_verse/models/core/enums/course_enums.dart';
import 'package:edu_verse/models/core/enums/enrollment_enums.dart';
import 'package:edu_verse/models/core/enums/lab_enums.dart' as api;
import 'package:edu_verse/models/core/lab_attendance_model.dart';
import 'package:edu_verse/models/core/lab_instruction_model.dart';
import 'package:edu_verse/models/core/shared_models.dart';
import 'package:edu_verse/models/labs/lab_model.dart';
import 'package:edu_verse/models/labs/lab_submission_model.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/enrollment_service.dart';
import 'package:edu_verse/services/api/lab_service.dart';
import 'package:edu_verse/utils/submission_event_tracker.dart';

class _FakeEnrollmentService extends EnrollmentService {
  _FakeEnrollmentService(this.result)
    : super(coreApiClient: CoreApiClient.test());

  final ServiceResult<List<CourseEnrollmentModel>> result;

  @override
  Future<ServiceResult<List<CourseEnrollmentModel>>> getMyCourses({
    int? semester,
    CancelToken? cancelToken,
  }) async {
    return result;
  }
}

class _FakeLabService extends LabService {
  _FakeLabService({
    required this.allResult,
    required this.byIdResult,
    required this.instructionsResult,
    required this.submissionsResult,
    required this.attendanceResult,
  }) : super(coreApiClient: CoreApiClient.test());

  final ServiceResult<List<LabModel>> allResult;
  final ServiceResult<LabModel> byIdResult;
  final ServiceResult<List<LabInstructionModel>> instructionsResult;
  final ServiceResult<List<LabSubmissionModel>> submissionsResult;
  final ServiceResult<List<LabAttendanceModel>> attendanceResult;

  @override
  Future<ServiceResult<List<LabModel>>> getAll({
    int? courseId,
    String? status,
    String? search,
    int page = 1,
    int limit = 50,
    CancelToken? cancelToken,
  }) async {
    return allResult;
  }

  @override
  Future<ServiceResult<LabModel>> getById(
    dynamic id, {
    CancelToken? cancelToken,
  }) async {
    return byIdResult;
  }

  @override
  Future<ServiceResult<List<LabInstructionModel>>> getInstructions(
    dynamic labId, {
    CancelToken? cancelToken,
  }) async {
    return instructionsResult;
  }

  @override
  Future<ServiceResult<List<LabSubmissionModel>>> getMySubmission(
    dynamic labId, {
    CancelToken? cancelToken,
  }) async {
    return submissionsResult;
  }

  @override
  Future<ServiceResult<List<LabAttendanceModel>>> getAttendance(
    dynamic labId, {
    CancelToken? cancelToken,
  }) async {
    return attendanceResult;
  }
}

class _NoopSubmissionTracker extends SubmissionEventTracker {
  @override
  Future<void> logSubmission(String labId) async {}

  @override
  Future<void> logSubmissionFailure(String labId, String error) async {}
}

CourseModel _course() {
  return CourseModel(
    id: 1,
    departmentId: 10,
    code: 'CS101',
    name: 'Algorithms',
    credits: 3,
    courseLevel: CourseLevel.freshman,
    courseStatus: CourseStatus.active,
  );
}

CourseEnrollmentModel _enrollment(CourseModel course) {
  return CourseEnrollmentModel(
    id: '1',
    userId: 99,
    sectionId: 11,
    enrollmentStatus: EnrollmentStatus.enrolled,
    enrollmentDate: DateTime(2026, 1, 1),
    course: course,
  );
}

LabModel _lab(CourseModel course) {
  return LabModel(
    id: 'lab-1',
    labId: 1,
    courseId: course.id,
    title: 'Sorting Lab',
    description: 'Implement quick sort and analyze complexity.',
    labNumber: 3,
    dueDate: DateTime.now().add(const Duration(days: 3)),
    maxScore: 100,
    weight: 20,
    status: api.LabStatus.published,
    course: CourseInfo(id: course.id, name: course.name, code: course.code),
  );
}

LabSubmissionModel _gradedSubmission() {
  return LabSubmissionModel(
    id: 7,
    labId: 1,
    userId: 99,
    submissionStatus: assignment_api.SubmissionStatus.graded,
    isLate: false,
    submittedAt: DateTime.now().subtract(const Duration(hours: 2)),
    score: 96,
    feedback: 'Excellent work and clean complexity notes.',
  );
}

void main() {
  test('student labs flow meets integration timing thresholds', () async {
    final course = _course();
    final lab = _lab(course);

    final enrollmentService = _FakeEnrollmentService(
      ServiceResult<List<CourseEnrollmentModel>>.success(
        <CourseEnrollmentModel>[_enrollment(course)],
      ),
    );

    final labService = _FakeLabService(
      allResult: ServiceResult<List<LabModel>>.success(<LabModel>[lab]),
      byIdResult: ServiceResult<LabModel>.success(lab),
      instructionsResult: ServiceResult<List<LabInstructionModel>>.success(
        <LabInstructionModel>[
          const LabInstructionModel(
            id: 1,
            labId: 1,
            instructionText: '## Step 1\nRun and document benchmarks.',
            orderIndex: 0,
          ),
        ],
      ),
      submissionsResult: ServiceResult<List<LabSubmissionModel>>.success(
        <LabSubmissionModel>[_gradedSubmission()],
      ),
      attendanceResult: ServiceResult<List<LabAttendanceModel>>.success(
        const <LabAttendanceModel>[
          LabAttendanceModel(
            id: 1,
            labId: 1,
            userId: 99,
            attendanceStatus: api.LabAttendanceStatus.present,
          ),
        ],
      ),
    );

    final labsCubit = LabsCubit(
      enrollmentService: enrollmentService,
      labService: labService,
    );

    final labsLoadTimer = Stopwatch()..start();
    await labsCubit.loadEnrolledCourses();
    labsLoadTimer.stop();

    expect(labsCubit.state.enrolledCourses.length, 1);
    expect(labsCubit.state.filteredLabs.length, 1);
    expect(labsLoadTimer.elapsedMilliseconds, lessThan(2000));

    final detailCubit = LabDetailCubit(
      labService: labService,
      enrollmentService: enrollmentService,
      cachedEnrolledCourses: labsCubit.state.enrolledCourses,
      submissionEventTracker: _NoopSubmissionTracker(),
    );

    final detailLoadTimer = Stopwatch()..start();
    await detailCubit.loadLab(lab.id);
    await detailCubit.loadInstructions(lab.id);
    await detailCubit.loadAttendance(lab.id);
    await detailCubit.loadMySubmissions(lab.id);
    detailLoadTimer.stop();

    expect(detailLoadTimer.elapsedMilliseconds, lessThan(2000));
    expect(detailCubit.state, isA<LabDetailLoaded>());

    final loadedState = detailCubit.state as LabDetailLoaded;
    expect(loadedState.instructions, isNotEmpty);
    expect(loadedState.attendanceStatus, api.LabAttendanceStatus.present);

    final gradeViewTimer = Stopwatch()..start();
    await detailCubit.loadMySubmissions(lab.id);
    gradeViewTimer.stop();

    final refreshedState = detailCubit.state as LabDetailLoaded;
    expect(gradeViewTimer.elapsedMilliseconds, lessThan(1000));
    expect(refreshedState.mySubmissions, isNotEmpty);
    expect(refreshedState.mySubmissions.first.isGraded, isTrue);
    expect(refreshedState.mySubmissions.first.score, isNotNull);

    await detailCubit.close();
    await labsCubit.close();
  });
}
