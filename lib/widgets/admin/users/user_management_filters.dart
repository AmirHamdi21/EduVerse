import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

/// Filter section for user management
class UserManagementFilters extends StatelessWidget {
  final bool isDark;
  final String selectedRole;
  final String selectedStatus;
  final bool showInactive;
  final ValueChanged<String> onRoleChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<bool> onInactiveChanged;

  const UserManagementFilters({
    super.key,
    required this.isDark,
    required this.selectedRole,
    required this.selectedStatus,
    required this.showInactive,
    required this.onRoleChanged,
    required this.onStatusChanged,
    required this.onInactiveChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AdminColors.darkCard.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AdminColors.darkCardBorder
              : AdminColors.lightCardBorder,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_list_rounded,
                color: AdminColors.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  value: selectedRole,
                  items: [
                    l10n.allRoles,
                    l10n.student,
                    l10n.instructor,
                    l10n.ta,
                    l10n.admin,
                  ],
                  onChanged: onRoleChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  value: selectedStatus,
                  items: [
                    l10n.allStatus,
                    l10n.active,
                    l10n.inactive,
                    l10n.pending,
                  ],
                  onChanged: onStatusChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildToggleChip(
                icon: Icons.access_time_rounded,
                label: l10n.mostInactive,
                isSelected: showInactive,
                onTap: () => onInactiveChanged(!showInactive),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AdminColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AdminColors.darkCardBorder : AdminColors.lightDivider,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AdminColors.getTextSecondaryColor(isDark),
          ),
          style: TextStyle(
            color: AdminColors.getTextColor(isDark),
            fontSize: 13,
          ),
          dropdownColor: isDark ? AdminColors.darkCard : Colors.white,
          items: items.map((item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: (val) => onChanged(val ?? items.first),
        ),
      ),
    );
  }

  Widget _buildToggleChip({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AdminColors.primary.withValues(alpha: 0.1)
              : (isDark ? AdminColors.darkSurface : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AdminColors.primary
                : (isDark
                      ? AdminColors.darkCardBorder
                      : AdminColors.lightDivider),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? AdminColors.primary
                  : AdminColors.getTextSecondaryColor(isDark),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? AdminColors.primary
                    : AdminColors.getTextColor(isDark),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
