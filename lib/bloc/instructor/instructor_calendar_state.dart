import 'package:equatable/equatable.dart';

import '../../models/schedule/schedule_models.dart';
import '../schedule/schedule_item_builder.dart';

// Instructor-specific event types
enum InstructorEventType {
  lecture,
  lab,
  officeHours,
  meeting,
  deadline,
  grading,
  exam,
}

// Event model for instructor calendar
class InstructorCalendarEvent {
  final String id;
  final String title;
  final InstructorEventType type;
  final DateTime date;
  final String? time;
  final String? endTime;
  final String? course;
  final String? location;
  final String? description;
  final bool isCompleted;
  final bool hasReminder;
  final int? studentCount;
  final ScheduleItemKind? kind;
  final int? courseId;
  final int? eventId;
  final int? examId;
  final int? campusEventId;
  final bool? isMandatory;
  final bool? registrationRequired;
  final UnifiedScheduleItem? sourceItem;

  const InstructorCalendarEvent({
    required this.id,
    required this.title,
    required this.type,
    required this.date,
    this.time,
    this.endTime,
    this.course,
    this.location,
    this.description,
    this.isCompleted = false,
    this.hasReminder = true,
    this.studentCount,
    this.kind,
    this.courseId,
    this.eventId,
    this.examId,
    this.campusEventId,
    this.isMandatory,
    this.registrationRequired,
    this.sourceItem,
  });

  InstructorCalendarEvent copyWith({
    String? id,
    String? title,
    InstructorEventType? type,
    DateTime? date,
    String? time,
    String? endTime,
    String? course,
    String? location,
    String? description,
    bool? isCompleted,
    bool? hasReminder,
    int? studentCount,
    ScheduleItemKind? kind,
    int? courseId,
    int? eventId,
    int? examId,
    int? campusEventId,
    bool? isMandatory,
    bool? registrationRequired,
    UnifiedScheduleItem? sourceItem,
  }) {
    return InstructorCalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      date: date ?? this.date,
      time: time ?? this.time,
      endTime: endTime ?? this.endTime,
      course: course ?? this.course,
      location: location ?? this.location,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      hasReminder: hasReminder ?? this.hasReminder,
      studentCount: studentCount ?? this.studentCount,
      kind: kind ?? this.kind,
      courseId: courseId ?? this.courseId,
      eventId: eventId ?? this.eventId,
      examId: examId ?? this.examId,
      campusEventId: campusEventId ?? this.campusEventId,
      isMandatory: isMandatory ?? this.isMandatory,
      registrationRequired: registrationRequired ?? this.registrationRequired,
      sourceItem: sourceItem ?? this.sourceItem,
    );
  }
}

// Reminder model
class InstructorReminder {
  final String id;
  final String title;
  final String message;
  final InstructorReminderType type;
  final DateTime createdAt;
  final bool isDismissed;

  const InstructorReminder({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isDismissed = false,
  });
}

enum InstructorReminderType { grading, deadline, meeting, suggestion }

enum CalendarViewType { month, week, day }

// Filter for instructor events
class InstructorEventFilter {
  final bool lectures;
  final bool labs;
  final bool officeHours;
  final bool meetings;
  final bool deadlines;
  final bool grading;
  final bool exams;

  const InstructorEventFilter({
    this.lectures = true,
    this.labs = true,
    this.officeHours = true,
    this.meetings = true,
    this.deadlines = true,
    this.grading = true,
    this.exams = true,
  });

  InstructorEventFilter copyWith({
    bool? lectures,
    bool? labs,
    bool? officeHours,
    bool? meetings,
    bool? deadlines,
    bool? grading,
    bool? exams,
  }) {
    return InstructorEventFilter(
      lectures: lectures ?? this.lectures,
      labs: labs ?? this.labs,
      officeHours: officeHours ?? this.officeHours,
      meetings: meetings ?? this.meetings,
      deadlines: deadlines ?? this.deadlines,
      grading: grading ?? this.grading,
      exams: exams ?? this.exams,
    );
  }

  bool isTypeEnabled(InstructorEventType type) {
    switch (type) {
      case InstructorEventType.lecture:
        return lectures;
      case InstructorEventType.lab:
        return labs;
      case InstructorEventType.officeHours:
        return officeHours;
      case InstructorEventType.meeting:
        return meetings;
      case InstructorEventType.deadline:
        return deadlines;
      case InstructorEventType.grading:
        return grading;
      case InstructorEventType.exam:
        return exams;
    }
  }
}

// State class
class InstructorCalendarState extends Equatable {
  final bool isLoading;
  final String? error;
  final String? successMessage;
  final List<InstructorCalendarEvent> events;
  final List<UnifiedScheduleItem> unifiedItems;
  final List<DailyScheduleResponse> rawDays;
  final List<InstructorReminder> reminders;
  final DateTime selectedDate;
  final DateTime focusedMonth;
  final CalendarViewType viewType;
  final InstructorEventFilter filter;
  final bool isFilterVisible;
  final bool isAddEventVisible;
  final ScheduleItemKind? kindFilter;
  final String? courseFilter;
  final String campusSource;

  InstructorCalendarState({
    this.isLoading = false,
    this.error,
    this.successMessage,
    this.events = const [],
    this.unifiedItems = const [],
    this.rawDays = const [],
    this.reminders = const [],
    DateTime? selectedDate,
    DateTime? focusedMonth,
    this.viewType = CalendarViewType.month,
    this.filter = const InstructorEventFilter(),
    this.isFilterVisible = false,
    this.isAddEventVisible = false,
    this.kindFilter,
    this.courseFilter,
    this.campusSource = 'all',
  }) : selectedDate = selectedDate ?? DateTime.now(),
       focusedMonth = focusedMonth ?? DateTime.now();

