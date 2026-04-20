import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/admin/admin_periods_models.dart';
import '../../models/schedule/schedule_models.dart';
import '../../services/api/office_hours_service.dart';
import '../../services/api/schedule_api_service.dart';
import '../schedule/schedule_item_builder.dart';
import 'ta_calendar_state.dart';

class TACalendarCubit extends Cubit<TACalendarState> {
  final ScheduleApiService _scheduleService;
  final OfficeHoursService _officeHoursService;

  TACalendarCubit({
    required ScheduleApiService scheduleService,
    required OfficeHoursService officeHoursService,
  }) : _scheduleService = scheduleService,
       _officeHoursService = officeHoursService,
       super(const TACalendarState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadSchedule();
  }

  Future<void> loadSchedule() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    List<DailyScheduleResponse> days = const <DailyScheduleResponse>[];

    if (state.viewType == TACalendarViewType.day) {
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
    } else if (state.viewType == TACalendarViewType.week) {
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

    final officeSlots = await _loadOfficeHoursSlots();
    final items = ScheduleItemBuilder.build(
      days: days,
      officeHoursSlots: officeSlots,
      startDate: toISODate(startOfWeek(state.selectedDate)),
      endDate: toISODate(endOfWeek(state.selectedDate)),
    );

    emit(state.copyWith(isLoading: false, rawDays: days, unifiedItems: items));
  }

  Future<List<OfficeHourSlotModel>> _loadOfficeHoursSlots() async {
    try {
      final result = await _officeHoursService.getSlots(page: 1, limit: 200);
      return result.items;
    } catch (_) {
      return const <OfficeHourSlotModel>[];
    }
  }

  void setView(String view) {
    final normalized = view.trim().toLowerCase();
    TACalendarViewType next;

    switch (normalized) {
      case 'week':
        next = TACalendarViewType.week;
        break;
      case 'day':
        next = TACalendarViewType.day;
        break;
      default:
        next = TACalendarViewType.month;
    }

    emit(state.copyWith(viewType: next));
    loadSchedule();
  }

  void setViewType(TACalendarViewType viewType) {
    emit(state.copyWith(viewType: viewType));
    loadSchedule();
  }

  void toggleFilter(String filterId) {
    final next = Set<String>.from(state.activeFilters);
    if (next.contains(filterId)) {
      next.remove(filterId);
    } else {
      next.add(filterId);
    }

    emit(state.copyWith(activeFilters: next));
  }

  void selectDate(DateTime date) {
    emit(state.copyWith(selectedDate: date));
    loadSchedule();
  }

  void setFocusedMonth(DateTime month) {
    emit(state.copyWith(focusedMonth: month));
    if (state.viewType == TACalendarViewType.month) {
      loadSchedule();
    }
  }

  void previousMonth() {
    final newMonth = DateTime(
      state.focusedMonth.year,
      state.focusedMonth.month - 1,
    );
    emit(state.copyWith(focusedMonth: newMonth));
    if (state.viewType == TACalendarViewType.month) {
      loadSchedule();
    }
  }

  void nextMonth() {
    final newMonth = DateTime(
      state.focusedMonth.year,
      state.focusedMonth.month + 1,
    );
    emit(state.copyWith(focusedMonth: newMonth));
    if (state.viewType == TACalendarViewType.month) {
      loadSchedule();
    }
  }

  void goToToday() {
    final now = DateTime.now();
    emit(state.copyWith(selectedDate: now, focusedMonth: now));
    loadSchedule();
  }

  Future<void> syncCalendar() async {
    await loadSchedule();
    emit(state.copyWith(successMessage: 'Calendar synced'));
    _clearSuccess();
  }

  Future<void> addEvent({
    required String title,
    required String type,
    required DateTime date,
    String? startTime,
    String? endTime,
    String? location,
    String? description,
  }) async {
    if (title.trim().isEmpty) {
      emit(state.copyWith(error: 'Event title is required'));
      _clearError();
      return;
    }

    emit(state.copyWith(isLoading: true));

    final start = _combineDateAndTime(date, startTime);
    final end = endTime == null || endTime.trim().isEmpty
        ? start.add(const Duration(hours: 1))
        : _combineDateAndTime(date, endTime);

    final payload = <String, dynamic>{
      'title': title.trim(),
      'eventType': _mapFilterToApi(type),
      'startTime': start.toUtc().toIso8601String(),
      'endTime': end.toUtc().toIso8601String(),
      'color': _resolveColor(type),
    };

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
    emit(state.copyWith(successMessage: 'Event added'));
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
    emit(state.copyWith(successMessage: 'Event deleted'));
    _clearSuccess();
  }

  int? _resolvePersonalEventId(String eventId) {
    for (final item in state.unifiedItems) {
      if (item.id == eventId && item.eventItem?.eventId != null) {
        return item.eventItem!.eventId;
      }
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

  DateTime _combineDateAndTime(DateTime date, String? value) {
    final parsed = _parseTime(value);
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

  String _mapFilterToApi(String filterType) {
    switch (filterType) {
      case 'lab':
        return 'LAB';
      case 'grading':
        return 'DEADLINE';
      case 'office_hours':
        return 'OFFICE_HOURS';
      case 'meetings':
        return 'MEETING';
      default:
        return 'PERSONAL';
    }
  }

  String _resolveColor(String filterType) {
    switch (filterType) {
      case 'lab':
        return '#0EA5E9';
      case 'grading':
        return '#F59E0B';
      case 'office_hours':
        return '#059669';
      case 'meetings':
        return '#155CFB';
      default:
        return '#8B5CF6';
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
