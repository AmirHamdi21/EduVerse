import 'package:flutter/material.dart';

class CourseModel {
  final int? courseId;
  final String title;
  final String instructor;
  final double progress;
  final String nextEvent;
  final String eventDate;
  final Color iconBackgroundColor;
  final IconData courseIcon;
  final String primaryButtonLabel;
  final VoidCallback? onPrimaryButtonPressed;
  final VoidCallback? onSecondaryButtonPressed;
  final String? instructorImage;
  final List<CourseModule>? modules;

  CourseModel({
    this.courseId,
    required this.title,
    required this.instructor,
    required this.progress,
    required this.nextEvent,
    required this.eventDate,
    required this.iconBackgroundColor,
    required this.courseIcon,
    this.primaryButtonLabel = 'Continue',
    this.onPrimaryButtonPressed,
    this.onSecondaryButtonPressed,
    this.instructorImage,
    this.modules,
  });

  int get eventDateAsNumber {
    final monthMap = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12,
    };
    final parts = eventDate.split(' ');
    if (parts.length == 2) {
      final month = monthMap[parts[0]] ?? 0;
      final day = int.tryParse(parts[1]) ?? 0;
      return month * 100 + day;
    }
    return 0;
  }
}

class CourseModule {
  final String title;
  final String description;
  final ModuleStatus status;
  final List<ModuleContent> contents;
  final bool isExpanded;

  CourseModule({
    required this.title,
    required this.description,
    required this.status,
    required this.contents,
    this.isExpanded = false,
  });
}

enum ModuleStatus { completed, inProgress, notStarted }

class ModuleContent {
  final String type; // video, pdf, slides
  final String? icon;

  ModuleContent({required this.type, this.icon});
}

class Lab {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final LabStatus status;
  final String? gradePercentage;

  Lab({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    this.gradePercentage,
  });
}

enum LabStatus { graded, submitted, pending, notStarted }

class Assignment {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final AssignmentStatus status;
  final int progressPercentage;
  final int? completedQuestions;
  final int? totalQuestions;
  final bool hasSubmission;
  final bool isGraded;

  Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    required this.progressPercentage,
    this.completedQuestions,
    this.totalQuestions,
    this.hasSubmission = false,
    this.isGraded = false,
  });

  bool get isSubmittedAwaitingGrading => hasSubmission && !isGraded;
}

enum AssignmentStatus { completed, inProgress, notStarted }
