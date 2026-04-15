import 'package:flutter/material.dart';
import '../shared/ta_colors.dart';

class TASessionComparisonCard extends StatelessWidget {
  final String currentSession;
  final String previousSession;
  final List<ComparisonMetric> metrics;
  final bool isDark;

  const TASessionComparisonCard({
    super.key,
    required this.currentSession,
    required this.previousSession,
    required this.metrics,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TAColors.info.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.compare_arrows_rounded,
                  color: TAColors.info,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Session Comparison',
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _buildSessionLabel(currentSession, true)),
              const SizedBox(width: 8),
              Icon(
                Icons.compare_arrows_rounded,
                size: 16,
                color: TAColors.textTertiaryColor(isDark),
              ),
              const SizedBox(width: 8),
              Expanded(child: _buildSessionLabel(previousSession, false)),
            ],
          ),
          const SizedBox(height: 14),
          ...metrics.asMap().entries.map((entry) {
            final index = entry.key;
            final metric = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < metrics.length - 1 ? 10 : 0,
              ),
              child: _buildMetricRow(metric),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSessionLabel(String label, bool isCurrent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isCurrent
            ? TAColors.primary.withValues(alpha: 0.12)
            : TAColors.borderColor(isDark).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isCurrent
              ? TAColors.primary
              : TAColors.textSecondaryColor(isDark),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMetricRow(ComparisonMetric metric) {
    final isPositive = metric.change >= 0;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            metric.name,
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            '${metric.currentValue}%',
            style: TextStyle(
              color: TAColors.textPrimaryColor(isDark),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Text(
            '${metric.previousValue}%',
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          width: 50,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: (isPositive ? TAColors.success : TAColors.error).withValues(
              alpha: 0.12,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPositive
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                size: 10,
                color: isPositive ? TAColors.success : TAColors.error,
              ),
              Text(
                '${isPositive ? '+' : ''}${metric.change}%',
                style: TextStyle(
                  color: isPositive ? TAColors.success : TAColors.error,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ComparisonMetric {
  final String name;
  final int currentValue;
  final int previousValue;
  final int change;

  ComparisonMetric({
    required this.name,
    required this.currentValue,
    required this.previousValue,
    required this.change,
  });
}
