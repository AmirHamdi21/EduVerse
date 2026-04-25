import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/calendar/calendar_cubit.dart';
import 'package:edu_verse/bloc/calendar/calendar_state.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/widgets/student/calendar/calendar_app_bar.dart';
import 'package:edu_verse/widgets/student/calendar/calendar_header.dart';
import 'package:edu_verse/widgets/student/calendar/calendar_filter_dropdown.dart';
import 'package:edu_verse/widgets/student/calendar/calendar_view_selector.dart';
import 'package:edu_verse/widgets/student/calendar/month_view_calendar.dart';
import 'package:edu_verse/widgets/student/calendar/week_view_calendar.dart';
import 'package:edu_verse/widgets/student/calendar/day_view_calendar.dart';
import 'package:edu_verse/widgets/student/calendar/upcoming_events_section.dart';
import 'package:edu_verse/widgets/student/calendar/add_event_sheet.dart';
import 'package:edu_verse/widgets/student/calendar/event_details_sheet.dart';
import 'package:edu_verse/widgets/student/calendar/date_events_sheet.dart';
import 'package:edu_verse/widgets/shared/loading/calendar_screen_skeleton.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/storage_service.dart';
import 'package:edu_verse/services/api/schedule_api_service.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final coreApiClient = CoreApiClient(storageService: StorageService());
        final scheduleApiService = ScheduleApiService(
          coreApiClient: coreApiClient,
        );

        return CalendarCubit(scheduleService: scheduleApiService);
      },
      child: const _CalendarView(),
    );
  }
}

class _CalendarView extends StatelessWidget {
  const _CalendarView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeState = context.watch<ThemeBloc>().state;
    final isDark = themeState.isDark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF030712)
          : const Color(0xFFF9FAFB),
      body: BlocConsumer<CalendarCubit, CalendarState>(
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
                    CalendarAppBar(
                      onAddEvent: () =>
                          _showAddEventSheet(context, isDark, l10n),
                    ),
                    Expanded(
                      child: state.isLoading
                          ? CalendarScreenSkeleton(isDark: isDark)
                          : SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const CalendarHeader(),
                                  CalendarFilterDropdown(
                                    filter: state.filter,
                                    isVisible: state.isFilterVisible,
                                    onToggle: () => context
                                        .read<CalendarCubit>()
                                        .toggleFilterVisibility(),
                                    onFilterChanged: (type) => context
                                        .read<CalendarCubit>()
                                        .toggleFilterType(type),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildCalendarCard(context, state, isDark),
                                  const SizedBox(height: 24),
                                  UpcomingEventsSection(
                                    onEventTap: (event) => _showEventDetails(
                                      context,
                                      event,
                                      isDark,
                                    ),
                                  ),
                                  const SizedBox(height: 100),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),

              // FAB
              Positioned(
                right: 20,
                bottom: 20 + MediaQuery.of(context).padding.bottom,
                child: _buildFAB(context, isDark, l10n),
              ),
            ],
          );
        },
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
                    0xFF2B7FFF,
                  ).withValues(alpha: isDark ? 0.1 : 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 200,
          left: -150,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(
                    0xFF00B8DB,
                  ).withValues(alpha: isDark ? 0.08 : 0.12),
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
    CalendarState state,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF101828) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? const Color(0xFF1E2939) : const Color(0xFFE5E7EB),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            CalendarViewSelector(
              currentView: state.viewType,
              onViewChanged: (view) =>
                  context.read<CalendarCubit>().setViewType(view),
            ),
            _buildCalendarView(context, state, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarView(
    BuildContext context,
    CalendarState state,
    bool isDark,
  ) {
    switch (state.viewType) {
      case CalendarViewType.month:
        return MonthViewCalendar(
          onDateTap: (date, events) {
            if (events.length == 1) {
              _showEventDetails(context, events.first, isDark);
            } else if (events.length > 1) {
              _showDateEvents(context, date, events, isDark);
            }
          },
        );
      case CalendarViewType.week:
        return WeekViewCalendar(
          onDateTap: (date, events) {
            if (events.length == 1) {
              _showEventDetails(context, events.first, isDark);
            } else if (events.length > 1) {
              _showDateEvents(context, date, events, isDark);
            }
          },
        );
      case CalendarViewType.day:
        return DayViewCalendar(
          onEventTap: (event) => _showEventDetails(context, event, isDark),
        );
    }
  }

  Widget _buildFAB(BuildContext context, bool isDark, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () => _showAddEventSheet(context, isDark, l10n),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2B7FFF).withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  void _showAddEventSheet(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final cubit = context.read<CalendarCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: cubit,
        child: AddEventSheet(isDark: isDark),
      ),
    );
  }

  void _showEventDetails(
    BuildContext context,
    CalendarEvent event,
    bool isDark,
  ) {
    final cubit = context.read<CalendarCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: cubit,
        child: EventDetailsSheet(event: event, isDark: isDark),
      ),
    );
  }

  void _showDateEvents(
    BuildContext context,
    DateTime date,
    List<CalendarEvent> events,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => DateEventsSheet(
        date: date,
        events: events,
        isDark: isDark,
        onEventTap: (event) => _showEventDetails(context, event, isDark),
      ),
    );
  }
}
