import 'package:flutter/material.dart';

import '../../../models/core/enums/lab_enums.dart';
import '../../../models/core/lab_attendance_model.dart';

class AttendanceSheet extends StatefulWidget {
  const AttendanceSheet({
    super.key,
    required this.records,
    required this.onMarkAttendance,
    this.canManage = true,
  });

  final List<LabAttendanceModel> records;
  final Future<void> Function(int userId, LabAttendanceStatus status)
  onMarkAttendance;
  final bool canManage;

  @override
  State<AttendanceSheet> createState() => _AttendanceSheetState();
}

class _AttendanceSheetState extends State<AttendanceSheet> {
  final Set<int> _savingUserIds = <int>{};

  @override
  Widget build(BuildContext context) {
    if (widget.records.isEmpty) {
      return const _EmptyAttendanceState();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: widget.records.length,
      itemBuilder: (context, index) {
        final record = widget.records[index];
        final userName = _nameOf(record);
        final isSaving = _savingUserIds.contains(record.userId);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (isSaving)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                if ((record.user?.email ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      record.user!.email,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children:
                      <LabAttendanceStatus>[
                            LabAttendanceStatus.present,
                            LabAttendanceStatus.absent,
                            LabAttendanceStatus.excused,
                            LabAttendanceStatus.late,
                          ]
                          .map((status) {
                            final selected = record.attendanceStatus == status;
                            return ConstrainedBox(
                              constraints: const BoxConstraints(
                                minWidth: 48,
                                minHeight: 48,
                              ),
                              child: ChoiceChip(
                                label: Text(_statusLabel(status)),
                                selected: selected,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.padded,
                                selectedColor: _statusColor(
                                  status,
                                ).withValues(alpha: 0.22),
                                labelStyle: TextStyle(
                                  color: selected ? _statusColor(status) : null,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                                onSelected: !widget.canManage || isSaving
                                    ? null
                                    : (_) =>
                                          _updateStatus(record.userId, status),
                              ),
                            );
                          })
                          .toList(growable: false),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateStatus(int userId, LabAttendanceStatus status) async {
    setState(() {
      _savingUserIds.add(userId);
    });

    await widget.onMarkAttendance(userId, status);

    if (!mounted) {
      return;
    }

    setState(() {
      _savingUserIds.remove(userId);
    });
  }

  String _nameOf(LabAttendanceModel record) {
    final first = record.user?.firstName.trim() ?? '';
    final last = record.user?.lastName.trim() ?? '';
    final fullName = '$first $last'.trim();
    if (fullName.isNotEmpty) {
      return fullName;
    }
    return 'Student #${record.userId}';
  }

  String _statusLabel(LabAttendanceStatus status) {
    switch (status) {
      case LabAttendanceStatus.present:
        return 'Present';
      case LabAttendanceStatus.absent:
        return 'Absent';
      case LabAttendanceStatus.excused:
        return 'Excused';
      case LabAttendanceStatus.late:
        return 'Late';
      case LabAttendanceStatus.unknown:
        return 'Unknown';
    }
  }

  Color _statusColor(LabAttendanceStatus status) {
    switch (status) {
      case LabAttendanceStatus.present:
        return const Color(0xFF16A34A);
      case LabAttendanceStatus.absent:
        return const Color(0xFFDC2626);
      case LabAttendanceStatus.excused:
        return const Color(0xFF2563EB);
      case LabAttendanceStatus.late:
        return const Color(0xFFF59E0B);
      case LabAttendanceStatus.unknown:
        return Colors.grey;
    }
  }
}

class _EmptyAttendanceState extends StatelessWidget {
  const _EmptyAttendanceState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const <Widget>[
            Icon(Icons.group_off_outlined, size: 52),
            SizedBox(height: 10),
            Text('No enrolled students', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
