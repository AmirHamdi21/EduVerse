import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'system_health_models.dart';

class SystemHealthServicesSection extends StatelessWidget {
  final bool isDark;
  final List<HealthService> services;
  final Function(HealthService) onServiceTap;

  const SystemHealthServicesSection({
    super.key,
    required this.isDark,
    required this.services,
    required this.onServiceTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Services Status',
              style: TextStyle(
                color: ITColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: Icon(Icons.refresh_rounded, size: 18, color: ITColors.primary),
              label: Text(
                'Refresh',
                style: TextStyle(color: ITColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...services.map((service) => _buildServiceItem(service)),
      ],
    );
  }

  Widget _buildServiceItem(HealthService service) {
    final statusColor = ITColors.getStatusColor(service.status);

    return GestureDetector(
      onTap: () => onServiceTap(service),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ITColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ITColors.borderColor(isDark)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(service.icon, color: statusColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: TextStyle(
                      color: ITColors.textPrimaryColor(isDark),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    service.description,
                    style: TextStyle(
                      color: ITColors.textSecondaryColor(isDark),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    service.status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${service.uptime.toStringAsFixed(1)}% uptime',
                  style: TextStyle(
                    color: ITColors.textTertiaryColor(isDark),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
