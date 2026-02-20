import 'package:flutter/material.dart';
import '../shared/it_colors.dart';

class ITProfilePermissionsSection extends StatelessWidget {
  final bool isDark;
  final String role;
  final String accessLevel;
  final List<String> permissions;
  final VoidCallback onViewFullPermissions;

  const ITProfilePermissionsSection({
    super.key,
    required this.isDark,
    required this.role,
    required this.accessLevel,
    required this.permissions,
    required this.onViewFullPermissions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ITColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ITColors.cardShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.shield_rounded,
                size: 18,
                color: ITColors.textSecondaryColor(isDark),
              ),
              const SizedBox(width: 8),
              Text(
                'Role & Permissions',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ITColors.textSecondaryColor(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          
          // Role card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : ITColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : ITColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ITColors.textPrimaryColor(isDark),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: ITColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    accessLevel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: ITColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          
          // Permissions list
          ...permissions.take(5).map((permission) => _buildPermissionItem(permission)),
          
          const SizedBox(height: 12),
          
          // View full permissions
          GestureDetector(
            onTap: onViewFullPermissions,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'View Full Permissions',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ITColors.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: ITColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem(String permission) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 16,
            color: ITColors.success,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              permission,
              style: TextStyle(
                fontSize: 13,
                color: ITColors.textSecondaryColor(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
