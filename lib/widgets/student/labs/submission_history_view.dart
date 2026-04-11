import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../common/utils/responsive.dart';
import '../../../../models/core/enums/assignment_enums.dart' as api;
import '../../../../models/labs/lab_submission_model.dart';

class SubmissionHistoryView extends StatelessWidget {
  final List<LabSubmissionModel> submissions;
  final double maxScore;
  final bool isDark;

  const SubmissionHistoryView({
    super.key,
    required this.submissions,
    required this.maxScore,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    if (submissions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(responsive.p14),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.grey.shade800.withValues(alpha: 0.35)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(responsive.radius12),
        ),
        child: Text(
          'No submissions yet',
          style: TextStyle(
            fontSize: responsive.fontSize13,
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
      );
    }

    final ordered = List<LabSubmissionModel>.from(submissions)
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

    return Column(
      children: ordered
          .map(
            (submission) => _SubmissionCard(
              submission: submission,
              maxScore: maxScore,
              isDark: isDark,
            ),
          )
          .toList(),
    );
  }
}

class _SubmissionCard extends StatelessWidget {
  final LabSubmissionModel submission;
  final double maxScore;
  final bool isDark;

  const _SubmissionCard({
    required this.submission,
    required this.maxScore,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Container(
      margin: EdgeInsets.only(bottom: responsive.p12),
      padding: EdgeInsets.all(responsive.p12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(responsive.radius12),
        border: Border.all(
          color: _statusColor(
            submission.submissionStatus,
          ).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _formatDate(submission.submittedAt),
                  style: TextStyle(
                    fontSize: responsive.fontSize12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _buildStatusBadge(context),
              if (submission.isLate) ...[
                SizedBox(width: responsive.p6),
                _buildLateBadge(context),
              ],
            ],
          ),
          if (submission.score != null) ...[
            SizedBox(height: responsive.p8),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: responsive.p10,
                vertical: responsive.p6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(responsive.radius8),
              ),
              child: Text(
                '${submission.score!.toStringAsFixed(1)} / ${maxScore.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: responsive.fontSize13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF10B981),
                ),
              ),
            ),
          ],
          if ((submission.feedback ?? '').trim().isNotEmpty) ...[
            SizedBox(height: responsive.p10),
            Text(
              'Feedback',
              style: TextStyle(
                fontSize: responsive.fontSize12,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: responsive.p4),
            Text(
              submission.feedback!.trim(),
              style: TextStyle(
                fontSize: responsive.fontSize13,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                height: 1.35,
              ),
            ),
          ],
          if ((submission.submissionText ?? '').trim().isNotEmpty) ...[
            SizedBox(height: responsive.p10),
            Text(
              submission.submissionText!.trim(),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: responsive.fontSize13,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
            ),
          ],
          if (submission.driveFile != null) ...[
            SizedBox(height: responsive.p10),
            InkWell(
              onTap: () => _openExternal(submission.driveFile!.downloadUrl),
              borderRadius: BorderRadius.circular(responsive.radius8),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: responsive.p6,
                  horizontal: responsive.p6,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.attach_file_rounded,
                      color: Color(0xFF3B82F6),
                    ),
                    SizedBox(width: responsive.p6),
                    Expanded(
                      child: Text(
                        submission.driveFile!.fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: responsive.fontSize12,
                          color: const Color(0xFF3B82F6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.download_rounded,
                      color: Color(0xFF3B82F6),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final responsive = context.responsive;
    final color = _statusColor(submission.submissionStatus);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.p8,
        vertical: responsive.p4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(responsive.radius8),
      ),
      child: Text(
        _statusLabel(submission.submissionStatus),
        style: TextStyle(
          fontSize: responsive.fontSize11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildLateBadge(BuildContext context) {
    final responsive = context.responsive;

    return Container(
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
          fontSize: responsive.fontSize11,
          fontWeight: FontWeight.w700,
          color: const Color(0xFFEF4444),
        ),
      ),
    );
  }

  String _statusLabel(api.SubmissionStatus status) {
    switch (status) {
      case api.SubmissionStatus.submitted:
        return 'Submitted';
      case api.SubmissionStatus.graded:
        return 'Graded';
      case api.SubmissionStatus.returned:
        return 'Returned';
      case api.SubmissionStatus.resubmit:
        return 'Resubmit';
      case api.SubmissionStatus.unknown:
        return 'Unknown';
    }
  }

  Color _statusColor(api.SubmissionStatus status) {
    switch (status) {
      case api.SubmissionStatus.submitted:
        return const Color(0xFF3B82F6);
      case api.SubmissionStatus.graded:
        return const Color(0xFF10B981);
      case api.SubmissionStatus.returned:
        return const Color(0xFFF59E0B);
      case api.SubmissionStatus.resubmit:
        return const Color(0xFF8B5CF6);
      case api.SubmissionStatus.unknown:
        return const Color(0xFF94A3B8);
    }
  }

  String _formatDate(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final suffix = date.hour >= 12 ? 'PM' : 'AM';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${hour == 0 ? 12 : hour}:${date.minute.toString().padLeft(2, '0')} $suffix';
  }

  Future<void> _openExternal(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
