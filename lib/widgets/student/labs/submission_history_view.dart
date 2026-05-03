import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../common/utils/responsive.dart';
import '../../../../models/core/enums/assignment_enums.dart' as api;
import '../../../../models/labs/lab_submission_model.dart';
import '../shared/drive_file_preview_screen.dart';

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

    return ListView.builder(
      shrinkWrap: true,
      primary: false,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ordered.length,
      itemBuilder: (context, index) {
        final submission = ordered[index];
        return _SubmissionCard(
          submission: submission,
          maxScore: maxScore,
          isDark: isDark,
        );
      },
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
    final statusColor = _statusColor(submission.submissionStatus);
    final score = submission.score;
    final percentage = score == null || maxScore <= 0
        ? null
        : (score / maxScore * 100).clamp(0, 100);

    return Container(
      margin: EdgeInsets.only(bottom: responsive.p14),
      padding: EdgeInsets.all(responsive.p14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.18),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(responsive.radius16),
                ),
                alignment: Alignment.center,
                child: Text(
                  'S${submission.id}',
                  style: TextStyle(
                    fontSize: responsive.fontSize14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2563EB),
                  ),
                ),
              ),
              SizedBox(width: responsive.p12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      submission.submissionText?.trim().isNotEmpty == true
                          ? submission.submissionText!.trim()
                          : 'Lab submission',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: responsive.fontSize16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: responsive.p4),
                    Text(
                      _formatDate(submission.submittedAt),
                      style: TextStyle(
                        fontSize: responsive.fontSize13,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.p10,
                  vertical: responsive.p6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _statusLabel(submission.submissionStatus),
                  style: TextStyle(
                    fontSize: responsive.fontSize12,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.p12),
          Wrap(
            spacing: responsive.p8,
            runSpacing: responsive.p8,
            children: <Widget>[
              _buildInfoPill(
                context,
                icon: Icons.event_rounded,
                text: _formatDate(submission.submittedAt),
              ),
              if (submission.isLate)
                _buildInfoPill(
                  context,
                  icon: Icons.warning_amber_rounded,
                  text: 'Late',
                  color: const Color(0xFFEF4444),
                ),
              if (submission.score != null)
                _buildInfoPill(
                  context,
                  icon: Icons.grade_rounded,
                  text: '${percentage!.toStringAsFixed(0)}% score',
                  color: const Color(0xFF10B981),
                ),
            ],
          ),
          SizedBox(height: responsive.p14),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(responsive.p14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  (score == null
                          ? const Color(0xFF10B981)
                          : statusColor)
                      .withValues(alpha: 0.16),
                  const Color(0xFF0EA5E9).withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: (score == null
                        ? const Color(0xFF10B981)
                        : statusColor)
                    .withValues(alpha: 0.18),
              ),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: score == null
                        ? const Color(0xFF10B981)
                        : statusColor,
                    borderRadius: BorderRadius.circular(responsive.radius16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    score == null
                        ? '--'
                        : (score == score.roundToDouble()
                              ? score.round().toString()
                              : score.toStringAsFixed(1)),
                    style: TextStyle(
                      fontSize: responsive.fontSize18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: responsive.p12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        score == null
                            ? 'Waiting for grading'
                            : '${score.toStringAsFixed(1)} / ${maxScore.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: responsive.fontSize18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: responsive.p4),
                      Text(
                        score == null
                            ? 'Your lab work is in the queue.'
                            : '${percentage!.toStringAsFixed(0)}% overall score',
                        style: TextStyle(
                          fontSize: responsive.fontSize13,
                          color: isDark
                              ? Colors.grey.shade300
                              : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if ((submission.feedback ?? '').trim().isNotEmpty) ...<Widget>[
            SizedBox(height: responsive.p14),
            _buildInlinePanel(
              context,
              title: 'Feedback',
              icon: Icons.forum_rounded,
              child: Text(
                submission.feedback!.trim(),
                style: TextStyle(
                  fontSize: responsive.fontSize14,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
            ),
          ],
          if (submission.driveFile != null) ...<Widget>[
            SizedBox(height: responsive.p14),
            _buildDriveFileCard(context, submission.driveFile!, responsive),
          ],
        ],
      ),
    );
  }

  Widget _buildDriveFileCard(
    BuildContext context,
    dynamic file,
    ResponsiveUtil responsive,
  ) {
    return Container(
      padding: EdgeInsets.all(responsive.p14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF2563EB).withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(responsive.radius14),
                ),
                child: const Icon(
                  Icons.description_rounded,
                  color: Color(0xFF2563EB),
                ),
              ),
              SizedBox(width: responsive.p10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      file.fileName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: responsive.fontSize14,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: responsive.p2),
                    Text(
                      'Submitted file',
                      style: TextStyle(
                        fontSize: responsive.fontSize12,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.p12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 460;

              final previewButton = OutlinedButton.icon(
                onPressed: () => openDriveFilePreviewScreen(
                  context,
                  file: file,
                  isDark: isDark,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2563EB),
                  side: BorderSide(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.32),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.visibility_rounded),
                label: const Text('Preview'),
              );

              final openButton = OutlinedButton.icon(
                onPressed: file.webViewLink.isEmpty
                    ? null
                    : () => _openExternal(file.webViewLink),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF8B5CF6),
                  side: BorderSide(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Open in Drive'),
              );

              final downloadButton = FilledButton.icon(
                onPressed: file.downloadUrl.isEmpty
                    ? null
                    : () => _openExternal(file.downloadUrl),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.download_rounded),
                label: const Text('Download'),
              );

              if (isCompact) {
                return Column(
                  children: <Widget>[
                    SizedBox(width: double.infinity, child: previewButton),
                    SizedBox(height: responsive.p8),
                    SizedBox(width: double.infinity, child: openButton),
                    SizedBox(height: responsive.p8),
                    SizedBox(width: double.infinity, child: downloadButton),
                  ],
                );
              }

              return Row(
                children: <Widget>[
                  Expanded(child: previewButton),
                  SizedBox(width: responsive.p8),
                  Expanded(child: openButton),
                  SizedBox(width: responsive.p8),
                  Expanded(child: downloadButton),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInlinePanel(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final responsive = context.responsive;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.p14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD9E2F0).withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.forum_rounded, size: 18, color: Color(0xFF2563EB)),
              SizedBox(width: responsive.p8),
              Text(
                title,
                style: TextStyle(
                  fontSize: responsive.fontSize14,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.p10),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoPill(
    BuildContext context, {
    required IconData icon,
    required String text,
    Color? color,
  }) {
    final responsive = context.responsive;
    final resolvedColor = color ?? const Color(0xFF2563EB);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.p10,
        vertical: responsive.p6,
      ),
      decoration: BoxDecoration(
        color: resolvedColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: resolvedColor),
          SizedBox(width: responsive.p6),
          Text(
            text,
            style: TextStyle(
              color: resolvedColor,
              fontSize: responsive.fontSize12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
        return const Color(0xFF2563EB);
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
