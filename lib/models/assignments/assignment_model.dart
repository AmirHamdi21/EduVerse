import 'package:flutter/material.dart';

enum AssignmentStatus { pending, submitted, graded, late, overdue }

enum AssignmentType { document, code, presentation, quiz, project, other }

enum AssignmentPriority { low, medium, high, urgent }

extension AssignmentStatusExtension on AssignmentStatus {
  String get label {
    switch (this) {
      case AssignmentStatus.pending:
        return 'Pending';
      case AssignmentStatus.submitted:
        return 'Submitted';
      case AssignmentStatus.graded:
        return 'Graded';
      case AssignmentStatus.late:
        return 'Late Submission';
      case AssignmentStatus.overdue:
        return 'Overdue';
    }
  }

  Color get color {
    switch (this) {
      case AssignmentStatus.pending:
        return const Color(0xFFF59E0B);
      case AssignmentStatus.submitted:
        return const Color(0xFF3B82F6);
      case AssignmentStatus.graded:
        return const Color(0xFF10B981);
      case AssignmentStatus.late:
        return const Color(0xFFEF4444);
      case AssignmentStatus.overdue:
        return const Color(0xFFDC2626);
    }
  }

  IconData get icon {
    switch (this) {
      case AssignmentStatus.pending:
        return Icons.hourglass_empty_rounded;
      case AssignmentStatus.submitted:
        return Icons.cloud_upload_rounded;
      case AssignmentStatus.graded:
        return Icons.grading_rounded;
      case AssignmentStatus.late:
        return Icons.warning_amber_rounded;
      case AssignmentStatus.overdue:
        return Icons.error_outline_rounded;
    }
  }
}

extension AssignmentTypeExtension on AssignmentType {
  String get label {
    switch (this) {
      case AssignmentType.document:
        return 'Document';
      case AssignmentType.code:
        return 'Code';
      case AssignmentType.presentation:
        return 'Presentation';
      case AssignmentType.quiz:
        return 'Quiz';
      case AssignmentType.project:
        return 'Project';
      case AssignmentType.other:
        return 'Other';
    }
  }

  Color get color {
    switch (this) {
      case AssignmentType.document:
        return const Color(0xFF3B82F6);
      case AssignmentType.code:
        return const Color(0xFF8B5CF6);
      case AssignmentType.presentation:
        return const Color(0xFFF59E0B);
      case AssignmentType.quiz:
        return const Color(0xFFEC4899);
      case AssignmentType.project:
        return const Color(0xFF10B981);
      case AssignmentType.other:
        return const Color(0xFF6B7280);
    }
  }

  IconData get icon {
    switch (this) {
      case AssignmentType.document:
        return Icons.description_rounded;
      case AssignmentType.code:
        return Icons.code_rounded;
      case AssignmentType.presentation:
        return Icons.slideshow_rounded;
      case AssignmentType.quiz:
        return Icons.quiz_rounded;
      case AssignmentType.project:
        return Icons.folder_special_rounded;
      case AssignmentType.other:
        return Icons.insert_drive_file_rounded;
    }
  }
}

extension AssignmentPriorityExtension on AssignmentPriority {
  String get label {
    switch (this) {
      case AssignmentPriority.low:
        return 'Low';
      case AssignmentPriority.medium:
        return 'Medium';
      case AssignmentPriority.high:
        return 'High';
      case AssignmentPriority.urgent:
        return 'Urgent';
    }
  }

  Color get color {
    switch (this) {
      case AssignmentPriority.low:
        return const Color(0xFF10B981);
      case AssignmentPriority.medium:
        return const Color(0xFFF59E0B);
      case AssignmentPriority.high:
        return const Color(0xFFEF4444);
      case AssignmentPriority.urgent:
        return const Color(0xFFDC2626);
    }
  }

