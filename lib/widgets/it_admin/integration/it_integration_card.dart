import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_integration_barrel.dart';

class ITIntegrationCard extends StatelessWidget {
  final bool isDark;
  final IntegrationProvider integration;
  final VoidCallback? onTap;
  final VoidCallback? onConfigure;
  final VoidCallback? onSync;
  final VoidCallback? onToggleConnection;
  final bool isExpanded;

  const ITIntegrationCard({
    super.key,
    required this.isDark,
    required this.integration,
    this.onTap,
    this.onConfigure,
    this.onSync,
    this.onToggleConnection,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final isConnected = integration.status == IntegrationStatus.connected;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? ITColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isConnected
                ? ITColors.success.withValues(alpha: 0.3)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : ITColors.border),
            width: isConnected ? 1.5 : 1,
          ),
          boxShadow: ITColors.lightCardShadow(isDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: integration.iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    integration.icon,
                    color: integration.iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // Name and category
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              integration.name,
                              style: TextStyle(
                                color: ITColors.textPrimaryColor(isDark),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (integration.isPopular) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: ITColors.warning.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    color: ITColors.warning,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'Popular',
                                    style: TextStyle(
                                      color: ITColors.warning,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            integration.category,
                            style: TextStyle(
                              color: ITColors.textTertiaryColor(isDark),
                              fontSize: 12,
                            ),
                          ),
                          if (integration.version != null) ...[
                            Text(
                              ' • v${integration.version}',
                              style: TextStyle(
                                color: ITColors.textTertiaryColor(isDark),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Status badge
                _buildStatusBadge(),
              ],
            ),
            const SizedBox(height: 12),
            // Description
            Text(
              integration.description,
              style: TextStyle(
                color: ITColors.textSecondaryColor(isDark),
                fontSize: 13,
                height: 1.4,
              ),
              maxLines: isExpanded ? null : 2,
              overflow: isExpanded ? null : TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            // API badges
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (integration.apiType != null)
                  _buildApiBadge(integration.apiType!, Icons.api_rounded),
                if (integration.hasOAuth)
                  _buildApiBadge('OAuth', Icons.key_rounded),
                if (integration.hasApiKey)
                  _buildApiBadge('API Key', Icons.vpn_key_rounded),
              ],
            ),
            if (isConnected && (integration.requestCount != null || integration.uptime != null)) ...[
              const SizedBox(height: 12),
              // Metrics row
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : ITColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (integration.requestCount != null)
                      _buildMetricItem(
                        label: 'Requests',
                        value: _formatNumber(integration.requestCount!),
                        subValue: integration.requestLimit != null
                            ? '/${_formatNumber(integration.requestLimit!)}'
                            : null,
                      ),
                    if (integration.uptime != null)
                      _buildMetricItem(
                        label: 'Uptime',
                        value: '${integration.uptime!.toStringAsFixed(1)}%',
                        valueColor: _getUptimeColor(integration.uptime!),
                      ),
                    if (integration.errorRate != null)
                      _buildMetricItem(
                        label: 'Error Rate',
                        value: '${integration.errorRate!.toStringAsFixed(2)}%',
                        valueColor: _getErrorRateColor(integration.errorRate!),
                      ),
                  ],
                ),
              ),
            ],
            if (integration.lastSync != null || onConfigure != null || onSync != null) ...[
              const SizedBox(height: 12),
              // Footer row
              Row(
                children: [
                  if (integration.lastSync != null)
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.sync_rounded,
                            size: 14,
                            color: ITColors.textTertiaryColor(isDark),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Last sync: ${integration.lastSync}',
                            style: TextStyle(
                              color: ITColors.textTertiaryColor(isDark),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Action buttons
                  if (isConnected) ...[
                    if (onSync != null)
                      _buildActionButton(
                        icon: Icons.sync_rounded,
                        label: 'Sync',
                        onTap: onSync!,
                        color: ITColors.info,
                      ),
                    const SizedBox(width: 8),
                    if (onConfigure != null)
                      _buildActionButton(
                        icon: Icons.settings_rounded,
                        label: 'Configure',
                        onTap: onConfigure!,
                        color: ITColors.primary,
                      ),
                  ] else ...[
                    if (onToggleConnection != null)
                      _buildActionButton(
                        icon: Icons.power_rounded,
                        label: 'Connect',
                        onTap: onToggleConnection!,
                        color: ITColors.success,
                        isPrimary: true,
                      ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor;
    String label;
    IconData icon;

    switch (integration.status) {
      case IntegrationStatus.connected:
        bgColor = ITColors.successLight;
        textColor = ITColors.success;
        label = 'Connected';
        icon = Icons.check_circle_rounded;
        break;
      case IntegrationStatus.disconnected:
        bgColor = isDark
            ? Colors.white.withValues(alpha: 0.1)
            : const Color(0xFFF1F5F9);
        textColor = ITColors.textTertiaryColor(isDark);
        label = 'Disconnected';
        icon = Icons.remove_circle_outline_rounded;
        break;
      case IntegrationStatus.pending:
        bgColor = ITColors.warningLight;
        textColor = ITColors.warning;
        label = 'Pending';
        icon = Icons.pending_rounded;
        break;
      case IntegrationStatus.error:
        bgColor = ITColors.errorLight;
        textColor = ITColors.error;
        label = 'Error';
        icon = Icons.error_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiBadge(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : ITColors.primarySurface,
        borderRadius: BorderRadius.circular(6),
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
            icon,
            size: 12,
            color: isDark ? ITColors.primaryLight : ITColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isDark ? ITColors.primaryLight : ITColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
    String? subValue,
    Color? valueColor,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                color: valueColor ?? ITColors.textPrimaryColor(isDark),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subValue != null)
              Text(
                subValue,
                style: TextStyle(
                  color: ITColors.textTertiaryColor(isDark),
                  fontSize: 11,
                ),
              ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: ITColors.textTertiaryColor(isDark),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
    bool isPrimary = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isPrimary ? color : color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: isPrimary
                ? null
                : Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: isPrimary ? Colors.white : color,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: isPrimary ? Colors.white : color,
                  fontSize: 12,
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

  Color _getErrorRateColor(double errorRate) {
    if (errorRate <= 0.5) return ITColors.success;
    if (errorRate <= 2.0) return ITColors.warning;
    return ITColors.error;
  }
}
