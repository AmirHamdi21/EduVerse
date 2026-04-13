import 'package:flutter/material.dart';

import '../../../models/assignments/assignment_model.dart';
import '../../../models/core/enums/assignment_enums.dart' as api;
import '../create_assignment/create_assignment_colors.dart';
import 'assignment_status_badge.dart';

class AssignmentCard extends StatelessWidget {
  const AssignmentCard({
    super.key,
    required this.assignment,
    required this.onViewSubmissions,
    this.onEdit,
    this.onDelete,
    this.onStatusChange,
    this.canManage = true,
  });

  final AssignmentModel assignment;
  final VoidCallback onViewSubmissions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final ValueChanged<api.AssignmentStatus>? onStatusChange;
  final bool canManage;

  @override
  Widget build(BuildContext context) {
    final nextStatus = _nextStatus(assignment.apiStatus);
    final maxScoreText = assignment.maxGrade.toStringAsFixed(
      assignment.maxGrade == assignment.maxGrade.roundToDouble() ? 0 : 1,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Text(
                    assignment.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                AssignmentStatusBadge(status: assignment.apiStatus),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              assignment.description?.trim().isNotEmpty == true
                  ? assignment.description!
                  : 'No description provided.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: <Widget>[
                _MetaItem(
                  icon: Icons.calendar_today_rounded,
                  text: _formatDate(assignment.dueDate),
                ),
                _MetaItem(
                  icon: _submissionTypeIcon(assignment.submissionType),
                  text: _submissionTypeLabel(assignment.submissionType),
                ),
                _MetaItem(icon: Icons.score_rounded, text: maxScoreText),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                TextButton.icon(
                  onPressed: onViewSubmissions,
                  icon: const Icon(Icons.list_alt_rounded),
                  label: const Text('View Submissions'),
                ),
                const Spacer(),
                if (canManage && onEdit != null)
                  IconButton(
                    tooltip: 'Edit assignment',
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                  ),
                if (canManage && onDelete != null)
                  IconButton(
                    tooltip: 'Delete assignment',
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                  ),
                if (canManage && nextStatus != null && onStatusChange != null)
                  PopupMenuButton<api.AssignmentStatus>(
                    tooltip: 'Update status',
                    onSelected: onStatusChange,
                    itemBuilder: (context) =>
                        <PopupMenuEntry<api.AssignmentStatus>>[
                          PopupMenuItem<api.AssignmentStatus>(
                            value: nextStatus,
                            child: Text('Move to ${_statusLabel(nextStatus)}'),
                          ),
                        ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: CreateAssignmentColors.primary.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: CreateAssignmentColors.primary.withValues(
                            alpha: 0.2,
                          ),
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          Text(
                            _statusLabel(nextStatus),
                            style: const TextStyle(
                              color: CreateAssignmentColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.swap_horiz_rounded,
                            color: CreateAssignmentColors.primary,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static api.AssignmentStatus? _nextStatus(api.AssignmentStatus status) {
    switch (status) {
      case api.AssignmentStatus.draft:
        return api.AssignmentStatus.published;
      case api.AssignmentStatus.published:
        return api.AssignmentStatus.closed;
      case api.AssignmentStatus.closed:
        return api.AssignmentStatus.archived;
      case api.AssignmentStatus.archived:
      case api.AssignmentStatus.unknown:
        return null;
    }
  }

  static String _statusLabel(api.AssignmentStatus status) {
    switch (status) {
      case api.AssignmentStatus.draft:
        return 'Draft';
      case api.AssignmentStatus.published:
        return 'Published';
      case api.AssignmentStatus.closed:
        return 'Closed';
      case api.AssignmentStatus.archived:
        return 'Archived';
      case api.AssignmentStatus.unknown:
        return 'Unknown';
    }
  }

  static IconData _submissionTypeIcon(api.SubmissionType type) {
    switch (type) {
      case api.SubmissionType.file:
        return Icons.upload_file_rounded;
      case api.SubmissionType.text:
        return Icons.subject_rounded;
      case api.SubmissionType.link:
        return Icons.link_rounded;
      case api.SubmissionType.multiple:
        return Icons.dashboard_customize_rounded;
      case api.SubmissionType.unknown:
        return Icons.help_outline_rounded;
    }
  }

  static String _submissionTypeLabel(api.SubmissionType type) {
    switch (type) {
      case api.SubmissionType.file:
        return 'File';
      case api.SubmissionType.text:
        return 'Text';
      case api.SubmissionType.link:
        return 'Link';
      case api.SubmissionType.multiple:
        return 'Multiple';
      case api.SubmissionType.unknown:
        return 'Unknown';
    }
  }

  static String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 5),
        Text(text, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      ],
    );
  }
}
