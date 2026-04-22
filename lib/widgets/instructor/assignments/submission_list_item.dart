import 'package:flutter/material.dart';

import '../../../models/assignments/assignment_submission_model.dart';
import '../../../models/core/enums/assignment_enums.dart' as api;
import '../grading/grading_theme_colors.dart';

class SubmissionListItem extends StatelessWidget {
  const SubmissionListItem({
    super.key,
    required this.submission,
    required this.onTap,
  });

  final AssignmentSubmissionModel submission;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final studentName = _studentName(submission);
    final status = submission.submissionStatus;
    final statusColor = _statusColor(status, submission.isLate);
    final relative = _relativeTime(submission.submittedAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          child: Text(studentName.isEmpty ? '?' : studentName[0].toUpperCase()),
        ),
        title: Text(studentName),
        subtitle: Text('Submitted $relative'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                _statusLabel(status, submission.isLate),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              submission.score == null
                  ? '-'
                  : submission.score!.toStringAsFixed(
                      submission.score == submission.score!.roundToDouble()
                          ? 0
                          : 1,
                    ),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  static String _studentName(AssignmentSubmissionModel submission) {
    final first = submission.user?.firstName.trim() ?? '';
    final last = submission.user?.lastName.trim() ?? '';
    final fullName = '$first $last'.trim();
    if (fullName.isNotEmpty) {
      return fullName;
    }
    return 'Student #${submission.userId}';
  }

  static String _statusLabel(api.SubmissionStatus status, bool isLate) {
    if (isLate) {
      return 'Late';
    }

    switch (status) {
      case api.SubmissionStatus.submitted:
        return 'Submitted';
      case api.SubmissionStatus.resubmit:
        return 'Resubmit';
      case api.SubmissionStatus.graded:
        return 'Graded';
      case api.SubmissionStatus.returned:
        return 'Returned';
      case api.SubmissionStatus.unknown:
        return 'Unknown';
    }
  }

  static Color _statusColor(api.SubmissionStatus status, bool isLate) {
    if (isLate) {
      return GradingColors.late;
    }

    switch (status) {
      case api.SubmissionStatus.submitted:
      case api.SubmissionStatus.resubmit:
        return GradingColors.pending;
      case api.SubmissionStatus.graded:
      case api.SubmissionStatus.returned:
        return GradingColors.graded;
      case api.SubmissionStatus.unknown:
        return Colors.grey;
    }
  }

  static String _relativeTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    }
    if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    }
    return '${diff.inMinutes}m ago';
  }
}
