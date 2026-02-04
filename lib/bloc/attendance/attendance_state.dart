import 'package:equatable/equatable.dart';

enum AttendanceStatus { present, absent, late, excused }

enum ViewMode { calendar, list }

enum FilterOption { all, present, absent, late, excused }

class AttendanceRecord extends Equatable {
  final String id;
  final String courseId;
  final String courseName;
  final String courseCode;
  final DateTime date;
  final AttendanceStatus status;
  final String? note;
  final String? lectureTitle;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const AttendanceRecord({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.courseCode,
    required this.date,
    required this.status,
    this.note,
    this.lectureTitle,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props => [
        id,
        courseId,
        courseName,
        courseCode,
        date,
        status,
        note,
        lectureTitle,
        startTime,
        endTime,
      ];
}

class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});

  String format() {
    final h = hour > 12 ? hour - 12 : hour;
    final period = hour >= 12 ? 'PM' : 'AM';
    return '${h.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }
}

class CourseAttendance extends Equatable {
  final String courseId;
  final String courseName;
  final String courseCode;
  final int totalClasses;
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final int excusedCount;
  final List<int> gradientColors;

  const CourseAttendance({
    required this.courseId,
    required this.courseName,
    required this.courseCode,
    required this.totalClasses,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
    required this.excusedCount,
    required this.gradientColors,
  });

  double get attendancePercentage {
    if (totalClasses == 0) return 100.0;
    return ((presentCount + lateCount + excusedCount) / totalClasses) * 100;
  }

  @override
  List<Object?> get props => [
        courseId,
        courseName,
        courseCode,
        totalClasses,
        presentCount,
        absentCount,
        lateCount,
        excusedCount,
        gradientColors,
      ];
}

class AttendanceStatistics extends Equatable {
  final int totalClasses;
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final int excusedCount;
  final double overallPercentage;
  final List<WeeklyAttendance> weeklyTrend;

  const AttendanceStatistics({
    required this.totalClasses,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
    required this.excusedCount,
    required this.overallPercentage,
    required this.weeklyTrend,
  });

  @override
  List<Object?> get props => [
        totalClasses,
        presentCount,
        absentCount,
        lateCount,
        excusedCount,
        overallPercentage,
        weeklyTrend,
      ];
}

class WeeklyAttendance extends Equatable {
  final String week;
  final double percentage;

  const WeeklyAttendance({required this.week, required this.percentage});

  @override
  List<Object?> get props => [week, percentage];
}

class AttendanceState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final List<AttendanceRecord> allRecords;
  final List<AttendanceRecord> filteredRecords;
  final List<CourseAttendance> courseAttendances;
  final AttendanceStatistics? statistics;
  final DateTime selectedDate;
  final String? selectedCourseId;
  final FilterOption filterOption;
  final ViewMode viewMode;
  final int selectedTabIndex;
  final String searchQuery;

  const AttendanceState({
    this.isLoading = false,
    this.errorMessage,
    this.allRecords = const [],
    this.filteredRecords = const [],
    this.courseAttendances = const [],
    this.statistics,
    DateTime? selectedDate,
    this.selectedCourseId,
    this.filterOption = FilterOption.all,
    this.viewMode = ViewMode.calendar,
    this.selectedTabIndex = 0,
    this.searchQuery = '',
  }) : selectedDate = selectedDate ?? const _DefaultDate();

  AttendanceState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    List<AttendanceRecord>? allRecords,
    List<AttendanceRecord>? filteredRecords,
    List<CourseAttendance>? courseAttendances,
    AttendanceStatistics? statistics,
    DateTime? selectedDate,
    String? selectedCourseId,
    bool clearSelectedCourse = false,
    FilterOption? filterOption,
    ViewMode? viewMode,
    int? selectedTabIndex,
    String? searchQuery,
  }) {
    return AttendanceState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      allRecords: allRecords ?? this.allRecords,
      filteredRecords: filteredRecords ?? this.filteredRecords,
      courseAttendances: courseAttendances ?? this.courseAttendances,
      statistics: statistics ?? this.statistics,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedCourseId:
          clearSelectedCourse ? null : selectedCourseId ?? this.selectedCourseId,
      filterOption: filterOption ?? this.filterOption,
      viewMode: viewMode ?? this.viewMode,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorMessage,
        allRecords,
        filteredRecords,
        courseAttendances,
        statistics,
        selectedDate,
        selectedCourseId,
        filterOption,
        viewMode,
        selectedTabIndex,
        searchQuery,
      ];
}

class _DefaultDate implements DateTime {
  const _DefaultDate();

  DateTime get _now => DateTime.now();

  @override
  int get year => _now.year;
  @override
  int get month => _now.month;
  @override
  int get day => _now.day;
  @override
  int get hour => _now.hour;
  @override
  int get minute => _now.minute;
  @override
  int get second => _now.second;
  @override
  int get millisecond => _now.millisecond;
  @override
  int get microsecond => _now.microsecond;
  @override
  int get weekday => _now.weekday;
  @override
  bool get isUtc => _now.isUtc;
  @override
  int get millisecondsSinceEpoch => _now.millisecondsSinceEpoch;
  @override
  int get microsecondsSinceEpoch => _now.microsecondsSinceEpoch;
  @override
  String get timeZoneName => _now.timeZoneName;
  @override
  Duration get timeZoneOffset => _now.timeZoneOffset;

  @override
  DateTime add(Duration duration) => _now.add(duration);
  @override
  DateTime subtract(Duration duration) => _now.subtract(duration);
  @override
  Duration difference(DateTime other) => _now.difference(other);
  @override
  bool isAfter(DateTime other) => _now.isAfter(other);
  @override
  bool isBefore(DateTime other) => _now.isBefore(other);
  @override
  bool isAtSameMomentAs(DateTime other) => _now.isAtSameMomentAs(other);
  @override
  int compareTo(DateTime other) => _now.compareTo(other);
  @override
  DateTime toLocal() => _now.toLocal();
  @override
  DateTime toUtc() => _now.toUtc();
  @override
  String toIso8601String() => _now.toIso8601String();
  @override
  String toString() => _now.toString();
}
