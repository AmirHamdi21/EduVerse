import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/ta_colors.dart';

class TAPerformanceQuickStats extends StatelessWidget {
  final bool isDark;
  final int highPerformers;
  final int atRisk;
  final int engagement;
  final int onTrack;
  final VoidCallback? onHighPerformersPressed;
  final VoidCallback? onAtRiskPressed;

  const TAPerformanceQuickStats({
    super.key,
    required this.isDark,
    required this.highPerformers,
    required this.atRisk,
    required this.engagement,
    required this.onTrack,
    this.onHighPerformersPressed,
    this.onAtRiskPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildQuickStatCard(
                  icon: Icons.trending_up_rounded,
                  value: highPerformers.toString(),
                  label: l10n.taPerformanceHighPerformers,
                  subtitle: l10n.taPerformanceScoring85,
                  color: TAColors.success,
                  onTap: onHighPerformersPressed,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickStatCard(
                  icon: Icons.warning_amber_rounded,
                  value: atRisk.toString(),
                  label: l10n.taPerformanceAtRisk,
                  subtitle: l10n.taPerformanceNeedSupport,
                  color: TAColors.error,
                  onTap: onAtRiskPressed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickStatCard(
                  icon: Icons.speed_rounded,
                  value: '$engagement%',
                  label: l10n.taPerformanceEngagement,
                  subtitle: l10n.taPerformanceOverallEngagement,
                  color: TAColors.info,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickStatCard(
                  icon: Icons.check_circle_outline_rounded,
                  value: onTrack.toString(),
                  label: l10n.taPerformanceOnTrack,
                  subtitle: l10n.taPerformanceAllSubmitted,
                  color: TAColors.teal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatCard({
    required IconData icon,
    required String value,
    required String label,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: TAColors.textSecondaryColor(isDark),
                  fontSize: 11,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
