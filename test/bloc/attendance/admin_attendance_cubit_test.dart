import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/attendance/admin_attendance_cubit.dart';
import 'package:edu_verse/bloc/attendance/admin_attendance_state.dart';
import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/models/attendance/attendance_session_model.dart';
import 'package:edu_verse/services/api/attendance_service.dart';

class _FakeAttendanceService implements AttendanceService {
  ServiceResult<List<AttendanceSessionModel>> sessionsResult =
      ServiceResult<List<AttendanceSessionModel>>.success(const []);

  ServiceResult<AttendanceSessionModel>? sessionDetailsResult;

  @override
  Future<ServiceResult<List<AttendanceSessionModel>>> getSessions({
    int? sectionId,
    int? courseId,
    String? status,
    int? limit,
    String? sortBy,
    String? sortOrder,
  }) async =>
      sessionsResult;

  @override
  Future<ServiceResult<AttendanceSessionModel>> getSessionDetails(
    int id,
  ) async =>
      sessionDetailsResult ??
      ServiceResult<AttendanceSessionModel>.success(
        AttendanceSessionModel.fromJson(<String, dynamic>{
          'id': id,
          'sectionId': 1,
          'status': 'completed',
          'records': <Map<String, dynamic>>[],
        }),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('AdminAttendanceCubit', () {
    late _FakeAttendanceService fakeService;
    late AdminAttendanceCubit cubit;

    setUp(() {
      fakeService = _FakeAttendanceService();
      cubit = AdminAttendanceCubit(attendanceService: fakeService);
    });

    tearDown(() async {
      await cubit.close();
    });

    test('initial state has overview tab and empty data', () {
      expect(cubit.state.activeTab, AdminAttendanceTab.overview);
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.courses, isEmpty);
      expect(cubit.state.students, isEmpty);
      expect(cubit.state.overallRate, 0);
    });

    test('setActiveTab changes active tab', () {
      cubit.setActiveTab(AdminAttendanceTab.courses);
      expect(cubit.state.activeTab, AdminAttendanceTab.courses);

      cubit.setActiveTab(AdminAttendanceTab.students);
      expect(cubit.state.activeTab, AdminAttendanceTab.students);
    });

    test('setCourseSearch updates search query', () {
      cubit.setCourseSearch('physics');
      expect(cubit.state.courseSearch, 'physics');
    });

    test('setDepartmentFilter updates filter', () {
      cubit.setDepartmentFilter('computer science');
      expect(cubit.state.departmentFilter, 'computer science');
    });

    test('setStudentSearch updates search query', () {
      cubit.setStudentSearch('john');
      expect(cubit.state.studentSearch, 'john');
    });

    test('setStatusFilter updates filter', () {
      cubit.setStatusFilter('high');
      expect(cubit.state.statusFilter, 'high');
    });

    test('loadOverviewStats computes stats from sessions', () async {
      fakeService.sessionsResult =
          ServiceResult<List<AttendanceSessionModel>>.success([
        AttendanceSessionModel.fromJson(<String, dynamic>{
          'id': 1,
          'sectionId': 1,
          'sessionDate': _dateOnly(DateTime.now()),
          'status': 'completed',
          'presentCount': 20,
          'absentCount': 5,
          'lateCount': 3,
          'excusedCount': 2,
        }),
      ]);

      await cubit.loadOverviewStats();

      expect(cubit.state.totalStudents, 30); // 20+5+3+2
      expect(cubit.state.presentToday, 20);
      expect(cubit.state.absentToday, 5);
      expect(cubit.state.lateToday, 3);
      expect(cubit.state.overallRate, greaterThan(0));
    });

    test('loadCourses groups by section', () async {
      fakeService.sessionsResult =
          ServiceResult<List<AttendanceSessionModel>>.success([
        AttendanceSessionModel.fromJson(<String, dynamic>{
          'id': 1,
          'sectionId': 10,
          'status': 'completed',
          'presentCount': 15,
          'absentCount': 5,
        }),
        AttendanceSessionModel.fromJson(<String, dynamic>{
          'id': 2,
          'sectionId': 10,
          'status': 'completed',
          'presentCount': 18,
          'absentCount': 2,
        }),
        AttendanceSessionModel.fromJson(<String, dynamic>{
          'id': 3,
          'sectionId': 20,
          'status': 'completed',
          'presentCount': 10,
          'absentCount': 10,
        }),
      ]);

      await cubit.loadCourses();

      expect(cubit.state.courses.length, 2); // Two distinct sectionIds
    });
  });

