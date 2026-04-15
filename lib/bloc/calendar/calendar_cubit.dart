import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'calendar_state.dart';

class CalendarCubit extends Cubit<CalendarState> {
  static const String _eventsStorageKey = 'calendar_events';

  CalendarCubit()
    : super(
        CalendarState(
          selectedDate: DateTime.now(),
          focusedMonth: DateTime.now(),
        ),
      ) {
    _initialize();
  }

  Future<void> _initialize() async {
    // Load saved events first
    final savedEvents = await _loadEventsFromStorage();

    if (savedEvents.isNotEmpty) {
      emit(
        state.copyWith(events: savedEvents, aiReminders: _getMockReminders()),
      );
    } else {
      // Only use mock events if no saved events exist
      emit(
        state.copyWith(
          events: _getMockEvents(),
          aiReminders: _getMockReminders(),
        ),
      );
      // Save mock events to storage
      await _saveEventsToStorage(_getMockEvents());
    }
  }

  Future<List<CalendarEvent>> _loadEventsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getString(_eventsStorageKey);

      if (eventsJson == null) return [];

      final List<dynamic> eventsList = json.decode(eventsJson);
      return eventsList
          .map((e) => _eventFromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveEventsToStorage(List<CalendarEvent> events) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = json.encode(
        events.map((e) => _eventToJson(e)).toList(),
      );
      await prefs.setString(_eventsStorageKey, eventsJson);
    } catch (e) {
      // Handle error silently
    }
  }

  Map<String, dynamic> _eventToJson(CalendarEvent event) {
    return {
      'id': event.id,
      'title': event.title,
      'type': event.type.index,
      'date': event.date.toIso8601String(),
      'time': event.time,
      'endTime': event.endTime,
      'course': event.course,
      'location': event.location,
      'description': event.description,
      'isCompleted': event.isCompleted,
      'hasReminder': event.hasReminder,
    };
  }

  CalendarEvent _eventFromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      type: EventType.values[json['type'] as int],
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String?,
      endTime: json['endTime'] as String?,
      course: json['course'] as String?,
      location: json['location'] as String?,
      description: json['description'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      hasReminder: json['hasReminder'] as bool? ?? true,
    );
  }

  List<CalendarEvent> _getMockEvents() {
    final now = DateTime.now();
    return [
      CalendarEvent(
        id: '1',
        title: 'Operating Systems Lecture',
        type: EventType.lecture,
        date: DateTime(now.year, now.month, now.day + 1),
        time: '09:00 AM',
        endTime: '10:30 AM',
        course: 'Operating Systems',
        location: 'Room 301, Building A',
      ),
      CalendarEvent(
        id: '2',
        title: 'Data Structures Lab',
        type: EventType.lab,
        date: DateTime(now.year, now.month, now.day + 2),
        time: '02:00 PM',
        endTime: '04:00 PM',
        course: 'Data Structures',
        location: 'Computer Lab 2',
      ),
      CalendarEvent(
        id: '3',
        title: 'Machine Learning Quiz',
        type: EventType.quiz,
        date: DateTime(now.year, now.month, now.day + 3),
        time: '11:00 AM',
        course: 'Machine Learning',
        location: 'Hall B',
      ),
      CalendarEvent(
        id: '4',
        title: 'Database Assignment Due',
        type: EventType.assignment,
        date: DateTime(now.year, now.month, now.day + 5),
        time: '11:59 PM',
        course: 'Database Systems',
        description: 'Submit SQL queries for Chapter 5',
      ),
      CalendarEvent(
        id: '5',
        title: 'Midterm Exam - Networks',
        type: EventType.exam,
        date: DateTime(now.year, now.month, now.day + 7),
        time: '10:00 AM',
        endTime: '12:00 PM',
        course: 'Computer Networks',
        location: 'Exam Hall 1',
      ),
      CalendarEvent(
        id: '6',
        title: 'Study Group Meeting',
        type: EventType.personalTask,
        date: DateTime(now.year, now.month, now.day + 1),
        time: '06:00 PM',
        location: 'Library',
        description: 'Review for upcoming exams',
      ),
    ];
  }

  List<AiReminder> _getMockReminders() {
    return [
      AiReminder(
        id: '1',
        title: 'AI Smart Reminder',
        message: 'You have a quiz in 3 days — try the AI practice quiz now.',
        type: ReminderType.quiz,
        createdAt: DateTime.now(),
      ),
      AiReminder(
        id: '2',
        title: 'AI Smart Reminder',
        message:
            "You've missed 1 lab session — would you like to schedule a review?",
        type: ReminderType.missedSession,
        createdAt: DateTime.now(),
      ),
    ];
  }

  void selectDate(DateTime date) {
    emit(state.copyWith(selectedDate: date));
  }

  void changeFocusedMonth(DateTime month) {
    emit(state.copyWith(focusedMonth: month));
  }

  void goToToday() {
    final today = DateTime.now();
    emit(state.copyWith(selectedDate: today, focusedMonth: today));
  }

  void goToPreviousMonth() {
    final newMonth = DateTime(
      state.focusedMonth.year,
      state.focusedMonth.month - 1,
    );
    emit(state.copyWith(focusedMonth: newMonth));
  }

  void goToNextMonth() {
    final newMonth = DateTime(
      state.focusedMonth.year,
      state.focusedMonth.month + 1,
    );
    emit(state.copyWith(focusedMonth: newMonth));
  }

  void setViewType(CalendarViewType viewType) {
    emit(state.copyWith(viewType: viewType));
  }

  void toggleFilterVisibility() {
    emit(state.copyWith(isFilterVisible: !state.isFilterVisible));
  }

  void updateFilter(EventFilter filter) {
    emit(state.copyWith(filter: filter));
  }

  void toggleFilterType(String type) {
    final currentFilter = state.filter;
    EventFilter newFilter;

    switch (type) {
      case 'lectures':
        newFilter = currentFilter.copyWith(lectures: !currentFilter.lectures);
        break;
      case 'labs':
        newFilter = currentFilter.copyWith(labs: !currentFilter.labs);
        break;
      case 'assignments':
        newFilter = currentFilter.copyWith(
          assignments: !currentFilter.assignments,
        );
        break;
      case 'exams':
        newFilter = currentFilter.copyWith(exams: !currentFilter.exams);
        break;
      case 'personalTasks':
        newFilter = currentFilter.copyWith(
          personalTasks: !currentFilter.personalTasks,
        );
        break;
      default:
        return;
    }

    emit(state.copyWith(filter: newFilter));
  }

  void showAddEvent() {
    emit(state.copyWith(isAddEventVisible: true));
  }

  void hideAddEvent() {
    emit(state.copyWith(isAddEventVisible: false));
  }

  Future<void> addEvent({
    required String title,
    required EventType type,
    required DateTime date,
    String? time,
    String? endTime,
    String? course,
    String? location,
    String? description,
  }) async {
    if (title.trim().isEmpty) {
      emit(state.copyWith(error: 'Event title is required'));
      _clearError();
      return;
    }

    emit(state.copyWith(isLoading: true));

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    final newEvent = CalendarEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      type: type,
      date: date,
      time: time,
      endTime: endTime,
      course: course?.trim(),
      location: location?.trim(),
      description: description?.trim(),
    );

    final updatedEvents = [...state.events, newEvent];

    emit(
      state.copyWith(
        isLoading: false,
        events: updatedEvents,
        isAddEventVisible: false,
        successMessage: 'Event added successfully',
      ),
    );

    // Save to storage
    await _saveEventsToStorage(updatedEvents);
    _clearSuccess();
  }

  Future<void> deleteEvent(String eventId) async {
    emit(state.copyWith(isLoading: true));

    await Future.delayed(const Duration(milliseconds: 300));

    final updatedEvents = state.events.where((e) => e.id != eventId).toList();

    emit(
      state.copyWith(
        isLoading: false,
        events: updatedEvents,
        successMessage: 'Event deleted',
      ),
    );

    // Save to storage
    await _saveEventsToStorage(updatedEvents);
    _clearSuccess();
  }

  void showEventDetails(CalendarEvent event) {
    // This is handled by the UI - method exists for potential future use
  }

  Future<void> toggleEventCompletion(String eventId) async {
    final updatedEvents = state.events.map((event) {
      if (event.id == eventId) {
        return event.copyWith(isCompleted: !event.isCompleted);
      }
      return event;
    }).toList();

    emit(state.copyWith(events: updatedEvents));
    await _saveEventsToStorage(updatedEvents);
  }

  void dismissReminder(String reminderId) {
    final updatedReminders = state.aiReminders
        .where((r) => r.id != reminderId)
        .toList();
    emit(state.copyWith(aiReminders: updatedReminders));
  }

  String? getAiSuggestedTimeSlot() {
    // Mock AI suggestion based on existing events
    final today = DateTime.now();
    final todayEvents = state.getEventsForDate(today);

    if (todayEvents.isEmpty) {
      return '10:00 AM - 11:00 AM';
    }

    // Find a free slot
    final times = ['09:00 AM', '11:00 AM', '02:00 PM', '04:00 PM'];
    for (final time in times) {
      final hasConflict = todayEvents.any((e) => e.time == time);
      if (!hasConflict) {
        return '$time - ${_addHour(time)}';
      }
    }

    return '06:00 PM - 07:00 PM';
  }

  String _addHour(String time) {
    final parts = time.split(':');
    var hour = int.parse(parts[0]);
    final isPM = time.contains('PM');

    hour++;
    if (hour == 12) {
      return '12:00 ${isPM ? 'PM' : 'AM'}';
    } else if (hour > 12) {
      return '${hour - 12}:00 PM';
    }
    return '$hour:00 ${isPM ? 'PM' : 'AM'}';
  }

  void _clearError() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!isClosed) {
        emit(state.copyWith(clearError: true));
      }
    });
  }

  void _clearSuccess() {
    Future.delayed(const Duration(seconds: 2), () {
      if (!isClosed) {
        emit(state.copyWith(clearSuccess: true));
      }
    });
  }
}
