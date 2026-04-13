import 'package:flutter/material.dart';

import '../../../models/labs/lab_model.dart';
import 'lab_status_badge.dart';

class LabCard extends StatelessWidget {
  const LabCard({
    super.key,
    required this.lab,
    required this.onViewSubmissions,
    this.onEdit,
    this.onDelete,
    this.canManage = true,
  });

  final LabModel lab;
  final VoidCallback onViewSubmissions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool canManage;

  @override
  Widget build(BuildContext context) {
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
                      if (canManage && (onEdit != null || onDelete != null))
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
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
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
