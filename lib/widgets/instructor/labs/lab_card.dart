import 'package:flutter/material.dart';

import '../../../models/core/enums/lab_enums.dart' as api;
import '../../../models/labs/lab_model.dart';
import 'lab_status_badge.dart';

class LabCard extends StatelessWidget {
  const LabCard({
    super.key,
    required this.lab,
    required this.onViewSubmissions,
    this.onEdit,
    this.onDelete,
    this.onStatusChange,
    this.canManage = true,
  });

  final LabModel lab;
  final VoidCallback onViewSubmissions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final ValueChanged<api.LabStatus>? onStatusChange;
  final bool canManage;

  @override
  Widget build(BuildContext context) {
    final nextStatus = _nextStatus(lab.status);

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
                    lab.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                LabStatusBadge(status: lab.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              lab.description?.trim().isNotEmpty == true
                  ? lab.description!
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
                  icon: Icons.school_rounded,
                  text: lab.course?.name ?? 'Unknown course',
                ),
                _MetaItem(
                  icon: Icons.calendar_today_rounded,
                  text: lab.formattedDueDate,
                ),
                _MetaItem(
                  icon: Icons.score_rounded,
                  text: lab.maxScore.toStringAsFixed(
                    lab.maxScore == lab.maxScore.roundToDouble() ? 0 : 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 360;

                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextButton.icon(
                        onPressed: onViewSubmissions,
                        icon: const Icon(Icons.visibility_outlined),
                        label: const Text('View Submissions'),
                      ),
                      if (canManage &&
                          (onEdit != null ||
                              onDelete != null ||
                              (onStatusChange != null && nextStatus != null)))
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            if (onEdit != null)
                              IconButton(
                                tooltip: 'Edit lab',
                                onPressed: onEdit,
                                icon: const Icon(Icons.edit_outlined),
                              ),
                            if (onDelete != null)
                              IconButton(
                                tooltip: 'Delete lab',
                                onPressed: onDelete,
                                icon: const Icon(Icons.delete_outline),
                              ),
                            if (onStatusChange != null && nextStatus != null)
                              _StatusActionButton(
                                nextStatus: nextStatus,
                                onSelected: onStatusChange!,
                              ),
                          ],
                        ),
                    ],
                  );
                }

                return Row(
                  children: <Widget>[
                    TextButton.icon(
                      onPressed: onViewSubmissions,
                      icon: const Icon(Icons.visibility_outlined),
                      label: const Text('View Submissions'),
                    ),
                    const Spacer(),
                    if (canManage && onEdit != null)
                      IconButton(
                        tooltip: 'Edit lab',
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined),
                      ),
                    if (canManage && onDelete != null)
                      IconButton(
                        tooltip: 'Delete lab',
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline),
                      ),
                    if (canManage &&
                        onStatusChange != null &&
                        nextStatus != null)
                      _StatusActionButton(
                        nextStatus: nextStatus,
                        onSelected: onStatusChange!,
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static api.LabStatus? _nextStatus(api.LabStatus status) {
    switch (status) {
      case api.LabStatus.draft:
        return api.LabStatus.published;
      case api.LabStatus.published:
        return api.LabStatus.closed;
      case api.LabStatus.closed:
        return api.LabStatus.archived;
      case api.LabStatus.archived:
      case api.LabStatus.unknown:
        return null;
    }
  }
}

class _StatusActionButton extends StatelessWidget {
  const _StatusActionButton({
    required this.nextStatus,
    required this.onSelected,
  });

  final api.LabStatus nextStatus;
  final ValueChanged<api.LabStatus> onSelected;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return PopupMenuButton<api.LabStatus>(
      tooltip: 'Update status',
      onSelected: onSelected,
      itemBuilder: (context) => <PopupMenuEntry<api.LabStatus>>[
        PopupMenuItem<api.LabStatus>(
          value: nextStatus,
          child: Text('Move to ${_statusLabel(nextStatus)}'),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              _statusLabel(nextStatus),
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 6),
            Icon(Icons.swap_horiz_rounded, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  static String _statusLabel(api.LabStatus status) {
    switch (status) {
      case api.LabStatus.draft:
        return 'Publish';
      case api.LabStatus.published:
        return 'Close';
      case api.LabStatus.closed:
        return 'Archive';
      case api.LabStatus.archived:
        return 'Archived';
      case api.LabStatus.unknown:
        return 'Update';
    }
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
