import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'api_models.dart';

class ApiKeysSection extends StatelessWidget {
  final bool isDark;
  final List<ApiKey> apiKeys;
  final Function(ApiKey) onKeyTap;
  final VoidCallback onCreateKey;

  const ApiKeysSection({
    super.key,
    required this.isDark,
    required this.apiKeys,
    required this.onKeyTap,
    required this.onCreateKey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('API Keys', style: TextStyle(color: ITColors.textPrimaryColor(isDark), fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton.icon(
              onPressed: onCreateKey,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Create'),
              style: TextButton.styleFrom(foregroundColor: ITColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...apiKeys.map((key) => _buildKeyCard(key)),
      ],
    );
  }

  Widget _buildKeyCard(ApiKey apiKey) {
    final statusColor = apiKey.status == 'active' ? ITColors.success : ITColors.error;

    return GestureDetector(
      onTap: () => onKeyTap(apiKey),
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
              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.key_rounded, color: statusColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(apiKey.name, style: TextStyle(color: ITColors.textPrimaryColor(isDark), fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('${apiKey.key.substring(0, 8)}...${apiKey.key.substring(apiKey.key.length - 4)}', 
                    style: TextStyle(color: ITColors.textTertiaryColor(isDark), fontFamily: 'monospace', fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('Expires: ${apiKey.expiresAt}', style: TextStyle(color: ITColors.textSecondaryColor(isDark), fontSize: 11)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text(apiKey.status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 6),
                Text('${apiKey.requestsToday} req', style: TextStyle(color: ITColors.textSecondaryColor(isDark), fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
