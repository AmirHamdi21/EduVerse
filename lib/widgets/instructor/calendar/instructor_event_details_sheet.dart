import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/instructor/instructor_calendar_cubit.dart';
import '../../../bloc/instructor/instructor_calendar_state.dart';
import '../../../generated_l10n/app_localizations.dart';

class InstructorEventDetailsSheet extends StatelessWidget {
  final InstructorCalendarEvent event;

  const InstructorEventDetailsSheet({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeState = context.watch<ThemeBloc>().state;
    final isDark = themeState.isDark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2939) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(isDark),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isDark),
                const SizedBox(height: 24),
                _buildEventInfo(isDark),
                const SizedBox(height: 24),
                _buildActionButtons(context, isDark, l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getEventColor(event.type).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            _getEventIcon(event.type),
            color: _getEventColor(event.type),
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getEventColor(event.type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _getEventTypeName(event.type),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getEventColor(event.type),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventInfo(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF374151) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.calendar_today_rounded,
            'Date',
            _formatDate(event.date),
            isDark,
          ),
          if (event.time != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.access_time_rounded,
              'Time',
              '${event.time}${event.endTime != null ? ' - ${event.endTime}' : ''}',
              isDark,
            ),
          ],
          if (event.course != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.school_outlined,
              'Course',
              event.course!,
              isDark,
            ),
          ],
          if (event.location != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.location_on_outlined,
              'Location',
              event.location!,
              isDark,
            ),
          ],
          if (event.studentCount != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.people_outline_rounded,
              'Students',
              '${event.studentCount} enrolled',
              isDark,
            ),
          ],
          if (event.description != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.notes_rounded,
              'Notes',
              event.description!,
              isDark,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E2939)
                : Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isDark, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: TextButton.icon(
            onPressed: () {
              context.read<InstructorCalendarCubit>().deleteEvent(event.id);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: Text(l10n.delete),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFEF4444)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextButton.icon(
            onPressed: () {
              context.read<InstructorCalendarCubit>().toggleEventCompletion(event.id);
              Navigator.pop(context);
            },
            icon: Icon(
              event.isCompleted
                  ? Icons.refresh_rounded
                  : Icons.check_rounded,
              size: 18,
            ),
            label: Text(event.isCompleted ? 'Reopen' : 'Complete'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF059669),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFF059669)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF155CFB),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              l10n.done,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final dayNames = [
      'Sunday', 'Monday', 'Tuesday', 'Wednesday',
      'Thursday', 'Friday', 'Saturday'
    ];
    return '${dayNames[date.weekday % 7]}, ${monthNames[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _getEventTypeName(InstructorEventType type) {
    switch (type) {
      case InstructorEventType.lecture:
        return 'Lecture';
      case InstructorEventType.lab:
        return 'Lab';
      case InstructorEventType.officeHours:
        return 'Office Hours';
      case InstructorEventType.meeting:
        return 'Meeting';
      case InstructorEventType.deadline:
        return 'Deadline';
      case InstructorEventType.grading:
        return 'Grading';
      case InstructorEventType.exam:
        return 'Exam';
    }
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

  IconData _getEventIcon(InstructorEventType type) {
    switch (type) {
      case InstructorEventType.lecture:
        return Icons.school_rounded;
      case InstructorEventType.lab:
        return Icons.science_rounded;
      case InstructorEventType.officeHours:
        return Icons.access_time_rounded;
      case InstructorEventType.meeting:
        return Icons.groups_rounded;
      case InstructorEventType.deadline:
        return Icons.flag_rounded;
      case InstructorEventType.grading:
        return Icons.grading_rounded;
      case InstructorEventType.exam:
        return Icons.quiz_rounded;
    }
  }
}
