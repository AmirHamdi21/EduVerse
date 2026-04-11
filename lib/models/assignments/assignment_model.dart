import 'dart:convert';

import 'package:flutter/material.dart';

import '../core/drive_file_model.dart';
import '../core/enums/assignment_enums.dart' as api;
import '../core/shared_models.dart';

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
    if (fileSize! < 1024 * 1024) {
      return '${(fileSize! / 1024).toStringAsFixed(1)}KB';
    }
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
  // Legacy UI-facing fields
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

  // Backend contract fields
  final int assignmentId;
  final int courseId;
  final String? instructionsText;
  final double weight;
  final DateTime? availableFrom;
  final bool lateSubmissionAllowed;
  final double latePenaltyPercent;
  final api.SubmissionType submissionType;
  final int maxFileSizeMb;
  final List<String>? allowedFileTypes;
  final api.AssignmentStatus apiStatus;
  final int createdBy;
  final DateTime? updatedAt;
  final CourseInfo? course;
  final List<DriveFileModel>? instructionFiles;

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
    this.assignmentId = 0,
    this.courseId = 0,
    this.instructionsText,
    this.weight = 0,
    this.availableFrom,
    this.lateSubmissionAllowed = false,
    this.latePenaltyPercent = 0,
    this.submissionType = api.SubmissionType.unknown,
    this.maxFileSizeMb = 0,
    this.allowedFileTypes,
    this.apiStatus = api.AssignmentStatus.unknown,
    this.createdBy = 0,
    this.updatedAt,
    this.course,
    this.instructionFiles,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    final parsedId = _parseInt(json['id']);
    final parsedSubmissionType = api.SubmissionType.fromString(
      _parseString(json['submissionType']),
    );
    final parsedStatus = api.AssignmentStatus.fromString(
      _parseString(json['status']),
    );
    final parsedInstructions = json['instructions']?.toString();
    final parsedInstructionFiles = _parseDriveFiles(json['instructionFiles']);

    return AssignmentModel(
      id: parsedId.toString(),
      assignmentId: parsedId,
      courseId: _parseInt(json['courseId']),
      title: _parseString(json['title']),
      description: json['description']?.toString(),
      courseName: _parseString(
        (json['course'] as Map<String, dynamic>?)?['name'],
      ),
      courseCode: _parseString(
        (json['course'] as Map<String, dynamic>?)?['code'],
      ),
      instructorName: _resolveInstructorName(json),
      type: _mapLegacyType(parsedSubmissionType),
      status: _mapLegacyStatus(parsedStatus),
      priority: AssignmentPriority.medium,
      dueDate: _parseDateTime(json['dueDate']) ?? DateTime.now(),
      assignedDate: _parseDateTime(json['availableFrom']),
      maxGrade: _parseDouble(json['maxScore']),
      attachments: parsedInstructionFiles
          ?.map(
            (file) => AssignmentAttachment(
              id: file.driveFileId.toString(),
              name: file.fileName,
              url: file.downloadUrl,
            ),
          )
          .toList(),
      instructions: parsedInstructions == null || parsedInstructions.isEmpty
          ? null
          : <String>[parsedInstructions],
      submission: null,
      isBookmarked: false,
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      instructionsText: parsedInstructions,
      weight: _parseDouble(json['weight']),
      availableFrom: _parseDateTime(json['availableFrom']),
      lateSubmissionAllowed: _parseBoolFromIntLike(
        json['lateSubmissionAllowed'],
      ),
      latePenaltyPercent: _parseDouble(json['latePenaltyPercent']),
      submissionType: parsedSubmissionType,
      maxFileSizeMb: _parseInt(json['maxFileSizeMb']),
      allowedFileTypes: _parseAllowedFileTypes(json['allowedFileTypes']),
      apiStatus: parsedStatus,
      createdBy: _parseInt(json['createdBy']),
      updatedAt: _parseDateTime(json['updatedAt']),
      course: json['course'] is Map<String, dynamic>
          ? CourseInfo.fromJson(json['course'] as Map<String, dynamic>)
          : null,
      instructionFiles: parsedInstructionFiles,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': assignmentId,
      'courseId': courseId,
      'title': title,
      'description': description,
      'instructions': instructionsText,
      'maxScore': maxGrade,
      'weight': weight,
      'dueDate': dueDate.toIso8601String(),
      'availableFrom': availableFrom?.toIso8601String(),
      'lateSubmissionAllowed': lateSubmissionAllowed ? 1 : 0,
      'latePenaltyPercent': latePenaltyPercent,
      'submissionType': submissionType.toJson(),
      'maxFileSizeMb': maxFileSizeMb,
      'allowedFileTypes': allowedFileTypes == null
          ? null
          : jsonEncode(allowedFileTypes),
      'status': apiStatus.toJson(),
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'course': course?.toJson(),
      'instructionFiles': instructionFiles?.map((e) => e.toJson()).toList(),
      // Compatibility keys
      'courseName': courseName,
      'courseCode': courseCode,
      'instructorName': instructorName,
      'maxGrade': maxGrade,
      'assignedDate': assignedDate?.toIso8601String(),
    };
  }

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
    int? assignmentId,
    int? courseId,
    String? instructionsText,
    double? weight,
    DateTime? availableFrom,
    bool? lateSubmissionAllowed,
    double? latePenaltyPercent,
    api.SubmissionType? submissionType,
    int? maxFileSizeMb,
    List<String>? allowedFileTypes,
    api.AssignmentStatus? apiStatus,
    int? createdBy,
    DateTime? updatedAt,
    CourseInfo? course,
    List<DriveFileModel>? instructionFiles,
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
      assignmentId: assignmentId ?? this.assignmentId,
      courseId: courseId ?? this.courseId,
      instructionsText: instructionsText ?? this.instructionsText,
      weight: weight ?? this.weight,
      availableFrom: availableFrom ?? this.availableFrom,
      lateSubmissionAllowed:
          lateSubmissionAllowed ?? this.lateSubmissionAllowed,
      latePenaltyPercent: latePenaltyPercent ?? this.latePenaltyPercent,
      submissionType: submissionType ?? this.submissionType,
      maxFileSizeMb: maxFileSizeMb ?? this.maxFileSizeMb,
      allowedFileTypes: allowedFileTypes ?? this.allowedFileTypes,
      apiStatus: apiStatus ?? this.apiStatus,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      course: course ?? this.course,
      instructionFiles: instructionFiles ?? this.instructionFiles,
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
  bool get hasSubmission => submission != null;

  String get submissionFilterStatus {
    if (hasSubmission) {
      return 'submitted';
    }
    if (dueDate.isBefore(DateTime.now())) {
      return 'overdue';
    }
    return 'pending';
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _parseDouble(dynamic value) {
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    return DateTime.tryParse(value.toString());
  }

  static String _parseString(dynamic value) {
    return value?.toString() ?? '';
  }

  static bool _parseBoolFromIntLike(dynamic value) {
    if (value is bool) {
      return value;
    }
    return _parseInt(value) == 1;
  }

  static List<String>? _parseAllowedFileTypes(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is List) {
      return value.map((dynamic item) => item.toString()).toList();
    }

    if (value is String) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) {
          return decoded.map((dynamic item) => item.toString()).toList();
        }
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  static List<DriveFileModel>? _parseDriveFiles(dynamic value) {
    if (value is! List) {
      return null;
    }

    return value
        .whereType<Map<String, dynamic>>()
        .map(DriveFileModel.fromJson)
        .toList();
  }

  static AssignmentStatus _mapLegacyStatus(api.AssignmentStatus status) {
    switch (status) {
      case api.AssignmentStatus.draft:
      case api.AssignmentStatus.published:
        return AssignmentStatus.pending;
      case api.AssignmentStatus.closed:
        return AssignmentStatus.submitted;
      case api.AssignmentStatus.archived:
        return AssignmentStatus.graded;
      case api.AssignmentStatus.unknown:
        return AssignmentStatus.pending;
    }
  }

  static AssignmentType _mapLegacyType(api.SubmissionType type) {
    switch (type) {
      case api.SubmissionType.file:
        return AssignmentType.document;
      case api.SubmissionType.text:
        return AssignmentType.quiz;
      case api.SubmissionType.link:
        return AssignmentType.presentation;
      case api.SubmissionType.multiple:
        return AssignmentType.project;
      case api.SubmissionType.unknown:
        return AssignmentType.other;
    }
  }

  static String _resolveInstructorName(Map<String, dynamic> json) {
    final instructor = json['instructor'];
    if (instructor is Map<String, dynamic>) {
      final firstName = instructor['firstName']?.toString() ?? '';
      final lastName = instructor['lastName']?.toString() ?? '';
      final fullName = '$firstName $lastName'.trim();
      if (fullName.isNotEmpty) {
        return fullName;
      }
    }
    return '';
  }
}
