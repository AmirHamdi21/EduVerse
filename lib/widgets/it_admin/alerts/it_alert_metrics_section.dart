import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_alerts_barrel.dart';

class ITAlertMetricsSection extends StatelessWidget {
  final bool isDark;
  final List<AlertMetric> metrics;
  final List<NoisyRule> noisyRules;

  const ITAlertMetricsSection({
    super.key,
    required this.isDark,
    required this.metrics,
    required this.noisyRules,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Alert Metrics
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? ITColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: ITColors.cardShadow(isDark),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Alert Metrics',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ITColors.textPrimaryColor(isDark),
                ),
              ),
              const SizedBox(height: 16),
              ...metrics.map((metric) => _buildMetricRow(metric)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Top Noisy Rules
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? ITColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: ITColors.cardShadow(isDark),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Top Noisy Rules',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ITColors.textPrimaryColor(isDark),
                ),
              ),
              const SizedBox(height: 16),
              ...noisyRules.map((rule) => _buildNoisyRuleRow(rule)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricRow(AlertMetric metric) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              metric.name,
              style: TextStyle(
                fontSize: 14,
                color: ITColors.textSecondaryColor(isDark),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${metric.value}${metric.unit ?? ''}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ITColors.textPrimaryColor(isDark),
                ),
              ),
              if (metric.change != null) ...[
                const SizedBox(width: 8),
                Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (metric.change! / 100).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: metric.isUp ? ITColors.success : ITColors.error,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoisyRuleRow(NoisyRule rule) {
    final maxCount = noisyRules.isNotEmpty
        ? noisyRules.map((r) => r.count).reduce((a, b) => a > b ? a : b)
        : 1;
    final progress = rule.count / maxCount;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  rule.name,
                  style: TextStyle(
                    fontSize: 14,
                    color: ITColors.textPrimaryColor(isDark),
                  ),
                ),
              ),
              Text(
                rule.count.toString(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ITColors.textSecondaryColor(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [ITColors.warning, ITColors.orange],
                    ),
                    borderRadius: BorderRadius.circular(3),
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
