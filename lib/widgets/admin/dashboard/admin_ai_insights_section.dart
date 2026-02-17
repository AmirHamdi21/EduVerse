import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

enum AlertSeverity { high, medium, low }

class AIAlertItem {
  final String title;
  final String description;
  final String timeAgo;
  final AlertSeverity severity;
  final IconData icon;

  AIAlertItem({
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.severity,
    required this.icon,
  });
}

class AdminAIInsightsSection extends StatelessWidget {
  const AdminAIInsightsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        final alerts = _getMockAlerts(l10n);

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      AdminColors.darkCard.withOpacity(0.8),
                      AdminColors.darkCard.withOpacity(0.6),
                    ]
                  : [
                      const Color(0xFFFAF5FF).withOpacity(0.8),
                      const Color(0xFFEFF6FF).withOpacity(0.8),
                    ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? AdminColors.darkCardBorder
                  : AdminColors.lightPurpleBorder,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 25,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: AdminColors.purpleGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.aiSystemInsights,
                              style: TextStyle(
                                color: AdminColors.getTextColor(isDark),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.intelligentMonitoring,
                              style: TextStyle(
                                color: AdminColors.getTextSecondaryColor(
                                  isDark,
                                ),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: _buildReviewButton(context, isDark, l10n),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...alerts.map(
                (alert) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildAlertCard(context, isDark, alert),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewButton(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return GestureDetector(
      onTap: () => _showAIReportDialog(context, isDark, l10n),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.white : AdminColors.lightCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark
                ? AdminColors.darkCardBorder
                : const Color(0xFFDAB2FF),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.description_outlined,
              color: AdminColors.getTextColor(isDark),
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              l10n.reviewAIReport,
              style: TextStyle(
                color: AdminColors.getTextColor(isDark),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, bool isDark, AIAlertItem alert) {
    final colors = _getSeverityColors(alert.severity);

    return GestureDetector(
      onTap: () => _showAlertDetailsDialog(context, isDark, alert),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors['bg']!.withOpacity(isDark ? 0.3 : 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colors['border']!.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(alert.icon, color: colors['text'], size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          alert.title,
                          style: TextStyle(
                            color: colors['text'],
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    alert.description,
                    style: TextStyle(
                      color: colors['text']!.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        color: colors['text']!.withOpacity(0.6),
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        alert.timeAgo,
                        style: TextStyle(
                          color: colors['text']!.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colors['badge'],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getSeverityText(alert.severity),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, Color> _getSeverityColors(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.high:
        return {
          'bg': const Color(0xFFFB2C36),
          'border': const Color(0xFFFB2C36),
          'text': const Color(0xFFE7000B),
          'badge': const Color(0xFFFB2C36),
        };
      case AlertSeverity.medium:
        return {
          'bg': const Color(0xFFF0B100),
          'border': const Color(0xFFF0B100),
          'text': const Color(0xFFD08700),
          'badge': const Color(0xFFF0B100),
        };
      case AlertSeverity.low:
        return {
          'bg': const Color(0xFF00C950),
          'border': const Color(0xFF00C950),
          'text': const Color(0xFF00A63E),
          'badge': const Color(0xFF00C950),
        };
    }
  }

  String _getSeverityText(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.high:
        return 'HIGH';
      case AlertSeverity.medium:
        return 'MEDIUM';
      case AlertSeverity.low:
        return 'LOW';
    }
  }

  List<AIAlertItem> _getMockAlerts(AppLocalizations l10n) {
    return [
      AIAlertItem(
        title: l10n.highFailedLoginAttempts,
        description: l10n.failedLoginDescription,
        timeAgo: l10n.minutesAgo(5),
        severity: AlertSeverity.high,
        icon: Icons.warning_amber_rounded,
      ),
      AIAlertItem(
        title: l10n.lowCourseEngagement,
        description: l10n.lowEngagementDescription,
        timeAgo: l10n.minutesAgo(12),
        severity: AlertSeverity.medium,
        icon: Icons.trending_down_rounded,
      ),
      AIAlertItem(
        title: l10n.missingInstructorResources,
        description: l10n.missingResourcesDescription,
        timeAgo: l10n.hoursAgo(1),
        severity: AlertSeverity.low,
        icon: Icons.folder_open_rounded,
      ),
      AIAlertItem(
        title: l10n.unassignedCourses,
        description: l10n.unassignedCoursesDescription,
        timeAgo: l10n.hoursAgo(2),
        severity: AlertSeverity.medium,
        icon: Icons.assignment_late_rounded,
      ),
    ];
  }

  void _showAIReportDialog(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AdminColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AdminColors.purpleGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.aiReport,
              style: TextStyle(
                color: AdminColors.getTextColor(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReportSection(
                isDark,
                l10n.securityAlerts,
                '3',
                AdminColors.error,
              ),
              const SizedBox(height: 16),
              _buildReportSection(
                isDark,
                l10n.performanceWarnings,
                '5',
                AdminColors.warning,
              ),
              const SizedBox(height: 16),
              _buildReportSection(
                isDark,
                l10n.systemRecommendations,
                '12',
                AdminColors.success,
              ),
              const SizedBox(height: 20),
              Text(
                l10n.aiReportSummary,
                style: TextStyle(
                  color: AdminColors.getTextSecondaryColor(isDark),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l10n.close,
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.reportDownloaded),
                  backgroundColor: AdminColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.secondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n.downloadReport),
          ),
        ],
      ),
    );
  }

  Widget _buildReportSection(
    bool isDark,
    String title,
    String count,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AdminColors.getTextColor(isDark),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              count,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAlertDetailsDialog(
    BuildContext context,
    bool isDark,
    AIAlertItem alert,
  ) {
    final colors = _getSeverityColors(alert.severity);
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AdminColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors['badge'],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(alert.icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                alert.title,
                style: TextStyle(
                  color: AdminColors.getTextColor(isDark),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colors['badge'],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getSeverityText(alert.severity),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              alert.description,
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  color: AdminColors.getTextTertiaryColor(isDark),
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  alert.timeAgo,
                  style: TextStyle(
                    color: AdminColors.getTextTertiaryColor(isDark),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l10n.dismiss,
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.alertResolved),
                  backgroundColor: AdminColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors['badge'],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n.resolve),
          ),
        ],
      ),
    );
  }
}
