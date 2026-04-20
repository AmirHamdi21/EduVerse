import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/schedule/schedule_models.dart';
import '../../services/api/schedule_api_service.dart';
import '../schedule/schedule_item_builder.dart';
import 'calendar_state.dart';

class CalendarCubit extends Cubit<CalendarState> {
  final ScheduleApiService _scheduleService;

  CalendarCubit({required ScheduleApiService scheduleService})
    : _scheduleService = scheduleService,
      super(
        CalendarState(
          selectedDate: DateTime.now(),
          focusedMonth: DateTime.now(),
        ),
      ) {
    _initialize();
  }

  Future<void> _initialize() async {
    emit(state.copyWith(aiReminders: _getMockReminders()));
    await loadSchedule();
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

  Future<void> loadSchedule() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    List<DailyScheduleResponse> days = const <DailyScheduleResponse>[];

    if (state.viewType == CalendarViewType.day) {
      final result = await _scheduleService.getDailySchedule(
        date: toISODate(state.selectedDate),
      );

      if (result.isFailure || result.data == null) {
        emit(
          state.copyWith(
            isLoading: false,
            error: result.error?.message ?? 'Failed to load schedule',
          ),
        );
        _clearError();
        return;
      }

      days = <DailyScheduleResponse>[result.data!];
    } else if (state.viewType == CalendarViewType.week) {
      final result = await _scheduleService.getWeeklySchedule(
        startDate: toISODate(startOfWeek(state.selectedDate)),
      );

      if (result.isFailure || result.data == null) {
        emit(
          state.copyWith(
            isLoading: false,
            error: result.error?.message ?? 'Failed to load schedule',
          ),
        );
        _clearError();
        return;
      }

      days = result.data!.days;
    } else {
      final result = await _scheduleService.getMonthSchedule(
        state.focusedMonth,
      );

      if (result.isFailure || result.data == null) {
        emit(
          state.copyWith(
            isLoading: false,
            error: result.error?.message ?? 'Failed to load schedule',
          ),
        );
        _clearError();
        return;
      }

      days = result.data!;
    }

    final items = ScheduleItemBuilder.build(days: days);

    emit(
      state.copyWith(
        isLoading: false,
        rawDays: days,
        unifiedItems: items,
        events: _mapToLegacyEvents(items),
      ),
    );
  }

  void selectDate(DateTime date) {
    emit(state.copyWith(selectedDate: date));
    loadSchedule();
  }

  void changeFocusedMonth(DateTime month) {
    emit(state.copyWith(focusedMonth: month));
    if (state.viewType == CalendarViewType.month) {
      loadSchedule();
    }
  }

  void goToToday() {
    final today = DateTime.now();
    emit(state.copyWith(selectedDate: today, focusedMonth: today));
    loadSchedule();
  }

  void goToPreviousMonth() {
    final newMonth = DateTime(
      state.focusedMonth.year,
      state.focusedMonth.month - 1,
    );
    emit(state.copyWith(focusedMonth: newMonth));
    if (state.viewType == CalendarViewType.month) {
      loadSchedule();
    }
  }

  void goToNextMonth() {
    final newMonth = DateTime(
      state.focusedMonth.year,
      state.focusedMonth.month + 1,
    );
    emit(state.copyWith(focusedMonth: newMonth));
    if (state.viewType == CalendarViewType.month) {
      loadSchedule();
    }
  }

