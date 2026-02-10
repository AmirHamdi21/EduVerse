import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/instructor_colors.dart';

enum InstructorChatFilter { all, students, colleagues, groups }

class InstructorChatFilterChips extends StatelessWidget {
  final InstructorChatFilter currentFilter;
  final bool isDark;
  final ValueChanged<InstructorChatFilter> onFilterChanged;

  const InstructorChatFilterChips({
    super.key,
    required this.currentFilter,
    required this.isDark,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildFilterChip(
            l10n.all,
            InstructorChatFilter.all,
          ),
          _buildFilterChip(
            l10n.students,
            InstructorChatFilter.students,
          ),
          _buildFilterChip(
            'Colleagues',
            InstructorChatFilter.colleagues,
          ),
          _buildFilterChip(
            l10n.groups,
            InstructorChatFilter.groups,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, InstructorChatFilter filter) {
    final isSelected = currentFilter == filter;

    return Expanded(
      child: GestureDetector(
        onTap: () => onFilterChanged(filter),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? InstructorColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : InstructorColors.textSecondaryColor(isDark),
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
