import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/calendar/calendar_cubit.dart';
import 'package:edu_verse/bloc/calendar/calendar_state.dart';
import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/models/schedule/schedule_models.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/schedule_api_service.dart';

class _FakeScheduleApiService extends ScheduleApiService {
  _FakeScheduleApiService() : super(coreApiClient: CoreApiClient.test());

  ServiceResult<DailyScheduleResponse> dailyResult = ServiceResult.success(
    _daily('2026-04-21'),
  );

  ServiceResult<WeeklyScheduleResponse> weeklyResult = ServiceResult.success(
    WeeklyScheduleResponse(
      weekStart: '2026-04-20',
      weekEnd: '2026-04-26',
      days: <DailyScheduleResponse>[_daily('2026-04-21')],
    ),
  );

  ServiceResult<List<DailyScheduleResponse>> monthResult =
      ServiceResult.success(<DailyScheduleResponse>[_daily('2026-04-21')]);

  ServiceResult<PersonalEventItem> createResult = ServiceResult.success(
    const PersonalEventItem(
      type: 'event',
      eventId: 77,
      title: 'Created',
      eventType: 'ASSIGNMENT',
      startTime: '2026-04-21T09:00:00Z',
      endTime: '2026-04-21T10:00:00Z',
      color: '#f59e0b',
    ),
  );

  ServiceResult<void> deleteResult = ServiceResult<void>.success(null);

  int monthCalls = 0;
  int dailyCalls = 0;
  int weeklyCalls = 0;

  Map<String, dynamic>? lastCreatePayload;

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
    return deleteResult;
  }
}

DailyScheduleResponse _daily(String date) {
  return DailyScheduleResponse(
    date: date,
    dayOfWeek: 'TUESDAY',
    schedules: <ClassScheduleItem>[
      ClassScheduleItem(
        type: 'class',
        id: 10,
        sectionId: 2,
        dayOfWeek: 'TUESDAY',
        startTime: '10:00:00',
        endTime: '11:00:00',
        scheduleType: 'LECTURE',
        section: ClassScheduleSection(
          id: 2,
          sectionNumber: 'A',
          course: const CourseBasic(
            courseId: 101,
            courseCode: 'CS101',
            courseName: 'Intro to CS',
          ),
        ),
      ),
    ],
    events: const <PersonalEventItem>[],
    exams: const <ExamScheduleItem>[],
    campusEvents: const <CampusEventScheduleItem>[],
  );
}

Future<void> _flush() async {
  await Future<void>.delayed(const Duration(milliseconds: 40));
}

void main() {
  group('CalendarCubit schedule migration', () {
    test('initializes and loads month schedule', () async {
      final scheduleService = _FakeScheduleApiService();
      final cubit = CalendarCubit(scheduleService: scheduleService);

      await _flush();

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.unifiedItems, isNotEmpty);
      expect(scheduleService.monthCalls, greaterThanOrEqualTo(1));

      await cubit.close();
    });

    test('addEvent maps EventType to API payload', () async {
      final scheduleService = _FakeScheduleApiService();
      final cubit = CalendarCubit(scheduleService: scheduleService);

      await _flush();

      await cubit.addEvent(
        title: 'Homework Session',
        type: EventType.assignment,
        date: DateTime(2026, 4, 21),
        time: '8:30 AM',
        endTime: '9:30 AM',
      );

      expect(scheduleService.lastCreatePayload, isNotNull);
      expect(scheduleService.lastCreatePayload!['title'], 'Homework Session');
      expect(scheduleService.lastCreatePayload!['eventType'], 'ASSIGNMENT');
      expect(cubit.state.successMessage, isNotNull);

      await cubit.close();
    });

    test('kind and course filters narrow the visible list', () async {
      final scheduleService = _FakeScheduleApiService();
      final cubit = CalendarCubit(scheduleService: scheduleService);

      await _flush();

      cubit.setKindFilter(ScheduleItemKind.classSession);
      cubit.setCourseFilter('CS101');

      final filtered = cubit.state.filteredItems;
      expect(filtered, isNotEmpty);
      expect(
        filtered.every((item) => item.kind == ScheduleItemKind.classSession),
        isTrue,
      );
      expect(filtered.every((item) => item.courseCode == 'CS101'), isTrue);

      await cubit.close();
    });

    test(
      'deleteEvent returns user-facing error for non-personal ids',
      () async {
        final scheduleService = _FakeScheduleApiService();
        final cubit = CalendarCubit(scheduleService: scheduleService);

        await _flush();
        await cubit.deleteEvent('campus-12');

        expect(cubit.state.error, 'Only personal events can be deleted');

        await cubit.close();
      },
    );

    test('day view triggers daily endpoint', () async {
      final scheduleService = _FakeScheduleApiService();
      final cubit = CalendarCubit(scheduleService: scheduleService);

      await _flush();
      final before = scheduleService.dailyCalls;

      cubit.setViewType(CalendarViewType.day);
      await _flush();

      expect(scheduleService.dailyCalls, greaterThan(before));

      await cubit.close();
    });
  });
}
