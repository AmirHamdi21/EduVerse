import 'package:flutter/material.dart';
import '../shared/admin_colors.dart';

class AIQuickAction {
  final String id;
  final String label;
  final IconData icon;
  final String prompt;
  final Color color;

  const AIQuickAction({
    required this.id,
    required this.label,
    required this.icon,
    required this.prompt,
    required this.color,
  });
}

class AdminAIQuickActions extends StatelessWidget {
  final bool isDark;
  final Function(AIQuickAction) onActionTap;

  const AdminAIQuickActions({
    super.key,
    required this.isDark,
    required this.onActionTap,
  });

  static const List<AIQuickAction> _actions = [
    AIQuickAction(
      id: 'report',
      label: 'Generate Report',
      icon: Icons.assessment_rounded,
      prompt: 'Generate a comprehensive platform usage report for this month',
      color: AdminColors.primary,
    ),
    AIQuickAction(
      id: 'analyze',
      label: 'Analyze Data',
      icon: Icons.analytics_rounded,
      prompt: 'Analyze current enrollment and attendance trends',
      color: AdminColors.success,
    ),
    AIQuickAction(
      id: 'issues',
      label: 'Find Issues',
      icon: Icons.bug_report_rounded,
      prompt: 'Identify potential issues or anomalies in the system',
      color: AdminColors.error,
    ),
    AIQuickAction(
      id: 'optimize',
      label: 'Optimize',
      icon: Icons.speed_rounded,
      prompt: 'Suggest optimizations for system performance',
      color: AdminColors.warning,
    ),
    AIQuickAction(
      id: 'forecast',
      label: 'Forecast',
      icon: Icons.trending_up_rounded,
      prompt: 'Forecast enrollment and resource needs for next semester',
      color: AdminColors.secondary,
    ),
    AIQuickAction(
      id: 'summary',
      label: 'Daily Summary',
      icon: Icons.summarize_rounded,
      prompt: 'Give me a summary of today\'s platform activity',
      color: AdminColors.accent,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AdminColors.darkCard : AdminColors.lightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AdminColors.darkCardBorder
              : AdminColors.lightCardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.flash_on_rounded,
                color: AdminColors.warning,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AdminColors.darkText : AdminColors.lightText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _actions
                .map((action) => _buildActionChip(action))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(AIQuickAction action) {
    return Material(
      color: action.color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => onActionTap(action),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(action.icon, size: 18, color: action.color),
              const SizedBox(width: 8),
              Text(
                action.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: action.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
