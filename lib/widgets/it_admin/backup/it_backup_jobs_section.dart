import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_backup_barrel.dart';

class ITBackupJobsSection extends StatelessWidget {
  final bool isDark;
  final List<BackupJob> jobs;
  final String selectedFilter;
  final Function(String) onFilterChanged;
  final Function(BackupJob) onJobTap;
  final Function(BackupJob) onRetry;
  final Function(BackupJob) onCancel;
  final VoidCallback? onStartBackup;

  const ITBackupJobsSection({
    super.key,
    required this.isDark,
    required this.jobs,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onJobTap,
    required this.onRetry,
    required this.onCancel,
    this.onStartBackup,
  });

  @override
  Widget build(BuildContext context) {
    final filters = ['All', 'Full', 'Incremental', 'Snapshot', 'Archive'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Backup Jobs',
              style: TextStyle(
                color: ITColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (onStartBackup != null)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onStartBackup,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: ITColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, color: Colors.white, size: 18),
                        SizedBox(width: 4),
                        Text(
                          'New Backup',
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
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filters.map((filter) {
              final isSelected = selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  selected: isSelected,
                  label: Text(filter),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : ITColors.textPrimaryColor(isDark),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 12,
                  ),
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white,
                  selectedColor: ITColors.primary,
                  checkmarkColor: Colors.white,
                  showCheckmark: false,
                  side: BorderSide(
                    color: isSelected
                        ? ITColors.primary
                        : (isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : ITColors.border),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onSelected: (_) => onFilterChanged(filter),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        // Job list
        if (jobs.isEmpty)
          _buildEmptyState()
        else
          ...jobs.map((job) => _buildJobCard(job)),
      ],
    );
  }

  Widget _buildJobCard(BackupJob job) {
    return GestureDetector(
      onTap: () => onJobTap(job),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? ITColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getStatusBorderColor(job.status),
            width: job.status == BackupStatus.running ? 1.5 : 1,
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
                    color: _getTypeColor(job.type).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getTypeIcon(job.type),
                    color: _getTypeColor(job.type),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.name,
                        style: TextStyle(
                          color: ITColors.textPrimaryColor(isDark),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildTypeBadge(job.type),
                      const SizedBox(height: 8),
                      Text(
                        job.target,
                        style: TextStyle(
                          color: ITColors.textTertiaryColor(isDark),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(job.status),
              ],
            ),
            if (job.status == BackupStatus.running) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: job.progress / 100,
                        backgroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : ITColors.primary.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ITColors.primary,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${job.progress.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: ITColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: ITColors.textTertiaryColor(isDark),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTime(job.startTime),
                  style: TextStyle(
                    color: ITColors.textTertiaryColor(isDark),
                    fontSize: 11,
                  ),
                ),
                if (job.duration != null) ...[
                  const SizedBox(width: 12),
                  Icon(
                    Icons.timer_outlined,
                    size: 14,
                    color: ITColors.textTertiaryColor(isDark),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDuration(job.duration!),
                    style: TextStyle(
                      color: ITColors.textTertiaryColor(isDark),
                      fontSize: 11,
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  '${job.sizeGB.toStringAsFixed(1)} GB',
                  style: TextStyle(
                    color: ITColors.textSecondaryColor(isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (job.status == BackupStatus.failed &&
                job.errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ITColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: ITColors.error,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        job.errorMessage!,
                        style: TextStyle(color: ITColors.error, fontSize: 11),
                      ),
                    ),
                    TextButton(
                      onPressed: () => onRetry(job),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Retry',
                        style: TextStyle(
                          color: ITColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (job.status == BackupStatus.running) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => onCancel(job),
                  icon: Icon(
                    Icons.cancel_rounded,
                    size: 16,
                    color: ITColors.error,
                  ),
                  label: Text(
                    'Cancel',
                    style: TextStyle(
                      color: ITColors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: Size.zero,
                  ),
                ),
              ),
            ],
          ],
        ),
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

  Widget _buildStatusBadge(BackupStatus status) {
    Color bgColor;
    Color textColor;
    String label;
    IconData icon;

    switch (status) {
      case BackupStatus.completed:
        bgColor = ITColors.successLight;
        textColor = ITColors.success;
        label = 'Completed';
        icon = Icons.check_circle_rounded;
        break;
      case BackupStatus.running:
        bgColor = ITColors.primarySurface;
        textColor = ITColors.primary;
        label = 'Running';
        icon = Icons.sync_rounded;
        break;
      case BackupStatus.failed:
        bgColor = ITColors.errorLight;
        textColor = ITColors.error;
        label = 'Failed';
        icon = Icons.error_rounded;
        break;
      case BackupStatus.scheduled:
        bgColor = ITColors.infoLight;
        textColor = ITColors.info;
        label = 'Scheduled';
        icon = Icons.schedule_rounded;
        break;
      case BackupStatus.cancelled:
        bgColor = isDark
            ? Colors.white.withValues(alpha: 0.1)
            : const Color(0xFFF1F5F9);
        textColor = ITColors.textTertiaryColor(isDark);
        label = 'Cancelled';
        icon = Icons.cancel_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
            Icons.backup_outlined,
            size: 48,
            color: ITColors.textTertiaryColor(isDark),
          ),
          const SizedBox(height: 12),
          Text(
            'No backup jobs found',
            style: TextStyle(
              color: ITColors.textPrimaryColor(isDark),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Create a new backup to get started',
            style: TextStyle(
              color: ITColors.textTertiaryColor(isDark),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusBorderColor(BackupStatus status) {
    switch (status) {
      case BackupStatus.running:
        return ITColors.primary.withValues(alpha: 0.3);
      case BackupStatus.failed:
        return ITColors.error.withValues(alpha: 0.3);
      default:
        return isDark ? Colors.white.withValues(alpha: 0.1) : ITColors.border;
    }
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

  IconData _getTypeIcon(BackupType type) {
    switch (type) {
      case BackupType.full:
        return Icons.backup_rounded;
      case BackupType.incremental:
        return Icons.add_circle_rounded;
      case BackupType.differential:
        return Icons.difference_rounded;
      case BackupType.snapshot:
        return Icons.camera_rounded;
      case BackupType.archive:
        return Icons.archive_rounded;
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

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${time.day}/${time.month}/${time.year}';
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    }
    return '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
  }
}