  group('AdminAttendanceState — filteredCourses', () {
    test('filteredCourses applies courseSearch filter', () {
      final state = AdminAttendanceState(
        courses: [
          const CourseAttendanceDataAdmin(
            sectionId: 1,
            courseName: 'Physics 101',
            courseCode: 'PHY101',
            department: 'physics',
            totalStudents: 30,
            present: 25,
            absent: 5,
            late: 0,
          ),
          const CourseAttendanceDataAdmin(
            sectionId: 2,
            courseName: 'Math 200',
            courseCode: 'MATH200',
            department: 'math',
            totalStudents: 40,
            present: 35,
            absent: 5,
            late: 0,
          ),
        ],
        courseSearch: 'physics',
      );

      expect(state.filteredCourses.length, 1);
      expect(state.filteredCourses.first.courseName, 'Physics 101');
    });

    test('filteredCourses applies departmentFilter', () {
      final state = AdminAttendanceState(
        courses: [
          const CourseAttendanceDataAdmin(
            sectionId: 1,
            courseName: 'CS 101',
            courseCode: 'CS101',
            department: 'computer science',
            totalStudents: 30,
            present: 25,
            absent: 5,
            late: 0,
          ),
          const CourseAttendanceDataAdmin(
            sectionId: 2,
            courseName: 'Math 200',
            courseCode: 'MATH200',
            department: 'math',
            totalStudents: 40,
            present: 35,
            absent: 5,
            late: 0,
          ),
        ],
        departmentFilter: 'math',
      );

      expect(state.filteredCourses.length, 1);
      expect(state.filteredCourses.first.department, 'math');
    });
  });

  group('AdminAttendanceState — filteredStudents', () {
    test('filteredStudents applies statusFilter', () {
      final state = AdminAttendanceState(
        students: [
          const StudentAttendanceInfoAdmin(
            userId: 1,
            name: 'Good Student',
            email: 'good@example.com',
            totalClasses: 20,
            attendedClasses: 19,
            latestStatus: 'present',
          ),
          const StudentAttendanceInfoAdmin(
            userId: 2,
            name: 'At-Risk Student',
            email: 'risk@example.com',
            totalClasses: 20,
            attendedClasses: 10,
            latestStatus: 'absent',
          ),
        ],
        statusFilter: 'high',
      );

      expect(state.filteredStudents.length, 1);
      expect(state.filteredStudents.first.name, 'At-Risk Student');
    });

    test('StudentAttendanceInfoAdmin risk levels work correctly', () {
      const low = StudentAttendanceInfoAdmin(
        userId: 1,
        name: 'A',
        email: '',
        totalClasses: 20,
        attendedClasses: 18,
        latestStatus: 'present',
      );
      expect(low.riskLevel, StudentRiskLevel.low);

      const medium = StudentAttendanceInfoAdmin(
        userId: 2,
        name: 'B',
        email: '',
        totalClasses: 20,
        attendedClasses: 15,
        latestStatus: 'present',
      );
      expect(medium.riskLevel, StudentRiskLevel.medium);

      const high = StudentAttendanceInfoAdmin(
        userId: 3,
        name: 'C',
        email: '',
        totalClasses: 20,
        attendedClasses: 10,
        latestStatus: 'absent',
      );
      expect(high.riskLevel, StudentRiskLevel.high);
    });
  });
}

String _dateOnly(DateTime d) {
  final month = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '${d.year}-$month-$day';
}
