import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/lab_detail/lab_detail_cubit.dart';
import 'package:edu_verse/bloc/lab_detail/lab_detail_state.dart';
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

class _FakeLabService extends LabService {
  _FakeLabService() : super(coreApiClient: CoreApiClient.test());

  ServiceResult<LabModel> labResult = ServiceResult<LabModel>.failure(
    const ServiceError(type: ServiceErrorType.server, message: 'lab error'),
  );
  ServiceResult<List<LabInstructionModel>> instructionsResult =
      ServiceResult<List<LabInstructionModel>>.success(
        const <LabInstructionModel>[],
      );
  ServiceResult<List<LabSubmissionModel>> submissionsResult =
      ServiceResult<List<LabSubmissionModel>>.success(
        const <LabSubmissionModel>[],
      );
  ServiceResult<LabSubmissionModel> submitResult =
      ServiceResult<LabSubmissionModel>.failure(
        const ServiceError(
          type: ServiceErrorType.server,
          message: 'submit error',
        ),
      );
  ServiceResult<LabSubmissionModel> submitFileResult =
      ServiceResult<LabSubmissionModel>.failure(
        const ServiceError(
          type: ServiceErrorType.server,
          message: 'submit file error',
        ),
      );
  ServiceResult<List<LabAttendanceModel>> attendanceResult =
      ServiceResult<List<LabAttendanceModel>>.success(
        const <LabAttendanceModel>[],
      );

  bool submitCalled = false;
  bool submitFileCalled = false;

  @override
  Future<ServiceResult<LabModel>> getById(
    dynamic id, {
    CancelToken? cancelToken,
  }) async => labResult;

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
  Future<ServiceResult<LabSubmissionModel>> submit(
    dynamic labId, {
    String? submissionText,
    String? submissionLink,
    CancelToken? cancelToken,
  }) async {
    submitCalled = true;
    return submitResult;
  }

  @override
  Future<ServiceResult<LabSubmissionModel>> submitFile(
    dynamic labId,
    File file, {
    String? submissionText,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    submitFileCalled = true;
    onSendProgress?.call(1, 1);
    return submitFileResult;
  }

  @override
  Future<ServiceResult<List<LabAttendanceModel>>> getAttendance(
    dynamic labId, {
    CancelToken? cancelToken,
  }) async {
    return attendanceResult;
  }
}

class _FakeEnrollmentService extends EnrollmentService {
  _FakeEnrollmentService(this.result)
    : super(coreApiClient: CoreApiClient.test());

  ServiceResult<List<CourseEnrollmentModel>> result;

  @override
  Future<ServiceResult<List<CourseEnrollmentModel>>> getMyCourses({
    int? semester,
    CancelToken? cancelToken,
  }) async {
    return result;
  }
}

class _FakeTracker extends SubmissionEventTracker {
  int successCount = 0;
  int failureCount = 0;

  @override
  Future<void> logSubmission(String labId) async {
    successCount++;
  }

