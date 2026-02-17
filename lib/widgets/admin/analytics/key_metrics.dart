import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

class KeyMetric {
  final String id;
  final String title;
  final String value;
  final String change;
  final bool isPositive;
  final IconData icon;
  final Color color;

  const KeyMetric({
    required this.id,
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.icon,
    required this.color,
  });
}

class KeyMetricsGrid extends StatelessWidget {
  final bool isDark;
  final List<KeyMetric> metrics;
  final Function(KeyMetric) onMetricTap;

  const KeyMetricsGrid({
    super.key,
    required this.isDark,
    required this.metrics,
    required this.onMetricTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        return _buildMetricCard(metrics[index]);
      },
    );
  }

  Widget _buildMetricCard(KeyMetric metric) {
    return InkWell(
      onTap: () => onMetricTap(metric),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AdminColors.getCardColor(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AdminColors.getCardBorderColor(isDark),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: metric.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    metric.icon,
                    size: 20,
                    color: metric.color,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (metric.isPositive ? AdminColors.success : AdminColors.error)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        metric.isPositive
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        size: 12,
                        color: metric.isPositive
                            ? AdminColors.success
                            : AdminColors.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        metric.change,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: metric.isPositive
                              ? AdminColors.success
                              : AdminColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metric.value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.getTextColor(isDark),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  metric.title,
                  style: TextStyle(
                    fontSize: 12,
                    color: AdminColors.getTextSecondaryColor(isDark),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class KeyMetricsRow extends StatelessWidget {
  final bool isDark;
  final List<KeyMetric> metrics;
  final Function(KeyMetric) onMetricTap;

  const KeyMetricsRow({
    super.key,
    required this.isDark,
    required this.metrics,
    required this.onMetricTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.keyMetrics,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AdminColors.getTextColor(isDark),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: metrics.map((metric) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _buildMetricCard(metric),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(KeyMetric metric) {
    return InkWell(
      onTap: () => onMetricTap(metric),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AdminColors.getCardColor(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AdminColors.getCardBorderColor(isDark),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: metric.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    metric.icon,
                    size: 18,
                    color: metric.color,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      metric.isPositive
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 12,
                      color: metric.isPositive
                          ? AdminColors.success
                          : AdminColors.error,
                    ),
                    Text(
                      metric.change,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: metric.isPositive
                            ? AdminColors.success
                            : AdminColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              metric.value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AdminColors.getTextColor(isDark),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              metric.title,
              style: TextStyle(
                fontSize: 12,
                color: AdminColors.getTextSecondaryColor(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
