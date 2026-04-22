import 'package:edu_verse/common/utils/responsive.dart';
import 'package:flutter/material.dart';
import '../../../models/instructor/ai_teaching_model.dart';
import 'ai_teaching_colors.dart';

/// Quick actions horizontal scroll widget
class AIQuickActions extends StatelessWidget {
  final List<QuickAction> actions;
  final ValueChanged<QuickAction> onActionTap;
  final bool isDark;

  const AIQuickActions({
    super.key,
    required this.actions,
    required this.onActionTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final action = actions[index];
          return _QuickActionChip(
            action: action,
            onTap: () => onActionTap(action),
            isDark: isDark,
          );
        },
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final QuickAction action;
  final VoidCallback onTap;
  final bool isDark;

  const _QuickActionChip({
    required this.action,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          height: ResponsiveUtil(context).isMobile ? 44 : 56,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: AITeachingColors.quickActionGradient(isDark),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AITeachingColors.primary.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: AITeachingColors.primary.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(action.icon, size: 18, color: AITeachingColors.primary),
              const SizedBox(width: 8),
              Text(
                action.label,
                style: TextStyle(
                  color: AITeachingColors.textPrimaryColor(isDark),
                  fontSize: ResponsiveUtil(context).isMobile ? 13 : 16,
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

/// Suggested prompts section widget
class AISuggestedPrompts extends StatelessWidget {
  final List<String> prompts;
  final ValueChanged<String> onPromptTap;
  final bool isDark;

  const AISuggestedPrompts({
    super.key,
    required this.prompts,
    required this.onPromptTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 18,
                color: AITeachingColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Suggested Prompts',
                style: TextStyle(
                  color: AITeachingColors.textPrimaryColor(isDark),
                  fontSize: ResponsiveUtil(context).isMobile ? 14 : 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: ResponsiveUtil(context).isMobile ? 90 : 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: prompts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return _SuggestedPromptCard(
                prompt: prompts[index],
                onTap: () => onPromptTap(prompts[index]),
                isDark: isDark,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SuggestedPromptCard extends StatelessWidget {
  final String prompt;
  final VoidCallback onTap;
  final bool isDark;

  const _SuggestedPromptCard({
    required this.prompt,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: ResponsiveUtil(context).isMobile ? 100 : 120,
          width: 200,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AITeachingColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AITeachingColors.borderColor(isDark)),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: ResponsiveUtil(context).isMobile ? 16 : 20,
                color: AITeachingColors.primary,
              ),
              const SizedBox(height: 8),
              Text(
                prompt,
                style: TextStyle(
                  color: AITeachingColors.textPrimaryColor(isDark),
                  fontSize: ResponsiveUtil(context).isMobile ? 12 : 16,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
