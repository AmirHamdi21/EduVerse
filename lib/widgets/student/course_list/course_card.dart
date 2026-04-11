import 'package:flutter/material.dart';

import '../../../models/core/enrollment_model.dart';
import '../../../models/core/schedule_model.dart';

class CourseCard extends StatelessWidget {
  final CourseEnrollmentModel enrollment;
  final VoidCallback? onTap;

  const CourseCard({super.key, required this.enrollment, this.onTap});

  String _dayLabel(ScheduleModel schedule) {
    final value = schedule.dayOfWeek.toJson();
    if (value.isEmpty) {
      return 'Day';
    }
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  String _scheduleLabel() {
    final schedules = enrollment.section?.schedules;
    if (schedules == null || schedules.isEmpty) {
      return 'Schedule TBD';
    }

    final first = schedules.first;
    final start = first.startTime.isNotEmpty ? first.startTime : '--:--';
    final end = first.endTime.isNotEmpty ? first.endTime : '--:--';
    return '${_dayLabel(first)} $start - $end';
  }

  @override
  Widget build(BuildContext context) {
    final course = enrollment.course;
    final code = course?.courseCode ?? 'COURSE';
    final name = course?.courseName ?? 'Untitled Course';
    final instructor = course?.departmentName ?? 'Instructor TBA';
    final section = enrollment.section?.sectionNumber;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      '$code • $name',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (section != null && section.isNotEmpty)
                    Text(
                      'Sec $section',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                instructor,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Row(
                children: <Widget>[
                  const Icon(Icons.schedule, size: 16, color: Colors.black54),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _scheduleLabel(),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    child: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
