import 'package:flutter/material.dart';
import 'create_assignment_colors.dart';

class ActionButtons extends StatelessWidget {
  final bool isDark;
  final VoidCallback onDraft;
  final VoidCallback onPreview;
  final VoidCallback onSchedule;
  final VoidCallback onAssign;
  final bool isAssignEnabled;

  const ActionButtons({
    super.key,
    required this.isDark,
    required this.onDraft,
    required this.onPreview,
    required this.onSchedule,
    required this.onAssign,
    this.isAssignEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Secondary Actions Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSecondaryButton(
              icon: Icons.save_outlined,
              label: 'Draft',
              onTap: onDraft,
            ),
            const SizedBox(width: 24),
            _buildSecondaryButton(
              icon: Icons.visibility_outlined,
              label: 'Preview',
              onTap: onPreview,
            ),
            const SizedBox(width: 24),
            _buildSecondaryButton(
              icon: Icons.schedule_outlined,
              label: 'Schedule',
              onTap: onSchedule,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Primary Action Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isAssignEnabled ? onAssign : null,
            icon: const Icon(Icons.send_rounded, size: 18),
            label: const Text('Assign to Class'),
            style: ElevatedButton.styleFrom(
              backgroundColor: CreateAssignmentColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: CreateAssignmentColors.primary.withValues(alpha: 0.5),
              disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: CreateAssignmentColors.textSecondaryColor(isDark),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: CreateAssignmentColors.textSecondaryColor(isDark),
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
