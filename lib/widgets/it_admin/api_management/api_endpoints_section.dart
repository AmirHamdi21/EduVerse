import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'api_models.dart';

class ApiEndpointsSection extends StatelessWidget {
  final bool isDark;
  final List<ApiEndpoint> endpoints;
  final Function(ApiEndpoint) onEndpointTap;

  const ApiEndpointsSection({
    super.key,
    required this.isDark,
    required this.endpoints,
    required this.onEndpointTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Endpoints', style: TextStyle(color: ITColors.textPrimaryColor(isDark), fontSize: 18, fontWeight: FontWeight.bold)),
            Text('${endpoints.length} total', style: TextStyle(color: ITColors.textSecondaryColor(isDark))),
          ],
        ),
        const SizedBox(height: 16),
        ...endpoints.map((endpoint) => _buildEndpointCard(endpoint)),
      ],
    );
  }

  Widget _buildEndpointCard(ApiEndpoint endpoint) {
    final methodColor = _getMethodColor(endpoint.method);
    final statusColor = ITColors.getStatusColor(endpoint.status);

    return GestureDetector(
      onTap: () => onEndpointTap(endpoint),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ITColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ITColors.borderColor(isDark)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: methodColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                  child: Text(endpoint.method, style: TextStyle(color: methodColor, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(endpoint.path, style: TextStyle(color: ITColors.textPrimaryColor(isDark), fontWeight: FontWeight.w500, fontFamily: 'monospace'))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                  child: Text(endpoint.version, style: TextStyle(color: statusColor, fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(endpoint.name, style: TextStyle(color: ITColors.textSecondaryColor(isDark), fontSize: 13)),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildMetric(Icons.trending_up_rounded, '${endpoint.requestsToday} req'),
                const SizedBox(width: 16),
                _buildMetric(Icons.timer_outlined, '${endpoint.avgResponseTime}ms'),
                const SizedBox(width: 16),
                _buildMetric(Icons.check_circle_outline, '${endpoint.successRate}%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: ITColors.textTertiaryColor(isDark), size: 14),
        const SizedBox(width: 4),
        Text(value, style: TextStyle(color: ITColors.textSecondaryColor(isDark), fontSize: 12)),
      ],
    );
  }

  Color _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET': return ITColors.success;
      case 'POST': return ITColors.info;
      case 'PUT': return ITColors.warning;
      case 'PATCH': return Colors.purple;
      case 'DELETE': return ITColors.error;
      default: return ITColors.textSecondaryColor(isDark);
    }
  }
}
