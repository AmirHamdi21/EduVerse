import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/calendar/calendar_cubit.dart';
import 'package:edu_verse/bloc/calendar/calendar_state.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class MonthViewCalendar extends StatelessWidget {
  final void Function(DateTime date, List<CalendarEvent> events)? onDateTap;
  
  const MonthViewCalendar({super.key, this.onDateTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeState = context.watch<ThemeBloc>().state;
    final isDark = themeState.isDark;

    return BlocBuilder<CalendarCubit, CalendarState>(
      builder: (context, state) {
        return Column(
          children: [
            _buildMonthNavigation(context, state, l10n, isDark),
            _buildWeekdayHeaders(l10n, isDark),
            _buildCalendarGrid(context, state, isDark),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  Widget _buildMonthNavigation(
    BuildContext context,
    CalendarState state,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final monthYear = DateFormat('MMMM\nyyyy').format(state.focusedMonth);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.read<CalendarCubit>().goToPreviousMonth(),
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
            monthYear,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFF3F4F6) : const Color(0xFF101828),
              height: 1.3,
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => context.read<CalendarCubit>().goToNextMonth(),
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

  Widget _buildWeekdayHeaders(AppLocalizations l10n, bool isDark) {
    final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: weekdays.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(BuildContext context, CalendarState state, bool isDark) {
    final daysInMonth = _getDaysInMonth(state.focusedMonth);
    final today = DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: List.generate(
          (daysInMonth.length / 7).ceil(),
          (weekIndex) {
            final weekStart = weekIndex * 7;
            final weekEnd = (weekStart + 7).clamp(0, daysInMonth.length);
            final weekDays = daysInMonth.sublist(weekStart, weekEnd);

            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: weekDays.map((date) {
                  if (date == null) {
                    return const Expanded(child: SizedBox(height: 40));
                  }

                  final isToday = date.year == today.year &&
                      date.month == today.month &&
                      date.day == today.day;
                  final isSelected = date.year == state.selectedDate.year &&
                      date.month == state.selectedDate.month &&
                      date.day == state.selectedDate.day;
                  final isCurrentMonth = date.month == state.focusedMonth.month;
                  final hasEvents = state.hasEventsOnDate(date);
                  final eventsOnDate = state.getEventsForDate(date);

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        context.read<CalendarCubit>().selectDate(date);
                        if (eventsOnDate.isNotEmpty && onDateTap != null) {
                          onDateTap!(date, eventsOnDate);
                        }
                      },
                      child: _buildDayCell(
                        date,
                        isToday: isToday,
                        isSelected: isSelected,
                        isCurrentMonth: isCurrentMonth,
                        hasEvents: hasEvents,
                        isDark: isDark,
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDayCell(
    DateTime date, {
    required bool isToday,
    required bool isSelected,
    required bool isCurrentMonth,
    required bool hasEvents,
    required bool isDark,
  }) {
    Color textColor;
    Color? backgroundColor;
    Color? borderColor;

    if (isSelected) {
      textColor = Colors.white;
      backgroundColor = const Color(0xFFF59E0B);
    } else if (isToday) {
      textColor = const Color(0xFF2B7FFF);
      borderColor = const Color(0xFF2B7FFF);
    } else if (!isCurrentMonth) {
      textColor = isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DC);
    } else {
      textColor = isDark ? const Color(0xFFD1D5DC) : const Color(0xFF374151);
    }

    return Container(
      height: 40,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: borderColor != null
            ? Border.all(color: borderColor, width: 1.5)
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '${date.day}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: isToday || isSelected ? FontWeight.w600 : FontWeight.w500,
              color: textColor,
            ),
          ),
          if (hasEvents && !isSelected)
            Positioned(
              bottom: 4,
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: isToday ? const Color(0xFF2B7FFF) : const Color(0xFFF59E0B),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<DateTime?> _getDaysInMonth(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7;

    final days = <DateTime?>[];

    // Add previous month's trailing days
    for (var i = 0; i < firstWeekday; i++) {
      final prevDay = firstDayOfMonth.subtract(Duration(days: firstWeekday - i));
      days.add(prevDay);
    }

    // Add current month's days
    for (var i = 1; i <= lastDayOfMonth.day; i++) {
      days.add(DateTime(month.year, month.month, i));
    }

    // Add next month's leading days to complete the grid
    final remainingDays = 42 - days.length; // 6 weeks * 7 days
    for (var i = 1; i <= remainingDays; i++) {
      days.add(DateTime(month.year, month.month + 1, i));
    }

    return days;
  }
}
