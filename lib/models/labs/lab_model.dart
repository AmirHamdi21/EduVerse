import 'package:flutter/material.dart';

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
  });

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
}
