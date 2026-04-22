import 'package:flutter/material.dart';
import '../shared/ta_colors.dart';
import '../../../generated_l10n/app_localizations.dart';

class TAGradingStatsCard extends StatelessWidget {
  final bool isDark;
  final int total;
  final int pending;
  final int reviewed;
  final int late;

  const TAGradingStatsCard({
    super.key,
    required this.isDark,
    required this.total,
    required this.pending,
    required this.reviewed,
    required this.late,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  label: l10n.taGradingTotal,
                  value: total.toString(),
                  icon: Icons.description_outlined,
                  color: TAColors.textPrimaryColor(isDark),
                  bgColor: TAColors.scaffoldColor(isDark),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  label: l10n.taGradingPending,
                  value: pending.toString(),
                  icon: Icons.hourglass_empty_rounded,
                  color: TAColors.warning,
                  bgColor: TAColors.warning.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  label: l10n.taGradingReviewed,
                  value: reviewed.toString(),
                  icon: Icons.check_circle_outline_rounded,
                  color: TAColors.success,
                  bgColor: TAColors.success.withValues(alpha: 0.1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  label: l10n.taGradingLate,
                  value: late.toString(),
                  icon: Icons.schedule_rounded,
                  color: TAColors.error,
                  bgColor: TAColors.error.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: TAColors.textSecondaryColor(isDark),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Spacer(),
          Icon(icon, color: color, size: 22),
        ],
      ),
    );
  }
}
