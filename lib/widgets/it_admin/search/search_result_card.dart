import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'search_models.dart';

class ITSearchResultCard extends StatelessWidget {
  final bool isDark;
  final ITSearchResult result;
  final VoidCallback onTap;

  const ITSearchResultCard({
    super.key,
    required this.isDark,
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getTypeColor(result.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: ITColors.cardColor(isDark),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: ITColors.borderColor(isDark).withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getTypeIcon(result.type),
                    color: color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.title,
                        style: TextStyle(
                          color: ITColors.textPrimaryColor(isDark),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        result.subtitle,
                        style: TextStyle(
                          color: ITColors.textSecondaryColor(isDark),
                          fontSize: 13,
                        ),
                      ),
                      if (result.timestamp != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          result.timestamp!,
                          style: TextStyle(
                            color: ITColors.textTertiaryColor(isDark),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getTypeLabel(result.type),
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (result.status != 'active') ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getStatusColor(result.status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          result.status.toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(result.status),
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'server':
        return ITColors.primary;
      case 'user':
        return ITColors.info;
      case 'service':
        return ITColors.success;
      case 'alert':
        return ITColors.warning;
      case 'incident':
        return ITColors.error;
      case 'log':
        return const Color(0xFF8B5CF6);
      case 'config':
        return ITColors.teal;
      case 'backup':
        return ITColors.orange;
      default:
        return ITColors.textSecondaryColor(false);
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'server':
        return Icons.dns_rounded;
      case 'user':
        return Icons.person_rounded;
      case 'service':
        return Icons.miscellaneous_services_rounded;
      case 'alert':
        return Icons.notifications_active_rounded;
      case 'incident':
        return Icons.warning_amber_rounded;
      case 'log':
        return Icons.article_rounded;
      case 'config':
        return Icons.settings_rounded;
      case 'backup':
        return Icons.backup_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'server':
        return 'Server';
      case 'user':
        return 'User';
      case 'service':
        return 'Service';
      case 'alert':
        return 'Alert';
      case 'incident':
        return 'Incident';
      case 'log':
        return 'Log';
      case 'config':
        return 'Config';
      case 'backup':
        return 'Backup';
      default:
        return type;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'operational':
      case 'active':
      case 'healthy':
        return ITColors.success;
      case 'degraded':
      case 'warning':
        return ITColors.warning;
      case 'offline':
      case 'error':
      case 'critical':
        return ITColors.error;
      case 'maintenance':
        return ITColors.info;
      default:
        return ITColors.textSecondaryColor(false);
    }
  }
}
