import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/calendar/calendar_cubit.dart';
import 'package:edu_verse/bloc/calendar/calendar_state.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class EventDetailsSheet extends StatelessWidget {
  final CalendarEvent event;
  final bool isDark;

  const EventDetailsSheet({
    super.key,
    required this.event,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
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
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with type badge and close button
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getEventTypeColor(event.type).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _getEventTypeEmoji(event.type),
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _getEventTypeName(event.type, l10n),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _getEventTypeColor(event.type),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
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
                  const SizedBox(height: 20),

                  // Event Title
                  Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Date and Time
                  _buildInfoRow(
                    icon: Icons.calendar_today_rounded,
                    title: l10n.date,
                    value: DateFormat('EEEE, MMMM d, yyyy').format(event.date),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 14),

                  if (event.time != null) ...[
                    _buildInfoRow(
                      icon: Icons.access_time_rounded,
                      title: l10n.time,
                      value: event.endTime != null 
                          ? '${event.time} - ${event.endTime}'
                          : event.time!,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Course
                  if (event.course != null) ...[
                    _buildInfoRow(
                      icon: Icons.menu_book_rounded,
                      title: l10n.course,
                      value: event.course!,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Location
                  if (event.location != null) ...[
                    _buildInfoRow(
                      icon: Icons.location_on_rounded,
                      title: l10n.location,
                      value: event.location!,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Description
                  if (event.description != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      l10n.description,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF99A1AF) : const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E2939) : const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Text(
                        event.description!,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: isDark ? const Color(0xFFD1D5DC) : const Color(0xFF4B5563),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          context: context,
                          icon: Icons.edit_outlined,
                          label: l10n.edit,
                          color: const Color(0xFF2B7FFF),
                          isDark: isDark,
                          onTap: () {
                            Navigator.pop(context);
                            // TODO: Open edit event sheet
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          context: context,
                          icon: Icons.delete_outline_rounded,
                          label: l10n.delete,
                          color: const Color(0xFFEF4444),
                          isDark: isDark,
                          onTap: () {
                            _showDeleteConfirmation(context, l10n);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2939) : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDark ? const Color(0xFF99A1AF) : const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDark ? const Color(0xFFF3F4F6) : const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF101828) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFEF4444),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.delete,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete this event? This action cannot be undone.',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white70 : const Color(0xFF6B7280),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color: isDark ? Colors.white54 : const Color(0xFF6B7280),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Close dialog
              Navigator.pop(context); // Close details sheet
              context.read<CalendarCubit>().deleteEvent(event.id);
            },
            child: Text(
              l10n.delete,
              style: const TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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

  String _getEventTypeName(EventType type, AppLocalizations l10n) {
    switch (type) {
      case EventType.lecture:
        return l10n.lectureType;
      case EventType.lab:
        return l10n.labType;
      case EventType.assignment:
        return l10n.assignmentType;
      case EventType.exam:
        return l10n.examType;
      case EventType.quiz:
        return l10n.quizType;
      case EventType.personalTask:
        return l10n.personalTaskType;
    }
  }
}
