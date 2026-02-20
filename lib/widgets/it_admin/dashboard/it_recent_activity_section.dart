import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import '../../../generated_l10n/app_localizations.dart';

class ITRecentActivitySection extends StatelessWidget {
  final bool isDark;
  final List<ITActivityItem> activities;
  final VoidCallback? onViewAll;
  final VoidCallback? onClearAll;

  const ITRecentActivitySection({
    super.key,
    required this.isDark,
    required this.activities,
    this.onViewAll,
    this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.white.withValues(alpha: 0.8),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : ITColors.border,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: ITColors.lightCardShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ITColors.teal.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.history_rounded,
                      color: ITColors.teal,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.itRecentActivity,
                    style: TextStyle(
                      color: ITColors.textPrimaryColor(isDark),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (onClearAll != null)
                    TextButton(
                      onPressed: onClearAll,
                      child: Text(
                        l10n.itClear,
                        style: TextStyle(
                          color: ITColors.textTertiaryColor(isDark),
                        ),
                      ),
                    ),
                  if (onViewAll != null)
                    TextButton(
                      onPressed: onViewAll,
                      child: Text(
                        l10n.itViewAll,
                        style: TextStyle(
                          color: ITColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (activities.isEmpty)
            _buildEmptyState(l10n)
          else
            Column(
              children: activities
                  .map((activity) => _buildActivityItem(activity))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              color: ITColors.textTertiaryColor(isDark),
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.itNoRecentActivity,
              style: TextStyle(
                color: ITColors.textSecondaryColor(isDark),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(ITActivityItem activity) {
    final typeColor = _getActivityTypeColor(activity.type);
    final typeIcon = _getActivityTypeIcon(activity.type);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(typeIcon, color: typeColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: TextStyle(
                    color: ITColors.textPrimaryColor(isDark),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity.description,
                  style: TextStyle(
                    color: ITColors.textSecondaryColor(isDark),
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            activity.time,
            style: TextStyle(
              color: ITColors.textTertiaryColor(isDark),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Color _getActivityTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'success':
      case 'deployed':
        return ITColors.success;
      case 'error':
      case 'failed':
        return ITColors.error;
      case 'warning':
        return ITColors.warning;
      case 'info':
        return ITColors.info;
      case 'security':
        return ITColors.purple;
      case 'update':
        return ITColors.secondary;
      case 'backup':
        return ITColors.teal;
      default:
        return ITColors.primary;
    }
  }

  IconData _getActivityTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'success':
      case 'deployed':
        return Icons.check_circle_rounded;
      case 'error':
      case 'failed':
        return Icons.error_rounded;
      case 'warning':
        return Icons.warning_rounded;
      case 'info':
        return Icons.info_rounded;
      case 'security':
        return Icons.security_rounded;
      case 'update':
        return Icons.system_update_rounded;
      case 'backup':
        return Icons.backup_rounded;
      case 'server':
        return Icons.dns_rounded;
      case 'database':
        return Icons.storage_rounded;
      default:
        return Icons.event_note_rounded;
    }
  }
}

class ITActivityItem {
  final String id;
  final String title;
  final String description;
  final String type;
  final String time;

  ITActivityItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.time,
  });
}
