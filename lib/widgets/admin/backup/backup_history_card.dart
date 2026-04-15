import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

class BackupItem {
  final String id;
  final String name;
  final String size;
  final DateTime date;
  final String type; // 'automatic', 'manual'
  final String status; // 'completed', 'failed', 'in_progress'

  const BackupItem({
    required this.id,
    required this.name,
    required this.size,
    required this.date,
    required this.type,
    required this.status,
  });
}

class BackupHistoryCard extends StatelessWidget {
  final bool isDark;
  final List<BackupItem> backups;
  final Function(BackupItem) onRestore;
  final Function(BackupItem) onDownload;
  final Function(BackupItem) onDelete;
  final VoidCallback onViewAll;

  const BackupHistoryCard({
    super.key,
    required this.isDark,
    required this.backups,
    required this.onRestore,
    required this.onDownload,
    required this.onDelete,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AdminColors.purpleGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.backupHistory,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.getTextColor(isDark),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${backups.length} ${l10n.backupsAvailable}',
                      style: TextStyle(
                        fontSize: 13,
                        color: AdminColors.getTextColor(
                          isDark,
                        ).withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onViewAll,
                child: Text(
                  l10n.viewAll,
                  style: TextStyle(
                    color: AdminColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (backups.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_off_rounded,
                      size: 48,
                      color: AdminColors.getTextColor(
                        isDark,
                      ).withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.noBackups,
                      style: TextStyle(
                        color: AdminColors.getTextColor(
                          isDark,
                        ).withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...backups
                .take(5)
                .map((backup) => _buildBackupItem(context, backup, l10n)),
        ],
      ),
    );
  }

  Widget _buildBackupItem(
    BuildContext context,
    BackupItem backup,
    AppLocalizations l10n,
  ) {
    final isCompleted = backup.status == 'completed';
    final isFailed = backup.status == 'failed';
    final isAutomatic = backup.type == 'automatic';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFailed
              ? AdminColors.error.withValues(alpha: 0.3)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isCompleted
                  ? AdminColors.success.withValues(alpha: 0.15)
                  : (isFailed
                        ? AdminColors.error.withValues(alpha: 0.15)
                        : AdminColors.warning.withValues(alpha: 0.15)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isCompleted
                  ? Icons.cloud_done_rounded
                  : (isFailed
                        ? Icons.cloud_off_rounded
                        : Icons.cloud_sync_rounded),
              color: isCompleted
                  ? AdminColors.success
                  : (isFailed ? AdminColors.error : AdminColors.warning),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        backup.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AdminColors.getTextColor(isDark),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isAutomatic
                            ? AdminColors.primary.withValues(alpha: 0.15)
                            : AdminColors.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isAutomatic ? l10n.auto : l10n.manual,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isAutomatic
                              ? AdminColors.primary
                              : AdminColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 12,
                      color: AdminColors.getTextColor(
                        isDark,
                      ).withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(backup.date),
                      style: TextStyle(
                        fontSize: 12,
                        color: AdminColors.getTextColor(
                          isDark,
                        ).withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.storage_rounded,
                      size: 12,
                      color: AdminColors.getTextColor(
                        isDark,
                      ).withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      backup.size,
                      style: TextStyle(
                        fontSize: 12,
                        color: AdminColors.getTextColor(
                          isDark,
                        ).withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              color: AdminColors.getTextColor(isDark).withValues(alpha: 0.6),
            ),
            color: AdminColors.getCardColor(isDark),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (context) => [
              if (isCompleted)
                PopupMenuItem(
                  value: 'restore',
                  child: Row(
                    children: [
                      Icon(
                        Icons.restore_rounded,
                        size: 18,
                        color: AdminColors.primary,
                      ),
                      const SizedBox(width: 10),
                      Text(l10n.restore),
                    ],
                  ),
                ),
              if (isCompleted)
                PopupMenuItem(
                  value: 'download',
                  child: Row(
                    children: [
                      Icon(
                        Icons.download_rounded,
                        size: 18,
                        color: AdminColors.accent,
                      ),
                      const SizedBox(width: 10),
                      Text(l10n.download),
                    ],
                  ),
                ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: AdminColors.error,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      l10n.delete,
                      style: TextStyle(color: AdminColors.error),
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'restore':
                  onRestore(backup);
                  break;
                case 'download':
                  onDownload(backup);
                  break;
                case 'delete':
                  onDelete(backup);
                  break;
              }
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
