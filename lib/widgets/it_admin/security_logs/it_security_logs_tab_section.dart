import 'package:flutter/material.dart';
import '../shared/it_colors.dart';

class ITSecurityLogsTabSection extends StatelessWidget {
  final bool isDark;
  final int selectedMainTab;
  final int selectedSubTab;
  final Function(int) onMainTabChanged;
  final Function(int) onSubTabChanged;

  const ITSecurityLogsTabSection({
    super.key,
    required this.isDark,
    required this.selectedMainTab,
    required this.selectedSubTab,
    required this.onMainTabChanged,
    required this.onSubTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main tabs
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : ITColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : ITColors.border,
            ),
          ),
          child: Row(
            children: [
              _buildMainTab(0, Icons.article_rounded, 'Security Logs'),
              _buildMainTab(
                1,
                Icons.admin_panel_settings_rounded,
                'Access Control',
              ),
              _buildMainTab(2, Icons.policy_rounded, 'Policies'),
            ],
          ),
        ),
        // Sub tabs for Access Control
        if (selectedMainTab == 1) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              _buildSubTab(0, Icons.pending_actions_rounded, 'Requests'),
              const SizedBox(width: 8),
              _buildSubTab(1, Icons.shield_rounded, 'Policies'),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildMainTab(int index, IconData icon, String label) {
    final isSelected = selectedMainTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onMainTabChanged(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? ITColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: ITColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? Colors.white
                    : ITColors.textTertiaryColor(isDark),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : ITColors.textSecondaryColor(isDark),
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubTab(int index, IconData icon, String label) {
    final isSelected = selectedSubTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onSubTabChanged(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? ITColors.primary.withValues(alpha: 0.1)
                : (isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? ITColors.primary
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : ITColors.border),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? ITColors.primary
                    : ITColors.textSecondaryColor(isDark),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? ITColors.primary
                      : ITColors.textSecondaryColor(isDark),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
