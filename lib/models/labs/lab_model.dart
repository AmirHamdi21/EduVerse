import 'package:flutter/material.dart';

import '../core/drive_file_model.dart';
import '../core/enums/lab_enums.dart' as api;
import '../core/shared_models.dart';

enum LabStatus { upcoming, inProgress, completed, missed }

enum LabType { virtual, physical, hybrid }

extension LabStatusExtension on LabStatus {
  String get label {
    switch (this) {
      case LabStatus.upcoming:
        return 'Upcoming';
      case LabStatus.inProgress:
        return 'In Progress';
      case LabStatus.completed:
        return 'Completed';
      case LabStatus.missed:
        return 'Missed';
    }
  }

  Color get color {
    switch (this) {
      case LabStatus.upcoming:
        return const Color(0xFF3B82F6);
      case LabStatus.inProgress:
        return const Color(0xFFF59E0B);
      case LabStatus.completed:
        return const Color(0xFF10B981);
      case LabStatus.missed:
        return const Color(0xFFEF4444);
    }
  }

  IconData get icon {
    switch (this) {
      case LabStatus.upcoming:
        return Icons.schedule_rounded;
      case LabStatus.inProgress:
        return Icons.play_circle_rounded;
      case LabStatus.completed:
        return Icons.check_circle_rounded;
      case LabStatus.missed:
        return Icons.cancel_rounded;
    }
  }
}

extension LabTypeExtension on LabType {
  String get label {
    switch (this) {
      case LabType.virtual:
        return 'Virtual';
      case LabType.physical:
        return 'Physical';
      case LabType.hybrid:
        return 'Hybrid';
    }
  }

  Color get color {
    switch (this) {
      case LabType.virtual:
        return const Color(0xFF8B5CF6);
      case LabType.physical:
        return const Color(0xFF10B981);
      case LabType.hybrid:
        return const Color(0xFF3B82F6);
    }
  }

  IconData get icon {
    switch (this) {
      case LabType.virtual:
        return Icons.computer_rounded;
      case LabType.physical:
        return Icons.science_rounded;
      case LabType.hybrid:
        return Icons.sync_alt_rounded;
    }
  }
}

class LabModel {
  // Legacy UI-facing fields
  final String id;
  final String title;
  final String? description;
  final String courseName;
  final String courseCode;
  final String instructorName;
  final LabType type;
  final LabStatus status;
  final DateTime scheduledDate;
  final Duration duration;
  final String? location;
  final String? virtualLink;
  final List<String>? materials;
  final List<String>? objectives;
  final double? grade;
  final double? maxGrade;
  final String? reportUrl;
  final bool isBookmarked;
  final DateTime createdAt;

  // Backend contract fields
  final int labId;
  final int courseId;
  final int? labNumber;
  final DateTime? dueDate;
  final DateTime? availableFrom;
  final double weight;
  final api.LabStatus apiStatus;
  final int createdBy;
  final DateTime? updatedAt;
  final CourseInfo? course;
  final List<DriveFileModel>? instructionFiles;

  const LabModel({
    required this.id,
    required this.title,
    this.description,
    required this.courseName,
    required this.courseCode,
    required this.instructorName,
    required this.type,
    required this.status,
    required this.scheduledDate,
    required this.duration,
    this.location,
    this.virtualLink,
    this.materials,
    this.objectives,
    this.grade,
    this.maxGrade,
    this.reportUrl,
    this.isBookmarked = false,
    required this.createdAt,
    this.labId = 0,
    this.courseId = 0,
    this.labNumber,
    this.dueDate,
    this.availableFrom,
    this.weight = 0,
    this.apiStatus = api.LabStatus.unknown,
    this.createdBy = 0,
    this.updatedAt,
    this.course,
    this.instructionFiles,
  });

