import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import '../../../generated_l10n/app_localizations.dart';

class ITSystemStatusSection extends StatelessWidget {
  final bool isDark;
  final String overallStatus;
  final List<ServiceStatus> services;
  final VoidCallback? onRefresh;

  const ITSystemStatusSection({
    super.key,
    required this.isDark,
    required this.overallStatus,
    required this.services,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildOverallStatusBadge(l10n),
        const SizedBox(height: 12),
        _buildServiceStatusRow(),
      ],
    );
  }

  Widget _buildOverallStatusBadge(AppLocalizations l10n) {
    final statusColor = ITColors.getStatusColor(overallStatus);
    final isOperational =
        overallStatus.toLowerCase() == 'normal' ||
        overallStatus.toLowerCase() == 'operational';

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isOperational
                    ? Icons.check_circle_rounded
                    : Icons.warning_rounded,
                color: Colors.white,
                size: 14,
              ),
              const SizedBox(width: 8),
              Text(
                '${l10n.itOverall}: ${_getStatusText(overallStatus, l10n)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (onRefresh != null)
          InkWell(
            onTap: onRefresh,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.refresh_rounded,
                    color: ITColors.textSecondaryColor(isDark),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.itRefresh,
                    style: TextStyle(
                      color: ITColors.textSecondaryColor(isDark),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildServiceStatusRow() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: services.map((service) => _buildServiceBadge(service)).toList(),
    );
  }

  Widget _buildServiceBadge(ServiceStatus service) {
    final statusColor = ITColors.getStatusColor(service.status);
    final bgColor = ITColors.getStatusBgColor(service.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: statusColor, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(service.icon, color: statusColor, size: 12),
          const SizedBox(width: 8),
          Text(
            '${service.name}: ${service.statusText}',
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status, AppLocalizations l10n) {
    switch (status.toLowerCase()) {
      case 'normal':
      case 'operational':
        return l10n.itNormal;
      case 'degraded':
        return l10n.itDegraded;
      case 'offline':
        return l10n.itOffline;
      case 'maintenance':
        return l10n.itMaintenance;
      default:
        return status;
    }
  }
}

class ServiceStatus {
  final String name;
  final String status;
  final String statusText;
  final IconData icon;

  ServiceStatus({
    required this.name,
    required this.status,
    required this.statusText,
    required this.icon,
  });
}
