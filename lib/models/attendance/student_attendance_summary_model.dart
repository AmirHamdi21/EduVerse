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
    final total = _toInt(json['totalClasses']);
    final attended = _toInt(json['attended']);
    final rawPct = json['percentage'];
    final parsedPct = rawPct is num
        ? rawPct.toDouble()
        : double.tryParse(rawPct?.toString() ?? '');

    return StudentAttendanceSummaryModel(
      courseId: _toInt(json['courseId']),
      courseName: json['courseName']?.toString() ?? '',
      courseCode: json['courseCode']?.toString() ?? '',
      totalClasses: total,
      attended: attended,
      absent: _toInt(json['absent']),
      lateCount: _toInt(json['late']),
      excused: _toInt(json['excused']),
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
