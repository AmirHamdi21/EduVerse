import 'dart:math' as math;

import 'package:equatable/equatable.dart';

import '../../models/admin/admin_periods_models.dart';
import '../../models/schedule/schedule_models.dart';

class ScheduleItemBuilder {
  static List<UnifiedScheduleItem> build({
    required List<DailyScheduleResponse> days,
    List<OfficeHourSlotModel>? officeHoursSlots,
    String? startDate,
    String? endDate,
  }) {
    final items = <UnifiedScheduleItem>[];

    for (final day in days) {
      for (final entry in day.schedules) {
        final course = entry.section?.course;
        final courseCode = _pickString(<String?>[course?.courseCode]);
        final courseName = _pickString(<String?>[course?.courseName]);

        final title = courseCode.isNotEmpty && courseName.isNotEmpty
            ? '$courseCode - $courseName'
            : (courseCode.isNotEmpty
                  ? courseCode
                  : (courseName.isNotEmpty ? courseName : 'Class Session'));

        final location = _joinNonEmpty(<String?>[entry.building, entry.room]);

        items.add(
          UnifiedScheduleItem(
            id: 'class-${entry.id}-${day.date}',
            kind: ScheduleItemKind.classSession,
            date: day.date,
            startTime: normalizeTime(entry.startTime),
            endTime: normalizeTime(entry.endTime),
            title: title,
            subtitle: _pickString(<String?>[
              entry.scheduleType,
            ], fallback: 'LECTURE').toUpperCase(),
            location: location.isEmpty ? 'TBD' : location,
            color: '#3b82f6',
            courseCode: courseCode.isEmpty ? null : courseCode,
            courseId: course?.courseId,
            classItem: entry,
          ),
        );
      }

      for (final entry in day.events) {
        items.add(
          UnifiedScheduleItem(
            id: 'event-${entry.eventId}-${day.date}',
            kind: ScheduleItemKind.event,
            date: day.date,
            startTime: normalizeTime(entry.startTime),
            endTime: normalizeTime(entry.endTime),
            title: _pickString(<String?>[
              entry.title,
            ], fallback: 'Untitled Event'),
            subtitle: _nullable(entry.eventType),
            location: _nullable(entry.location) ?? 'TBD',
            color: _pickString(<String?>[entry.color], fallback: '#8b5cf6'),
            courseCode: _nullable(entry.course?.courseCode),
            courseId: entry.course?.courseId,
            eventItem: entry,
          ),
        );
      }

      for (final exam in day.exams) {
        final startTime = normalizeTime(exam.startTime);
        final startMinutes = toMinutes(startTime);
        final endMinutes =
            startMinutes + math.max(exam.durationMinutes, 30).toInt();
        final endTime = _minutesToTime(endMinutes);

        final courseCode = _pickString(<String?>[exam.course.courseCode]);

        final upperExamType = _pickString(<String?>[
          exam.examType,
        ], fallback: 'EXAM').toUpperCase();

        final title = courseCode.isNotEmpty
            ? '$courseCode $upperExamType'
            : upperExamType;

        items.add(
          UnifiedScheduleItem(
            id: 'exam-${exam.examId}',
            kind: ScheduleItemKind.exam,
            date: _pickString(<String?>[
              exam.examDate,
              day.date,
            ], fallback: day.date),
            startTime: startTime,
            endTime: endTime,
            title: title,
            subtitle: _nullable(exam.title) ?? 'Exam',
            location: _nullable(exam.location) ?? 'TBD',
            color: '#ef4444',
            courseCode: _nullable(courseCode),
            courseId: exam.courseId,
            examItem: exam,
          ),
        );
      }

      for (final entry in day.campusEvents) {
        final parsed = DateTime.tryParse(entry.startDatetime);
        final resolvedDate = parsed == null
            ? day.date
            : toISODate(parsed.toLocal());

        items.add(
          UnifiedScheduleItem(
            id: 'campus-${entry.eventId}',
            kind: ScheduleItemKind.campusEvent,
            date: resolvedDate,
            startTime: normalizeTime(entry.startDatetime),
            endTime: normalizeTime(entry.endDatetime),
            title: _pickString(<String?>[
              entry.title,
            ], fallback: 'Campus Event'),
            subtitle: _nullable(entry.eventType),
            location: _nullable(entry.location) ?? 'TBD',
            color: _pickString(<String?>[entry.color], fallback: '#10b981'),
            campusEventItem: entry,
            isMandatory: entry.isMandatory,
            registrationRequired: entry.registrationRequired,
          ),
        );
      }
    }

    final slots = officeHoursSlots ?? const <OfficeHourSlotModel>[];
    if (slots.isNotEmpty) {
      final range = _resolveDateRange(
        days,
        startDate: startDate,
        endDate: endDate,
      );
      for (final slot in slots) {
        final dayIndex = _dayOfWeekIndex(slot.dayOfWeek);
        var cursor = range.start;

        while (!cursor.isAfter(range.end)) {
          if ((cursor.weekday % 7) == dayIndex) {
            final iso = toISODate(cursor);
            items.add(
              UnifiedScheduleItem(
                id: 'oh-${slot.slotId}-$iso',
                kind: ScheduleItemKind.officeHours,
                date: iso,
                startTime: normalizeTime(slot.startTime),
                endTime: normalizeTime(slot.endTime),
                title: 'Office Hours',
                subtitle: _nullable(slot.mode),
                location: _nullable(slot.location) ?? 'TBD',
                color: '#f59e0b',
                officeHoursSlot: slot,
              ),
            );
          }

          cursor = cursor.add(const Duration(days: 1));
        }
      }
    }

    items.sort((a, b) {
      final byDate = a.date.compareTo(b.date);
      if (byDate != 0) {
        return byDate;
      }
      return toMinutes(a.startTime).compareTo(toMinutes(b.startTime));
    });

    return items;
  }

