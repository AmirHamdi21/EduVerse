import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_performance_report_barrel.dart';

class ITPerformanceOverviewCards extends StatelessWidget {
  final bool isDark;
  final List<PerformanceMetric> metrics;
  final VoidCallback? onViewDetails;

  const ITPerformanceOverviewCards({
    super.key,
    required this.isDark,
    required this.metrics,
    this.onViewDetails,
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
              : Colors.grey.withValues(alpha: 0.1),
        ),
        boxShadow: isDark ? null : ITColors.cardShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ITColors.primary.withValues(alpha: 0.2),
                      ITColors.teal.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.dashboard_rounded,
                  color: ITColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Performance Overview',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ITColors.textPrimaryColor(isDark),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Real-time system metrics',
                      style: TextStyle(
                        fontSize: 12,
                        color: ITColors.textSecondaryColor(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              if (onViewDetails != null)
                TextButton(
                  onPressed: onViewDetails,
                  child: Text(
                    'Details',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ITColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Metrics Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: metrics.length,
            itemBuilder: (context, index) {
              return _buildMetricCard(metrics[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(PerformanceMetric metric) {
    final isHighUsage = metric.percentage > 80;
    final isMediumUsage = metric.percentage > 60 && metric.percentage <= 80;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            metric.color.withValues(alpha: isDark ? 0.2 : 0.1),
            metric.color.withValues(alpha: isDark ? 0.1 : 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: metric.color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: metric.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(metric.icon, size: 16, color: metric.color),
              ),
              const Spacer(),
              if (metric.trend != null)
                Row(
                  children: [
                    Icon(
                      metric.isUp
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 14,
                      color: metric.isUp
                          ? (isHighUsage ? ITColors.error : ITColors.success)
                          : ITColors.success,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${metric.trend!.abs().toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: metric.isUp
                            ? (isHighUsage ? ITColors.error : ITColors.success)
                            : ITColors.success,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const Spacer(),
          Text(
            '${metric.value.toStringAsFixed(metric.unit == 'ms' ? 0 : 1)}${metric.unit}',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isHighUsage
                  ? ITColors.error
                  : isMediumUsage
                  ? ITColors.warning
                  : metric.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            metric.name,
            style: TextStyle(
              fontSize: 11,
              color: ITColors.textSecondaryColor(isDark),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          // Progress bar
          Stack(
            children: [
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              FractionallySizedBox(
                widthFactor: metric.percentage / 100,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: isHighUsage
                        ? ITColors.error
                        : isMediumUsage
                        ? ITColors.warning
                        : metric.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
