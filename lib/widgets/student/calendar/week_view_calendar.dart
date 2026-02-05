import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/calendar/calendar_cubit.dart';
import 'package:edu_verse/bloc/calendar/calendar_state.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class WeekViewCalendar extends StatelessWidget {
  final Function(DateTime, List<CalendarEvent>) onDateTap;

  const WeekViewCalendar({
    super.key,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeState = context.watch<ThemeBloc>().state;
    final isDark = themeState.isDark;

    return BlocBuilder<CalendarCubit, CalendarState>(
      builder: (context, state) {
        final weekDays = _getWeekDays(state.selectedDate);

        return Column(
          children: [
            _buildWeekNavigation(context, state, l10n, isDark),
            const SizedBox(height: 12),
            _buildWeekDaysRow(context, state, weekDays, isDark),
            const SizedBox(height: 16),
            _buildTimeSlots(context, state, weekDays, isDark),
          ],
        );
      },
    );
  }

  Widget _buildWeekNavigation(
    BuildContext context,
    CalendarState state,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final weekStart = _getWeekStart(state.selectedDate);
    final weekEnd = weekStart.add(const Duration(days: 6));
    final dateFormat = DateFormat('MMM d');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              final newDate = state.selectedDate.subtract(const Duration(days: 7));
              context.read<CalendarCubit>().selectDate(newDate);
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2939) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.chevron_left_rounded,
                color: isDark ? const Color(0xFF99A1AF) : const Color(0xFF6B7280),
              ),
            ),
          ),
          Text(
            '${dateFormat.format(weekStart)} - ${dateFormat.format(weekEnd)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFF3F4F6) : const Color(0xFF101828),
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  final newDate = state.selectedDate.add(const Duration(days: 7));
                  context.read<CalendarCubit>().selectDate(newDate);
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2939) : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: isDark ? const Color(0xFF99A1AF) : const Color(0xFF6B7280),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => context.read<CalendarCubit>().goToToday(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2939) : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Text(
                    l10n.today,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFFD1D5DC) : const Color(0xFF374151),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDaysRow(
    BuildContext context,
    CalendarState state,
    List<DateTime> weekDays,
    bool isDark,
  ) {
    final today = DateTime.now();
    final dayFormat = DateFormat('EEE');
    final dateFormat = DateFormat('d');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: weekDays.map((date) {
          final isToday = date.year == today.year &&
              date.month == today.month &&
              date.day == today.day;
          final isSelected = date.year == state.selectedDate.year &&
              date.month == state.selectedDate.month &&
              date.day == state.selectedDate.day;
          final hasEvents = state.hasEventsOnDate(date);
          final events = state.getEventsForDate(date);

          return Expanded(
            child: GestureDetector(
              onTap: () {
                context.read<CalendarCubit>().selectDate(date);
                if (events.isNotEmpty) {
                  onDateTap(date, events);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2B7FFF)
                      : (isDark ? const Color(0xFF1E2939) : const Color(0xFFF9FAFB)),
                  borderRadius: BorderRadius.circular(12),
                  border: isToday && !isSelected
                      ? Border.all(color: const Color(0xFF2B7FFF), width: 1.5)
                      : null,
                ),
                child: Column(
                  children: [
                    Text(
                      dayFormat.format(date),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white70
                            : (isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(date),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? const Color(0xFFF3F4F6) : const Color(0xFF101828)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (hasEvents)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : const Color(0xFFF59E0B),
                          shape: BoxShape.circle,
                        ),
                      )
                    else
                      const SizedBox(height: 6),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimeSlots(
    BuildContext context,
    CalendarState state,
    List<DateTime> weekDays,
    bool isDark,
  ) {
    final selectedDateEvents = state.selectedDateEvents;

    if (selectedDateEvents.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.event_available_rounded,
                size: 48,
                color: isDark ? const Color(0xFF374151) : const Color(0xFFD1D5DC),
              ),
              const SizedBox(height: 12),
              Text(
                'No events on this day',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: selectedDateEvents.map((event) {
          return _buildEventCard(context, event, isDark);
        }).toList(),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, CalendarEvent event, bool isDark) {
    return GestureDetector(
      onTap: () {
        context.read<CalendarCubit>().showEventDetails(event);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2939) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 50,
              decoration: BoxDecoration(
                color: _getEventTypeColor(event.type),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFF3F4F6) : const Color(0xFF101828),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.time ?? 'All day',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? const Color(0xFF99A1AF) : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  List<DateTime> _getWeekDays(DateTime date) {
    final weekStart = _getWeekStart(date);
    return List.generate(7, (index) => weekStart.add(Duration(days: index)));
  }

  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday % 7; // Sunday = 0
    return DateTime(date.year, date.month, date.day - weekday);
  }

  Color _getEventTypeColor(EventType type) {
    switch (type) {
      case EventType.lecture:
        return const Color(0xFF2B7FFF);
      case EventType.lab:
        return const Color(0xFF10B981);
      case EventType.assignment:
        return const Color(0xFFF59E0B);
      case EventType.exam:
        return const Color(0xFFEF4444);
      case EventType.quiz:
        return const Color(0xFF8B5CF6);
      case EventType.personalTask:
        return const Color(0xFFEC4899);
    }
  }
}
