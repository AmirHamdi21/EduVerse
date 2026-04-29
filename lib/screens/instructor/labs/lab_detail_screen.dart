import 'dart:io';

import 'package:edu_verse/common/utils/responsive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../bloc/instructor/lab_detail_cubit.dart';
import '../../../bloc/instructor/lab_detail_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/core/enums/assignment_enums.dart' as assignment_api;
import '../../../models/core/enums/course_enums.dart';
import '../../../models/core/enums/lab_enums.dart' as api;
import '../../../models/core/lab_attendance_model.dart';
import '../../../models/core/lab_instruction_model.dart';
import '../../../models/core/course_model.dart';
import '../../../models/core/section_model.dart';
import '../../../models/core/semester_model.dart';
import '../../../models/labs/lab_model.dart';
import '../../../models/labs/lab_submission_model.dart';
import '../../../models/instructor/teaching_course_model.dart';
import '../../shared/lab_editor_screen.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/lab_service.dart';
import '../../../services/storage_service.dart';
import '../../../widgets/instructor/labs/attendance_sheet.dart';
import '../../../widgets/instructor/labs/grading_panel.dart';
import '../../../widgets/instructor/labs/instruction_manager.dart';
import '../../../widgets/instructor/labs/lab_create_form.dart';
import '../../../widgets/instructor/shared/instructor_colors.dart';
import '../../../widgets/shared/submission_detail_viewer.dart';

class LabDetailScreen extends StatelessWidget {
  const LabDetailScreen({
    super.key,
    required this.labId,
    this.initialTab = 0,
    this.labService,
    this.storageService,
  });

  final String labId;
  final int initialTab;
  final LabService? labService;
  final StorageService? storageService;

  @override
  Widget build(BuildContext context) {
    final resolvedStorage = storageService ?? StorageService();
    final coreApiClient = CoreApiClient(storageService: resolvedStorage);
    final resolvedLabService =
        labService ?? LabService(coreApiClient: coreApiClient);

    return BlocProvider<LabDetailCubit>(
      create: (_) {
        final cubit = LabDetailCubit(labService: resolvedLabService);
        cubit.loadLabDetail(labId).then((_) {
          cubit.loadInstructions(labId);
          cubit.loadSubmissions(labId);
          cubit.loadAttendance(labId);
        });
        return cubit;
      },
      child: _LabDetailView(
        labId: labId,
        initialTab: initialTab,
        labService: resolvedLabService,
        storageService: resolvedStorage,
      ),
    );
  }
}

class _LabDetailView extends StatefulWidget {
  const _LabDetailView({
    required this.labId,
    required this.initialTab,
    required this.labService,
    required this.storageService,
  });

  final String labId;
  final int initialTab;
  final LabService labService;
  final StorageService storageService;

  @override
  State<_LabDetailView> createState() => _LabDetailViewState();
}

