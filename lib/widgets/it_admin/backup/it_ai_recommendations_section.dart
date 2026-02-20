import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_backup_barrel.dart';

class ITAIRecommendationsSection extends StatelessWidget {
  final bool isDark;
  final List<AIRecommendation> recommendations;
  final Function(AIRecommendation) onAction;
  final Function(AIRecommendation) onDismiss;

  const ITAIRecommendationsSection({
    super.key,
    required this.isDark,
    required this.recommendations,
    required this.onAction,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ITColors.purple.withValues(alpha: 0.2),
                    ITColors.primary.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: ITColors.purple,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'AI Recommendations',
              style: TextStyle(
                color: ITColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Recommendations list
        ...recommendations.map((rec) => _buildRecommendationCard(rec)),
      ],
    );
  }

  Widget _buildRecommendationCard(AIRecommendation recommendation) {
    return Dismissible(
      key: Key(recommendation.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(recommendation),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: ITColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? ITColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: recommendation.color.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: ITColors.lightCardShadow(isDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with gradient
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    recommendation.color.withValues(alpha: 0.15),
                    recommendation.color.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: recommendation.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      recommendation.icon,
                      color: recommendation.color,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      recommendation.title,
                      style: TextStyle(
                        color: ITColors.textPrimaryColor(isDark),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _buildPriorityBadge(recommendation.priority),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recommendation.description,
                    style: TextStyle(
                      color: ITColors.textSecondaryColor(isDark),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onAction(recommendation),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: recommendation.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: recommendation.color.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getActionIcon(recommendation.type),
                              color: recommendation.color,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              recommendation.actionLabel,
                              style: TextStyle(
                                color: recommendation.color,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color color;
    switch (priority.toLowerCase()) {
      case 'high':
        color = ITColors.error;
        break;
      case 'medium':
        color = ITColors.warning;
        break;
      default:
        color = ITColors.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  IconData _getActionIcon(String type) {
    switch (type.toLowerCase()) {
      case 'optimize':
        return Icons.tune_rounded;
      case 'warning':
        return Icons.warning_rounded;
      case 'cost':
        return Icons.savings_rounded;
      case 'test':
        return Icons.schedule_rounded;
      default:
        return Icons.arrow_forward_rounded;
    }
  }
}
