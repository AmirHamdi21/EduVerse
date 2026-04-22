import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/ta_colors.dart';

class TAQuickActionsGrid extends StatelessWidget {
  final bool isDark;
  final Function(String action)? onActionTap;

  const TAQuickActionsGrid({super.key, required this.isDark, this.onActionTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final actions = [
      _QuickAction(
        id: 'exam_grading',
        icon: Icons.grading_rounded,
        label: l10n.taExamGrading,
        color: TAColors.primary,
        lightColor: TAColors.primarySurface,
      ),
      _QuickAction(
        id: 'review_labs',
        icon: Icons.science_rounded,
        label: l10n.taReviewLabs,
        color: TAColors.secondary,
        lightColor: TAColors.accentLight,
      ),
      _QuickAction(
        id: 'open_discussions',
        icon: Icons.forum_rounded,
        label: l10n.taOpenDiscussions,
        color: TAColors.teal,
        lightColor: TAColors.tealLight,
      ),
      _QuickAction(
        id: 'ask_ai',
        icon: Icons.psychology_rounded,
        label: l10n.taAskAIHelp,
        color: TAColors.pink,
        lightColor: TAColors.pinkLight,
        isAI: true,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.taQuickActions,
          style: TextStyle(
            color: TAColors.textPrimaryColor(isDark),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.65,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return _buildActionCard(action);
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(_QuickAction action) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onActionTap?.call(action.id),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? TAColors.darkCard : action.lightColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? TAColors.darkBorder.withValues(alpha: 0.3)
                  : action.color.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: action.color.withValues(alpha: isDark ? 0.1 : 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? LinearGradient(
                              colors: [
                                action.color.withValues(alpha: 0.2),
                                action.color.withValues(alpha: 0.1),
                              ],
                            )
                          : null,
                      color: isDark
                          ? null
                          : action.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(action.icon, color: action.color, size: 24),
                  ),
                  if (action.isAI)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          gradient: TAColors.aiGradient,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'AI',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                action.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 11,
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

class _QuickAction {
  final String id;
  final IconData icon;
  final String label;
  final Color color;
  final Color lightColor;
  final bool isAI;

  _QuickAction({
    required this.id,
    required this.icon,
    required this.label,
    required this.color,
    required this.lightColor,
    this.isAI = false,
  });
}
