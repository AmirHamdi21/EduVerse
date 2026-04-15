import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/instructor/instructor_calendar_cubit.dart';
import '../../../bloc/instructor/instructor_calendar_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/instructor/calendar/instructor_calendar_app_bar.dart';
import '../../../widgets/instructor/calendar/instructor_calendar_header.dart';
import '../../../widgets/instructor/calendar/instructor_calendar_filter_dropdown.dart';
import '../../../widgets/instructor/calendar/instructor_calendar_view_selector.dart';
import '../../../widgets/instructor/calendar/instructor_month_view_calendar.dart';
import '../../../widgets/instructor/calendar/instructor_week_view_calendar.dart';
import '../../../widgets/instructor/calendar/instructor_day_view_calendar.dart';
import '../../../widgets/instructor/calendar/instructor_upcoming_events_section.dart';
import '../../../widgets/instructor/calendar/instructor_add_event_sheet.dart';
import '../../../widgets/instructor/calendar/instructor_event_details_sheet.dart';

class InstructorCalendarScreen extends StatelessWidget {
  const InstructorCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InstructorCalendarCubit(),
      child: const _InstructorCalendarView(),
    );
  }
}

class _InstructorCalendarView extends StatelessWidget {
  const _InstructorCalendarView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeState = context.watch<ThemeBloc>().state;
    final isDark = themeState.isDark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF030712)
          : const Color(0xFFF9FAFB),
      body: BlocConsumer<InstructorCalendarCubit, InstructorCalendarState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: const Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: const Color(0xFFEF4444),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // Background decorations
              _buildBackgroundDecorations(isDark),

              // Main content
              SafeArea(
                child: Column(
                  children: [
                    InstructorCalendarAppBar(
                      onAddEvent: () =>
                          _showAddEventSheet(context, isDark, l10n),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const InstructorCalendarHeader(),
                            InstructorCalendarFilterDropdown(
                              filter: state.filter,
                              isVisible: state.isFilterVisible,
                              onToggle: () => context
                                  .read<InstructorCalendarCubit>()
                                  .toggleFilterVisibility(),
                              onFilterChanged: (type) => context
                                  .read<InstructorCalendarCubit>()
                                  .toggleFilterType(type),
                            ),
                            const SizedBox(height: 16),
                            _buildCalendarCard(context, state, isDark),
                            const SizedBox(height: 24),
                            InstructorUpcomingEventsSection(
                              onEventTap: (event) =>
                                  _showEventDetails(context, event, isDark),
                            ),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEventSheet(context, isDark, l10n),
        backgroundColor: const Color(0xFF155CFB),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          l10n.addEvent,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundDecorations(bool isDark) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(
                    0xFF155CFB,
                  ).withValues(alpha: isDark ? 0.15 : 0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(
                    0xFF7C3AED,
                  ).withValues(alpha: isDark ? 0.1 : 0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarCard(
    BuildContext context,
    InstructorCalendarState state,
    bool isDark,
  ) {
    return Column(
      children: [
        InstructorCalendarViewSelector(
          currentView: state.viewType,
          onViewChanged: (type) =>
              context.read<InstructorCalendarCubit>().setViewType(type),
        ),
        const SizedBox(height: 16),
        _buildCurrentView(context, state, isDark),
      ],
    );
  }

  Widget _buildCurrentView(
    BuildContext context,
    InstructorCalendarState state,
    bool isDark,
  ) {
    switch (state.viewType) {
      case CalendarViewType.month:
        return InstructorMonthViewCalendar(
          onDateSelected: (date) =>
              context.read<InstructorCalendarCubit>().selectDate(date),
          onDateDoubleTap: (date) =>
              _showDateEvents(context, date, state, isDark),
        );
      case CalendarViewType.week:
        return InstructorWeekViewCalendar(
          onDateSelected: (date) =>
              context.read<InstructorCalendarCubit>().selectDate(date),
          onEventTap: (event) => _showEventDetails(context, event, isDark),
        );
      case CalendarViewType.day:
        return InstructorDayViewCalendar(
          onEventTap: (event) => _showEventDetails(context, event, isDark),
        );
    }
  }

  void _showAddEventSheet(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final cubit = context.read<InstructorCalendarCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => BlocProvider.value(
        value: cubit,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (_, controller) =>
                InstructorAddEventSheet(initialDate: cubit.state.selectedDate),
          ),
        ),
      ),
    );
  }

  void _showEventDetails(
    BuildContext context,
    InstructorCalendarEvent event,
    bool isDark,
  ) {
    final cubit = context.read<InstructorCalendarCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => BlocProvider.value(
        value: cubit,
        child: InstructorEventDetailsSheet(event: event),
      ),
    );
  }

  void _showDateEvents(
    BuildContext context,
    DateTime date,
    InstructorCalendarState state,
    bool isDark,
  ) {
    final events = state.getEventsForDate(date);
    if (events.isEmpty) {
      _showAddEventSheet(context, isDark, AppLocalizations.of(context));
      return;
    }

    final cubit = context.read<InstructorCalendarCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => BlocProvider.value(
        value: cubit,
        child: _DateEventsSheet(
          date: date,
          events: events,
          isDark: isDark,
          onEventTap: (event) {
            Navigator.pop(bottomSheetContext);
            _showEventDetails(context, event, isDark);
          },
        ),
      ),
    );
  }
}

class _DateEventsSheet extends StatelessWidget {
  final DateTime date;
  final List<InstructorCalendarEvent> events;
  final bool isDark;
  final Function(InstructorCalendarEvent) onEventTap;

  const _DateEventsSheet({
    required this.date,
    required this.events,
    required this.isDark,
    required this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
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

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2939) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${monthNames[date.month - 1]} ${date.day}, ${date.year}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  '${events.length} event${events.length > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 16),
                ...events.map((event) => _buildEventItem(event)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem(InstructorCalendarEvent event) {
    return GestureDetector(
      onTap: () => onEventTap(event),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF374151) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
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
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  if (event.time != null)
                    Text(
                      '${event.time}${event.endTime != null ? ' - ${event.endTime}' : ''}',
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
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ],
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
