import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/instructor/instructor_assignments_cubit.dart';
import '../../../bloc/instructor/instructor_assignments_state.dart';
import '../../../models/assignments/assignment_submission_model.dart';
import '../../../services/api/assignment_service.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/enrollment_service.dart';
import '../../../services/storage_service.dart';
import '../../../widgets/instructor/assignments/grading_panel.dart';
import '../../../widgets/instructor/assignments/submission_content_viewer.dart';

class SubmissionGradingScreen extends StatelessWidget {
  const SubmissionGradingScreen({
    super.key,
    required this.assignmentId,
    required this.submissionId,
    this.assignmentTitle,
    this.maxScore,
    this.assignmentDueDate,
    this.latePenaltyPercent = 0,
    this.isArchived = false,
    this.assignmentService,
    this.enrollmentService,
  });

  final int assignmentId;
  final int submissionId;
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
      child: _SubmissionGradingView(
        assignmentId: assignmentId,
        submissionId: submissionId,
        assignmentTitle: assignmentTitle,
        maxScore: maxScore,
        assignmentDueDate: assignmentDueDate,
        latePenaltyPercent: latePenaltyPercent,
        isArchived: isArchived,
      ),
    );
  }
}

class _SubmissionGradingView extends StatefulWidget {
  const _SubmissionGradingView({
    required this.assignmentId,
    required this.submissionId,
    this.assignmentTitle,
    this.maxScore,
    this.assignmentDueDate,
    this.latePenaltyPercent = 0,
    this.isArchived = false,
  });

  final int assignmentId;
  final int submissionId;
  final String? assignmentTitle;
  final double? maxScore;
  final DateTime? assignmentDueDate;
  final double latePenaltyPercent;
  final bool isArchived;

  @override
  State<_SubmissionGradingView> createState() => _SubmissionGradingViewState();
}

class _SubmissionGradingViewState extends State<_SubmissionGradingView> {
  bool _isSaving = false;

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
        final submission = state.submissions
            .where((item) => item.id == widget.submissionId)
            .firstOrNull;

        final effectiveMaxScore =
            widget.maxScore != null && widget.maxScore! > 0
            ? widget.maxScore!
            : 100.0;

        final studentName = submission == null
            ? null
            : _studentName(submission);
        final daysLate = _daysLate(submission);

        return Scaffold(
          appBar: AppBar(
            title: Text(
              studentName ?? widget.assignmentTitle ?? 'Grade Submission',
            ),
          ),
          body: submission == null
              ? Center(
                  child: state.submissionsLoading
                      ? const CircularProgressIndicator()
                      : const Text('Submission not found.'),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (widget.isArchived)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.orange.withValues(alpha: 0.25),
                            ),
                          ),
                          child: const Text(
                            'This assignment is archived. Grading is read-only.',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      _SubmissionSummaryCard(submission: submission),
                      const SizedBox(height: 14),
                      SubmissionContentViewer(submission: submission),
                      const SizedBox(height: 14),
                      GradingPanel(
                        maxScore: effectiveMaxScore,
                        initialScore: submission.score,
                        initialFeedback: submission.feedback,
                        latePenaltyPercent: widget.latePenaltyPercent,
                        daysLate: daysLate,
                        isSaving: _isSaving,
                        errorMessage: state.errorMessage,
                        readOnly: widget.isArchived,
                        onSave: (score, feedback) async {
                          await _saveGrade(cubit, submission, score, feedback);
                        },
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Future<void> _saveGrade(
    InstructorAssignmentsCubit cubit,
    AssignmentSubmissionModel submission,
    double score,
    String? feedback,
  ) async {
    setState(() => _isSaving = true);

    await cubit.gradeSubmission(submission.id, score, feedback);

    if (!mounted) {
      return;
    }

    final hasError = cubit.state.errorMessage != null;
    setState(() => _isSaving = false);

    if (!hasError) {
      await cubit.loadSubmissions(widget.assignmentId, page: 1, limit: 20);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Grade saved successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop(true);
    }
  }

  static String _formatScore(double value) {
    return value == value.roundToDouble()
        ? value.round().toString()
        : value.toStringAsFixed(1);
  }

  int _daysLate(AssignmentSubmissionModel? submission) {
    if (submission == null ||
        !submission.isLate ||
        widget.assignmentDueDate == null) {
      return 0;
    }

    final diff = submission.submittedAt.difference(widget.assignmentDueDate!);
    if (diff.isNegative) {
      return 0;
    }
    return diff.inDays == 0 ? 1 : diff.inDays;
  }
}

class _SubmissionSummaryCard extends StatelessWidget {
  const _SubmissionSummaryCard({required this.submission});

  final AssignmentSubmissionModel submission;

  @override
  Widget build(BuildContext context) {
    final studentName = _studentName(submission);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              studentName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text('Submitted at: ${_formatDateTime(submission.submittedAt)}'),
            const SizedBox(height: 4),
            Text('Status: ${submission.submissionStatus.value}'),
            if (submission.isLate)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Late submission',
                  style: TextStyle(
                    color: Color(0xFFDC2626),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

String _studentName(AssignmentSubmissionModel submission) {
  final first = submission.user?.firstName.trim() ?? '';
  final last = submission.user?.lastName.trim() ?? '';
  final fullName = '$first $last'.trim();
  if (fullName.isNotEmpty) {
    return fullName;
  }
  return 'Student #${submission.userId}';
}

String _formatDateTime(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '${value.year}-$month-$day $hour:$minute';
}
