import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/admin/admin_periods_models.dart';
import '../../models/schedule/schedule_models.dart';
import '../../services/api/office_hours_service.dart';
import '../../services/api/schedule_api_service.dart';
import '../schedule/schedule_item_builder.dart';
import 'instructor_calendar_state.dart';

class InstructorCalendarCubit extends Cubit<InstructorCalendarState> {
  final ScheduleApiService _scheduleService;
  final OfficeHoursService _officeHoursService;

  InstructorCalendarCubit({
    required ScheduleApiService scheduleService,
    required OfficeHoursService officeHoursService,
  }) : _scheduleService = scheduleService,
       _officeHoursService = officeHoursService,
       super(InstructorCalendarState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    emit(state.copyWith(reminders: _getMockReminders()));
    await loadSchedule();
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

    final slots = await _loadOfficeHoursSlots();

    var items = ScheduleItemBuilder.build(
      days: days,
      officeHoursSlots: slots,
      startDate: toISODate(startOfWeek(state.selectedDate)),
      endDate: toISODate(endOfWeek(state.selectedDate)),
    );

    if (state.campusSource == 'my') {
      final myCampusResult = await _scheduleService.getMyCampusEvents(
        page: 1,
        limit: 100,
      );

      if (!myCampusResult.isFailure && myCampusResult.data != null) {
        final myCampusItems = myCampusResult.data!.items
            .map(_mapCampusModelToItem)
            .toList(growable: false);

        final withoutCampus = items
            .where((item) => item.kind != ScheduleItemKind.campusEvent)
            .toList(growable: false);

        items = <UnifiedScheduleItem>[...withoutCampus, ...myCampusItems]
          ..sort((a, b) {
            final byDate = a.date.compareTo(b.date);
            if (byDate != 0) {
              return byDate;
            }
            return toMinutes(a.startTime).compareTo(toMinutes(b.startTime));
          });
      }
    }

    emit(
      state.copyWith(
        isLoading: false,
        rawDays: days,
        unifiedItems: items,
        events: _mapToLegacyEvents(items),
      ),
    );
  }

  Future<List<OfficeHourSlotModel>> _loadOfficeHoursSlots() async {
    try {
      final slots = await _officeHoursService.getSlots(page: 1, limit: 200);
      return slots.items;
    } catch (_) {
      return const <OfficeHourSlotModel>[];
    }
  }

  void setViewType(CalendarViewType type) {
    emit(state.copyWith(viewType: type, clearError: true, clearSuccess: true));
    loadSchedule();
  }

  void selectDate(DateTime date) {
    emit(
      state.copyWith(selectedDate: date, clearError: true, clearSuccess: true),
    );
    loadSchedule();
  }

  void nextMonth() {
    final newMonth = DateTime(
      state.focusedMonth.year,
      state.focusedMonth.month + 1,
    );
    emit(state.copyWith(focusedMonth: newMonth));
    if (state.viewType == CalendarViewType.month) {
      loadSchedule();
    }
  }

  void previousMonth() {
    final newMonth = DateTime(
      state.focusedMonth.year,
      state.focusedMonth.month - 1,
    );
    emit(state.copyWith(focusedMonth: newMonth));
    if (state.viewType == CalendarViewType.month) {
      loadSchedule();
    }
  }

  void goToToday() {
    final now = DateTime.now();
    emit(state.copyWith(selectedDate: now, focusedMonth: now));
    loadSchedule();
  }

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

  void setCampusSource(String source) {
    final normalized = source.trim().toLowerCase();
    if (normalized != 'all' && normalized != 'my') {
      return;
    }

    emit(state.copyWith(campusSource: normalized));
    loadSchedule();
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

  Future<void> addEvent(InstructorCalendarEvent event) async {
    emit(state.copyWith(isLoading: true));

    final start = _combineDateAndTime(event.date, event.time);
    final end = event.endTime == null || event.endTime!.trim().isEmpty
        ? start.add(const Duration(hours: 1))
        : _combineDateAndTime(event.date, event.endTime);

    final payload = <String, dynamic>{
      'title': event.title,
      'eventType': _mapTypeToApi(event.type),
      'startTime': start.toUtc().toIso8601String(),
      'endTime': end.toUtc().toIso8601String(),
      'color': _resolveColor(event.type),
    };

    if (event.location != null && event.location!.trim().isNotEmpty) {
      payload['location'] = event.location!.trim();
    }
    if (event.description != null && event.description!.trim().isNotEmpty) {
      payload['description'] = event.description!.trim();
    }

    final courseId = int.tryParse(event.course?.trim() ?? '');
    if (courseId != null) {
      payload['courseId'] = courseId;
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
    emit(state.copyWith(successMessage: 'Event added successfully'));
    _clearSuccess();
  }

  Future<void> updateEvent(InstructorCalendarEvent event) async {
    emit(state.copyWith(isLoading: true));

    final personalEventId = _resolvePersonalEventId(
      event.id,
      fallback: event.eventId,
    );
    if (personalEventId == null) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Only personal events can be updated',
        ),
      );
      _clearError();
      return;
    }

