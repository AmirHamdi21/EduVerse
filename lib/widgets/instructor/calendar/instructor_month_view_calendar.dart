import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/instructor/instructor_calendar_cubit.dart';
import '../../../bloc/instructor/instructor_calendar_state.dart';

class InstructorMonthViewCalendar extends StatelessWidget {
  final Function(DateTime) onDateSelected;
  final Function(DateTime) onDateDoubleTap;

  const InstructorMonthViewCalendar({
    super.key,
    required this.onDateSelected,
    required this.onDateDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeBloc>().state;
    final isDark = themeState.isDark;

    return BlocBuilder<InstructorCalendarCubit, InstructorCalendarState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2939) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
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
              _buildMonthHeader(context, state, isDark),
              const SizedBox(height: 16),
              _buildWeekDays(isDark),
              const SizedBox(height: 8),
              _buildCalendarGrid(context, state, isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMonthHeader(
    BuildContext context,
    InstructorCalendarState state,
    bool isDark,
  ) {
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildNavButton(
          context,
          Icons.chevron_left_rounded,
          isDark,
          () => context.read<InstructorCalendarCubit>().previousMonth(),
        ),
        GestureDetector(
          onTap: () => context.read<InstructorCalendarCubit>().goToToday(),
          child: Column(
            children: [
              Text(
                monthNames[state.focusedMonth.month - 1],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${state.focusedMonth.year}',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        _buildNavButton(
          context,
          Icons.chevron_right_rounded,
          isDark,
          () => context.read<InstructorCalendarCubit>().nextMonth(),
        ),
      ],
    );
  }

  Widget _buildNavButton(
    BuildContext context,
    IconData icon,
    bool isDark,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF374151) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 22,
          color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
        ),
      ),
    );
  }

  Widget _buildWeekDays(bool isDark) {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days.map((day) {
        return SizedBox(
          width: 36,
          child: Text(
            day,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid(
    BuildContext context,
    InstructorCalendarState state,
    bool isDark,
  ) {
    final firstDayOfMonth = DateTime(
      state.focusedMonth.year,
      state.focusedMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      state.focusedMonth.year,
      state.focusedMonth.month + 1,
      0,
    );
    final daysInMonth = lastDayOfMonth.day;
    final startingWeekday = firstDayOfMonth.weekday % 7;

    final today = DateTime.now();
    final cells = <Widget>[];

    // Empty cells for days before the first day
    for (int i = 0; i < startingWeekday; i++) {
      cells.add(const SizedBox(width: 36, height: 36));
    }

    // Day cells
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(
        state.focusedMonth.year,
        state.focusedMonth.month,
        day,
      );
      final isToday =
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
      final isSelected =
          date.year == state.selectedDate.year &&
          date.month == state.selectedDate.month &&
          date.day == state.selectedDate.day;
      final hasEvents = state.hasEventsOnDate(date);

      cells.add(
        GestureDetector(
          onTap: () => onDateSelected(date),
          onDoubleTap: () => onDateDoubleTap(date),
          child: Container(
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
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isToday || isSelected
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
                if (hasEvents && !isSelected)
                  Positioned(
                    bottom: 2,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isToday
                            ? const Color(0xFF155CFB)
                            : (isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B)),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.start,
      children: cells,
    );
  }
}