  List<UnifiedScheduleItem> get filteredItems {
    return ScheduleItemBuilder.filter(
      unifiedItems,
      kindFilter: kindFilter,
      courseFilter: courseFilter,
    );
  }

  // Get filtered events
  List<InstructorCalendarEvent> get filteredEvents {
    final source = events.isNotEmpty ? events : _toLegacyEvents(filteredItems);
    return source.where((event) => filter.isTypeEnabled(event.type)).toList();
  }

  // Get events for selected date
  List<InstructorCalendarEvent> get selectedDateEvents {
    return filteredEvents.where((event) {
      return event.date.year == selectedDate.year &&
          event.date.month == selectedDate.month &&
          event.date.day == selectedDate.day;
    }).toList();
  }

  // Get upcoming events (next 7 days)
  List<InstructorCalendarEvent> get upcomingEvents {
    final upcomingItems = ScheduleItemBuilder.upcoming(filteredItems);
    return _toLegacyEvents(upcomingItems)
        .where((event) => filter.isTypeEnabled(event.type))
        .toList(growable: false)
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<UnifiedScheduleItem> get upcomingItems {
    return ScheduleItemBuilder.upcoming(filteredItems);
  }

  // Check if date has events
  bool hasEventsOnDate(DateTime date) {
    return filteredEvents.any(
      (event) =>
          event.date.year == date.year &&
          event.date.month == date.month &&
          event.date.day == date.day,
    );
  }

  // Get events for a specific date
  List<InstructorCalendarEvent> getEventsForDate(DateTime date) {
    return filteredEvents
        .where(
          (event) =>
              event.date.year == date.year &&
              event.date.month == date.month &&
              event.date.day == date.day,
        )
        .toList();
  }

  List<UnifiedScheduleItem> getUnifiedEventsForDate(DateTime date) {
    final isoDate = toISODate(date);
    return filteredItems
        .where((event) => event.date == isoDate)
        .toList(growable: false);
  }

  InstructorCalendarState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
    List<InstructorCalendarEvent>? events,
    List<UnifiedScheduleItem>? unifiedItems,
    List<DailyScheduleResponse>? rawDays,
    List<InstructorReminder>? reminders,
    DateTime? selectedDate,
    DateTime? focusedMonth,
    CalendarViewType? viewType,
    InstructorEventFilter? filter,
    bool? isFilterVisible,
    bool? isAddEventVisible,
    ScheduleItemKind? kindFilter,
    String? courseFilter,
    String? campusSource,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearKindFilter = false,
    bool clearCourseFilter = false,
  }) {
    return InstructorCalendarState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
      events: events ?? this.events,
      unifiedItems: unifiedItems ?? this.unifiedItems,
      rawDays: rawDays ?? this.rawDays,
      reminders: reminders ?? this.reminders,
      selectedDate: selectedDate ?? this.selectedDate,
      focusedMonth: focusedMonth ?? this.focusedMonth,
      viewType: viewType ?? this.viewType,
      filter: filter ?? this.filter,
      isFilterVisible: isFilterVisible ?? this.isFilterVisible,
      isAddEventVisible: isAddEventVisible ?? this.isAddEventVisible,
      kindFilter: clearKindFilter ? null : (kindFilter ?? this.kindFilter),
      courseFilter: clearCourseFilter
          ? null
          : (courseFilter ?? this.courseFilter),
      campusSource: campusSource ?? this.campusSource,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    error,
    successMessage,
    events,
    unifiedItems,
    rawDays,
    reminders,
    selectedDate,
    focusedMonth,
    viewType,
    filter,
    isFilterVisible,
    isAddEventVisible,
    kindFilter,
    courseFilter,
    campusSource,
  ];

  List<InstructorCalendarEvent> _toLegacyEvents(
    List<UnifiedScheduleItem> items,
  ) {
    return items
        .map((item) {
          final parsedDate = DateTime.tryParse(item.date);
          final date = parsedDate == null
              ? DateTime.now()
              : DateTime(parsedDate.year, parsedDate.month, parsedDate.day);

          return InstructorCalendarEvent(
            id: item.id,
            title: item.title,
            type: _mapKindToType(item.kind),
            date: date,
            time: item.startTime,
            endTime: item.endTime,
            course: item.courseCode,
            location: item.location,
            description:
                item.eventItem?.description ??
                item.campusEventItem?.description ??
                item.examItem?.title,
            studentCount: item.officeHoursSlot?.currentAppointments,
            kind: item.kind,
            courseId: item.courseId,
            eventId: item.eventItem?.eventId,
            examId: item.examItem?.examId,
            campusEventId: item.campusEventItem?.eventId,
            isMandatory: item.isMandatory,
            registrationRequired: item.registrationRequired,
            sourceItem: item,
          );
        })
        .toList(growable: false);
  }

  InstructorEventType _mapKindToType(ScheduleItemKind kind) {
    switch (kind) {
      case ScheduleItemKind.classSession:
        return InstructorEventType.lecture;
      case ScheduleItemKind.exam:
        return InstructorEventType.exam;
      case ScheduleItemKind.event:
        return InstructorEventType.meeting;
      case ScheduleItemKind.campusEvent:
        return InstructorEventType.meeting;
      case ScheduleItemKind.officeHours:
        return InstructorEventType.officeHours;
      case ScheduleItemKind.unknown:
        return InstructorEventType.meeting;
    }
  }
}
