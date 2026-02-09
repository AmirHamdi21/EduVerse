import 'package:flutter/material.dart';

/// Search result category for instructors
enum InstructorSearchCategory {
  all,
  students,
  courses,
  assignments,
  grades,
  materials,
  announcements,
}

extension InstructorSearchCategoryExtension on InstructorSearchCategory {
  String get displayName {
    switch (this) {
      case InstructorSearchCategory.all:
        return 'All';
      case InstructorSearchCategory.students:
        return 'Students';
      case InstructorSearchCategory.courses:
        return 'Courses';
      case InstructorSearchCategory.assignments:
        return 'Assignments';
      case InstructorSearchCategory.grades:
        return 'Grades';
      case InstructorSearchCategory.materials:
        return 'Materials';
      case InstructorSearchCategory.announcements:
        return 'Announcements';
    }
  }

  IconData get icon {
    switch (this) {
      case InstructorSearchCategory.all:
        return Icons.search_rounded;
      case InstructorSearchCategory.students:
        return Icons.people_outlined;
      case InstructorSearchCategory.courses:
        return Icons.school_outlined;
      case InstructorSearchCategory.assignments:
        return Icons.assignment_outlined;
      case InstructorSearchCategory.grades:
        return Icons.grading_outlined;
      case InstructorSearchCategory.materials:
        return Icons.folder_outlined;
      case InstructorSearchCategory.announcements:
        return Icons.campaign_outlined;
    }
  }

  Color get color {
    switch (this) {
      case InstructorSearchCategory.all:
        return const Color(0xFF64748B);
      case InstructorSearchCategory.students:
        return const Color(0xFF155CFB);
      case InstructorSearchCategory.courses:
        return const Color(0xFF10B981);
      case InstructorSearchCategory.assignments:
        return const Color(0xFFF59E0B);
      case InstructorSearchCategory.grades:
        return const Color(0xFF8B5CF6);
      case InstructorSearchCategory.materials:
        return const Color(0xFF06B6D4);
      case InstructorSearchCategory.announcements:
        return const Color(0xFFEC4899);
    }
  }
}

/// Search result item model
class InstructorSearchResult {
  final String id;
  final String title;
  final String subtitle;
  final InstructorSearchCategory category;
  final String? imageUrl;
  final String? route;
  final Map<String, dynamic>? extra;

  const InstructorSearchResult({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    this.imageUrl,
    this.route,
    this.extra,
  });
}

/// Search filter model
class InstructorSearchFilter {
  final InstructorSearchCategory category;
  final String? courseId;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const InstructorSearchFilter({
    this.category = InstructorSearchCategory.all,
    this.courseId,
    this.dateFrom,
    this.dateTo,
  });

  bool get hasActiveFilters =>
      category != InstructorSearchCategory.all ||
      courseId != null ||
      dateFrom != null ||
      dateTo != null;

  InstructorSearchFilter copyWith({
    InstructorSearchCategory? category,
    String? courseId,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    return InstructorSearchFilter(
      category: category ?? this.category,
      courseId: courseId ?? this.courseId,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
    );
  }
}

/// Quick action model for search screen
class InstructorSearchQuickAction {
  final String title;
  final IconData icon;
  final Color color;
  final String route;

  const InstructorSearchQuickAction({
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
  });
}
