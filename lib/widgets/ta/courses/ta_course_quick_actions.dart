import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/ta_colors.dart';

class TACourseQuickActions extends StatelessWidget {
  final bool isDark;
  final VoidCallback? onViewLabs;
  final VoidCallback? onViewSubmissions;
  final VoidCallback? onViewDiscussions;
  final VoidCallback? onAIInsights;

  const TACourseQuickActions({
    super.key,
    required this.isDark,
    this.onViewLabs,
    this.onViewSubmissions,
    this.onViewDiscussions,
    this.onAIInsights,
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
                icon: Icons.science_outlined,
                label: l10n.taCourseViewLabs,
                onTap: onViewLabs,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.task_alt_rounded,
                label: l10n.taCourseSubmissions,
                onTap: onViewSubmissions,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.forum_outlined,
                label: l10n.taDiscussions,
                onTap: onViewDiscussions,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.auto_awesome_rounded,
                label: l10n.taCourseAIInsights,
                onTap: onAIInsights,
                isAI: true,
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
    bool isAI = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: isAI
                ? (isDark
                      ? TAColors.primary.withValues(alpha: 0.15)
                      : TAColors.primarySurface)
                : TAColors.cardColor(isDark),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isAI
                  ? TAColors.primary.withValues(alpha: 0.3)
                  : TAColors.borderColor(isDark),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isAI
                    ? TAColors.primary
                    : TAColors.textSecondaryColor(isDark),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isAI
                        ? TAColors.primary
                        : TAColors.textPrimaryColor(isDark),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
