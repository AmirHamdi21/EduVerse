import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_integration_barrel.dart';

class ITIntegrationDetailSheet extends StatelessWidget {
  final bool isDark;
  final IntegrationProvider integration;
  final VoidCallback? onConfigure;
  final VoidCallback? onSync;
  final VoidCallback? onDisconnect;
  final VoidCallback? onConnect;
  final VoidCallback? onViewLogs;
  final VoidCallback? onViewDocs;

  const ITIntegrationDetailSheet({
    super.key,
    required this.isDark,
    required this.integration,
    this.onConfigure,
    this.onSync,
    this.onDisconnect,
    this.onConnect,
    this.onViewLogs,
    this.onViewDocs,
  });

  @override
  Widget build(BuildContext context) {
    final isConnected = integration.status == IntegrationStatus.connected;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? ITColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ITColors.textTertiaryColor(isDark),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Header
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: integration.iconBgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    integration.icon,
                    color: integration.iconColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        integration.name,
                        style: TextStyle(
                          color: ITColors.textPrimaryColor(isDark),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            integration.category,
                            style: TextStyle(
                              color: ITColors.textTertiaryColor(isDark),
                              fontSize: 13,
                            ),
                          ),
                          if (integration.version != null) ...[
                            Text(
                              ' • v${integration.version}',
                              style: TextStyle(
                                color: ITColors.textTertiaryColor(isDark),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(),
              ],
            ),
            const SizedBox(height: 20),
            // Description
            Text(
              integration.description,
              style: TextStyle(
                color: ITColors.textSecondaryColor(isDark),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            // Connection settings (if connected)
            if (isConnected && integration.connectionSettings != null) ...[
              _buildSectionTitle('Connection Settings'),
              const SizedBox(height: 12),
              _buildSettingsCard([
                _buildSettingRow('API Endpoint', 
                    integration.connectionSettings!.apiEndpoint ?? 'Not configured'),
                _buildSettingRow('Auto Sync', 
                    integration.connectionSettings!.autoSync ? 'Enabled' : 'Disabled'),
                _buildSettingRow('Sync Interval', 
                    '${integration.connectionSettings!.syncInterval} min'),
                _buildSettingRow('Rate Limit', 
                    '${integration.connectionSettings!.rateLimitPerMinute}/min'),
                _buildSettingRow('Timeout', 
                    '${integration.connectionSettings!.timeout}s'),
              ]),
              const SizedBox(height: 20),
            ],
            // Performance metrics (if connected)
            if (isConnected && integration.performanceMetrics != null) ...[
              _buildSectionTitle('Performance Metrics'),
              const SizedBox(height: 12),
              _buildPerformanceGrid(),
              const SizedBox(height: 20),
            ],
            // Features
            if (integration.features.isNotEmpty) ...[
              _buildSectionTitle('Features'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: integration.features.map((feature) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : ITColors.primarySurface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : ITColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 14,
                          color: ITColors.success,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          feature,
                          style: TextStyle(
                            color: ITColors.textPrimaryColor(isDark),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
            // Quick actions
            _buildSectionTitle('Quick Actions'),
            const SizedBox(height: 12),
            if (isConnected) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.sync_rounded,
                      label: 'Sync Now',
                      color: ITColors.info,
                      onTap: () {
                        Navigator.pop(context);
                        onSync?.call();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.settings_rounded,
                      label: 'Configure',
                      color: ITColors.primary,
                      onTap: () {
                        Navigator.pop(context);
                        onConfigure?.call();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.description_rounded,
                      label: 'View Logs',
                      color: ITColors.purple,
                      onTap: () {
                        Navigator.pop(context);
                        onViewLogs?.call();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.article_rounded,
                      label: 'Documentation',
                      color: ITColors.teal,
                      onTap: () {
                        Navigator.pop(context);
                        onViewDocs?.call();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: _buildActionButton(
                  icon: Icons.power_off_rounded,
                  label: 'Disconnect',
                  color: ITColors.error,
                  onTap: () {
                    Navigator.pop(context);
                    onDisconnect?.call();
                  },
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: _buildActionButton(
                  icon: Icons.power_rounded,
                  label: 'Connect Integration',
                  color: ITColors.success,
                  isPrimary: true,
                  onTap: () {
                    Navigator.pop(context);
                    onConnect?.call();
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: _buildActionButton(
                  icon: Icons.article_rounded,
                  label: 'View Documentation',
                  color: ITColors.teal,
                  onTap: () {
                    Navigator.pop(context);
                    onViewDocs?.call();
                  },
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor;
    String label;

    switch (integration.status) {
      case IntegrationStatus.connected:
        bgColor = ITColors.successLight;
        textColor = ITColors.success;
        label = 'Connected';
        break;
      case IntegrationStatus.disconnected:
        bgColor = isDark
            ? Colors.white.withValues(alpha: 0.1)
            : const Color(0xFFF1F5F9);
        textColor = ITColors.textTertiaryColor(isDark);
        label = 'Disconnected';
        break;
      case IntegrationStatus.pending:
        bgColor = ITColors.warningLight;
        textColor = ITColors.warning;
        label = 'Pending';
        break;
      case IntegrationStatus.error:
        bgColor = ITColors.errorLight;
        textColor = ITColors.error;
        label = 'Error';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: ITColors.textPrimaryColor(isDark),
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : ITColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : ITColors.border,
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: ITColors.textTertiaryColor(isDark),
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: ITColors.textPrimaryColor(isDark),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceGrid() {
    final metrics = integration.performanceMetrics!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : ITColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : ITColors.border,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  'Total Requests',
                  _formatNumber(metrics.totalRequests),
                  Icons.sync_rounded,
                  ITColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  'Success Rate',
                  '${metrics.successRate.toStringAsFixed(1)}%',
                  Icons.check_circle_rounded,
                  ITColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  'Avg Response',
                  '${metrics.averageResponseTime.toStringAsFixed(0)}ms',
                  Icons.speed_rounded,
                  ITColors.info,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  'Uptime',
                  '${metrics.uptimePercentage.toStringAsFixed(2)}%',
                  Icons.timer_rounded,
                  _getUptimeColor(metrics.uptimePercentage),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: ITColors.textTertiaryColor(isDark),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: ITColors.textPrimaryColor(isDark),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isPrimary ? color : color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: isPrimary
                ? null
                : Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isPrimary ? Colors.white : color,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isPrimary ? Colors.white : color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
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