  factory LabModel.fromJson(Map<String, dynamic> json) {
    final parsedId = _parseInt(json['id']);
    final parsedStatus = api.LabStatus.fromString(_parseString(json['status']));
    final parsedInstructionFiles = _parseDriveFiles(json['instructionFiles']);
    final parsedDueDate = _parseDateTime(json['dueDate']);
    final parsedAvailableFrom = _parseDateTime(json['availableFrom']);

    return LabModel(
      id: parsedId.toString(),
      title: _parseString(json['title']),
      description: json['description']?.toString(),
      courseName: _parseString(
        (json['course'] as Map<String, dynamic>?)?['name'],
      ),
      courseCode: _parseString(
        (json['course'] as Map<String, dynamic>?)?['code'],
      ),
      instructorName: '',
      type: _mapLegacyType(json),
      status: _mapLegacyStatus(parsedStatus),
      scheduledDate: parsedAvailableFrom ?? parsedDueDate ?? DateTime.now(),
      duration: const Duration(hours: 2),
      location: json['location']?.toString(),
      virtualLink: json['virtualLink']?.toString(),
      materials: parsedInstructionFiles?.map((file) => file.fileName).toList(),
      objectives: null,
      grade: _parseNullableDouble(json['score']),
      maxGrade: _parseNullableDouble(json['maxScore']),
      reportUrl: null,
      isBookmarked: false,
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      labId: parsedId,
      courseId: _parseInt(json['courseId']),
      labNumber: _parseNullableInt(json['labNumber']),
      dueDate: parsedDueDate,
      availableFrom: parsedAvailableFrom,
      weight: _parseDouble(json['weight']),
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
      'id': labId,
      'courseId': courseId,
      'title': title,
      'description': description,
      'labNumber': labNumber,
      'dueDate': dueDate?.toIso8601String(),
      'availableFrom': availableFrom?.toIso8601String(),
      'maxScore': maxGrade,
      'weight': weight,
      'status': apiStatus.toJson(),
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'course': course?.toJson(),
      'instructionFiles': instructionFiles?.map((e) => e.toJson()).toList(),
      // Compatibility keys
      'courseName': courseName,
      'courseCode': courseCode,
      'scheduledDate': scheduledDate.toIso8601String(),
      'statusLegacy': status.name,
    };
  }

  LabModel copyWith({
    String? id,
    String? title,
    String? description,
    String? courseName,
    String? courseCode,
    String? instructorName,
    LabType? type,
    LabStatus? status,
    DateTime? scheduledDate,
    Duration? duration,
    String? location,
    String? virtualLink,
    List<String>? materials,
    List<String>? objectives,
    double? grade,
    double? maxGrade,
    String? reportUrl,
    bool? isBookmarked,
    DateTime? createdAt,
    int? labId,
    int? courseId,
    int? labNumber,
    DateTime? dueDate,
    DateTime? availableFrom,
    double? weight,
    api.LabStatus? apiStatus,
    int? createdBy,
    DateTime? updatedAt,
    CourseInfo? course,
    List<DriveFileModel>? instructionFiles,
  }) {
    return LabModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      courseName: courseName ?? this.courseName,
      courseCode: courseCode ?? this.courseCode,
      instructorName: instructorName ?? this.instructorName,
      type: type ?? this.type,
      status: status ?? this.status,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      duration: duration ?? this.duration,
      location: location ?? this.location,
      virtualLink: virtualLink ?? this.virtualLink,
      materials: materials ?? this.materials,
      objectives: objectives ?? this.objectives,
      grade: grade ?? this.grade,
      maxGrade: maxGrade ?? this.maxGrade,
      reportUrl: reportUrl ?? this.reportUrl,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      createdAt: createdAt ?? this.createdAt,
      labId: labId ?? this.labId,
      courseId: courseId ?? this.courseId,
      labNumber: labNumber ?? this.labNumber,
      dueDate: dueDate ?? this.dueDate,
      availableFrom: availableFrom ?? this.availableFrom,
      weight: weight ?? this.weight,
      apiStatus: apiStatus ?? this.apiStatus,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      course: course ?? this.course,
      instructionFiles: instructionFiles ?? this.instructionFiles,
    );
  }

  bool get isToday {
    final now = DateTime.now();
    return scheduledDate.year == now.year &&
        scheduledDate.month == now.month &&
        scheduledDate.day == now.day;
  }

  bool get isPast => scheduledDate.isBefore(DateTime.now());

  int get daysUntil => scheduledDate.difference(DateTime.now()).inDays;

  double? get gradePercentage {
    if (grade == null || maxGrade == null || maxGrade == 0) return null;
    return (grade! / maxGrade!) * 100;
  }

  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
    return '${minutes}m';
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    return int.tryParse(value.toString());
  }

  static double _parseDouble(dynamic value) {
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double? _parseNullableDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    return double.tryParse(value.toString());
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

  static List<DriveFileModel>? _parseDriveFiles(dynamic value) {
    if (value is! List) {
      return null;
    }

    return value
        .whereType<Map<String, dynamic>>()
        .map(DriveFileModel.fromJson)
        .toList();
  }

  static LabStatus _mapLegacyStatus(api.LabStatus status) {
    switch (status) {
      case api.LabStatus.draft:
        return LabStatus.upcoming;
      case api.LabStatus.published:
        return LabStatus.inProgress;
      case api.LabStatus.closed:
        return LabStatus.completed;
      case api.LabStatus.archived:
        return LabStatus.missed;
      case api.LabStatus.unknown:
        return LabStatus.upcoming;
    }
  }

  static LabType _mapLegacyType(Map<String, dynamic> json) {
    final link = json['virtualLink']?.toString();
    if (link != null && link.isNotEmpty) {
      return LabType.virtual;
    }
    return LabType.physical;
  }
}
