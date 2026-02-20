import 'package:flutter/material.dart';
import '../shared/it_colors.dart';

class ITIntegrationStatsCard extends StatelessWidget {
  final bool isDark;
  final int totalIntegrations;
  final int connectedCount;
  final int activeApiCalls;
  final double overallUptime;
  final VoidCallback? onAddIntegration;

  const ITIntegrationStatsCard({
    super.key,
    required this.isDark,
    required this.totalIntegrations,
    required this.connectedCount,
    required this.activeApiCalls,
    required this.overallUptime,
    this.onAddIntegration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                colors: [
                  ITColors.primary.withValues(alpha: 0.3),
                  ITColors.primaryDark.withValues(alpha: 0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [
                  ITColors.primarySurface,
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? ITColors.primary.withValues(alpha: 0.3)
              : ITColors.primary.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: ITColors.primary.withValues(alpha: isDark ? 0.2 : 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: ITColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.hub_rounded,
                      color: ITColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Integration Overview',
                        style: TextStyle(
                          color: ITColors.textPrimaryColor(isDark),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Real-time connection status',
                        style: TextStyle(
                          color: ITColors.textTertiaryColor(isDark),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (onAddIntegration != null)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onAddIntegration,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: ITColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Add',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          // Stats grid
          Row(
            children: [
              Expanded(
                child: _buildStatTile(
                  icon: Icons.apps_rounded,
                  label: 'Total',
                  value: totalIntegrations.toString(),
                  color: ITColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatTile(
                  icon: Icons.check_circle_rounded,
                  label: 'Connected',
                  value: connectedCount.toString(),
                  color: ITColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatTile(
                  icon: Icons.sync_rounded,
                  label: 'API Calls',
                  value: _formatNumber(activeApiCalls),
                  color: ITColors.info,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatTile(
                  icon: Icons.timer_rounded,
                  label: 'Uptime',
                  value: '${overallUptime.toStringAsFixed(1)}%',
                  color: _getUptimeColor(overallUptime),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : ITColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: ITColors.textPrimaryColor(isDark),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: ITColors.textTertiaryColor(isDark),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  Color _getUptimeColor(double uptime) {
    if (uptime >= 99.5) return ITColors.success;
    if (uptime >= 99.0) return ITColors.warning;
    return ITColors.error;
  }
}
