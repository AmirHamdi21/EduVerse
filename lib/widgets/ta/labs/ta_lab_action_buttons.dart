import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/ta_colors.dart';

class TALabActionButtons extends StatelessWidget {
  final bool isDark;
  final VoidCallback? onUpload;
  final VoidCallback? onAttendance;
  final VoidCallback? onAIInsights;
  final VoidCallback? onAllLabs;

  const TALabActionButtons({
    super.key,
    required this.isDark,
    this.onUpload,
    this.onAttendance,
    this.onAIInsights,
    this.onAllLabs,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.upload_rounded,
                label: l10n.taLabUpload,
                onTap: onUpload,
                isPrimary: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.people_alt_outlined,
                label: l10n.taLabAttendance,
                onTap: onAttendance,
                isPrimary: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.auto_awesome_rounded,
                label: l10n.taLabAIInsights,
                onTap: onAIInsights,
                isAI: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.grid_view_rounded,
                label: l10n.taLabAllLabs,
                onTap: onAllLabs,
                isPrimary: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    bool isPrimary = false,
    bool isAI = false,
  }) {
    final bgColor = isAI
        ? TAColors.primary
        : (isPrimary
              ? (isDark
                    ? TAColors.primary.withValues(alpha: 0.2)
                    : TAColors.primarySurface)
              : TAColors.cardColor(isDark));

    final textColor = isAI
        ? Colors.white
        : (isPrimary ? TAColors.primary : TAColors.textPrimaryColor(isDark));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isAI
                  ? Colors.transparent
                  : TAColors.primary.withValues(alpha: 0.3),
            ),
            boxShadow: isAI
                ? [
                    BoxShadow(
                      color: TAColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: textColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
