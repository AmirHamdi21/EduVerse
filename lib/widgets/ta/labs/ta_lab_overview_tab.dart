import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/ta_colors.dart';

class TALabOverviewTab extends StatelessWidget {
  final bool isDark;
  final List<TALabTaskItem> tasks;
  final List<TALabQuestion> questions;
  final List<TALabActivityItem> activities;
  final Function(TALabTaskItem)? onTaskAction;
  final Function(TALabQuestion)? onReply;
  final Function(TALabQuestion)? onResolve;

  const TALabOverviewTab({
    super.key,
    required this.isDark,
    required this.tasks,
    required this.questions,
    required this.activities,
    this.onTaskAction,
    this.onReply,
    this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTaskSummarySection(l10n),
          const SizedBox(height: 20),
          _buildStudentQuestionsSection(l10n),
          const SizedBox(height: 20),
          _buildRecentActivitySection(l10n),
        ],
      ),
    );
  }

  Widget _buildTaskSummarySection(AppLocalizations l10n) {
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
                  color: TAColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.task_alt_rounded,
                  color: TAColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.taLabTaskSummary,
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...tasks.map((task) => _buildTaskItem(task, l10n)),
        ],
      ),
    );
  }

  Widget _buildTaskItem(TALabTaskItem task, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? TAColors.darkSurface.withValues(alpha: 0.5)
            : TAColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  task.subtitle,
                  style: TextStyle(
                    color: TAColors.textSecondaryColor(isDark),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _buildTaskActionButton(task, l10n),
        ],
      ),
    );
  }

  Widget _buildTaskActionButton(TALabTaskItem task, AppLocalizations l10n) {
    String label;
    IconData icon;
    Color color;

    switch (task.actionType) {
      case TALabTaskActionType.start:
        label = l10n.taLabTaskStart;
        icon = Icons.play_arrow_rounded;
        color = TAColors.primary;
        break;
      case TALabTaskActionType.mark:
        label = l10n.taLabTaskMark;
        icon = Icons.people_alt_outlined;
        color = TAColors.secondary;
        break;
      case TALabTaskActionType.reply:
        label = l10n.taLabTaskReply;
        icon = Icons.chat_bubble_outline_rounded;
        color = TAColors.teal;
        break;
      case TALabTaskActionType.review:
        label = l10n.taLabTaskReview;
        icon = Icons.visibility_outlined;
        color = TAColors.warning;
        break;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTaskAction?.call(task),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentQuestionsSection(AppLocalizations l10n) {
    final unresolvedCount = questions.where((q) => !q.isResolved).length;

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
              Text(
                l10n.taLabStudentQuestions,
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: unresolvedCount > 0
                      ? TAColors.warning.withValues(alpha: 0.1)
                      : TAColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$unresolvedCount ${l10n.taLabUnresolved}',
                  style: TextStyle(
                    color: unresolvedCount > 0
                        ? TAColors.warning
                        : TAColors.success,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...questions.map((q) => _buildQuestionItem(q, l10n)),
        ],
      ),
    );
  }

  Widget _buildQuestionItem(TALabQuestion question, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? TAColors.darkSurface.withValues(alpha: 0.5)
            : TAColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: TAColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    question.studentName.isNotEmpty
                        ? question.studentName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: TAColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question.studentName,
                      style: TextStyle(
                        color: TAColors.textPrimaryColor(isDark),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      question.timeAgo,
                      style: TextStyle(
                        color: TAColors.textTertiaryColor(isDark),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (question.isResolved)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: TAColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 12,
                        color: TAColors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.taLabResolved,
                        style: TextStyle(
                          color: TAColors.success,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            question.question,
            style: TextStyle(
              color: TAColors.textPrimaryColor(isDark),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          if (question.aiHint != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: TAColors.info.withValues(alpha: isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: TAColors.info.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.auto_awesome, size: 14, color: TAColors.info),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      question.aiHint!,
                      style: TextStyle(
                        color: TAColors.textSecondaryColor(isDark),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (!question.isResolved) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuestionAction(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: l10n.taLabTaskReply,
                    onTap: () => onReply?.call(question),
                    color: TAColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuestionAction(
                    icon: Icons.check_circle_outline_rounded,
                    label: l10n.taLabResolve,
                    onTap: () => onResolve?.call(question),
                    color: TAColors.success,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestionAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: TAColors.cardColor(isDark),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: TAColors.borderColor(isDark)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection(AppLocalizations l10n) {
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
                  color: TAColors.teal.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.trending_up_rounded,
                  color: TAColors.teal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.taCourseRecentActivity,
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...activities.map((activity) => _buildActivityItem(activity)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(TALabActivityItem activity) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: activity.color.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(activity.icon, color: activity.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity.timeAgo,
                  style: TextStyle(
                    color: TAColors.textTertiaryColor(isDark),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Models
class TALabTaskItem {
  final String id;
  final String title;
  final String subtitle;
  final TALabTaskActionType actionType;

  TALabTaskItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.actionType,
  });
}

enum TALabTaskActionType { start, mark, reply, review }

class TALabQuestion {
  final String id;
  final String studentName;
  final String question;
  final String timeAgo;
  final String? aiHint;
  final bool isResolved;

  TALabQuestion({
    required this.id,
    required this.studentName,
    required this.question,
    required this.timeAgo,
    this.aiHint,
    this.isResolved = false,
  });
}

class TALabActivityItem {
  final String id;
  final String title;
  final String timeAgo;
  final IconData icon;
  final Color color;

  TALabActivityItem({
    required this.id,
    required this.title,
    required this.timeAgo,
    required this.icon,
    required this.color,
  });
}
