import 'package:equatable/equatable.dart';

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
  final List<AiReminder> aiReminders;
  final DateTime selectedDate;
  final DateTime focusedMonth;
  final CalendarViewType viewType;
  final EventFilter filter;
  final bool isFilterVisible;
  final bool isAddEventVisible;

  const CalendarState({
    this.isLoading = false,
    this.error,
    this.successMessage,
    this.events = const [],
    this.aiReminders = const [],
    DateTime? selectedDate,
    DateTime? focusedMonth,
    this.viewType = CalendarViewType.month,
    this.filter = const EventFilter(),
    this.isFilterVisible = false,
    this.isAddEventVisible = false,
  }) : selectedDate = selectedDate ?? const _DefaultDate(),
       focusedMonth = focusedMonth ?? const _DefaultDate();

  // Get filtered events
  List<CalendarEvent> get filteredEvents {
    return events.where((event) => filter.isTypeEnabled(event.type)).toList();
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
    final now = DateTime.now();
    final weekLater = now.add(const Duration(days: 7));
    return filteredEvents.where((event) {
      return event.date.isAfter(now.subtract(const Duration(days: 1))) &&
          event.date.isBefore(weekLater);
    }).toList()..sort((a, b) => a.date.compareTo(b.date));
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

  CalendarState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
    List<CalendarEvent>? events,
    List<AiReminder>? aiReminders,
    DateTime? selectedDate,
    DateTime? focusedMonth,
    CalendarViewType? viewType,
    EventFilter? filter,
    bool? isFilterVisible,
    bool? isAddEventVisible,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return CalendarState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
      events: events ?? this.events,
      aiReminders: aiReminders ?? this.aiReminders,
      selectedDate: selectedDate ?? this.selectedDate,
      focusedMonth: focusedMonth ?? this.focusedMonth,
      viewType: viewType ?? this.viewType,
      filter: filter ?? this.filter,
      isFilterVisible: isFilterVisible ?? this.isFilterVisible,
      isAddEventVisible: isAddEventVisible ?? this.isAddEventVisible,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    error,
    successMessage,
    events,
    aiReminders,
    selectedDate,
    focusedMonth,
    viewType,
    filter,
    isFilterVisible,
    isAddEventVisible,
  ];
}

// Helper class for default date
class _DefaultDate implements DateTime {
  const _DefaultDate();

  DateTime get _now => DateTime.now();

  @override
  int get year => _now.year;
  @override
  int get month => _now.month;
  @override
  int get day => _now.day;
  @override
  int get hour => _now.hour;
  @override
  int get minute => _now.minute;
  @override
  int get second => _now.second;
  @override
  int get millisecond => _now.millisecond;
  @override
  int get microsecond => _now.microsecond;
  @override
  int get weekday => _now.weekday;
  @override
  bool get isUtc => _now.isUtc;
  @override
  String get timeZoneName => _now.timeZoneName;
  @override
  Duration get timeZoneOffset => _now.timeZoneOffset;
  @override
  int get millisecondsSinceEpoch => _now.millisecondsSinceEpoch;
  @override
  int get microsecondsSinceEpoch => _now.microsecondsSinceEpoch;

  @override
  DateTime add(Duration duration) => _now.add(duration);
  @override
  DateTime subtract(Duration duration) => _now.subtract(duration);
  @override
  Duration difference(DateTime other) => _now.difference(other);
  @override
  bool isAfter(DateTime other) => _now.isAfter(other);
  @override
  bool isBefore(DateTime other) => _now.isBefore(other);
  @override
  bool isAtSameMomentAs(DateTime other) => _now.isAtSameMomentAs(other);
  @override
  int compareTo(DateTime other) => _now.compareTo(other);
  @override
  DateTime toLocal() => _now.toLocal();
  @override
  DateTime toUtc() => _now.toUtc();
  @override
  String toIso8601String() => _now.toIso8601String();
  @override
  String toString() => _now.toString();
}
