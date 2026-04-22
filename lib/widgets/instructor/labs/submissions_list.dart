import 'package:flutter/material.dart';

import '../../../models/core/enums/assignment_enums.dart' as assignment_api;
import '../../../models/labs/lab_submission_model.dart';

enum SubmissionSortOption {
  dateNewest,
  dateOldest,
  scoreHigh,
  scoreLow,
  studentAz,
  studentZa,
}

class SubmissionsList extends StatefulWidget {
  const SubmissionsList({
    super.key,
    required this.submissions,
    required this.onTapSubmission,
    this.canManage = true,
  });

  final List<LabSubmissionModel> submissions;
  final ValueChanged<LabSubmissionModel> onTapSubmission;
  final bool canManage;

  @override
  State<SubmissionsList> createState() => _SubmissionsListState();
}

class _SubmissionsListState extends State<SubmissionsList> {
  String _searchQuery = '';
  String _statusFilter = 'all';
  SubmissionSortOption _sortOption = SubmissionSortOption.dateNewest;

  @override
  Widget build(BuildContext context) {
    final filtered = _applyFilters(widget.submissions);

    if (widget.submissions.isEmpty) {
      return const _EmptySubmissionsState();
    }

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: const InputDecoration(
              hintText: 'Search by student name',
              prefixIcon: Icon(Icons.search_rounded),
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _FilterChip(
                label: 'All',
                selected: _statusFilter == 'all',
                onTap: () => setState(() => _statusFilter = 'all'),
              ),
              _FilterChip(
                label: 'Submitted',
                selected: _statusFilter == 'submitted',
                onTap: () => setState(() => _statusFilter = 'submitted'),
              ),
              _FilterChip(
                label: 'Graded',
                selected: _statusFilter == 'graded',
                onTap: () => setState(() => _statusFilter = 'graded'),
              ),
              _FilterChip(
                label: 'Returned',
                selected: _statusFilter == 'returned',
                onTap: () => setState(() => _statusFilter = 'returned'),
              ),
              _FilterChip(
                label: 'Resubmit',
                selected: _statusFilter == 'resubmit',
                onTap: () => setState(() => _statusFilter = 'resubmit'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: DropdownButtonFormField<SubmissionSortOption>(
            key: ValueKey<SubmissionSortOption>(_sortOption),
            initialValue: _sortOption,
            decoration: const InputDecoration(
              labelText: 'Sort by',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: const <DropdownMenuItem<SubmissionSortOption>>[
              DropdownMenuItem(
                value: SubmissionSortOption.dateNewest,
                child: Text('Date (newest first)'),
              ),
              DropdownMenuItem(
                value: SubmissionSortOption.dateOldest,
                child: Text('Date (oldest first)'),
              ),
              DropdownMenuItem(
                value: SubmissionSortOption.scoreHigh,
                child: Text('Score (high to low)'),
              ),
              DropdownMenuItem(
                value: SubmissionSortOption.scoreLow,
                child: Text('Score (low to high)'),
              ),
              DropdownMenuItem(
                value: SubmissionSortOption.studentAz,
                child: Text('Student Name (A-Z)'),
              ),
              DropdownMenuItem(
                value: SubmissionSortOption.studentZa,
                child: Text('Student Name (Z-A)'),
              ),
            ],
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() => _sortOption = value);
            },
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const _EmptySubmissionsState(
                  message: 'No submissions match the selected filters.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final submission = filtered[index];
                    return _SubmissionCard(
                      submission: submission,
                      canManage: widget.canManage,
                      onTap: () => widget.onTapSubmission(submission),
                    );
                  },
                ),
        ),
      ],
    );
  }

  List<LabSubmissionModel> _applyFilters(List<LabSubmissionModel> source) {
    final normalizedQuery = _searchQuery.trim().toLowerCase();

    final filtered = source
        .where((item) {
          final fullName = _studentName(item).toLowerCase();
          final matchesQuery =
              normalizedQuery.isEmpty || fullName.contains(normalizedQuery);

          final status = item.submissionStatus.toJson();
          final matchesStatus =
              _statusFilter == 'all' || status == _statusFilter;

          return matchesQuery && matchesStatus;
        })
        .toList(growable: false);

    filtered.sort((a, b) {
      switch (_sortOption) {
        case SubmissionSortOption.dateNewest:
          return b.submittedAt.compareTo(a.submittedAt);
        case SubmissionSortOption.dateOldest:
          return a.submittedAt.compareTo(b.submittedAt);
        case SubmissionSortOption.studentAz:
          return _studentName(
            a,
          ).toLowerCase().compareTo(_studentName(b).toLowerCase());
        case SubmissionSortOption.studentZa:
          return _studentName(
            b,
          ).toLowerCase().compareTo(_studentName(a).toLowerCase());
        case SubmissionSortOption.scoreHigh:
          return _compareScoreWithNullBottom(
            a.score,
            b.score,
            descending: true,
          );
        case SubmissionSortOption.scoreLow:
          return _compareScoreWithNullBottom(
            a.score,
            b.score,
            descending: false,
          );
      }
    });

    return filtered;
  }

  int _compareScoreWithNullBottom(
    double? left,
    double? right, {
    required bool descending,
  }) {
    if (left == null && right == null) {
      return 0;
    }
    if (left == null) {
      return 1;
    }
    if (right == null) {
      return -1;
    }

    return descending ? right.compareTo(left) : left.compareTo(right);
  }

  String _studentName(LabSubmissionModel submission) {
    final first = submission.user?.firstName.trim() ?? '';
    final last = submission.user?.lastName.trim() ?? '';
    final fullName = '$first $last'.trim();
    if (fullName.isNotEmpty) {
      return fullName;
    }
    return 'Student #${submission.userId}';
  }
}

