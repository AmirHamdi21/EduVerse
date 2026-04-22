import 'package:flutter/material.dart';
import '../shared/it_colors.dart';

class ServerQuickActions extends StatelessWidget {
  final bool isDark;
  final VoidCallback onAddServer;
  final VoidCallback onBulkAction;
  final VoidCallback onRefresh;

  const ServerQuickActions({
    super.key,
    required this.isDark,
    required this.onAddServer,
    required this.onBulkAction,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.add_rounded,
            label: 'Add Server',
            onTap: onAddServer,
            isPrimary: true,
          ),
        ),
        const SizedBox(width: 10),
        _buildIconButton(Icons.checklist_rounded, onBulkAction),
        const SizedBox(width: 10),
        _buildIconButton(Icons.refresh_rounded, onRefresh),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary ? ITColors.primary : ITColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(12),
          border: isPrimary
              ? null
              : Border.all(color: ITColors.borderColor(isDark)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isPrimary
                  ? Colors.white
                  : ITColors.textPrimaryColor(isDark),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isPrimary
                    ? Colors.white
                    : ITColors.textPrimaryColor(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ITColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ITColors.borderColor(isDark)),
        ),
        child: Icon(icon, color: ITColors.textPrimaryColor(isDark), size: 20),
      ),
    );
  }
}
