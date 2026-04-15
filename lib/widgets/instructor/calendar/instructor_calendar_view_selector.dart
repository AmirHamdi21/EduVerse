import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/instructor/instructor_calendar_state.dart';
import '../../../generated_l10n/app_localizations.dart';

class InstructorCalendarViewSelector extends StatelessWidget {
  final CalendarViewType currentView;
  final Function(CalendarViewType) onViewChanged;

  const InstructorCalendarViewSelector({
    super.key,
    required this.currentView,
    required this.onViewChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeState = context.watch<ThemeBloc>().state;
    final isDark = themeState.isDark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2939) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _buildViewButton(context, l10n.month, CalendarViewType.month, isDark),
          _buildViewButton(context, l10n.week, CalendarViewType.week, isDark),
          _buildViewButton(context, l10n.day, CalendarViewType.day, isDark),
        ],
      ),
    );
  }

  Widget _buildViewButton(
    BuildContext context,
    String label,
    CalendarViewType type,
    bool isDark,
  ) {
    final isSelected = currentView == type;

    return Expanded(
      child: GestureDetector(
        onTap: () => onViewChanged(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF155CFB) : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: isDark
                          ? const Color(0xFF155CFB).withValues(alpha: 0.3)
                          : Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? (isDark ? Colors.white : const Color(0xFF155CFB))
                  : (isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B)),
            ),
          ),
        ),
      ),
    );
  }
}
