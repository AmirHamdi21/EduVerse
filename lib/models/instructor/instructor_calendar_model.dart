import 'package:flutter/material.dart';

/// Event type enum for instructor calendar
enum InstructorEventType {
  lecture,
  lab,
  officeHours,
  meeting,
  deadline,
  grading,
  exam,
  other,
}

/// Extension on InstructorEventType to get display properties
extension InstructorEventTypeExtension on InstructorEventType {
  String get displayName {
    switch (this) {
      case InstructorEventType.lecture:
        return 'Lecture';
      case InstructorEventType.lab:
        return 'Lab Session';
      case InstructorEventType.officeHours:
        return 'Office Hours';
      case InstructorEventType.meeting:
        return 'Meeting';
      case InstructorEventType.deadline:
        return 'Deadline';
      case InstructorEventType.grading:
        return 'Grading';
      case InstructorEventType.exam:
        return 'Exam';
      case InstructorEventType.other:
        return 'Other';
    }
  }

  Color get color {
    switch (this) {
      case InstructorEventType.lecture:
        return const Color(0xFF155CFB);
      case InstructorEventType.lab:
        return const Color(0xFF8B5CF6);
      case InstructorEventType.officeHours:
        return const Color(0xFF10B981);
      case InstructorEventType.meeting:
        return const Color(0xFF06B6D4);
      case InstructorEventType.deadline:
        return const Color(0xFFEF4444);
      case InstructorEventType.grading:
        return const Color(0xFFF59E0B);
      case InstructorEventType.exam:
        return const Color(0xFFEC4899);
      case InstructorEventType.other:
        return const Color(0xFF64748B);
    }
  }

  Color get lightColor {
    switch (this) {
      case InstructorEventType.lecture:
        return const Color(0xFFEEF5FF);
      case InstructorEventType.lab:
        return const Color(0xFFEDE9FE);
      case InstructorEventType.officeHours:
        return const Color(0xFFD1FAE5);
      case InstructorEventType.meeting:
        return const Color(0xFFCFFAFE);
      case InstructorEventType.deadline:
        return const Color(0xFFFEE2E2);
      case InstructorEventType.grading:
        return const Color(0xFFFEF3C7);
      case InstructorEventType.exam:
        return const Color(0xFFFCE7F3);
      case InstructorEventType.other:
        return const Color(0xFFF1F5F9);
    }
  }

  IconData get icon {
    switch (this) {
      case InstructorEventType.lecture:
        return Icons.school_outlined;
      case InstructorEventType.lab:
        return Icons.science_outlined;
      case InstructorEventType.officeHours:
        return Icons.access_time_outlined;
      case InstructorEventType.meeting:
        return Icons.groups_outlined;
      case InstructorEventType.deadline:
        return Icons.alarm_outlined;
      case InstructorEventType.grading:
        return Icons.grading_outlined;
      case InstructorEventType.exam:
        return Icons.quiz_outlined;
      case InstructorEventType.other:
        return Icons.event_outlined;
    }
  }
}

/// Instructor calendar event model
class InstructorCalendarEvent {
  final String id;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final InstructorEventType type;
  final String? courseId;
  final String? courseName;
  final String? location;
  final List<String> attendees;
  final bool isRecurring;
  final String? recurrenceRule;
  final bool reminder;
  final int? reminderMinutes;

  const InstructorCalendarEvent({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.type,
    this.courseId,
    this.courseName,
    this.location,
    this.attendees = const [],
    this.isRecurring = false,
    this.recurrenceRule,
    this.reminder = true,
    this.reminderMinutes = 15,
  });

  InstructorCalendarEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    InstructorEventType? type,
    String? courseId,
    String? courseName,
    String? location,
    List<String>? attendees,
    bool? isRecurring,
    String? recurrenceRule,
    bool? reminder,
    int? reminderMinutes,
  }) {
    return InstructorCalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      location: location ?? this.location,
      attendees: attendees ?? this.attendees,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      reminder: reminder ?? this.reminder,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
    );
  }

  bool get isAllDay {
    return startTime.hour == 0 &&
        startTime.minute == 0 &&
        endTime.hour == 23 &&
        endTime.minute == 59;
  }

  Duration get duration => endTime.difference(startTime);

  String get formattedTime {
    final start =
        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final end =
        '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    return '$start - $end';
  }
}

/// Filter model for instructor calendar
class InstructorCalendarFilter {
  final Set<InstructorEventType> types;
  final String? courseId;
  final bool showRecurring;
  final bool showPast;

  const InstructorCalendarFilter({
    this.types = const {},
    this.courseId,
    this.showRecurring = true,
    this.showPast = false,
  });

  bool get hasActiveFilters =>
      types.isNotEmpty || courseId != null || !showRecurring;

  InstructorCalendarFilter copyWith({
    Set<InstructorEventType>? types,
    String? courseId,
    bool? showRecurring,
    bool? showPast,
  }) {
    return InstructorCalendarFilter(
      types: types ?? this.types,
      courseId: courseId ?? this.courseId,
      showRecurring: showRecurring ?? this.showRecurring,
      showPast: showPast ?? this.showPast,
    );
  }

  InstructorCalendarFilter clearFilters() {
    return const InstructorCalendarFilter();
  }
}

/// Course option for calendar filtering
class CalendarCourseOption {
  final String id;
  final String name;
  final String code;

  const CalendarCourseOption({
    required this.id,
    required this.name,
    required this.code,
  });
}
