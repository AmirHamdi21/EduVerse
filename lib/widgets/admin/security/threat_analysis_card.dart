import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

class ThreatData {
  final String category;
  final int count;
  final Color color;

  const ThreatData({
    required this.category,
    required this.count,
    required this.color,
  });
}

class ThreatAnalysisCard extends StatelessWidget {
  final bool isDark;
  final List<ThreatData> threats;
  final int blockedToday;
  final int blockedThisWeek;
  final VoidCallback onViewDetails;

  const ThreatAnalysisCard({
    super.key,
    required this.isDark,
    required this.threats,
    required this.blockedToday,
    required this.blockedThisWeek,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final totalThreats = threats.fold<int>(0, (sum, t) => sum + t.count);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AdminColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.shield_rounded,
                  color: AdminColors.error,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.threatAnalysis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.getTextColor(isDark),
                      ),
                    ),
                    Text(
                      l10n.threatAnalysisDesc,
                      style: TextStyle(
                        fontSize: 12,
                        color: AdminColors.getTextSecondaryColor(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onViewDetails,
                child: Text(
                  l10n.details,
                  style: TextStyle(color: AdminColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.today_rounded,
                  label: l10n.blockedToday,
                  value: blockedToday.toString(),
                  color: AdminColors.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.date_range_rounded,
                  label: l10n.blockedThisWeek,
                  value: blockedThisWeek.toString(),
                  color: AdminColors.chartOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            l10n.threatBreakdown,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AdminColors.getTextColor(isDark),
            ),
          ),
          const SizedBox(height: 12),
          ...threats.map((threat) => _buildThreatBar(threat, totalThreats)),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: color.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThreatBar(ThreatData threat, int total) {
    final percentage = total > 0 ? (threat.count / total) : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                threat.category,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AdminColors.getTextColor(isDark),
                ),
              ),
              Text(
                '${threat.count} (${(percentage * 100).toInt()}%)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: threat.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: threat.color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(threat.color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