  static List<ScheduleConflict> detectConflicts(
    List<UnifiedScheduleItem> items,
  ) {
    final grouped = <String, List<UnifiedScheduleItem>>{};

    for (final item in items) {
      grouped.putIfAbsent(item.date, () => <UnifiedScheduleItem>[]).add(item);
    }

    final conflicts = <ScheduleConflict>[];

    for (final entry in grouped.entries) {
      final date = entry.key;
      final dayItems = List<UnifiedScheduleItem>.from(entry.value)
        ..sort(
          (a, b) => toMinutes(a.startTime).compareTo(toMinutes(b.startTime)),
        );

      for (var i = 0; i < dayItems.length; i++) {
        final first = dayItems[i];
        final firstEnd = toMinutes(first.endTime);

        for (var j = i + 1; j < dayItems.length; j++) {
          final second = dayItems[j];
          final secondStart = toMinutes(second.startTime);

          if (secondStart >= firstEnd) {
            break;
          }

          conflicts.add(
            ScheduleConflict(date: date, first: first, second: second),
          );
        }
      }
    }

    return conflicts;
  }

  static List<UnifiedScheduleItem> upcoming(
    List<UnifiedScheduleItem> items, {
    int limit = 6,
  }) {
    final now = DateTime.now();
    final nowDate = toISODate(now);
    final nowMinutes = now.hour * 60 + now.minute;

    final filtered =
        items.where((item) {
          if (item.date.compareTo(nowDate) > 0) {
            return true;
          }
          if (item.date.compareTo(nowDate) < 0) {
            return false;
          }
          return toMinutes(item.endTime) >= nowMinutes;
        }).toList()..sort((a, b) {
          final byDate = a.date.compareTo(b.date);
          if (byDate != 0) {
            return byDate;
          }
          return toMinutes(a.startTime).compareTo(toMinutes(b.startTime));
        });

    if (limit < 1 || filtered.length <= limit) {
      return filtered;
    }

    return filtered.take(limit).toList(growable: false);
  }

  static List<UnifiedScheduleItem> filter(
    List<UnifiedScheduleItem> items, {
    ScheduleItemKind? kindFilter,
    String? courseFilter,
  }) {
    final normalizedCourse = (courseFilter ?? '').trim().toLowerCase();

    return items
        .where((item) {
          if (kindFilter != null && item.kind != kindFilter) {
            return false;
          }

          if (normalizedCourse.isNotEmpty) {
            final code = (item.courseCode ?? '').trim().toLowerCase();
            if (code != normalizedCourse) {
              return false;
            }
          }

          return true;
        })
        .toList(growable: false);
  }

  static List<String> extractCourseCodes(List<UnifiedScheduleItem> items) {
    final set = <String>{};

    for (final item in items) {
      final code = (item.courseCode ?? '').trim();
      if (code.isNotEmpty) {
        set.add(code);
      }
    }

    final result = set.toList(growable: false)..sort();
    return result;
  }
}

class ScheduleConflict extends Equatable {
  final String date;
  final UnifiedScheduleItem first;
  final UnifiedScheduleItem second;

  const ScheduleConflict({
    required this.date,
    required this.first,
    required this.second,
  });

  @override
  List<Object?> get props => <Object?>[date, first, second];
}

class _DateRange {
  final DateTime start;
  final DateTime end;

  const _DateRange({required this.start, required this.end});
}

_DateRange _resolveDateRange(
  List<DailyScheduleResponse> days, {
  String? startDate,
  String? endDate,
}) {
  final parsedStart = startDate == null ? null : DateTime.tryParse(startDate);
  final parsedEnd = endDate == null ? null : DateTime.tryParse(endDate);

  final fallbackDates =
      days
          .map((day) => DateTime.tryParse(day.date))
          .whereType<DateTime>()
          .map((date) => DateTime(date.year, date.month, date.day))
          .toList(growable: false)
        ..sort();

  final start = parsedStart != null
      ? DateTime(parsedStart.year, parsedStart.month, parsedStart.day)
      : (fallbackDates.isNotEmpty ? fallbackDates.first : DateTime.now());

  final end = parsedEnd != null
      ? DateTime(parsedEnd.year, parsedEnd.month, parsedEnd.day)
      : (fallbackDates.isNotEmpty
            ? fallbackDates.last
            : start.add(const Duration(days: 30)));

  if (end.isBefore(start)) {
    return _DateRange(start: end, end: start);
  }

  return _DateRange(start: start, end: end);
}

String _pickString(List<String?> values, {String fallback = ''}) {
  for (final value in values) {
    if (value != null && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return fallback;
}

String _joinNonEmpty(List<String?> values) {
  return values
      .whereType<String>()
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .join(' ')
      .trim();
}

String? _nullable(String? value) {
  if (value == null) {
    return null;
  }

  final output = value.trim();
  return output.isEmpty ? null : output;
}

String _minutesToTime(int totalMinutes) {
  final safe = totalMinutes < 0 ? 0 : totalMinutes;
  final hours = ((safe ~/ 60) % 24).toString().padLeft(2, '0');
  final minutes = (safe % 60).toString().padLeft(2, '0');
  return '$hours:$minutes';
}

int _dayOfWeekIndex(String value) {
  final normalized = value.trim().toUpperCase();
  switch (normalized) {
    case 'SUNDAY':
      return 0;
    case 'MONDAY':
      return 1;
    case 'TUESDAY':
      return 2;
    case 'WEDNESDAY':
      return 3;
    case 'THURSDAY':
      return 4;
    case 'FRIDAY':
      return 5;
    case 'SATURDAY':
      return 6;
    default:
      return 0;
  }
}
