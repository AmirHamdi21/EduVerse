import 'package:equatable/equatable.dart';

/// Maps GET /attendance/my and GET /attendance/by-student/:id responses.
class StudentAttendanceSummaryModel extends Equatable {
  final int courseId;
  final String courseName;
  final String courseCode;
  final int totalClasses;
  final int attended;
  final int absent;
  final int lateCount; // `late` is reserved in Dart
  final int excused;
  final double percentage;
  final String? lastClassDate;

  const StudentAttendanceSummaryModel({
    required this.courseId,
    required this.courseName,
    required this.courseCode,
    required this.totalClasses,
    required this.attended,
    required this.absent,
    this.lateCount = 0,
    this.excused = 0,
    required this.percentage,
    this.lastClassDate,
  });

  factory StudentAttendanceSummaryModel.fromJson(Map<String, dynamic> json) {
    // The backend may return either per-course fields (courseId, totalClasses,
    // attended, …) or flat aggregate fields (totalSessions, totalPresent, …).
    // We handle both formats with fallback mappings.
    final total = _toInt(json['totalClasses']) > 0
        ? _toInt(json['totalClasses'])
        : _toInt(json['totalSessions']);
    final attended = _toInt(json['attended']) > 0
        ? _toInt(json['attended'])
        : _toInt(json['totalPresent']);
    final absent = _toInt(json['absent']) > 0
        ? _toInt(json['absent'])
        : _toInt(json['totalAbsent']);
    final late = _toInt(json['late']) > 0
        ? _toInt(json['late'])
        : _toInt(json['totalLate']);
    final excused = _toInt(json['excused']) > 0
        ? _toInt(json['excused'])
        : _toInt(json['totalExcused']);

    final rawPct = json['percentage'] ?? json['attendancePercentage'];
    final parsedPct = rawPct is num
        ? rawPct.toDouble()
        : double.tryParse(rawPct?.toString() ?? '');

    // For courseName, fall back to studentName when the backend returns the
    // flat summary (which has no per-course breakdown).
    final courseName =
        json['courseName']?.toString() ?? json['studentName']?.toString() ?? '';

    return StudentAttendanceSummaryModel(
      courseId: _toInt(json['courseId']) > 0
          ? _toInt(json['courseId'])
          : _toInt(json['userId']),
      courseName: courseName,
      courseCode: json['courseCode']?.toString() ?? '',
      totalClasses: total,
      attended: attended,
      absent: absent,
      lateCount: late,
      excused: excused,
      percentage: parsedPct ?? (total > 0 ? (attended / total) * 100 : 0),
      lastClassDate: json['lastClassDate']?.toString(),
    );
  }

  String get statusLabel {
    if (percentage >= 90) return 'excellent';
    if (percentage >= 80) return 'good';
    return 'warning';
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  List<Object?> get props => [
    courseId,
    courseName,
    courseCode,
    totalClasses,
    attended,
    absent,
    lateCount,
    excused,
    percentage,
    lastClassDate,
  ];
}
