import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/schedule/schedule_item_builder.dart';
import 'package:edu_verse/models/admin/admin_periods_models.dart';
import 'package:edu_verse/models/schedule/schedule_models.dart';

DailyScheduleResponse _sampleDay() {
  return DailyScheduleResponse(
    date: '2026-04-21',
    dayOfWeek: 'TUESDAY',
    schedules: <ClassScheduleItem>[
      ClassScheduleItem(
        type: 'class',
        id: 11,
        sectionId: 2,
        dayOfWeek: 'TUESDAY',
        startTime: '10:00:00',
        endTime: '11:30:00',
        room: '205',
        building: 'Science',
        scheduleType: 'LAB',
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
    events: <PersonalEventItem>[
      const PersonalEventItem(
        type: 'event',
        eventId: 22,
        title: 'Study Group',
        description: 'Chapter 3 review',
        eventType: 'MEETING',
        startTime: '12:00:00',
        endTime: '13:00:00',
        location: 'Library',
        color: '#155CFB',
      ),
    ],
    exams: <ExamScheduleItem>[
      const ExamScheduleItem(
        type: 'exam',
        examId: 33,
        courseId: 101,
        examType: 'midterm',
        title: 'Midterm',
        examDate: '2026-04-21',
        startTime: '14:00:00',
        durationMinutes: 90,
        location: 'Hall A',
        course: CourseBasic(
          courseId: 101,
          courseCode: 'CS101',
          courseName: 'Intro to CS',
        ),
      ),
    ],
    campusEvents: <CampusEventScheduleItem>[
      const CampusEventScheduleItem(
        type: 'campus_event',
        eventId: 44,
        title: 'Hackathon Kickoff',
        description: 'Main campus event',
        eventType: 'GENERAL',
        startDatetime: '2026-04-21T16:00:00Z',
        endDatetime: '2026-04-21T18:00:00Z',
        location: 'Auditorium',
        color: '#10b981',
        isMandatory: false,
        registrationRequired: true,
      ),
    ],
  );
}

OfficeHourSlotModel _officeSlot() {
  return const OfficeHourSlotModel(
    slotId: 1,
    instructorId: 19,
    dayOfWeek: 'TUESDAY',
    startTime: '08:00:00',
    endTime: '09:00:00',
    location: 'Room 9',
    mode: 'in_person',
    maxAppointments: 6,
    currentAppointments: 2,
    isActive: true,
    notes: null,
  );
}

void main() {
  group('ScheduleItemBuilder', () {
    test('build produces all item kinds in sorted order', () {
      final items = ScheduleItemBuilder.build(
        days: <DailyScheduleResponse>[_sampleDay()],
        officeHoursSlots: <OfficeHourSlotModel>[_officeSlot()],
        startDate: '2026-04-21',
        endDate: '2026-04-21',
      );

      expect(items.length, 5);
      expect(items.first.kind, ScheduleItemKind.officeHours);

      final kinds = items.map((item) => item.kind).toList(growable: false);
      expect(kinds, contains(ScheduleItemKind.classSession));
      expect(kinds, contains(ScheduleItemKind.event));
      expect(kinds, contains(ScheduleItemKind.exam));
      expect(kinds, contains(ScheduleItemKind.campusEvent));
      expect(kinds, contains(ScheduleItemKind.officeHours));
    });

    test('detectConflicts finds overlapping items on same date', () {
      const first = UnifiedScheduleItem(
        id: 'a',
        kind: ScheduleItemKind.classSession,
        date: '2026-04-21',
        startTime: '10:00',
        endTime: '11:00',
        title: 'Class A',
        color: '#3b82f6',
      );

      const second = UnifiedScheduleItem(
        id: 'b',
        kind: ScheduleItemKind.event,
        date: '2026-04-21',
        startTime: '10:30',
        endTime: '11:30',
        title: 'Event B',
        color: '#155CFB',
      );

      const third = UnifiedScheduleItem(
        id: 'c',
        kind: ScheduleItemKind.exam,
        date: '2026-04-21',
        startTime: '12:00',
        endTime: '13:00',
        title: 'Exam C',
        color: '#ef4444',
      );

      final conflicts = ScheduleItemBuilder.detectConflicts(
        const <UnifiedScheduleItem>[first, second, third],
      );

      expect(conflicts.length, 1);
      expect(conflicts.first.first.id, 'a');
      expect(conflicts.first.second.id, 'b');
    });

    test('upcoming excludes items from past dates', () {
      final yesterday = toISODate(
        DateTime.now().subtract(const Duration(days: 1)),
      );
      final tomorrow = toISODate(DateTime.now().add(const Duration(days: 1)));

      final items = <UnifiedScheduleItem>[
        UnifiedScheduleItem(
          id: 'past',
          kind: ScheduleItemKind.event,
          date: yesterday,
          startTime: '09:00',
          endTime: '10:00',
          title: 'Past',
          color: '#155CFB',
        ),
        UnifiedScheduleItem(
          id: 'future',
          kind: ScheduleItemKind.event,
          date: tomorrow,
          startTime: '09:00',
          endTime: '10:00',
          title: 'Future',
          color: '#155CFB',
        ),
      ];

      final upcoming = ScheduleItemBuilder.upcoming(items, limit: 10);

      expect(upcoming.length, 1);
      expect(upcoming.first.id, 'future');
    });
  });
}
