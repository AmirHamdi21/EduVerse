import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

class LoginActivityData {
  final String hour;
  final int successCount;
  final int failedCount;

  const LoginActivityData({
    required this.hour,
    required this.successCount,
    required this.failedCount,
  });
}

class LoginActivityChart extends StatelessWidget {
  final bool isDark;
  final List<LoginActivityData> data;
  final VoidCallback? onViewDetails;

  const LoginActivityChart({
    super.key,
    required this.isDark,
    required this.data,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final maxValue = data.fold<int>(0, (max, item) {
      final total = item.successCount + item.failedCount;
      return total > max ? total : max;
    });

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
                    Icons.login_rounded,
                    color: AdminColors.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    l10n.loginActivity,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AdminColors.getTextColor(isDark),
                    ),
                  ),
                ],
              ),
              if (onViewDetails != null)
                TextButton(
                  onPressed: onViewDetails,
                  child: Text(
                    l10n.viewDetails,
                    style: TextStyle(
                      fontSize: 13,
                      color: AdminColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Legend
          Row(
            children: [
              _buildLegendItem(
                color: AdminColors.success,
                label: l10n.successful,
              ),
              const SizedBox(width: 20),
              _buildLegendItem(
                color: AdminColors.error,
                label: l10n.failed,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Chart
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((item) {
                final successHeight = maxValue > 0
                    ? (item.successCount / maxValue) * 140
                    : 0.0;
                final failedHeight = maxValue > 0
                    ? (item.failedCount / maxValue) * 140
                    : 0.0;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Stacked Bars
                        Column(
                          children: [
                            // Failed (top)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOutCubic,
                              width: double.infinity,
                              height: failedHeight.clamp(0.0, 140.0),
                              decoration: BoxDecoration(
                                color: AdminColors.error,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                              ),
                            ),
                            // Success (bottom)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOutCubic,
                              width: double.infinity,
                              height: successHeight.clamp(0.0, 140.0),
                              decoration: BoxDecoration(
                                color: AdminColors.success,
                                borderRadius: failedHeight > 0
                                    ? null
                                    : const BorderRadius.vertical(
                                        top: Radius.circular(4),
                                      ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Label
                        Text(
                          item.hour,
                          style: TextStyle(
                            fontSize: 10,
                            color: AdminColors.getTextTertiaryColor(isDark),
                          ),
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

  Widget _buildLegendItem({
    required Color color,
    required String label,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AdminColors.getTextSecondaryColor(isDark),
          ),
        ),
      ],
    );
  }
}
