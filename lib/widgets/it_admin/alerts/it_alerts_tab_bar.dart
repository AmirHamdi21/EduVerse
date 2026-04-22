import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_alerts_barrel.dart';

class ITAlertsTabBar extends StatelessWidget {
  final bool isDark;
  final AlertTab selectedTab;
  final ValueChanged<AlertTab> onTabChanged;

  const ITAlertsTabBar({
    super.key,
    required this.isDark,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: AlertTab.values.map((tab) {
            final isSelected = tab == selectedTab;
            return GestureDetector(
              onTap: () => onTabChanged(tab),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? ITColors.primary : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: isDark
                                ? ITColors.primary.withValues(alpha: 0.3)
                                : Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getTabIcon(tab),
                      size: 16,
                      color: isSelected
                          ? (isDark ? Colors.white : ITColors.primary)
                          : ITColors.textSecondaryColor(isDark),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getTabLabel(tab),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected
                            ? (isDark ? Colors.white : ITColors.primary)
                            : ITColors.textSecondaryColor(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  IconData _getTabIcon(AlertTab tab) {
    switch (tab) {
      case AlertTab.rules:
        return Icons.rule_rounded;
      case AlertTab.channels:
        return Icons.send_rounded;
      case AlertTab.escalation:
        return Icons.trending_up_rounded;
      case AlertTab.suppress:
        return Icons.do_not_disturb_rounded;
      case AlertTab.history:
        return Icons.history_rounded;
    }
  }

  String _getTabLabel(AlertTab tab) {
    switch (tab) {
      case AlertTab.rules:
        return 'Rules';
      case AlertTab.channels:
        return 'Channels';
      case AlertTab.escalation:
        return 'Escalation';
      case AlertTab.suppress:
        return 'Suppress';
      case AlertTab.history:
        return 'History';
    }
  }
}
