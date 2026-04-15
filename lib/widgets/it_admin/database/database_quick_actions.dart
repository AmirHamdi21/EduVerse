import 'package:flutter/material.dart';
import '../shared/it_colors.dart';

class DatabaseQuickActions extends StatelessWidget {
  final bool isDark;
  final VoidCallback onBackup;
  final VoidCallback onOptimize;
  final VoidCallback onQuery;

  const DatabaseQuickActions({
    super.key,
    required this.isDark,
    required this.onBackup,
    required this.onOptimize,
    required this.onQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton('Backup', Icons.backup_rounded, onBackup),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton('Optimize', Icons.tune_rounded, onOptimize),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton('Query', Icons.code_rounded, onQuery),
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
