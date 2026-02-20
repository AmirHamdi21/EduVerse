import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_security_logs_barrel.dart';

class ITRolePermissionsSection extends StatelessWidget {
  final bool isDark;
  final List<UserRole> roles;
  final Function(UserRole) onViewPermissions;
  final Function(UserRole) onViewUsers;

  const ITRolePermissionsSection({
    super.key,
    required this.isDark,
    required this.roles,
    required this.onViewPermissions,
    required this.onViewUsers,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Role & Permission Management',
          style: TextStyle(
            color: ITColors.textPrimaryColor(isDark),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...roles.map((role) => _buildRoleCard(role)),
      ],
    );
  }

  Widget _buildRoleCard(UserRole role) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ITColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : ITColors.border,
        ),
        boxShadow: ITColors.lightCardShadow(isDark),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: role.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(role.icon, color: role.color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role.name,
                  style: TextStyle(
                    color: ITColors.textPrimaryColor(isDark),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  role.description,
                  style: TextStyle(
                    color: ITColors.textTertiaryColor(isDark),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.people_rounded, size: 14, color: ITColors.textTertiaryColor(isDark)),
                    const SizedBox(width: 4),
                    Text(
                      '${role.userCount} users',
                      style: TextStyle(
                        color: ITColors.textTertiaryColor(isDark),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              _buildActionButton(
                icon: Icons.admin_panel_settings_outlined,
                label: 'Permissions',
                onTap: () => onViewPermissions(role),
              ),
              const SizedBox(height: 8),
              _buildActionButton(
                icon: Icons.visibility_outlined,
                label: 'View Users',
                onTap: () => onViewUsers(role),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : ITColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : ITColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: ITColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: ITColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
