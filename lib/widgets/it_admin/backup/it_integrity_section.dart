import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_backup_barrel.dart';

class ITIntegritySection extends StatelessWidget {
  final bool isDark;
  final int verifiedCount;
  final int pendingCount;
  final String autoVerifySchedule;
  final List<IntegrityCheck> recentChecks;
  final VoidCallback? onVerifyNow;
  final VoidCallback? onEditSchedule;

  const ITIntegritySection({
    super.key,
    required this.isDark,
    required this.verifiedCount,
    required this.pendingCount,
    required this.autoVerifySchedule,
    required this.recentChecks,
    this.onVerifyNow,
    this.onEditSchedule,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Integrity & Verification',
              style: TextStyle(
                color: ITColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onVerifyNow,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: ITColors.success,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Verify Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Verify backup integrity and data recoverability',
          style: TextStyle(
            color: ITColors.textTertiaryColor(isDark),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 20),
        // Stats cards
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.check_circle_rounded,
                iconColor: ITColors.success,
                title: 'Verified Backups',
                value: verifiedCount.toString(),
                subtitle: 'Last 7 days',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.pending_rounded,
                iconColor: ITColors.warning,
                title: 'Pending Verification',
                value: pendingCount.toString(),
                subtitle: 'Requires attention',
                isWarning: pendingCount > 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Auto-verify schedule
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? ITColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : ITColors.border,
            ),
            boxShadow: ITColors.lightCardShadow(isDark),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ITColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.schedule_rounded,
                  color: ITColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Auto-Verify Schedule',
                      style: TextStyle(
                        color: ITColors.textTertiaryColor(isDark),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      autoVerifySchedule,
                      style: TextStyle(
                        color: ITColors.textPrimaryColor(isDark),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '08:05:00 UTC',
                      style: TextStyle(
                        color: ITColors.textTertiaryColor(isDark),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onEditSchedule,
                icon: Icon(
                  Icons.edit_rounded,
                  color: ITColors.primary,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Recent checks
        Text(
          'Recent Integrity Checks',
          style: TextStyle(
            color: ITColors.textSecondaryColor(isDark),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (recentChecks.isEmpty)
          _buildEmptyState()
        else
          ...recentChecks.map((check) => _buildCheckCard(check)),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
    bool isWarning = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ITColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWarning
              ? ITColors.warning.withValues(alpha: 0.3)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : ITColors.border),
        ),
        boxShadow: ITColors.lightCardShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: ITColors.textPrimaryColor(isDark),
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: ITColors.textSecondaryColor(isDark),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: ITColors.textTertiaryColor(isDark),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckCard(IntegrityCheck check) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? ITColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: check.passed
              ? ITColors.success.withValues(alpha: 0.2)
              : ITColors.error.withValues(alpha: 0.3),
        ),
        boxShadow: ITColors.lightCardShadow(isDark),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: check.passed ? ITColors.successLight : ITColors.errorLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              check.passed ? Icons.check_circle_rounded : Icons.error_rounded,
              color: check.passed ? ITColors.success : ITColors.error,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  check.backupName,
                  style: TextStyle(
                    color: ITColors.textPrimaryColor(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildTypeBadge(check.type),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimeAgo(check.checkedAt),
                      style: TextStyle(
                        color: ITColors.textTertiaryColor(isDark),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: check.passed ? ITColors.successLight : ITColors.errorLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              check.passed ? 'Passed' : 'Failed',
              style: TextStyle(
                color: check.passed ? ITColors.success : ITColors.error,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(BackupType type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getTypeColor(type).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _getTypeName(type),
        style: TextStyle(
          color: _getTypeColor(type),
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? ITColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : ITColors.border,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.verified_outlined,
            size: 40,
            color: ITColors.textTertiaryColor(isDark),
          ),
          const SizedBox(height: 8),
          Text(
            'No recent checks',
            style: TextStyle(
              color: ITColors.textPrimaryColor(isDark),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(BackupType type) {
    switch (type) {
      case BackupType.full:
        return ITColors.primary;
      case BackupType.incremental:
        return ITColors.teal;
      case BackupType.differential:
        return ITColors.purple;
      case BackupType.snapshot:
        return ITColors.info;
      case BackupType.archive:
        return ITColors.orange;
    }
  }

  String _getTypeName(BackupType type) {
    switch (type) {
      case BackupType.full:
        return 'Full';
      case BackupType.incremental:
        return 'Incr';
      case BackupType.differential:
        return 'Diff';
      case BackupType.snapshot:
        return 'Snap';
      case BackupType.archive:
        return 'Arch';
    }
  }

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
