import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/ta/ta_calendar_cubit.dart';
import 'package:edu_verse/bloc/ta/ta_calendar_state.dart';
import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/models/admin/admin_periods_models.dart';
import 'package:edu_verse/models/schedule/schedule_models.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/office_hours_service.dart';
import 'package:edu_verse/services/api/schedule_api_service.dart';

class _FakeScheduleApiService extends ScheduleApiService {
  _FakeScheduleApiService() : super(coreApiClient: CoreApiClient.test());

  ServiceResult<DailyScheduleResponse> dailyResult = ServiceResult.success(
    _daily('2026-04-21', eventId: 21),
  );

  ServiceResult<WeeklyScheduleResponse> weeklyResult = ServiceResult.success(
    WeeklyScheduleResponse(
      weekStart: '2026-04-20',
      weekEnd: '2026-04-26',
      days: <DailyScheduleResponse>[_daily('2026-04-21', eventId: 21)],
    ),
  );

  ServiceResult<List<DailyScheduleResponse>> monthResult =
      ServiceResult.success(<DailyScheduleResponse>[
        _daily('2026-04-21', eventId: 21),
      ]);

  ServiceResult<PersonalEventItem> createResult = ServiceResult.success(
    const PersonalEventItem(
      type: 'event',
      eventId: 77,
      title: 'Created',
      eventType: 'LAB',
      startTime: '2026-04-21T09:00:00Z',
      endTime: '2026-04-21T10:00:00Z',
      color: '#0EA5E9',
    ),
  );

  ServiceResult<void> deleteResult = ServiceResult<void>.success(null);

  int monthCalls = 0;
  int dailyCalls = 0;
  int weeklyCalls = 0;

  Map<String, dynamic>? lastCreatePayload;
  int? lastDeleteEventId;

  @override
  Future<ServiceResult<DailyScheduleResponse>> getDailySchedule({
    String? date,
  }) async {
    dailyCalls += 1;
    return dailyResult;
  }

  @override
  Future<ServiceResult<WeeklyScheduleResponse>> getWeeklySchedule({
    String? startDate,
  }) async {
    weeklyCalls += 1;
    return weeklyResult;
  }

  @override
  Future<ServiceResult<List<DailyScheduleResponse>>> getMonthSchedule(
    DateTime referenceDate,
  ) async {
    monthCalls += 1;
    return monthResult;
  }

  @override
  Future<ServiceResult<PersonalEventItem>> createCalendarEvent(
    Map<String, dynamic> data,
  ) async {
    lastCreatePayload = Map<String, dynamic>.from(data);
    return createResult;
  }

  @override
  Future<ServiceResult<void>> deleteCalendarEvent(int eventId) async {
    lastDeleteEventId = eventId;
    return deleteResult;
  }
}

class _FakeOfficeHoursService extends OfficeHoursService {
  _FakeOfficeHoursService() : super(coreApiClient: CoreApiClient.test());

  PaginatedResult<OfficeHourSlotModel> slots = const PaginatedResult(
    items: <OfficeHourSlotModel>[],
    meta: PaginationMeta(),
  );

  @override
  Future<PaginatedResult<OfficeHourSlotModel>> getSlots({
    int page = 1,
    int limit = 10,
    int? instructorId,
    String? dayOfWeek,
  }) async {
    return slots;
  }
}

DailyScheduleResponse _daily(String date, {required int eventId}) {
  return DailyScheduleResponse(
    date: date,
    dayOfWeek: 'TUESDAY',
    schedules: const <ClassScheduleItem>[],
    events: <PersonalEventItem>[
      PersonalEventItem(
        type: 'event',
        eventId: eventId,
        title: 'TA Event $eventId',
        eventType: 'MEETING',
        startTime: '09:00:00',
        endTime: '10:00:00',
        location: 'Lab Room',
        color: '#155CFB',
      ),
    ],
    exams: const <ExamScheduleItem>[],
    campusEvents: const <CampusEventScheduleItem>[],
  );
}

Future<void> _flush() async {
  await Future<void>.delayed(const Duration(milliseconds: 40));
}

void main() {
  group('TACalendarCubit', () {
    test('initializes and loads month schedule', () async {
      final scheduleService = _FakeScheduleApiService();
      final cubit = TACalendarCubit(
        scheduleService: scheduleService,
        officeHoursService: _FakeOfficeHoursService(),
      );

      await _flush();

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.unifiedItems, isNotEmpty);
      expect(scheduleService.monthCalls, greaterThanOrEqualTo(1));

      await cubit.close();
    });

    test('addEvent maps filter type and sends payload to API', () async {
      final scheduleService = _FakeScheduleApiService();
      final cubit = TACalendarCubit(
        scheduleService: scheduleService,
        officeHoursService: _FakeOfficeHoursService(),
      );

      await _flush();

      await cubit.addEvent(
        title: 'TA Lab Prep',
        type: 'lab',
        date: DateTime(2026, 4, 21),
        startTime: '9:15 AM',
        endTime: '10:15 AM',
        location: 'Lab 2',
      );

      expect(scheduleService.lastCreatePayload, isNotNull);
      expect(scheduleService.lastCreatePayload!['title'], 'TA Lab Prep');
      expect(scheduleService.lastCreatePayload!['eventType'], 'LAB');
      expect(scheduleService.lastCreatePayload!['location'], 'Lab 2');
      expect(cubit.state.successMessage, isNotNull);

      await cubit.close();
    });

    test(
      'deleteEvent uses resolved personal id and rejects non-personal ids',
      () async {
        final scheduleService = _FakeScheduleApiService();
        final cubit = TACalendarCubit(
          scheduleService: scheduleService,
          officeHoursService: _FakeOfficeHoursService(),
        );

        await _flush();

        await cubit.deleteEvent('event-21-2026-04-21');
        expect(scheduleService.lastDeleteEventId, 21);

        scheduleService.deleteResult = ServiceResult<void>.failure(
          const ServiceError(
            type: ServiceErrorType.server,
            message: 'delete failed',
          ),
        );

        await cubit.deleteEvent('campus-99');
        expect(cubit.state.error, 'Only personal events can be deleted');

        await cubit.close();
      },
    );

    test('setView day loads daily schedule', () async {
      final scheduleService = _FakeScheduleApiService();
      final cubit = TACalendarCubit(
        scheduleService: scheduleService,
        officeHoursService: _FakeOfficeHoursService(),
      );

      await _flush();
      final before = scheduleService.dailyCalls;

      cubit.setView('day');
      await _flush();

      expect(cubit.state.viewType, TACalendarViewType.day);
      expect(scheduleService.dailyCalls, greaterThan(before));

      await cubit.close();
    });
  });
}
