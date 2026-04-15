import 'package:flutter/material.dart';

/// Model for instructor's course
class InstructorCourseModel {
  final String id;
  final String code;
  final String name;
  final String description;
  final int totalStudents;
  final int capacity;
  final int progress;
  final int colorValue;
  final IconData courseIcon;
  final int newItems;
  final int activeQuizzes;
  final int unreadMessages;
  final String semester;
  final DateTime? nextClass;
  final String? nextClassLocation;
  final bool isActive;
  final List<AnnouncementModel> announcements;
  final List<MaterialModel> materials;
  final List<AssignmentModel> assignments;

  const InstructorCourseModel({
    required this.id,
    required this.code,
    required this.name,
    this.description = '',
    required this.totalStudents,
    this.capacity = 0,
    this.progress = 0,
    this.colorValue = 0xFF6366F1,
    this.courseIcon = Icons.school,
    this.newItems = 0,
    this.activeQuizzes = 0,
    this.unreadMessages = 0,
    this.semester = '',
    this.nextClass,
    this.nextClassLocation,
    this.isActive = true,
    this.announcements = const [],
    this.materials = const [],
    this.assignments = const [],
  });

  InstructorCourseModel copyWith({
    String? id,
    String? code,
    String? name,
    String? description,
    int? totalStudents,
    int? capacity,
    int? progress,
    int? colorValue,
    IconData? courseIcon,
    int? newItems,
    int? activeQuizzes,
    int? unreadMessages,
    String? semester,
    DateTime? nextClass,
    String? nextClassLocation,
    bool? isActive,
    List<AnnouncementModel>? announcements,
    List<MaterialModel>? materials,
    List<AssignmentModel>? assignments,
  }) {
    return InstructorCourseModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      totalStudents: totalStudents ?? this.totalStudents,
      capacity: capacity ?? this.capacity,
      progress: progress ?? this.progress,
      colorValue: colorValue ?? this.colorValue,
      courseIcon: courseIcon ?? this.courseIcon,
      newItems: newItems ?? this.newItems,
      activeQuizzes: activeQuizzes ?? this.activeQuizzes,
      unreadMessages: unreadMessages ?? this.unreadMessages,
      semester: semester ?? this.semester,
      nextClass: nextClass ?? this.nextClass,
      nextClassLocation: nextClassLocation ?? this.nextClassLocation,
      isActive: isActive ?? this.isActive,
      announcements: announcements ?? this.announcements,
      materials: materials ?? this.materials,
      assignments: assignments ?? this.assignments,
    );
  }
}

/// Assignment model
class AssignmentModel {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final int totalPoints;
  final int submissionsCount;
  final int gradedCount;

  const AssignmentModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.dueDate,
    this.totalPoints = 100,
    this.submissionsCount = 0,
    this.gradedCount = 0,
  });

  bool get isGraded => submissionsCount > 0 && gradedCount >= submissionsCount;
  double get gradingProgress =>
      submissionsCount > 0 ? gradedCount / submissionsCount : 0;
}

/// Material model
class MaterialModel {
  final String id;
  final String title;
  final String type;
  final String fileSize;
  final String fileUrl;
  final bool isPublished;
  final DateTime? uploadedAt;

  const MaterialModel({
    required this.id,
    required this.title,
    required this.type,
    this.fileSize = '',
    this.fileUrl = '',
    this.isPublished = true,
    this.uploadedAt,
  });
}

/// Announcement model
class AnnouncementModel {
  final String id;
  final String title;
  final String content;
  final DateTime postedAt;
  final bool isPinned;

  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.postedAt,
    this.isPinned = false,
  });
}

enum DeadlineType { assignment, lab }

enum DeadlineStatus { upcoming, dueToday, overdue }

class DeadlineCardModel {
  final String id;
  final String title;
  final DeadlineType type;
  final DateTime? dueDate;
  final DeadlineStatus status;
  final int courseId;

  const DeadlineCardModel({
    required this.id,
    required this.title,
    required this.type,
    required this.dueDate,
    required this.status,
    required this.courseId,
  });
}

class EngagementMetricsModel {
  final int totalMaterialViews;
  final int totalMaterialDownloads;
  final double assignmentSubmissionRate;
  final int totalSubmissions;
  final int totalEnrolledStudents;

  const EngagementMetricsModel({
    required this.totalMaterialViews,
    required this.totalMaterialDownloads,
    required this.assignmentSubmissionRate,
    required this.totalSubmissions,
    required this.totalEnrolledStudents,
  });
}

class SectionStudentModel {
  final int userId;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String status;
  final double? grade;
  final double? finalScore;
  final DateTime? enrollmentDate;
  final int? sectionId;
  final String? courseCode;
  final String? courseName;

  const SectionStudentModel({
    required this.userId,
    this.firstName,
    this.lastName,
    this.email,
    required this.status,
    this.grade,
    this.finalScore,
    this.enrollmentDate,
    this.sectionId,
    this.courseCode,
    this.courseName,
  });

  /// Display name with fallback to "Student #userId" when names unavailable
  String get displayName {
    if (firstName != null || lastName != null) {
      return '$firstName $lastName'.trim();
    }
    return 'Student #$userId';
  }

  factory SectionStudentModel.fromJson(Map<String, dynamic> json) {
    // Extract nested course and section data
    final courseData = json['course'] as Map<String, dynamic>?;
    final sectionData = json['section'] as Map<String, dynamic>?;

    return SectionStudentModel(
      userId: int.tryParse(json['userId']?.toString() ?? '') ?? 0,
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
      email: json['email']?.toString(),
      status: json['status']?.toString() ?? 'enrolled',
      grade: double.tryParse(json['grade']?.toString() ?? ''),
      finalScore: double.tryParse(json['finalScore']?.toString() ?? ''),
      enrollmentDate: json['enrollmentDate'] != null
          ? DateTime.tryParse(json['enrollmentDate'].toString())
          : null,
      sectionId: int.tryParse(sectionData?['id']?.toString() ?? '')
          ?? int.tryParse(json['sectionId']?.toString() ?? ''),
      courseCode: courseData?['code']?.toString(),
      courseName: courseData?['name']?.toString(),
    );
  }
}
