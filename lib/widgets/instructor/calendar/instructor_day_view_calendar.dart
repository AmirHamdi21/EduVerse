import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/instructor/instructor_calendar_cubit.dart';
import '../../../bloc/instructor/instructor_calendar_state.dart';

class InstructorDayViewCalendar extends StatelessWidget {
  final Function(InstructorCalendarEvent) onEventTap;

  const InstructorDayViewCalendar({
    super.key,
    required this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeBloc>().state;
    final isDark = themeState.isDark;

    return BlocBuilder<InstructorCalendarCubit, InstructorCalendarState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
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
              _buildDayHeader(context, state, isDark),
              const Divider(height: 1),
              _buildTimelineView(context, state, isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDayHeader(
      BuildContext context, InstructorCalendarState state, bool isDark) {
    final date = state.selectedDate;
    final dayNames = [
      'Sunday', 'Monday', 'Tuesday', 'Wednesday',
      'Thursday', 'Friday', 'Saturday'
    ];
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              final newDate =
                  state.selectedDate.subtract(const Duration(days: 1));
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
                dayNames[date.weekday % 7],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${monthNames[date.month - 1]} ${date.day}, ${date.year}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              final newDate = state.selectedDate.add(const Duration(days: 1));
              context.read<InstructorCalendarCubit>().selectDate(newDate);
            },
            icon: Icon(
              Icons.chevron_right_rounded,
              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineView(
      BuildContext context, InstructorCalendarState state, bool isDark) {
    final events = state.selectedDateEvents;
    final hours = List.generate(14, (i) => i + 7); // 7 AM to 8 PM

    return SizedBox(
      height: 400,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: hours.map((hour) {
            final hourEvents = events.where((e) {
              if (e.time == null) return false;
              final eventHour = int.tryParse(e.time!.split(':')[0]) ?? 0;
              return eventHour == hour;
            }).toList();

            return Container(
              height: 60,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? const Color(0xFF374151)
                        : const Color(0xFFE5E7EB),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    padding: const EdgeInsets.only(top: 8, left: 12),
                    child: Text(
                      '${hour.toString().padLeft(2, '0')}:00',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  Expanded(
                    child: hourEvents.isEmpty
                        ? const SizedBox()
                        : Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: hourEvents.map((event) {
                                return GestureDetector(
                                  onTap: () => onEventTap(event),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 4),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: _getEventColor(event.type),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            event.title,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (event.location != null) ...[
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.location_on_outlined,
                                            size: 14,
                                            color: Colors.white.withValues(alpha: 0.8),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
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
}
