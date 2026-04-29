import 'package:edu_verse/common/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../bloc/ta/ta_labs_cubit.dart';
import '../../../bloc/ta/ta_labs_state.dart';
import '../../../bloc/ta/ta_courses_cubit.dart';
import '../../../bloc/ta/ta_courses_state.dart';
import '../../../models/labs/lab_model.dart';
import '../../../models/labs/lab_submission_model.dart';
import '../../../models/instructor/teaching_course_model.dart';
import '../../../models/core/course_model.dart';
import '../../../models/core/section_model.dart';
import '../../../models/core/semester_model.dart';
import '../../../models/core/enums/course_enums.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../shared/lab_editor_screen.dart';
import '../../../widgets/ta/shared/ta_colors.dart';
import '../../../widgets/instructor/assignments/grading_panel.dart';
import '../../../widgets/instructor/labs/lab_create_form.dart';
import '../../../widgets/instructor/labs/attendance_sheet.dart';
import '../../../models/core/lab_attendance_model.dart';
import '../../../models/core/enums/lab_enums.dart' as lab_enums;
import '../../../services/api/lab_service.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/storage_service.dart';
import '../../../bloc/instructor/lab_detail_cubit.dart';
import '../../../bloc/instructor/lab_detail_state.dart';
import '../../../widgets/instructor/labs/instruction_manager.dart';
import '../../../widgets/shared/submission_detail_viewer.dart';

/// T030: TA Lab Detail Screen — fully refactored from mock data to TALabsCubit.
/// All mock model classes (TALabDetail, TALabTaskItem, TALabQuestion, etc.) removed.
/// Includes read-only Submissions tab (US4 AC3) and Attendance tab.
class TALabDetailScreen extends StatefulWidget {
  final String labId;
  final LabService? labService;

  const TALabDetailScreen({super.key, required this.labId, this.labService});

  @override
  State<TALabDetailScreen> createState() => _TALabDetailScreenState();
}

