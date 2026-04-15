import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_security_logs_barrel.dart';

class ITAISecurityInsights extends StatelessWidget {
  final bool isDark;
  final List<AISecurityInsight> insights;
  final Function(AISecurityInsight) onTap;

  const ITAISecurityInsights({
    super.key,
    required this.isDark,
    required this.insights,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              'AI Security Insights',
              style: TextStyle(
                color: ITColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...insights.map((insight) => _buildInsightCard(insight)),
      ],
    );
  }

  Widget _buildInsightCard(AISecurityInsight insight) {
    return GestureDetector(
      onTap: () => onTap(insight),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? ITColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _getSeverityColor(insight.severity).withValues(alpha: 0.3),
          ),
          boxShadow: ITColors.lightCardShadow(isDark),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getSeverityColor(
                  insight.severity,
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                insight.icon,
                color: _getSeverityColor(insight.severity),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    insight.title,
                    style: TextStyle(
                      color: ITColors.textPrimaryColor(isDark),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    insight.description,
                    style: TextStyle(
                      color: ITColors.textTertiaryColor(isDark),
                      fontSize: 11,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: ITColors.textTertiaryColor(isDark),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(IncidentSeverity severity) {
    switch (severity) {
      case IncidentSeverity.critical:
        return ITColors.error;
      case IncidentSeverity.warning:
        return ITColors.warning;
      case IncidentSeverity.info:
        return ITColors.info;
    }
  }
}
