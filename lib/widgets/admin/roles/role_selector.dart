import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

/// Role selector widget for Role & Permissions screen
class RoleSelector extends StatelessWidget {
  final bool isDark;
  final String selectedRole;
  final ValueChanged<String> onRoleChanged;
  final VoidCallback onAddCustomRole;

  const RoleSelector({
    super.key,
    required this.isDark,
    required this.selectedRole,
    required this.onRoleChanged,
    required this.onAddCustomRole,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final roles = [
      _RoleItem(id: 'student', name: l10n.student, icon: Icons.school_rounded),
      _RoleItem(id: 'instructor', name: l10n.instructor, icon: Icons.person_rounded),
      _RoleItem(id: 'ta', name: l10n.ta, icon: Icons.support_agent_rounded),
      _RoleItem(id: 'admin', name: l10n.admin, icon: Icons.admin_panel_settings_rounded),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AdminColors.darkCard.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AdminColors.darkCardBorder : AdminColors.lightCardBorder,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ...roles.map((role) => _buildRoleChip(role)),
            const SizedBox(width: 8),
            _buildAddCustomRoleButton(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleChip(_RoleItem role) {
    final isSelected = selectedRole == role.id;
    final color = _getRoleColor(role.id);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onRoleChanged(role.id),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(colors: [color, color.withValues(alpha: 0.8)])
                  : null,
              color: isSelected
                  ? null
                  : (isDark
                      ? AdminColors.darkSurface.withValues(alpha: 0.5)
                      : Colors.white),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? color
                    : (isDark
                        ? AdminColors.darkCardBorder
                        : AdminColors.lightDivider),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  role.icon,
                  size: 18,
                  color: isSelected
                      ? Colors.white
                      : AdminColors.getTextSecondaryColor(isDark),
                ),
                const SizedBox(width: 8),
                Text(
                  role.name,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : AdminColors.getTextColor(isDark),
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddCustomRoleButton(AppLocalizations l10n) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onAddCustomRole,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isDark
                ? AdminColors.darkSurface.withValues(alpha: 0.5)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AdminColors.darkCardBorder : AdminColors.lightDivider,
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_rounded,
                size: 18,
                color: AdminColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.customRole,
                style: TextStyle(
                  color: AdminColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'student':
        return AdminColors.primary;
      case 'instructor':
        return AdminColors.secondary;
      case 'ta':
        return AdminColors.accent;
      case 'admin':
        return AdminColors.error;
      default:
        return AdminColors.primary;
    }
  }
}

class _RoleItem {
  final String id;
  final String name;
  final IconData icon;

  _RoleItem({required this.id, required this.name, required this.icon});
}
