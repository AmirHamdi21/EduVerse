// Model for instructor attendance management

enum AttendanceStatus { present, absent, late, excused, unmarked }

extension AttendanceStatusExtension on AttendanceStatus {
  String get displayName {
    switch (this) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.excused:
        return 'Excused';
      case AttendanceStatus.unmarked:
        return 'Unmarked';
    }
  }

  String get icon {
    switch (this) {
      case AttendanceStatus.present:
        return '✓';
      case AttendanceStatus.absent:
        return '✗';
      case AttendanceStatus.late:
        return '⏰';
      case AttendanceStatus.excused:
        return '📋';
      case AttendanceStatus.unmarked:
        return '○';
    }
  }
}

class StudentAttendance {
  final String id;
  final String studentId;
  final String studentName;
  final String? avatarUrl;
  final AttendanceStatus status;
  final double overallAttendanceRate;
  final DateTime? lastAttended;
  final String? note;
  final int totalClasses;
  final int attendedClasses;

  StudentAttendance({
    required this.id,
    required this.studentId,
    required this.studentName,
    this.avatarUrl,
    this.status = AttendanceStatus.unmarked,
    this.overallAttendanceRate = 0.0,
    this.lastAttended,
    this.note,
    this.totalClasses = 0,
    this.attendedClasses = 0,
  });

  StudentAttendance copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? avatarUrl,
    AttendanceStatus? status,
    double? overallAttendanceRate,
    DateTime? lastAttended,
    String? note,
    int? totalClasses,
    int? attendedClasses,
  }) {
    return StudentAttendance(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
      overallAttendanceRate:
          overallAttendanceRate ?? this.overallAttendanceRate,
      lastAttended: lastAttended ?? this.lastAttended,
      note: note ?? this.note,
      totalClasses: totalClasses ?? this.totalClasses,
      attendedClasses: attendedClasses ?? this.attendedClasses,
    );
  }
}

class AttendanceSession {
  final String id;
  final String courseId;
  final String courseName;
  final String courseCode;
  final int weekNumber;
  final String sessionType; // Lecture, Lab, Tutorial
  final DateTime sessionDate;
  final List<StudentAttendance> students;
  final bool isSaved;

  AttendanceSession({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.courseCode,
    required this.weekNumber,
    required this.sessionType,
    required this.sessionDate,
    required this.students,
    this.isSaved = false,
  });

  int get presentCount =>
      students.where((s) => s.status == AttendanceStatus.present).length;
  int get absentCount =>
      students.where((s) => s.status == AttendanceStatus.absent).length;
  int get lateCount =>
      students.where((s) => s.status == AttendanceStatus.late).length;
  int get excusedCount =>
      students.where((s) => s.status == AttendanceStatus.excused).length;
  int get unmarkedCount =>
      students.where((s) => s.status == AttendanceStatus.unmarked).length;
  int get markedCount => students.length - unmarkedCount;

  double get progressRate =>
      students.isEmpty ? 0 : markedCount / students.length;

  AttendanceSession copyWith({
    String? id,
    String? courseId,
    String? courseName,
    String? courseCode,
    int? weekNumber,
    String? sessionType,
    DateTime? sessionDate,
    List<StudentAttendance>? students,
    bool? isSaved,
  }) {
    return AttendanceSession(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      courseCode: courseCode ?? this.courseCode,
      weekNumber: weekNumber ?? this.weekNumber,
      sessionType: sessionType ?? this.sessionType,
      sessionDate: sessionDate ?? this.sessionDate,
      students: students ?? this.students,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}

class CourseAttendanceStats {
  final String courseId;
  final String courseName;
  final double averageAttendance;
  final int totalSessions;
  final int studentsAtRisk;
  final List<StudentAttendance> lowAttendanceStudents;

  CourseAttendanceStats({
    required this.courseId,
    required this.courseName,
    required this.averageAttendance,
    required this.totalSessions,
    required this.studentsAtRisk,
    required this.lowAttendanceStudents,
  });
}
