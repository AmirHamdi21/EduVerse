import 'package:flutter/material.dart';
import '../../../models/instructor/reports_model.dart';
import 'reports_colors.dart';

/// Tab selector for Performance, Attendance, Analytics
class ReportsTabSelector extends StatelessWidget {
  final ReportTabType selectedTab;
  final ValueChanged<ReportTabType> onTabChanged;
  final bool isDark;

  const ReportsTabSelector({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? ReportsColors.darkCard.withValues(alpha: 0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: ReportsColors.borderColor(isDark),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: ReportTabType.values.map((tab) {
          final isSelected = tab == selectedTab;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(tab),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? ReportsColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: ReportsColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getTabIcon(tab),
                      size: 18,
                      color: isSelected
                          ? Colors.white
                          : ReportsColors.textSecondaryColor(isDark),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getTabLabel(tab),
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : ReportsColors.textSecondaryColor(isDark),
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getTabIcon(ReportTabType tab) {
    switch (tab) {
      case ReportTabType.performance:
        return Icons.trending_up_rounded;
      case ReportTabType.attendance:
        return Icons.calendar_today_rounded;
      case ReportTabType.analytics:
        return Icons.bar_chart_rounded;
    }
  }

  String _getTabLabel(ReportTabType tab) {
    switch (tab) {
      case ReportTabType.performance:
        return 'Performance';
      case ReportTabType.attendance:
        return 'Attendance';
      case ReportTabType.analytics:
        return 'Analytics';
    }
  }
}

