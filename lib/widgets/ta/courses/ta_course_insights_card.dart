import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/ta_colors.dart';

class TACourseInsightsCard extends StatelessWidget {
  final bool isDark;
  final List<String> insights;
  final VoidCallback? onOpenFullInsights;

  const TACourseInsightsCard({
    super.key,
    required this.isDark,
    required this.insights,
    this.onOpenFullInsights,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: TAColors.aiGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.taCourseInsightsTitle,
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...insights.map((insight) => _buildInsightItem(insight)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onOpenFullInsights,
              style: OutlinedButton.styleFrom(
                foregroundColor: TAColors.primary,
                side: BorderSide(
                  color: TAColors.primary.withValues(alpha: 0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                l10n.taCourseOpenInsights,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String insight) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            child: const Icon(
              Icons.auto_awesome,
              size: 14,
              color: TAColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              insight,
              style: TextStyle(
                color: TAColors.textSecondaryColor(isDark),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TAFullInsightsSheet extends StatelessWidget {
  final bool isDark;
  final List<String> priorityTasks;
  final List<TAQuickAction> quickActions;

  const TAFullInsightsSheet({
    super.key,
    required this.isDark,
    required this.priorityTasks,
    required this.quickActions,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: TAColors.borderColor(isDark),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: TAColors.aiGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.psychology_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.taCourseFullInsightsTitle,
                            style: TextStyle(
                              color: TAColors.textPrimaryColor(isDark),
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            l10n.taCourseFullInsightsSubtitle,
                            style: TextStyle(
                              color: TAColors.textSecondaryColor(isDark),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close_rounded,
                        color: TAColors.textSecondaryColor(isDark),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildPriorityTasksSection(l10n),
                const SizedBox(height: 20),
                _buildQuickActionsSection(l10n, context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityTasksSection(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? TAColors.error.withValues(alpha: 0.1)
            : TAColors.errorLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: TAColors.error.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.priority_high_rounded,
                color: TAColors.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.taCoursePriorityTasks,
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...priorityTasks.map((task) => _buildPriorityItem(task)),
        ],
      ),
    );
  }

  Widget _buildPriorityItem(String task) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            child: Icon(
              Icons.warning_amber_rounded,
              size: 16,
              color: TAColors.warning,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              task,
              style: TextStyle(
                color: TAColors.textPrimaryColor(isDark),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(AppLocalizations l10n, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? TAColors.primary.withValues(alpha: 0.1)
            : TAColors.primarySurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: TAColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bolt_rounded,
                color: TAColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.taQuickActions,
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...quickActions.map((action) => _buildQuickActionItem(action, context)),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem(TAQuickAction action, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            action.onTap?.call();
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: BoxDecoration(
              color: TAColors.cardColor(isDark),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: TAColors.borderColor(isDark),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  action.icon,
                  size: 18,
                  color: TAColors.textSecondaryColor(isDark),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    action.label,
                    style: TextStyle(
                      color: TAColors.textPrimaryColor(isDark),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: TAColors.textTertiaryColor(isDark),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TAQuickAction {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  TAQuickAction({
    required this.icon,
    required this.label,
    this.onTap,
  });
}
