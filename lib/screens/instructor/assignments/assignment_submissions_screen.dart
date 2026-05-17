import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/instructor/instructor_assignments_cubit.dart';
import '../../../bloc/instructor/instructor_assignments_state.dart';
import '../../../models/assignments/assignment_submission_model.dart';
import '../../../models/core/enums/assignment_enums.dart' as api;
import '../../../services/api/assignment_service.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/enrollment_service.dart';
import '../../../services/storage_service.dart';
import '../../../utils/navigation/safe_back.dart';
import '../../../widgets/instructor/assignments/submission_list_item.dart';

class AssignmentSubmissionsScreen extends StatelessWidget {
  const AssignmentSubmissionsScreen({
    super.key,
    required this.assignmentId,
    this.assignmentTitle,
    this.maxScore,
    this.assignmentDueDate,
    this.latePenaltyPercent = 0,
    this.isArchived = false,
    this.assignmentService,
    this.enrollmentService,
  });

  final int assignmentId;
  final String? assignmentTitle;
  final double? maxScore;
  final DateTime? assignmentDueDate;
  final double latePenaltyPercent;
  final bool isArchived;
  final AssignmentService? assignmentService;
  final EnrollmentService? enrollmentService;

  @override
  Widget build(BuildContext context) {
    final coreApiClient = CoreApiClient(storageService: StorageService());
    final resolvedAssignmentService =
        assignmentService ?? AssignmentService(coreApiClient: coreApiClient);
    final resolvedEnrollmentService =
        enrollmentService ?? EnrollmentService(coreApiClient: coreApiClient);

    return BlocProvider<InstructorAssignmentsCubit>(
      create: (_) => InstructorAssignmentsCubit(
        assignmentService: resolvedAssignmentService,
        enrollmentService: resolvedEnrollmentService,
      )..loadSubmissions(assignmentId, page: 1, limit: 20),
      child: _AssignmentSubmissionsView(
        assignmentId: assignmentId,
        assignmentTitle: assignmentTitle,
        maxScore: maxScore,
        assignmentDueDate: assignmentDueDate,
        latePenaltyPercent: latePenaltyPercent,
        isArchived: isArchived,
      ),
    );
  }
}

class _AssignmentSubmissionsView extends StatefulWidget {
  const _AssignmentSubmissionsView({
    required this.assignmentId,
    this.assignmentTitle,
    this.maxScore,
    this.assignmentDueDate,
    this.latePenaltyPercent = 0,
    this.isArchived = false,
  });

  final int assignmentId;
  final String? assignmentTitle;
  final double? maxScore;
  final DateTime? assignmentDueDate;
  final double latePenaltyPercent;
  final bool isArchived;

  @override
  State<_AssignmentSubmissionsView> createState() =>
      _AssignmentSubmissionsViewState();
}

