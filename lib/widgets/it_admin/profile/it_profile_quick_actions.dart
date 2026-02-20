import 'package:flutter/material.dart';
import '../shared/it_colors.dart';

class ITProfileQuickActions extends StatelessWidget {
  final bool isDark;
  final VoidCallback onEditProfile;
  final VoidCallback onManageSecurity;
  final VoidCallback onViewActivityLogs;

  const ITProfileQuickActions({
    super.key,
    required this.isDark,
    required this.onEditProfile,
    required this.onManageSecurity,
    required this.onViewActivityLogs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? ITColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ITColors.cardShadow(isDark),
      ),
      child: Column(
        children: [
          _buildActionItem(
            icon: Icons.edit_rounded,
            label: 'Edit Profile',
            onTap: onEditProfile,
          ),
          Divider(
            height: 1,
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.grey.withValues(alpha: 0.15),
          ),
          _buildActionItem(
            icon: Icons.security_rounded,
            label: 'Manage Security',
            onTap: onManageSecurity,
          ),
          Divider(
            height: 1,
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.grey.withValues(alpha: 0.15),
          ),
          _buildActionItem(
            icon: Icons.history_rounded,
            label: 'View Activity Logs',
            onTap: onViewActivityLogs,
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: ITColors.textSecondaryColor(isDark),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: ITColors.textPrimaryColor(isDark),
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: ITColors.textSecondaryColor(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
