import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_backup_barrel.dart';

class ITStorageDistributionSection extends StatelessWidget {
  final bool isDark;
  final List<StorageItem> items;
  final double totalUsedGB;
  final double totalCapacityGB;

  const ITStorageDistributionSection({
    super.key,
    required this.isDark,
    required this.items,
    required this.totalUsedGB,
    required this.totalCapacityGB,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? ITColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : ITColors.border,
        ),
        boxShadow: ITColors.lightCardShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Storage Distribution',
                style: TextStyle(
                  color: ITColors.textPrimaryColor(isDark),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ITColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_formatSize(totalUsedGB)} / ${_formatSize(totalCapacityGB)}',
                  style: TextStyle(
                    color: ITColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 12,
              child: Row(
                children: items.asMap().entries.map((entry) {
                  final item = entry.value;
                  final percentage = item.sizeGB / totalCapacityGB;
                  return Expanded(
                    flex: (percentage * 100).toInt().clamp(1, 100),
                    child: Container(
                      color: item.color,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Items list
          ...items.map((item) => _buildStorageItem(item)),
        ],
      ),
    );
  }

  Widget _buildStorageItem(StorageItem item) {
    final percentage = (item.sizeGB / totalUsedGB * 100).toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 12),
          Icon(item.icon, color: item.color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.name,
              style: TextStyle(
                color: ITColors.textSecondaryColor(isDark),
                fontSize: 13,
              ),
            ),
          ),
          Text(
            '$percentage%',
            style: TextStyle(
              color: ITColors.textTertiaryColor(isDark),
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 70,
            child: Text(
              _formatSize(item.sizeGB),
              style: TextStyle(
                color: ITColors.textPrimaryColor(isDark),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _formatSize(double gb) {
    if (gb >= 1000) {
      return '${(gb / 1000).toStringAsFixed(1)} TB';
    }
    return '${gb.toStringAsFixed(0)} GB';
  }
}
