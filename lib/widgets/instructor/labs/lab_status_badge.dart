import 'package:flutter/material.dart';

import '../../../models/core/enums/lab_enums.dart' as api;

class LabStatusBadge extends StatelessWidget {
  const LabStatusBadge({super.key, required this.status});

  final api.LabStatus status;

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

  static Color _statusColor(api.LabStatus status) {
    switch (status) {
      case api.LabStatus.draft:
        return const Color(0xFF2563EB);
      case api.LabStatus.published:
        return const Color(0xFF16A34A);
      case api.LabStatus.closed:
        return const Color(0xFF64748B);
      case api.LabStatus.archived:
        return const Color(0xFFF59E0B);
      case api.LabStatus.unknown:
        return Colors.grey;
    }
  }

  static String _statusLabel(api.LabStatus status) {
    switch (status) {
      case api.LabStatus.draft:
        return 'Draft';
      case api.LabStatus.published:
        return 'Published';
      case api.LabStatus.closed:
        return 'Closed';
      case api.LabStatus.archived:
        return 'Archived';
      case api.LabStatus.unknown:
        return 'Unknown';
    }
  }
}
