import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../config/app_theme.dart';
import '../../../models/notifications/notification_model.dart';
import '../../../generated_l10n/app_localizations.dart';

class AIInsightCard extends StatelessWidget {
  final AIInsightModel insight;
  final bool isDarkMode;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;

  const AIInsightCard({
    super.key,
    required this.insight,
    required this.isDarkMode,
    this.onAction,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = _getInsightColors(insight.insightType);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  colors.background.withValues(alpha: 0.3),
                  colors.background.withValues(alpha: 0.15),
                ]
              : [
                  colors.background.withValues(alpha: 0.15),
                  colors.background.withValues(alpha: 0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.primary.withValues(alpha: isDarkMode ? 0.3 : 0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background decoration
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primary.withValues(alpha: 0.1),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [colors.primary, colors.secondary],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: colors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _getInsightIcon(insight.insightType),
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Title
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              insight.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode
                                    ? AppTheme.darkTextPrimary
                                    : AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getInsightTypeLabel(insight.insightType, l10n),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: colors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Dismiss button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onDismiss?.call();
                        },
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: isDarkMode
                                ? AppTheme.darkTextSecondary
                                : AppTheme.textLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Message
                  Text(
                    insight.message,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDarkMode
                          ? AppTheme.darkTextSecondary
                          : AppTheme.textLight,
                      height: 1.5,
                    ),
                  ),
                  if (insight.actionText != null) ...[
                    const SizedBox(height: 14),
                    // Action button
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onAction?.call();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [colors.primary, colors.secondary],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: colors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              insight.actionText!,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.arrow_forward,
                              size: 16,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getInsightIcon(AIInsightType type) {
    switch (type) {
      case AIInsightType.performanceAlert:
        return Icons.trending_down;
      case AIInsightType.recommendation:
        return Icons.lightbulb_outline;
      case AIInsightType.studyTip:
        return Icons.tips_and_updates;
      case AIInsightType.reminder:
        return Icons.alarm;
    }
  }

  _InsightColors _getInsightColors(AIInsightType type) {
    switch (type) {
      case AIInsightType.performanceAlert:
        return const _InsightColors(
          primary: Color(0xFFFF6B35),
          secondary: Color(0xFFFF8F65),
          background: Color(0xFFFF6B35),
        );
      case AIInsightType.recommendation:
        return const _InsightColors(
          primary: Color(0xFF3B82F6),
          secondary: Color(0xFF60A5FA),
          background: Color(0xFF3B82F6),
        );
      case AIInsightType.studyTip:
        return const _InsightColors(
          primary: Color(0xFF10B981),
          secondary: Color(0xFF34D399),
          background: Color(0xFF10B981),
        );
      case AIInsightType.reminder:
        return const _InsightColors(
          primary: Color(0xFF8B5CF6),
          secondary: Color(0xFFA78BFA),
          background: Color(0xFF8B5CF6),
        );
    }
  }

  String _getInsightTypeLabel(AIInsightType type, AppLocalizations l10n) {
    switch (type) {
      case AIInsightType.performanceAlert:
        return l10n.notificationPerformanceAlert;
      case AIInsightType.recommendation:
        return l10n.notificationAIRecommendation;
      case AIInsightType.studyTip:
        return l10n.notificationStudyTip;
      case AIInsightType.reminder:
        return l10n.notificationReminder;
    }
  }
}

class _InsightColors {
  final Color primary;
  final Color secondary;
  final Color background;

  const _InsightColors({
    required this.primary,
    required this.secondary,
    required this.background,
  });
}
