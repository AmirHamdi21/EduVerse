import 'package:equatable/equatable.dart';

enum AdminAttendanceTab { overview, courses, students }

enum StudentRiskLevel { low, medium, high }

class DepartmentAttendanceData extends Equatable {
  final String department;
  final int attended;
  final int total;

  const DepartmentAttendanceData({
    required this.department,
    required this.attended,
    required this.total,
  });

  double get rate => total > 0 ? (attended / total) * 100 : 0;

  @override
  List<Object?> get props => [department, attended, total];
}

class WeeklyTrendData extends Equatable {
  final String label;
  final double rate;

  const WeeklyTrendData({required this.label, required this.rate});

  @override
  List<Object?> get props => [label, rate];
}

class CourseAttendanceDataAdmin extends Equatable {
  final int sectionId;
  final String courseName;
  final String courseCode;
  final String department;
  final int totalStudents;
  final int present;
  final int absent;
  final int late;

  const CourseAttendanceDataAdmin({
    required this.sectionId,
    required this.courseName,
    required this.courseCode,
    required this.department,
    required this.totalStudents,
    required this.present,
    required this.absent,
    required this.late,
  });

  double get attendanceRate =>
      totalStudents > 0 ? ((present + late) / totalStudents) * 100 : 0;

  @override
  List<Object?> get props => [
    sectionId,
    courseName,
    courseCode,
    department,
    totalStudents,
    present,
    absent,
    late,
  ];
}

class StudentAttendanceInfoAdmin extends Equatable {
  final int userId;
  final String name;
  final String email;
  final int totalClasses;
  final int attendedClasses;
  final String latestStatus;

  const StudentAttendanceInfoAdmin({
    required this.userId,
    required this.name,
    required this.email,
    required this.totalClasses,
    required this.attendedClasses,
    required this.latestStatus,
  });

  double get attendanceRate =>
      totalClasses > 0 ? (attendedClasses / totalClasses) * 100 : 0;

  StudentRiskLevel get riskLevel {
    if (attendanceRate >= 85) return StudentRiskLevel.low;
    if (attendanceRate >= 70) return StudentRiskLevel.medium;
    return StudentRiskLevel.high;
  }

  @override
  List<Object?> get props => [
    userId,
    name,
    email,
    totalClasses,
    attendedClasses,
    latestStatus,
  ];
}

class AdminAttendanceState extends Equatable {
  final AdminAttendanceTab activeTab;
  final bool isLoading;
  final String? error;

  final int totalStudents;
  final int presentToday;
  final int absentToday;
  final int lateToday;
  final double overallRate;
  final List<DepartmentAttendanceData> departmentStats;
  final List<WeeklyTrendData> weeklyTrends;

  final List<CourseAttendanceDataAdmin> courses;
  final String courseSearch;
  final String departmentFilter;

  final List<StudentAttendanceInfoAdmin> students;
  final String studentSearch;
  final String statusFilter;

  const AdminAttendanceState({
    this.activeTab = AdminAttendanceTab.overview,
    this.isLoading = false,
    this.error,
    this.totalStudents = 0,
    this.presentToday = 0,
    this.absentToday = 0,
    this.lateToday = 0,
    this.overallRate = 0,
    this.departmentStats = const <DepartmentAttendanceData>[],
    this.weeklyTrends = const <WeeklyTrendData>[],
    this.courses = const <CourseAttendanceDataAdmin>[],
    this.courseSearch = '',
    this.departmentFilter = 'all',
    this.students = const <StudentAttendanceInfoAdmin>[],
    this.studentSearch = '',
    this.statusFilter = 'all',
  });

  List<CourseAttendanceDataAdmin> get filteredCourses {
    var filtered = courses;
    final q = courseSearch.trim().toLowerCase();
    if (q.isNotEmpty) {
      filtered = filtered.where((c) {
        return c.courseName.toLowerCase().contains(q) ||
            c.courseCode.toLowerCase().contains(q);
      }).toList();
    }

    if (departmentFilter != 'all') {
      filtered = filtered
          .where(
            (c) => c.department.toLowerCase() == departmentFilter.toLowerCase(),
          )
          .toList();
    }

    return filtered;
  }

  List<StudentAttendanceInfoAdmin> get filteredStudents {
    var filtered = students;

    final q = studentSearch.trim().toLowerCase();
    if (q.isNotEmpty) {
      filtered = filtered.where((s) {
        return s.name.toLowerCase().contains(q) ||
            s.email.toLowerCase().contains(q) ||
            s.userId.toString().contains(q);
      }).toList();
    }

    if (statusFilter != 'all') {
      filtered = filtered.where((s) {
        switch (statusFilter) {
          case 'low':
            return s.riskLevel == StudentRiskLevel.low;
          case 'medium':
            return s.riskLevel == StudentRiskLevel.medium;
          case 'high':
            return s.riskLevel == StudentRiskLevel.high;
          default:
            return true;
        }
      }).toList();
    }

    return filtered;
  }

  AdminAttendanceState copyWith({
    AdminAttendanceTab? activeTab,
    bool? isLoading,
    String? error,
    bool clearError = false,
    int? totalStudents,
    int? presentToday,
    int? absentToday,
    int? lateToday,
    double? overallRate,
    List<DepartmentAttendanceData>? departmentStats,
    List<WeeklyTrendData>? weeklyTrends,
    List<CourseAttendanceDataAdmin>? courses,
    String? courseSearch,
    String? departmentFilter,
    List<StudentAttendanceInfoAdmin>? students,
    String? studentSearch,
    String? statusFilter,
  }) {
    return AdminAttendanceState(
      activeTab: activeTab ?? this.activeTab,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      totalStudents: totalStudents ?? this.totalStudents,
      presentToday: presentToday ?? this.presentToday,
      absentToday: absentToday ?? this.absentToday,
      lateToday: lateToday ?? this.lateToday,
      overallRate: overallRate ?? this.overallRate,
      departmentStats: departmentStats ?? this.departmentStats,
      weeklyTrends: weeklyTrends ?? this.weeklyTrends,
      courses: courses ?? this.courses,
      courseSearch: courseSearch ?? this.courseSearch,
      departmentFilter: departmentFilter ?? this.departmentFilter,
      students: students ?? this.students,
      studentSearch: studentSearch ?? this.studentSearch,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }

  @override
  List<Object?> get props => [
    activeTab,
    isLoading,
    error,
    totalStudents,
    presentToday,
    absentToday,
    lateToday,
    overallRate,
    departmentStats,
    weeklyTrends,
    courses,
    courseSearch,
    departmentFilter,
    students,
    studentSearch,
    statusFilter,
  ];
}