  @override
  Future<void> logSubmissionFailure(String labId, String error) async {
    failureCount++;
  }
}

CourseModel _course(int id) {
  return CourseModel(
    id: id,
    departmentId: 1,
    code: 'CS$id',
    name: 'Course $id',
    credits: 3,
    courseLevel: CourseLevel.freshman,
    courseStatus: CourseStatus.active,
  );
}

LabModel _lab({int courseId = 1}) {
  return LabModel(
    id: 'lab-1',
    labId: 1,
    courseId: courseId,
    title: 'Lab One',
    dueDate: DateTime.now().add(const Duration(days: 1)),
    maxScore: 100,
    status: api.LabStatus.published,
    course: CourseInfo(id: courseId, name: 'Course', code: 'CS101'),
  );
}

LabSubmissionModel _submission({required DateTime submittedAt}) {
  return LabSubmissionModel(
    id: 1,
    labId: 1,
    userId: 7,
    submissionStatus: assignment_api.SubmissionStatus.submitted,
    isLate: false,
    submittedAt: submittedAt,
  );
}

void main() {
  group('LabDetailCubit', () {
    test('loadLab emits loaded state with lab details', () async {
      final labService = _FakeLabService()
        ..labResult = ServiceResult<LabModel>.success(_lab());
      final enrollmentService = _FakeEnrollmentService(
        ServiceResult<List<CourseEnrollmentModel>>.success(
          const <CourseEnrollmentModel>[],
        ),
      );

      final cubit = LabDetailCubit(
        labService: labService,
        enrollmentService: enrollmentService,
      );

      await cubit.loadLab('lab-1');

      expect(cubit.state, isA<LabDetailLoaded>());
      expect((cubit.state as LabDetailLoaded).lab.id, 'lab-1');

      await cubit.close();
    });

    test(
      'loadInstructions stores instructions sorted by order index',
      () async {
        final labService = _FakeLabService()
          ..labResult = ServiceResult<LabModel>.success(_lab())
          ..instructionsResult =
              ServiceResult<List<LabInstructionModel>>.success(
                <LabInstructionModel>[
                  const LabInstructionModel(
                    id: 2,
                    labId: 1,
                    instructionText: 'Second',
                    orderIndex: 1,
                  ),
                  const LabInstructionModel(
                    id: 1,
                    labId: 1,
                    instructionText: 'First',
                    orderIndex: 0,
                  ),
                ],
              );

        final cubit = LabDetailCubit(
          labService: labService,
          enrollmentService: _FakeEnrollmentService(
            ServiceResult<List<CourseEnrollmentModel>>.success(
              const <CourseEnrollmentModel>[],
            ),
          ),
        );

        await cubit.loadLab('lab-1');
        await cubit.loadInstructions('lab-1');

        final state = cubit.state as LabDetailLoaded;
        expect(state.instructions.first.instructionText, 'First');
        expect(state.instructions.last.instructionText, 'Second');

        await cubit.close();
      },
    );

    test(
      'loadMySubmissions stores submissions ordered by newest first',
      () async {
        final now = DateTime.now();
        final older = now.subtract(const Duration(days: 2));
        final newer = now.subtract(const Duration(days: 1));

        final labService = _FakeLabService()
          ..labResult = ServiceResult<LabModel>.success(_lab())
          ..submissionsResult = ServiceResult<List<LabSubmissionModel>>.success(
            <LabSubmissionModel>[
              _submission(submittedAt: older),
              _submission(submittedAt: newer),
            ],
          );

        final cubit = LabDetailCubit(
          labService: labService,
          enrollmentService: _FakeEnrollmentService(
            ServiceResult<List<CourseEnrollmentModel>>.success(
              const <CourseEnrollmentModel>[],
            ),
          ),
        );

        await cubit.loadLab('lab-1');
        await cubit.loadMySubmissions('lab-1');

        final state = cubit.state as LabDetailLoaded;
        expect(state.mySubmissions.length, 2);
        expect(state.mySubmissions.first.submittedAt, newer);
        expect(state.mySubmissions.last.submittedAt, older);

        await cubit.close();
      },
    );

    test('loadLab emits error state on failure', () async {
      final labService = _FakeLabService();
      final cubit = LabDetailCubit(
        labService: labService,
        enrollmentService: _FakeEnrollmentService(
          ServiceResult<List<CourseEnrollmentModel>>.success(
            const <CourseEnrollmentModel>[],
          ),
        ),
      );

      await cubit.loadLab('lab-1');

      expect(cubit.state, isA<LabDetailError>());

      await cubit.close();
    });

    test('submitText calls service and refreshes submissions', () async {
      final now = DateTime.now();
      final labService = _FakeLabService()
        ..labResult = ServiceResult<LabModel>.success(_lab())
        ..submitResult = ServiceResult<LabSubmissionModel>.success(
          _submission(submittedAt: now),
        )
        ..submissionsResult = ServiceResult<List<LabSubmissionModel>>.success(
          <LabSubmissionModel>[_submission(submittedAt: now)],
        );

      final tracker = _FakeTracker();
      final cubit = LabDetailCubit(
        labService: labService,
        enrollmentService: _FakeEnrollmentService(
          ServiceResult<List<CourseEnrollmentModel>>.success(
            <CourseEnrollmentModel>[
              CourseEnrollmentModel(
                id: '1',
                userId: 7,
                sectionId: 1,
                enrollmentStatus: EnrollmentStatus.enrolled,
                enrollmentDate: DateTime(2026, 1, 1),
                course: _course(1),
              ),
            ],
          ),
        ),
        submissionEventTracker: tracker,
        cachedEnrolledCourses: <CourseModel>[_course(1)],
      );

      await cubit.loadLab('lab-1');
      final result = await cubit.submitText('lab-1', 'my work');

      expect(result, isTrue);
      expect(labService.submitCalled, isTrue);
      expect(tracker.successCount, 1);
      expect((cubit.state as LabDetailLoaded).mySubmissions.length, 1);

      await cubit.close();
    });

    test('submitFile calls upload endpoint and tracks success', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'lab_detail_cubit_test',
      );
      final file = File(
        '${tempDir.path}${Platform.pathSeparator}submission.txt',
      );
      await file.writeAsString('content');

      try {
        final now = DateTime.now();
        final labService = _FakeLabService()
          ..labResult = ServiceResult<LabModel>.success(_lab())
          ..submitFileResult = ServiceResult<LabSubmissionModel>.success(
            _submission(submittedAt: now),
          )
          ..submissionsResult = ServiceResult<List<LabSubmissionModel>>.success(
            <LabSubmissionModel>[_submission(submittedAt: now)],
          );

        final tracker = _FakeTracker();
        final cubit = LabDetailCubit(
          labService: labService,
          enrollmentService: _FakeEnrollmentService(
            ServiceResult<List<CourseEnrollmentModel>>.success(
              <CourseEnrollmentModel>[
                CourseEnrollmentModel(
                  id: '1',
                  userId: 7,
                  sectionId: 1,
                  enrollmentStatus: EnrollmentStatus.enrolled,
                  enrollmentDate: DateTime(2026, 1, 1),
                  course: _course(1),
                ),
              ],
            ),
          ),
          submissionEventTracker: tracker,
          cachedEnrolledCourses: <CourseModel>[_course(1)],
        );

        await cubit.loadLab('lab-1');
        final result = await cubit.submitFile('lab-1', file.path);

        expect(result, isTrue);
        expect(labService.submitFileCalled, isTrue);
        expect(tracker.successCount, 1);

        await cubit.close();
      } finally {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      }
    });

    test('loadAttendance stores present status when available', () async {
      final labService = _FakeLabService()
        ..labResult = ServiceResult<LabModel>.success(_lab())
        ..attendanceResult = ServiceResult<List<LabAttendanceModel>>.success(
          <LabAttendanceModel>[
            const LabAttendanceModel(
              id: 1,
              labId: 1,
              userId: 7,
              attendanceStatus: api.LabAttendanceStatus.absent,
            ),
            const LabAttendanceModel(
              id: 2,
              labId: 1,
              userId: 7,
              attendanceStatus: api.LabAttendanceStatus.present,
            ),
          ],
        );

      final cubit = LabDetailCubit(
        labService: labService,
        enrollmentService: _FakeEnrollmentService(
          ServiceResult<List<CourseEnrollmentModel>>.success(
            const <CourseEnrollmentModel>[],
          ),
        ),
      );

      await cubit.loadLab('lab-1');
      await cubit.loadAttendance('lab-1');

      final state = cubit.state as LabDetailLoaded;
      expect(state.attendanceStatus, api.LabAttendanceStatus.present);

      await cubit.close();
    });
  });
}
