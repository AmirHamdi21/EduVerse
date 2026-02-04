import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'attendance_state.dart';

class AttendanceCubit extends Cubit<AttendanceState> {
  AttendanceCubit() : super(const AttendanceState());

  Future<void> loadAttendance() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final records = _generateDemoRecords();
      final courseAttendances = _generateCourseAttendances(records);
      final statistics = _calculateStatistics(records);

      emit(
        state.copyWith(
          isLoading: false,
          allRecords: records,
          filteredRecords: records,
          courseAttendances: courseAttendances,
          statistics: statistics,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load attendance data: $e',
        ),
      );
    }
  }

  void setSelectedDate(DateTime date) {
    final filtered = _filterRecordsByDate(state.allRecords, date);
    emit(state.copyWith(selectedDate: date, filteredRecords: filtered));
  }

  void setSelectedCourse(String? courseId) {
    if (courseId == null) {
      emit(
        state.copyWith(
          clearSelectedCourse: true,
          filteredRecords: state.allRecords,
        ),
      );
    } else {
      final filtered = state.allRecords
          .where((r) => r.courseId == courseId)
          .toList();
      emit(
        state.copyWith(selectedCourseId: courseId, filteredRecords: filtered),
      );
    }
  }

  void setFilter(FilterOption option) {
    List<AttendanceRecord> filtered;

    if (option == FilterOption.all) {
      filtered = state.allRecords;
    } else {
      final status = _filterOptionToStatus(option);
      filtered = state.allRecords.where((r) => r.status == status).toList();
    }

    if (state.selectedCourseId != null) {
      filtered = filtered
          .where((r) => r.courseId == state.selectedCourseId)
          .toList();
    }

    emit(state.copyWith(filterOption: option, filteredRecords: filtered));
  }

  void setViewMode(ViewMode mode) {
    emit(state.copyWith(viewMode: mode));
  }

  void setSelectedTab(int index) {
    emit(state.copyWith(selectedTabIndex: index));
  }

  void setSearchQuery(String query) {
    List<AttendanceRecord> filtered = state.allRecords;

    if (query.isNotEmpty) {
      filtered = filtered.where((r) {
        return r.courseName.toLowerCase().contains(query.toLowerCase()) ||
            r.courseCode.toLowerCase().contains(query.toLowerCase()) ||
            (r.lectureTitle?.toLowerCase().contains(query.toLowerCase()) ??
                false);
      }).toList();
    }

    if (state.filterOption != FilterOption.all) {
      final status = _filterOptionToStatus(state.filterOption);
      filtered = filtered.where((r) => r.status == status).toList();
    }

    emit(state.copyWith(searchQuery: query, filteredRecords: filtered));
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  AttendanceStatus _filterOptionToStatus(FilterOption option) {
    switch (option) {
      case FilterOption.present:
        return AttendanceStatus.present;
      case FilterOption.absent:
        return AttendanceStatus.absent;
      case FilterOption.late:
        return AttendanceStatus.late;
      case FilterOption.excused:
        return AttendanceStatus.excused;
      default:
        return AttendanceStatus.present;
    }
  }

  List<AttendanceRecord> _filterRecordsByDate(
    List<AttendanceRecord> records,
    DateTime date,
  ) {
    return records.where((r) {
      return r.date.year == date.year &&
          r.date.month == date.month &&
          r.date.day == date.day;
    }).toList();
  }

  List<AttendanceRecord> _generateDemoRecords() {
    final random = Random(42);
    final List<AttendanceRecord> records = [];

    final courses = [
      {'id': 'cs101', 'name': 'Data Structures', 'code': 'CS101'},
      {'id': 'cs102', 'name': 'Algorithms', 'code': 'CS102'},
      {'id': 'cs103', 'name': 'Database Systems', 'code': 'CS103'},
      {'id': 'cs104', 'name': 'Computer Networks', 'code': 'CS104'},
      {'id': 'cs105', 'name': 'Software Engineering', 'code': 'CS105'},
      {'id': 'cs106', 'name': 'Machine Learning', 'code': 'CS106'},
    ];

    final lectureTitles = [
      'Introduction',
      'Fundamentals',
      'Advanced Topics',
      'Practical Session',
      'Review & Practice',
      'Lab Work',
      'Quiz & Assessment',
    ];

    final now = DateTime.now();

    for (int weekOffset = 0; weekOffset < 12; weekOffset++) {
      for (var course in courses) {
        final classesPerWeek = 2 + random.nextInt(2);

        for (int c = 0; c < classesPerWeek; c++) {
          final dayOffset = random.nextInt(5);
          final date = now.subtract(Duration(days: weekOffset * 7 + dayOffset));

          if (date.isAfter(now)) continue;

          final statusRoll = random.nextDouble();
          AttendanceStatus status;
          if (statusRoll < 0.75) {
            status = AttendanceStatus.present;
          } else if (statusRoll < 0.88) {
            status = AttendanceStatus.late;
          } else if (statusRoll < 0.95) {
            status = AttendanceStatus.absent;
          } else {
            status = AttendanceStatus.excused;
          }

          final hour = 8 + random.nextInt(8);

          records.add(
            AttendanceRecord(
              id: '${course['id']}_${date.millisecondsSinceEpoch}_$c',
              courseId: course['id']!,
              courseName: course['name']!,
              courseCode: course['code']!,
              date: date,
              status: status,
              lectureTitle: lectureTitles[random.nextInt(lectureTitles.length)],
              startTime: TimeOfDay(hour: hour, minute: 0),
              endTime: TimeOfDay(hour: hour + 1, minute: 30),
              note: status == AttendanceStatus.excused
                  ? 'Medical leave approved'
                  : status == AttendanceStatus.absent
                  ? 'Unexcused absence'
                  : null,
            ),
          );
        }
      }
    }

    records.sort((a, b) => b.date.compareTo(a.date));
    return records;
  }

  List<CourseAttendance> _generateCourseAttendances(
    List<AttendanceRecord> records,
  ) {
    final Map<String, List<AttendanceRecord>> courseRecords = {};

    for (var record in records) {
      courseRecords.putIfAbsent(record.courseId, () => []).add(record);
    }

    final gradientColors = [
      [0xFF6366F1, 0xFF8B5CF6],
      [0xFF3B82F6, 0xFF06B6D4],
      [0xFF10B981, 0xFF059669],
      [0xFFF59E0B, 0xFFEF4444],
      [0xFFEC4899, 0xFF8B5CF6],
      [0xFF14B8A6, 0xFF22D3EE],
    ];

    int colorIndex = 0;
    final List<CourseAttendance> courseAttendances = [];

    for (var entry in courseRecords.entries) {
      final records = entry.value;
      final presentCount = records
          .where((r) => r.status == AttendanceStatus.present)
          .length;
      final absentCount = records
          .where((r) => r.status == AttendanceStatus.absent)
          .length;
      final lateCount = records
          .where((r) => r.status == AttendanceStatus.late)
          .length;
      final excusedCount = records
          .where((r) => r.status == AttendanceStatus.excused)
          .length;

      courseAttendances.add(
        CourseAttendance(
          courseId: entry.key,
          courseName: records.first.courseName,
          courseCode: records.first.courseCode,
          totalClasses: records.length,
          presentCount: presentCount,
          absentCount: absentCount,
          lateCount: lateCount,
          excusedCount: excusedCount,
          gradientColors: gradientColors[colorIndex % gradientColors.length],
        ),
      );

      colorIndex++;
    }

    return courseAttendances;
  }

  AttendanceStatistics _calculateStatistics(List<AttendanceRecord> records) {
    final presentCount = records
        .where((r) => r.status == AttendanceStatus.present)
        .length;
    final absentCount = records
        .where((r) => r.status == AttendanceStatus.absent)
        .length;
    final lateCount = records
        .where((r) => r.status == AttendanceStatus.late)
        .length;
    final excusedCount = records
        .where((r) => r.status == AttendanceStatus.excused)
        .length;
    final totalClasses = records.length;

    final overallPercentage = totalClasses > 0
        ? ((presentCount + lateCount + excusedCount) / totalClasses) * 100
        : 100.0;

    final weeklyTrend = _calculateWeeklyTrend(records);

    return AttendanceStatistics(
      totalClasses: totalClasses,
      presentCount: presentCount,
      absentCount: absentCount,
      lateCount: lateCount,
      excusedCount: excusedCount,
      overallPercentage: overallPercentage,
      weeklyTrend: weeklyTrend,
    );
  }

  List<WeeklyAttendance> _calculateWeeklyTrend(List<AttendanceRecord> records) {
    final now = DateTime.now();
    final List<WeeklyAttendance> trend = [];

    for (int i = 7; i >= 0; i--) {
      final weekStart = now.subtract(Duration(days: i * 7 + now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));

      final weekRecords = records.where((r) {
        return r.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
            r.date.isBefore(weekEnd.add(const Duration(days: 1)));
      }).toList();

      if (weekRecords.isEmpty) continue;

      final attended = weekRecords
          .where(
            (r) =>
                r.status == AttendanceStatus.present ||
                r.status == AttendanceStatus.late ||
                r.status == AttendanceStatus.excused,
          )
          .length;

      final percentage = (attended / weekRecords.length) * 100;
      final weekLabel = 'W${8 - i}';

      trend.add(WeeklyAttendance(week: weekLabel, percentage: percentage));
    }

    return trend;
  }
}
