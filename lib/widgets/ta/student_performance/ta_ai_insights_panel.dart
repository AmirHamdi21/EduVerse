import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/ta_colors.dart';

class TAAIInsightsPanel extends StatelessWidget {
  final bool isDark;
  final List<TAStudentAtRisk> studentsNeedingSupport;
  final List<TARecommendedAction> recommendedActions;
  final List<TAAcademicAlert> academicAlerts;
  final VoidCallback? onGenerateMaterials;
  final VoidCallback? onClose;

  const TAAIInsightsPanel({
    super.key,
    required this.isDark,
    required this.studentsNeedingSupport,
    required this.recommendedActions,
    required this.academicAlerts,
    this.onGenerateMaterials,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: TAColors.borderColor(isDark),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(l10n),
                  const SizedBox(height: 20),
                  _buildStudentsNeedingSupport(l10n),
                  const SizedBox(height: 16),
                  _buildRecommendedActions(l10n),
                  if (academicAlerts.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildAcademicAlerts(l10n),
                  ],
                  const SizedBox(height: 20),
                  _buildGenerateMaterialsButton(l10n),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                TAColors.primary.withValues(alpha: 0.2),
                TAColors.primary.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.auto_awesome,
            color: TAColors.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.taPerformanceAIInsights,
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l10n.taPerformanceAIInsightsSubtitle,
                style: TextStyle(
                  color: TAColors.textSecondaryColor(isDark),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onClose,
          icon: Icon(
            Icons.close_rounded,
            color: TAColors.textSecondaryColor(isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentsNeedingSupport(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? TAColors.error.withValues(alpha: 0.1)
            : TAColors.error.withValues(alpha: 0.05),
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
                Icons.warning_amber_rounded,
                size: 18,
                color: TAColors.error,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.taPerformanceStudentsNeedingSupport,
                style: TextStyle(
                  color: TAColors.error,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...studentsNeedingSupport.map((student) => _buildAtRiskStudentItem(student)),
        ],
      ),
    );
  }

  Widget _buildAtRiskStudentItem(TAStudentAtRisk student) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: TAColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: TAColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  student.issue,
                  style: TextStyle(
                    color: TAColors.textSecondaryColor(isDark),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: TAColors.error.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${student.score.toStringAsFixed(0)}%',
              style: TextStyle(
                color: TAColors.error,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedActions(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? TAColors.darkSurface.withValues(alpha: 0.5)
            : TAColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 18,
                color: TAColors.teal,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.taPerformanceRecommendedActions,
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recommendedActions.map((action) => _buildActionItem(action)),
        ],
      ),
    );
  }

  Widget _buildActionItem(TARecommendedAction action) {
    IconData icon;
    Color color;

    switch (action.priority) {
      case ActionPriority.high:
        icon = Icons.priority_high_rounded;
        color = TAColors.error;
        break;
      case ActionPriority.medium:
        icon = Icons.fiber_manual_record;
        color = TAColors.warning;
        break;
      case ActionPriority.low:
        icon = Icons.fiber_manual_record;
        color = TAColors.success;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              action.action,
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

  Widget _buildAcademicAlerts(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? TAColors.warning.withValues(alpha: 0.1)
            : TAColors.warning.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: TAColors.warning.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.security_rounded,
                size: 18,
                color: TAColors.warning,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.taPerformanceAcademicIntegrityAlerts,
                style: TextStyle(
                  color: TAColors.warning,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...academicAlerts.map((alert) => _buildAlertItem(alert)),
        ],
      ),
    );
  }

  Widget _buildAlertItem(TAAcademicAlert alert) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: TAColors.warning,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  alert.description,
                  style: TextStyle(
                    color: TAColors.textSecondaryColor(isDark),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateMaterialsButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onGenerateMaterials,
        icon: const Icon(Icons.auto_awesome, size: 18),
        label: Text(l10n.taPerformanceGenerateMaterials),
        style: ElevatedButton.styleFrom(
          backgroundColor: TAColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

// Models
class TAStudentAtRisk {
  final String id;
  final String name;
  final String issue;
  final double score;

  TAStudentAtRisk({
    required this.id,
    required this.name,
    required this.issue,
    required this.score,
  });
}

enum ActionPriority { high, medium, low }

class TARecommendedAction {
  final String action;
  final ActionPriority priority;

  TARecommendedAction({
    required this.action,
    required this.priority,
  });
}

class TAAcademicAlert {
  final String title;
  final String description;
  final String? studentName;

  TAAcademicAlert({
    required this.title,
    required this.description,
    this.studentName,
  });
}
