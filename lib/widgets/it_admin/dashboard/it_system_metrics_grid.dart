import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import '../../../generated_l10n/app_localizations.dart';

class ITSystemMetricsGrid extends StatelessWidget {
  final bool isDark;
  final double cpuUsage;
  final double memoryUsage;
  final double diskUsage;
  final double networkUsage;
  final String apiLatency;
  final String uptime;
  final int activeIncidents;
  final int databaseConnections;

  const ITSystemMetricsGrid({
    super.key,
    required this.isDark,
    required this.cpuUsage,
    required this.memoryUsage,
    required this.diskUsage,
    required this.networkUsage,
    required this.apiLatency,
    required this.uptime,
    required this.activeIncidents,
    required this.databaseConnections,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.analytics_rounded,
              color: ITColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.itSystemMetrics,
              style: TextStyle(
                color: ITColors.textPrimaryColor(isDark),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: [
            _buildMetricCard(
              context,
              title: l10n.itCpuUsage,
              value: '${cpuUsage.toInt()}',
              unit: '%',
              metricType: 'cpu',
              progress: cpuUsage / 100,
              badge: 'CPU',
            ),
            _buildMetricCard(
              context,
              title: l10n.itMemory,
              value: '${memoryUsage.toInt()}',
              unit: '%',
              metricType: 'memory',
              progress: memoryUsage / 100,
              badge: 'RAM',
            ),
            _buildMetricCard(
              context,
              title: l10n.itStorage,
              value: '${diskUsage.toInt()}',
              unit: '%',
              metricType: 'storage',
              progress: diskUsage / 100,
              badge: 'Disk',
            ),
            _buildMetricCard(
              context,
              title: l10n.itApiLatency,
              value: apiLatency.replaceAll('ms', ''),
              unit: 'ms',
              metricType: 'latency',
              badge: 'API',
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSmallMetricCard(
                context,
                title: l10n.itUptime,
                value: uptime,
                icon: Icons.timer_rounded,
                color: ITColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSmallMetricCard(
                context,
                title: l10n.itIncidents,
                value: activeIncidents.toString(),
                icon: Icons.warning_rounded,
                color: activeIncidents > 0 ? ITColors.warning : ITColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSmallMetricCard(
                context,
                title: l10n.itDbConnections,
                value: databaseConnections.toString(),
                icon: Icons.storage_rounded,
                color: ITColors.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required String unit,
    required String metricType,
    double? progress,
    String? badge,
  }) {
    final metricColor = ITColors.getMetricColor(metricType);
    final metricIcon = ITColors.getMetricIcon(metricType);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.8),
        border: Border.all(
          color: ITColors.accent,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: ITColors.cardShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: metricColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(metricIcon, color: metricColor, size: 18),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.1),
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: ITColors.textPrimaryColor(isDark),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: ITColors.textSecondaryColor(isDark),
              fontSize: 11,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: ITColors.textPrimaryColor(isDark),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 2, bottom: 3),
                child: Text(
                  unit,
                  style: TextStyle(
                    color: ITColors.textTertiaryColor(isDark),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 8),
            _buildProgressBar(metricColor, progress),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressBar(Color color, double progress) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: clampedProgress,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : color.withValues(alpha: 0.08),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: ITColors.textPrimaryColor(isDark),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: ITColors.textSecondaryColor(isDark),
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