    final start = _combineDateAndTime(event.date, event.time);
    final end = event.endTime == null || event.endTime!.trim().isEmpty
        ? start.add(const Duration(hours: 1))
        : _combineDateAndTime(event.date, event.endTime);

    final payload = <String, dynamic>{
      'title': event.title,
      'eventType': _mapTypeToApi(event.type),
      'startTime': start.toUtc().toIso8601String(),
      'endTime': end.toUtc().toIso8601String(),
      'color': _resolveColor(event.type),
    };

    if (event.location != null && event.location!.trim().isNotEmpty) {
      payload['location'] = event.location!.trim();
    }
    if (event.description != null && event.description!.trim().isNotEmpty) {
      payload['description'] = event.description!.trim();
    }

    final result = await _scheduleService.updateCalendarEvent(
      personalEventId,
      payload,
    );

    if (result.isFailure) {
      emit(
        state.copyWith(
          isLoading: false,
          error: result.error?.message ?? 'Failed to update event',
        ),
      );
      _clearError();
      return;
    }

    await loadSchedule();
    emit(state.copyWith(successMessage: 'Event updated successfully'));
    _clearSuccess();
  }

  Future<void> deleteEvent(String eventId) async {
    emit(state.copyWith(isLoading: true));

    final personalEventId = _resolvePersonalEventId(eventId);
    if (personalEventId == null) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Only personal events can be deleted',
        ),
      );
      _clearError();
      return;
    }

    final result = await _scheduleService.deleteCalendarEvent(personalEventId);
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
    emit(state.copyWith(successMessage: 'Event deleted successfully'));
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

  Future<void> toggleEventCompletion(String eventId) async {
    final updatedEvents = state.events
        .map((e) {
          if (e.id == eventId) {
            return e.copyWith(isCompleted: !e.isCompleted);
          }
          return e;
        })
        .toList(growable: false);

    emit(state.copyWith(events: updatedEvents));
  }

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
        .toList(growable: false);

    emit(state.copyWith(reminders: updatedReminders));
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

  List<InstructorCalendarEvent> _mapToLegacyEvents(
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

  UnifiedScheduleItem _mapCampusModelToItem(CampusEventModel event) {
    final start = event.startDateTime ?? DateTime.now();
    final end = event.endDateTime ?? start.add(const Duration(hours: 1));

    final campusScheduleItem = CampusEventScheduleItem(
      type: 'campus_event',
      eventId: event.eventId,
      title: event.title,
      description: event.description,
      eventType: event.eventType,
      startDatetime: start.toUtc().toIso8601String(),
      endDatetime: end.toUtc().toIso8601String(),
      location: event.location,
      color: event.color,
      isMandatory: event.isMandatory,
      registrationRequired: event.registrationRequired,
    );

    return UnifiedScheduleItem(
      id: 'campus-${event.eventId}',
      kind: ScheduleItemKind.campusEvent,
      date: toISODate(start),
      startTime: normalizeTime(start.toUtc().toIso8601String()),
      endTime: normalizeTime(end.toUtc().toIso8601String()),
      title: event.title,
      subtitle: event.eventType,
      location: (event.location ?? '').trim().isEmpty ? 'TBD' : event.location,
      color: event.color.trim().isEmpty ? '#10b981' : event.color,
      campusEventItem: campusScheduleItem,
      isMandatory: event.isMandatory,
      registrationRequired: event.registrationRequired,
    );
  }

  int? _resolvePersonalEventId(String eventId, {int? fallback}) {
    CalendarEventRef? ref;
    for (final event in state.events) {
      if (event.id == eventId) {
        ref = CalendarEventRef(event.eventId, event.id);
        break;
      }
    }

    if (ref?.eventId != null) {
      return ref!.eventId;
    }

    if (fallback != null) {
      return fallback;
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

  DateTime _combineDateAndTime(DateTime date, String? text) {
    final parsed = _parseTime(text);
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

  String _mapTypeToApi(InstructorEventType type) {
    switch (type) {
      case InstructorEventType.lecture:
        return 'LECTURE';
      case InstructorEventType.lab:
        return 'LAB';
      case InstructorEventType.officeHours:
        return 'OFFICE_HOURS';
      case InstructorEventType.meeting:
        return 'MEETING';
      case InstructorEventType.deadline:
        return 'DEADLINE';
      case InstructorEventType.grading:
        return 'GRADING';
      case InstructorEventType.exam:
        return 'EXAM';
    }
  }

  String _resolveColor(InstructorEventType type) {
    switch (type) {
      case InstructorEventType.lecture:
        return '#155CFB';
      case InstructorEventType.lab:
        return '#7C3AED';
      case InstructorEventType.officeHours:
        return '#059669';
      case InstructorEventType.meeting:
        return '#F59E0B';
      case InstructorEventType.deadline:
        return '#EF4444';
      case InstructorEventType.grading:
        return '#0EA5E9';
      case InstructorEventType.exam:
        return '#EC4899';
    }
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

class CalendarEventRef {
  final int? eventId;
  final String id;

  const CalendarEventRef(this.eventId, this.id);
}
