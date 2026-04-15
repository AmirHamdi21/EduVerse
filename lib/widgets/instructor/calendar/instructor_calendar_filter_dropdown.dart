import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/instructor/instructor_calendar_state.dart';
import '../../../generated_l10n/app_localizations.dart';

class InstructorCalendarFilterDropdown extends StatelessWidget {
  final InstructorEventFilter filter;
  final bool isVisible;
  final VoidCallback onToggle;
  final Function(InstructorEventType) onFilterChanged;

  const InstructorCalendarFilterDropdown({
    super.key,
    required this.filter,
    required this.isVisible,
    required this.onToggle,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeState = context.watch<ThemeBloc>().state;
    final isDark = themeState.isDark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildFilterToggle(isDark, l10n),
          if (isVisible) ...[
            const SizedBox(height: 12),
            _buildFilterChips(isDark, l10n),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterToggle(bool isDark, AppLocalizations l10n) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2939) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.filter_list_rounded,
                  size: 20,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
                const SizedBox(width: 10),
                Text(
                  'Filter Events',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? const Color(0xFFE2E8F0)
                        : const Color(0xFF334155),
                  ),
                ),
              ],
            ),
            AnimatedRotation(
              turns: isVisible ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(bool isDark, AppLocalizations l10n) {
    final filterItems = [
      _FilterItem(
        type: InstructorEventType.lecture,
        label: 'Lectures',
        icon: Icons.school_rounded,
        color: const Color(0xFF155CFB),
        isActive: filter.lectures,
      ),
      _FilterItem(
        type: InstructorEventType.lab,
        label: 'Labs',
        icon: Icons.science_rounded,
        color: const Color(0xFF7C3AED),
        isActive: filter.labs,
      ),
      _FilterItem(
        type: InstructorEventType.officeHours,
        label: 'Office Hours',
        icon: Icons.access_time_rounded,
        color: const Color(0xFF059669),
        isActive: filter.officeHours,
      ),
      _FilterItem(
        type: InstructorEventType.meeting,
        label: 'Meetings',
        icon: Icons.groups_rounded,
        color: const Color(0xFFF59E0B),
        isActive: filter.meetings,
      ),
      _FilterItem(
        type: InstructorEventType.deadline,
        label: 'Deadlines',
        icon: Icons.flag_rounded,
        color: const Color(0xFFEF4444),
        isActive: filter.deadlines,
      ),
      _FilterItem(
        type: InstructorEventType.grading,
        label: 'Grading',
        icon: Icons.grading_rounded,
        color: const Color(0xFF0EA5E9),
        isActive: filter.grading,
      ),
      _FilterItem(
        type: InstructorEventType.exam,
        label: 'Exams',
        icon: Icons.quiz_rounded,
        color: const Color(0xFFEC4899),
        isActive: filter.exams,
      ),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: filterItems.map((item) {
        return GestureDetector(
          onTap: () => onFilterChanged(item.type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: item.isActive
                  ? item.color.withValues(alpha: 0.15)
                  : (isDark ? const Color(0xFF1E2939) : Colors.white),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: item.isActive
                    ? item.color
                    : (isDark
                          ? const Color(0xFF374151)
                          : const Color(0xFFE5E7EB)),
                width: item.isActive ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item.icon,
                  size: 16,
                  color: item.isActive
                      ? item.color
                      : (isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B)),
                ),
                const SizedBox(width: 8),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: item.isActive
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: item.isActive
                        ? item.color
                        : (isDark
                              ? const Color(0xFFE2E8F0)
                              : const Color(0xFF334155)),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _FilterItem {
  final InstructorEventType type;
  final String label;
  final IconData icon;
  final Color color;
  final bool isActive;

  const _FilterItem({
    required this.type,
    required this.label,
    required this.icon,
    required this.color,
    required this.isActive,
  });
}
