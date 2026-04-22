import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

enum ServerStatus { online, warning, offline, maintenance }

class ServerInfo {
  final String id;
  final String name;
  final ServerStatus status;
  final double cpuUsage;
  final double memoryUsage;
  final String uptime;
  final String region;

  const ServerInfo({
    required this.id,
    required this.name,
    required this.status,
    required this.cpuUsage,
    required this.memoryUsage,
    required this.uptime,
    required this.region,
  });
}

class ServerStatusCard extends StatelessWidget {
  final bool isDark;
  final List<ServerInfo> servers;
  final Function(ServerInfo) onServerTap;
  final VoidCallback? onViewAll;

  const ServerStatusCard({
    super.key,
    required this.isDark,
    required this.servers,
    required this.onServerTap,
    this.onViewAll,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.dns_outlined,
                    color: AdminColors.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    l10n.serverStatus,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AdminColors.getTextColor(isDark),
                    ),
                  ),
                ],
              ),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: Text(
                    l10n.viewAll,
                    style: TextStyle(fontSize: 13, color: AdminColors.primary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Status Summary
          _buildStatusSummary(l10n),
          const SizedBox(height: 16),
          // Server List
          ...servers.map((server) => _buildServerItem(context, server)),
        ],
      ),
    );
  }

  Widget _buildStatusSummary(AppLocalizations l10n) {
    final online = servers.where((s) => s.status == ServerStatus.online).length;
    final warning = servers
        .where((s) => s.status == ServerStatus.warning)
        .length;
    final offline = servers
        .where((s) => s.status == ServerStatus.offline)
        .length;

    return Row(
      children: [
        _buildStatusBadge(
          count: online,
          label: l10n.online,
          color: AdminColors.success,
        ),
        const SizedBox(width: 16),
        _buildStatusBadge(
          count: warning,
          label: l10n.warning,
          color: AdminColors.warning,
        ),
        const SizedBox(width: 16),
        _buildStatusBadge(
          count: offline,
          label: l10n.offline,
          color: AdminColors.error,
        ),
      ],
    );
  }

  Widget _buildStatusBadge({
    required int count,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$count $label',
          style: TextStyle(
            fontSize: 12,
            color: AdminColors.getTextSecondaryColor(isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildServerItem(BuildContext context, ServerInfo server) {
    final l10n = AppLocalizations.of(context);

    return InkWell(
      onTap: () => onServerTap(server),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AdminColors.darkSurface : AdminColors.lightBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AdminColors.getDividerColor(isDark)),
        ),
        child: Row(
          children: [
            // Status Indicator
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _getStatusColor(server.status),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _getStatusColor(
                      server.status,
                    ).withValues(alpha: 0.4),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Server Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AdminColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      server.region,
                      style: TextStyle(
                        fontSize: 10,
                        color: AdminColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    server.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AdminColors.getTextColor(isDark),
                    ),
                  ),

                  const SizedBox(height: 4),
                  Text(
                    '${l10n.uptime}: ${server.uptime}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AdminColors.getTextTertiaryColor(isDark),
                    ),
                  ),
                ],
              ),
            ),
            // Usage Bars
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildMiniProgress(
                  label: 'CPU',
                  value: server.cpuUsage,
                  color: AdminColors.primary,
                ),
                const SizedBox(height: 4),
                _buildMiniProgress(
                  label: 'RAM',
                  value: server.memoryUsage,
                  color: AdminColors.secondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniProgress({
    required String label,
    required double value,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AdminColors.getTextTertiaryColor(isDark),
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 50,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: AdminColors.getDividerColor(isDark),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '${value.toInt()}%',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AdminColors.getTextSecondaryColor(isDark),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(ServerStatus status) {
    switch (status) {
      case ServerStatus.online:
        return AdminColors.success;
      case ServerStatus.warning:
        return AdminColors.warning;
      case ServerStatus.offline:
        return AdminColors.error;
      case ServerStatus.maintenance:
        return AdminColors.chartPurple;
    }
  }
}
