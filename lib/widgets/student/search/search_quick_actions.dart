import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';

class SearchQuickActions extends StatelessWidget {
  final bool isDark;
  final ValueChanged<String> onNavigate;

  const SearchQuickActions({
    super.key,
    required this.isDark,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final actions = [
      _QuickAction(l10n.courses, Icons.school_rounded, const Color(0xFF155DFC), '/courses'),
      _QuickAction(l10n.tasks, Icons.task_alt_rounded, const Color(0xFF10B981), '/tasks'),
      _QuickAction(l10n.assignments, Icons.assignment_rounded, const Color(0xFFF59E0B), '/assignments'),
      _QuickAction(l10n.grades, Icons.grade_rounded, const Color(0xFF8B5CF6), '/grades'),
      _QuickAction(l10n.labs, Icons.science_rounded, const Color(0xFF06B6D4), '/labs'),
      _QuickAction(l10n.aiAssistant, Icons.smart_toy_rounded, const Color(0xFFEC4899), '/ai-chat'),
      _QuickAction(l10n.flashcards, Icons.style_rounded, const Color(0xFFEF4444), '/flashcards'),
      _QuickAction(l10n.calendar, Icons.calendar_month_rounded, const Color(0xFF14B8A6), '/calendar'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.bolt_rounded,
                size: 18,
                color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.searchQuickActions,
                style: TextStyle(
                  color: isDark ? Colors.white70 : const Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return _QuickActionCard(
                action: action,
                isDark: isDark,
                onTap: () => onNavigate(action.route),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final String route;

  const _QuickAction(this.label, this.icon, this.color, this.route);
}

class _QuickActionCard extends StatelessWidget {
  final _QuickAction action;
  final bool isDark;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.action,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: action.color.withValues(alpha: isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: action.color.withValues(alpha: isDark ? 0.25 : 0.15),
              ),
            ),
            child: Icon(
              action.icon,
              color: action.color,
              size: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            action.label,
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF475569),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
