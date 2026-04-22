import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_backup_barrel.dart';

class ITRestoreSection extends StatelessWidget {
  final bool isDark;
  final List<RestorePoint> restorePoints;
  final Function(RestorePoint) onRestore;
  final Function(RestorePoint) onVerify;
  final VoidCallback? onNewRestore;

  const ITRestoreSection({
    super.key,
    required this.isDark,
    required this.restorePoints,
    required this.onRestore,
    required this.onVerify,
    this.onNewRestore,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Restore Workflows',
                  style: TextStyle(
                    color: ITColors.textPrimaryColor(isDark),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Guided restore with safety checks and verification',
                  style: TextStyle(
                    color: ITColors.textTertiaryColor(isDark),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (onNewRestore != null)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onNewRestore,
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
                          Icons.restore_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'New Restore',
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
        const SizedBox(height: 16),
        // Section title
        Text(
          'Available Restore Points',
          style: TextStyle(
            color: ITColors.textSecondaryColor(isDark),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        // Restore points list
        if (restorePoints.isEmpty)
          _buildEmptyState()
        else
          ...restorePoints.map((point) => _buildRestorePointCard(point)),
      ],
    );
  }

  Widget _buildRestorePointCard(RestorePoint point) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ITColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: point.isVerified
              ? ITColors.success.withValues(alpha: 0.3)
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getTypeColor(point.type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.restore_rounded,
                  color: _getTypeColor(point.type),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDateTime(point.timestamp),
                      style: TextStyle(
                        color: ITColors.textPrimaryColor(isDark),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildTypeBadge(point.type),
                        const SizedBox(width: 8),
                        Text(
                          '${point.sizeGB.toStringAsFixed(1)} GB',
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
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildVerificationBadge(point),
                  const SizedBox(height: 8),
                  _buildRestoreButton(point),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.source_rounded,
                size: 14,
                color: ITColors.textTertiaryColor(isDark),
              ),
              const SizedBox(width: 4),
              Text(
                point.source,
                style: TextStyle(
                  color: ITColors.textTertiaryColor(isDark),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(BackupType type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _getTypeColor(type).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _getTypeName(type),
        style: TextStyle(
          color: _getTypeColor(type),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildVerificationBadge(RestorePoint point) {
    if (point.isVerified) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: ITColors.successLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_rounded, color: ITColors.success, size: 12),
            const SizedBox(width: 4),
            Text(
              'Verified',
              style: TextStyle(
                color: ITColors.success,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    } else {
      return GestureDetector(
        onTap: () => onVerify(point),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: ITColors.warningLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.pending_rounded, color: ITColors.warning, size: 12),
              const SizedBox(width: 4),
              Text(
                'Verify',
                style: TextStyle(
                  color: ITColors.warning,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildRestoreButton(RestorePoint point) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onRestore(point),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: ITColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: ITColors.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.replay_rounded, color: ITColors.primary, size: 14),
              const SizedBox(width: 4),
              Text(
                'Restore',
                style: TextStyle(
                  color: ITColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
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
            Icons.restore_outlined,
            size: 48,
            color: ITColors.textTertiaryColor(isDark),
          ),
          const SizedBox(height: 12),
          Text(
            'No restore points available',
            style: TextStyle(
              color: ITColors.textPrimaryColor(isDark),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Complete a backup to create restore points',
            style: TextStyle(
              color: ITColors.textTertiaryColor(isDark),
              fontSize: 13,
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
        return 'Incremental';
      case BackupType.differential:
        return 'Differential';
      case BackupType.snapshot:
        return 'Snapshot';
      case BackupType.archive:
        return 'Archive';
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} UTC';
  }
}
