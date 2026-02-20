import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import '../../../generated_l10n/app_localizations.dart';

class ITServerStatusSection extends StatelessWidget {
  final bool isDark;
  final List<ServerInfo> servers;
  final VoidCallback? onViewAll;
  final Function(ServerInfo)? onServerTap;
  final Function(ServerInfo)? onRestart;

  const ITServerStatusSection({
    super.key,
    required this.isDark,
    required this.servers,
    this.onViewAll,
    this.onServerTap,
    this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.white.withValues(alpha: 0.8),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : ITColors.border,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: ITColors.lightCardShadow(isDark),
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
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ITColors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.dns_rounded,
                      color: ITColors.secondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.itServerStatus,
                        style: TextStyle(
                          color: ITColors.textPrimaryColor(isDark),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${servers.length} ${l10n.itServers.toLowerCase()}',
                        style: TextStyle(
                          color: ITColors.textTertiaryColor(isDark),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: Text(
                    l10n.itViewAll,
                    style: TextStyle(
                      color: ITColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ...servers.map((server) => _buildServerItem(server, l10n)),
        ],
      ),
    );
  }

  Widget _buildServerItem(ServerInfo server, AppLocalizations l10n) {
    final statusColor = ITColors.getStatusColor(server.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onServerTap?.call(server),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : ITColors.surface,
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : ITColors.border,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withValues(alpha: 0.5),
                            blurRadius: 6,
                          ),
                        ],
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
                              color: ITColors.textPrimaryColor(isDark),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            server.type,
                            style: TextStyle(
                              color: ITColors.textTertiaryColor(isDark),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        server.status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (onRestart != null &&
                        server.status.toLowerCase() != 'offline') ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => onRestart?.call(server),
                        icon: Icon(
                          Icons.restart_alt_rounded,
                          color: ITColors.textSecondaryColor(isDark),
                          size: 20,
                        ),
                        tooltip: l10n.itRestart,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildMetricChip(
                      Icons.memory_rounded,
                      'CPU: ${server.cpuUsage}%',
                      ITColors.cyan,
                    ),
                    const SizedBox(width: 8),
                    _buildMetricChip(
                      Icons.storage_rounded,
                      'RAM: ${server.memoryUsage}%',
                      ITColors.purple,
                    ),
                    const SizedBox(width: 8),
                    _buildMetricChip(
                      Icons.sd_storage_rounded,
                      '${server.diskUsage}% Disk',
                      ITColors.orange,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class ServerInfo {
  final String id;
  final String name;
  final String type;
  final String status;
  final int cpuUsage;
  final int memoryUsage;
  final int diskUsage;
  final String uptime;

  ServerInfo({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.cpuUsage,
    required this.memoryUsage,
    required this.diskUsage,
    required this.uptime,
  });
}
