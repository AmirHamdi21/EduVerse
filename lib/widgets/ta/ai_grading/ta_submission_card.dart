import 'package:flutter/material.dart';
import '../shared/ta_colors.dart';

enum TASubmissionStatus { pending, aiEvaluated, finalized, late }

class TASubmissionItem {
  final String id;
  final String studentName;
  final String studentId;
  final String timeAgo;
  final int wordCount;
  final TASubmissionStatus status;
  final double? aiScore;
  final bool isLate;
  final String? avatarUrl;

  const TASubmissionItem({
    required this.id,
    required this.studentName,
    required this.studentId,
    required this.timeAgo,
    required this.wordCount,
    required this.status,
    this.aiScore,
    this.isLate = false,
    this.avatarUrl,
  });
}

class TASubmissionCard extends StatelessWidget {
  final TASubmissionItem submission;
  final bool isDark;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onEvaluate;

  const TASubmissionCard({
    super.key,
    required this.submission,
    required this.isDark,
    this.isSelected = false,
    this.onTap,
    this.onEvaluate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TAColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? TAColors.primary
                : TAColors.borderColor(isDark).withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: _getStatusColor().withValues(alpha: 0.15),
              child: Text(
                submission.studentName[0].toUpperCase(),
                style: TextStyle(
                  color: _getStatusColor(),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          submission.studentName,
                          style: TextStyle(
                            color: TAColors.textPrimaryColor(isDark),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildStatusIndicator(),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: TAColors.textTertiaryColor(isDark),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        submission.timeAgo,
                        style: TextStyle(
                          color: TAColors.textTertiaryColor(isDark),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.description_outlined,
                        size: 12,
                        color: TAColors.textTertiaryColor(isDark),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${submission.wordCount} words',
                        style: TextStyle(
                          color: TAColors.textTertiaryColor(isDark),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStatusTag(),
                      if (submission.aiScore != null) ...[
                        const SizedBox(width: 8),
                        _buildAIScoreTag(),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    IconData icon;
    Color color;

    switch (submission.status) {
      case TASubmissionStatus.aiEvaluated:
        icon = Icons.auto_awesome;
        color = TAColors.info;
        break;
      case TASubmissionStatus.finalized:
        icon = Icons.check_circle_rounded;
        color = TAColors.success;
        break;
      case TASubmissionStatus.late:
        icon = Icons.schedule_rounded;
        color = TAColors.error;
        break;
      case TASubmissionStatus.pending:
        icon = Icons.hourglass_empty_rounded;
        color = TAColors.warning;
        break;
    }

    return Icon(icon, color: color, size: 20);
  }

  Widget _buildStatusTag() {
    String label;
    Color bgColor;
    Color textColor;

    switch (submission.status) {
      case TASubmissionStatus.aiEvaluated:
        label = 'AI Evaluated';
        bgColor = TAColors.info.withValues(alpha: 0.15);
        textColor = TAColors.info;
        break;
      case TASubmissionStatus.finalized:
        label = 'Finalized';
        bgColor = TAColors.success.withValues(alpha: 0.15);
        textColor = TAColors.success;
        break;
      case TASubmissionStatus.late:
        label = 'Late';
        bgColor = TAColors.error.withValues(alpha: 0.15);
        textColor = TAColors.error;
        break;
      case TASubmissionStatus.pending:
        label = 'Pending';
        bgColor = TAColors.warning.withValues(alpha: 0.15);
        textColor = TAColors.warning;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAIScoreTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: TAColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'AI: ${submission.aiScore!.toStringAsFixed(1)}/10',
        style: TextStyle(
          color: TAColors.primary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (submission.status) {
      case TASubmissionStatus.aiEvaluated:
        return TAColors.info;
      case TASubmissionStatus.finalized:
        return TAColors.success;
      case TASubmissionStatus.late:
        return TAColors.error;
      case TASubmissionStatus.pending:
        return TAColors.warning;
    }
  }
}
