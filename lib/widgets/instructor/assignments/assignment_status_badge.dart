import 'package:flutter/material.dart';

import '../../../models/core/enums/assignment_enums.dart' as api;
import '../create_assignment/create_assignment_colors.dart';

class AssignmentStatusBadge extends StatelessWidget {
  const AssignmentStatusBadge({super.key, required this.status});

  final api.AssignmentStatus status;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static Color _statusColor(api.AssignmentStatus status) {
    switch (status) {
      case api.AssignmentStatus.draft:
        return Colors.grey.shade700;
      case api.AssignmentStatus.published:
        return CreateAssignmentColors.success;
      case api.AssignmentStatus.closed:
        return CreateAssignmentColors.warning;
      case api.AssignmentStatus.archived:
        return CreateAssignmentColors.primary;
      case api.AssignmentStatus.unknown:
        return Colors.grey;
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
}
