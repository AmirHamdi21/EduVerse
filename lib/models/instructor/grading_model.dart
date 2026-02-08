import 'package:flutter/material.dart';

/// Model for student submission
class StudentSubmission {
  final String id;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final String studentAvatar;
  final String assignmentId;
  final String assignmentTitle;
  final String assignmentType;
  final String courseId;
  final String courseName;
  final DateTime submittedAt;
  final DateTime? gradedAt;
  final int? grade;
  final int maxGrade;
  final String? feedback;
  final String status;
  final List<String> attachments;
  final String? textContent;
  final int lateDays;

  const StudentSubmission({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    this.studentAvatar = '',
    required this.assignmentId,
    required this.assignmentTitle,
    this.assignmentType = 'assignment',
    required this.courseId,
    required this.courseName,
    required this.submittedAt,
    this.gradedAt,
    this.grade,
    this.maxGrade = 100,
    this.feedback,
    this.status = 'pending',
    this.attachments = const [],
    this.textContent,
    this.lateDays = 0,
  });

  String get letterGrade {
    if (grade == null) return '-';
    final percentage = (grade! / maxGrade) * 100;
    if (percentage >= 90) return 'A';
    if (percentage >= 80) return 'B';
    if (percentage >= 70) return 'C';
    if (percentage >= 60) return 'D';
    return 'F';
  }

  Color get gradeColor {
    if (grade == null) return const Color(0xFF64748B);
    final percentage = (grade! / maxGrade) * 100;
    if (percentage >= 90) return const Color(0xFF10B981);
    if (percentage >= 80) return const Color(0xFF3B82F6);
    if (percentage >= 70) return const Color(0xFFF59E0B);
    if (percentage >= 60) return const Color(0xFFF97316);
    return const Color(0xFFEF4444);
  }

  StudentSubmission copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? studentEmail,
    String? studentAvatar,
    String? assignmentId,
    String? assignmentTitle,
    String? assignmentType,
    String? courseId,
    String? courseName,
    DateTime? submittedAt,
    DateTime? gradedAt,
    int? grade,
    int? maxGrade,
    String? feedback,
    String? status,
    List<String>? attachments,
    String? textContent,
    int? lateDays,
  }) {
    return StudentSubmission(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentEmail: studentEmail ?? this.studentEmail,
      studentAvatar: studentAvatar ?? this.studentAvatar,
      assignmentId: assignmentId ?? this.assignmentId,
      assignmentTitle: assignmentTitle ?? this.assignmentTitle,
      assignmentType: assignmentType ?? this.assignmentType,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      submittedAt: submittedAt ?? this.submittedAt,
      gradedAt: gradedAt ?? this.gradedAt,
      grade: grade ?? this.grade,
      maxGrade: maxGrade ?? this.maxGrade,
      feedback: feedback ?? this.feedback,
      status: status ?? this.status,
      attachments: attachments ?? this.attachments,
      textContent: textContent ?? this.textContent,
      lateDays: lateDays ?? this.lateDays,
    );
  }
}

/// Model for grading statistics
class GradingStatistics {
  final int totalSubmissions;
  final int pendingSubmissions;
  final int gradedSubmissions;
  final int lateSubmissions;
  final double averageGrade;
  final double completionRate;

  const GradingStatistics({
    this.totalSubmissions = 0,
    this.pendingSubmissions = 0,
    this.gradedSubmissions = 0,
    this.lateSubmissions = 0,
    this.averageGrade = 0,
    this.completionRate = 0,
  });

  double get gradingProgress =>
      totalSubmissions > 0 ? gradedSubmissions / totalSubmissions : 0;
}

/// Assignment filter model
class GradingFilter {
  final String? courseId;
  final String? assignmentId;
  final String? status;
  final String searchQuery;
  final GradingSortBy sortBy;
  final bool sortAscending;

  const GradingFilter({
    this.courseId,
    this.assignmentId,
    this.status,
    this.searchQuery = '',
    this.sortBy = GradingSortBy.submittedAt,
    this.sortAscending = false,
  });

  GradingFilter copyWith({
    String? courseId,
    String? assignmentId,
    String? status,
    String? searchQuery,
    GradingSortBy? sortBy,
    bool? sortAscending,
    bool clearCourse = false,
    bool clearAssignment = false,
    bool clearStatus = false,
  }) {
    return GradingFilter(
      courseId: clearCourse ? null : (courseId ?? this.courseId),
      assignmentId: clearAssignment ? null : (assignmentId ?? this.assignmentId),
      status: clearStatus ? null : (status ?? this.status),
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }
}

enum GradingSortBy { studentName, submittedAt, score, status }
