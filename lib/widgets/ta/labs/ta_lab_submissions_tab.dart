import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/ta_colors.dart';

enum TASubmissionStatus { pending, reviewed, late }

class TALabSubmissionsTab extends StatelessWidget {
  final bool isDark;
  final List<TALabSubmission> submissions;
  final Function(TALabSubmission)? onOpenSubmission;

  const TALabSubmissionsTab({
    super.key,
    required this.isDark,
    required this.submissions,
    this.onOpenSubmission,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.taLabAllSubmissions,
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: TAColors.primary.withValues(alpha: isDark ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${submissions.length} ${l10n.taLabTotal}',
                  style: TextStyle(
                    color: TAColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...submissions.map((s) => _buildSubmissionCard(s, l10n)),
        ],
      ),
    );
  }

  Widget _buildSubmissionCard(TALabSubmission submission, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: TAColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          submission.studentName.isNotEmpty
                              ? submission.studentName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: TAColors.primary,
                            fontSize: 16,
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
                            submission.studentName,
                            style: TextStyle(
                              color: TAColors.textPrimaryColor(isDark),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${l10n.taLabSubmitted} ${submission.submittedAgo}',
                            style: TextStyle(
                              color: TAColors.textSecondaryColor(isDark),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(submission.status, l10n),
                  ],
                ),
                const SizedBox(height: 14),
                _buildScoreSection(submission, l10n),
              ],
            ),
          ),
          _buildOpenButton(submission, l10n),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(TASubmissionStatus status, AppLocalizations l10n) {
    Color color;
    String label;

    switch (status) {
      case TASubmissionStatus.pending:
        color = TAColors.warning;
        label = l10n.taLabPending;
        break;
      case TASubmissionStatus.reviewed:
        color = TAColors.success;
        label = l10n.taLabReviewed;
        break;
      case TASubmissionStatus.late:
        color = TAColors.error;
        label = l10n.taLabLate;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
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

  Widget _buildScoreSection(TALabSubmission submission, AppLocalizations l10n) {
    final hasAIScore = submission.aiScore != null;
    final hasFinalScore = submission.finalScore != null;

    return Container(
      padding: const EdgeInsets.all(12),
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
          if (hasAIScore && !hasFinalScore) ...[
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 14,
                  color: TAColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.taLabAIScore,
                  style: TextStyle(
                    color: TAColors.textSecondaryColor(isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  '${submission.aiScore}/100',
                  style: TextStyle(
                    color: TAColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (submission.aiComment != null) ...[
              const SizedBox(height: 8),
              Text(
                submission.aiComment!,
                style: TextStyle(
                  color: TAColors.textSecondaryColor(isDark),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ] else if (hasFinalScore) ...[
            Row(
              children: [
                Text(
                  l10n.taLabFinalScore,
                  style: TextStyle(
                    color: TAColors.textSecondaryColor(isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  '${submission.finalScore}/100',
                  style: TextStyle(
                    color: TAColors.success,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ] else ...[
            Text(
              l10n.taLabNoScoreYet,
              style: TextStyle(
                color: TAColors.textTertiaryColor(isDark),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOpenButton(TALabSubmission submission, AppLocalizations l10n) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onOpenSubmission?.call(submission),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: TAColors.primary,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.visibility_outlined,
                size: 18,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.taLabOpenSubmission,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TALabSubmission {
  final String id;
  final String studentName;
  final String submittedAgo;
  final TASubmissionStatus status;
  final int? aiScore;
  final String? aiComment;
  final int? finalScore;

  TALabSubmission({
    required this.id,
    required this.studentName,
    required this.submittedAgo,
    required this.status,
    this.aiScore,
    this.aiComment,
    this.finalScore,
  });
}
