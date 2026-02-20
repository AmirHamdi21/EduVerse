import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_profile_barrel.dart';

class ITProfileTabBar extends StatelessWidget {
  final bool isDark;
  final ProfileTab selectedTab;
  final Function(ProfileTab) onTabChanged;

  const ITProfileTabBar({
    super.key,
    required this.isDark,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: ProfileTab.values.map((tab) {
          final isSelected = tab == selectedTab;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(tab),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? ITColors.darkCard : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getTabIcon(tab),
                        size: 14,
                        color: isSelected
                            ? ITColors.primary
                            : ITColors.textSecondaryColor(isDark),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          _getTabLabel(tab),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isSelected
                                ? ITColors.primary
                                : ITColors.textSecondaryColor(isDark),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getTabIcon(ProfileTab tab) {
    switch (tab) {
      case ProfileTab.personal:
        return Icons.person_outline_rounded;
      case ProfileTab.notifications:
        return Icons.notifications_none_rounded;
      case ProfileTab.security:
        return Icons.security_rounded;
      case ProfileTab.preferences:
        return Icons.tune_rounded;
    }
  }

  String _getTabLabel(ProfileTab tab) {
    switch (tab) {
      case ProfileTab.personal:
        return 'Personal';
      case ProfileTab.notifications:
        return 'Notifications';
      case ProfileTab.security:
        return 'Security';
      case ProfileTab.preferences:
        return 'Preferences';
    }
  }
}
