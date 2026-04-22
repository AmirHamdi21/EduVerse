import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'server_models.dart';

class ServerListSection extends StatelessWidget {
  final bool isDark;
  final List<Server> servers;
  final Function(Server) onServerTap;
  final Function(Server) onServerAction;

  const ServerListSection({
    super.key,
    required this.isDark,
    required this.servers,
    required this.onServerTap,
    required this.onServerAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Servers',
          style: TextStyle(
            color: ITColors.textPrimaryColor(isDark),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...servers.map((server) => _buildServerCard(server)),
      ],
    );
  }

  Widget _buildServerCard(Server server) {
    final statusColor = ITColors.getStatusColor(server.status);

    return GestureDetector(
      onTap: () => onServerTap(server),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ITColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ITColors.borderColor(isDark)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.dns_rounded, color: statusColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        server.name,
                        style: TextStyle(
                          color: ITColors.textPrimaryColor(isDark),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          server.status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${server.type} • ${server.ipAddress} • ${server.region}',
                        style: TextStyle(
                          color: ITColors.textSecondaryColor(isDark),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: ITColors.textSecondaryColor(isDark),
                  ),
                  onSelected: (value) => onServerAction(server),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'ssh',
                      child: Text('SSH Connect'),
                    ),
                    const PopupMenuItem(
                      value: 'restart',
                      child: Text('Restart'),
                    ),
                    const PopupMenuItem(
                      value: 'logs',
                      child: Text('View Logs'),
                    ),
                    const PopupMenuItem(
                      value: 'maintenance',
                      child: Text('Maintenance Mode'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _buildResourceBar('CPU', server.cpuUsage, isDark),
                const SizedBox(width: 10),
                _buildResourceBar('RAM', server.memoryUsage, isDark),
                const SizedBox(width: 10),
                _buildResourceBar('Disk', server.diskUsage, isDark),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip(Icons.timer_rounded, server.uptime, isDark),
                const SizedBox(width: 12),
                _buildInfoChip(
                  Icons.people_rounded,
                  '${server.activeConnections} conn',
                  isDark,
                ),
                const SizedBox(width: 12),
                _buildInfoChip(Icons.computer_rounded, server.os, isDark),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceBar(String label, double value, bool isDark) {
    final color = value > 80
        ? ITColors.error
        : value > 60
        ? ITColors.warning
        : ITColors.success;

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
                  color: ITColors.textSecondaryColor(isDark),
                  fontSize: 11,
                ),
              ),
              Text(
                '${value.toInt()}%',
                style: TextStyle(
                  color: ITColors.textPrimaryColor(isDark),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: ITColors.borderColor(isDark),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ITColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: ITColors.textTertiaryColor(isDark)),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: ITColors.textSecondaryColor(isDark),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
