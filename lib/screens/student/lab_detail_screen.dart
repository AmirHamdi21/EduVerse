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
import '../../models/core/enums/assignment_enums.dart' as api;
import '../../models/core/enums/lab_enums.dart';
import '../../models/labs/lab_model.dart';
import '../../models/labs/lab_submission_model.dart';
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
              title: Text(
                l10n.labDetails,
                style: TextStyle(
                  fontSize: responsive.fontSize18,
                  fontWeight: FontWeight.w700,
                ),
              ),
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
                      onSubmitPressed: null,
                    );
                  }

                  return const LabDetailLoadingView();
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
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(responsive.p24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: responsive.p80,
                height: responsive.p80,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: responsive.fontSize40,
                  color: const Color(0xFFEF4444),
                ),
              ),
              SizedBox(height: responsive.p16),
              Text(
                'Unable to load lab details',
                style: TextStyle(
                  fontSize: responsive.fontSize20,
                  fontWeight: FontWeight.w800,
                  color: _StudentLabDetailColors.textPrimary(isDark),
                ),
              ),
              SizedBox(height: responsive.p8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: responsive.fontSize14,
                  color: _StudentLabDetailColors.textSecondary(isDark),
                  height: 1.45,
                ),
              ),
              SizedBox(height: responsive.p20),
              FilledButton.icon(
                onPressed: () => context.read<LabDetailCubit>().loadLab(labId),
                style: FilledButton.styleFrom(
                  backgroundColor: _StudentLabDetailColors.primary,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
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
  final VoidCallback? onSubmitPressed;

  const _LabDetailBody({
    required this.state,
    required this.isDark,
    required this.onSubmitPressed,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final l10n = AppLocalizations.of(context);
    final latestSubmission = _latestSubmission;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        responsive.p16,
        responsive.p8,
        responsive.p16,
        responsive.p24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildHero(context, l10n, responsive),
          SizedBox(height: responsive.p16),
          _buildSnapshotGrid(context, responsive),
          SizedBox(height: responsive.p16),
          _buildOverviewSection(context, l10n, responsive),
          if ((state.lab.description ?? '').trim().isNotEmpty) ...<Widget>[
            SizedBox(height: responsive.p16),
            _buildContentCard(
              context,
              title: l10n.description,
              icon: Icons.notes_rounded,
              child: Text(
                state.lab.description!,
                style: TextStyle(
                  fontSize: responsive.fontSize14,
                  color: _StudentLabDetailColors.textSecondary(isDark),
                  height: 1.55,
                ),
              ),
            ),
          ],
          SizedBox(height: responsive.p16),
          _buildContentCard(
            context,
            title: l10n.instructions,
            icon: Icons.menu_book_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (state.isLoadingInstructions)
                  Padding(
                    padding: EdgeInsets.only(bottom: responsive.p12),
                    child: const LinearProgressIndicator(
                      color: _StudentLabDetailColors.primary,
                    ),
                  ),
                InstructionViewer(
                  instructions: state.instructions,
                  attachmentFiles: state.lab.instructionFiles,
                  isDark: isDark,
                ),
              ],
            ),
          ),
          SizedBox(height: responsive.p16),
          _buildContentCard(
            context,
            title: 'My submissions',
            icon: Icons.cloud_done_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (latestSubmission != null) ...<Widget>[
                  Wrap(
                    spacing: responsive.p8,
                    runSpacing: responsive.p8,
                    children: <Widget>[
                      _buildInfoPill(
                        context,
                        icon: Icons.event_rounded,
                        text:
                            '${l10n.submitted} ${latestSubmission.formattedSubmittedAt}',
                      ),
                      _buildInfoPill(
                        context,
                        icon: Icons.flag_rounded,
                        text: latestSubmission.isLate
                            ? l10n.late
                            : _submissionStatusLabel(
                                latestSubmission.submissionStatus,
                                l10n,
                              ),
                        color: latestSubmission.isLate
                            ? _StudentLabDetailColors.error
                            : _statusColorForSubmission(
                                latestSubmission.submissionStatus,
                              ),
                      ),
                    ],
                  ),
                  SizedBox(height: responsive.p14),
                  _buildLatestSubmissionSummary(
                    context,
                    latestSubmission,
                    responsive,
                  ),
                  SizedBox(height: responsive.p16),
                ],
                if (state.isLoadingSubmissions)
                  Padding(
                    padding: EdgeInsets.only(bottom: responsive.p12),
                    child: const LinearProgressIndicator(
                      color: _StudentLabDetailColors.primary,
                    ),
                  ),
                SubmissionHistoryView(
                  submissions: state.mySubmissions,
                  maxScore: state.lab.maxScore,
                  isDark: isDark,
                ),
              ],
            ),
          ),
          if (state.lab.isAcceptingSubmissions ||
              onSubmitPressed != null) ...<Widget>[
            SizedBox(height: responsive.p20),
            _buildActionCard(context, l10n, responsive),
          ],
        ],
      ),
    );
  }

  LabSubmissionModel? get _latestSubmission {
    if (state.mySubmissions.isEmpty) {
      return null;
    }

    final ordered = List<LabSubmissionModel>.from(state.mySubmissions)
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    return ordered.first;
  }

  Widget _buildHero(
    BuildContext context,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: <Color>[
                  Color(0xFF1E3A8A),
                  Color(0xFF2563EB),
                  Color(0xFF0EA5E9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: <Color>[
                  Color(0xFF2563EB),
                  Color(0xFF3B82F6),
                  Color(0xFF60A5FA),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(
              0xFF2563EB,
            ).withValues(alpha: isDark ? 0.28 : 0.2),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -34,
              right: -4,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -44,
              left: -18,
              child: Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(responsive.p18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Wrap(
                    spacing: responsive.p8,
                    runSpacing: responsive.p8,
                    children: <Widget>[
                      _buildHeroChip(
                        icon: Icons.menu_book_rounded,
                        label: state.lab.course?.code ?? 'LAB',
                      ),
                      _buildHeroChip(
                        icon: Icons.science_rounded,
                        label: state.lab.labNumber == null
                            ? 'Lab'
                            : 'Lab ${state.lab.labNumber}',
                      ),
                      _buildHeroChip(
                        icon: Icons.stars_rounded,
                        label: '${_formatScore(state.lab.maxScore)} pts',
                      ),
                    ],
                  ),
                  SizedBox(height: responsive.p14),
                  Text(
                    state.lab.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: responsive.isMobile
                          ? responsive.fontSize24
                          : responsive.fontSize28,
                      fontWeight: FontWeight.w800,
                      height: 1.12,
                    ),
                  ),
                  SizedBox(height: responsive.p6),
                  Text(
                    '${state.lab.course?.name ?? "Course"} • ${_statusLabel(state.lab.status)}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.84),
                      fontSize: responsive.fontSize14,
                      height: 1.35,
                    ),
                  ),
                  SizedBox(height: responsive.p16),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(responsive.p14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.calendar_month_rounded,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: responsive.p12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                state.lab.isPastDue
                                    ? 'Deadline passed'
                                    : 'Next deadline',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.76),
                                  fontSize: responsive.fontSize12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: responsive.p4),
                              Text(
                                state.lab.formattedDueDate,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: responsive.fontSize16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: responsive.p12,
                            vertical: responsive.p8,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor(
                              state.lab.status,
                            ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _statusLabel(state.lab.status),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: responsive.fontSize12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSnapshotGrid(BuildContext context, ResponsiveUtil responsive) {
    final cards = <({IconData icon, String label, String value, Color color})>[
      (
        icon: Icons.stars_rounded,
        label: 'Max score',
        value: _formatScore(state.lab.maxScore),
        color: _StudentLabDetailColors.primary,
      ),
      (
        icon: Icons.pie_chart_rounded,
        label: 'Weight',
        value: '${state.lab.weight.toStringAsFixed(0)}%',
        color: _StudentLabDetailColors.accent,
      ),
      (
        icon: Icons.schedule_send_rounded,
        label: 'Available from',
        value: state.lab.availableFrom == null
            ? 'Immediately'
            : _formatDate(state.lab.availableFrom!),
        color: _StudentLabDetailColors.info,
      ),
      (
        icon: Icons.assignment_turned_in_rounded,
        label: 'Submissions',
        value: '${state.mySubmissions.length}',
        color: _StudentLabDetailColors.success,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 4 : 2;
        final spacing = responsive.p10;
        final itemWidth =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards
              .map((card) {
                return SizedBox(
                  width: itemWidth,
                  child: Container(
                    padding: EdgeInsets.all(responsive.p14),
                    decoration: BoxDecoration(
                      color: _StudentLabDetailColors.card(isDark),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _StudentLabDetailColors.border(
                          isDark,
                        ).withValues(alpha: 0.7),
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.08 : 0.03,
                          ),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: card.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(card.icon, color: card.color, size: 20),
                        ),
                        SizedBox(height: responsive.p12),
                        Text(
                          card.value,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: responsive.fontSize14,
                            fontWeight: FontWeight.w800,
                            color: _StudentLabDetailColors.textPrimary(isDark),
                          ),
                        ),
                        SizedBox(height: responsive.p4),
                        Text(
                          card.label,
                          style: TextStyle(
                            fontSize: responsive.fontSize12,
                            fontWeight: FontWeight.w600,
                            color: _StudentLabDetailColors.textSecondary(
                              isDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              })
              .toList(growable: false),
        );
      },
    );
  }

  Widget _buildOverviewSection(
    BuildContext context,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    final rows = <({IconData icon, String label, String value})>[
      (
        icon: Icons.school_rounded,
        label: l10n.course,
        value:
            '${state.lab.course?.name ?? "Course"} (${state.lab.course?.code ?? "N/A"})',
      ),
      (
        icon: Icons.science_outlined,
        label: 'Lab number',
        value: state.lab.labNumber == null
            ? 'Lab activity'
            : 'Lab ${state.lab.labNumber}',
      ),
      (
        icon: Icons.calendar_today_rounded,
        label: l10n.dueDate,
        value: state.lab.formattedDueDate,
      ),
      (
        icon: Icons.verified_rounded,
        label: 'Attendance',
        value: state.attendanceStatus == LabAttendanceStatus.present
            ? 'Attendance: Present'
            : 'No attendance record',
      ),
    ];

    return _buildContentCard(
      context,
      title: 'Lab snapshot',
      icon: Icons.dashboard_customize_rounded,
      child: Column(
        children: rows
            .map((row) {
              final isLast = identical(row, rows.last);
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : responsive.p12),
                child: Container(
                  padding: EdgeInsets.all(responsive.p12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _StudentLabDetailColors.border(
                        isDark,
                      ).withValues(alpha: 0.55),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: _StudentLabDetailColors.primary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          row.icon,
                          color: _StudentLabDetailColors.primary,
                          size: 18,
                        ),
                      ),
                      SizedBox(width: responsive.p10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              row.label,
                              style: TextStyle(
                                fontSize: responsive.fontSize12,
                                fontWeight: FontWeight.w700,
                                color: _StudentLabDetailColors.textSecondary(
                                  isDark,
                                ),
                              ),
                            ),
                            SizedBox(height: responsive.p4),
                            Text(
                              row.value,
                              style: TextStyle(
                                fontSize: responsive.fontSize14,
                                fontWeight: FontWeight.w700,
                                color: _StudentLabDetailColors.textPrimary(
                                  isDark,
                                ),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }

  Widget _buildContentCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final responsive = context.responsive;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.p16),
      decoration: BoxDecoration(
        color: _StudentLabDetailColors.card(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _StudentLabDetailColors.border(isDark).withValues(alpha: 0.72),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.035),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _StudentLabDetailColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: _StudentLabDetailColors.primary,
                  size: 24,
                ),
              ),
              SizedBox(width: responsive.p12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: responsive.fontSize18,
                    fontWeight: FontWeight.w800,
                    color: _StudentLabDetailColors.textPrimary(isDark),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.p16),
          child,
        ],
      ),
    );
  }

  Widget _buildLatestSubmissionSummary(
    BuildContext context,
    LabSubmissionModel submission,
    ResponsiveUtil responsive,
  ) {
    final score = submission.score;
    final percentage = score == null || state.lab.maxScore <= 0
        ? null
        : (score / state.lab.maxScore * 100).clamp(0, 100);
    final color = score == null
        ? _StudentLabDetailColors.success
        : _statusColorForSubmission(submission.submissionStatus);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.p14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            color.withValues(alpha: 0.16),
            _StudentLabDetailColors.info.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              score == null ? '--' : _formatCompactScore(score),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(width: responsive.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  score == null
                      ? 'Waiting for grading'
                      : '${_formatScore(score)} / ${_formatScore(state.lab.maxScore)}',
                  style: TextStyle(
                    fontSize: responsive.fontSize20,
                    fontWeight: FontWeight.w800,
                    color: _StudentLabDetailColors.textPrimary(isDark),
                  ),
                ),
                SizedBox(height: responsive.p4),
                Text(
                  score == null
                      ? 'Your latest lab work was submitted successfully.'
                      : '${percentage!.toStringAsFixed(0)}% overall score',
                  style: TextStyle(
                    fontSize: responsive.fontSize13,
                    color: _StudentLabDetailColors.textSecondary(isDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.p16),
      decoration: BoxDecoration(
        color: _StudentLabDetailColors.card(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _StudentLabDetailColors.border(isDark).withValues(alpha: 0.72),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.035),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            state.mySubmissions.isEmpty
                ? 'Ready for your first submission'
                : 'Submit an updated version',
            style: TextStyle(
              fontSize: responsive.fontSize18,
              fontWeight: FontWeight.w800,
              color: _StudentLabDetailColors.textPrimary(isDark),
            ),
          ),
          SizedBox(height: responsive.p6),
          Text(
            'Use the submission sheet to upload a file, add text, and keep your lab progress moving.',
            style: TextStyle(
              fontSize: responsive.fontSize14,
              color: _StudentLabDetailColors.textSecondary(isDark),
              height: 1.5,
            ),
          ),
          SizedBox(height: responsive.p16),
          if (state.isSubmitting)
            Padding(
              padding: EdgeInsets.only(bottom: responsive.p12),
              child: LinearProgressIndicator(
                value: state.submitProgress > 0
                    ? state.submitProgress.clamp(0, 1)
                    : null,
                minHeight: 8,
                borderRadius: BorderRadius.circular(999),
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0xFFE2E8F0),
                color: _StudentLabDetailColors.primary,
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: responsive.p56,
            child: ElevatedButton.icon(
              onPressed: state.isSubmitting ? null : onSubmitPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: _StudentLabDetailColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade500,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: state.isSubmitting
                  ? SizedBox(
                      width: responsive.p18,
                      height: responsive.p18,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      state.mySubmissions.isEmpty
                          ? Icons.upload_rounded
                          : Icons.replay_rounded,
                    ),
              label: Text(
                state.isSubmitting
                    ? 'Submitting...'
                    : (state.mySubmissions.isEmpty
                          ? 'Submit Lab'
                          : 'Submit Updated Work'),
                style: TextStyle(
                  fontSize: responsive.fontSize16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPill(
    BuildContext context, {
    required IconData icon,
    required String text,
    Color? color,
  }) {
    final responsive = context.responsive;
    final resolvedColor = color ?? _StudentLabDetailColors.primary;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.p10,
        vertical: responsive.p6,
      ),
      decoration: BoxDecoration(
        color: resolvedColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: resolvedColor),
          SizedBox(width: responsive.p6),
          Text(
            text,
            style: TextStyle(
              color: resolvedColor,
              fontSize: responsive.fontSize12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime value) {
    final hour = value.hour > 12 ? value.hour - 12 : value.hour;
    final suffix = value.hour >= 12 ? 'PM' : 'AM';
    return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')} ${hour == 0 ? 12 : hour}:${value.minute.toString().padLeft(2, '0')} $suffix';
  }

  String _formatScore(double value) {
    return value == value.roundToDouble()
        ? value.round().toString()
        : value.toStringAsFixed(1);
  }

  String _formatCompactScore(double value) {
    return value == value.roundToDouble()
        ? value.round().toString()
        : value.toStringAsFixed(1);
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

  Color _statusColor(LabStatus status) {
    switch (status) {
      case LabStatus.published:
        return _StudentLabDetailColors.success;
      case LabStatus.closed:
        return const Color(0xFF64748B);
      case LabStatus.archived:
        return const Color(0xFF475569);
      case LabStatus.draft:
        return _StudentLabDetailColors.warning;
      case LabStatus.unknown:
        return const Color(0xFF94A3B8);
    }
  }

  String _submissionStatusLabel(
    api.SubmissionStatus status,
    AppLocalizations l10n,
  ) {
    switch (status) {
      case api.SubmissionStatus.graded:
        return 'Graded';
      case api.SubmissionStatus.returned:
        return 'Returned';
      case api.SubmissionStatus.resubmit:
        return 'Resubmit';
      case api.SubmissionStatus.submitted:
        return l10n.submitted;
      case api.SubmissionStatus.unknown:
        return l10n.pending;
    }
  }

  Color _statusColorForSubmission(api.SubmissionStatus status) {
    switch (status) {
      case api.SubmissionStatus.graded:
        return _StudentLabDetailColors.success;
      case api.SubmissionStatus.returned:
        return _StudentLabDetailColors.warning;
      case api.SubmissionStatus.resubmit:
        return _StudentLabDetailColors.accent;
      case api.SubmissionStatus.submitted:
        return _StudentLabDetailColors.primary;
      case api.SubmissionStatus.unknown:
        return _StudentLabDetailColors.info;
    }
  }
}

class LabDetailLoadingView extends StatelessWidget {
  const LabDetailLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    Widget block({double? height, double? width}) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(14),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(responsive.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: responsive.isMobile ? 240 : 220,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[
                  Color(0xFF2563EB),
                  Color(0xFF3B82F6),
                  Color(0xFF60A5FA),
                ],
              ),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Padding(
              padding: EdgeInsets.all(responsive.p18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  block(height: 32, width: 160),
                  SizedBox(height: responsive.p12),
                  block(height: 20, width: double.infinity),
                  SizedBox(height: responsive.p10),
                  block(height: 20, width: responsive.screenWidth * 0.55),
                  const Spacer(),
                  block(height: 78, width: double.infinity),
                ],
              ),
            ),
          ),
          SizedBox(height: responsive.p16),
          Wrap(
            spacing: responsive.p10,
            runSpacing: responsive.p10,
            children: List<Widget>.generate(4, (_) {
              return Container(
                width:
                    (responsive.screenWidth -
                        (responsive.p16 * 2) -
                        responsive.p10) /
                    2,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                padding: EdgeInsets.all(responsive.p14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    block(height: 40, width: 40),
                    SizedBox(height: responsive.p12),
                    block(height: 18, width: 90),
                    SizedBox(height: responsive.p6),
                    block(height: 12, width: 60),
                  ],
                ),
              );
            }),
          ),
          SizedBox(height: responsive.p16),
          ...List<Widget>.generate(3, (_) {
            return Container(
              margin: EdgeInsets.only(bottom: responsive.p16),
              padding: EdgeInsets.all(responsive.p16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  block(height: 20, width: 180),
                  SizedBox(height: responsive.p16),
                  block(height: 16, width: double.infinity),
                  SizedBox(height: responsive.p10),
                  block(height: 16, width: double.infinity),
                  SizedBox(height: responsive.p10),
                  block(height: 16, width: responsive.screenWidth * 0.5),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _StudentLabDetailColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color accent = Color(0xFF8B5CF6);
  static const Color info = Color(0xFF0EA5E9);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  static Color card(bool isDark) {
    return isDark ? const Color(0xFF111827) : Colors.white;
  }

  static Color border(bool isDark) {
    return isDark ? const Color(0xFF334155) : const Color(0xFFD9E2F0);
  }

  static Color textPrimary(bool isDark) {
    return isDark ? Colors.white : const Color(0xFF0F172A);
  }

  static Color textSecondary(bool isDark) {
    return isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);
  }
}
