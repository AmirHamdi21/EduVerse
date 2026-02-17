import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

enum TimePeriod { today, thisWeek, thisMonth, custom }

class AnalyticsFilters extends StatelessWidget {
  final bool isDark;
  final TimePeriod selectedPeriod;
  final ValueChanged<TimePeriod> onPeriodChanged;
  final VoidCallback onCustomDateRange;

  const AnalyticsFilters({
    super.key,
    required this.isDark,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    required this.onCustomDateRange,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildPeriodChip(
            label: l10n.today,
            period: TimePeriod.today,
            icon: Icons.today_rounded,
          ),
          const SizedBox(width: 8),
          _buildPeriodChip(
            label: l10n.thisWeek,
            period: TimePeriod.thisWeek,
            icon: Icons.date_range_rounded,
          ),
          const SizedBox(width: 8),
          _buildPeriodChip(
            label: l10n.thisMonth,
            period: TimePeriod.thisMonth,
            icon: Icons.calendar_month_rounded,
          ),
          const SizedBox(width: 8),
          _buildPeriodChip(
            label: l10n.custom,
            period: TimePeriod.custom,
            icon: Icons.tune_rounded,
            onTap: onCustomDateRange,
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip({
    required String label,
    required TimePeriod period,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    final isSelected = selectedPeriod == period;
    return InkWell(
      onTap: onTap ?? () => onPeriodChanged(period),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AdminColors.primary
              : AdminColors.getCardColor(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AdminColors.primary
                : AdminColors.getCardBorderColor(isDark),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? Colors.white
                  : AdminColors.getTextSecondaryColor(isDark),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : AdminColors.getTextColor(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
