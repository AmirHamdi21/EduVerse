/// Submission status enum
enum SubmissionStatus {
  pending,
  graded,
  late,
}

/// Extension to get display properties for submission status
extension SubmissionStatusExtension on SubmissionStatus {
  String get name {
    switch (this) {
      case SubmissionStatus.pending:
        return 'pending';
      case SubmissionStatus.graded:
        return 'graded';
      case SubmissionStatus.late:
        return 'late';
    }
  }

  static SubmissionStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return SubmissionStatus.pending;
      case 'graded':
        return SubmissionStatus.graded;
      case 'late':
        return SubmissionStatus.late;
      default:
        return SubmissionStatus.pending;
    }
  }
}

/// Model representing a student submission
class Submission {
  final String id;
  final String studentName;
  final String studentEmail;
  final String studentAvatarUrl;
  final String assignmentTitle;
  final String assignmentId;
  final String courseName;
  final String courseId;
  final DateTime submittedAt;
  final DateTime? dueDate;
  SubmissionStatus status;
  int? grade;
  final int maxGrade;
  final int? lateDays;
  String? feedback;
  final String? fileUrl;
  final String? fileType;
  final int? fileSize;

  Submission({
    required this.id,
    required this.studentName,
    required this.studentEmail,
    this.studentAvatarUrl = '',
    required this.assignmentTitle,
    this.assignmentId = '',
    required this.courseName,
    this.courseId = '',
    required this.submittedAt,
    this.dueDate,
    required this.status,
    this.grade,
    required this.maxGrade,
    this.lateDays,
    this.feedback,
    this.fileUrl,
    this.fileType,
    this.fileSize,
  });

  /// Get grade percentage
  double get gradePercentage => grade != null ? (grade! / maxGrade) * 100 : 0;

  /// Check if submission is late
  bool get isLate => status == SubmissionStatus.late || (lateDays != null && lateDays! > 0);

  /// Get grade letter
  String get gradeLetter {
    if (grade == null) return '-';
    final percentage = gradePercentage;
    if (percentage >= 90) return 'A';
    if (percentage >= 80) return 'B';
    if (percentage >= 70) return 'C';
    if (percentage >= 60) return 'D';
    return 'F';
  }

  /// Copy with method for immutable updates
  Submission copyWith({
    String? id,
    String? studentName,
    String? studentEmail,
    String? studentAvatarUrl,
    String? assignmentTitle,
    String? assignmentId,
    String? courseName,
    String? courseId,
    DateTime? submittedAt,
    DateTime? dueDate,
    SubmissionStatus? status,
    int? grade,
    int? maxGrade,
    int? lateDays,
    String? feedback,
    String? fileUrl,
    String? fileType,
    int? fileSize,
  }) {
    return Submission(
      id: id ?? this.id,
      studentName: studentName ?? this.studentName,
      studentEmail: studentEmail ?? this.studentEmail,
      studentAvatarUrl: studentAvatarUrl ?? this.studentAvatarUrl,
      assignmentTitle: assignmentTitle ?? this.assignmentTitle,
      assignmentId: assignmentId ?? this.assignmentId,
      courseName: courseName ?? this.courseName,
      courseId: courseId ?? this.courseId,
      submittedAt: submittedAt ?? this.submittedAt,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      grade: grade ?? this.grade,
      maxGrade: maxGrade ?? this.maxGrade,
      lateDays: lateDays ?? this.lateDays,
      feedback: feedback ?? this.feedback,
      fileUrl: fileUrl ?? this.fileUrl,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
    );
  }
}
