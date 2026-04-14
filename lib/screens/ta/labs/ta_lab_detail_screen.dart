import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
import '../../../generated_l10n/app_localizations.dart';
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
    _instructionCubit = LabDetailCubit(
      labService: _labService,
    );
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
            if (state is TALabGradeSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Grade saved successfully!'),
                  backgroundColor: TAColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is TALabGradeError) {
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
                    onPressed: () => context.pop(),
                    icon: Icon(Icons.arrow_back_rounded,
                        color: TAColors.textPrimaryColor(isDark)),
                  ),
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline_rounded,
                          size: 48, color: TAColors.error),
                      const SizedBox(height: 16),
                      Text(state.message,
                          style: TextStyle(
                              color: TAColors.textSecondaryColor(isDark))),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => context
                            .read<TALabsCubit>()
                            .fetchLabDetail(widget.labId),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is TALabDetailLoaded || state is TALabAttendanceRefreshing) {
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
                  isDark, l10n, lab, submissions, attendance);
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
              SliverToBoxAdapter(child: _buildLabHeader(isDark, lab)),
              SliverToBoxAdapter(child: _buildStatsRow(isDark, lab, submissions)),
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
              _buildOverviewTab(isDark, lab),
              _buildSubmissionsTab(isDark, lab, submissions),
              _buildAttendanceTab(isDark, attendance),
              _buildInstructionsTab(isDark, lab),
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
        onPressed: () => context.pop(),
        icon: Icon(Icons.arrow_back_rounded,
            color: TAColors.textPrimaryColor(isDark)),
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
          icon: Icon(Icons.more_vert_rounded,
              color: TAColors.textSecondaryColor(isDark)),
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
                  Icon(Icons.edit_rounded,
                      size: 20, color: TAColors.textPrimaryColor(isDark)),
                  const SizedBox(width: 10),
                  const Text('Edit Lab'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_rounded,
                      size: 20, color: TAColors.error),
                  const SizedBox(width: 10),
                  Text('Delete Lab',
                      style: TextStyle(color: TAColors.error)),
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

  Widget _buildLabHeader(bool isDark, LabModel lab) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: TAColors.primary
                      .withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  lab.course?.code ?? 'Course #${lab.courseId}',
                  style: TextStyle(
                    color: TAColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  lab.course?.name ?? '',
                  style: TextStyle(
                    color: TAColors.textSecondaryColor(isDark),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            lab.title,
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
      child: Row(
        children: [
          _buildStatCard(isDark, lab.status.toJson().toUpperCase(), 'Status',
              Icons.info_rounded, TAColors.info),
          const SizedBox(width: 8),
          _buildStatCard(isDark, '${submissions.length}', 'Submissions',
              Icons.assignment_rounded, TAColors.warning),
          const SizedBox(width: 8),
          _buildStatCard(isDark, lab.formattedDueDate, 'Due',
              Icons.calendar_today_rounded, TAColors.error),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    bool isDark,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: color.withValues(alpha: 0.2)),
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
              maxLines: 1,
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
    return TabBar(
      controller: _tabController,
      labelColor: TAColors.primary,
      unselectedLabelColor: TAColors.textSecondaryColor(isDark),
      indicatorColor: TAColors.primary,
      indicatorWeight: 3,
      labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      unselectedLabelStyle:
          const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      tabs: [
        Tab(text: l10n.taLabOverview),
        Tab(text: l10n.taLabSubmissionsTab),
        Tab(text: l10n.taLabAttendanceTab),
        const Tab(text: 'Instructions'),
      ],
    );
  }

  // ── Tab 1: Overview ──────────────────────────────────────────

  Widget _buildOverviewTab(bool isDark, LabModel lab) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(isDark, 'Lab Information'),
          const SizedBox(height: 8),
          _buildInfoCard(isDark, 'Max Score', '${lab.maxScore}',
              Icons.stars_rounded, TAColors.warning),
          if (lab.weight > 0)
            _buildInfoCard(isDark, 'Weight', '${lab.weight}%',
                Icons.balance_rounded, TAColors.info),
          _buildInfoCard(
              isDark,
              'Status',
              lab.status.toJson().toUpperCase(),
              Icons.flag_rounded,
              TAColors.success),
          _buildInfoCard(isDark, 'Due Date', lab.formattedDueDate,
              Icons.calendar_today_rounded, TAColors.error),
          if (lab.instructions.isNotEmpty) ...[
            const SizedBox(height: 16),
            _sectionTitle(isDark, 'Instructions'),
            const SizedBox(height: 8),
            ...lab.instructions.map((instr) => _buildInfoCard(
                  isDark,
                  'Instruction #${instr.orderIndex + 1}',
                  instr.instructionText ?? 'File attachment',
                  Icons.description_rounded,
                  TAColors.primary,
                )),
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
            color: TAColors.borderColor(isDark).withValues(alpha: 0.5)),
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
                Text(title,
                    style: TextStyle(
                      color: TAColors.textSecondaryColor(isDark),
                      fontSize: 11,
                    )),
                Text(value,
                    style: TextStyle(
                      color: TAColors.textPrimaryColor(isDark),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
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
    LabModel lab,
    List<LabSubmissionModel> submissions,
  ) {
    if (submissions.isEmpty) {
      return _buildEmptyTab(isDark, 'No submissions found for this lab',
          Icons.inbox_rounded);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: submissions.length,
      itemBuilder: (ctx, i) =>
          _buildSubmissionCard(isDark, lab, submissions[i]),
    );
  }

  Widget _buildSubmissionCard(
    bool isDark,
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
            color: TAColors.borderColor(isDark).withValues(alpha: 0.5)),
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
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color:
                                    TAColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('LATE',
                                  style: TextStyle(
                                    color: TAColors.error,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  )),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (isGraded && sub.score != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            // T037: Grade button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openLabGrading(isDark, lab, sub),
                icon: Icon(
                  isGraded ? Icons.edit_rounded : Icons.grading_rounded,
                  size: 16,
                ),
                label: Text(isGraded ? 'Re-grade' : 'Grade'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: TAColors.primary,
                  side: BorderSide(
                      color: TAColors.primary.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
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
              bottom: MediaQuery.of(ctx).viewInsets.bottom),
          decoration: BoxDecoration(
            color: TAColors.cardColor(isDark),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
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

  Widget _buildAttendanceTab(bool isDark, List<LabAttendanceModel> attendance) {
    if (attendance.isEmpty) {
      return _buildEmptyTab(
          isDark, 'No attendance records for this lab', Icons.people_rounded);
    }

    return AttendanceSheet(
      records: attendance,
      canManage: true,
      onMarkAttendance: (int userId, lab_enums.LabAttendanceStatus status) async {
        // T042: Mark attendance via LabService then refresh cubit
        await _labService.markAttendance(
          widget.labId,
          <String, dynamic>{
            'userId': userId,
            'attendanceStatus': status.toJson(),
          },
        );
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

  Widget _buildInstructionsTab(bool isDark, LabModel lab) {
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
                    label: 'Retry',
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
                  const SizedBox(height: 24),
                  // T047: TA Materials placeholder
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: TAColors.info.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: TAColors.info.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            color: TAColors.info, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'TA Materials upload is not yet supported by the backend.',
                            style: TextStyle(
                              color: TAColors.info,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
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
    final hasSubmissions = state is TALabDetailLoaded &&
        state.submissions.isNotEmpty;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Lab'),
        content: Text(
          hasSubmissions
              ? 'This lab has existing student submissions. Deleting it will permanently remove all submission data. Continue?'
              : 'Are you sure you want to delete this lab?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<TALabsCubit>().deleteLab(lab.id);
              context.go('/ta/labs');
            },
            style: TextButton.styleFrom(foregroundColor: TAColors.error),
            child: Text(hasSubmissions ? 'Delete Anyway' : 'Delete'),
          ),
        ],
      ),
    );
  }

  // T032: Open Edit Lab form
  void _openEditLabForm(bool isDark, LabModel lab) {
    final coursesState = context.read<TACoursesCubit>().state;
    final courses = coursesState.coursesStatus is TASubTabLoaded<List<TeachingCourseModel>>
        ? (coursesState.coursesStatus as TASubTabLoaded<List<TeachingCourseModel>>).data
        : <TeachingCourseModel>[];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: TAColors.cardColor(isDark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (_, scrollController) {
            return LabCreateForm(
              courses: courses,
              existingLab: lab,
              onCancel: () => Navigator.of(ctx).pop(),
              onSubmit: (data) async {
                Navigator.of(ctx).pop();
                try {
                  await _labService.update(lab.id, data);
                  context.read<TALabsCubit>().fetchLabDetail(widget.labId);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          e.toString().contains('403')
                              ? "You don't have permission to edit this lab"
                              : 'Failed to update lab: $e',
                        ),
                        backgroundColor: TAColors.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
            );
          },
        );
      },
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  _SliverTabBarDelegate({
    required this.tabBar,
    required this.backgroundColor,
  });

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: backgroundColor, child: tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
