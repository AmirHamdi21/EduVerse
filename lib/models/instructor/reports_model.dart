// Models for Reports & Analytics screen

/// Student performance data for reports
class StudentReportData {
  final String id;
  final String studentId;
  final String name;
  final String? avatarUrl;
  final double averageGrade;
  final double attendanceRate;
  final double assignmentScore;
  final double labScore;
  final double quizScore;
  final double midtermScore;
  final StudentPerformanceTrend trend;
  final bool isAtRisk;
  final DateTime? lastActivity;

  const StudentReportData({
    required this.id,
    required this.studentId,
    required this.name,
    this.avatarUrl,
    required this.averageGrade,
    required this.attendanceRate,
    this.assignmentScore = 0,
    this.labScore = 0,
    this.quizScore = 0,
    this.midtermScore = 0,
    this.trend = StudentPerformanceTrend.stable,
    this.isAtRisk = false,
    this.lastActivity,
  });

  StudentReportData copyWith({
    String? id,
    String? studentId,
    String? name,
    String? avatarUrl,
    double? averageGrade,
    double? attendanceRate,
    double? assignmentScore,
    double? labScore,
    double? quizScore,
    double? midtermScore,
    StudentPerformanceTrend? trend,
    bool? isAtRisk,
    DateTime? lastActivity,
  }) {
    return StudentReportData(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      averageGrade: averageGrade ?? this.averageGrade,
      attendanceRate: attendanceRate ?? this.attendanceRate,
      assignmentScore: assignmentScore ?? this.assignmentScore,
      labScore: labScore ?? this.labScore,
      quizScore: quizScore ?? this.quizScore,
      midtermScore: midtermScore ?? this.midtermScore,
      trend: trend ?? this.trend,
      isAtRisk: isAtRisk ?? this.isAtRisk,
      lastActivity: lastActivity ?? this.lastActivity,
    );
  }

  /// Get performance letter grade
  String get letterGrade {
    if (averageGrade >= 90) return 'A';
    if (averageGrade >= 80) return 'B';
    if (averageGrade >= 70) return 'C';
    if (averageGrade >= 60) return 'D';
    return 'F';
  }

  /// Get grade color category
  GradeCategory get gradeCategory {
    if (averageGrade >= 90) return GradeCategory.excellent;
    if (averageGrade >= 80) return GradeCategory.good;
    if (averageGrade >= 70) return GradeCategory.satisfactory;
    if (averageGrade >= 60) return GradeCategory.needsImprovement;
    return GradeCategory.failing;
  }
}

/// Performance trend direction
enum StudentPerformanceTrend {
  improving,
  stable,
  declining,
}

/// Grade categories for coloring
enum GradeCategory {
  excellent,
  good,
  satisfactory,
  needsImprovement,
  failing,
}

/// Course statistics summary
class CourseStatistics {
  final String courseId;
  final String courseName;
  final String courseCode;
  final int totalStudents;
  final double averageGrade;
  final double attendanceRate;
  final int studentsAtRisk;
  final GradeDistribution gradeDistribution;
  final EngagementMetrics engagementMetrics;
  final AttendanceBreakdown attendanceBreakdown;
  final String? aiInsight;

  const CourseStatistics({
    required this.courseId,
    required this.courseName,
    required this.courseCode,
    required this.totalStudents,
    required this.averageGrade,
    required this.attendanceRate,
    required this.studentsAtRisk,
    required this.gradeDistribution,
    required this.engagementMetrics,
    required this.attendanceBreakdown,
    this.aiInsight,
  });
}

/// Grade distribution data
class GradeDistribution {
  final int gradeA; // 90-100%
  final int gradeB; // 80-89%
  final int gradeC; // 70-79%
  final int gradeD; // 60-69%
  final int gradeF; // Below 60%

  const GradeDistribution({
    required this.gradeA,
    required this.gradeB,
    required this.gradeC,
    required this.gradeD,
    required this.gradeF,
  });

  int get total => gradeA + gradeB + gradeC + gradeD + gradeF;

  double get percentA => total > 0 ? (gradeA / total) * 100 : 0;
  double get percentB => total > 0 ? (gradeB / total) * 100 : 0;
  double get percentC => total > 0 ? (gradeC / total) * 100 : 0;
  double get percentD => total > 0 ? (gradeD / total) * 100 : 0;
  double get percentF => total > 0 ? (gradeF / total) * 100 : 0;
}

/// Engagement metrics for analytics
class EngagementMetrics {
  final double assignmentSubmissionRate;
  final double labCompletionRate;
  final double discussionParticipation;
  final double videoWatchRate;
  final double resourceAccessRate;

  const EngagementMetrics({
    required this.assignmentSubmissionRate,
    required this.labCompletionRate,
    required this.discussionParticipation,
    this.videoWatchRate = 0,
    this.resourceAccessRate = 0,
  });
}

/// Attendance breakdown for overview
class AttendanceBreakdown {
  final double presentRate;
  final double absentRate;
  final double lateRate;
  final String? insight;

  const AttendanceBreakdown({
    required this.presentRate,
    required this.absentRate,
    required this.lateRate,
    this.insight,
  });
}

/// Report tab types
enum ReportTabType {
  performance,
  attendance,
  analytics,
}

/// Filter options for reports
enum ReportFilterType {
  all,
  atRisk,
  excellent,
  needsImprovement,
}

/// Sort options for student list
enum ReportSortType {
  nameAsc,
  nameDesc,
  gradeHighToLow,
  gradeLowToHigh,
  attendanceHighToLow,
  attendanceLowToHigh,
}

/// Export format options
enum ExportFormat {
  pdf,
  csv,
  excel,
}
