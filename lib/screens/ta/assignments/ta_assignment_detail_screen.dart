import 'package:edu_verse/common/utils/responsive.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/widgets/student/shared/drive_file_preview_screen.dart';
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
import '../../../screens/instructor/create_assignment_screen.dart';
import '../../../services/api/assignment_service.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/storage_service.dart';
import '../../../widgets/instructor/assignments/grading_panel.dart';
import '../../../widgets/ta/shared/ta_colors.dart';

class InstructorColors {
  InstructorColors._();

  static const Color primary = TAColors.primary;
  static const Color primaryLight = TAColors.primaryLight;
  static const Color primaryLighter = TAColors.primaryLighter;
  static const Color primaryDark = TAColors.primaryDark;
  static const Color primarySurface = TAColors.primarySurface;
  static const Color success = TAColors.success;
  static const Color successLight = TAColors.successLight;
  static const Color warning = TAColors.warning;
  static const Color warningLight = TAColors.warningLight;
  static const Color error = TAColors.error;
  static const Color errorLight = TAColors.errorLight;
  static const Color info = TAColors.info;
  static const Color infoLight = TAColors.infoLight;
  static const Color accent = TAColors.accent;
  static const Color accentLight = TAColors.primarySurface;
  static const Color teal = TAColors.teal;
  static const Color tealLight = TAColors.tealLight;
  static const Color cyan = TAColors.cyan;
  static const Color cyanLight = TAColors.cyanLight;
  static const Color orange = TAColors.orange;
  static const Color orangeLight = TAColors.orangeLight;
  static const Color pink = TAColors.pink;
  static const Color pinkLight = TAColors.pinkLight;
  static const Color textPrimary = TAColors.textPrimary;
  static const Color textSecondary = TAColors.textSecondary;
  static const Color textTertiary = TAColors.textTertiary;
  static const Color border = TAColors.border;
  static const Color divider = TAColors.divider;
  static const Color surface = TAColors.surface;
  static const Color card = TAColors.card;
  static const LinearGradient headerGradient = TAColors.headerGradient;
  static const LinearGradient darkHeaderGradient = TAColors.darkHeaderGradient;

  static Color background(bool isDark) => TAColors.background(isDark);
  static Color cardColor(bool isDark) => TAColors.cardColor(isDark);
  static Color surfaceColor(bool isDark) => TAColors.surfaceColor(isDark);
  static Color borderColor(bool isDark) => TAColors.borderColor(isDark);
  static Color textPrimaryColor(bool isDark) =>
      TAColors.textPrimaryColor(isDark);
  static Color textSecondaryColor(bool isDark) =>
      TAColors.textSecondaryColor(isDark);
  static Color textTertiaryColor(bool isDark) =>
      TAColors.textTertiaryColor(isDark);
}

class TAAssignmentDetailScreen extends StatefulWidget {
  const TAAssignmentDetailScreen({
    super.key,
    required this.assignmentId,
    this.initialAssignment,
    this.initialTab = 0,
    this.assignmentService,
  });

  final int assignmentId;
  final AssignmentModel? initialAssignment;
  final int initialTab;
  final AssignmentService? assignmentService;

  @override
  State<TAAssignmentDetailScreen> createState() =>
      _TAAssignmentDetailScreenState();
}

enum _SubmissionFilter { all, pending, graded, late }

