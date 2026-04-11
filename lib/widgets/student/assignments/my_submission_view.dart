import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../common/utils/responsive.dart';
import '../../../../models/assignments/assignment_submission_model.dart';
import '../../../../models/core/enums/assignment_enums.dart';

class MySubmissionView extends StatelessWidget {
  final AssignmentSubmissionModel submission;
  final double maxScore;
  final bool isDark;
  final VoidCallback? onResubmit;

  const MySubmissionView({
    super.key,
    required this.submission,
    required this.maxScore,
    required this.isDark,
    this.onResubmit,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Container(
      padding: EdgeInsets.all(responsive.p16),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withValues(alpha: isDark ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(responsive.radius16),
        border: Border.all(
          color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.cloud_done_rounded,
                color: const Color(0xFF3B82F6),
                size: responsive.fontSize18,
              ),
              SizedBox(width: responsive.p8),
              Text(
                'My Submission',
                style: TextStyle(
                  fontSize: responsive.fontSize16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              if (submission.isLate)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.p8,
                    vertical: responsive.p4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(responsive.radius8),
                  ),
                  child: Text(
                    'Late',
                    style: TextStyle(
                      fontSize: responsive.fontSize12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: responsive.p12),
          _buildSubmittedAt(context),
          SizedBox(height: responsive.p12),
          _buildSubmissionContent(context),
          SizedBox(height: responsive.p16),
          ScoreDisplay(
            submission: submission,
            maxScore: maxScore,
            isDark: isDark,
          ),
          if ((submission.feedback ?? '').trim().isNotEmpty) ...[
            SizedBox(height: responsive.p12),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(responsive.p12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.grey.shade800.withValues(alpha: 0.35)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(responsive.radius12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instructor Feedback',
                    style: TextStyle(
                      fontSize: responsive.fontSize13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: responsive.p4),
                  Text(
                    submission.feedback!,
                    style: TextStyle(
                      fontSize: responsive.fontSize13,
                      color: isDark
                          ? Colors.grey.shade300
                          : Colors.grey.shade700,
                    ),
                  ),
                  if (submission.gradedAt != null) ...[
                    SizedBox(height: responsive.p4),
                    Text(
                      'Graded on ${_formatDate(submission.gradedAt!)}',
                      style: TextStyle(
                        fontSize: responsive.fontSize11,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          if (submission.submissionStatus == SubmissionStatus.graded &&
              onResubmit != null) ...[
            SizedBox(height: responsive.p16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onResubmit,
                icon: const Icon(Icons.replay_rounded),
                label: const Text('Resubmit Assignment'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF3B82F6),
                  side: const BorderSide(color: Color(0xFF3B82F6)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubmittedAt(BuildContext context) {
    final responsive = context.responsive;
    return Row(
      children: [
        Icon(
          Icons.access_time_rounded,
          size: responsive.fontSize14,
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
        SizedBox(width: responsive.p6),
        Text(
          'Submitted ${_formatDate(submission.submittedAt)}',
          style: TextStyle(
            fontSize: responsive.fontSize13,
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmissionContent(BuildContext context) {
    final responsive = context.responsive;

    if ((submission.submissionText ?? '').trim().isNotEmpty) {
      return Text(
        submission.submissionText!,
        style: TextStyle(
          fontSize: responsive.fontSize13,
          color: isDark ? Colors.grey.shade200 : Colors.grey.shade800,
          height: 1.4,
        ),
      );
    }

    if ((submission.submissionLink ?? '').trim().isNotEmpty) {
      return InkWell(
        onTap: () => _openExternal(submission.submissionLink!),
        child: Text(
          submission.submissionLink!,
          style: TextStyle(
            fontSize: responsive.fontSize13,
            color: const Color(0xFF3B82F6),
            decoration: TextDecoration.underline,
          ),
        ),
      );
    }

    if (submission.driveFile != null) {
      final file = submission.driveFile!;
      return Row(
        children: [
          const Icon(Icons.attach_file_rounded, color: Color(0xFF3B82F6)),
          Expanded(
            child: Text(
              file.fileName,
              style: TextStyle(
                fontSize: responsive.fontSize13,
                color: isDark ? Colors.grey.shade200 : Colors.grey.shade800,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: () => _openExternal(file.webViewLink),
            child: const Text('Open'),
          ),
        ],
      );
    }

    return Text(
      'Submission saved',
      style: TextStyle(
        fontSize: responsive.fontSize13,
        color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
      ),
    );
  }

  Future<void> _openExternal(String value) async {
    final uri = Uri.tryParse(value);
    if (uri == null) {
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _formatDate(DateTime value) {
    final hour = value.hour > 12 ? value.hour - 12 : value.hour;
    final suffix = value.hour >= 12 ? 'PM' : 'AM';
    return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')} ${hour == 0 ? 12 : hour}:${value.minute.toString().padLeft(2, '0')} $suffix';
  }
}

class ScoreDisplay extends StatelessWidget {
  final AssignmentSubmissionModel submission;
  final double maxScore;
  final bool isDark;

  const ScoreDisplay({
    super.key,
    required this.submission,
    required this.maxScore,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final score = submission.score;

    if (score == null) {
      return Text(
        'Not yet graded',
        style: TextStyle(
          fontSize: responsive.fontSize14,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
        ),
      );
    }

    final percent = maxScore <= 0 ? 0 : (score / maxScore) * 100;
    Color color;
    if (percent >= 80) {
      color = const Color(0xFF10B981);
    } else if (percent >= 60) {
      color = const Color(0xFFF59E0B);
    } else {
      color = const Color(0xFFEF4444);
    }

    return Row(
      children: [
        Icon(Icons.grade_rounded, color: color, size: responsive.fontSize18),
        SizedBox(width: responsive.p6),
        Text(
          '${score.toStringAsFixed(1)} / ${maxScore.toStringAsFixed(1)} (${percent.toStringAsFixed(0)}%)',
          style: TextStyle(
            fontSize: responsive.fontSize14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