class _AssignmentSubmissionsViewState
    extends State<_AssignmentSubmissionsView> {
  String _searchQuery = '';
  String _filter = 'all';
  _SubmissionSortField _sortField = _SubmissionSortField.submissionDate;
  bool _sortAscending = false;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InstructorAssignmentsCubit, InstructorAssignmentsState>(
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<InstructorAssignmentsCubit>();
        final submissions = _applyFiltersAndSort(state.submissions);
        final totalCount = state.submissions.length;
        final gradedCount = state.submissions
            .where(
              (item) =>
                  item.submissionStatus == api.SubmissionStatus.graded ||
                  item.submissionStatus == api.SubmissionStatus.returned,
            )
            .length;
        final pendingCount = state.submissions
            .where(
              (item) =>
                  item.submissionStatus == api.SubmissionStatus.submitted ||
                  item.submissionStatus == api.SubmissionStatus.resubmit,
            )
            .length;
        final lateCount = state.submissions.where((item) => item.isLate).length;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => safeBack(context, '/instructor/dashboard'),
              icon: Icon(iosBackIcon(context)),
            ),
            title: Text(widget.assignmentTitle ?? 'Assignment Submissions'),
          ),
          body: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    _StatChip(label: 'Total', count: totalCount),
                    _StatChip(label: 'Pending', count: pendingCount),
                    _StatChip(label: 'Graded', count: gradedCount),
                    _StatChip(label: 'Late', count: lateCount),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  onChanged: (value) {
                    _debounce?.cancel();
                    _debounce = Timer(const Duration(milliseconds: 300), () {
                      if (!mounted) {
                        return;
                      }
                      setState(() => _searchQuery = value);
                    });
                  },
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
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: <Widget>[
                            _FilterChip(
                              label: 'All',
                              selected: _filter == 'all',
                              onTap: () => setState(() => _filter = 'all'),
                            ),
                            _FilterChip(
                              label: 'Ungraded',
                              selected: _filter == 'ungraded',
                              onTap: () => setState(() => _filter = 'ungraded'),
                            ),
                            _FilterChip(
                              label: 'Graded',
                              selected: _filter == 'graded',
                              onTap: () => setState(() => _filter = 'graded'),
                            ),
                            _FilterChip(
                              label: 'Late',
                              selected: _filter == 'late',
                              onTap: () => setState(() => _filter = 'late'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<_SubmissionSortField>(
                      value: _sortField,
                      items: const <DropdownMenuItem<_SubmissionSortField>>[
                        DropdownMenuItem(
                          value: _SubmissionSortField.studentName,
                          child: Text('Student'),
                        ),
                        DropdownMenuItem(
                          value: _SubmissionSortField.submissionDate,
                          child: Text('Date'),
                        ),
                        DropdownMenuItem(
                          value: _SubmissionSortField.score,
                          child: Text('Score'),
                        ),
                        DropdownMenuItem(
                          value: _SubmissionSortField.status,
                          child: Text('Status'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() => _sortField = value);
                      },
                    ),
                    IconButton(
                      onPressed: () =>
                          setState(() => _sortAscending = !_sortAscending),
                      icon: Icon(
                        _sortAscending
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: state.submissionsLoading && state.submissions.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : submissions.isEmpty
                    ? const _EmptySubmissionsState()
                    : RefreshIndicator(
                        onRefresh: () => cubit.loadSubmissions(
                          widget.assignmentId,
                          page: 1,
                          limit: 20,
                        ),
                        child: CustomScrollView(
                          slivers: <Widget>[
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                              sliver: SliverList.builder(
                                itemCount: submissions.length,
                                itemBuilder: (context, index) {
                                  final submission = submissions[index];
                                  return SubmissionListItem(
                                    submission: submission,
                                    onTap: () =>
                                        _openGrading(context, submission),
                                  );
                                },
                              ),
                            ),
                            if (state.hasMoreSubmissions)
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    16,
                                  ),
                                  child: OutlinedButton(
                                    onPressed: state.submissionsLoading
                                        ? null
                                        : () => cubit.loadSubmissions(
                                            widget.assignmentId,
                                            page: state.submissionsPage + 1,
                                            limit: 20,
                                          ),
                                    child: state.submissionsLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text('Load More'),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openGrading(
    BuildContext context,
    AssignmentSubmissionModel submission,
  ) async {
    final result = await context.push<bool>(
      '/instructor/assignments/${widget.assignmentId}/submissions/${submission.id}/grading',
      extra: <String, dynamic>{
        'assignmentTitle': widget.assignmentTitle,
        'maxScore': widget.maxScore,
        'assignmentDueDate': widget.assignmentDueDate,
        'latePenaltyPercent': widget.latePenaltyPercent,
        'isArchived': widget.isArchived,
      },
    );

    if (result == true && mounted) {
      await context.read<InstructorAssignmentsCubit>().loadSubmissions(
        widget.assignmentId,
        page: 1,
        limit: 20,
      );
    }
  }

  List<AssignmentSubmissionModel> _applyFiltersAndSort(
    List<AssignmentSubmissionModel> source,
  ) {
    final query = _searchQuery.trim().toLowerCase();

    final filtered = source.where((item) {
      final name = _studentName(item).toLowerCase();
      final matchesSearch = query.isEmpty || name.contains(query);

      final isGraded =
          item.submissionStatus == api.SubmissionStatus.graded ||
          item.submissionStatus == api.SubmissionStatus.returned;
      final isUngraded =
          item.submissionStatus == api.SubmissionStatus.submitted ||
          item.submissionStatus == api.SubmissionStatus.resubmit ||
          item.submissionStatus == api.SubmissionStatus.unknown;

      final matchesFilter =
          _filter == 'all' ||
          (_filter == 'graded' && isGraded) ||
          (_filter == 'ungraded' && isUngraded) ||
          (_filter == 'late' && item.isLate);

      return matchesSearch && matchesFilter;
    }).toList();

    filtered.sort((a, b) {
      int result;
      switch (_sortField) {
        case _SubmissionSortField.studentName:
          result = _studentName(
            a,
          ).toLowerCase().compareTo(_studentName(b).toLowerCase());
          break;
        case _SubmissionSortField.submissionDate:
          result = a.submittedAt.compareTo(b.submittedAt);
          break;
        case _SubmissionSortField.score:
          result = (a.score ?? -1).compareTo(b.score ?? -1);
          break;
        case _SubmissionSortField.status:
          result = a.submissionStatus.value.compareTo(b.submissionStatus.value);
          break;
      }
      return _sortAscending ? result : -result;
    });

    return filtered;
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
      return const Color(0xFFDC2626);
    }

    switch (status) {
      case api.SubmissionStatus.submitted:
      case api.SubmissionStatus.resubmit:
        return const Color(0xFFF59E0B);
      case api.SubmissionStatus.graded:
      case api.SubmissionStatus.returned:
        return const Color(0xFF16A34A);
      case api.SubmissionStatus.unknown:
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

enum _SubmissionSortField { studentName, submissionDate, score, status }

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
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _EmptySubmissionsState extends StatelessWidget {
  const _EmptySubmissionsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const <Widget>[
            Icon(Icons.inbox_outlined, size: 52),
            SizedBox(height: 10),
            Text(
              'No submissions found for this assignment.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            count.toString(),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}
