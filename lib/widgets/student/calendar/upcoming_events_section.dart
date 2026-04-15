import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/calendar/calendar_cubit.dart';
import 'package:edu_verse/bloc/calendar/calendar_state.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';

class UpcomingEventsSection extends StatelessWidget {
  final void Function(CalendarEvent event)? onEventTap;

  const UpcomingEventsSection({super.key, this.onEventTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeState = context.watch<ThemeBloc>().state;
    final isDark = themeState.isDark;

    return BlocBuilder<CalendarCubit, CalendarState>(
      builder: (context, state) {
        final hasEvents =
            state.upcomingEvents.isNotEmpty || state.events.isNotEmpty;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.upcomingEvents,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? const Color(0xFFF3F4F6)
                      : const Color(0xFF101828),
                ),
              ),
              const SizedBox(height: 16),
              // AI Reminders
              ...state.aiReminders.map(
                (reminder) => _buildAiReminderCard(context, reminder, isDark),
              ),
              // Upcoming Events
              if (state.upcomingEvents.isEmpty)
                _buildEmptyState(context, l10n, isDark)
              else
                ...state.upcomingEvents
                    .take(5)
                    .map((event) => _buildEventCard(context, event, isDark)),
              const SizedBox(height: 16),
              // Only show "Add Your First Event" button when there are no events
              if (!hasEvents) _buildAddEventButton(context, l10n, isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAiReminderCard(
    BuildContext context,
    AiReminder reminder,
    bool isDark,
  ) {
    final isQuizType = reminder.type == ReminderType.quiz;
    final gradientColors = isQuizType
        ? [const Color(0xFF2B7FFF), const Color(0xFF60A5FA)]
        : [const Color(0xFFF59E0B), const Color(0xFFFBBF24)];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors
                .map((c) => c.withValues(alpha: 0.15))
                .toList(),
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: gradientColors[0].withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isQuizType
                    ? Icons.psychology_rounded
                    : Icons.notifications_active_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 14,
                        color: gradientColors[0],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        reminder.title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: gradientColors[0],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reminder.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? const Color(0xFFD1D5DC)
                          : const Color(0xFF374151),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () =>
                  context.read<CalendarCubit>().dismissReminder(reminder.id),
              child: Icon(
                Icons.close_rounded,
                size: 20,
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

  Widget _buildEventCard(
    BuildContext context,
    CalendarEvent event,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () => onEventTap?.call(event),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF101828) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? const Color(0xFF1E2939) : const Color(0xFFE5E7EB),
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
                        color: isDark
                            ? const Color(0xFFF3F4F6)
                            : const Color(0xFF101828),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: isDark
                              ? const Color(0xFF6B7280)
                              : const Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          event.time ?? 'All day',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? const Color(0xFF99A1AF)
                                : const Color(0xFF6B7280),
                          ),
                        ),
                        if (event.location != null) ...[
                          const SizedBox(width: 12),
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
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getEventTypeColor(event.type).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getEventTypeIcon(event.type),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
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
              l10n.noUpcomingEvents,
              style: TextStyle(
                fontSize: 15,
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

  Widget _buildAddEventButton(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        // This will be handled by the FAB, but we can also trigger from here
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF101828) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF1E2939) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_rounded,
              size: 20,
              color: isDark ? const Color(0xFF99A1AF) : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 8),
            Text(
              l10n.addYourFirstEvent,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? const Color(0xFF99A1AF)
                    : const Color(0xFF6B7280),
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

  String _getEventTypeIcon(EventType type) {
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
