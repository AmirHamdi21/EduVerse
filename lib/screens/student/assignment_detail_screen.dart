import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/assignments/assignment_bloc.dart';
import '../../bloc/assignments/assignment_event.dart';
import '../../bloc/assignments/assignment_state.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../common/utils/responsive.dart';
import '../../config/app_theme.dart';
import '../../models/assignments/assignment_model.dart';
import '../../widgets/student/assignments/assignment_detail_body.dart';
import '../../widgets/student/assignments/submission_form_sheet.dart';

class AssignmentDetailScreen extends StatefulWidget {
  final AssignmentModel assignment;

  const AssignmentDetailScreen({super.key, required this.assignment});

  @override
  State<AssignmentDetailScreen> createState() => _AssignmentDetailScreenState();
}

class _AssignmentDetailScreenState extends State<AssignmentDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<AssignmentBloc>().add(
        SelectAssignment(assignment: widget.assignment),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return Scaffold(
          backgroundColor: isDark
              ? AppTheme.darkSurfaceColor
              : const Color(0xFFF8FAFC),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: isDark ? Colors.white : const Color(0xFF1E293B),
            title: Text(
              'Assignment Details',
              style: TextStyle(
                fontSize: responsive.fontSize18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: BlocConsumer<AssignmentBloc, AssignmentState>(
            listener: (context, state) {
              if (state.error == null) {
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error!),
                  backgroundColor: const Color(0xFFEF4444),
                ),
              );
              context.read<AssignmentBloc>().add(const ClearError());
            },
            builder: (context, state) {
              final assignment =
                  state.selectedAssignment != null &&
                      state.selectedAssignment!.assignmentId ==
                          widget.assignment.assignmentId
                  ? state.selectedAssignment!
                  : widget.assignment;

              if (state.isDetailLoading && state.selectedAssignment == null) {
                return const AssignmentDetailLoadingView();
              }

              return AssignmentDetailBody(
                assignment: assignment,
                mySubmission: state.mySubmission,
                isDark: isDark,
                isSubmitting: state.isSubmitting,
                submitProgress: state.submitProgress,
                onSubmitPressed: () =>
                    _openSubmissionForm(context, assignment, isDark),
                onResubmitPressed: () =>
                    _openSubmissionForm(context, assignment, isDark),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _openSubmissionForm(
    BuildContext context,
    AssignmentModel assignment,
    bool isDark,
  ) async {
    await SubmissionFormSheet.show(
      context,
      assignment: assignment,
      isDark: isDark,
    );
  }
}
