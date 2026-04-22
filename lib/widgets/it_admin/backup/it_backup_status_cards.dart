import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_backup_barrel.dart';

class ITBackupStatusCards extends StatelessWidget {
  final bool isDark;
  final BackupStats stats;
  final VoidCallback? onViewJobs;
  final VoidCallback? onInvestigate;

  const ITBackupStatusCards({
    super.key,
    required this.isDark,
    required this.stats,
    this.onViewJobs,
    this.onInvestigate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // First row - Backup status
        Row(
          children: [
            Expanded(
              child: _buildStatusCard(
                icon: Icons.access_time_rounded,
                iconColor: ITColors.primary,
                title: 'Last Full Backup',
                value: stats.lastFullBackup,
                subtitle: 'Duration: 45m 32s',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatusCard(
                icon: Icons.check_circle_rounded,
                iconColor: ITColors.success,
                title: 'Successful (24h)',
                value: stats.successful24h.toString(),
                actionLabel: 'View Jobs',
                onAction: onViewJobs,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Second row
        Row(
          children: [
            Expanded(
              child: _buildStatusCard(
                icon: Icons.error_rounded,
                iconColor: ITColors.error,
                title: 'Failed (24h)',
                value: stats.failed24h.toString(),
                actionLabel: stats.failed24h > 0 ? 'Investigate' : null,
                onAction: onInvestigate,
                isWarning: stats.failed24h > 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatusCard(
                icon: Icons.schedule_rounded,
                iconColor: ITColors.info,
                title: 'Next Scheduled',
                value: stats.nextScheduled,
                subtitle: 'User files incremental',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Third row - Storage and Recovery
        Row(
          children: [
            Expanded(child: _buildStorageCard()),
            const SizedBox(width: 12),
            Expanded(child: _buildRecoveryScoreCard()),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    String? subtitle,
    String? actionLabel,
    VoidCallback? onAction,
    bool isWarning = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ITColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWarning
              ? ITColors.error.withValues(alpha: 0.3)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : ITColors.border),
        ),
        boxShadow: ITColors.lightCardShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const Spacer(),
              if (actionLabel != null && onAction != null)
                GestureDetector(
                  onTap: onAction,
                  child: Text(
                    actionLabel,
                    style: TextStyle(
                      color: ITColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: ITColors.textTertiaryColor(isDark),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: ITColors.textPrimaryColor(isDark),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: ITColors.textTertiaryColor(isDark),
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStorageCard() {
    final usagePercent = (stats.storageUsedGB / stats.storageTotalGB * 100)
        .clamp(0, 100);
    final color = usagePercent > 90
        ? ITColors.error
        : usagePercent > 75
        ? ITColors.warning
        : ITColors.success;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ITColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : ITColors.border,
        ),
        boxShadow: ITColors.lightCardShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ITColors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.storage_rounded,
                  color: ITColors.purple,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Storage Used',
            style: TextStyle(
              color: ITColors.textTertiaryColor(isDark),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                stats.storageUsedGB.toStringAsFixed(1),
                style: TextStyle(
                  color: ITColors.textPrimaryColor(isDark),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  'GB',
                  style: TextStyle(
                    color: ITColors.textTertiaryColor(isDark),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: usagePercent / 100,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecoveryScoreCard() {
    final score = stats.recoveryScore;
    final color = score >= 95
        ? ITColors.success
        : score >= 80
        ? ITColors.warning
        : ITColors.error;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ITColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : ITColors.border,
        ),
        boxShadow: ITColors.lightCardShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.verified_rounded, color: color, size: 18),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ITColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: ITColors.success,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'AI Generated',
                      style: TextStyle(
                        color: ITColors.success,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Recovery Score',
            style: TextStyle(
              color: ITColors.textTertiaryColor(isDark),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                score.toString(),
                style: TextStyle(
                  color: ITColors.textPrimaryColor(isDark),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  '/100',
                  style: TextStyle(
                    color: ITColors.textTertiaryColor(isDark),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
