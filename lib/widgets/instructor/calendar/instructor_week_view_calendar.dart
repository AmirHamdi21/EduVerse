import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/instructor/instructor_calendar_cubit.dart';
import '../../../bloc/instructor/instructor_calendar_state.dart';

class InstructorWeekViewCalendar extends StatelessWidget {
  final Function(DateTime) onDateSelected;
  final Function(InstructorCalendarEvent) onEventTap;

  const InstructorWeekViewCalendar({
    super.key,
    required this.onDateSelected,
    required this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeBloc>().state;
    final isDark = themeState.isDark;

    return BlocBuilder<InstructorCalendarCubit, InstructorCalendarState>(
      builder: (context, state) {
        final weekDates = _getWeekDates(state.selectedDate);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2939) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildWeekHeader(context, state, isDark),
              const SizedBox(height: 16),
              _buildDaySelector(context, state, weekDates, isDark),
              const SizedBox(height: 16),
              _buildTimeSlots(context, state, isDark),
            ],
          ),
        );
      },
    );
  }

  List<DateTime> _getWeekDates(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday % 7));
    return List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
  }

  Widget _buildWeekHeader(
      BuildContext context, InstructorCalendarState state, bool isDark) {
    final weekDates = _getWeekDates(state.selectedDate);
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            final newDate =
                state.selectedDate.subtract(const Duration(days: 7));
            context.read<InstructorCalendarCubit>().selectDate(newDate);
          },
          icon: Icon(
            Icons.chevron_left_rounded,
            color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
          ),
        ),
        Column(
          children: [
            Text(
              '${monthNames[weekDates.first.month - 1]} ${weekDates.first.year}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            Text(
              'Week ${_getWeekNumber(state.selectedDate)}',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () {
            final newDate = state.selectedDate.add(const Duration(days: 7));
            context.read<InstructorCalendarCubit>().selectDate(newDate);
          },
          icon: Icon(
            Icons.chevron_right_rounded,
            color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
          ),
        ),
      ],
    );
  }

  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirst = date.difference(firstDayOfYear).inDays;
    return ((daysSinceFirst + firstDayOfYear.weekday) / 7).ceil();
  }

  Widget _buildDaySelector(
    BuildContext context,
    InstructorCalendarState state,
    List<DateTime> weekDates,
    bool isDark,
  ) {
    final dayNames = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final today = DateTime.now();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekDates.asMap().entries.map((entry) {
        final date = entry.value;
        final isSelected = date.year == state.selectedDate.year &&
            date.month == state.selectedDate.month &&
            date.day == state.selectedDate.day;
        final isToday = date.year == today.year &&
            date.month == today.month &&
            date.day == today.day;
        final hasEvents = state.hasEventsOnDate(date);

        return GestureDetector(
          onTap: () => onDateSelected(date),
          child: Column(
            children: [
              Text(
                dayNames[entry.key],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF155CFB)
                      : (isToday
                          ? const Color(0xFF155CFB).withValues(alpha: 0.1)
                          : Colors.transparent),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected || isToday
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : (isToday
                              ? const Color(0xFF155CFB)
                              : (isDark
                                  ? const Color(0xFFE2E8F0)
                                  : const Color(0xFF334155))),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              if (hasEvents)
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF155CFB)
                        : (isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B)),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimeSlots(
      BuildContext context, InstructorCalendarState state, bool isDark) {
    final events = state.selectedDateEvents;

    if (events.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.event_available_rounded,
              size: 48,
              color:
                  isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
            ),
            const SizedBox(height: 12),
            Text(
              'No events scheduled',
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: events.map((event) {
        return GestureDetector(
          onTap: () => onEventTap(event),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getEventColor(event.type).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getEventColor(event.type).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getEventColor(event.type),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      if (event.time != null)
                        Text(
                          '${event.time}${event.endTime != null ? ' - ${event.endTime}' : ''}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  _getEventIcon(event.type),
                  size: 20,
                  color: _getEventColor(event.type),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getEventColor(InstructorEventType type) {
    switch (type) {
      case InstructorEventType.lecture:
        return const Color(0xFF155CFB);
      case InstructorEventType.lab:
        return const Color(0xFF7C3AED);
      case InstructorEventType.officeHours:
        return const Color(0xFF059669);
      case InstructorEventType.meeting:
        return const Color(0xFFF59E0B);
      case InstructorEventType.deadline:
        return const Color(0xFFEF4444);
      case InstructorEventType.grading:
        return const Color(0xFF0EA5E9);
      case InstructorEventType.exam:
        return const Color(0xFFEC4899);
    }
  }

  IconData _getEventIcon(InstructorEventType type) {
    switch (type) {
      case InstructorEventType.lecture:
        return Icons.school_rounded;
      case InstructorEventType.lab:
        return Icons.science_rounded;
      case InstructorEventType.officeHours:
        return Icons.access_time_rounded;
      case InstructorEventType.meeting:
        return Icons.groups_rounded;
      case InstructorEventType.deadline:
        return Icons.flag_rounded;
      case InstructorEventType.grading:
        return Icons.grading_rounded;
      case InstructorEventType.exam:
        return Icons.quiz_rounded;
    }
  }
}