class _TALabDetailScreenState extends State<TALabDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late LabDetailCubit _instructionCubit;
  late LabService _labService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // T030: Resolve LabService — try provider tree, fallback to local instance
    try {
      _labService = context.read<LabService>();
    } catch (_) {
      final coreApiClient = CoreApiClient(storageService: StorageService());
      _labService = LabService(coreApiClient: coreApiClient);
    }

    // T030: Fetch via cubit — loads lab info + submissions + attendance
    context.read<TALabsCubit>().fetchLabDetail(widget.labId);

    // T045: Local LabDetailCubit for InstructionManager reuse
    _instructionCubit = LabDetailCubit(labService: _labService);
    _instructionCubit.loadLabDetail(widget.labId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _instructionCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return BlocConsumer<TALabsCubit, TALabsState>(
          listener: (context, state) {
            final l10n = AppLocalizations.of(context);
            if (state is TALabGradeSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.gradeSubmitted),
                  backgroundColor: TAColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is TALabGradeError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${l10n.failed}: ${state.message}'),
                  backgroundColor: TAColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is TALabDetailLoading || state is TALabGrading) {
              return Scaffold(
                backgroundColor: TAColors.scaffoldColor(isDark),
                body: Center(
                  child: CircularProgressIndicator(color: TAColors.primary),
                ),
              );
            }

            if (state is TALabDetailError) {
              return Scaffold(
                backgroundColor: TAColors.scaffoldColor(isDark),
                appBar: AppBar(
                  backgroundColor: TAColors.scaffoldColor(isDark),
                  leading: IconButton(
                    onPressed: () {
                      context.read<TALabsCubit>().restoreLabsList();
                      context.pop();
                    },
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: TAColors.textPrimaryColor(isDark),
                    ),
                  ),
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: TAColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        style: TextStyle(
                          color: TAColors.textSecondaryColor(isDark),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => context
                            .read<TALabsCubit>()
                            .fetchLabDetail(widget.labId),
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(l10n.retry),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is TALabDetailLoaded ||
                state is TALabAttendanceRefreshing) {
              final lab = state is TALabDetailLoaded
                  ? state.lab
                  : (state as TALabAttendanceRefreshing).lab;
              final submissions = state is TALabDetailLoaded
                  ? state.submissions
                  : (state as TALabAttendanceRefreshing).submissions;
              final attendance = state is TALabDetailLoaded
                  ? state.attendance
                  : (state as TALabAttendanceRefreshing).attendance;

              return _buildDetailScaffold(
                isDark,
                l10n,
                lab,
                submissions,
                attendance,
              );
            }

            return Scaffold(
              backgroundColor: TAColors.scaffoldColor(isDark),
              body: Center(
                child: CircularProgressIndicator(color: TAColors.primary),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailScaffold(
    bool isDark,
    AppLocalizations l10n,
    LabModel lab,
    List<LabSubmissionModel> submissions,
    List<LabAttendanceModel> attendance,
  ) {
    return Scaffold(
      backgroundColor: TAColors.scaffoldColor(isDark),
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              _buildSliverAppBar(isDark, l10n, lab, innerBoxIsScrolled),
              SliverToBoxAdapter(child: _buildLabHeader(isDark, l10n, lab)),
              SliverToBoxAdapter(
                child: _buildStatsRow(isDark, lab, submissions),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(
                  tabBar: _buildTabBar(isDark, l10n),
                  backgroundColor: TAColors.scaffoldColor(isDark),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(isDark, l10n, lab),
              _buildSubmissionsTab(isDark, l10n, lab, submissions),
              _buildAttendanceTab(isDark, l10n, attendance),
              _buildInstructionsTab(isDark, l10n),
            ],
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(
    bool isDark,
    AppLocalizations l10n,
    LabModel lab,
    bool innerBoxIsScrolled,
  ) {
    return SliverAppBar(
      backgroundColor: TAColors.scaffoldColor(isDark),
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        onPressed: () {
          context.read<TALabsCubit>().restoreLabsList();
          context.pop();
        },
        icon: Icon(
          Icons.arrow_back_rounded,
          color: TAColors.textPrimaryColor(isDark),
        ),
      ),
      title: AnimatedOpacity(
        opacity: innerBoxIsScrolled ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Text(
          lab.title,
          style: TextStyle(
            color: TAColors.textPrimaryColor(isDark),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () =>
              context.read<ThemeBloc>().add(const ToggleThemeEvent()),
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: TAColors.textSecondaryColor(isDark),
          ),
        ),
        // T033: Delete action
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert_rounded,
            color: TAColors.textSecondaryColor(isDark),
          ),
          onSelected: (value) {
            if (value == 'edit') {
              _openEditLabForm(isDark, lab);
            } else if (value == 'delete') {
              _confirmDeleteLab(lab);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(
                    Icons.edit_rounded,
                    size: 20,
                    color: TAColors.textPrimaryColor(isDark),
                  ),
                  const SizedBox(width: 10),
                  Text(l10n.taLabEdit),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_rounded, size: 20, color: TAColors.error),
                  const SizedBox(width: 10),
                  Text(
                    l10n.taLabDelete,
                    style: const TextStyle(color: TAColors.error),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
      floating: true,
      snap: true,
    );
  }

  Widget _buildLabHeader(bool isDark, AppLocalizations l10n, LabModel lab) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: TAColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  lab.course?.code ?? '${l10n.course} #${lab.courseId}',
                  style: TextStyle(
                    color: TAColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if ((lab.course?.name ?? '').isNotEmpty)
                Text(
                  lab.course!.name,
                  style: TextStyle(
                    color: TAColors.textSecondaryColor(isDark),
                    fontSize: 13,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            lab.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: TAColors.textPrimaryColor(isDark),
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (lab.description != null) ...[
            const SizedBox(height: 8),
            Text(
              lab.description!,
              style: TextStyle(
                color: TAColors.textSecondaryColor(isDark),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsRow(
    bool isDark,
    LabModel lab,
    List<LabSubmissionModel> submissions,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 420;
          final spacing = 8.0;
          final itemWidth = isCompact
              ? (constraints.maxWidth - spacing) / 2
              : (constraints.maxWidth - (spacing * 2)) / 3;
          final l10n = AppLocalizations.of(context);
          final cards = [
            _buildStatCard(
              isDark,
              _statusLabel(l10n, lab.status),
              l10n.taLabStatus,
              Icons.info_rounded,
              TAColors.info,
              width: itemWidth,
            ),
            _buildStatCard(
              isDark,
              '${submissions.length}',
              l10n.taLabSubmissions,
              Icons.assignment_rounded,
              TAColors.warning,
              width: itemWidth,
            ),
            _buildStatCard(
              isDark,
              _formatDueDate(context, l10n, lab),
              l10n.taLabDue,
              Icons.calendar_today_rounded,
              TAColors.error,
              width: itemWidth,
            ),
          ];

          return Wrap(spacing: spacing, runSpacing: spacing, children: cards);
        },
      ),
    );
  }

  Widget _buildStatCard(
    bool isDark,
    String value,
    String label,
    IconData icon,
    Color color, {
    double? width,
  }) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: TAColors.textPrimaryColor(isDark),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: TextStyle(
                color: TAColors.textSecondaryColor(isDark),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  TabBar _buildTabBar(bool isDark, AppLocalizations l10n) {
    final r = context.responsive;
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      padding: EdgeInsets.zero,
      labelColor: TAColors.primary,
      unselectedLabelColor: TAColors.textSecondaryColor(isDark),
      indicatorColor: TAColors.primary,
      indicatorWeight: 3,
      labelStyle: TextStyle(
        fontSize: r.isMobile ? 13 : 14,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: r.isMobile ? 13 : 14,
        fontWeight: FontWeight.w500,
      ),
      tabs: [
        Tab(text: l10n.taLabOverview),
        Tab(text: l10n.taLabSubmissionsTab),
        Tab(text: l10n.taLabAttendanceTab),
        Tab(text: l10n.instructions),
      ],
    );
  }

  // ── Tab 1: Overview ──────────────────────────────────────────

  Widget _buildOverviewTab(bool isDark, AppLocalizations l10n, LabModel lab) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(isDark, l10n.taLabInformation),
          const SizedBox(height: 8),
          _buildInfoCard(
            isDark,
            l10n.taLabMaxScore,
            '${lab.maxScore}',
            Icons.stars_rounded,
            TAColors.warning,
          ),
          if (lab.weight > 0)
            _buildInfoCard(
              isDark,
              l10n.quizWeight,
              '${lab.weight}%',
              Icons.balance_rounded,
              TAColors.info,
            ),
          _buildInfoCard(
            isDark,
            l10n.taLabStatus,
            _statusLabel(l10n, lab.status),
            Icons.flag_rounded,
            TAColors.success,
          ),
          _buildInfoCard(
            isDark,
            l10n.dueDate,
            _formatDueDate(context, l10n, lab),
            Icons.calendar_today_rounded,
            TAColors.error,
          ),
          if (lab.instructions.isNotEmpty) ...[
            const SizedBox(height: 16),
            _sectionTitle(isDark, l10n.instructions),
            const SizedBox(height: 8),
            ...lab.instructions.map(
              (instr) => _buildInfoCard(
                isDark,
                '${l10n.instructions} #${instr.orderIndex + 1}',
                instr.instructionText ?? l10n.instructions,
                Icons.description_rounded,
                TAColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sectionTitle(bool isDark, String title) {
    return Text(
      title,
      style: TextStyle(
        color: TAColors.textPrimaryColor(isDark),
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildInfoCard(
    bool isDark,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: TAColors.textSecondaryColor(isDark),
                    fontSize: 11,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab 2: Submissions (T030/T036) ───────────────────────────

  Widget _buildSubmissionsTab(
    bool isDark,
    AppLocalizations l10n,
    LabModel lab,
    List<LabSubmissionModel> submissions,
  ) {
    if (submissions.isEmpty) {
      return _buildEmptyTab(
        isDark,
        l10n.taLabNoSubmissionsDesc,
        Icons.inbox_rounded,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: submissions.length,
      itemBuilder: (ctx, i) =>
          _buildSubmissionCard(isDark, l10n, lab, submissions[i]),
    );
  }

  Widget _buildSubmissionCard(
    bool isDark,
    AppLocalizations l10n,
    LabModel lab,
    LabSubmissionModel sub,
  ) {
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
                            : '${l10n.student} #${sub.userId}',
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
                                l10n.late.toUpperCase(),
                                style: TextStyle(
                                  color: TAColors.error,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
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
                      '${sub.score}/${lab.maxScore}',
                      style: TextStyle(
                        color: TAColors.success,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 360;
                final viewButton = OutlinedButton.icon(
                  onPressed: () => _viewLabSubmission(l10n, lab, sub),
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: Text(l10n.view),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: TAColors.primary,
                    side: BorderSide(
                      color: TAColors.primary.withValues(alpha: 0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
                final gradeButton = OutlinedButton.icon(
                  onPressed: () => _openLabGrading(isDark, lab, sub),
                  icon: Icon(
                    isGraded ? Icons.edit_rounded : Icons.grading_rounded,
                    size: 16,
                  ),
                  label: Text(isGraded ? l10n.taLabRegrade : l10n.grade),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: TAColors.primary,
                    side: BorderSide(
                      color: TAColors.primary.withValues(alpha: 0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );

                if (isCompact) {
                  return Column(
                    children: [
                      SizedBox(width: double.infinity, child: viewButton),
                      const SizedBox(height: 8),
                      SizedBox(width: double.infinity, child: gradeButton),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: viewButton),
                    const SizedBox(width: 8),
                    Expanded(child: gradeButton),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // T037: View lab submission details
  Future<void> _viewLabSubmission(
    AppLocalizations l10n,
    LabModel lab,
    LabSubmissionModel sub,
  ) async {
    final studentName = sub.user != null
        ? '${sub.user!.firstName} ${sub.user!.lastName}'.trim()
        : '${l10n.student} #${sub.userId}';

    await SubmissionDetailViewer.showLab(
      context: context,
      submission: sub,
      studentName: studentName.isEmpty
          ? '${l10n.student} #${sub.userId}'
          : studentName,
      labTitle: lab.title,
      maxScore: lab.maxScore,
      onGrade: (score, feedback) async {
        // Grade from submission viewer
        context.read<TALabsCubit>().gradeLabSubmission(
          lab.id,
          sub.id,
          score,
          feedback,
          'graded',
        );
      },
    );
  }

  // T037: Grade lab submission via GradingPanel
  void _openLabGrading(bool isDark, LabModel lab, LabSubmissionModel sub) {
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
              maxScore: lab.maxScore,
              initialScore: sub.score,
              initialFeedback: sub.feedback,
              onSave: (score, feedback) async {
                Navigator.of(ctx).pop();
                // Principle I: route through cubit
                context.read<TALabsCubit>().gradeLabSubmission(
                  lab.id,
                  sub.id,
                  score,
                  feedback,
                  'graded',
                );
              },
            ),
          ),
        );
      },
    );
  }

  // ── Tab 3: Attendance (T042) — shared AttendanceSheet ───────

  Widget _buildAttendanceTab(
    bool isDark,
    AppLocalizations l10n,
    List<LabAttendanceModel> attendance,
  ) {
    if (attendance.isEmpty) {
      return _buildEmptyTab(
        isDark,
        l10n.taLabNoAttendanceDesc,
        Icons.people_rounded,
      );
    }

    return AttendanceSheet(
      records: attendance,
      canManage: true,
      onMarkAttendance:
          (int userId, lab_enums.LabAttendanceStatus status) async {
            // T042: Mark attendance via LabService then refresh cubit
            await _labService.markAttendance(widget.labId, <String, dynamic>{
              'userId': userId,
              'attendanceStatus': status.toJson(),
            });
            // Principle I: refresh through cubit
            if (mounted) {
              context.read<TALabsCubit>().refreshLabAttendance(widget.labId);
            }
          },
    );
  }

  Widget _buildEmptyTab(bool isDark, String message, IconData icon) {
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
            child: Icon(icon, size: 48, color: TAColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab 4: Instructions (T045/T046) ─────────────────────────

  Widget _buildInstructionsTab(bool isDark, AppLocalizations l10n) {
    return BlocProvider<LabDetailCubit>.value(
      value: _instructionCubit,
      child: BlocConsumer<LabDetailCubit, LabDetailState>(
        listener: (context, state) {
          // T048: Show error/success messages
          if (state is LabDetailLoaded) {
            if (state.message != null && state.message!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message!),
                  backgroundColor: TAColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              _instructionCubit.clearMessages();
              // Refresh TALabsCubit to sync instructions back (Principle I)
              context.read<TALabsCubit>().fetchLabDetail(widget.labId);
            }
            if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: TAColors.error,
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: l10n.retry,
                    textColor: Colors.white,
                    onPressed: () {
                      _instructionCubit.loadInstructions(widget.labId);
                    },
                  ),
                ),
              );
              _instructionCubit.clearMessages();
            }
          }
        },
        builder: (context, state) {
          if (state is LabDetailLoading) {
            return Center(
              child: CircularProgressIndicator(color: TAColors.primary),
            );
          }

          if (state is LabDetailError) {
            return _buildEmptyTab(
              isDark,
              state.message,
              Icons.error_outline_rounded,
            );
          }

          if (state is LabDetailLoaded) {
            final instructions = state.instructions ?? [];
            final isUpdating = state is LabInstructionUpdating;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // T045/T046: InstructionManager (add text + upload files)
                  InstructionManager(
                    labId: widget.labId,
                    instructions: instructions,
                    canManage: true,
                    isUpdating: isUpdating,
                  ),
                ],
              ),
            );
          }

          // Fallback — loading state
          return Center(
            child: CircularProgressIndicator(color: TAColors.primary),
          );
        },
      ),
    );
  }

  // T033: Delete lab confirmation with submission check
  void _confirmDeleteLab(LabModel lab) {
    final state = context.read<TALabsCubit>().state;
    final hasSubmissions =
        state is TALabDetailLoaded && state.submissions.isNotEmpty;
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.taLabDelete),
        content: Text(
          hasSubmissions
              ? l10n.taLabDeleteWithSubmissionsConfirm
              : l10n.taLabDeleteConfirm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<TALabsCubit>().deleteLab(lab.id);
              context.go('/ta/labs');
            },
            style: TextButton.styleFrom(foregroundColor: TAColors.error),
            child: Text(hasSubmissions ? l10n.taLabDeleteAnyway : l10n.delete),
          ),
        ],
      ),
    );
  }

  // T032: Open Edit Lab form
  Future<void> _openEditLabForm(bool _, LabModel lab) async {
    final coursesState = context.read<TACoursesCubit>().state;
    final courses =
        coursesState.coursesStatus is TASubTabLoaded<List<TeachingCourseModel>>
        ? (coursesState.coursesStatus
                  as TASubTabLoaded<List<TeachingCourseModel>>)
              .data
        : <TeachingCourseModel>[];
    final l10n = AppLocalizations.of(context);
    final fallbackCourses = courses.isNotEmpty
        ? courses
        : <TeachingCourseModel>[
            TeachingCourseModel(
              courseId: lab.courseId,
              sectionId: 0,
              course: CourseModel(
                id: lab.courseId,
                departmentId: 0,
                code: lab.course?.code ?? 'COURSE',
                name: lab.course?.name ?? '${l10n.course} #${lab.courseId}',
                description: null,
                credits: 0,
                courseLevel: CourseLevel.unknown,
                courseStatus: CourseStatus.unknown,
              ),
              section: SectionModel(
                id: 0,
                courseId: lab.courseId,
                semesterId: 0,
                sectionNumber: '1',
                maxCapacity: 0,
                currentEnrollment: 0,
                location: null,
                sectionStatus: SectionStatus.unknown,
              ),
              semester: const SemesterModel(id: 0, name: ''),
              role: 'ta',
            ),
          ];

    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute<Map<String, dynamic>>(
        builder: (_) => LabEditorScreen(
          role: LabComposerRole.ta,
          courses: fallbackCourses,
          existingLab: lab,
          onSave: (data) async {
            final result = await _labService.update(lab.id, data);
            if (!result.isSuccess) {
              return result.error?.message ?? l10n.taLabPermissionEditDenied;
            }
            return null;
          },
        ),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_labSavedMessage(result['status']?.toString())),
        backgroundColor: TAColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.read<TALabsCubit>().fetchLabDetail(widget.labId);
  }

  String _formatDueDate(
    BuildContext context,
    AppLocalizations l10n,
    LabModel lab,
  ) {
    if (lab.dueDate == null) {
      return l10n.taLabNoDueDate;
    }

    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMMMd(locale).add_jm().format(lab.dueDate!.toLocal());
  }

  String _labSavedMessage(String? rawStatus) {
    final status = rawStatus?.trim().toLowerCase();
    return switch (status) {
      'published' => AppLocalizations.of(context).taLabsCreatedPublished,
      'draft' => AppLocalizations.of(context).taLabsCreatedDraft,
      _ => AppLocalizations.of(context).taLabsCreatedDraft,
    };
  }

  String _statusLabel(AppLocalizations l10n, lab_enums.LabStatus status) {
    return switch (status) {
      lab_enums.LabStatus.published => l10n.taLabActive,
      lab_enums.LabStatus.draft => l10n.draft,
      lab_enums.LabStatus.closed => l10n.taLabClosed,
      lab_enums.LabStatus.archived => l10n.archived,
      lab_enums.LabStatus.unknown => status.value.toUpperCase(),
    };
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  _SliverTabBarDelegate({required this.tabBar, required this.backgroundColor});

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: backgroundColor, child: tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
