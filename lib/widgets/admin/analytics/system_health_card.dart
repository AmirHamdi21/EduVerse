import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

class SystemHealthCard extends StatelessWidget {
  final bool isDark;
  final double healthPercent;
  final double cpuUsage;
  final double memoryUsage;
  final double diskUsage;
  final double networkLatency;

  const SystemHealthCard({
    super.key,
    required this.isDark,
    required this.healthPercent,
    required this.cpuUsage,
    required this.memoryUsage,
    required this.diskUsage,
    required this.networkLatency,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
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
            children: [
              Icon(
                Icons.monitor_heart_outlined,
                color: AdminColors.primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                l10n.systemHealthOverview,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AdminColors.getTextColor(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Circular Health Gauge using CircularProgressIndicator
          Center(
            child: SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background track
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 12,
                      strokeCap: StrokeCap.round,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AdminColors.getDividerColor(isDark),
                      ),
                    ),
                  ),
                  // Progress arc — starts at top (12 o'clock) by default
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: healthPercent / 100,
                      strokeWidth: 12,
                      strokeCap: StrokeCap.round,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getHealthColor(healthPercent),
                      ),
                    ),
                  ),
                  // Center text
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${healthPercent.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: _getHealthColor(healthPercent),
                        ),
                      ),
                      Text(
                        _getHealthStatus(healthPercent, l10n),
                        style: TextStyle(
                          fontSize: 13,
                          color: AdminColors.getTextSecondaryColor(isDark),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Status Indicators
          _buildStatusRow(
            icon: Icons.memory_rounded,
            label: l10n.cpuUsage,
            value: cpuUsage,
            color: AdminColors.primary,
          ),
          const SizedBox(height: 12),
          _buildStatusRow(
            icon: Icons.storage_rounded,
            label: l10n.memoryUsage,
            value: memoryUsage,
            color: AdminColors.secondary,
          ),
          const SizedBox(height: 12),
          _buildStatusRow(
            icon: Icons.disc_full_rounded,
            label: l10n.diskUsage,
            value: diskUsage,
            color: AdminColors.chartCyan,
          ),
          const SizedBox(height: 12),
          _buildStatusRow(
            icon: Icons.network_check_rounded,
            label: l10n.networkLatency,
            value: networkLatency,
            suffix: 'ms',
            maxValue: 500,
            color: AdminColors.chartGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow({
    required IconData icon,
    required String label,
    required double value,
    required Color color,
    String suffix = '%',
    double maxValue = 100,
  }) {
    final progress = value / maxValue;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: AdminColors.getTextSecondaryColor(isDark),
                  ),
                ),
              ],
            ),
            Text(
              '${value.toStringAsFixed(suffix == 'ms' ? 0 : 1)}$suffix',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AdminColors.getTextColor(isDark),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: AdminColors.getDividerColor(isDark),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Color _getHealthColor(double percent) {
    if (percent >= 90) return AdminColors.success;
    if (percent >= 70) return AdminColors.chartCyan;
    if (percent >= 50) return AdminColors.warning;
    return AdminColors.error;
  }

  String _getHealthStatus(double percent, AppLocalizations l10n) {
    if (percent >= 90) return l10n.excellent;
    if (percent >= 70) return l10n.good;
    if (percent >= 50) return l10n.fair;
    return l10n.poor;
  }
}