class _TAAssignmentDetailScreenState extends State<TAAssignmentDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AssignmentService _assignmentService;
  late final TabController _tabController;
  final ScrollController _outerScrollController = ScrollController();
  late int _currentTabIndex;

  AssignmentModel? _assignment;
  List<AssignmentSubmissionModel> _submissions =
      const <AssignmentSubmissionModel>[];
  bool _loadingAssignment = true;
  bool _loadingSubmissions = true;
  bool _updatingStatus = false;
  bool _deleting = false;
  String _searchQuery = '';
  _SubmissionFilter _submissionFilter = _SubmissionFilter.all;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final coreApiClient = CoreApiClient(storageService: StorageService());
    _assignmentService =
        widget.assignmentService ??
        AssignmentService(coreApiClient: coreApiClient);
    _assignment = widget.initialAssignment;
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 3),
    );
    _currentTabIndex = _tabController.index;
    _tabController.addListener(_handleTabChanged);
    _loadData(refreshAssignment: _assignment == null);
  }

  @override
  void dispose() {
    _outerScrollController.dispose();
    _tabController.removeListener(_handleTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChanged() {
    if (!mounted || _currentTabIndex == _tabController.index) {
      return;
    }
    setState(() {
      _currentTabIndex = _tabController.index;
    });
  }

  Future<void> _loadData({bool refreshAssignment = true}) async {
    await Future.wait<void>(<Future<void>>[
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
    setState(() {
      _loadingSubmissions = true;
    });

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
            backgroundColor: InstructorColors.background(isDark),
            body: SafeArea(child: _AssignmentDetailLoadingView(isDark: isDark)),
          );
        }

        if (_assignment == null) {
          return Scaffold(
            backgroundColor: InstructorColors.background(isDark),
            body: SafeArea(child: _buildErrorState(context, isDark, l10n)),
          );
        }

        final assignment = _assignment!;
        return Scaffold(
          backgroundColor: InstructorColors.background(isDark),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _currentTabRefreshAction,
              child: CustomScrollView(
                controller: _outerScrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: <Widget>[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Column(
                        children: <Widget>[
                          _buildTopBar(context, isDark, l10n, assignment),
                          const SizedBox(height: 10),
                          _buildHeroHeader(context, isDark, l10n, assignment),
                        ],
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _AssignmentDetailTabsHeaderDelegate(
                      height: 86,
                      child: Container(
                        color: InstructorColors.background(isDark),
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        child: _buildTabStrip(context, isDark, l10n),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: KeyedSubtree(
                        key: ValueKey<int>(_currentTabIndex),
                        child: _buildCurrentTabContent(
                          context,
                          isDark,
                          l10n,
                          assignment,
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _currentTabRefreshAction() {
    switch (_currentTabIndex) {
      case 1:
        return _loadSubmissions();
      case 0:
      case 2:
      case 3:
      default:
        return _refreshAll();
    }
  }

  Widget _buildCurrentTabContent(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    AssignmentModel assignment,
  ) {
    switch (_currentTabIndex) {
      case 0:
        return _buildOverviewTab(context, isDark, l10n, assignment);
      case 1:
        return _buildSubmissionsTab(context, isDark, l10n, assignment);
      case 2:
        return _buildInstructionsTab(context, isDark, l10n, assignment);
      case 3:
      default:
        return _buildSettingsTab(context, isDark, l10n, assignment);
    }
  }

  Widget _buildTopBar(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    AssignmentModel assignment,
  ) {
    return Row(
      children: <Widget>[
        _buildIconShell(
          icon: Icons.arrow_back_ios_new_rounded,
          isDark: isDark,
          onTap: () => context.pop(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            assignment.course?.name.trim().isNotEmpty == true
                ? assignment.course!.name
                : assignment.courseName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: InstructorColors.textPrimaryColor(isDark),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 12),
        _buildThemeToggle(isDark),
        const SizedBox(width: 10),
        _buildActionMenu(isDark, l10n, assignment),
      ],
    );
  }

  Widget _buildThemeToggle(bool isDark) {
    return _buildIconShell(
      icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
      isDark: isDark,
      onTap: () => context.read<ThemeBloc>().add(const ToggleThemeEvent()),
    );
  }

  Widget _buildActionMenu(
    bool isDark,
    AppLocalizations l10n,
    AssignmentModel assignment,
  ) {
    final nextStatuses = _nextStatuses(assignment.apiStatus);
    return PopupMenuButton<String>(
      enabled: !_updatingStatus && !_deleting,
      tooltip: '',
      color: InstructorColors.cardColor(isDark),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      icon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: InstructorColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: InstructorColors.borderColor(isDark).withValues(alpha: 0.74),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.14 : 0.05),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          _updatingStatus || _deleting
              ? Icons.hourglass_top_rounded
              : Icons.more_horiz_rounded,
          color: InstructorColors.textPrimaryColor(isDark),
        ),
      ),
      onSelected: (value) {
        if (value == 'edit') {
          _openEditScreen(assignment);
        } else if (value == 'delete') {
          _confirmDelete(assignment);
        } else if (value.startsWith('status:')) {
          _updateStatus(api.AssignmentStatus.fromString(value.split(':').last));
        }
      },
      itemBuilder: (context) {
        return <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: 'edit',
            child: Row(
              children: <Widget>[
                const Icon(Icons.edit_rounded, size: 18),
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
                  const Icon(Icons.swap_horiz_rounded, size: 18),
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
                  size: 18,
                  color: InstructorColors.error,
                ),
                const SizedBox(width: 10),
                Text(
                  l10n.delete,
                  style: const TextStyle(color: InstructorColors.error),
                ),
              ],
            ),
          ),
        ];
      },
    );
  }

  Widget _buildIconShell({
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: InstructorColors.cardColor(isDark),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: InstructorColors.borderColor(
                isDark,
              ).withValues(alpha: 0.74),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.14 : 0.05),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(icon, color: InstructorColors.textPrimaryColor(isDark)),
        ),
      ),
    );
  }

  Widget _buildHeroHeader(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    AssignmentModel assignment,
  ) {
    final r = context.responsive;
    final stats = <({IconData icon, String label, String value, Color color})>[
      (
        icon: Icons.flag_rounded,
        label: l10n.status,
        value: _statusLabel(l10n, assignment.apiStatus),
        color: _statusColor(assignment.apiStatus),
      ),
      (
        icon: Icons.assignment_turned_in_rounded,
        label: l10n.assignmentSubmissionsTab,
        value: _submissions.length.toString(),
        color: InstructorColors.accent,
      ),
      (
        icon: Icons.stars_rounded,
        label: l10n.instructorAssignmentMaxScore,
        value: _formatScore(assignment.maxGrade),
        color: InstructorColors.warning,
      ),
      (
        icon: Icons.schedule_rounded,
        label: l10n.dueDate,
        value: _compactDate(context, assignment.dueDate),
        color: InstructorColors.teal,
      ),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: isDark
            ? InstructorColors.darkHeaderGradient
            : InstructorColors.headerGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: InstructorColors.primary.withValues(
              alpha: isDark ? 0.26 : 0.18,
            ),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -26,
              right: -8,
              child: Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -42,
              left: -18,
              child: Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.assignment_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              assignment.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: r.isMobile
                                    ? r.fontSize20
                                    : r.fontSize24,
                                fontWeight: FontWeight.w800,
                                height: 1.12,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              l10n.instructorAssignmentDetailHeroSubtitle,
                              maxLines: r.isMobile ? 2 : 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.84),
                                fontSize: r.fontSize12,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      _buildHeroChip(
                        icon: Icons.menu_book_rounded,
                        label: assignment.course?.code.isNotEmpty == true
                            ? assignment.course!.code
                            : assignment.courseCode,
                      ),
                      _buildHeroChip(
                        icon: Icons.people_alt_rounded,
                        label: _submissionTypeLabel(
                          l10n,
                          assignment.submissionType,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 900
                          ? 4
                          : constraints.maxWidth >= 600
                          ? 4
                          : 2;
                      final spacing = 8.0;
                      final itemWidth =
                          (constraints.maxWidth - (spacing * (columns - 1))) /
                          columns;

                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: stats
                            .map(
                              (stat) => _buildHeroStatCard(
                                width: itemWidth,
                                icon: stat.icon,
                                label: stat.label,
                                value: stat.value,
                                color: stat.color,
                              ),
                            )
                            .toList(growable: false),
                      );
                    },
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

  Widget _buildHeroStatCard({
    required double width,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabStrip(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final r = context.responsive;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: InstructorColors.borderColor(isDark).withValues(alpha: 0.7),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: InstructorColors.primary,
          borderRadius: BorderRadius.circular(999),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        padding: EdgeInsets.zero,
        labelPadding: EdgeInsets.symmetric(horizontal: r.p14),
        labelColor: Colors.white,
        unselectedLabelColor: InstructorColors.textPrimaryColor(isDark),
        labelStyle: TextStyle(
          fontSize: r.fontSize14,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: r.fontSize14,
          fontWeight: FontWeight.w600,
        ),
        tabs: <Widget>[
          _buildTab(
            icon: Icons.dashboard_customize_rounded,
            text: l10n.overview,
          ),
          _buildTab(
            icon: Icons.assignment_turned_in_rounded,
            text: l10n.assignmentSubmissionsTab,
          ),
          _buildTab(icon: Icons.menu_book_rounded, text: l10n.instructions),
          _buildTab(icon: Icons.tune_rounded, text: l10n.settings),
        ],
      ),
    );
  }

  Widget _buildTab({required IconData icon, required String text}) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    AssignmentModel assignment,
  ) {
    final rows = <({IconData icon, String title, String value, Color color})>[
      (
        icon: Icons.school_rounded,
        title: l10n.course,
        value:
            '${assignment.course?.name ?? assignment.courseName} (${assignment.course?.code.isNotEmpty == true ? assignment.course!.code : assignment.courseCode})',
        color: InstructorColors.primary,
      ),
      (
        icon: Icons.flag_rounded,
        title: l10n.status,
        value: _statusLabel(l10n, assignment.apiStatus),
        color: _statusColor(assignment.apiStatus),
      ),
      (
        icon: Icons.cloud_upload_rounded,
        title: l10n.assignmentSubmissionType,
        value: _submissionTypeLabel(l10n, assignment.submissionType),
        color: InstructorColors.accent,
      ),
      (
        icon: Icons.schedule_rounded,
        title: l10n.availableFrom,
        value: assignment.availableFrom == null
            ? l10n.assignmentNoDueDate
            : _formatDateTime(context, assignment.availableFrom!),
        color: InstructorColors.teal,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: <Widget>[
          _buildSectionCard(
            context,
            isDark,
            title: l10n.instructorAssignmentDetailSnapshotTitle,
            subtitle: l10n.instructorAssignmentDetailSnapshotSubtitle,
            icon: Icons.insights_rounded,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 720 ? 2 : 1;
                const spacing = 12.0;
                final itemWidth =
                    (constraints.maxWidth - (spacing * (columns - 1))) /
                    columns;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: rows
                      .map(
                        (row) => _buildInfoTile(
                          isDark: isDark,
                          width: itemWidth,
                          icon: row.icon,
                          title: row.title,
                          value: row.value,
                          color: row.color,
                        ),
                      )
                      .toList(growable: false),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            context,
            isDark,
            title: l10n.instructorAssignmentDetailBriefTitle,
            subtitle: l10n.instructorAssignmentDetailBriefSubtitle,
            icon: Icons.notes_rounded,
            child: Text(
              assignment.description?.trim().isNotEmpty == true
                  ? assignment.description!.trim()
                  : l10n.instructorAssignmentDetailBriefEmpty,
              style: TextStyle(
                color: InstructorColors.textSecondaryColor(isDark),
                fontSize: 14,
                height: 1.58,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            context,
            isDark,
            title: l10n.instructorAssignmentDetailWorkflowTitle,
            subtitle: l10n.instructorAssignmentDetailWorkflowSubtitle,
            icon: Icons.route_rounded,
            child: Column(
              children: <Widget>[
                _buildPillRow(
                  isDark: isDark,
                  icon: Icons.event_available_rounded,
                  label: l10n.dueDate,
                  value: _formatDateTime(context, assignment.dueDate),
                  color: InstructorColors.error,
                ),
                const SizedBox(height: 12),
                _buildPillRow(
                  isDark: isDark,
                  icon: Icons.rule_rounded,
                  label: l10n.assignmentLatePenalty,
                  value: assignment.lateSubmissionAllowed
                      ? '${_formatScore(assignment.latePenaltyPercent)}%'
                      : l10n.assignmentStatusClosed,
                  color: assignment.lateSubmissionAllowed
                      ? InstructorColors.warning
                      : InstructorColors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionsTab(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    AssignmentModel assignment,
  ) {
    final filtered = _filteredSubmissions(l10n);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: <Widget>[
          _buildSectionCard(
            context,
            isDark,
            title: l10n.instructorAssignmentDetailSubmissionsTitle,
            subtitle: l10n.instructorAssignmentDetailSubmissionsSubtitle,
            icon: Icons.fact_check_rounded,
            child: Column(
              children: <Widget>[
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: l10n.instructorAssignmentDetailSearchStudents,
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: isDark
                        ? InstructorColors.surfaceColor(isDark)
                        : const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                        color: InstructorColors.borderColor(
                          isDark,
                        ).withValues(alpha: 0.7),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                        color: InstructorColors.borderColor(
                          isDark,
                        ).withValues(alpha: 0.7),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(
                        color: InstructorColors.primary,
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: <Widget>[
                      _buildFilterChip(
                        isDark: isDark,
                        label: l10n.all,
                        count: _submissions.length,
                        selected: _submissionFilter == _SubmissionFilter.all,
                        onTap: () => setState(
                          () => _submissionFilter = _SubmissionFilter.all,
                        ),
                      ),
                      _buildFilterChip(
                        isDark: isDark,
                        label: l10n.pending,
                        count: _submissions
                            .where((item) => _isPendingSubmission(item))
                            .length,
                        selected:
                            _submissionFilter == _SubmissionFilter.pending,
                        onTap: () => setState(
                          () => _submissionFilter = _SubmissionFilter.pending,
                        ),
                      ),
                      _buildFilterChip(
                        isDark: isDark,
                        label: l10n.graded,
                        count: _submissions
                            .where((item) => _isGradedSubmission(item))
                            .length,
                        selected: _submissionFilter == _SubmissionFilter.graded,
                        onTap: () => setState(
                          () => _submissionFilter = _SubmissionFilter.graded,
                        ),
                      ),
                      _buildFilterChip(
                        isDark: isDark,
                        label: l10n.late,
                        count: _submissions.where((item) => item.isLate).length,
                        selected: _submissionFilter == _SubmissionFilter.late,
                        onTap: () => setState(
                          () => _submissionFilter = _SubmissionFilter.late,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_loadingSubmissions && _submissions.isEmpty)
            ...List<Widget>.generate(
              3,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildSubmissionSkeletonCard(isDark),
              ),
            )
          else if (filtered.isEmpty)
            _buildEmptyCourseCard(
              isDark,
              title: l10n.instructorAssignmentDetailNoSubmissionsTitle,
              subtitle: l10n.instructorAssignmentDetailNoSubmissionsSubtitle,
              icon: Icons.inbox_outlined,
            )
          else
            ...filtered.map(
              (submission) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildSubmissionCard(
                  context,
                  isDark,
                  l10n,
                  assignment,
                  submission,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInstructionsTab(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    AssignmentModel assignment,
  ) {
    final files = assignment.instructionFiles ?? const <DriveFileModel>[];
    final hasInstructions =
        assignment.instructionsText?.trim().isNotEmpty == true;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: <Widget>[
          _buildSectionCard(
            context,
            isDark,
            title: l10n.instructions,
            subtitle: l10n.instructorAssignmentResourcesSectionSubtitle,
            icon: Icons.menu_book_rounded,
            child: hasInstructions
                ? MarkdownBody(data: assignment.instructionsText!.trim())
                : _buildInlineEmptyMessage(
                    isDark,
                    l10n.assignmentNoInstructions,
                  ),
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            context,
            isDark,
            title: l10n.assignmentInstructionFiles,
            subtitle: l10n.instructorAssignmentResourcesHint,
            icon: Icons.attach_file_rounded,
            child: files.isEmpty
                ? _buildInlineEmptyMessage(
                    isDark,
                    l10n.assignmentNoInstructionFiles,
                  )
                : Column(
                    children: files
                        .map(
                          (file) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildDriveFileCard(
                              context,
                              isDark,
                              l10n,
                              file,
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    AssignmentModel assignment,
  ) {
    final rows = <({IconData icon, String title, String value, Color color})>[
      (
        icon: Icons.cloud_upload_rounded,
        title: l10n.assignmentSubmissionType,
        value: _submissionTypeLabel(l10n, assignment.submissionType),
        color: InstructorColors.primary,
      ),
      (
        icon: Icons.timer_off_rounded,
        title: l10n.assignmentLatePenalty,
        value: assignment.lateSubmissionAllowed
            ? '${_formatScore(assignment.latePenaltyPercent)}%'
            : l10n.assignmentStatusClosed,
        color: InstructorColors.warning,
      ),
      (
        icon: Icons.folder_zip_rounded,
        title: l10n.assignmentMaxFileSize,
        value: assignment.maxFileSizeMb > 0
            ? '${assignment.maxFileSizeMb} MB'
            : l10n.assignmentNotConfigured,
        color: InstructorColors.teal,
      ),
      (
        icon: Icons.file_copy_rounded,
        title: l10n.assignmentAllowedFileTypes,
        value:
            (assignment.allowedFileTypes == null ||
                assignment.allowedFileTypes!.isEmpty)
            ? l10n.assignmentNotConfigured
            : assignment.allowedFileTypes!.join(', '),
        color: InstructorColors.accent,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: <Widget>[
          _buildSectionCard(
            context,
            isDark,
            title: l10n.settings,
            subtitle: l10n.instructorAssignmentSettingsSectionSubtitle,
            icon: Icons.tune_rounded,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 720 ? 2 : 1;
                const spacing = 12.0;
                final itemWidth =
                    (constraints.maxWidth - (spacing * (columns - 1))) /
                    columns;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: rows
                      .map(
                        (row) => _buildInfoTile(
                          isDark: isDark,
                          width: itemWidth,
                          icon: row.icon,
                          title: row.title,
                          value: row.value,
                          color: row.color,
                        ),
                      )
                      .toList(growable: false),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            context,
            isDark,
            title: l10n.instructorAssignmentScheduleSection,
            subtitle: l10n.instructorAssignmentScheduleSectionSubtitle,
            icon: Icons.calendar_month_rounded,
            child: Column(
              children: <Widget>[
                _buildPillRow(
                  isDark: isDark,
                  icon: Icons.event_available_rounded,
                  label: l10n.availableFrom,
                  value: assignment.availableFrom == null
                      ? l10n.assignmentNoDueDate
                      : _formatDateTime(context, assignment.availableFrom!),
                  color: InstructorColors.info,
                ),
                const SizedBox(height: 12),
                _buildPillRow(
                  isDark: isDark,
                  icon: Icons.event_busy_rounded,
                  label: l10n.dueDate,
                  value: _formatDateTime(context, assignment.dueDate),
                  color: InstructorColors.error,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    bool isDark, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    final r = context.responsive;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: InstructorColors.borderColor(isDark).withValues(alpha: 0.7),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: InstructorColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: InstructorColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                        color: InstructorColors.textPrimaryColor(isDark),
                        fontSize: r.fontSize18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: InstructorColors.textSecondaryColor(isDark),
                        fontSize: r.fontSize13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required bool isDark,
    required double width,
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: InstructorColors.borderColor(isDark).withValues(alpha: 0.58),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    color: InstructorColors.textSecondaryColor(isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: InstructorColors.textPrimaryColor(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillRow({
    required bool isDark,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: InstructorColors.borderColor(isDark).withValues(alpha: 0.58),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: TextStyle(
                    color: InstructorColors.textSecondaryColor(isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: InstructorColors.textPrimaryColor(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required bool isDark,
    required String label,
    required int count,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final color = selected
        ? InstructorColors.primary
        : InstructorColors.textSecondaryColor(isDark);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? InstructorColors.primary.withValues(alpha: 0.12)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.03)
                    : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? InstructorColors.primary.withValues(alpha: 0.25)
                : InstructorColors.borderColor(isDark).withValues(alpha: 0.58),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: selected
                    ? InstructorColors.primary
                    : color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: selected ? Colors.white : color,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionCard(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    AssignmentModel assignment,
    AssignmentSubmissionModel submission,
  ) {
    final studentName = _studentName(l10n, submission);
    final initials = _initials(studentName);
    final statusColor = _submissionStatusColor(submission);
    final isGraded = _isGradedSubmission(submission);
    final cardGradient = LinearGradient(
      colors: <Color>[
        InstructorColors.primary.withValues(alpha: isDark ? 0.18 : 0.08),
        InstructorColors.teal.withValues(alpha: isDark ? 0.12 : 0.05),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: InstructorColors.borderColor(isDark).withValues(alpha: 0.68),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: cardGradient,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: InstructorColors.primary.withValues(alpha: 0.25),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: InstructorColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        studentName,
                        style: TextStyle(
                          color: InstructorColors.textPrimaryColor(isDark),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _submissionSubtitle(submission),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: InstructorColors.textSecondaryColor(isDark),
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(
                  label: _submissionStatusLabel(l10n, submission),
                  color: statusColor,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    _buildMetaPill(
                      isDark: isDark,
                      icon: Icons.event_rounded,
                      text: _formatDateTime(context, submission.submittedAt),
                    ),
                    _buildMetaPill(
                      isDark: isDark,
                      icon: Icons.swap_horiz_rounded,
                      text:
                          '${l10n.instructorAssignmentDetailAttempt} ${submission.attemptNumber}',
                    ),
                    _buildMetaPill(
                      isDark: isDark,
                      icon: Icons.attach_file_rounded,
                      text: _submissionAssetLabel(submission),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        statusColor.withValues(alpha: 0.16),
                        InstructorColors.info.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          isGraded && submission.score != null
                              ? _formatCompactScore(submission.score!)
                              : '--',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              isGraded && submission.score != null
                                  ? '${_formatScore(submission.score!)} / ${_formatScore(assignment.maxGrade)}'
                                  : l10n.pending,
                              style: TextStyle(
                                color: InstructorColors.textPrimaryColor(
                                  isDark,
                                ),
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isGraded
                                  ? l10n.graded
                                  : _submissionStatusLabel(l10n, submission),
                              style: TextStyle(
                                color: InstructorColors.textSecondaryColor(
                                  isDark,
                                ),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isGraded && submission.score != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            '${((submission.score! / assignment.maxGrade) * 100).clamp(0, 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 430;
                    final viewButton = OutlinedButton.icon(
                      onPressed: () => _showSubmissionDetails(
                        context,
                        assignment,
                        submission,
                        isDark,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: InstructorColors.primary,
                        side: BorderSide(
                          color: InstructorColors.primary.withValues(
                            alpha: 0.28,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        minimumSize: const Size.fromHeight(52),
                      ),
                      icon: const Icon(Icons.visibility_rounded),
                      label: Text(l10n.view),
                    );
                    final gradeButton = FilledButton.icon(
                      onPressed: () =>
                          _openGradingScreen(assignment, submission),
                      style: FilledButton.styleFrom(
                        backgroundColor: InstructorColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        minimumSize: const Size.fromHeight(52),
                      ),
                      icon: Icon(
                        isGraded ? Icons.edit_rounded : Icons.grading_rounded,
                      ),
                      label: Text(
                        isGraded
                            ? l10n.instructorAssignmentDetailActionEditGrade
                            : l10n.grade,
                      ),
                    );

                    if (compact) {
                      return Column(
                        children: <Widget>[
                          SizedBox(width: double.infinity, child: viewButton),
                          const SizedBox(height: 10),
                          SizedBox(width: double.infinity, child: gradeButton),
                        ],
                      );
                    }

                    return Row(
                      children: <Widget>[
                        Expanded(child: viewButton),
                        const SizedBox(width: 10),
                        Expanded(child: gradeButton),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _buildMetaPill({
    required bool isDark,
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            size: 15,
            color: InstructorColors.textSecondaryColor(isDark),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: InstructorColors.textSecondaryColor(isDark),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionSkeletonCard(bool isDark) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: InstructorColors.borderColor(isDark).withValues(alpha: 0.68),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List<Widget>.generate(6, (index) {
          final widths = <double>[120, 220, 260, 180, 210, 240];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              height: index == 0 ? 20 : 16,
              width: widths[index],
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDriveFileCard(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    DriveFileModel file,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: InstructorColors.borderColor(isDark).withValues(alpha: 0.58),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: InstructorColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.description_rounded,
                  color: InstructorColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  file.fileName,
                  style: TextStyle(
                    color: InstructorColors.textPrimaryColor(isDark),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 420;

              final previewButton = OutlinedButton.icon(
                onPressed: _canPreviewFile(file)
                    ? () => openDriveFilePreviewScreen(
                        context,
                        file: file,
                        isDark: isDark,
                      )
                    : null,
                icon: const Icon(Icons.visibility_rounded, size: 16),
                label: Text(l10n.instructorAssignmentDetailPreview),
                style: OutlinedButton.styleFrom(
                  foregroundColor: InstructorColors.primary,
                  side: BorderSide(
                    color: InstructorColors.primary.withValues(alpha: 0.28),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              );
              final openButton = OutlinedButton.icon(
                onPressed: file.webViewLink.trim().isEmpty
                    ? null
                    : () => _openUrl(file.webViewLink),
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: Text(l10n.assignmentOpenFile),
                style: OutlinedButton.styleFrom(
                  foregroundColor: InstructorColors.accent,
                  side: BorderSide(
                    color: InstructorColors.accent.withValues(alpha: 0.28),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              );
              final downloadButton = FilledButton.icon(
                onPressed: file.downloadUrl.trim().isEmpty
                    ? null
                    : () => _openUrl(file.downloadUrl),
                icon: const Icon(Icons.download_rounded, size: 16),
                label: Text(l10n.assignmentDownloadFile),
                style: FilledButton.styleFrom(
                  backgroundColor: InstructorColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              );

              if (compact) {
                return Column(
                  children: <Widget>[
                    SizedBox(width: double.infinity, child: previewButton),
                    const SizedBox(height: 8),
                    SizedBox(width: double.infinity, child: openButton),
                    const SizedBox(height: 8),
                    SizedBox(width: double.infinity, child: downloadButton),
                  ],
                );
              }

              return Row(
                children: <Widget>[
                  Expanded(child: previewButton),
                  const SizedBox(width: 8),
                  Expanded(child: openButton),
                  const SizedBox(width: 8),
                  Expanded(child: downloadButton),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInlineEmptyMessage(bool isDark, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        message,
        style: TextStyle(color: InstructorColors.textSecondaryColor(isDark)),
      ),
    );
  }

  Widget _buildEmptyCourseCard(
    bool isDark, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: InstructorColors.borderColor(isDark).withValues(alpha: 0.68),
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: InstructorColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: InstructorColors.primary, size: 30),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: InstructorColors.textPrimaryColor(isDark),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: InstructorColors.textSecondaryColor(isDark),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: InstructorColors.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_late_rounded,
                size: 42,
                color: InstructorColors.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? l10n.assignmentDetails,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: InstructorColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.instructorAssignmentDetailNoSubmissionsSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: InstructorColors.textSecondaryColor(isDark),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _refreshAll,
              style: FilledButton.styleFrom(
                backgroundColor: InstructorColors.primary,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  List<AssignmentSubmissionModel> _filteredSubmissions(AppLocalizations l10n) {
    final query = _searchQuery.trim().toLowerCase();

    return _submissions
        .where((submission) {
          final name = _studentName(l10n, submission).toLowerCase();
          final matchesSearch = query.isEmpty || name.contains(query);

          final matchesFilter = switch (_submissionFilter) {
            _SubmissionFilter.all => true,
            _SubmissionFilter.pending => _isPendingSubmission(submission),
            _SubmissionFilter.graded => _isGradedSubmission(submission),
            _SubmissionFilter.late => submission.isLate,
          };

          return matchesSearch && matchesFilter;
        })
        .toList(growable: false);
  }

  bool _isPendingSubmission(AssignmentSubmissionModel submission) {
    return submission.submissionStatus == api.SubmissionStatus.submitted ||
        submission.submissionStatus == api.SubmissionStatus.resubmit ||
        submission.submissionStatus == api.SubmissionStatus.unknown;
  }

  bool _isGradedSubmission(AssignmentSubmissionModel submission) {
    return submission.submissionStatus == api.SubmissionStatus.graded ||
        submission.submissionStatus == api.SubmissionStatus.returned;
  }

  String _submissionStatusLabel(
    AppLocalizations l10n,
    AssignmentSubmissionModel submission,
  ) {
    if (submission.isLate) {
      return l10n.late;
    }

    switch (submission.submissionStatus) {
      case api.SubmissionStatus.submitted:
        return l10n.submitted;
      case api.SubmissionStatus.resubmit:
        return l10n.instructorAssignmentDetailResubmit;
      case api.SubmissionStatus.graded:
        return l10n.graded;
      case api.SubmissionStatus.returned:
        return l10n.instructorAssignmentDetailReturned;
      case api.SubmissionStatus.unknown:
        return l10n.pending;
    }
  }

  Color _submissionStatusColor(AssignmentSubmissionModel submission) {
    if (submission.isLate) {
      return InstructorColors.error;
    }

    switch (submission.submissionStatus) {
      case api.SubmissionStatus.submitted:
      case api.SubmissionStatus.resubmit:
      case api.SubmissionStatus.unknown:
        return InstructorColors.warning;
      case api.SubmissionStatus.graded:
      case api.SubmissionStatus.returned:
        return InstructorColors.success;
    }
  }

  String _submissionSubtitle(AssignmentSubmissionModel submission) {
    final email = submission.user?.email.trim() ?? '';
    if (email.isNotEmpty) {
      return email;
    }

    if (submission.submissionText?.trim().isNotEmpty == true) {
      return submission.submissionText!.trim();
    }

    if (submission.submissionLink?.trim().isNotEmpty == true) {
      return submission.submissionLink!.trim();
    }

    if (submission.driveFile?.fileName.trim().isNotEmpty == true) {
      return submission.driveFile!.fileName;
    }

    return 'Student #${submission.userId}';
  }

  String _submissionAssetLabel(AssignmentSubmissionModel submission) {
    if (submission.driveFile != null) {
      return 'File';
    }
    if (submission.submissionLink?.trim().isNotEmpty == true) {
      return 'Link';
    }
    if (submission.submissionText?.trim().isNotEmpty == true) {
      return 'Text';
    }
    return 'Empty';
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

  String _initials(String value) {
    final parts = value
        .split(' ')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return 'ST';
    }
    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length.clamp(0, 2))
          .toUpperCase();
    }
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  Future<void> _showSubmissionDetails(
    BuildContext context,
    AssignmentModel assignment,
    AssignmentSubmissionModel submission,
    bool isDark,
  ) async {
    final l10n = AppLocalizations.of(context);
    final studentName = _studentName(l10n, submission);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * 0.88,
          ),
          decoration: BoxDecoration(
            color: InstructorColors.cardColor(isDark),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: <Widget>[
                Container(
                  width: 44,
                  height: 5,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: InstructorColors.borderColor(isDark),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: InstructorColors.primary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _initials(studentName),
                          style: const TextStyle(
                            color: InstructorColors.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
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
                                color: InstructorColors.textPrimaryColor(
                                  isDark,
                                ),
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.instructorAssignmentDetailSubmissionDetailsTitle,
                              style: TextStyle(
                                color: InstructorColors.textSecondaryColor(
                                  isDark,
                                ),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
                    children: <Widget>[
                      _buildSectionCard(
                        sheetContext,
                        isDark,
                        title:
                            l10n.instructorAssignmentDetailSubmissionSnapshot,
                        subtitle:
                            '${l10n.assignmentDetails} • ${assignment.title}',
                        icon: Icons.grid_view_rounded,
                        child: Column(
                          children: <Widget>[
                            _buildPillRow(
                              isDark: isDark,
                              icon: Icons.person_outline_rounded,
                              label: l10n.student,
                              value: studentName,
                              color: InstructorColors.primary,
                            ),
                            const SizedBox(height: 12),
                            _buildPillRow(
                              isDark: isDark,
                              icon: Icons.event_rounded,
                              label: l10n.instructorAssignmentDetailSubmittedAt,
                              value: _formatDateTime(
                                context,
                                submission.submittedAt,
                              ),
                              color: InstructorColors.teal,
                            ),
                            const SizedBox(height: 12),
                            _buildPillRow(
                              isDark: isDark,
                              icon: Icons.swap_horiz_rounded,
                              label: l10n.instructorAssignmentDetailAttempt,
                              value: submission.attemptNumber.toString(),
                              color: InstructorColors.accent,
                            ),
                            const SizedBox(height: 12),
                            _buildPillRow(
                              isDark: isDark,
                              icon: Icons.grade_rounded,
                              label:
                                  l10n.instructorAssignmentDetailCurrentScore,
                              value: submission.score == null
                                  ? l10n.pending
                                  : '${_formatScore(submission.score!)} / ${_formatScore(assignment.maxGrade)}',
                              color: _submissionStatusColor(submission),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (submission.submissionText?.trim().isNotEmpty == true)
                        _buildSectionCard(
                          sheetContext,
                          isDark,
                          title: l10n.instructorAssignmentDetailSubmissionText,
                          subtitle:
                              l10n.instructorAssignmentDetailBriefSubtitle,
                          icon: Icons.notes_rounded,
                          child: MarkdownBody(
                            data: submission.submissionText!.trim(),
                          ),
                        ),
                      if (submission.submissionText?.trim().isNotEmpty == true)
                        const SizedBox(height: 16),
                      if (submission.submissionLink?.trim().isNotEmpty == true)
                        _buildSectionCard(
                          sheetContext,
                          isDark,
                          title: l10n.instructorAssignmentDetailSubmissionLink,
                          subtitle:
                              l10n.instructorAssignmentDetailWorkflowSubtitle,
                          icon: Icons.link_rounded,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final linkButton = FilledButton.icon(
                                onPressed: () =>
                                    _openUrl(submission.submissionLink!.trim()),
                                style: FilledButton.styleFrom(
                                  backgroundColor: InstructorColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                                icon: const Icon(Icons.open_in_new_rounded),
                                label: Text(
                                  l10n.instructorAssignmentDetailOpenLink,
                                ),
                              );
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    submission.submissionLink!.trim(),
                                    style: TextStyle(
                                      color: InstructorColors.primary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  linkButton,
                                ],
                              );
                            },
                          ),
                        ),
                      if (submission.submissionLink?.trim().isNotEmpty == true)
                        const SizedBox(height: 16),
                      if (submission.driveFile != null)
                        _buildSectionCard(
                          sheetContext,
                          isDark,
                          title: l10n.instructorAssignmentDetailSubmittedFile,
                          subtitle: submission.driveFile!.fileName,
                          icon: Icons.attach_file_rounded,
                          child: _buildDriveFileCard(
                            sheetContext,
                            isDark,
                            l10n,
                            submission.driveFile!,
                          ),
                        ),
                      if (submission.submissionText?.trim().isNotEmpty !=
                              true &&
                          submission.submissionLink?.trim().isNotEmpty !=
                              true &&
                          submission.driveFile == null)
                        _buildInlineEmptyMessage(
                          isDark,
                          l10n.instructorAssignmentDetailNoSubmissionContent,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openEditScreen(AssignmentModel assignment) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => CreateAssignmentScreen(
          assignment: assignment,
          assignmentId: assignment.assignmentId,
          preferredCourseId: assignment.courseId,
          useTAColors: true,
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
    setState(() => _updatingStatus = true);
    final result = await _assignmentService.updateStatus(
      widget.assignmentId,
      status,
    );
    if (!mounted) {
      return;
    }
    setState(() => _updatingStatus = false);

    if (!result.isSuccess || result.data == null) {
      _showSnack(result.error?.message ?? 'Failed to update assignment status');
      return;
    }

    setState(() => _assignment = result.data);
    _showSnack(_statusUpdateMessage(AppLocalizations.of(context), status));
  }

  Future<void> _openGradingScreen(
    AssignmentModel assignment,
    AssignmentSubmissionModel submission,
  ) async {
    final l10n = AppLocalizations.of(context);
    final isDark = context.read<ThemeBloc>().state.isDark;
    final daysLate = submission.isLate
        ? submission.submittedAt.difference(assignment.dueDate).inDays.abs()
        : 0;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final sheetNavigator = Navigator.of(sheetContext);
        var isSaving = false;
        String? errorMessage;

        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: InstructorColors.cardColor(isDark),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: InstructorColors.borderColor(isDark),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: isDark
                              ? InstructorColors.darkHeaderGradient
                              : InstructorColors.headerGradient,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.grading_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    l10n.grade,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _studentName(l10n, submission),
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.92,
                                      ),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: <Widget>[
                                      _buildHeroChip(
                                        icon: Icons.menu_book_rounded,
                                        label: assignment.courseCode,
                                      ),
                                      _buildHeroChip(
                                        icon: Icons.event_rounded,
                                        label: _compactDate(
                                          context,
                                          submission.submittedAt,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: isSaving
                                  ? null
                                  : () => Navigator.of(sheetContext).pop(),
                              icon: const Icon(Icons.close_rounded),
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      GradingPanel(
                        maxScore: assignment.maxGrade,
                        initialScore: submission.score,
                        initialFeedback: submission.feedback,
                        latePenaltyPercent: assignment.latePenaltyPercent,
                        daysLate: daysLate,
                        isSaving: isSaving,
                        errorMessage: errorMessage,
                        readOnly:
                            assignment.apiStatus ==
                            api.AssignmentStatus.archived,
                        onSave: (score, feedback) async {
                          final successMessage = l10n.gradeSubmitted;
                          setSheetState(() {
                            isSaving = true;
                            errorMessage = null;
                          });

                          final result = await _assignmentService
                              .gradeSubmission(
                                assignment.assignmentId,
                                submission.id,
                                score,
                                feedback: feedback,
                              );

                          if (!mounted) {
                            return;
                          }

                          if (!result.isSuccess) {
                            setSheetState(() {
                              isSaving = false;
                              errorMessage =
                                  result.error?.message ??
                                  'Failed to grade submission';
                            });
                            return;
                          }

                          if (sheetNavigator.canPop()) {
                            sheetNavigator.pop();
                          }
                          _showSnack(successMessage);
                          await _loadSubmissions();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  String _compactDate(BuildContext context, DateTime value) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat.MMMd(locale).format(value.toLocal());
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

  String _formatCompactScore(double value) {
    return value == value.roundToDouble()
        ? value.round().toString()
        : value.toStringAsFixed(1);
  }

  bool _canPreviewFile(DriveFileModel file) {
    return file.iframeUrl.trim().isNotEmpty && file.driveId.trim().isNotEmpty;
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static List<api.AssignmentStatus> _nextStatuses(
    api.AssignmentStatus current,
  ) {
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
        return InstructorColors.warning;
      case api.AssignmentStatus.published:
        return InstructorColors.success;
      case api.AssignmentStatus.closed:
        return InstructorColors.info;
      case api.AssignmentStatus.archived:
        return InstructorColors.pink;
      case api.AssignmentStatus.unknown:
        return InstructorColors.textSecondary;
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
}

class _AssignmentDetailLoadingView extends StatelessWidget {
  const _AssignmentDetailLoadingView({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    Widget block({required double height, double? width}) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(14),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: <Widget>[
        Row(
          children: <Widget>[
            block(height: 48, width: 48),
            const SizedBox(width: 12),
            Expanded(child: block(height: 24)),
            const SizedBox(width: 12),
            block(height: 48, width: 48),
            const SizedBox(width: 10),
            block(height: 48, width: 48),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 190,
          decoration: BoxDecoration(
            gradient: InstructorColors.headerGradient,
            borderRadius: BorderRadius.circular(28),
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  block(height: 48, width: 48),
                  const SizedBox(width: 10),
                  Expanded(child: block(height: 24, width: 220)),
                ],
              ),
              const SizedBox(height: 8),
              block(height: 16, width: double.infinity),
              const SizedBox(height: 6),
              block(height: 16, width: r.screenWidth * 0.46),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  block(height: 32, width: 92),
                  block(height: 32, width: 90),
                ],
              ),
              const Spacer(),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List<Widget>.generate(
                  4,
                  (_) => Container(
                    width: (r.screenWidth - 32 - 24) / 2,
                    height: 62,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        block(height: 56, width: double.infinity),
        const SizedBox(height: 16),
        ...List<Widget>.generate(
          3,
          (_) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: InstructorColors.cardColor(isDark),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: InstructorColors.borderColor(
                  isDark,
                ).withValues(alpha: 0.68),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                block(height: 20, width: 170),
                const SizedBox(height: 14),
                block(height: 16, width: double.infinity),
                const SizedBox(height: 10),
                block(height: 16, width: double.infinity),
                const SizedBox(height: 10),
                block(height: 16, width: r.screenWidth * 0.45),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AssignmentDetailTabsHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  const _AssignmentDetailTabsHeaderDelegate({
    required this.height,
    required this.child,
  });

  final double height;
  final Widget child;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(
    covariant _AssignmentDetailTabsHeaderDelegate oldDelegate,
  ) {
    return height != oldDelegate.height || child != oldDelegate.child;
  }
}
