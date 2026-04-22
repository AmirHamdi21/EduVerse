import 'package:flutter/material.dart';
import '../shared/it_colors.dart';

class ApiQuickActions extends StatelessWidget {
  final bool isDark;
  final VoidCallback onCreateEndpoint;
  final VoidCallback onViewDocs;
  final VoidCallback onViewLogs;

  const ApiQuickActions({
    super.key,
    required this.isDark,
    required this.onCreateEndpoint,
    required this.onViewDocs,
    required this.onViewLogs,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            'New Endpoint',
            Icons.add_link_rounded,
            onCreateEndpoint,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            'Docs',
            Icons.description_outlined,
            onViewDocs,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            'Logs',
            Icons.receipt_long_outlined,
            onViewLogs,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: ITColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ITColors.borderColor(isDark)),
        ),
        child: Column(
          children: [
            Icon(icon, color: ITColors.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: ITColors.textPrimaryColor(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