  void setViewType(CalendarViewType viewType) {
    emit(state.copyWith(viewType: viewType));
    loadSchedule();
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

  void setKindFilter(ScheduleItemKind? kind) {
    emit(state.copyWith(kindFilter: kind));
  }

  void setCourseFilter(String? courseCode) {
    final normalized = courseCode?.trim();
    emit(
      state.copyWith(
        courseFilter: normalized == null || normalized.isEmpty
            ? null
            : normalized,
      ),
    );
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

    final startDateTime = _combineDateAndTime(date, time);
    final resolvedEnd = endTime == null || endTime.trim().isEmpty
        ? startDateTime.add(const Duration(hours: 1))
        : _combineDateAndTime(date, endTime);

    final payload = <String, dynamic>{
      'title': title.trim(),
      'eventType': _mapEventTypeToApi(type),
      'startTime': startDateTime.toUtc().toIso8601String(),
      'endTime': resolvedEnd.toUtc().toIso8601String(),
      'color': _resolveEventColor(type),
    };

    final parsedCourseId = int.tryParse(course?.trim() ?? '');
    if (parsedCourseId != null) {
      payload['courseId'] = parsedCourseId;
    }
    if (location != null && location.trim().isNotEmpty) {
      payload['location'] = location.trim();
    }
    if (description != null && description.trim().isNotEmpty) {
      payload['description'] = description.trim();
    }

    final result = await _scheduleService.createCalendarEvent(payload);
    if (result.isFailure) {
      emit(
        state.copyWith(
          isLoading: false,
          error: result.error?.message ?? 'Failed to add event',
        ),
      );
      _clearError();
      return;
    }

    await loadSchedule();
    emit(
      state.copyWith(
        isAddEventVisible: false,
        successMessage: 'Event added successfully',
      ),
    );
    _clearSuccess();
  }

  Future<void> deleteEvent(String eventId) async {
    emit(state.copyWith(isLoading: true));

    final resolvedEventId = _resolvePersonalEventId(eventId);
    if (resolvedEventId == null) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Only personal events can be deleted',
        ),
      );
      _clearError();
      return;
    }

    final result = await _scheduleService.deleteCalendarEvent(resolvedEventId);
    if (result.isFailure) {
      emit(
        state.copyWith(
          isLoading: false,
          error: result.error?.message ?? 'Failed to delete event',
        ),
      );
      _clearError();
      return;
    }

    await loadSchedule();
    emit(state.copyWith(successMessage: 'Event deleted'));
    _clearSuccess();
  }

  Future<void> registerForCampusEvent(int eventId, {String? notes}) async {
    emit(state.copyWith(isLoading: true));

    final result = await _scheduleService.registerForCampusEvent(
      eventId,
      notes: notes,
    );

    if (result.isFailure) {
      emit(
        state.copyWith(
          isLoading: false,
          error: result.error?.message ?? 'Failed to register for event',
        ),
      );
      _clearError();
      return;
    }

    await loadSchedule();
    emit(state.copyWith(successMessage: 'Registered for event'));
    _clearSuccess();
  }

  Future<void> unregisterFromCampusEvent(int eventId) async {
    emit(state.copyWith(isLoading: true));

    final result = await _scheduleService.unregisterFromCampusEvent(eventId);

    if (result.isFailure) {
      emit(
        state.copyWith(
          isLoading: false,
          error: result.error?.message ?? 'Failed to unregister from event',
        ),
      );
      _clearError();
      return;
    }

    await loadSchedule();
    emit(state.copyWith(successMessage: 'Unregistered from event'));
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
  }

  void dismissReminder(String reminderId) {
    final updatedReminders = state.aiReminders
        .where((r) => r.id != reminderId)
        .toList();
    emit(state.copyWith(aiReminders: updatedReminders));
  }

  String? getAiSuggestedTimeSlot() {
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

  List<CalendarEvent> _mapToLegacyEvents(List<UnifiedScheduleItem> items) {
    return items
        .map((item) {
          final parsedDate = DateTime.tryParse(item.date);
          final date = parsedDate == null
              ? DateTime.now()
              : DateTime(parsedDate.year, parsedDate.month, parsedDate.day);

          return CalendarEvent(
            id: item.id,
            title: item.title,
            type: _mapKindToLegacyType(item.kind),
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

  EventType _mapKindToLegacyType(ScheduleItemKind kind) {
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

  int? _resolvePersonalEventId(String eventId) {
    CalendarEvent? fromState;
    for (final event in state.events) {
      if (event.id == eventId) {
        fromState = event;
        break;
      }
    }

    if (fromState?.eventId != null) {
      return fromState!.eventId;
    }

    final direct = int.tryParse(eventId);
    if (direct != null) {
      return direct;
    }

    final parts = eventId.split('-');
    if (parts.length >= 2 && parts.first == 'event') {
      return int.tryParse(parts[1]);
    }

    return null;
  }

  DateTime _combineDateAndTime(DateTime date, String? timeText) {
    final parsed = _parseTime(timeText);
    final hour = parsed?.$1 ?? 9;
    final minute = parsed?.$2 ?? 0;

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  (int, int)? _parseTime(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final raw = value.trim();
    final hhmm = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(raw);
    if (hhmm != null) {
      final hour = int.tryParse(hhmm.group(1) ?? '') ?? 0;
      final minute = int.tryParse(hhmm.group(2) ?? '') ?? 0;
      return (_safeHour(hour), _safeMinute(minute));
    }

    final hhmmss = RegExp(r'^(\d{1,2}):(\d{2}):(\d{2})$').firstMatch(raw);
    if (hhmmss != null) {
      final hour = int.tryParse(hhmmss.group(1) ?? '') ?? 0;
      final minute = int.tryParse(hhmmss.group(2) ?? '') ?? 0;
      return (_safeHour(hour), _safeMinute(minute));
    }

    final amPm = RegExp(r'^(\d{1,2}):(\d{2})\s*([AaPp][Mm])$').firstMatch(raw);
    if (amPm != null) {
      var hour = int.tryParse(amPm.group(1) ?? '') ?? 0;
      final minute = int.tryParse(amPm.group(2) ?? '') ?? 0;
      final meridiem = (amPm.group(3) ?? '').toUpperCase();

      hour %= 12;
      if (meridiem == 'PM') {
        hour += 12;
      }

      return (_safeHour(hour), _safeMinute(minute));
    }

    return null;
  }

  int _safeHour(int value) {
    return value < 0 ? 0 : (value > 23 ? 23 : value);
  }

  int _safeMinute(int value) {
    return value < 0 ? 0 : (value > 59 ? 59 : value);
  }

  String _mapEventTypeToApi(EventType type) {
    switch (type) {
      case EventType.lecture:
        return 'LECTURE';
      case EventType.lab:
        return 'LAB';
      case EventType.assignment:
        return 'ASSIGNMENT';
      case EventType.exam:
        return 'EXAM';
      case EventType.quiz:
        return 'QUIZ';
      case EventType.personalTask:
        return 'PERSONAL';
    }
  }

  String _resolveEventColor(EventType type) {
    switch (type) {
      case EventType.lecture:
        return '#3b82f6';
      case EventType.lab:
        return '#10b981';
      case EventType.assignment:
        return '#f59e0b';
      case EventType.exam:
        return '#ef4444';
      case EventType.quiz:
        return '#8b5cf6';
      case EventType.personalTask:
        return '#ec4899';
    }
  }
}
