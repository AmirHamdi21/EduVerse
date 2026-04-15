import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'cloud_models.dart';

class CloudServicesSection extends StatelessWidget {
  final bool isDark;
  final List<CloudService> services;
  final Function(CloudService) onServiceTap;

  const CloudServicesSection({
    super.key,
    required this.isDark,
    required this.services,
    required this.onServiceTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ITColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ITColors.borderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active Services',
            style: TextStyle(
              color: ITColors.textPrimaryColor(isDark),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...services.map((service) => _buildServiceRow(service)),
        ],
      ),
    );
  }

  Widget _buildServiceRow(CloudService service) {
    final statusColor = ITColors.getStatusColor(service.status);

    return GestureDetector(
      onTap: () => onServiceTap(service),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: ITColors.borderColor(isDark)),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: TextStyle(
                      color: ITColors.textPrimaryColor(isDark),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${service.type} • ${service.region}',
                    style: TextStyle(
                      color: ITColors.textSecondaryColor(isDark),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Text(
                service.provider,
                style: TextStyle(
                  color: ITColors.textSecondaryColor(isDark),
                  fontSize: 12,
                ),
              ),
            ),
            Text(
              '\$${service.monthlyCost.toStringAsFixed(0)}',
              style: TextStyle(
                color: ITColors.textPrimaryColor(isDark),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