  IconData get icon {
    switch (this) {
      case AssignmentPriority.low:
        return Icons.arrow_downward_rounded;
      case AssignmentPriority.medium:
        return Icons.remove_rounded;
      case AssignmentPriority.high:
        return Icons.arrow_upward_rounded;
      case AssignmentPriority.urgent:
        return Icons.priority_high_rounded;
    }
  }
}

class AssignmentAttachment {
  final String id;
  final String name;
  final String url;
  final String? fileType;
  final int? fileSize;

  const AssignmentAttachment({
    required this.id,
    required this.name,
    required this.url,
    this.fileType,
    this.fileSize,
  });

  String get formattedSize {
    if (fileSize == null) return '';
    if (fileSize! < 1024) return '${fileSize}B';
    if (fileSize! < 1024 * 1024) return '${(fileSize! / 1024).toStringAsFixed(1)}KB';
    return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

class SubmissionModel {
  final String id;
  final DateTime submittedAt;
  final List<AssignmentAttachment> attachments;
  final String? comments;
  final double? grade;
  final double? maxGrade;
  final String? feedback;
  final DateTime? gradedAt;

  const SubmissionModel({
    required this.id,
    required this.submittedAt,
    required this.attachments,
    this.comments,
    this.grade,
    this.maxGrade,
    this.feedback,
    this.gradedAt,
  });

  double? get gradePercentage {
    if (grade == null || maxGrade == null || maxGrade == 0) return null;
    return (grade! / maxGrade!) * 100;
  }
}

class AssignmentModel {
  final String id;
  final String title;
  final String? description;
  final String courseName;
  final String courseCode;
  final String instructorName;
  final AssignmentType type;
  final AssignmentStatus status;
  final AssignmentPriority priority;
  final DateTime dueDate;
  final DateTime? assignedDate;
  final double maxGrade;
  final List<AssignmentAttachment>? attachments;
  final List<String>? instructions;
  final SubmissionModel? submission;
  final bool isBookmarked;
  final DateTime createdAt;

  const AssignmentModel({
    required this.id,
    required this.title,
    this.description,
    required this.courseName,
    required this.courseCode,
    required this.instructorName,
    required this.type,
    required this.status,
    required this.priority,
    required this.dueDate,
    this.assignedDate,
    required this.maxGrade,
    this.attachments,
    this.instructions,
    this.submission,
    this.isBookmarked = false,
    required this.createdAt,
  });

  AssignmentModel copyWith({
    String? id,
    String? title,
    String? description,
    String? courseName,
    String? courseCode,
    String? instructorName,
    AssignmentType? type,
    AssignmentStatus? status,
    AssignmentPriority? priority,
    DateTime? dueDate,
    DateTime? assignedDate,
    double? maxGrade,
    List<AssignmentAttachment>? attachments,
    List<String>? instructions,
    SubmissionModel? submission,
    bool? isBookmarked,
    DateTime? createdAt,
  }) {
    return AssignmentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      courseName: courseName ?? this.courseName,
      courseCode: courseCode ?? this.courseCode,
      instructorName: instructorName ?? this.instructorName,
      type: type ?? this.type,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      assignedDate: assignedDate ?? this.assignedDate,
      maxGrade: maxGrade ?? this.maxGrade,
      attachments: attachments ?? this.attachments,
      instructions: instructions ?? this.instructions,
      submission: submission ?? this.submission,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isOverdue =>
      dueDate.isBefore(DateTime.now()) &&
      status != AssignmentStatus.submitted &&
      status != AssignmentStatus.graded &&
      status != AssignmentStatus.late;

  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;

  int get hoursUntilDue => dueDate.difference(DateTime.now()).inHours;

  bool get isDueToday {
    final now = DateTime.now();
    return dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day;
  }

  bool get isDueTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return dueDate.year == tomorrow.year &&
        dueDate.month == tomorrow.month &&
        dueDate.day == tomorrow.day;
  }

  double? get grade => submission?.grade;
  double? get gradePercentage => submission?.gradePercentage;
  String? get feedback => submission?.feedback;
}
