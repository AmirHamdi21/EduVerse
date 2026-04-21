import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/instructor/instructor_calendar_cubit.dart';
import 'package:edu_verse/bloc/instructor/instructor_calendar_state.dart';
import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/models/admin/admin_periods_models.dart';
import 'package:edu_verse/models/schedule/schedule_models.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/office_hours_service.dart';
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

  ServiceResult<PaginatedResult<CampusEventModel>> myCampusResult =
      ServiceResult.success(
        PaginatedResult<CampusEventModel>(
          items: <CampusEventModel>[
            CampusEventModel(
              eventId: 99,
              title: 'My Campus Event',
              description: 'Instructor-specific campus event',
              eventType: 'GENERAL',
              scopeId: null,
              startDateTime: DateTime(2026, 4, 22, 16),
              endDateTime: DateTime(2026, 4, 22, 18),
              location: 'Main Hall',
              building: null,
              room: null,
              isMandatory: false,
              registrationRequired: true,
              maxAttendees: null,
              color: '#10b981',
              status: 'published',
              tags: const <String>[],
              registrationCount: 0,
              spotsRemaining: null,
            ),
          ],
          meta: const PaginationMeta(
            page: 1,
            limit: 100,
            total: 1,
            totalPages: 1,
          ),
        ),
      );

  int monthCalls = 0;
  int myCampusCalls = 0;

  @override
  Future<ServiceResult<DailyScheduleResponse>> getDailySchedule({
    String? date,
  }) async {
    return dailyResult;
  }

  @override
  Future<ServiceResult<WeeklyScheduleResponse>> getWeeklySchedule({
    String? startDate,
  }) async {
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
  Future<ServiceResult<PaginatedResult<CampusEventModel>>> getMyCampusEvents({
    int page = 1,
    int limit = 10,
  }) async {
    myCampusCalls += 1;
    return myCampusResult;
  }
}

class _FakeOfficeHoursService extends OfficeHoursService {
  _FakeOfficeHoursService() : super(coreApiClient: CoreApiClient.test());

  @override
  Future<PaginatedResult<OfficeHourSlotModel>> getSlots({
    int page = 1,
    int limit = 10,
    int? instructorId,
    String? dayOfWeek,
  }) async {
    return const PaginatedResult<OfficeHourSlotModel>(
      items: <OfficeHourSlotModel>[],
      meta: PaginationMeta(),
    );
  }
}

DailyScheduleResponse _daily(String date) {
  return DailyScheduleResponse(
    date: date,
    dayOfWeek: 'TUESDAY',
    schedules: const <ClassScheduleItem>[],
    events: const <PersonalEventItem>[],
    exams: const <ExamScheduleItem>[],
    campusEvents: <CampusEventScheduleItem>[
      const CampusEventScheduleItem(
        type: 'campus_event',
        eventId: 44,
        title: 'Global Campus Event',
        description: 'Shown in all source mode',
        eventType: 'GENERAL',
        startDatetime: '2026-04-21T16:00:00Z',
        endDatetime: '2026-04-21T17:00:00Z',
        location: 'Auditorium',
        color: '#10b981',
        isMandatory: false,
        registrationRequired: false,
      ),
    ],
  );
}

Future<void> _flush() async {
  await Future<void>.delayed(const Duration(milliseconds: 50));
}

void main() {
  group('InstructorCalendarCubit schedule migration', () {
    test('initializes and loads month schedule', () async {
      final scheduleService = _FakeScheduleApiService();
      final cubit = InstructorCalendarCubit(
        scheduleService: scheduleService,
        officeHoursService: _FakeOfficeHoursService(),
      );

      await _flush();

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.unifiedItems, isNotEmpty);
      expect(scheduleService.monthCalls, greaterThanOrEqualTo(1));

      await cubit.close();
    });

    test(
      'campus source my replaces campus items using /campus-events/my',
      () async {
        final scheduleService = _FakeScheduleApiService();
        final cubit = InstructorCalendarCubit(
          scheduleService: scheduleService,
          officeHoursService: _FakeOfficeHoursService(),
        );

        await _flush();

        cubit.setCampusSource('my');
        await _flush();

        expect(cubit.state.campusSource, 'my');
        expect(scheduleService.myCampusCalls, greaterThanOrEqualTo(1));

        final campusItems = cubit.state.unifiedItems
            .where((item) => item.kind == ScheduleItemKind.campusEvent)
            .toList(growable: false);

        expect(campusItems.length, 1);
        expect(campusItems.first.id, 'campus-99');
        expect(campusItems.first.title, 'My Campus Event');

        await cubit.close();
      },
    );

    test('kind and course filters update state', () async {
      final scheduleService = _FakeScheduleApiService();
      scheduleService.monthResult = ServiceResult.success(
        <DailyScheduleResponse>[
          DailyScheduleResponse(
            date: '2026-04-21',
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
          ),
        ],
      );

      final cubit = InstructorCalendarCubit(
        scheduleService: scheduleService,
        officeHoursService: _FakeOfficeHoursService(),
      );

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

    test('invalid campus source is ignored', () async {
      final scheduleService = _FakeScheduleApiService();
      final cubit = InstructorCalendarCubit(
        scheduleService: scheduleService,
        officeHoursService: _FakeOfficeHoursService(),
      );

      await _flush();

      cubit.setCampusSource('invalid');
      await _flush();

      expect(cubit.state.campusSource, 'all');

      await cubit.close();
    });

    test('my campus fetch failure keeps existing campus list', () async {
      final scheduleService = _FakeScheduleApiService();
      scheduleService.myCampusResult = ServiceResult.failure(
        const ServiceError(
          type: ServiceErrorType.server,
          message: 'campus my failed',
        ),
      );

      final cubit = InstructorCalendarCubit(
        scheduleService: scheduleService,
        officeHoursService: _FakeOfficeHoursService(),
      );

      await _flush();

      final beforeCount = cubit.state.unifiedItems
          .where((item) => item.kind == ScheduleItemKind.campusEvent)
          .length;

      cubit.setCampusSource('my');
      await _flush();

      final afterCount = cubit.state.unifiedItems
          .where((item) => item.kind == ScheduleItemKind.campusEvent)
          .length;

      expect(beforeCount, greaterThanOrEqualTo(1));
      expect(afterCount, equals(beforeCount));

      await cubit.close();
    });
  });
}
