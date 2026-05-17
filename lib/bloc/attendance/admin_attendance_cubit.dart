import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/bloc/route_request_controller.dart';
import '../../models/attendance/attendance_record_model.dart';
import '../../models/attendance/attendance_session_model.dart';
import '../../services/api/attendance_service.dart';
import 'admin_attendance_state.dart';

class AdminAttendanceCubit extends Cubit<AdminAttendanceState>
    with SafeRouteCubitMixin<AdminAttendanceState> {
  final AttendanceService _attendanceService;
  late final RouteRequestController _overviewRequest = trackRouteRequest(
    RouteRequestController(),
  );
  late final RouteRequestController _coursesRequest = trackRouteRequest(
    RouteRequestController(),
  );
  late final RouteRequestController _studentsRequest = trackRouteRequest(
    RouteRequestController(),
  );

  AdminAttendanceCubit({required AttendanceService attendanceService})
    : _attendanceService = attendanceService,
      super(const AdminAttendanceState());

  Future<void> initialize() async {
    emitIfOpen(state.copyWith(isLoading: true, clearError: true));
    await Future.wait(<Future<void>>[
      loadOverviewStats(),
      loadCourses(),
      loadStudents(),
    ]);
    emitIfOpen(state.copyWith(isLoading: false));
  }

  Future<void> loadOverviewStats() async {
    final requestId = _overviewRequest.begin();
    final sessions = await _attendanceService.getSessions(
      limit: 200,
      cancelToken: _overviewRequest.token,
    );
    if (!isRequestCurrent(_overviewRequest, requestId)) {
      return;
    }
    if (!sessions.isSuccess || sessions.data == null) {
      emitIfOpen(
        state.copyWith(
          error: sessions.error?.message ?? 'Failed to load overview stats',
        ),
      );
      return;
    }

    final items = sessions.data!;
    final total = items.fold<int>(
      0,
      (sum, s) =>
          sum + s.presentCount + s.absentCount + s.lateCount + s.excusedCount,
    );
    final attended = items.fold<int>(
      0,
      (sum, s) => sum + s.presentCount + s.lateCount + s.excusedCount,
    );

    final today = _dateOnly(DateTime.now());
    int presentToday = 0;
    int absentToday = 0;
    int lateToday = 0;

    for (final s in items.where((x) => x.sessionDate.startsWith(today))) {
      presentToday += s.presentCount;
      absentToday += s.absentCount;
      lateToday += s.lateCount;
    }

    final deptStats = _buildDepartmentStats(items);
    final weekly = _buildWeeklyTrends(items);

    emitIfOpen(
      state.copyWith(
        totalStudents: total,
        presentToday: presentToday,
        absentToday: absentToday,
        lateToday: lateToday,
        overallRate: total > 0 ? (attended / total) * 100 : 0,
        departmentStats: deptStats,
        weeklyTrends: weekly,
      ),
    );
  }

  Future<void> loadCourses() async {
    final requestId = _coursesRequest.begin();
    final sessions = await _attendanceService.getSessions(
      limit: 200,
      cancelToken: _coursesRequest.token,
    );
    if (!isRequestCurrent(_coursesRequest, requestId)) {
      return;
    }
    if (!sessions.isSuccess || sessions.data == null) {
      emitIfOpen(
        state.copyWith(
          error: sessions.error?.message ?? 'Failed to load courses',
        ),
      );
      return;
    }

    final map = <int, List<AttendanceSessionModel>>{};
    for (final session in sessions.data!) {
      map
          .putIfAbsent(session.sectionId, () => <AttendanceSessionModel>[])
          .add(session);
    }

    final departments = <String>['computer science', 'it', 'ai', 'software'];

    final courses = map.entries.map((entry) {
      final sectionId = entry.key;
      final list = entry.value;
      final present = list.fold<int>(0, (sum, s) => sum + s.presentCount);
      final absent = list.fold<int>(0, (sum, s) => sum + s.absentCount);
      final late = list.fold<int>(0, (sum, s) => sum + s.lateCount);
      final excused = list.fold<int>(0, (sum, s) => sum + s.excusedCount);
      final total = present + absent + late + excused;

      return CourseAttendanceDataAdmin(
        sectionId: sectionId,
        courseName: 'Section $sectionId',
        courseCode: 'SEC-$sectionId',
        department: departments[sectionId % departments.length],
        totalStudents: total,
        present: present,
        absent: absent,
        late: late,
      );
    }).toList();

    emitIfOpen(state.copyWith(courses: courses));
  }

  Future<void> loadStudents() async {
    final requestId = _studentsRequest.begin();
    final sessions = await _attendanceService.getSessions(
      status: 'completed',
      limit: 15,
      sortBy: 'sessionDate',
      sortOrder: 'DESC',
      cancelToken: _studentsRequest.token,
    );
    if (!isRequestCurrent(_studentsRequest, requestId)) {
      return;
    }
    if (!sessions.isSuccess || sessions.data == null) {
      emitIfOpen(
        state.copyWith(
          error: sessions.error?.message ?? 'Failed to load students',
        ),
      );
      return;
    }

    final latestStatus = <int, String>{};
    final latestName = <int, String>{};
    final latestEmail = <int, String>{};
    final totalClasses = <int, int>{};
    final attendedClasses = <int, int>{};

    for (final session in sessions.data!) {
      final detail = await _attendanceService.getSessionDetails(
        session.id,
        cancelToken: _studentsRequest.token,
      );
      if (!isRequestCurrent(_studentsRequest, requestId)) {
        return;
      }
      final records = detail.data?.records ?? const <AttendanceRecordModel>[];
      for (final record in records) {
        final userId = record.userId;
        final status = AttendanceRecordModel.normalizeStatus(
          record.attendanceStatus,
        );

        totalClasses[userId] = (totalClasses[userId] ?? 0) + 1;
        if (status == 'present' || status == 'late' || status == 'excused') {
          attendedClasses[userId] = (attendedClasses[userId] ?? 0) + 1;
        }

        latestStatus[userId] = status;
        latestName[userId] = record.displayName;
        latestEmail[userId] = record.email ?? '';
      }
    }

    final students = totalClasses.keys.map((userId) {
      return StudentAttendanceInfoAdmin(
        userId: userId,
        name: latestName[userId] ?? 'Student #$userId',
        email: latestEmail[userId] ?? '',
        totalClasses: totalClasses[userId] ?? 0,
        attendedClasses: attendedClasses[userId] ?? 0,
        latestStatus: latestStatus[userId] ?? 'absent',
      );
    }).toList()..sort((a, b) => a.attendanceRate.compareTo(b.attendanceRate));

    emitIfOpen(state.copyWith(students: students));
  }

  void setActiveTab(AdminAttendanceTab tab) {
    emitIfOpen(state.copyWith(activeTab: tab));
  }

  void setCourseSearch(String query) {
    emitIfOpen(state.copyWith(courseSearch: query));
  }

  void setDepartmentFilter(String department) {
    emitIfOpen(state.copyWith(departmentFilter: department));
  }

  void setStudentSearch(String query) {
    emitIfOpen(state.copyWith(studentSearch: query));
  }

  void setStatusFilter(String status) {
    emitIfOpen(state.copyWith(statusFilter: status));
  }

  List<DepartmentAttendanceData> _buildDepartmentStats(
    List<AttendanceSessionModel> sessions,
  ) {
    if (sessions.isEmpty) {
      return const <DepartmentAttendanceData>[];
    }

    final buckets = <String, List<AttendanceSessionModel>>{};
    for (final session in sessions) {
      final key = switch (session.sectionId % 4) {
        0 => 'computer science',
        1 => 'it',
        2 => 'software',
        _ => 'ai',
      };
      buckets.putIfAbsent(key, () => <AttendanceSessionModel>[]).add(session);
    }

    return buckets.entries.map((entry) {
      final total = entry.value.fold<int>(
        0,
        (sum, s) =>
            sum + s.presentCount + s.absentCount + s.lateCount + s.excusedCount,
      );
      final attended = entry.value.fold<int>(
        0,
        (sum, s) => sum + s.presentCount + s.lateCount + s.excusedCount,
      );
      return DepartmentAttendanceData(
        department: entry.key,
        attended: attended,
        total: total,
      );
    }).toList();
  }

  List<WeeklyTrendData> _buildWeeklyTrends(
    List<AttendanceSessionModel> sessions,
  ) {
    final now = DateTime.now();
    final trends = <WeeklyTrendData>[];

    for (int i = 7; i >= 0; i--) {
      final start = now.subtract(Duration(days: i * 7 + now.weekday - 1));
      final end = start.add(const Duration(days: 6));

      final inWeek = sessions.where((s) {
        final dt = DateTime.tryParse(s.sessionDate);
        if (dt == null) return false;
        return !dt.isBefore(start) && !dt.isAfter(end);
      }).toList();

      if (inWeek.isEmpty) continue;

      final total = inWeek.fold<int>(
        0,
        (sum, s) =>
            sum + s.presentCount + s.absentCount + s.lateCount + s.excusedCount,
      );
      final attended = inWeek.fold<int>(
        0,
        (sum, s) => sum + s.presentCount + s.lateCount + s.excusedCount,
      );

      trends.add(
        WeeklyTrendData(
          label: 'W${8 - i}',
          rate: total > 0 ? (attended / total) * 100 : 0,
        ),
      );
    }

    return trends;
  }

  static String _dateOnly(DateTime d) {
    final month = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$month-$day';
  }
}
