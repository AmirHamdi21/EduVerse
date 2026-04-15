import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'instructor_calendar_state.dart';

class InstructorCalendarCubit extends Cubit<InstructorCalendarState> {
  static const String _eventsStorageKey = 'instructor_calendar_events';

  InstructorCalendarCubit() : super(InstructorCalendarState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    final savedEvents = await _loadEventsFromStorage();

    if (savedEvents.isNotEmpty) {
      emit(state.copyWith(events: savedEvents, reminders: _getMockReminders()));
    } else {
      emit(
        state.copyWith(
          events: _getMockEvents(),
          reminders: _getMockReminders(),
        ),
      );
      await _saveEventsToStorage(_getMockEvents());
    }
  }

  Future<List<InstructorCalendarEvent>> _loadEventsFromStorage() async {
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

  Future<void> _saveEventsToStorage(
    List<InstructorCalendarEvent> events,
  ) async {
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

  Map<String, dynamic> _eventToJson(InstructorCalendarEvent event) {
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
      'studentCount': event.studentCount,
    };
  }

  InstructorCalendarEvent _eventFromJson(Map<String, dynamic> json) {
    return InstructorCalendarEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      type: InstructorEventType.values[json['type'] as int],
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String?,
      endTime: json['endTime'] as String?,
      course: json['course'] as String?,
      location: json['location'] as String?,
      description: json['description'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      hasReminder: json['hasReminder'] as bool? ?? true,
      studentCount: json['studentCount'] as int?,
    );
  }

  // View type management
  void setViewType(CalendarViewType type) {
    emit(state.copyWith(viewType: type, clearError: true, clearSuccess: true));
  }

  // Date selection
  void selectDate(DateTime date) {
    emit(
      state.copyWith(selectedDate: date, clearError: true, clearSuccess: true),
    );
  }

  // Month navigation
  void nextMonth() {
    final newMonth = DateTime(
      state.focusedMonth.year,
      state.focusedMonth.month + 1,
    );
    emit(state.copyWith(focusedMonth: newMonth));
  }

  void previousMonth() {
    final newMonth = DateTime(
      state.focusedMonth.year,
      state.focusedMonth.month - 1,
    );
    emit(state.copyWith(focusedMonth: newMonth));
  }

  void goToToday() {
    final now = DateTime.now();
    emit(state.copyWith(selectedDate: now, focusedMonth: now));
  }

  // Filter management
  void toggleFilterVisibility() {
    emit(state.copyWith(isFilterVisible: !state.isFilterVisible));
  }

  void toggleFilterType(InstructorEventType type) {
    final currentFilter = state.filter;
    InstructorEventFilter newFilter;

    switch (type) {
      case InstructorEventType.lecture:
        newFilter = currentFilter.copyWith(lectures: !currentFilter.lectures);
        break;
      case InstructorEventType.lab:
        newFilter = currentFilter.copyWith(labs: !currentFilter.labs);
        break;
      case InstructorEventType.officeHours:
        newFilter = currentFilter.copyWith(
          officeHours: !currentFilter.officeHours,
        );
        break;
      case InstructorEventType.meeting:
        newFilter = currentFilter.copyWith(meetings: !currentFilter.meetings);
        break;
      case InstructorEventType.deadline:
        newFilter = currentFilter.copyWith(deadlines: !currentFilter.deadlines);
        break;
      case InstructorEventType.grading:
        newFilter = currentFilter.copyWith(grading: !currentFilter.grading);
        break;
      case InstructorEventType.exam:
        newFilter = currentFilter.copyWith(exams: !currentFilter.exams);
        break;
    }

    emit(state.copyWith(filter: newFilter));
  }

  void resetFilters() {
    emit(state.copyWith(filter: const InstructorEventFilter()));
  }

  // Event management
  Future<void> addEvent(InstructorCalendarEvent event) async {
    final updatedEvents = [...state.events, event];
    emit(
      state.copyWith(
        events: updatedEvents,
        successMessage: 'Event added successfully',
      ),
    );
    await _saveEventsToStorage(updatedEvents);
    // Clear success message after delay
    await Future.delayed(const Duration(seconds: 2));
    emit(state.copyWith(clearSuccess: true));
  }

  Future<void> updateEvent(InstructorCalendarEvent event) async {
    final updatedEvents = state.events.map((e) {
      if (e.id == event.id) return event;
      return e;
    }).toList();

    emit(
      state.copyWith(
        events: updatedEvents,
        successMessage: 'Event updated successfully',
      ),
    );
    await _saveEventsToStorage(updatedEvents);
    await Future.delayed(const Duration(seconds: 2));
    emit(state.copyWith(clearSuccess: true));
  }

  Future<void> deleteEvent(String eventId) async {
    final updatedEvents = state.events.where((e) => e.id != eventId).toList();
    emit(
      state.copyWith(
        events: updatedEvents,
        successMessage: 'Event deleted successfully',
      ),
    );
    await _saveEventsToStorage(updatedEvents);
    await Future.delayed(const Duration(seconds: 2));
    emit(state.copyWith(clearSuccess: true));
  }

  Future<void> toggleEventCompletion(String eventId) async {
    final updatedEvents = state.events.map((e) {
      if (e.id == eventId) {
        return e.copyWith(isCompleted: !e.isCompleted);
      }
      return e;
    }).toList();

    emit(state.copyWith(events: updatedEvents));
    await _saveEventsToStorage(updatedEvents);
  }

  // Reminder management
  void dismissReminder(String reminderId) {
    final updatedReminders = state.reminders
        .map(
          (r) => r.id == reminderId
              ? InstructorReminder(
                  id: r.id,
                  title: r.title,
                  message: r.message,
                  type: r.type,
                  createdAt: r.createdAt,
                  isDismissed: true,
                )
              : r,
        )
        .toList();
    emit(state.copyWith(reminders: updatedReminders));
  }

  // Mock data
  List<InstructorCalendarEvent> _getMockEvents() {
    final now = DateTime.now();
    return [
      InstructorCalendarEvent(
        id: '1',
        title: 'CS201 - Data Structures',
        type: InstructorEventType.lecture,
        date: now,
        time: '09:00',
        endTime: '10:30',
        course: 'CS201',
        location: 'Room 301',
        description: 'Trees and Graphs introduction',
        studentCount: 45,
      ),
      InstructorCalendarEvent(
        id: '2',
        title: 'Office Hours',
        type: InstructorEventType.officeHours,
        date: now,
        time: '14:00',
        endTime: '16:00',
        location: 'Office 215',
        description: 'Open office hours for all students',
      ),
      InstructorCalendarEvent(
        id: '3',
        title: 'CS201 Lab Session',
        type: InstructorEventType.lab,
        date: now.add(const Duration(days: 1)),
        time: '10:00',
        endTime: '12:00',
        course: 'CS201',
        location: 'Lab 102',
        description: 'Binary Search Tree implementation',
        studentCount: 25,
      ),
      InstructorCalendarEvent(
        id: '4',
        title: 'Department Meeting',
        type: InstructorEventType.meeting,
        date: now.add(const Duration(days: 1)),
        time: '15:00',
        endTime: '16:30',
        location: 'Conference Room A',
        description: 'Monthly department review',
      ),
      InstructorCalendarEvent(
        id: '5',
        title: 'Assignment 3 Deadline',
        type: InstructorEventType.deadline,
        date: now.add(const Duration(days: 3)),
        time: '23:59',
        course: 'CS201',
        description: 'Binary Trees Assignment',
        studentCount: 45,
      ),
      InstructorCalendarEvent(
        id: '6',
        title: 'Grade Midterm Exams',
        type: InstructorEventType.grading,
        date: now.add(const Duration(days: 2)),
        time: '10:00',
        endTime: '14:00',
        course: 'CS301',
        description: '35 exams to grade',
        studentCount: 35,
      ),
      InstructorCalendarEvent(
        id: '7',
        title: 'CS301 Midterm Exam',
        type: InstructorEventType.exam,
        date: now.add(const Duration(days: 5)),
        time: '09:00',
        endTime: '11:00',
        course: 'CS301',
        location: 'Exam Hall B',
        description: 'Midterm examination',
        studentCount: 35,
      ),
      InstructorCalendarEvent(
        id: '8',
        title: 'CS401 - Advanced Algorithms',
        type: InstructorEventType.lecture,
        date: now.add(const Duration(days: 2)),
        time: '11:00',
        endTime: '12:30',
        course: 'CS401',
        location: 'Room 405',
        description: 'Dynamic Programming',
        studentCount: 28,
      ),
    ];
  }

  List<InstructorReminder> _getMockReminders() {
    return [
      InstructorReminder(
        id: '1',
        title: 'Pending Grades',
        message: 'You have 12 assignments waiting to be graded',
        type: InstructorReminderType.grading,
        createdAt: DateTime.now(),
      ),
      InstructorReminder(
        id: '2',
        title: 'Upcoming Deadline',
        message: 'Assignment 3 deadline is in 3 days',
        type: InstructorReminderType.deadline,
        createdAt: DateTime.now(),
      ),
    ];
  }
}
