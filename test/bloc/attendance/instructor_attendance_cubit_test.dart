import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/attendance/instructor_attendance_cubit.dart';
import 'package:edu_verse/bloc/attendance/instructor_attendance_state.dart';
import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/models/attendance/attendance_record_model.dart';
import 'package:edu_verse/models/attendance/attendance_session_model.dart';
import 'package:edu_verse/models/instructor/instructor_course_model.dart';
import 'package:edu_verse/models/instructor/teaching_course_model.dart';
import 'package:edu_verse/services/api/attendance_service.dart';
import 'package:edu_verse/services/api/enrollment_service.dart';

// ─── Fakes ───────────────────────────────────────────────────────────────────

class _FakeAttendanceService implements AttendanceService {
  ServiceResult<List<AttendanceSessionModel>> sessionsResult =
      ServiceResult<List<AttendanceSessionModel>>.success(const []);

  ServiceResult<AttendanceSessionModel>? createSessionResult;
  ServiceResult<AttendanceSessionModel>? sessionDetailsResult;
  ServiceResult<void> batchResult = ServiceResult<void>.success(null);
  ServiceResult<void> closeResult = ServiceResult<void>.success(null);

  @override
  Future<ServiceResult<List<AttendanceSessionModel>>> getSessions({
    int? sectionId,
    int? courseId,
    String? status,
    int? limit,
    String? sortBy,
    String? sortOrder,
  }) async => sessionsResult;

  @override
  Future<ServiceResult<AttendanceSessionModel>> createSession({
    required int sectionId,
    required String sessionDate,
    required String sessionType,
    int? totalMinutes,
  }) async =>
      createSessionResult ??
      ServiceResult<AttendanceSessionModel>.success(
        AttendanceSessionModel.fromJson(<String, dynamic>{
          'id': 100,
          'sectionId': sectionId,
          'sessionDate': sessionDate,
          'sessionType': sessionType,
          'status': 'scheduled',
        }),
      );

  @override
  Future<ServiceResult<AttendanceSessionModel>> getSessionDetails(
    int id,
  ) async =>
      sessionDetailsResult ??
      ServiceResult<AttendanceSessionModel>.success(
        AttendanceSessionModel.fromJson(<String, dynamic>{
          'id': id,
          'sectionId': 10,
          'status': 'in_progress',
          'records': <Map<String, dynamic>>[
            {
              'userId': 1,
              'attendanceStatus': 'absent',
              'firstName': 'Alice',
              'lastName': 'A',
            },
            {
              'userId': 2,
              'attendanceStatus': 'present',
              'firstName': 'Bob',
              'lastName': 'B',
            },
          ],
        }),
      );

  @override
  Future<ServiceResult<void>> markBatchAttendance({
    required int sessionId,
    required List<Map<String, dynamic>> records,
  }) async => batchResult;

  @override
  Future<ServiceResult<void>> closeSession(int id) async => closeResult;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeEnrollmentService implements EnrollmentService {
  ServiceResult<List<TeachingCourseModel>> teachingResult =
      ServiceResult<List<TeachingCourseModel>>.success(const []);

  ServiceResult<List<SectionStudentModel>>? sectionStudentsResult;

  @override
  Future<ServiceResult<List<TeachingCourseModel>>> getTeachingCourses() async =>
      teachingResult;

  @override
  Future<ServiceResult<List<SectionStudentModel>>> getSectionStudentsLite(
    dynamic sectionId,
  ) async =>
      sectionStudentsResult ??
      ServiceResult<List<SectionStudentModel>>.success(const []);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('InstructorAttendanceCubit', () {
    late _FakeAttendanceService fakeAttendance;
    late _FakeEnrollmentService fakeEnrollment;
    late InstructorAttendanceCubit cubit;

    setUp(() {
      fakeAttendance = _FakeAttendanceService();
      fakeEnrollment = _FakeEnrollmentService();
      cubit = InstructorAttendanceCubit(
        attendanceService: fakeAttendance,
        enrollmentService: fakeEnrollment,
      );
    });

    tearDown(() async {
      await cubit.close();
    });

    test('initial state is classes view', () {
      expect(cubit.state.view, InstructorAttendanceView.classes);
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.teachingSections, isEmpty);
    });

    test('loadTeachingSections populates sections', () async {
      fakeEnrollment.teachingResult =
          ServiceResult<List<TeachingCourseModel>>.failure(
            const ServiceError(
              type: ServiceErrorType.network,
              message: 'No network',
            ),
          );

      await cubit.loadTeachingSections();

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.error, contains('No network'));
    });

    test('backToClasses resets to classes view', () async {
      // Simulate being in section view
      cubit.backToClasses();

      expect(cubit.state.view, InstructorAttendanceView.classes);
      expect(cubit.state.sessions, isEmpty);
      expect(cubit.state.rosterRows, isEmpty);
    });

    test('backToSection resets roster state', () {
      cubit.backToSection();

      expect(cubit.state.view, InstructorAttendanceView.section);
      expect(cubit.state.rosterRows, isEmpty);
      expect(cubit.state.isRosterDirty, isFalse);
    });

    test('applyStatus modifies roster row status', () async {
      // Load a roster first
      fakeAttendance
          .sessionDetailsResult = ServiceResult<AttendanceSessionModel>.success(
        AttendanceSessionModel.fromJson(<String, dynamic>{
          'id': 5,
          'sectionId': 10,
          'status': 'in_progress',
          'records': <Map<String, dynamic>>[
            {'userId': 1, 'attendanceStatus': 'absent', 'firstName': 'Alice'},
          ],
        }),
      );

      await cubit.loadRosterData(5, false);

      expect(cubit.state.rosterRows.length, 1);
      expect(cubit.state.rosterRows.first.status, 'absent');

      cubit.applyStatus(1, 'present');
      expect(cubit.state.rosterRows.first.status, 'present');
      expect(cubit.state.isRosterDirty, isTrue);
    });

    test('applyStatus is no-op when read-only', () async {
      fakeAttendance.sessionDetailsResult =
          ServiceResult<AttendanceSessionModel>.success(
            AttendanceSessionModel.fromJson(<String, dynamic>{
              'id': 5,
              'sectionId': 10,
              'status': 'completed',
              'records': <Map<String, dynamic>>[
                {'userId': 1, 'attendanceStatus': 'absent'},
              ],
            }),
          );

      await cubit.loadRosterData(5, true);
      cubit.applyStatus(1, 'present');

      // Should remain unchanged because read-only
      expect(cubit.state.rosterRows.first.status, 'absent');
    });

    test('setAllStatus updates all roster rows', () async {
      fakeAttendance.sessionDetailsResult =
          ServiceResult<AttendanceSessionModel>.success(
            AttendanceSessionModel.fromJson(<String, dynamic>{
              'id': 5,
              'sectionId': 10,
              'status': 'in_progress',
              'records': <Map<String, dynamic>>[
                {'userId': 1, 'attendanceStatus': 'absent'},
                {'userId': 2, 'attendanceStatus': 'absent'},
              ],
            }),
          );

      await cubit.loadRosterData(5, false);
      cubit.setAllStatus('present');

      expect(
        cubit.state.rosterRows.every((r) => r.status == 'present'),
        isTrue,
      );
    });

    test('updateNewSessionDate and updateNewSessionType update state', () {
      cubit.updateNewSessionDate('2026-05-01');
      expect(cubit.state.newSessionDate, '2026-05-01');

      cubit.updateNewSessionType('lab');
      expect(cubit.state.newSessionType, 'lab');
    });
  });
}
