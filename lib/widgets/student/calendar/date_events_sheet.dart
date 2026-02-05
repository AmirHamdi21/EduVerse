import 'package:flutter/material.dart';
import 'package:edu_verse/bloc/calendar/calendar_state.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class DateEventsSheet extends StatelessWidget {
  final DateTime date;
  final List<CalendarEvent> events;
  final bool isDark;
  final Function(CalendarEvent) onEventTap;

  const DateEventsSheet({
    super.key,
    required this.date,
    required this.events,
    required this.isDark,
    required this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF101828) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2B7FFF).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_today_rounded,
                    color: Color(0xFF2B7FFF),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, MMMM d').format(date),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${events.length} event${events.length > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? const Color(0xFF99A1AF) : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E2939) : const Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: isDark ? const Color(0xFF99A1AF) : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: isDark ? const Color(0xFF1E2939) : const Color(0xFFE5E7EB),
            height: 1,
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return _buildEventItem(context, event, l10n);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem(BuildContext context, CalendarEvent event, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onEventTap(event);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2939) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(14),
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
                  Row(
                    children: [
                      Text(
                        _getEventTypeEmoji(event.type),
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFFF3F4F6) : const Color(0xFF101828),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (event.time != null) ...[
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          event.time!,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? const Color(0xFF99A1AF) : const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                      if (event.location != null) ...[
                        if (event.time != null) const SizedBox(width: 12),
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location!,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? const Color(0xFF99A1AF) : const Color(0xFF6B7280),
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
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
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
