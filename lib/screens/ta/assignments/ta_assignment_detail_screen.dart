import 'package:edu_verse/common/utils/responsive.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/widgets/instructor/assignments/grading_panel.dart';
import 'package:edu_verse/widgets/instructor/assignments/submission_content_viewer.dart';
import 'package:edu_verse/widgets/ta/shared/ta_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../models/assignments/assignment_model.dart';
import '../../../models/assignments/assignment_submission_model.dart';
import '../../../models/core/drive_file_model.dart';
import '../../../models/core/enums/assignment_enums.dart' as api;
import '../../../services/api/assignment_service.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/storage_service.dart';
import '../../instructor/create_assignment_screen.dart';

class TAAssignmentDetailScreen extends StatefulWidget {
  const TAAssignmentDetailScreen({
    super.key,
    required this.assignmentId,
    this.initialAssignment,
    this.assignmentService,
  });

  final int assignmentId;
  final AssignmentModel? initialAssignment;
  final AssignmentService? assignmentService;

  @override
  State<TAAssignmentDetailScreen> createState() =>
      _TAAssignmentDetailScreenState();
}

class _TAAssignmentDetailScreenState extends State<TAAssignmentDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AssignmentService _assignmentService;
  late final TabController _tabController;

  AssignmentModel? _assignment;
  List<AssignmentSubmissionModel> _submissions = const <AssignmentSubmissionModel>[];
  bool _loadingAssignment = true;
  bool _loadingSubmissions = true;
  bool _savingStatus = false;
  bool _deleting = false;
  bool _grading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final coreApiClient = CoreApiClient(storageService: StorageService());
    _assignmentService =
        widget.assignmentService ??
        AssignmentService(coreApiClient: coreApiClient);
    _assignment = widget.initialAssignment;
    _tabController = TabController(length: 4, vsync: this);
    _loadData(refreshAssignment: _assignment == null);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData({bool refreshAssignment = true}) async {
    await Future.wait(<Future<void>>[
      if (refreshAssignment) _loadAssignment(),
      _loadSubmissions(),
    ]);
  }

  Future<void> _loadAssignment() async {
    setState(() {
      _loadingAssignment = true;
      _errorMessage = null;
    });
    final result = await _assignmentService.getById(widget.assignmentId);
    if (!mounted) {
      return;
    }
    if (!result.isSuccess || result.data == null) {
      setState(() {
        _loadingAssignment = false;
        _errorMessage = result.error?.message ?? 'Failed to load assignment';
      });
      return;
    }
    setState(() {
      _assignment = result.data;
      _loadingAssignment = false;
    });
  }

  Future<void> _loadSubmissions() async {
    setState(() => _loadingSubmissions = true);
    final result = await _assignmentService.getSubmissions(widget.assignmentId);
    if (!mounted) {
      return;
    }
    if (!result.isSuccess || result.data == null) {
      setState(() {
        _loadingSubmissions = false;
        _errorMessage =
            result.error?.message ?? 'Failed to load assignment submissions';
      });
      return;
    }
    final items = result.data!.toList()
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    setState(() {
      _submissions = items;
      _loadingSubmissions = false;
    });
  }

  Future<void> _refreshAll() async {
    await _loadData(refreshAssignment: true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        if (_loadingAssignment && _assignment == null) {
          return Scaffold(
            backgroundColor: TAColors.scaffoldColor(isDark),
            body: Center(
              child: CircularProgressIndicator(color: TAColors.primary),
            ),
          );
        }

        if (_assignment == null) {
          return Scaffold(
            backgroundColor: TAColors.scaffoldColor(isDark),
            appBar: AppBar(
              backgroundColor: TAColors.scaffoldColor(isDark),
              leading: IconButton(
                onPressed: () => context.pop(),
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: TAColors.textPrimaryColor(isDark),
                ),
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.assignment_late_rounded,
                      size: 48,
                      color: TAColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage ?? 'Assignment not found.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: TAColors.textSecondaryColor(isDark)),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _refreshAll,
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final assignment = _assignment!;
        return Scaffold(
          backgroundColor: TAColors.scaffoldColor(isDark),
          body: SafeArea(
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return <Widget>[
                  _buildSliverAppBar(
                    isDark,
                    l10n,
                    assignment,
                    innerBoxIsScrolled,
                  ),
                  SliverToBoxAdapter(
                    child: _buildAssignmentHeader(isDark, assignment),
                  ),
                  SliverToBoxAdapter(
                    child: _buildStatsRow(isDark, l10n, assignment),
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
                children: <Widget>[
                  _buildOverviewTab(isDark, l10n, assignment),
                  _buildSubmissionsTab(isDark, l10n, assignment),
                  _buildInstructionsTab(isDark, l10n, assignment),
                  _buildSettingsTab(isDark, l10n, assignment),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  SliverAppBar _buildSliverAppBar(
    bool isDark,
    AppLocalizations l10n,
    AssignmentModel assignment,
    bool innerBoxIsScrolled,
  ) {
    return SliverAppBar(
      backgroundColor: TAColors.scaffoldColor(isDark),
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Icon(
          Icons.arrow_back_rounded,
          color: TAColors.textPrimaryColor(isDark),
        ),
      ),
      title: AnimatedOpacity(
        opacity: innerBoxIsScrolled ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Text(
          assignment.title,
          style: TextStyle(
            color: TAColors.textPrimaryColor(isDark),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      actions: <Widget>[
        IconButton(
          onPressed: () =>
              context.read<ThemeBloc>().add(const ToggleThemeEvent()),
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: TAColors.textSecondaryColor(isDark),
          ),
        ),
        PopupMenuButton<String>(
          icon: Icon(
            _savingStatus || _deleting
                ? Icons.hourglass_top_rounded
                : Icons.more_vert_rounded,
            color: TAColors.textSecondaryColor(isDark),
          ),
          enabled: !_savingStatus && !_deleting,
          onSelected: (value) {
            if (value == 'edit') {
              _openEditScreen(assignment);
            } else if (value == 'delete') {
              _confirmDelete(assignment);
            } else if (value.startsWith('status:')) {
              final raw = value.split(':').last;
              _updateStatus(api.AssignmentStatus.fromString(raw));
            }
          },
          itemBuilder: (context) {
            final nextStatuses = _nextStatuses(assignment.apiStatus);
            return <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.edit_rounded,
                      size: 20,
                      color: TAColors.textPrimaryColor(isDark),
                    ),
                    const SizedBox(width: 10),
                    Text(l10n.edit),
                  ],
                ),
              ),
              ...nextStatuses.map(
                (status) => PopupMenuItem<String>(
                  value: 'status:${status.value}',
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.swap_horiz_rounded, size: 20),
                      const SizedBox(width: 10),
                      Text(_statusLabel(l10n, status)),
                    ],
                  ),
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.delete_rounded,
                      size: 20,
                      color: TAColors.error,
                    ),
                    const SizedBox(width: 10),
                    Text(l10n.delete, style: const TextStyle(color: TAColors.error)),
                  ],
                ),
              ),
            ];
          },
        ),
        const SizedBox(width: 8),
      ],
      floating: true,
      snap: true,
    );
  }

  Widget _buildAssignmentHeader(bool isDark, AssignmentModel assignment) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: TAColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  assignment.course?.code.isNotEmpty == true
                      ? assignment.course!.code
                      : assignment.courseCode,
                  style: const TextStyle(
                    color: TAColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _buildAssignmentStateBadge(isDark, assignment.apiStatus),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            assignment.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: TAColors.textPrimaryColor(isDark),
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          if ((assignment.course?.name ?? assignment.courseName).trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                (assignment.course?.name ?? assignment.courseName).trim(),
                style: TextStyle(
                  color: TAColors.textSecondaryColor(isDark),
                  fontSize: 13,
                ),
              ),
            ),
          if (assignment.description?.trim().isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                assignment.description!.trim(),
                style: TextStyle(
                  color: TAColors.textSecondaryColor(isDark),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(
    bool isDark,
    AppLocalizations l10n,
    AssignmentModel assignment,
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
          final cards = <Widget>[
            _buildStatCard(
              isDark,
              _statusLabel(l10n, assignment.apiStatus),
              l10n.status,
              Icons.info_rounded,
              TAColors.info,
              width: itemWidth,
            ),
            _buildStatCard(
              isDark,
              '${_submissions.length}',
              l10n.assignmentSubmissionsTab,
              Icons.assignment_rounded,
              TAColors.warning,
              width: itemWidth,
            ),
            _buildStatCard(
              isDark,
              _formatDateTime(context, assignment.dueDate),
              l10n.dueDate,
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
          children: <Widget>[
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
      tabs: <Widget>[
        Tab(text: l10n.overview),
        Tab(text: l10n.assignmentSubmissionsTab),
        Tab(text: l10n.instructions),
        Tab(text: l10n.settings),
      ],
    );
  }

  Widget _buildOverviewTab(
    bool isDark,
    AppLocalizations l10n,
    AssignmentModel assignment,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _sectionTitle(isDark, l10n.assignmentDetails),
          const SizedBox(height: 8),
          _buildInfoCard(
            isDark,
            l10n.taLabMaxScore,
            _formatScore(assignment.maxGrade),
            Icons.stars_rounded,
            TAColors.warning,
          ),
          if (assignment.weight > 0)
            _buildInfoCard(
              isDark,
              l10n.quizWeight,
              '${_formatScore(assignment.weight)}%',
              Icons.balance_rounded,
              TAColors.info,
            ),
          _buildInfoCard(
            isDark,
            l10n.status,
            _statusLabel(l10n, assignment.apiStatus),
            Icons.flag_rounded,
            TAColors.success,
          ),
          _buildInfoCard(
            isDark,
            l10n.assignmentSubmissionType,
            _submissionTypeLabel(l10n, assignment.submissionType),
            Icons.upload_file_rounded,
            TAColors.secondary,
          ),
          _buildInfoCard(
            isDark,
            l10n.availableFrom,
            assignment.availableFrom == null
                ? l10n.assignmentNoDueDate
                : _formatDateTime(context, assignment.availableFrom!),
            Icons.schedule_rounded,
            TAColors.teal,
          ),
          _buildInfoCard(
            isDark,
            l10n.dueDate,
            _formatDateTime(context, assignment.dueDate),
            Icons.event_rounded,
            TAColors.error,
          ),
          if (assignment.description?.trim().isNotEmpty == true) ...<Widget>[
            const SizedBox(height: 16),
            _sectionTitle(isDark, l10n.description),
            const SizedBox(height: 8),
            _buildTextBlock(isDark, assignment.description!.trim()),
          ],
        ],
      ),
    );
  }

  Widget _buildSubmissionsTab(
    bool isDark,
    AppLocalizations l10n,
    AssignmentModel assignment,
  ) {
    if (_loadingSubmissions && _submissions.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: TAColors.primary),
      );
    }
    if (_submissions.isEmpty) {
      return _buildEmptyTab(
        isDark,
        l10n.assignmentNoSubmissions,
        Icons.inbox_rounded,
      );
    }
    return RefreshIndicator(
      onRefresh: _loadSubmissions,
      color: TAColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _submissions.length,
        itemBuilder: (context, index) =>
            _buildSubmissionCard(isDark, l10n, assignment, _submissions[index]),
      ),
    );
  }

  Widget _buildSubmissionCard(
    bool isDark,
    AppLocalizations l10n,
    AssignmentModel assignment,
    AssignmentSubmissionModel submission,
  ) {
    final isGraded =
        submission.submissionStatus == api.SubmissionStatus.graded ||
        submission.submissionStatus == api.SubmissionStatus.returned;
    final studentName = _studentName(l10n, submission);

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
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color:
                        (isGraded ? TAColors.success : TAColors.warning)
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isGraded ? Icons.check_circle_rounded : Icons.pending_rounded,
                    size: 20,
                    color: isGraded ? TAColors.success : TAColors.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        studentName,
                        style: TextStyle(
                          color: TAColors.textPrimaryColor(isDark),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: <Widget>[
                          Text(
                            submission.submissionStatus.value.toUpperCase(),
                            style: TextStyle(
                              color: TAColors.textSecondaryColor(isDark),
                              fontSize: 11,
                            ),
                          ),
                          if (submission.isLate)
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
                                style: const TextStyle(
                                  color: TAColors.error,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          Text(
                            _formatDateTime(context, submission.submittedAt),
                            style: TextStyle(
                              color: TAColors.textTertiaryColor(isDark),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (submission.score != null)
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
                      '${_formatScore(submission.score!)} / ${_formatScore(assignment.maxGrade)}',
                      style: const TextStyle(
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
                  onPressed: () => _showSubmissionPreview(submission),
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
                  onPressed: _grading ? null : () => _openGradingSheet(isDark, assignment, submission),
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
                    children: <Widget>[
                      SizedBox(width: double.infinity, child: viewButton),
                      const SizedBox(height: 8),
                      SizedBox(width: double.infinity, child: gradeButton),
                    ],
                  );
                }

                return Row(
                  children: <Widget>[
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

  Widget _buildInstructionsTab(
    bool isDark,
    AppLocalizations l10n,
    AssignmentModel assignment,
  ) {
    final files = assignment.instructionFiles ?? const <DriveFileModel>[];
    final hasInstructions = assignment.instructionsText?.trim().isNotEmpty == true;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _sectionTitle(isDark, l10n.instructions),
          const SizedBox(height: 8),
          if (hasInstructions)
            _buildMarkdownBlock(isDark, assignment.instructionsText!.trim())
          else
            _buildEmptyCard(isDark, l10n.assignmentNoInstructions),
          const SizedBox(height: 16),
          _sectionTitle(isDark, l10n.assignmentInstructionFiles),
          const SizedBox(height: 8),
          if (files.isEmpty)
            _buildEmptyCard(isDark, l10n.assignmentNoInstructionFiles)
          else
            ...files.map((file) => _buildInstructionFileCard(isDark, l10n, file)),
        ],
      ),
    );
  }

  Widget _buildSettingsTab(
    bool isDark,
    AppLocalizations l10n,
    AssignmentModel assignment,
  ) {
    final allowedTypes = assignment.allowedFileTypes
            ?.where((item) => item.trim().isNotEmpty)
            .join(', ') ??
        '';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _sectionTitle(isDark, l10n.settings),
          const SizedBox(height: 8),
          _buildInfoCard(
            isDark,
            l10n.assignmentSubmissionType,
            _submissionTypeLabel(l10n, assignment.submissionType),
            Icons.cloud_upload_rounded,
            TAColors.primary,
          ),
          _buildInfoCard(
            isDark,
            l10n.assignmentLatePenalty,
            '${_formatScore(assignment.latePenaltyPercent)}%',
            Icons.timer_off_rounded,
            TAColors.orange,
          ),
          _buildInfoCard(
            isDark,
            l10n.assignmentMaxFileSize,
            assignment.maxFileSizeMb > 0
                ? '${assignment.maxFileSizeMb} MB'
                : l10n.assignmentNotConfigured,
            Icons.folder_zip_rounded,
            TAColors.teal,
          ),
          _buildInfoCard(
            isDark,
            l10n.assignmentAllowedFileTypes,
            allowedTypes.isEmpty ? l10n.assignmentNotConfigured : allowedTypes,
            Icons.file_copy_rounded,
            TAColors.secondary,
          ),
          _buildInfoCard(
            isDark,
            l10n.availableFrom,
            assignment.availableFrom == null
                ? l10n.assignmentNoDueDate
                : _formatDateTime(context, assignment.availableFrom!),
            Icons.schedule_rounded,
            TAColors.info,
          ),
          _buildInfoCard(
            isDark,
            l10n.dueDate,
            _formatDateTime(context, assignment.dueDate),
            Icons.event_available_rounded,
            TAColors.error,
          ),
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
        children: <Widget>[
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
              children: <Widget>[
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
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextBlock(bool isDark, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: TAColors.textPrimaryColor(isDark),
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildMarkdownBlock(bool isDark, String markdown) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
        ),
      ),
      child: MarkdownBody(data: markdown),
    );
  }

  Widget _buildInstructionFileCard(
    bool isDark,
    AppLocalizations l10n,
    DriveFileModel file,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: TAColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.attach_file_rounded,
                  color: TAColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  file.fileName,
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              OutlinedButton.icon(
                onPressed: () => _openUrl(file.webViewLink),
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: Text(l10n.assignmentOpenFile),
              ),
              OutlinedButton.icon(
                onPressed: () => _openUrl(file.downloadUrl),
                icon: const Icon(Icons.download_rounded, size: 16),
                label: Text(l10n.assignmentDownloadFile),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTab(bool isDark, String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: TAColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: TAColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: TAColors.textSecondaryColor(isDark)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard(bool isDark, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        message,
        style: TextStyle(color: TAColors.textSecondaryColor(isDark)),
      ),
    );
  }

  Widget _buildAssignmentStateBadge(bool isDark, api.AssignmentStatus status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _statusLabel(AppLocalizations.of(context), status),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Future<void> _openEditScreen(AssignmentModel assignment) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => CreateAssignmentScreen(
          assignment: assignment,
          assignmentId: assignment.assignmentId,
          preferredCourseId: assignment.courseId,
        ),
      ),
    );

    if (result == true && mounted) {
      await _refreshAll();
    }
  }

  Future<void> _confirmDelete(AssignmentModel assignment) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.assignmentDeleteTitle),
          content: Text(l10n.assignmentDeleteConfirm),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() => _deleting = true);
    final result = await _assignmentService.delete(assignment.assignmentId);
    if (!mounted) {
      return;
    }
    setState(() => _deleting = false);

    if (!result.isSuccess) {
      _showSnack(result.error?.message ?? 'Failed to delete assignment');
      return;
    }

    _showSnack(l10n.assignmentDeletedSuccess);
    context.pop(true);
  }

  Future<void> _updateStatus(api.AssignmentStatus status) async {
    setState(() => _savingStatus = true);
    final result = await _assignmentService.updateStatus(widget.assignmentId, status);
    if (!mounted) {
      return;
    }
    setState(() => _savingStatus = false);

    if (!result.isSuccess || result.data == null) {
      _showSnack(result.error?.message ?? 'Failed to update assignment status');
      return;
    }

    setState(() => _assignment = result.data);
    _showSnack(_statusUpdateMessage(AppLocalizations.of(context), status));
  }

  Future<void> _showSubmissionPreview(AssignmentSubmissionModel submission) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = context.read<ThemeBloc>().state.isDark;
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.86,
          ),
          decoration: BoxDecoration(
            color: TAColors.cardColor(isDark),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: TAColors.borderColor(isDark),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SubmissionContentViewer(submission: submission),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openGradingSheet(
    bool isDark,
    AssignmentModel assignment,
    AssignmentSubmissionModel submission,
  ) {
    final daysLate = assignment.dueDate.isBefore(submission.submittedAt)
        ? submission.submittedAt.difference(assignment.dueDate).inDays == 0
              ? 1
              : submission.submittedAt.difference(assignment.dueDate).inDays
        : 0;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          decoration: BoxDecoration(
            color: TAColors.cardColor(isDark),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GradingPanel(
              maxScore: assignment.maxGrade,
              initialScore: submission.score,
              initialFeedback: submission.feedback,
              latePenaltyPercent: assignment.latePenaltyPercent,
              daysLate: submission.isLate ? daysLate : 0,
              isSaving: _grading,
              onSave: (score, feedback) async {
                Navigator.of(ctx).pop();
                await _saveGrade(submission, score, feedback);
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveGrade(
    AssignmentSubmissionModel submission,
    double score,
    String? feedback,
  ) async {
    setState(() => _grading = true);
    final result = await _assignmentService.gradeSubmission(
      widget.assignmentId,
      submission.id,
      score,
      feedback: feedback,
    );
    if (!mounted) {
      return;
    }
    setState(() => _grading = false);

    if (!result.isSuccess) {
      _showSnack(result.error?.message ?? 'Failed to save grade');
      return;
    }

    _showSnack(AppLocalizations.of(context).gradeSubmitted);
    await _loadSubmissions();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static List<api.AssignmentStatus> _nextStatuses(api.AssignmentStatus current) {
    switch (current) {
      case api.AssignmentStatus.draft:
        return const <api.AssignmentStatus>[api.AssignmentStatus.published];
      case api.AssignmentStatus.published:
        return const <api.AssignmentStatus>[
          api.AssignmentStatus.closed,
          api.AssignmentStatus.archived,
        ];
      case api.AssignmentStatus.closed:
        return const <api.AssignmentStatus>[
          api.AssignmentStatus.archived,
          api.AssignmentStatus.draft,
        ];
      case api.AssignmentStatus.archived:
        return const <api.AssignmentStatus>[api.AssignmentStatus.draft];
      case api.AssignmentStatus.unknown:
        return const <api.AssignmentStatus>[];
    }
  }

  static Color _statusColor(api.AssignmentStatus status) {
    switch (status) {
      case api.AssignmentStatus.draft:
        return TAColors.warning;
      case api.AssignmentStatus.published:
        return TAColors.success;
      case api.AssignmentStatus.closed:
        return TAColors.info;
      case api.AssignmentStatus.archived:
        return TAColors.pink;
      case api.AssignmentStatus.unknown:
        return TAColors.textSecondary;
    }
  }

  static String _statusLabel(
    AppLocalizations l10n,
    api.AssignmentStatus status,
  ) {
    switch (status) {
      case api.AssignmentStatus.draft:
        return l10n.draft;
      case api.AssignmentStatus.published:
        return l10n.assignmentStatusPublished;
      case api.AssignmentStatus.closed:
        return l10n.assignmentStatusClosed;
      case api.AssignmentStatus.archived:
        return l10n.archived;
      case api.AssignmentStatus.unknown:
        return l10n.unknown;
    }
  }

  static String _submissionTypeLabel(
    AppLocalizations l10n,
    api.SubmissionType type,
  ) {
    switch (type) {
      case api.SubmissionType.file:
        return l10n.assignmentSubmissionTypeFile;
      case api.SubmissionType.text:
        return l10n.assignmentSubmissionTypeText;
      case api.SubmissionType.link:
        return l10n.assignmentSubmissionTypeLink;
      case api.SubmissionType.multiple:
        return l10n.assignmentSubmissionTypeMultiple;
      case api.SubmissionType.unknown:
        return l10n.unknown;
    }
  }

  String _studentName(
    AppLocalizations l10n,
    AssignmentSubmissionModel submission,
  ) {
    final first = submission.user?.firstName.trim() ?? '';
    final last = submission.user?.lastName.trim() ?? '';
    final fullName = '$first $last'.trim();
    if (fullName.isNotEmpty) {
      return fullName;
    }
    return '${l10n.student} #${submission.userId}';
  }

  String _formatDateTime(BuildContext context, DateTime value) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat.yMMMd(locale).add_jm().format(value.toLocal());
  }

  String _formatScore(double value) {
    return value == value.roundToDouble()
        ? value.round().toString()
        : value.toStringAsFixed(1);
  }

  String _statusUpdateMessage(
    AppLocalizations l10n,
    api.AssignmentStatus status,
  ) {
    switch (status) {
      case api.AssignmentStatus.published:
        return l10n.assignmentPublishedSuccess;
      case api.AssignmentStatus.closed:
        return l10n.assignmentClosedSuccess;
      case api.AssignmentStatus.archived:
        return l10n.assignmentArchivedSuccess;
      case api.AssignmentStatus.draft:
        return l10n.assignmentMovedToDraft;
      case api.AssignmentStatus.unknown:
        return l10n.assignmentStatusUpdated;
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  const _SliverTabBarDelegate({
    required this.tabBar,
    required this.backgroundColor,
  });

  final TabBar tabBar;
  final Color backgroundColor;

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
    return Container(
      color: backgroundColor,
      alignment: Alignment.centerLeft,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _SliverTabBarDelegate oldDelegate) {
    return oldDelegate.tabBar != tabBar ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
