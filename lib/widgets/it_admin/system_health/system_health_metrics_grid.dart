import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'system_health_models.dart';

class SystemHealthMetricsGrid extends StatelessWidget {
  final bool isDark;
  final List<SystemHealthMetric> metrics;
  final Function(SystemHealthMetric) onMetricTap;

  const SystemHealthMetricsGrid({
    super.key,
    required this.isDark,
    required this.metrics,
    required this.onMetricTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Metrics',
          style: TextStyle(
            color: ITColors.textPrimaryColor(isDark),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
          ),
          itemCount: metrics.length,
          itemBuilder: (context, index) {
            final metric = metrics[index];
            return _buildMetricCard(metric);
          },
        ),
      ],
    );
  }

  Widget _buildMetricCard(SystemHealthMetric metric) {
    final statusColor = ITColors.getStatusColor(metric.status);
    final metricColor = ITColors.getMetricColor(metric.name.toLowerCase());
    final percentage = (metric.value / metric.maxValue * 100).clamp(0, 100);

    return GestureDetector(
      onTap: () => onMetricTap(metric),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ITColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ITColors.borderColor(isDark),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(metric.icon, color: metricColor, size: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    metric.trend,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              '${metric.value.toStringAsFixed(1)}${metric.unit}',
              style: TextStyle(
                color: ITColors.textPrimaryColor(isDark),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              metric.name,
              style: TextStyle(
                color: ITColors.textSecondaryColor(isDark),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: ITColors.borderColor(isDark),
                valueColor: AlwaysStoppedAnimation(metricColor),
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
