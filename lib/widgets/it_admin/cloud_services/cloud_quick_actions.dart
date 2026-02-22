import 'package:flutter/material.dart';
import '../shared/it_colors.dart';

class CloudQuickActions extends StatelessWidget {
  final bool isDark;
  final VoidCallback onAddService;
  final VoidCallback onViewCosts;
  final VoidCallback onSync;

  const CloudQuickActions({
    super.key,
    required this.isDark,
    required this.onAddService,
    required this.onViewCosts,
    required this.onSync,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildActionButton('Add Service', Icons.add_rounded, onAddService)),
        const SizedBox(width: 12),
        Expanded(child: _buildActionButton('View Costs', Icons.attach_money_rounded, onViewCosts)),
        const SizedBox(width: 12),
        Expanded(child: _buildActionButton('Sync', Icons.sync_rounded, onSync)),
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
            Text(label, style: TextStyle(color: ITColors.textPrimaryColor(isDark), fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
