import 'package:flutter/material.dart';
import '../shared/it_colors.dart';

class ITMetricCard extends StatelessWidget {
  final bool isDark;
  final String title;
  final String value;
  final String unit;
  final String metricType;
  final String? subtitle;
  final double? progress;
  final String? badge;
  final Color? badgeColor;
  final Widget? chart;
  final VoidCallback? onTap;

  const ITMetricCard({
    super.key,
    required this.isDark,
    required this.title,
    required this.value,
    required this.unit,
    required this.metricType,
    this.subtitle,
    this.progress,
    this.badge,
    this.badgeColor,
    this.chart,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final metricColor = ITColors.getMetricColor(metricType);
    final metricIcon = ITColors.getMetricIcon(metricType);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.8),
          border: Border.all(color: ITColors.accent, width: 1),
          borderRadius: BorderRadius.circular(24),
          boxShadow: ITColors.cardShadow(isDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: metricColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(metricIcon, color: metricColor, size: 24),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          badgeColor?.withValues(alpha: 0.1) ??
                          Colors.black.withValues(alpha: 0.05),
                      border: Border.all(
                        color:
                            badgeColor?.withValues(alpha: 0.3) ??
                            Colors.black.withValues(alpha: 0.1),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badge!,
                      style: TextStyle(
                        color: badgeColor ?? ITColors.textPrimaryColor(isDark),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Subtitle
            Text(
              title,
              style: TextStyle(
                color: ITColors.textSecondaryColor(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),

            // Value
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: ITColors.textPrimaryColor(isDark),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (unit.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(
                      unit,
                      style: TextStyle(
                        color: ITColors.textTertiaryColor(isDark),
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),

            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(
                  color: ITColors.textTertiaryColor(isDark),
                  fontSize: 12,
                ),
              ),
            ],

            // Progress bar
            if (progress != null) ...[
              const SizedBox(height: 12),
              _buildProgressBar(metricColor),
            ],

            // Chart
            if (chart != null) ...[const SizedBox(height: 12), chart!],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(Color color) {
    final clampedProgress = (progress ?? 0).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Usage',
              style: TextStyle(
                color: ITColors.textTertiaryColor(isDark),
                fontSize: 11,
              ),
            ),
            Text(
              '${(clampedProgress * 100).toInt()}%',
              style: TextStyle(
                color: ITColors.textSecondaryColor(isDark),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: clampedProgress,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ITMetricMiniCard extends StatelessWidget {
  final bool isDark;
  final String label;
  final String value;
  final Color? color;
  final IconData? icon;

  const ITMetricMiniCard({
    super.key,
    required this.isDark,
    required this.label,
    required this.value,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (color ?? ITColors.primary).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color ?? ITColors.primary, size: 14),
            const SizedBox(width: 6),
          ],
          Text(
            '$label: ',
            style: TextStyle(
              color: ITColors.textTertiaryColor(isDark),
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color ?? ITColors.textPrimaryColor(isDark),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