class _SubmissionCard extends StatelessWidget {
  const _SubmissionCard({
    required this.submission,
    required this.onTap,
    required this.canManage,
  });

  final LabSubmissionModel submission;
  final VoidCallback onTap;
  final bool canManage;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(
      submission.submissionStatus,
      submission.isLate,
    );
    final first = submission.user?.firstName.trim() ?? '';
    final last = submission.user?.lastName.trim() ?? '';
    final studentName = '$first $last'.trim().isEmpty
        ? 'Student #${submission.userId}'
        : '$first $last'.trim();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: canManage ? onTap : null,
        leading: CircleAvatar(
          child: Text(studentName.isEmpty ? '?' : studentName[0].toUpperCase()),
        ),
        title: Text(studentName),
        subtitle: Text('Submitted ${_formatDateTime(submission.submittedAt)}'),
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
                _statusLabel(submission.submissionStatus, submission.isLate),
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

  static String _statusLabel(
    assignment_api.SubmissionStatus status,
    bool isLate,
  ) {
    if (isLate) {
      return 'Late';
    }

    switch (status) {
      case assignment_api.SubmissionStatus.submitted:
        return 'Submitted';
      case assignment_api.SubmissionStatus.graded:
        return 'Graded';
      case assignment_api.SubmissionStatus.returned:
        return 'Returned';
      case assignment_api.SubmissionStatus.resubmit:
        return 'Resubmit';
      case assignment_api.SubmissionStatus.unknown:
        return 'Unknown';
    }
  }

  static Color _statusColor(
    assignment_api.SubmissionStatus status,
    bool isLate,
  ) {
    if (isLate) {
      return const Color(0xFFDC2626);
    }

    switch (status) {
      case assignment_api.SubmissionStatus.submitted:
      case assignment_api.SubmissionStatus.resubmit:
        return const Color(0xFFF59E0B);
      case assignment_api.SubmissionStatus.graded:
      case assignment_api.SubmissionStatus.returned:
        return const Color(0xFF16A34A);
      case assignment_api.SubmissionStatus.unknown:
        return Colors.grey;
    }
  }

  static String _formatDateTime(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '${value.year}-$month-$day $hour:$minute';
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        materialTapTargetSize: MaterialTapTargetSize.padded,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _EmptySubmissionsState extends StatelessWidget {
  const _EmptySubmissionsState({this.message = 'No submissions yet.'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.inbox_outlined, size: 52),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
