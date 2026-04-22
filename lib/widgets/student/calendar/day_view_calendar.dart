import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/calendar/calendar_cubit.dart';
import 'package:edu_verse/bloc/calendar/calendar_state.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class DayViewCalendar extends StatelessWidget {
  final Function(CalendarEvent) onEventTap;

  const DayViewCalendar({super.key, required this.onEventTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeState = context.watch<ThemeBloc>().state;
    final isDark = themeState.isDark;

    return BlocBuilder<CalendarCubit, CalendarState>(
      builder: (context, state) {
        return Column(
          children: [
            _buildDayNavigation(context, state, l10n, isDark),
            const SizedBox(height: 16),
            _buildDaySchedule(context, state, isDark),
          ],
        );
      },
    );
  }

  Widget _buildDayNavigation(
    BuildContext context,
    CalendarState state,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final today = DateTime.now();
    final isToday =
        state.selectedDate.year == today.year &&
        state.selectedDate.month == today.month &&
        state.selectedDate.day == today.day;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              final newDate = state.selectedDate.subtract(
                const Duration(days: 1),
              );
              context.read<CalendarCubit>().selectDate(newDate);
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E2939)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.chevron_left_rounded,
                color: isDark
                    ? const Color(0xFF99A1AF)
                    : const Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  dateFormat.format(state.selectedDate),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFFF3F4F6)
                        : const Color(0xFF101828),
                  ),
                ),
                if (isToday)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2B7FFF).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      l10n.today,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2B7FFF),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  final newDate = state.selectedDate.add(
                    const Duration(days: 1),
                  );
                  context.read<CalendarCubit>().selectDate(newDate);
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E2939)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: isDark
                        ? const Color(0xFF99A1AF)
                        : const Color(0xFF6B7280),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => context.read<CalendarCubit>().goToToday(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E2939)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF374151)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Text(
                    l10n.today,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? const Color(0xFFD1D5DC)
                          : const Color(0xFF374151),
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

  Widget _buildDaySchedule(
    BuildContext context,
    CalendarState state,
    bool isDark,
  ) {
    final events = state.selectedDateEvents;

    if (events.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.event_available_rounded,
                size: 56,
                color: isDark
                    ? const Color(0xFF374151)
                    : const Color(0xFFD1D5DC),
              ),
              const SizedBox(height: 16),
              Text(
                'No events scheduled',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? const Color(0xFF6B7280)
                      : const Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap + to add an event',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? const Color(0xFF4B5563)
                      : const Color(0xFFD1D5DC),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Sort events by time
    final sortedEvents = List<CalendarEvent>.from(events);
    sortedEvents.sort((a, b) {
      if (a.time == null && b.time == null) return 0;
      if (a.time == null) return 1;
      if (b.time == null) return -1;
      return a.time!.compareTo(b.time!);
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${events.length} event${events.length > 1 ? 's' : ''} today',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 12),
          ...sortedEvents.map(
            (event) => _buildEventCard(context, event, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(
    BuildContext context,
    CalendarEvent event,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () => onEventTap(event),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2939) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 5,
              height: 80,
              decoration: BoxDecoration(
                color: _getEventTypeColor(event.type),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _getEventTypeColor(
                              event.type,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _getEventTypeEmoji(event.type),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        const Spacer(),
                        if (event.time != null)
                          Text(
                            event.time!,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2B7FFF),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFFF3F4F6)
                            : const Color(0xFF101828),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (event.location != null) ...[
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: isDark
                                ? const Color(0xFF6B7280)
                                : const Color(0xFF9CA3AF),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.location!,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? const Color(0xFF99A1AF)
                                    : const Color(0xFF6B7280),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ] else if (event.course != null) ...[
                          Icon(
                            Icons.menu_book_outlined,
                            size: 14,
                            color: isDark
                                ? const Color(0xFF6B7280)
                                : const Color(0xFF9CA3AF),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            event.course!,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? const Color(0xFF99A1AF)
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                Icons.chevron_right_rounded,
                color: isDark
                    ? const Color(0xFF6B7280)
                    : const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
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

  String _getEventTypeEmoji(EventType type) {
    switch (type) {
      case EventType.lecture:
        return '📚';
      case EventType.lab:
        return '🔬';
      case EventType.assignment:
        return '📝';
      case EventType.exam:
        return '📋';
      case EventType.quiz:
        return '❓';
      case EventType.personalTask:
        return '⭐';
    }
  }
}
