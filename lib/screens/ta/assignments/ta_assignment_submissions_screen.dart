import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/ta/ta_assignment_submissions_cubit.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../models/assignments/assignment_model.dart';
import '../../../models/assignments/assignment_submission_model.dart';
import '../../../services/api/assignment_service.dart';
import '../../../widgets/ta/shared/ta_colors.dart';
import '../../../widgets/instructor/assignments/grading_panel.dart';

/// T023-T028: TA Assignment Submissions Screen
/// Provides a locally-scoped TAAssignmentSubmissionsCubit.
class TAAssignmentSubmissionsScreen extends StatelessWidget {
  final AssignmentModel assignment;

  const TAAssignmentSubmissionsScreen({super.key, required this.assignment});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => TAAssignmentSubmissionsCubit(
        assignmentService: ctx.read<AssignmentService>(),
      )..fetchSubmissions(assignment.assignmentId),
      child: _TASubmissionsBody(assignment: assignment),
    );
  }
}

class _TASubmissionsBody extends StatefulWidget {
  final AssignmentModel assignment;

  const _TASubmissionsBody({required this.assignment});

  @override
  State<_TASubmissionsBody> createState() => _TASubmissionsBodyState();
}

class _TASubmissionsBodyState extends State<_TASubmissionsBody> {
  // T024: Local filter state
  String _statusFilter = 'all'; // all | graded | ungraded
  String _lateFilter = 'all'; // all | late | ontime

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return Scaffold(
          backgroundColor: TAColors.scaffoldColor(isDark),
          appBar: AppBar(
            backgroundColor: TAColors.scaffoldColor(isDark),
            surfaceTintColor: Colors.transparent,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.assignment.title,
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Submissions',
                  style: TextStyle(
                    color: TAColors.textSecondaryColor(isDark),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            iconTheme: IconThemeData(color: TAColors.textPrimaryColor(isDark)),
          ),
          body: BlocConsumer<TAAssignmentSubmissionsCubit, TASubsState>(
            // T025: Listener for grade success/error toasts
            listener: (context, state) {
              if (state is TASubsGradeSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Grade saved successfully!'),
                    backgroundColor: TAColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else if (state is TASubsGradeError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Grading failed: ${state.message}'),
                    backgroundColor: TAColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is TASubsLoading || state is TASubsGrading) {
                return Center(
                  child: CircularProgressIndicator(color: TAColors.primary),
                );
              }

              if (state is TASubsError) {
                return _buildError(isDark, state.message);
              }

              if (state is TASubsLoaded) {
                return _buildSubmissionsList(isDark, state.submissions);
              }

              // TASubsGradeSuccess/TASubsGradeError are transient — show spinner
              return Center(
                child: CircularProgressIndicator(color: TAColors.primary),
              );
            },
          ),
        );
      },
    );
  }

  // T024: Apply local filters
  List<AssignmentSubmissionModel> _applyFilters(
    List<AssignmentSubmissionModel> subs,
  ) {
    var filtered = subs;

    if (_statusFilter == 'graded') {
      filtered = filtered
          .where((s) => s.submissionStatus.value == 'graded')
          .toList();
    } else if (_statusFilter == 'ungraded') {
      filtered = filtered
          .where((s) => s.submissionStatus.value != 'graded')
          .toList();
    }

    if (_lateFilter == 'late') {
      filtered = filtered.where((s) => s.isLate).toList();
    } else if (_lateFilter == 'ontime') {
      filtered = filtered.where((s) => !s.isLate).toList();
    }

    return filtered;
  }

  Widget _buildSubmissionsList(
    bool isDark,
    List<AssignmentSubmissionModel> submissions,
  ) {
    final filtered = _applyFilters(submissions);

    return Column(
      children: [
        // T024: Filter chips
        _buildFilterBar(isDark, submissions),
        Expanded(
          child: filtered.isEmpty
              ? _buildEmpty(isDark)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) =>
                      _buildSubmissionItem(isDark, filtered[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildFilterBar(bool isDark, List<AssignmentSubmissionModel> allSubs) {
    final ungradedCount = allSubs
        .where((s) => s.submissionStatus.value != 'graded')
        .length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filterChip(
              isDark,
              'All (${allSubs.length})',
              'all',
              _statusFilter,
              (v) => setState(() => _statusFilter = v),
            ),
            const SizedBox(width: 8),
            _filterChip(
              isDark,
              'Ungraded ($ungradedCount)',
              'ungraded',
              _statusFilter,
              (v) => setState(() => _statusFilter = v),
            ),
            const SizedBox(width: 8),
            _filterChip(
              isDark,
              'Graded (${allSubs.length - ungradedCount})',
              'graded',
              _statusFilter,
              (v) => setState(() => _statusFilter = v),
            ),
            const SizedBox(width: 16),
            _filterChip(
              isDark,
              'All Time',
              'all',
              _lateFilter,
              (v) => setState(() => _lateFilter = v),
            ),
            const SizedBox(width: 8),
            _filterChip(
              isDark,
              'Late',
              'late',
              _lateFilter,
              (v) => setState(() => _lateFilter = v),
            ),
            const SizedBox(width: 8),
            _filterChip(
              isDark,
              'On Time',
              'ontime',
              _lateFilter,
              (v) => setState(() => _lateFilter = v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(
    bool isDark,
    String label,
    String value,
    String currentValue,
    ValueChanged<String> onTap,
  ) {
    final isSelected = currentValue == value;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(value),
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? TAColors.primary : TAColors.cardColor(isDark),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? TAColors.primary
                  : TAColors.borderColor(isDark),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : TAColors.textPrimaryColor(isDark),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmissionItem(bool isDark, AssignmentSubmissionModel sub) {
    final isGraded = sub.submissionStatus.value == 'graded';
    final studentName =
        '${sub.user?.firstName ?? ''} ${sub.user?.lastName ?? ''}'.trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (isGraded ? TAColors.success : TAColors.warning)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isGraded
                        ? Icons.check_circle_rounded
                        : Icons.pending_rounded,
                    size: 20,
                    color: isGraded ? TAColors.success : TAColors.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentName.isNotEmpty
                            ? studentName
                            : 'Student #${sub.userId}',
                        style: TextStyle(
                          color: TAColors.textPrimaryColor(isDark),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            sub.submissionStatus.value.toUpperCase(),
                            style: TextStyle(
                              color: TAColors.textSecondaryColor(isDark),
                              fontSize: 11,
                            ),
                          ),
                          if (sub.isLate) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: TAColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'LATE',
                                style: TextStyle(
                                  color: TAColors.error,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                          if (sub.attemptNumber > 1) ...[
                            const SizedBox(width: 6),
                            Text(
                              'Attempt ${sub.attemptNumber}',
                              style: TextStyle(
                                color: TAColors.textTertiaryColor(isDark),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // T026: Show score if graded
                if (isGraded && sub.score != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: TAColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${sub.score}/${widget.assignment.maxGrade}',
                      style: TextStyle(
                        color: TAColors.success,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            // T026: Previous grader info for re-grading
            if (isGraded && sub.gradedBy != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TAColors.surfaceColor(isDark),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_rounded,
                      size: 14,
                      color: TAColors.textTertiaryColor(isDark),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Graded by #${sub.gradedBy}',
                      style: TextStyle(
                        color: TAColors.textTertiaryColor(isDark),
                        fontSize: 11,
                      ),
                    ),
                    if (sub.gradedAt != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '${sub.gradedAt!.day}/${sub.gradedAt!.month}/${sub.gradedAt!.year}',
                        style: TextStyle(
                          color: TAColors.textTertiaryColor(isDark),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            // T025: Grade button with GradingPanel
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openGradingPanel(isDark, sub),
                icon: Icon(
                  isGraded ? Icons.edit_rounded : Icons.grading_rounded,
                  size: 16,
                ),
                label: Text(isGraded ? 'Re-grade' : 'Grade'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: TAColors.primary,
                  side: BorderSide(
                    color: TAColors.primary.withValues(alpha: 0.3),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // T025: Open GradingPanel in a modal bottom sheet
  void _openGradingPanel(bool isDark, AssignmentSubmissionModel sub) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: TAColors.cardColor(isDark),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GradingPanel(
              maxScore: widget.assignment.maxGrade,
              initialScore: sub.score,
              initialFeedback: sub.feedback,
              latePenaltyPercent: widget.assignment.latePenaltyPercent,
              daysLate: sub.isLate
                  ? widget.assignment.dueDate
                        .difference(sub.submittedAt)
                        .inDays
                        .abs()
                  : 0,
              onSave: (score, feedback) async {
                Navigator.of(ctx).pop();
                // Principle I: Route through cubit
                context.read<TAAssignmentSubmissionsCubit>().gradeSubmission(
                  widget.assignment.assignmentId,
                  sub.id,
                  score,
                  feedback,
                );
              },
            ),
          ),
        );
      },
    );
  }

  // T028: Empty state
  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: TAColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.inbox_rounded, size: 48, color: TAColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'No submissions found for this assignment',
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(bool isDark, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 48, color: TAColors.error),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<TAAssignmentSubmissionsCubit>().fetchSubmissions(
                widget.assignment.assignmentId,
              );
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: TAColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
