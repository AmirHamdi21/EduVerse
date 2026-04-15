import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'database_models.dart';

class DatabaseListSection extends StatelessWidget {
  final bool isDark;
  final List<DatabaseInstance> databases;
  final Function(DatabaseInstance) onDatabaseTap;

  const DatabaseListSection({
    super.key,
    required this.isDark,
    required this.databases,
    required this.onDatabaseTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Databases',
              style: TextStyle(
                color: ITColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${databases.length} instances',
              style: TextStyle(color: ITColors.textSecondaryColor(isDark)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...databases.map((db) => _buildDatabaseCard(db)),
      ],
    );
  }

  Widget _buildDatabaseCard(DatabaseInstance db) {
    final statusColor = ITColors.getStatusColor(db.status);
    final typeIcon = _getTypeIcon(db.type);

    return GestureDetector(
      onTap: () => onDatabaseTap(db),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ITColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ITColors.borderColor(isDark)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(typeIcon, color: statusColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        db.name,
                        style: TextStyle(
                          color: ITColors.textPrimaryColor(isDark),
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${db.type} ${db.version}',
                        style: TextStyle(
                          color: ITColors.textSecondaryColor(isDark),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    db.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildProgressMetric(
                    'Storage',
                    db.storagePercentage,
                    '${db.storageUsed.toStringAsFixed(1)}/${db.storageTotal.toStringAsFixed(0)} GB',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildProgressMetric(
                    'Connections',
                    db.connectionPercentage,
                    '${db.activeConnections}/${db.maxConnections}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildMetric(Icons.link_rounded, db.host),
                const Spacer(),
                _buildMetric(Icons.speed_rounded, '${db.queryLatency}ms'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressMetric(String label, double percentage, String value) {
    final color = percentage > 80
        ? ITColors.error
        : percentage > 60
        ? ITColors.warning
        : ITColors.success;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: ITColors.textSecondaryColor(isDark),
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: ITColors.textPrimaryColor(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildMetric(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: ITColors.textTertiaryColor(isDark), size: 14),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: ITColors.textSecondaryColor(isDark),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'postgresql':
        return Icons.storage_rounded;
      case 'mysql':
        return Icons.dns_rounded;
      case 'mongodb':
        return Icons.data_array_rounded;
      case 'redis':
        return Icons.memory_rounded;
      default:
        return Icons.storage_rounded;
    }
  }
}
