import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/lab_detail/lab_detail_cubit.dart';
import '../../bloc/lab_detail/lab_detail_state.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../common/utils/responsive.dart';
import '../../config/app_theme.dart';
import '../../generated_l10n/app_localizations.dart';
import '../../models/core/course_model.dart';
import '../../models/core/enums/lab_enums.dart';
import '../../models/labs/lab_model.dart';
import '../../services/api/enrollment_service.dart';
import '../../services/api/lab_service.dart';
import '../../widgets/student/labs/instruction_viewer.dart';
import '../../widgets/student/labs/lab_submission_sheet.dart';
import '../../widgets/student/labs/submission_history_view.dart';

class LabDetailScreen extends StatelessWidget {
  final String labId;
  final LabModel? lab;
  final List<CourseModel> enrolledCourses;
  final LabService labService;
  final EnrollmentService enrollmentService;

  const LabDetailScreen({
    super.key,
    required this.labId,
    required this.labService,
    required this.enrollmentService,
    this.lab,
    this.enrolledCourses = const <CourseModel>[],
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LabDetailCubit>(
      create: (_) {
        final cubit = LabDetailCubit(
          labService: labService,
          enrollmentService: enrollmentService,
          cachedEnrolledCourses: enrolledCourses,
        );

        if (lab != null) {
          cubit.seedWithLab(lab!);
        }

        cubit.initialize(labId);

        return cubit;
      },
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final isDark = themeState.isDark;
          final responsive = context.responsive;
          final l10n = AppLocalizations.of(context);

          return Scaffold(
            backgroundColor: isDark
                ? AppTheme.darkSurfaceColor
                : const Color(0xFFF8FAFC),
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor: isDark ? Colors.white : const Color(0xFF1E293B),
              title: Text(l10n.labDetails),
            ),
            body: BlocConsumer<LabDetailCubit, LabDetailState>(
              listener: (context, state) {
                if (state is! LabDetailLoaded) {
                  return;
                }

                if (state.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage!),
                      backgroundColor: const Color(0xFFEF4444),
                    ),
                  );
                  context.read<LabDetailCubit>().clearMessages();
                  return;
                }

                if (state.successMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.successMessage!),
                      backgroundColor: const Color(0xFF10B981),
                    ),
                  );
                  context.read<LabDetailCubit>().clearMessages();
                }
              },
              builder: (context, state) {
                if (state is LabDetailInitial || state is LabDetailLoading) {
                  final cachedLab = state is LabDetailLoading
                      ? state.cachedLab
                      : null;
                  if (cachedLab != null) {
                    return _LabDetailBody(
                      state: LabDetailLoaded(lab: cachedLab),
                      isDark: isDark,
                      responsive: responsive,
                      onSubmitPressed: null,
                    );
                  }

                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
                  );
                }

                if (state is LabDetailError) {
                  return _buildErrorState(
                    context,
                    state.message,
                    isDark,
                    responsive,
                  );
                }

                final loaded = state as LabDetailLoaded;
                return _LabDetailBody(
                  state: loaded,
                  isDark: isDark,
                  responsive: responsive,
                  onSubmitPressed: loaded.lab.isAcceptingSubmissions
                      ? () => _openSubmissionSheet(context, loaded, isDark)
                      : null,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    String message,
    bool isDark,
    ResponsiveUtil responsive,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(responsive.p24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: responsive.fontSize56,
              color: const Color(0xFFEF4444),
            ),
            SizedBox(height: responsive.p16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: responsive.fontSize14,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            SizedBox(height: responsive.p20),
            ElevatedButton.icon(
              onPressed: () => context.read<LabDetailCubit>().loadLab(labId),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openSubmissionSheet(
    BuildContext context,
    LabDetailLoaded loaded,
    bool isDark,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BlocProvider.value(
          value: context.read<LabDetailCubit>(),
          child: BlocBuilder<LabDetailCubit, LabDetailState>(
            builder: (context, state) {
              final detailState = state is LabDetailLoaded ? state : loaded;

              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: LabSubmissionSheet(
                  lab: detailState.lab,
                  isDark: isDark,
                  isSubmitting: detailState.isSubmitting,
                  submitProgress: detailState.submitProgress,
                  onSubmitText: (text) {
                    return context.read<LabDetailCubit>().submitText(
                      labId,
                      text,
                    );
                  },
                  onSubmitFile: (filePath, submissionText) {
                    return context.read<LabDetailCubit>().submitFile(
                      labId,
                      filePath,
                      submissionText: submissionText,
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _LabDetailBody extends StatelessWidget {
  final LabDetailLoaded state;
  final bool isDark;
  final ResponsiveUtil responsive;
  final VoidCallback? onSubmitPressed;

  const _LabDetailBody({
    required this.state,
    required this.isDark,
    required this.responsive,
    required this.onSubmitPressed,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1024;

        if (isDesktop) {
          return Row(
            children: [
              Expanded(
                flex: 4,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(responsive.p16),
                  child: _buildLeftColumn(context),
                ),
              ),
              VerticalDivider(
                width: 1,
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              ),
              Expanded(
                flex: 6,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(responsive.p16),
                  child: _buildRightColumn(context),
                ),
              ),
            ],
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(responsive.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLeftColumn(context),
              SizedBox(height: responsive.p16),
              _buildRightColumn(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLeftColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        SizedBox(height: responsive.p16),
        _buildMetaSection(),
        if (state.attendanceStatus == LabAttendanceStatus.present) ...[
          SizedBox(height: responsive.p12),
          _buildAttendanceBadge(),
        ],
        if (state.lab.status != LabStatus.closed &&
            state.lab.status != LabStatus.archived) ...[
          SizedBox(height: responsive.p16),
          _buildSubmitButton(),
        ],
      ],
    );
  }

  Widget _buildRightColumn(BuildContext context) {
    final hasGradedSubmission = state.mySubmissions
        .where((submission) => submission.score != null)
        .isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Instructions', Icons.menu_book_rounded),
        SizedBox(height: responsive.p8),
        if (state.isLoadingInstructions)
          const LinearProgressIndicator(color: Color(0xFF3B82F6)),
        InstructionViewer(
          instructions: state.instructions,
          attachmentFiles: state.lab.instructionFiles,
          isDark: isDark,
        ),
        SizedBox(height: responsive.p16),
        ExpansionTile(
          initiallyExpanded: hasGradedSubmission,
          tilePadding: EdgeInsets.zero,
          title: _buildSectionTitle('My Submissions', Icons.history_rounded),
          children: [
            if (state.isLoadingSubmissions)
              const LinearProgressIndicator(color: Color(0xFF3B82F6)),
            SubmissionHistoryView(
              submissions: state.mySubmissions,
              maxScore: state.lab.maxScore,
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: responsive.p56,
          height: responsive.p56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
            ),
            borderRadius: BorderRadius.circular(responsive.radius16),
          ),
          child: Icon(
            Icons.science_rounded,
            color: Colors.white,
            size: responsive.fontSize28,
          ),
        ),
        SizedBox(width: responsive.p12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.lab.title,
                style: TextStyle(
                  fontSize: responsive.fontSize20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: responsive.p4),
              Text(
                '${state.lab.course?.name ?? 'Course'} (${state.lab.course?.code ?? 'N/A'})',
                style: TextStyle(
                  fontSize: responsive.fontSize13,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetaSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.p14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey.shade800.withValues(alpha: 0.35)
            : Colors.white,
        borderRadius: BorderRadius.circular(responsive.radius12),
        border: Border.all(
          color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
        ),
      ),
      child: Wrap(
        spacing: responsive.p8,
        runSpacing: responsive.p8,
        children: [
          _metaChip(
            Icons.format_list_numbered_rounded,
            state.lab.labNumber == null ? 'Lab' : 'Lab ${state.lab.labNumber}',
            const Color(0xFF6366F1),
          ),
          _metaChip(
            Icons.calendar_today_rounded,
            state.lab.formattedDueDate,
            const Color(0xFF3B82F6),
          ),
          _metaChip(
            Icons.grade_rounded,
            '${state.lab.maxScore.toStringAsFixed(0)} pts',
            const Color(0xFF8B5CF6),
          ),
          _metaChip(
            Icons.pie_chart_rounded,
            '${state.lab.weight.toStringAsFixed(0)}% weight',
            const Color(0xFF0EA5E9),
          ),
          _metaChip(
            _statusIcon(state.lab.status),
            _statusLabel(state.lab.status),
            _statusColor(state.lab.status),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.p12,
        vertical: responsive.p8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(responsive.radius10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.verified_rounded,
            color: Color(0xFF10B981),
            size: 18,
          ),
          SizedBox(width: responsive.p6),
          Text(
            'Attendance: Present',
            style: TextStyle(
              fontSize: responsive.fontSize12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: responsive.p48,
      child: ElevatedButton.icon(
        onPressed: onSubmitPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.white,
        ),
        icon: const Icon(Icons.upload_rounded),
        label: Text(
          'Submit Work',
          style: TextStyle(
            fontSize: responsive.fontSize14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF3B82F6), size: responsive.fontSize18),
        SizedBox(width: responsive.p6),
        Text(
          title,
          style: TextStyle(
            fontSize: responsive.fontSize16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _metaChip(IconData icon, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.p10,
        vertical: responsive.p6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(responsive.radius8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: responsive.fontSize13, color: color),
          SizedBox(width: responsive.p4),
          Text(
            text,
            style: TextStyle(
              fontSize: responsive.fontSize12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(LabStatus status) {
    switch (status) {
      case LabStatus.published:
        return 'Active';
      case LabStatus.closed:
        return 'Closed';
      case LabStatus.archived:
        return 'Archived';
      case LabStatus.draft:
        return 'Draft';
      case LabStatus.unknown:
        return 'Unknown';
    }
  }

  IconData _statusIcon(LabStatus status) {
    switch (status) {
      case LabStatus.published:
        return Icons.play_circle_rounded;
      case LabStatus.closed:
        return Icons.check_circle_rounded;
      case LabStatus.archived:
        return Icons.archive_rounded;
      case LabStatus.draft:
        return Icons.edit_note_rounded;
      case LabStatus.unknown:
        return Icons.help_outline_rounded;
    }
  }

  Color _statusColor(LabStatus status) {
    switch (status) {
      case LabStatus.published:
        return const Color(0xFF10B981);
      case LabStatus.closed:
        return const Color(0xFF64748B);
      case LabStatus.archived:
        return const Color(0xFF475569);
      case LabStatus.draft:
        return const Color(0xFFF59E0B);
      case LabStatus.unknown:
        return const Color(0xFF94A3B8);
    }
  }
}
