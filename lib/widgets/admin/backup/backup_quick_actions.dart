import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

class BackupQuickActions extends StatelessWidget {
  final bool isDark;
  final bool isBackingUp;
  final bool isExporting;
  final VoidCallback onBackupNow;
  final VoidCallback onExportData;
  final VoidCallback onRestoreBackup;
  final VoidCallback onScheduleBackup;

  const BackupQuickActions({
    super.key,
    required this.isDark,
    required this.isBackingUp,
    required this.isExporting,
    required this.onBackupNow,
    required this.onExportData,
    required this.onRestoreBackup,
    required this.onScheduleBackup,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickActions,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AdminColors.getTextColor(isDark),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context: context,
                icon: Icons.backup_rounded,
                label: l10n.backupNow,
                gradient: AdminColors.primaryGradient,
                isLoading: isBackingUp,
                onTap: onBackupNow,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                context: context,
                icon: Icons.download_rounded,
                label: l10n.exportData,
                gradient: AdminColors.cyanGradient,
                isLoading: isExporting,
                onTap: onExportData,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context: context,
                icon: Icons.restore_rounded,
                label: l10n.restore,
                gradient: AdminColors.purpleGradient,
                onTap: onRestoreBackup,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                context: context,
                icon: Icons.schedule_rounded,
                label: l10n.schedule,
                gradient: AdminColors.greenGradient,
                onTap: onScheduleBackup,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required LinearGradient gradient,
    bool isLoading = false,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              if (isLoading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else
                Icon(icon, color: Colors.white, size: 28),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
