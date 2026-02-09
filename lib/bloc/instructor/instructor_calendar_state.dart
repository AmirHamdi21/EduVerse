import 'package:equatable/equatable.dart';

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

enum InstructorReminderType {
  grading,
  deadline,
  meeting,
  suggestion,
}

enum CalendarViewType {
  month,
  week,
  day,
}

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
  final List<InstructorReminder> reminders;
  final DateTime selectedDate;
  final DateTime focusedMonth;
  final CalendarViewType viewType;
  final InstructorEventFilter filter;
  final bool isFilterVisible;
  final bool isAddEventVisible;

  InstructorCalendarState({
    this.isLoading = false,
    this.error,
    this.successMessage,
    this.events = const [],
    this.reminders = const [],
    DateTime? selectedDate,
    DateTime? focusedMonth,
    this.viewType = CalendarViewType.month,
    this.filter = const InstructorEventFilter(),
    this.isFilterVisible = false,
    this.isAddEventVisible = false,
  })  : selectedDate = selectedDate ?? DateTime.now(),
        focusedMonth = focusedMonth ?? DateTime.now();

  // Get filtered events
  List<InstructorCalendarEvent> get filteredEvents {
    return events.where((event) => filter.isTypeEnabled(event.type)).toList();
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
    final now = DateTime.now();
    final weekLater = now.add(const Duration(days: 7));
    return filteredEvents.where((event) {
      return event.date.isAfter(now.subtract(const Duration(days: 1))) &&
          event.date.isBefore(weekLater);
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  // Check if date has events
  bool hasEventsOnDate(DateTime date) {
    return filteredEvents.any((event) =>
        event.date.year == date.year &&
        event.date.month == date.month &&
        event.date.day == date.day);
  }

  // Get events for a specific date
  List<InstructorCalendarEvent> getEventsForDate(DateTime date) {
    return filteredEvents
        .where((event) =>
            event.date.year == date.year &&
            event.date.month == date.month &&
            event.date.day == date.day)
        .toList();
  }

  InstructorCalendarState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
    List<InstructorCalendarEvent>? events,
    List<InstructorReminder>? reminders,
    DateTime? selectedDate,
    DateTime? focusedMonth,
    CalendarViewType? viewType,
    InstructorEventFilter? filter,
    bool? isFilterVisible,
    bool? isAddEventVisible,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return InstructorCalendarState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
      events: events ?? this.events,
      reminders: reminders ?? this.reminders,
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
        reminders,
        selectedDate,
        focusedMonth,
        viewType,
        filter,
        isFilterVisible,
        isAddEventVisible,
      ];
}
