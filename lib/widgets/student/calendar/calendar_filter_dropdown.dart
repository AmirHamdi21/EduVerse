import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/calendar/calendar_state.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';

class CalendarFilterDropdown extends StatelessWidget {
  final EventFilter filter;
  final bool isVisible;
  final VoidCallback onToggle;
  final Function(String) onFilterChanged;

  const CalendarFilterDropdown({
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterButton(l10n, isDark),
          if (isVisible) ...[
            const SizedBox(height: 8),
            _buildFilterOptions(l10n, isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterButton(AppLocalizations l10n, bool isDark) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2939) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_list_rounded,
              size: 18,
              color: isDark ? const Color(0xFF99A1AF) : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 8),
            Text(
              l10n.filters,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFFD1D5DC) : const Color(0xFF374151),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              isVisible ? Icons.expand_less_rounded : Icons.expand_more_rounded,
              size: 18,
              color: isDark ? const Color(0xFF99A1AF) : const Color(0xFF6B7280),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOptions(AppLocalizations l10n, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF101828) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF1E2939) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildFilterItem(
            l10n.lecturesFilter,
            '📚',
            filter.lectures,
            'lectures',
            isDark,
          ),
          _buildFilterItem(
            l10n.labsFilter,
            '🔬',
            filter.labs,
            'labs',
            isDark,
          ),
          _buildFilterItem(
            l10n.assignmentsFilter,
            '📝',
            filter.assignments,
            'assignments',
            isDark,
          ),
          _buildFilterItem(
            l10n.examsFilter,
            '📋',
            filter.exams,
            'exams',
            isDark,
          ),
          _buildFilterItem(
            l10n.personalTasksFilter,
            '⭐',
            filter.personalTasks,
            'personalTasks',
            isDark,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterItem(
    String label,
    String emoji,
    bool isEnabled,
    String type,
    bool isDark, {
    bool isLast = false,
  }) {
    return GestureDetector(
      onTap: () => onFilterChanged(type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: isDark ? const Color(0xFF1E2939) : const Color(0xFFF3F4F6),
                  ),
                ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isEnabled
                    ? const Color(0xFF2B7FFF)
                    : (isDark ? const Color(0xFF1E2939) : const Color(0xFFF3F4F6)),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isEnabled
                      ? const Color(0xFF2B7FFF)
                      : (isDark ? const Color(0xFF374151) : const Color(0xFFD1D5DC)),
                ),
              ),
              child: isEnabled
                  ? const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              emoji,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFFD1D5DC) : const Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