class _LabDetailViewState extends State<_LabDetailView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  bool _roleCheckDone = false;
  bool _canManage = false;
  bool _uploadingTaMaterial = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 3),
    );
    _resolveRoleAccess();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _resolveRoleAccess() async {
    try {
      final user = await widget.storageService.getUserData();
      final roleNames =
          user?.roles
              .map((role) => role.roleName.toLowerCase().trim())
              .toSet() ??
          <String>{};

      if (!mounted) {
        return;
      }

      setState(() {
        _roleCheckDone = true;
        _canManage = roleNames.isEmpty || roleNames.contains('instructor');
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _roleCheckDone = true;
        _canManage = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return BlocConsumer<LabDetailCubit, LabDetailState>(
          listener: (context, state) {
            if (state is! LabDetailLoaded) {
              return;
            }

            if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }

            if (state.message != null && state.message!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message!),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }

            context.read<LabDetailCubit>().clearMessages();
          },
          builder: (context, state) {
            if (state is LabDetailInitial || state is LabDetailLoading) {
              return Scaffold(
                backgroundColor: InstructorColors.background(isDark),
                appBar: AppBar(
                  backgroundColor: InstructorColors.background(isDark),
                  title: Text(
                    state is LabDetailLoading && state.cachedLab != null
                        ? state.cachedLab!.title
                        : l10n.taLabsTitle,
                  ),
                ),
                body: Center(
                  child: CircularProgressIndicator(
                    color: InstructorColors.primary,
                  ),
                ),
              );
            }

            if (state is LabDetailError) {
              return Scaffold(
                backgroundColor: InstructorColors.background(isDark),
                appBar: AppBar(
                  backgroundColor: InstructorColors.background(isDark),
                  leading: IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: InstructorColors.textPrimaryColor(isDark),
                    ),
                  ),
                  title: Text(l10n.taLabsTitle),
                ),
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          state.statusCode == 404
                              ? Icons.search_off_rounded
                              : Icons.error_outline_rounded,
                          size: 48,
                          color: state.statusCode == 404
                              ? InstructorColors.warning
                              : InstructorColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.statusCode == 404
                              ? l10n.instructorLabNotFound
                              : state.message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: InstructorColors.textSecondaryColor(isDark),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => context
                              .read<LabDetailCubit>()
                              .loadLabDetail(widget.labId),
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(l10n.retry),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: InstructorColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final loaded = state as LabDetailLoaded;
            return _buildDetailScaffold(isDark, l10n, loaded);
          },
        );
      },
    );
  }

  Widget _buildDetailScaffold(
    bool isDark,
    AppLocalizations l10n,
    LabDetailLoaded state,
  ) {
    return Scaffold(
      backgroundColor: InstructorColors.background(isDark),
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              _buildSliverAppBar(isDark, l10n, state.lab, innerBoxIsScrolled),
              SliverToBoxAdapter(
                child: _buildLabHeader(isDark, l10n, state.lab),
              ),
              SliverToBoxAdapter(
                child: _buildStatsRow(
                  isDark,
                  l10n,
                  state.lab,
                  state.submissions ?? const <LabSubmissionModel>[],
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(
                  tabBar: _buildTabBar(isDark, l10n),
                  backgroundColor: InstructorColors.background(isDark),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(isDark, l10n, state.lab),
              _buildSubmissionsTab(isDark, l10n, state.lab, state.submissions),
              _buildAttendanceTab(isDark, l10n, state.attendance),
              _buildInstructionsTab(isDark, l10n, state.instructions),
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
      backgroundColor: InstructorColors.background(isDark),
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Icon(
          Icons.arrow_back_rounded,
          color: InstructorColors.textPrimaryColor(isDark),
        ),
      ),
      title: AnimatedOpacity(
        opacity: innerBoxIsScrolled ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Text(
          lab.title,
          style: TextStyle(
            color: InstructorColors.textPrimaryColor(isDark),
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
            color: InstructorColors.textSecondaryColor(isDark),
          ),
        ),
        if (_canManage)
          PopupMenuButton<String>(
            icon: Icon(
              _uploadingTaMaterial
                  ? Icons.hourglass_top_rounded
                  : Icons.more_vert_rounded,
              color: InstructorColors.textSecondaryColor(isDark),
            ),
            enabled: !_uploadingTaMaterial,
            onSelected: (value) {
              if (value == 'edit') {
                _openEditLabForm(isDark, lab);
              } else if (value == 'delete') {
                _confirmDeleteLab(lab);
              } else if (value == 'upload') {
                _pickAndUploadTaMaterial(context);
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
                      color: InstructorColors.textPrimaryColor(isDark),
                    ),
                    const SizedBox(width: 10),
                    Text(l10n.taLabEdit),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'upload',
                child: Row(
                  children: [
                    const Icon(Icons.upload_file_rounded, size: 20),
                    const SizedBox(width: 10),
                    Text(l10n.instructorLabUploadMaterial),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(
                      Icons.delete_rounded,
                      size: 20,
                      color: InstructorColors.error,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      l10n.taLabDelete,
                      style: const TextStyle(color: InstructorColors.error),
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
                  color: InstructorColors.primary.withValues(
                    alpha: isDark ? 0.2 : 0.1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  lab.course?.code ?? '${l10n.course} #${lab.courseId}',
                  style: const TextStyle(
                    color: InstructorColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if ((lab.course?.name ?? '').isNotEmpty)
                Text(
                  lab.course!.name,
                  style: TextStyle(
                    color: InstructorColors.textSecondaryColor(isDark),
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
              color: InstructorColors.textPrimaryColor(isDark),
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (lab.description != null) ...[
            const SizedBox(height: 8),
            Text(
              lab.description!,
              style: TextStyle(
                color: InstructorColors.textSecondaryColor(isDark),
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
    AppLocalizations l10n,
    LabModel lab,
    List<LabSubmissionModel> submissions,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 420;
          const spacing = 8.0;
          final itemWidth = isCompact
              ? (constraints.maxWidth - spacing) / 2
              : (constraints.maxWidth - (spacing * 2)) / 3;
          final cards = [
            _buildStatCard(
              isDark,
              _statusLabel(l10n, lab.status),
              l10n.taLabStatus,
              Icons.info_rounded,
              InstructorColors.info,
              width: itemWidth,
            ),
            _buildStatCard(
              isDark,
              '${submissions.length}',
              l10n.taLabSubmissions,
              Icons.assignment_rounded,
              InstructorColors.warning,
              width: itemWidth,
            ),
            _buildStatCard(
              isDark,
              _formatDueDate(context, l10n, lab),
              l10n.taLabDue,
              Icons.calendar_today_rounded,
              InstructorColors.error,
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
                color: InstructorColors.textPrimaryColor(isDark),
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
                color: InstructorColors.textSecondaryColor(isDark),
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
      labelColor: InstructorColors.primary,
      unselectedLabelColor: InstructorColors.textSecondaryColor(isDark),
      indicatorColor: InstructorColors.primary,
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
            InstructorColors.warning,
          ),
          if (lab.weight > 0)
            _buildInfoCard(
              isDark,
              l10n.quizWeight,
              '${lab.weight}%',
              Icons.balance_rounded,
              InstructorColors.info,
            ),
          _buildInfoCard(
            isDark,
            l10n.taLabStatus,
            _statusLabel(l10n, lab.status),
            Icons.flag_rounded,
            InstructorColors.success,
          ),
          _buildInfoCard(
            isDark,
            l10n.dueDate,
            _formatDueDate(context, l10n, lab),
            Icons.calendar_today_rounded,
            InstructorColors.error,
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
                InstructorColors.primary,
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
        color: InstructorColors.textPrimaryColor(isDark),
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
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: InstructorColors.borderColor(isDark).withValues(alpha: 0.5),
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
                    color: InstructorColors.textSecondaryColor(isDark),
                    fontSize: 11,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: InstructorColors.textPrimaryColor(isDark),
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

  Widget _buildSubmissionsTab(
    bool isDark,
    AppLocalizations l10n,
    LabModel lab,
    List<LabSubmissionModel>? submissions,
  ) {
    if (submissions == null) {
      return Center(
        child: CircularProgressIndicator(color: InstructorColors.primary),
      );
    }

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
      itemBuilder: (context, index) =>
          _buildSubmissionCard(isDark, l10n, lab, submissions[index]),
    );
  }

  Widget _buildSubmissionCard(
    bool isDark,
    AppLocalizations l10n,
    LabModel lab,
    LabSubmissionModel submission,
  ) {
    final isGraded =
        submission.submissionStatus == assignment_api.SubmissionStatus.graded;
    final studentName =
        '${submission.user?.firstName ?? ''} ${submission.user?.lastName ?? ''}'
            .trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: InstructorColors.borderColor(isDark).withValues(alpha: 0.5),
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
                    color:
                        (isGraded
                                ? InstructorColors.success
                                : InstructorColors.warning)
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isGraded
                        ? Icons.check_circle_rounded
                        : Icons.pending_rounded,
                    size: 20,
                    color: isGraded
                        ? InstructorColors.success
                        : InstructorColors.warning,
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
                            : '${l10n.student} #${submission.userId}',
                        style: TextStyle(
                          color: InstructorColors.textPrimaryColor(isDark),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            submission.submissionStatus.value.toUpperCase(),
                            style: TextStyle(
                              color: InstructorColors.textSecondaryColor(
                                isDark,
                              ),
                              fontSize: 11,
                            ),
                          ),
                          if (submission.isLate) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: InstructorColors.error.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                l10n.late.toUpperCase(),
                                style: const TextStyle(
                                  color: InstructorColors.error,
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
                if (isGraded && submission.score != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: InstructorColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${submission.score}/${lab.maxScore}',
                      style: const TextStyle(
                        color: InstructorColors.success,
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
                  onPressed: () => _viewSubmission(l10n, lab, submission),
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: Text(l10n.view),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: InstructorColors.primary,
                    side: BorderSide(
                      color: InstructorColors.primary.withValues(alpha: 0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
                final gradeButton = OutlinedButton.icon(
                  onPressed: _canManage
                      ? () => _openGradingPanel(lab, submission)
                      : null,
                  icon: Icon(
                    isGraded ? Icons.edit_rounded : Icons.grading_rounded,
                    size: 16,
                  ),
                  label: Text(isGraded ? l10n.taLabRegrade : l10n.grade),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: InstructorColors.primary,
                    side: BorderSide(
                      color: InstructorColors.primary.withValues(alpha: 0.3),
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

  Future<void> _viewSubmission(
    AppLocalizations l10n,
    LabModel lab,
    LabSubmissionModel submission,
  ) async {
    final studentName = submission.user != null
        ? '${submission.user!.firstName} ${submission.user!.lastName}'.trim()
        : '${l10n.student} #${submission.userId}';

    await SubmissionDetailViewer.showLab(
      context: context,
      submission: submission,
      studentName: studentName.isEmpty
          ? '${l10n.student} #${submission.userId}'
          : studentName,
      labTitle: lab.title,
      maxScore: lab.maxScore,
      onGrade: (score, feedback) async {
        if (!_canManage) {
          return;
        }
        await context.read<LabDetailCubit>().gradeSubmission(
          widget.labId,
          submission.id.toString(),
          score,
          feedback: feedback,
        );
      },
    );
  }

  Future<void> _openGradingPanel(
    LabModel lab,
    LabSubmissionModel submission,
  ) async {
    if (!_canManage) {
      return;
    }

    final cubit = context.read<LabDetailCubit>();
    final currentState = cubit.state;
    final loaded = currentState is LabDetailLoaded ? currentState : null;
    if (loaded == null) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return BlocProvider.value(
          value: cubit,
          child: BlocBuilder<LabDetailCubit, LabDetailState>(
            builder: (context, state) {
              final detailState = state is LabDetailLoaded ? state : loaded;
              return Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
                ),
                decoration: BoxDecoration(
                  color: InstructorColors.cardColor(
                    context.read<ThemeBloc>().state.isDark,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: LabGradingPanel(
                      submission: submission,
                      maxScore: detailState.lab.maxScore,
                      dueDate: detailState.lab.dueDate,
                      isSaving: detailState.isSubmittingGrade,
                      errorMessage: detailState.errorMessage,
                      onSave:
                          (
                            finalScore,
                            feedback,
                            status,
                            latePenaltyPercent,
                          ) async {
                            await cubit.gradeSubmission(
                              widget.labId,
                              submission.id.toString(),
                              finalScore,
                              feedback: feedback,
                              status: status,
                              latePenaltyPercent: latePenaltyPercent,
                            );

                            if (!mounted || !sheetContext.mounted) {
                              return;
                            }

                            final nextState = cubit.state;
                            if (nextState is LabDetailLoaded &&
                                (nextState.errorMessage == null ||
                                    nextState.errorMessage!.isEmpty)) {
                              Navigator.of(sheetContext).pop();
                            }
                          },
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAttendanceTab(
    bool isDark,
    AppLocalizations l10n,
    List<LabAttendanceModel>? attendance,
  ) {
    if (attendance == null) {
      return Center(
        child: CircularProgressIndicator(color: InstructorColors.primary),
      );
    }

    if (attendance.isEmpty) {
      return _buildEmptyTab(
        isDark,
        l10n.taLabNoAttendanceDesc,
        Icons.people_rounded,
      );
    }

    return AttendanceSheet(
      records: attendance,
      canManage: _canManage,
      onMarkAttendance: (userId, status) {
        return context.read<LabDetailCubit>().markAttendance(
          widget.labId,
          <AttendanceData>[
            AttendanceData(userId: userId, attendanceStatus: status),
          ],
        );
      },
    );
  }

  Widget _buildInstructionsTab(
    bool isDark,
    AppLocalizations l10n,
    List<LabInstructionModel>? instructions,
  ) {
    if (instructions == null) {
      return Center(
        child: CircularProgressIndicator(color: InstructorColors.primary),
      );
    }

    final state = context.watch<LabDetailCubit>().state;
    final isUpdating = state is LabInstructionUpdating;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_roleCheckDone && _canManage) ...[
            _InstructorMaterialUploadCard(
              isDark: isDark,
              l10n: l10n,
              isUploading: _uploadingTaMaterial,
              onUpload: _uploadingTaMaterial
                  ? null
                  : () => _pickAndUploadTaMaterial(context),
            ),
            const SizedBox(height: 16),
          ],
          InstructionManager(
            labId: widget.labId,
            instructions: instructions,
            canManage: _roleCheckDone && _canManage,
            isUpdating: isUpdating,
          ),
        ],
      ),
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
              color: InstructorColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: InstructorColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: InstructorColors.textSecondaryColor(isDark),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadTaMaterial(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final result = await FilePicker.platform.pickFiles(withData: false);
    final filePath = result == null || result.files.isEmpty
        ? null
        : result.files.first.path;
    if (filePath == null) {
      return;
    }

    setState(() => _uploadingTaMaterial = true);
    final uploadResult = await widget.labService.uploadTaMaterial(
      widget.labId,
      File(filePath),
    );

    if (!mounted) {
      return;
    }

    setState(() => _uploadingTaMaterial = false);

    if (!uploadResult.isSuccess || uploadResult.data == null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            uploadResult.error?.message ?? l10n.instructorLabUploadFailed,
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          '${l10n.instructorLabUploadSuccess}: ${uploadResult.data!.fileName}',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _confirmDeleteLab(LabModel lab) async {
    final l10n = AppLocalizations.of(context);
    final state = context.read<LabDetailCubit>().state;
    final loaded = state is LabDetailLoaded ? state : null;
    final hasSubmissions =
        (loaded?.submissions ?? const <LabSubmissionModel>[]).isNotEmpty;
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.taLabDelete),
          content: Text(
            hasSubmissions
                ? l10n.taLabDeleteWithSubmissionsConfirm
                : l10n.taLabDeleteConfirm,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: InstructorColors.error,
              ),
              child: Text(
                hasSubmissions ? l10n.taLabDeleteAnyway : l10n.delete,
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final labIdentifier = lab.id.isNotEmpty ? lab.id : lab.labId;
    final result = await widget.labService.delete(labIdentifier);

    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(result.error?.message ?? l10n.failed),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.taLabDeletedSuccess),
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.go('/instructor/labs');
  }

  Future<void> _openEditLabForm(bool _, LabModel lab) async {
    final l10n = AppLocalizations.of(context);
    final courseInfo = lab.course;
    final courseOptions = <TeachingCourseModel>[
      TeachingCourseModel(
        courseId: lab.courseId,
        sectionId: 0,
        course: CourseModel(
          id: lab.courseId,
          departmentId: 0,
          code: courseInfo?.code ?? 'COURSE',
          name: courseInfo?.name ?? '${l10n.course} #${lab.courseId}',
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
        role: 'instructor',
      ),
    ];
    final messenger = ScaffoldMessenger.of(context);

    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute<Map<String, dynamic>>(
        builder: (_) => LabEditorScreen(
          role: LabComposerRole.instructor,
          courses: courseOptions,
          existingLab: lab,
          onSave: (payload) async {
            final result = await widget.labService.update(
              lab.id.isNotEmpty ? lab.id : lab.labId,
              payload,
            );

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

    messenger.showSnackBar(
      SnackBar(
        content: Text(_labSavedMessage(l10n, result['status'])),
        behavior: SnackBarBehavior.floating,
      ),
    );

    final cubit = context.read<LabDetailCubit>();
    await cubit.loadLabDetail(widget.labId);
    await cubit.loadInstructions(widget.labId);
    await cubit.loadSubmissions(widget.labId);
    await cubit.loadAttendance(widget.labId);
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

  String _labSavedMessage(AppLocalizations l10n, Object? rawStatus) {
    final status = rawStatus?.toString().trim().toLowerCase();
    return switch (status) {
      'published' => l10n.taLabsCreatedPublished,
      'draft' => l10n.taLabsCreatedDraft,
      _ => l10n.taLabsCreatedDraft,
    };
  }

  String _statusLabel(AppLocalizations l10n, api.LabStatus status) {
    return switch (status) {
      api.LabStatus.published => l10n.taLabActive,
      api.LabStatus.draft => l10n.draft,
      api.LabStatus.closed => l10n.taLabClosed,
      api.LabStatus.archived => l10n.archived,
      api.LabStatus.unknown => status.value.toUpperCase(),
    };
  }
}

class _InstructorMaterialUploadCard extends StatelessWidget {
  const _InstructorMaterialUploadCard({
    required this.isDark,
    required this.l10n,
    required this.isUploading,
    required this.onUpload,
  });

  final bool isDark;
  final AppLocalizations l10n;
  final bool isUploading;
  final VoidCallback? onUpload;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: InstructorColors.borderColor(isDark).withValues(alpha: 0.65),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: InstructorColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.folder_shared_outlined,
                  color: InstructorColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.instructorLabMaterialTitle,
                  style: TextStyle(
                    color: InstructorColors.textPrimaryColor(isDark),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            l10n.instructorLabMaterialSubtitle,
            style: TextStyle(
              color: InstructorColors.textSecondaryColor(isDark),
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onUpload,
            style: OutlinedButton.styleFrom(
              foregroundColor: InstructorColors.primary,
              side: BorderSide(
                color: InstructorColors.primary.withValues(alpha: 0.3),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: isUploading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.upload_file_rounded),
            label: Text(
              isUploading ? l10n.uploading : l10n.instructorLabUploadMaterial,
            ),
          ),
        ],
      ),
    );
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
