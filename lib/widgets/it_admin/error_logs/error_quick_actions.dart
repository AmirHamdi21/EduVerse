import 'package:flutter/material.dart';
import '../shared/it_colors.dart';

class ErrorQuickActions extends StatelessWidget {
  final bool isDark;
  final VoidCallback onExport;
  final VoidCallback onClearResolved;
  final VoidCallback onRefresh;

  const ErrorQuickActions({
    super.key,
    required this.isDark,
    required this.onExport,
    required this.onClearResolved,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildActionButton('Export', Icons.download_rounded, onExport)),
        const SizedBox(width: 12),
        Expanded(child: _buildActionButton('Clear Resolved', Icons.cleaning_services_rounded, onClearResolved)),
        const SizedBox(width: 12),
        Expanded(child: _buildActionButton('Refresh', Icons.refresh_rounded, onRefresh)),
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
            Text(label, style: TextStyle(color: ITColors.textPrimaryColor(isDark), fontSize: 11, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
