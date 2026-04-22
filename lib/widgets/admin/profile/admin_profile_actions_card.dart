import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

class AdminProfileActionsCard extends StatelessWidget {
  final bool isDark;
  final VoidCallback onEditProfile;
  final VoidCallback onChangePassword;
  final VoidCallback onTwoFactorAuth;
  final VoidCallback onExportData;
  final VoidCallback onLogout;

  const AdminProfileActionsCard({
    super.key,
    required this.isDark,
    required this.onEditProfile,
    required this.onChangePassword,
    required this.onTwoFactorAuth,
    required this.onExportData,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AdminColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.settings_rounded,
                  color: AdminColors.secondary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.quickActions,
                style: TextStyle(
                  color: AdminColors.getTextColor(isDark),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildActionItem(
            icon: Icons.edit_rounded,
            label: l10n.editProfile,
            color: AdminColors.primary,
            onTap: onEditProfile,
          ),
          _buildDivider(),
          _buildActionItem(
            icon: Icons.lock_rounded,
            label: l10n.changePassword,
            color: AdminColors.warning,
            onTap: onChangePassword,
          ),
          _buildDivider(),
          _buildActionItem(
            icon: Icons.security_rounded,
            label: l10n.twoFactorAuthentication,
            color: AdminColors.success,
            onTap: onTwoFactorAuth,
          ),
          _buildDivider(),
          _buildActionItem(
            icon: Icons.download_rounded,
            label: l10n.exportMyData,
            color: AdminColors.chartCyan,
            onTap: onExportData,
          ),
          _buildDivider(),
          _buildActionItem(
            icon: Icons.logout_rounded,
            label: l10n.logout,
            color: AdminColors.error,
            onTap: onLogout,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: AdminColors.getDividerColor(isDark));
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isDestructive
                        ? color
                        : AdminColors.getTextColor(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AdminColors.getTextTertiaryColor(isDark),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
