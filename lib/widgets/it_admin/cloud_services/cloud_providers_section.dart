import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'cloud_models.dart';

class CloudProvidersSection extends StatelessWidget {
  final bool isDark;
  final List<CloudProvider> providers;
  final Function(CloudProvider)? onProviderTap;

  const CloudProvidersSection({
    super.key,
    required this.isDark,
    required this.providers,
    this.onProviderTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Cloud Providers', style: TextStyle(color: ITColors.textPrimaryColor(isDark), fontSize: 18, fontWeight: FontWeight.bold)),
            Text('${providers.length} providers', style: TextStyle(color: ITColors.textSecondaryColor(isDark))),
          ],
        ),
        const SizedBox(height: 16),
        ...providers.map((provider) => _buildProviderCard(provider)),
      ],
    );
  }

  Widget _buildProviderCard(CloudProvider provider) {
    final providerColor = _getProviderColor(provider.logo);

    return GestureDetector(
      onTap: onProviderTap != null ? () => onProviderTap!(provider) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ITColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ITColors.borderColor(isDark)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: providerColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(_getProviderIcon(provider.logo), color: providerColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(provider.name, style: TextStyle(color: ITColors.textPrimaryColor(isDark), fontWeight: FontWeight.w600, fontSize: 16)),
                  Text('${provider.services} services', style: TextStyle(color: ITColors.textSecondaryColor(isDark), fontSize: 12)),
                ],
              ),
            ),
            Text('\$${provider.cost.toStringAsFixed(2)}', 
              style: TextStyle(color: ITColors.textPrimaryColor(isDark), fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  IconData _getProviderIcon(String logo) {
    switch (logo.toLowerCase()) {
      case 'aws': return Icons.cloud_rounded;
      case 'azure': return Icons.cloud_circle_rounded;
      case 'gcp': return Icons.cloud_queue_rounded;
      default: return Icons.cloud_rounded;
    }
  }

  Color _getProviderColor(String logo) {
    switch (logo.toLowerCase()) {
      case 'aws': return const Color(0xFFFF9900);
      case 'azure': return const Color(0xFF0078D4);
      case 'gcp': return const Color(0xFF4285F4);
      default: return ITColors.primary;
    }
  }
}
