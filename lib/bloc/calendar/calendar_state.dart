import 'package:equatable/equatable.dart';

import '../../models/schedule/schedule_models.dart';
import '../schedule/schedule_item_builder.dart';

// Models
class CalendarEvent {
  final String id;
  final String title;
  final EventType type;
  final DateTime date;
  final String? time;
  final String? endTime;
  final String? course;
  final String? location;
  final String? description;
  final bool isCompleted;
  final bool hasReminder;
  final ScheduleItemKind? kind;
  final int? courseId;
  final int? eventId;
  final int? examId;
  final int? campusEventId;
  final bool? isMandatory;
  final bool? registrationRequired;
  final UnifiedScheduleItem? sourceItem;

  const CalendarEvent({
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
    this.kind,
    this.courseId,
    this.eventId,
    this.examId,
    this.campusEventId,
    this.isMandatory,
    this.registrationRequired,
    this.sourceItem,
  });

  CalendarEvent copyWith({
    String? id,
    String? title,
    EventType? type,
    DateTime? date,
    String? time,
    String? endTime,
    String? course,
    String? location,
    String? description,
    bool? isCompleted,
    bool? hasReminder,
    ScheduleItemKind? kind,
    int? courseId,
    int? eventId,
    int? examId,
    int? campusEventId,
    bool? isMandatory,
    bool? registrationRequired,
    UnifiedScheduleItem? sourceItem,
  }) {
    return CalendarEvent(
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

enum EventType { lecture, lab, assignment, exam, quiz, personalTask }

class AiReminder {
  final String id;
  final String title;
  final String message;
  final ReminderType type;
  final DateTime createdAt;
  final bool isDismissed;

  const AiReminder({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isDismissed = false,
  });
}

enum ReminderType { quiz, missedSession, deadline, suggestion }

enum CalendarViewType { month, week, day }

class EventFilter {
  final bool lectures;
  final bool labs;
  final bool assignments;
  final bool exams;
  final bool personalTasks;

  const EventFilter({
    this.lectures = true,
    this.labs = true,
    this.assignments = true,
    this.exams = true,
    this.personalTasks = true,
  });

  EventFilter copyWith({
    bool? lectures,
    bool? labs,
    bool? assignments,
    bool? exams,
    bool? personalTasks,
  }) {
    return EventFilter(
      lectures: lectures ?? this.lectures,
      labs: labs ?? this.labs,
      assignments: assignments ?? this.assignments,
      exams: exams ?? this.exams,
      personalTasks: personalTasks ?? this.personalTasks,
    );
  }

  bool isTypeEnabled(EventType type) {
    switch (type) {
      case EventType.lecture:
        return lectures;
      case EventType.lab:
        return labs;
      case EventType.assignment:
        return assignments;
      case EventType.exam:
      case EventType.quiz:
        return exams;
      case EventType.personalTask:
        return personalTasks;
    }
  }
}

// State
class CalendarState extends Equatable {
  final bool isLoading;
  final String? error;
  final String? successMessage;
  final List<CalendarEvent> events;
  final List<UnifiedScheduleItem> unifiedItems;
  final List<DailyScheduleResponse> rawDays;
  final List<AiReminder> aiReminders;
  final DateTime selectedDate;
  final DateTime focusedMonth;
  final CalendarViewType viewType;
  final EventFilter filter;
  final bool isFilterVisible;
  final bool isAddEventVisible;
  final ScheduleItemKind? kindFilter;
  final String? courseFilter;

  CalendarState({
    this.isLoading = false,
    this.error,
    this.successMessage,
    this.events = const [],
    this.unifiedItems = const [],
    this.rawDays = const [],
    this.aiReminders = const [],
    DateTime? selectedDate,
    DateTime? focusedMonth,
    this.viewType = CalendarViewType.month,
    this.filter = const EventFilter(),
    this.isFilterVisible = false,
    this.isAddEventVisible = false,
    this.kindFilter,
    this.courseFilter,
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
  List<CalendarEvent> get filteredEvents {
    final source = events.isNotEmpty ? events : _toLegacyEvents(filteredItems);
    return source.where((event) => filter.isTypeEnabled(event.type)).toList();
  }

  // Get events for selected date
  List<CalendarEvent> get selectedDateEvents {
    return filteredEvents.where((event) {
      return event.date.year == selectedDate.year &&
          event.date.month == selectedDate.month &&
          event.date.day == selectedDate.day;
    }).toList();
  }

  // Get upcoming events (next 7 days)
  List<CalendarEvent> get upcomingEvents {
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
  List<CalendarEvent> getEventsForDate(DateTime date) {
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

  CalendarState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
    List<CalendarEvent>? events,
    List<UnifiedScheduleItem>? unifiedItems,
    List<DailyScheduleResponse>? rawDays,
    List<AiReminder>? aiReminders,
    DateTime? selectedDate,
    DateTime? focusedMonth,
    CalendarViewType? viewType,
    EventFilter? filter,
    bool? isFilterVisible,
    bool? isAddEventVisible,
    ScheduleItemKind? kindFilter,
    String? courseFilter,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearKindFilter = false,
    bool clearCourseFilter = false,
  }) {
    return CalendarState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
      events: events ?? this.events,
      unifiedItems: unifiedItems ?? this.unifiedItems,
      rawDays: rawDays ?? this.rawDays,
      aiReminders: aiReminders ?? this.aiReminders,
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
    aiReminders,
    selectedDate,
    focusedMonth,
    viewType,
    filter,
    isFilterVisible,
    isAddEventVisible,
    kindFilter,
    courseFilter,
  ];

  List<CalendarEvent> _toLegacyEvents(List<UnifiedScheduleItem> items) {
    return items
        .map((item) {
          final parsedDate = DateTime.tryParse(item.date);
          final date = parsedDate == null
              ? DateTime.now()
              : DateTime(parsedDate.year, parsedDate.month, parsedDate.day);

          return CalendarEvent(
            id: item.id,
            title: item.title,
            type: _mapKindToEventType(item.kind),
            date: date,
            time: item.startTime,
            endTime: item.endTime,
            course: item.courseCode,
            location: item.location,
            description:
                item.eventItem?.description ??
                item.campusEventItem?.description ??
                item.examItem?.title,
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

  EventType _mapKindToEventType(ScheduleItemKind kind) {
    switch (kind) {
      case ScheduleItemKind.classSession:
        return EventType.lecture;
      case ScheduleItemKind.exam:
        return EventType.exam;
      case ScheduleItemKind.event:
        return EventType.personalTask;
      case ScheduleItemKind.campusEvent:
        return EventType.assignment;
      case ScheduleItemKind.officeHours:
        return EventType.lab;
      case ScheduleItemKind.unknown:
        return EventType.personalTask;
    }
  }
}
