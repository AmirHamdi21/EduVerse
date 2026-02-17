import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

class UserActivityData {
  final String label;
  final double value;
  final Color? color;

  const UserActivityData({
    required this.label,
    required this.value,
    this.color,
  });
}

class UserActivityChart extends StatelessWidget {
  final bool isDark;
  final List<UserActivityData> data;
  final String title;
  final VoidCallback? onViewMore;

  const UserActivityChart({
    super.key,
    required this.isDark,
    required this.data,
    required this.title,
    this.onViewMore,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.bar_chart_rounded,
                    color: AdminColors.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AdminColors.getTextColor(isDark),
                    ),
                  ),
                ],
              ),
              if (onViewMore != null)
                TextButton(
                  onPressed: onViewMore,
                  child: Text(
                    l10n.viewMore,
                    style: TextStyle(
                      fontSize: 13,
                      color: AdminColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final barHeight = (item.value / maxValue) * 160;
                final color = item.color ?? _getBarColor(index);
                
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Value label
                        Text(
                          _formatValue(item.value),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AdminColors.getTextSecondaryColor(isDark),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Bar
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutCubic,
                          width: double.infinity,
                          height: barHeight.clamp(8.0, 160.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                color,
                                color.withValues(alpha: 0.7),
                              ],
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Label
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 11,
                            color: AdminColors.getTextTertiaryColor(isDark),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBarColor(int index) {
    final colors = [
      AdminColors.primary,
      AdminColors.secondary,
      AdminColors.chartCyan,
      AdminColors.chartGreen,
      AdminColors.chartOrange,
      AdminColors.chartPink,
      AdminColors.chartPurple,
    ];
    return colors[index % colors.length];
  }

  String _formatValue(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}
