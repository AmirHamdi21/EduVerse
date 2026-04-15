import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/ta_colors.dart';

class TACourseGradingTab extends StatelessWidget {
  final bool isDark;
  final List<TAGradingTask> gradingTasks;
  final Function(TAGradingTask)? onStartReview;
  final Function(TAGradingTask)? onApplyAIScore;

  const TACourseGradingTab({
    super.key,
    required this.isDark,
    required this.gradingTasks,
    this.onStartReview,
    this.onApplyAIScore,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (gradingTasks.isEmpty) {
      return _buildEmptyState(l10n);
    }

    return Column(
      children: gradingTasks
          .map((task) => _buildGradingCard(task, l10n))
          .toList(),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: TAColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.assignment_turned_in_rounded,
              size: 48,
              color: TAColors.success,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.taCourseNoGrading,
            style: TextStyle(
              color: TAColors.textPrimaryColor(isDark),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.taCourseNoGradingDesc,
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGradingCard(TAGradingTask task, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: TAColors.warning.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.grading_rounded,
                  color: TAColors.warning,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.studentName,
                      style: TextStyle(
                        color: TAColors.textPrimaryColor(isDark),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      task.assignmentName,
                      style: TextStyle(
                        color: TAColors.textSecondaryColor(isDark),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(task.status, l10n),
            ],
          ),
          const SizedBox(height: 16),
          _buildAIGradingHelper(task, l10n),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => onApplyAIScore?.call(task),
                  icon: const Icon(Icons.auto_awesome, size: 18),
                  label: Text(l10n.taCourseApplyAIScore),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: TAColors.primary,
                    side: BorderSide(
                      color: TAColors.primary.withValues(alpha: 0.3),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => onStartReview?.call(task),
                  icon: const Icon(Icons.rate_review_rounded, size: 18),
                  label: Text(l10n.taCourseStartReview),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TAColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(TAGradingStatus status, AppLocalizations l10n) {
    Color color;
    Color bgColor;
    String label;

    switch (status) {
      case TAGradingStatus.pending:
        color = TAColors.warning;
        bgColor = TAColors.warning.withValues(alpha: 0.1);
        label = l10n.taCourseGradingPending;
        break;
      case TAGradingStatus.inProgress:
        color = TAColors.info;
        bgColor = TAColors.info.withValues(alpha: 0.1);
        label = l10n.taCourseGradingInProgress;
        break;
      case TAGradingStatus.completed:
        color = TAColors.success;
        bgColor = TAColors.success.withValues(alpha: 0.1);
        label = l10n.taCourseGradingComplete;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAIGradingHelper(TAGradingTask task, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: TAColors.aiGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.psychology_rounded, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.taCourseAIGradingHelper,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${l10n.taCourseSuggestedScore}: ${task.aiSuggestedScore}/100',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${task.aiSuggestedScore}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TAGradingTask {
  final String id;
  final String studentName;
  final String assignmentName;
  final TAGradingStatus status;
  final int aiSuggestedScore;

  TAGradingTask({
    required this.id,
    required this.studentName,
    required this.assignmentName,
    required this.status,
    required this.aiSuggestedScore,
  });
}

enum TAGradingStatus { pending, inProgress, completed }
