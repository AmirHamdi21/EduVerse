import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_performance_report_barrel.dart';

class ITServerHealthSection extends StatelessWidget {
  final bool isDark;
  final List<ServerHealth> servers;
  final ValueChanged<ServerHealth>? onServerTap;
  final VoidCallback? onViewAll;

  const ITServerHealthSection({
    super.key,
    required this.isDark,
    required this.servers,
    this.onServerTap,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? ITColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.1),
        ),
        boxShadow: isDark ? null : ITColors.cardShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ITColors.teal.withValues(alpha: 0.2),
                      ITColors.success.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.dns_rounded,
                  color: ITColors.teal,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Server Health',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ITColors.textPrimaryColor(isDark),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${servers.where((s) => s.status == ServerStatus.healthy).length}/${servers.length} servers healthy',
                      style: TextStyle(
                        fontSize: 12,
                        color: ITColors.textSecondaryColor(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ITColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Server List
          ...servers.map((server) => _buildServerCard(server)),
          
          if (servers.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.dns_outlined,
                      size: 48,
                      color: ITColors.textSecondaryColor(isDark),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No servers configured',
                      style: TextStyle(
                        fontSize: 14,
                        color: ITColors.textSecondaryColor(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildServerCard(ServerHealth server) {
    return GestureDetector(
      onTap: () => onServerTap?.call(server),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.03)
              : server.statusColor.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : server.statusColor.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: server.statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    server.typeIcon,
                    size: 20,
                    color: server.statusColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        server.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ITColors.textPrimaryColor(isDark),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Uptime: ${server.uptime}',
                        style: TextStyle(
                          fontSize: 11,
                          color: ITColors.textSecondaryColor(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: server.statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: server.statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        server.statusText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: server.statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildMiniMetric('CPU', server.cpuUsage, ITColors.primary),
                const SizedBox(width: 12),
                _buildMiniMetric('Memory', server.memoryUsage, ITColors.purple),
                const SizedBox(width: 12),
                _buildMiniMetric('Disk', server.diskUsage, ITColors.teal),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniMetric(String label, double value, Color color) {
    final isHigh = value > 80;
    final isMedium = value > 60 && value <= 80;
    final displayColor = isHigh ? ITColors.error : isMedium ? ITColors.warning : color;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: ITColors.textSecondaryColor(isDark),
                ),
              ),
              Text(
                '${value.round()}%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: displayColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Stack(
            children: [
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              FractionallySizedBox(
                widthFactor: value / 100,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: displayColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
