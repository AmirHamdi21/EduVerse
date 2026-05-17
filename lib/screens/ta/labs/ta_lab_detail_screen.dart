import 'dart:io';

import 'package:edu_verse/common/utils/responsive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../bloc/instructor/lab_detail_cubit.dart';
import '../../../bloc/instructor/lab_detail_state.dart';
import '../../../bloc/ta/ta_labs_cubit.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/core/drive_file_model.dart';
import '../../../models/core/enums/assignment_enums.dart' as assignment_api;
import '../../../models/core/enums/course_enums.dart';
import '../../../models/core/enums/lab_enums.dart' as api;
import '../../../models/core/lab_attendance_model.dart';
import '../../../models/core/lab_instruction_model.dart';
import '../../../models/core/shared_models.dart';
import '../../../models/instructor/teaching_course_model.dart';
import '../../../models/labs/lab_model.dart';
import '../../../models/labs/lab_submission_model.dart';
import '../../../models/core/course_model.dart';
import '../../../models/core/section_model.dart';
import '../../../models/core/semester_model.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/lab_service.dart';
import '../../../services/storage_service.dart';
import '../../../utils/navigation/safe_back.dart';
import '../../../widgets/instructor/labs/grading_panel.dart';
import '../../../widgets/instructor/labs/lab_create_form.dart';
import '../../../widgets/ta/shared/ta_colors.dart';
import '../../../widgets/student/academic/academic_list_skeleton.dart';
import '../../../widgets/student/shared/drive_file_preview_screen.dart';
import '../../shared/lab_editor_screen.dart';

class TALabDetailScreen extends StatelessWidget {
  const TALabDetailScreen({
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
        cubit.initialize(labId);
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

enum _LabSubmissionFilter { all, pending, graded, late }

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
  final ScrollController _outerScrollController = ScrollController();
  final TextEditingController _newInstructionController =
      TextEditingController();
  final Map<int, TextEditingController> _editControllers =
      <int, TextEditingController>{};
  final Set<int> _editingInstructionIds = <int>{};

  late int _currentTabIndex;
  bool _canManage = true;
  bool _uploadingTaMaterial = false;
  bool _uploadingInstructionFile = false;
  String _searchQuery = '';
  _LabSubmissionFilter _submissionFilter = _LabSubmissionFilter.all;
  final Map<int, api.LabAttendanceStatus> _attendanceOverrides =
      <int, api.LabAttendanceStatus>{};
  final Set<int> _attendancePendingIds = <int>{};

  bool _isCompactHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height < 700;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 3),
    );
    _currentTabIndex = _tabController.index;
    _tabController.addListener(_handleTabChanged);
    _resolveRoleAccess();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChanged);
    _tabController.dispose();
    _outerScrollController.dispose();
    _newInstructionController.dispose();
    for (final controller in _editControllers.values) {
      controller.dispose();
    }
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
        _canManage =
            roleNames.isEmpty ||
            roleNames.contains('instructor') ||
            roleNames.contains('ta') ||
            roleNames.contains('teaching_assistant') ||
            roleNames.contains('teaching assistant');
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _canManage = true;
      });
    }
  }

  void _restoreTaLabsListIfAvailable() {
    try {
      context.read<TALabsCubit>().restoreLabsList();
    } catch (_) {
      // The detail route can be opened outside the TA labs list scope.
    }
  }

  void _handleBackNavigation() {
    _restoreTaLabsListIfAvailable();
    safeBack(context, '/ta/dashboard');
  }

  Widget _buildIconShell({
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: TAColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: TAColors.borderColor(isDark).withValues(alpha: 0.74),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.14 : 0.05),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: TAColors.textPrimaryColor(isDark)),
      ),
    );
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

            if (!state.isSubmittingAttendance) {
              _attendanceOverrides.clear();
              _attendancePendingIds.clear();
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
                backgroundColor: TAColors.background(isDark),
                body: SafeArea(child: _LabDetailLoadingView(isDark: isDark)),
              );
            }

            if (state is LabDetailError) {
              return Scaffold(
                backgroundColor: TAColors.background(isDark),
                body: SafeArea(
                  child: _buildErrorState(context, isDark, l10n, state),
                ),
              );
            }

            final loaded = state as LabDetailLoaded;
            return _buildDetailScaffold(context, isDark, l10n, loaded);
          },
        );
      },
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    LabDetailError state,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: TAColors.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                state.statusCode == 404
                    ? Icons.search_off_rounded
                    : Icons.cloud_off_rounded,
                size: 44,
                color: TAColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              state.statusCode == 404
                  ? l10n.instructorLabNotFound
                  : l10n.instructorLabDetailErrorTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TAColors.textPrimaryColor(isDark),
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TAColors.textSecondaryColor(isDark),
                fontSize: 15,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () =>
                  context.read<LabDetailCubit>().initialize(widget.labId),
              style: FilledButton.styleFrom(
                backgroundColor: TAColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailScaffold(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    LabDetailLoaded state,
  ) {
    final compactHeight = _isCompactHeight(context);
    return Scaffold(
      backgroundColor: TAColors.background(isDark),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _currentTabRefreshAction(context),
          child: NestedScrollView(
            controller: _outerScrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            headerSliverBuilder: (context, innerBoxIsScrolled) => <Widget>[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Column(
                    children: <Widget>[
                      _buildTopBar(context, isDark, l10n, state.lab),
                      SizedBox(height: compactHeight ? 8 : 10),
                      _buildHeroHeader(
                        context,
                        isDark,
                        l10n,
                        state.lab,
                        state.submissions ?? const <LabSubmissionModel>[],
                      ),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _LabDetailTabsHeaderDelegate(
                  height: compactHeight ? 76 : 86,
                  child: Container(
                    color: TAColors.background(isDark),
                    padding: EdgeInsets.fromLTRB(
                      16,
                      compactHeight ? 8 : 12,
                      16,
                      compactHeight ? 8 : 12,
                    ),
                    child: _buildTabStrip(context, isDark, l10n),
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: List<Widget>.generate(
                4,
                (index) => ListView(
                  padding: EdgeInsets.zero,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: ClampingScrollPhysics(),
                  ),
                  children: <Widget>[
                    _buildCurrentTabContent(
                      context,
                      isDark,
                      l10n,
                      state,
                      index,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _currentTabRefreshAction(BuildContext context) {
    final cubit = context.read<LabDetailCubit>();
    switch (_currentTabIndex) {
      case 1:
        return cubit.loadSubmissions(widget.labId);
      case 2:
        return cubit.loadAttendance(widget.labId);
      case 3:
        return cubit.loadInstructions(widget.labId);
      case 0:
      default:
        return cubit.initialize(widget.labId);
    }
  }

  Widget _buildCurrentTabContent(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    LabDetailLoaded state,
    int tabIndex,
  ) {
    switch (tabIndex) {
      case 0:
        return _buildOverviewTab(context, isDark, l10n, state.lab);
      case 1:
        return _buildSubmissionsTab(
          context,
          isDark,
          l10n,
          state.lab,
          state.submissions,
        );
      case 2:
        return _buildAttendanceTab(context, isDark, l10n, state.attendance);
      case 3:
      default:
        return _buildInstructionsTab(context, isDark, l10n, state);
    }
  }

  Widget _buildTopBar(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    LabModel lab,
  ) {
    return Row(
      children: <Widget>[
        _buildIconShell(
          icon: iosBackIcon(context),
          isDark: isDark,
          onTap: _handleBackNavigation,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            lab.course?.name.trim().isNotEmpty == true
                ? lab.course!.name
                : '${l10n.course} #${lab.courseId}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: TAColors.textPrimaryColor(isDark),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 12),
        _buildIconShell(
          icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          isDark: isDark,
          onTap: () => context.read<ThemeBloc>().add(const ToggleThemeEvent()),
        ),
        const SizedBox(width: 10),
        if (_canManage)
          PopupMenuButton<String>(
            enabled: !_uploadingTaMaterial && !_uploadingInstructionFile,
            tooltip: '',
            color: TAColors.cardColor(isDark),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            icon: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: TAColors.cardColor(isDark),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: TAColors.borderColor(isDark).withValues(alpha: 0.74),
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
                _uploadingTaMaterial || _uploadingInstructionFile
                    ? Icons.hourglass_top_rounded
                    : Icons.more_horiz_rounded,
                color: TAColors.textPrimaryColor(isDark),
              ),
            ),
            onSelected: (value) {
              if (value == 'edit') {
                _openEditLabForm(lab);
              } else if (value == 'upload_material') {
                _pickAndUploadTaMaterial(context);
              } else if (value == 'delete') {
                _confirmDeleteLab(lab);
              }
            },
            itemBuilder: (context) => <PopupMenuEntry<String>>[
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
              PopupMenuItem<String>(
                value: 'upload_material',
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.upload_file_rounded, size: 18),
                    const SizedBox(width: 10),
                    Text(l10n.instructorLabUploadMaterial),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: TAColors.error,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      l10n.delete,
                      style: const TextStyle(color: TAColors.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildHeroHeader(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    LabModel lab,
    List<LabSubmissionModel> submissions,
  ) {
    final r = context.responsive;
    final compactHeight = _isCompactHeight(context);
    final stats = <({IconData icon, String label, String value, Color color})>[
      (
        icon: Icons.flag_rounded,
        label: l10n.status,
        value: _statusLabel(l10n, lab.status),
        color: _labStatusColor(lab.status),
      ),
      (
        icon: Icons.assignment_turned_in_rounded,
        label: l10n.submissions,
        value: submissions.length.toString(),
        color: TAColors.accent,
      ),
      (
        icon: Icons.stars_rounded,
        label: l10n.taLabMaxScore,
        value: _formatScore(lab.maxScore),
        color: TAColors.warning,
      ),
      (
        icon: Icons.schedule_rounded,
        label: l10n.dueDate,
        value: _compactDate(context, lab.dueDate),
        color: TAColors.teal,
      ),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: isDark
            ? TAColors.darkHeaderGradient
            : TAColors.headerGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: TAColors.primary.withValues(alpha: isDark ? 0.26 : 0.18),
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
              padding: EdgeInsets.fromLTRB(
                14,
                compactHeight ? 14 : 16,
                14,
                compactHeight ? 12 : 14,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: compactHeight ? 42 : 48,
                        height: compactHeight ? 42 : 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.science_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      SizedBox(width: compactHeight ? 8 : 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              lab.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: compactHeight
                                    ? (r.isMobile ? 20 : 22)
                                    : (r.isMobile
                                          ? r.fontSize20
                                          : r.fontSize24),
                                fontWeight: FontWeight.w800,
                                height: 1.12,
                              ),
                            ),
                            if (!compactHeight) ...<Widget>[
                              const SizedBox(height: 5),
                              Text(
                                l10n.instructorLabDetailHeroSubtitle,
                                maxLines: r.isMobile ? 2 : 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.84),
                                  fontSize: r.fontSize12,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: compactHeight ? 10 : 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      _buildHeroChip(
                        icon: Icons.menu_book_rounded,
                        label: (lab.course?.code ?? '').trim().isNotEmpty
                            ? lab.course!.code
                            : '${l10n.course} #${lab.courseId}',
                      ),
                      if ((lab.labNumber ?? 0) > 0)
                        _buildHeroChip(
                          icon: Icons.tag_rounded,
                          label: '${l10n.labDetails} #${lab.labNumber}',
                        ),
                    ],
                  ),
                  SizedBox(height: compactHeight ? 10 : 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 900
                          ? 4
                          : constraints.maxWidth >= 600
                          ? 4
                          : 2;
                      const spacing = 8.0;
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
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
              fontSize: 11,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
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
              fontSize: 14,
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
    final tabs = <({IconData icon, String label})>[
      (icon: Icons.grid_view_rounded, label: l10n.overview),
      (icon: Icons.assignment_turned_in_rounded, label: l10n.submissions),
      (icon: Icons.how_to_reg_rounded, label: l10n.taLabAttendanceTab),
      (icon: Icons.menu_book_rounded, label: l10n.instructions),
    ];

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.7),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicator: BoxDecoration(
          color: TAColors.primary,
          borderRadius: BorderRadius.circular(999),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: TAColors.primary.withValues(alpha: 0.28),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: TAColors.textPrimaryColor(isDark),
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        splashBorderRadius: BorderRadius.circular(999),
        padding: EdgeInsets.zero,
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: tabs
            .map(
              (tab) => Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(tab.icon, size: 18),
                    const SizedBox(width: 8),
                    Text(tab.label),
                  ],
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }

  Widget _buildOverviewTab(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    LabModel lab,
  ) {
    final rows = <({IconData icon, String title, String value, Color color})>[
      (
        icon: Icons.school_rounded,
        title: l10n.course,
        value:
            '${lab.course?.name ?? '${l10n.course} #${lab.courseId}'} (${(lab.course?.code ?? '').trim().isNotEmpty ? lab.course!.code : lab.courseId})',
        color: TAColors.primary,
      ),
      (
        icon: Icons.flag_rounded,
        title: l10n.status,
        value: _statusLabel(l10n, lab.status),
        color: _labStatusColor(lab.status),
      ),
      (
        icon: Icons.event_available_rounded,
        title: l10n.availableFrom,
        value: lab.availableFrom == null
            ? l10n.assignmentNoDueDate
            : _formatDateTime(context, lab.availableFrom!),
        color: TAColors.teal,
      ),
      (
        icon: Icons.schedule_rounded,
        title: l10n.dueDate,
        value: _formatDueDate(context, l10n, lab),
        color: TAColors.error,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: <Widget>[
          _buildSectionCard(
            context,
            isDark,
            title: l10n.instructorLabDetailSnapshotTitle,
            subtitle: l10n.instructorLabDetailSnapshotSubtitle,
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
            title: l10n.instructorLabDetailBriefTitle,
            subtitle: l10n.instructorLabDetailBriefSubtitle,
            icon: Icons.notes_rounded,
            child: Text(
              lab.description?.trim().isNotEmpty == true
                  ? lab.description!.trim()
                  : l10n.instructorLabDetailBriefEmpty,
              style: TextStyle(
                color: TAColors.textSecondaryColor(isDark),
                fontSize: 14,
                height: 1.58,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            context,
            isDark,
            title: l10n.instructorLabDetailWorkflowTitle,
            subtitle: l10n.instructorLabDetailWorkflowSubtitle,
            icon: Icons.route_rounded,
            child: Column(
              children: <Widget>[
                _buildPillRow(
                  isDark: isDark,
                  icon: Icons.stars_rounded,
                  label: l10n.taLabMaxScore,
                  value: _formatScore(lab.maxScore),
                  color: TAColors.warning,
                ),
                const SizedBox(height: 12),
                _buildPillRow(
                  isDark: isDark,
                  icon: Icons.scale_rounded,
                  label: l10n.labEditorWeight,
                  value: '${_formatScore(lab.weight)}%',
                  color: TAColors.accent,
                ),
                const SizedBox(height: 12),
                _buildPillRow(
                  isDark: isDark,
                  icon: Icons.file_copy_rounded,
                  label: l10n.assignmentAllowedFileTypes,
                  value: (lab.allowedFileTypes ?? '').trim().isEmpty
                      ? l10n.assignmentNotConfigured
                      : lab.allowedFileTypes!,
                  color: TAColors.primary,
                ),
                const SizedBox(height: 12),
                _buildPillRow(
                  isDark: isDark,
                  icon: Icons.folder_zip_rounded,
                  label: l10n.assignmentMaxFileSize,
                  value: (lab.maxFileSizeMb ?? 0) > 0
                      ? '${_formatScore(lab.maxFileSizeMb!)} MB'
                      : l10n.assignmentNotConfigured,
                  color: TAColors.teal,
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
    LabModel lab,
    List<LabSubmissionModel>? submissions,
  ) {
    final allSubmissions = submissions ?? const <LabSubmissionModel>[];
    final filtered = _filteredSubmissions(allSubmissions);
    final compactHeight = _isCompactHeight(context);
    final pendingCount = allSubmissions.where(_isPendingSubmission).length;
    final gradedCount = allSubmissions.where(_isGradedSubmission).length;
    final lateCount = allSubmissions.where((item) => item.isLate).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: <Widget>[
          if (_canManage) ...<Widget>[
            _buildSectionCard(
              context,
              isDark,
              title: l10n.instructorLabDetailSubmissionsTitle,
              subtitle: compactHeight
                  ? ''
                  : l10n.instructorLabDetailSubmissionsSubtitle,
              icon: Icons.fact_check_rounded,
              compact: compactHeight,
              child: Column(
                children: <Widget>[
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.trim();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: l10n.instructorLabDetailSearchStudents,
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: isDark
                          ? TAColors.surfaceColor(isDark)
                          : const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: TAColors.borderColor(
                            isDark,
                          ).withValues(alpha: 0.7),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: TAColors.borderColor(
                            isDark,
                          ).withValues(alpha: 0.7),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: TAColors.primary,
                          width: 1.4,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: compactHeight ? 10 : 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: <Widget>[
                          _buildFilterChip(
                            isDark: isDark,
                            label: l10n.all,
                            count: allSubmissions.length,
                            selected:
                                _submissionFilter == _LabSubmissionFilter.all,
                            onTap: () => setState(
                              () =>
                                  _submissionFilter = _LabSubmissionFilter.all,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _buildFilterChip(
                            isDark: isDark,
                            label: l10n.pending,
                            count: pendingCount,
                            selected:
                                _submissionFilter ==
                                _LabSubmissionFilter.pending,
                            onTap: () => setState(
                              () => _submissionFilter =
                                  _LabSubmissionFilter.pending,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _buildFilterChip(
                            isDark: isDark,
                            label: l10n.graded,
                            count: gradedCount,
                            selected:
                                _submissionFilter ==
                                _LabSubmissionFilter.graded,
                            onTap: () => setState(
                              () => _submissionFilter =
                                  _LabSubmissionFilter.graded,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _buildFilterChip(
                            isDark: isDark,
                            label: l10n.late,
                            count: lateCount,
                            selected:
                                _submissionFilter == _LabSubmissionFilter.late,
                            onTap: () => setState(
                              () =>
                                  _submissionFilter = _LabSubmissionFilter.late,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (submissions == null)
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
              title: l10n.instructorLabDetailNoSubmissionsTitle,
              subtitle: l10n.instructorLabDetailNoSubmissionsSubtitle,
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
                  lab,
                  submission,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubmissionCard(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    LabModel lab,
    LabSubmissionModel submission,
  ) {
    final isGraded = _isGradedSubmission(submission);
    final statusColor = _submissionStatusColor(submission);
    final studentName = _studentName(l10n, submission.user, submission.userId);
    final scoreText = submission.score == null
        ? l10n.taLabNoScoreYet
        : '${_formatScore(submission.score!)} / ${_formatScore(lab.maxScore)}';

    return Container(
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.7),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: _canManage
              ? () => _showSubmissionDetails(context, l10n, lab, submission)
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: TAColors.primary,
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _initials(studentName),
                            style: const TextStyle(
                              color: TAColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
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
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: TAColors.textPrimaryColor(isDark),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                submission.user?.email.trim().isNotEmpty == true
                                    ? submission.user!.email
                                    : (submission.submissionText
                                                  ?.trim()
                                                  .isNotEmpty ==
                                              true
                                          ? submission.submissionText!.trim()
                                          : '${l10n.taLabOverview} #${submission.id}'),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: TAColors.textSecondaryColor(isDark),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildStatusBadge(
                          label: _submissionStatusLabel(l10n, submission),
                          color: statusColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        _buildMetaChip(
                          isDark: isDark,
                          icon: Icons.calendar_today_rounded,
                          label: _compactDateTime(
                            context,
                            submission.submittedAt,
                          ),
                        ),
                        if (submission.driveFile != null)
                          _buildMetaChip(
                            isDark: isDark,
                            icon: Icons.attach_file_rounded,
                            label: _fileExtensionLabel(
                              submission.driveFile!,
                              l10n.assignmentSubmissionTypeFile,
                            ),
                          ),
                        _buildMetaChip(
                          isDark: isDark,
                          icon: Icons.flag_rounded,
                          label: submission.isLate ? l10n.late : l10n.submitted,
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
                            TAColors.success.withValues(alpha: 0.16),
                            TAColors.teal.withValues(alpha: 0.16),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: TAColors.success.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: TAColors.success,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              submission.score == null
                                  ? '--'
                                  : _formatScore(submission.score!),
                              style: const TextStyle(
                                color: Colors.white,
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
                                  scoreText,
                                  style: const TextStyle(
                                    color: TAColors.success,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: LinearProgressIndicator(
                                    value:
                                        submission.score == null ||
                                            lab.maxScore <= 0
                                        ? 0
                                        : (submission.score! / lab.maxScore)
                                              .clamp(0, 1)
                                              .toDouble(),
                                    minHeight: 6,
                                    backgroundColor: Colors.white.withValues(
                                      alpha: 0.55,
                                    ),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          TAColors.success,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final compact = constraints.maxWidth < 380;
                        final viewButton = OutlinedButton.icon(
                          onPressed: () => _showSubmissionDetails(
                            context,
                            l10n,
                            lab,
                            submission,
                          ),
                          icon: const Icon(Icons.visibility_outlined, size: 18),
                          label: Text(l10n.view),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: TAColors.primary,
                            side: BorderSide(
                              color: TAColors.primary.withValues(alpha: 0.3),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        );
                        final gradeButton = FilledButton.icon(
                          onPressed: _canManage
                              ? () => _openGradingPanel(lab, submission)
                              : null,
                          icon: Icon(
                            isGraded
                                ? Icons.edit_rounded
                                : Icons.grading_rounded,
                            size: 18,
                          ),
                          label: Text(
                            isGraded ? l10n.taLabRegrade : l10n.grade,
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: TAColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        );

                        if (compact) {
                          return Column(
                            children: <Widget>[
                              SizedBox(
                                width: double.infinity,
                                child: viewButton,
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: gradeButton,
                              ),
                            ],
                          );
                        }

                        return Row(
                          children: <Widget>[
                            Expanded(child: viewButton),
                            const SizedBox(width: 12),
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
        ),
      ),
    );
  }

  Widget _buildAttendanceTab(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    List<LabAttendanceModel>? attendance,
  ) {
    final items = attendance ?? const <LabAttendanceModel>[];
    final compactHeight = _isCompactHeight(context);
    final presentCount = items
        .where(
          (item) => item.attendanceStatus == api.LabAttendanceStatus.present,
        )
        .length;
    final absentCount = items
        .where(
          (item) => item.attendanceStatus == api.LabAttendanceStatus.absent,
        )
        .length;
    final lateCount = items
        .where((item) => item.attendanceStatus == api.LabAttendanceStatus.late)
        .length;
    final excusedCount = items
        .where(
          (item) => item.attendanceStatus == api.LabAttendanceStatus.excused,
        )
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: <Widget>[
          if (_canManage) ...<Widget>[
            _buildSectionCard(
              context,
              isDark,
              title: l10n.instructorLabDetailAttendanceTitle,
              subtitle: compactHeight
                  ? ''
                  : l10n.instructorLabDetailAttendanceSubtitle,
              icon: Icons.how_to_reg_rounded,
              compact: compactHeight,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 720 ? 4 : 2;
                  const spacing = 10.0;
                  final itemWidth =
                      (constraints.maxWidth - (spacing * (columns - 1))) /
                      columns;
                  final stats = <({String label, int count, Color color})>[
                    (
                      label: l10n.taLabPresent,
                      count: presentCount,
                      color: TAColors.success,
                    ),
                    (
                      label: l10n.taLabAbsent,
                      count: absentCount,
                      color: TAColors.error,
                    ),
                    (
                      label: l10n.taLabLateMark,
                      count: lateCount,
                      color: TAColors.warning,
                    ),
                    (
                      label: l10n.excused,
                      count: excusedCount,
                      color: TAColors.teal,
                    ),
                  ];
                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: stats
                        .map(
                          (stat) => _buildAttendanceSummaryCard(
                            isDark: isDark,
                            width: itemWidth,
                            label: stat.label,
                            count: stat.count,
                            color: stat.color,
                          ),
                        )
                        .toList(growable: false),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (attendance == null)
            ...List<Widget>.generate(
              3,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildSubmissionSkeletonCard(isDark),
              ),
            )
          else if (attendance.isEmpty)
            _buildEmptyCourseCard(
              isDark,
              title: l10n.instructorLabDetailNoAttendanceTitle,
              subtitle: l10n.instructorLabDetailNoAttendanceSubtitle,
              icon: Icons.group_off_outlined,
            )
          else
            ...attendance.map(
              (record) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildAttendanceRecordCard(
                  context,
                  isDark,
                  l10n,
                  record,
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
    LabDetailLoaded state,
  ) {
    final instructions = state.instructions;
    final isUpdating = state is LabInstructionUpdating;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: <Widget>[
          if (_canManage) ...<Widget>[
            _buildSectionCard(
              context,
              isDark,
              title: l10n.instructorLabDetailInstructionComposerTitle,
              subtitle: l10n.instructorLabDetailInstructionComposerSubtitle,
              icon: Icons.edit_note_rounded,
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: _newInstructionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: l10n.instructorLabDetailInstructionHint,
                      filled: true,
                      fillColor: isDark
                          ? TAColors.surfaceColor(isDark)
                          : const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: TAColors.borderColor(
                            isDark,
                          ).withValues(alpha: 0.7),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: TAColors.borderColor(
                            isDark,
                          ).withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isUpdating || _uploadingInstructionFile
                              ? null
                              : _uploadInstructionFile,
                          icon: _uploadingInstructionFile
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.attach_file_rounded),
                          label: Text(l10n.assignmentDownloadFile),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: TAColors.primary,
                            side: BorderSide(
                              color: TAColors.primary.withValues(alpha: 0.28),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: isUpdating ? null : _addInstruction,
                          icon: const Icon(Icons.add_rounded),
                          label: Text(l10n.instructorLabDetailAddInstruction),
                          style: FilledButton.styleFrom(
                            backgroundColor: TAColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildInstructorMaterialUploadCard(isDark, l10n),
            const SizedBox(height: 16),
          ],
          _buildSectionCard(
            context,
            isDark,
            title: l10n.instructorLabDetailInstructionsTitle,
            subtitle: l10n.instructorLabDetailInstructionsSubtitle,
            icon: Icons.menu_book_rounded,
            child: instructions == null
                ? _buildInlineLoading(isDark)
                : instructions.isEmpty
                ? _buildInlineEmptyMessage(
                    isDark,
                    l10n.instructorLabDetailNoInstructionsSubtitle,
                  )
                : Column(
                    children: List<Widget>.generate(instructions.length, (
                      index,
                    ) {
                      final instruction = instructions[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == instructions.length - 1 ? 0 : 12,
                        ),
                        child: _buildInstructionCard(
                          context,
                          isDark,
                          l10n,
                          instruction,
                          index,
                          instructions.length,
                          isUpdating,
                        ),
                      );
                    }),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionCard(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    LabInstructionModel instruction,
    int index,
    int totalCount,
    bool isUpdating,
  ) {
    final isEditing = _editingInstructionIds.contains(instruction.id);
    final hasText = instruction.instructionText?.trim().isNotEmpty == true;
    final file = instruction.file;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? TAColors.surfaceColor(isDark) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: TAColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${l10n.instructorLabDetailInstructionOrder} ${index + 1}',
                  style: const TextStyle(
                    color: TAColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  file != null
                      ? file.fileName
                      : l10n.instructorLabDetailTextInstruction,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (_canManage) ...<Widget>[
                _buildMiniIconButton(
                  icon: Icons.arrow_upward_rounded,
                  enabled: !isUpdating && index > 0,
                  onTap: () => _moveInstruction(index, -1),
                ),
                const SizedBox(width: 6),
                _buildMiniIconButton(
                  icon: Icons.arrow_downward_rounded,
                  enabled: !isUpdating && index < totalCount - 1,
                  onTap: () => _moveInstruction(index, 1),
                ),
              ],
            ],
          ),
          if (hasText) ...<Widget>[
            const SizedBox(height: 12),
            if (isEditing)
              TextField(
                controller: _controllerForInstruction(instruction),
                maxLines: 4,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: TAColors.cardColor(isDark),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              )
            else
              MarkdownBody(data: instruction.instructionText!.trim()),
          ],
          if (file != null) ...<Widget>[
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                OutlinedButton.icon(
                  onPressed: _canPreviewFile(file)
                      ? () => openDriveFilePreviewScreen(
                          context,
                          file: file,
                          isDark: isDark,
                        )
                      : null,
                  icon: const Icon(Icons.visibility_rounded, size: 18),
                  label: Text(l10n.instructorAssignmentDetailPreview),
                ),
                TextButton.icon(
                  onPressed: () => _openUrl(file.webViewLink),
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: Text(l10n.assignmentOpenFile),
                ),
                TextButton.icon(
                  onPressed: () => _openUrl(file.downloadUrl),
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: Text(l10n.download),
                ),
              ],
            ),
          ],
          if (_canManage) ...<Widget>[
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                if (hasText && !isEditing)
                  TextButton.icon(
                    onPressed: isUpdating
                        ? null
                        : () {
                            setState(() {
                              _editingInstructionIds.add(instruction.id);
                            });
                          },
                    icon: const Icon(Icons.edit_outlined),
                    label: Text(l10n.edit),
                  ),
                if (hasText && isEditing)
                  TextButton.icon(
                    onPressed: isUpdating
                        ? null
                        : () => _saveInstructionEdit(instruction),
                    icon: const Icon(Icons.check_rounded),
                    label: Text(l10n.save),
                  ),
                if (hasText && isEditing)
                  TextButton.icon(
                    onPressed: isUpdating
                        ? null
                        : () {
                            setState(() {
                              _editingInstructionIds.remove(instruction.id);
                              _controllerForInstruction(instruction).text =
                                  instruction.instructionText ?? '';
                            });
                          },
                    icon: const Icon(Icons.close_rounded),
                    label: Text(l10n.cancel),
                  ),
                const Spacer(),
                TextButton.icon(
                  onPressed: isUpdating
                      ? null
                      : () => _deleteInstruction(instruction),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: TAColors.error,
                  ),
                  label: Text(
                    l10n.delete,
                    style: const TextStyle(color: TAColors.error),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAttendanceRecordCard(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    LabAttendanceModel record,
  ) {
    final studentName = _studentName(l10n, record.user, record.userId);
    final email = record.user?.email.trim() ?? '';
    final effectiveStatus =
        _attendanceOverrides[record.userId] ?? record.attendanceStatus;
    final isPending = _attendancePendingIds.contains(record.userId);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: TAColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials(studentName),
                  style: const TextStyle(
                    color: TAColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
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
                        color: TAColors.textPrimaryColor(isDark),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (email.isNotEmpty)
                      Text(
                        email,
                        style: TextStyle(
                          color: TAColors.textSecondaryColor(isDark),
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
              _buildStatusBadge(
                label: _attendanceStatusLabel(l10n, effectiveStatus),
                color: _attendanceStatusColor(effectiveStatus),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                <api.LabAttendanceStatus>[
                      api.LabAttendanceStatus.present,
                      api.LabAttendanceStatus.absent,
                      api.LabAttendanceStatus.excused,
                      api.LabAttendanceStatus.late,
                    ]
                    .map((status) {
                      final selected = effectiveStatus == status;
                      return ChoiceChip(
                        avatar: selected && isPending
                            ? SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _attendanceStatusColor(status),
                                  ),
                                ),
                              )
                            : null,
                        label: Text(_attendanceStatusLabel(l10n, status)),
                        selected: selected,
                        selectedColor: _attendanceStatusColor(
                          status,
                        ).withValues(alpha: 0.16),
                        backgroundColor: isDark
                            ? TAColors.surfaceColor(isDark)
                            : const Color(0xFFF8FAFC),
                        labelStyle: TextStyle(
                          color: selected
                              ? _attendanceStatusColor(status)
                              : TAColors.textSecondaryColor(isDark),
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                        onSelected: !_canManage
                            ? null
                            : (_) => _handleAttendanceSelection(
                                record.userId,
                                status,
                              ),
                      );
                    })
                    .toList(growable: false),
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
    bool compact = false,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 14 : 18),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.68),
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
                width: compact ? 48 : 56,
                height: compact ? 48 : 56,
                decoration: BoxDecoration(
                  color: TAColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  icon,
                  color: TAColors.primary,
                  size: compact ? 22 : 26,
                ),
              ),
              SizedBox(width: compact ? 12 : 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                        color: TAColors.textPrimaryColor(isDark),
                        fontSize: compact ? 15 : 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (subtitle.trim().isNotEmpty) ...<Widget>[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: compact ? 1 : null,
                        overflow: compact ? TextOverflow.ellipsis : null,
                        style: TextStyle(
                          color: TAColors.textSecondaryColor(isDark),
                          fontSize: compact ? 13 : 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 14 : 18),
          child,
        ],
      ),
    );
  }

  Future<void> _handleAttendanceSelection(
    int userId,
    api.LabAttendanceStatus status,
  ) async {
    setState(() {
      _attendanceOverrides[userId] = status;
      _attendancePendingIds.add(userId);
    });

    await context.read<LabDetailCubit>().markAttendance(
      widget.labId,
      <AttendanceData>[
        AttendanceData(userId: userId, attendanceStatus: status),
      ],
    );

    if (!mounted) {
      return;
    }

    final current = context.read<LabDetailCubit>().state;
    if (current is LabDetailLoaded && current.isSubmittingAttendance) {
      return;
    }

    setState(() {
      _attendancePendingIds.remove(userId);
      _attendanceOverrides.remove(userId);
    });
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
        color: isDark ? TAColors.surfaceColor(isDark) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.56),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 20),
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
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
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
        color: isDark ? TAColors.surfaceColor(isDark) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.56),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: TextStyle(
                    color: TAColors.textSecondaryColor(isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
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

  Widget _buildEmptyCourseCard(
    bool isDark, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.68),
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: TAColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: TAColors.primary, size: 34),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: TAColors.textPrimaryColor(isDark),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontSize: 14,
              height: 1.5,
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
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? TAColors.primary
              : (isDark
                    ? TAColors.surfaceColor(isDark)
                    : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : TAColors.textSecondaryColor(isDark),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.18)
                    : TAColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: selected ? Colors.white : TAColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildMetaChip({
    required bool isDark,
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? TAColors.surfaceColor(isDark) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: TAColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: TAColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceSummaryCard({
    required bool isDark,
    required double width,
    required String label,
    required int count,
    required Color color,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: TAColors.textPrimaryColor(isDark),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniIconButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: enabled ? onTap : null,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: enabled
              ? TAColors.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? TAColors.primary : TAColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildInlineEmptyMessage(bool isDark, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? TAColors.surfaceColor(isDark) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: TAColors.textSecondaryColor(isDark),
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildInlineLoading(bool isDark) {
    return Column(
      children: List<Widget>.generate(
        2,
        (index) => Container(
          margin: EdgeInsets.only(bottom: index == 1 ? 0 : 12),
          height: 66,
          decoration: BoxDecoration(
            color: isDark
                ? TAColors.surfaceColor(isDark)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructorMaterialUploadCard(
    bool isDark,
    AppLocalizations l10n,
  ) {
    return _buildSectionCard(
      context,
      isDark,
      title: l10n.instructorLabMaterialTitle,
      subtitle: l10n.instructorLabMaterialSubtitle,
      icon: Icons.folder_shared_outlined,
      child: FilledButton.icon(
        onPressed: _uploadingTaMaterial
            ? null
            : () => _pickAndUploadTaMaterial(context),
        style: FilledButton.styleFrom(
          backgroundColor: TAColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: _uploadingTaMaterial
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.upload_file_rounded),
        label: Text(
          _uploadingTaMaterial
              ? l10n.uploading
              : l10n.instructorLabUploadMaterial,
        ),
      ),
    );
  }

  Widget _buildSubmissionSkeletonCard(bool isDark) {
    Widget block({required double height, double? width}) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark
              ? TAColors.surfaceColor(isDark)
              : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(14),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              block(height: 48, width: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    block(height: 18, width: 180),
                    const SizedBox(height: 8),
                    block(height: 14, width: 130),
                  ],
                ),
              ),
              block(height: 28, width: 92),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              block(height: 32, width: 116),
              block(height: 32, width: 90),
              block(height: 32, width: 82),
            ],
          ),
          const SizedBox(height: 14),
          block(height: 78, width: double.infinity),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(child: block(height: 48)),
              const SizedBox(width: 12),
              Expanded(child: block(height: 48)),
            ],
          ),
        ],
      ),
    );
  }

  List<LabSubmissionModel> _filteredSubmissions(
    List<LabSubmissionModel> source,
  ) {
    return source
        .where((submission) {
          final query = _searchQuery.toLowerCase();
          final studentName =
              '${submission.user?.firstName ?? ''} ${submission.user?.lastName ?? ''}'
                  .trim()
                  .toLowerCase();
          final email = submission.user?.email.toLowerCase() ?? '';
          final matchesSearch =
              query.isEmpty ||
              studentName.contains(query) ||
              email.contains(query) ||
              (submission.submissionText?.toLowerCase().contains(query) ??
                  false);

          final matchesFilter = switch (_submissionFilter) {
            _LabSubmissionFilter.all => true,
            _LabSubmissionFilter.pending => _isPendingSubmission(submission),
            _LabSubmissionFilter.graded => _isGradedSubmission(submission),
            _LabSubmissionFilter.late => submission.isLate,
          };

          return matchesSearch && matchesFilter;
        })
        .toList(growable: false);
  }

  bool _isPendingSubmission(LabSubmissionModel submission) {
    return submission.submissionStatus ==
            assignment_api.SubmissionStatus.submitted ||
        !_isGradedSubmission(submission);
  }

  bool _isGradedSubmission(LabSubmissionModel submission) {
    return submission.submissionStatus ==
        assignment_api.SubmissionStatus.graded;
  }

  String _submissionStatusLabel(
    AppLocalizations l10n,
    LabSubmissionModel submission,
  ) {
    switch (submission.submissionStatus) {
      case assignment_api.SubmissionStatus.graded:
        return l10n.graded;
      case assignment_api.SubmissionStatus.returned:
        return l10n.instructorAssignmentDetailReturned;
      case assignment_api.SubmissionStatus.resubmit:
        return l10n.instructorAssignmentDetailResubmit;
      case assignment_api.SubmissionStatus.submitted:
        return l10n.pending;
      case assignment_api.SubmissionStatus.unknown:
        return l10n.status;
    }
  }

  Color _submissionStatusColor(LabSubmissionModel submission) {
    switch (submission.submissionStatus) {
      case assignment_api.SubmissionStatus.graded:
        return TAColors.success;
      case assignment_api.SubmissionStatus.returned:
      case assignment_api.SubmissionStatus.resubmit:
        return TAColors.warning;
      case assignment_api.SubmissionStatus.submitted:
        return TAColors.accent;
      case assignment_api.SubmissionStatus.unknown:
        return TAColors.textSecondary;
    }
  }

  Color _labStatusColor(api.LabStatus status) {
    switch (status) {
      case api.LabStatus.published:
        return TAColors.success;
      case api.LabStatus.draft:
        return TAColors.warning;
      case api.LabStatus.closed:
        return TAColors.error;
      case api.LabStatus.archived:
        return TAColors.accent;
      case api.LabStatus.unknown:
        return TAColors.textSecondary;
    }
  }

  Color _attendanceStatusColor(api.LabAttendanceStatus status) {
    switch (status) {
      case api.LabAttendanceStatus.present:
        return TAColors.success;
      case api.LabAttendanceStatus.absent:
        return TAColors.error;
      case api.LabAttendanceStatus.excused:
        return TAColors.teal;
      case api.LabAttendanceStatus.late:
        return TAColors.warning;
      case api.LabAttendanceStatus.unknown:
        return TAColors.textSecondary;
    }
  }

  String _attendanceStatusLabel(
    AppLocalizations l10n,
    api.LabAttendanceStatus status,
  ) {
    switch (status) {
      case api.LabAttendanceStatus.present:
        return l10n.taLabPresent;
      case api.LabAttendanceStatus.absent:
        return l10n.taLabAbsent;
      case api.LabAttendanceStatus.excused:
        return l10n.excused;
      case api.LabAttendanceStatus.late:
        return l10n.taLabLateMark;
      case api.LabAttendanceStatus.unknown:
        return l10n.status;
    }
  }

  String _studentName(AppLocalizations l10n, UserInfo? user, int userId) {
    final fullName = '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();
    if (fullName.isNotEmpty) {
      return fullName;
    }
    return '${l10n.student} #$userId';
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

  String _compactDate(BuildContext context, DateTime? value) {
    if (value == null) {
      return AppLocalizations.of(context).assignmentNoDueDate;
    }
    return DateFormat.MMMd(
      Localizations.localeOf(context).toString(),
    ).format(value.toLocal());
  }

  String _compactDateTime(BuildContext context, DateTime value) {
    return DateFormat.MMMd(
      Localizations.localeOf(context).toString(),
    ).format(value.toLocal());
  }

  String _formatDateTime(BuildContext context, DateTime value) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMMMd(locale).add_jm().format(value.toLocal());
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

  String _formatScore(num value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }

  String _initials(String value) {
    final parts = value
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return 'ST';
    }
    if (parts.length == 1) {
      final take = parts.first.length >= 2 ? 2 : parts.first.length;
      return parts.first.substring(0, take).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  bool _canPreviewFile(DriveFileModel file) {
    return _fileExtension(file).toLowerCase() == 'pdf';
  }

  String _fileExtensionLabel(DriveFileModel file, String fallback) {
    final ext = _fileExtension(file);
    return ext.isEmpty ? fallback : ext.toUpperCase();
  }

  String _fileExtension(DriveFileModel file) {
    final name = file.fileName.trim();
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex <= 0 || dotIndex == name.length - 1) {
      return '';
    }
    return name.substring(dotIndex + 1);
  }

  Future<void> _openUrl(String? url) async {
    if (url == null || url.trim().isEmpty) {
      return;
    }
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Future<void> _showSubmissionDetails(
    BuildContext context,
    AppLocalizations l10n,
    LabModel lab,
    LabSubmissionModel submission,
  ) async {
    final isDark = context.read<ThemeBloc>().state.isDark;
    final studentName = _studentName(l10n, submission.user, submission.userId);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: TAColors.cardColor(isDark),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * 0.9,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: 12),
                Container(
                  width: 46,
                  height: 4,
                  decoration: BoxDecoration(
                    color: TAColors.borderColor(isDark),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Flexible(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: TAColors.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    _initials(studentName),
                                    style: const TextStyle(
                                      color: TAColors.primary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        studentName,
                                        style: TextStyle(
                                          color: TAColors.textPrimaryColor(
                                            isDark,
                                          ),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        lab.title,
                                        style: TextStyle(
                                          color: TAColors.textSecondaryColor(
                                            isDark,
                                          ),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
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
                      const SizedBox(height: 16),
                      _buildSectionCard(
                        context,
                        isDark,
                        title: l10n.instructorLabDetailSubmissionSnapshot,
                        subtitle: l10n.instructorLabDetailSubmissionsSubtitle,
                        icon: Icons.assignment_turned_in_rounded,
                        child: Column(
                          children: <Widget>[
                            _buildPillRow(
                              isDark: isDark,
                              icon: Icons.person_rounded,
                              label: l10n.student,
                              value: studentName,
                              color: TAColors.primary,
                            ),
                            const SizedBox(height: 12),
                            _buildPillRow(
                              isDark: isDark,
                              icon: Icons.schedule_rounded,
                              label: l10n.instructorLabDetailSubmittedAt,
                              value: _formatDateTime(
                                context,
                                submission.submittedAt,
                              ),
                              color: TAColors.teal,
                            ),
                            const SizedBox(height: 12),
                            _buildPillRow(
                              isDark: isDark,
                              icon: Icons.stars_rounded,
                              label: l10n.instructorLabDetailCurrentScore,
                              value: submission.score == null
                                  ? l10n.taLabNoScoreYet
                                  : '${_formatScore(submission.score!)} / ${_formatScore(lab.maxScore)}',
                              color: TAColors.warning,
                            ),
                          ],
                        ),
                      ),
                      if (submission.submissionText?.trim().isNotEmpty ==
                          true) ...<Widget>[
                        const SizedBox(height: 16),
                        _buildSectionCard(
                          context,
                          isDark,
                          title: l10n.instructorLabDetailSubmissionText,
                          subtitle: l10n.instructorLabDetailBriefSubtitle,
                          icon: Icons.notes_rounded,
                          child: Text(
                            submission.submissionText!.trim(),
                            style: TextStyle(
                              color: TAColors.textPrimaryColor(isDark),
                              fontSize: 14,
                              height: 1.55,
                            ),
                          ),
                        ),
                      ],
                      if (submission.driveFile != null) ...<Widget>[
                        const SizedBox(height: 16),
                        _buildSectionCard(
                          context,
                          isDark,
                          title: l10n.instructorLabDetailSubmittedFile,
                          subtitle: submission.driveFile!.fileName,
                          icon: Icons.attach_file_rounded,
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: <Widget>[
                              OutlinedButton.icon(
                                onPressed:
                                    _canPreviewFile(submission.driveFile!)
                                    ? () => openDriveFilePreviewScreen(
                                        context,
                                        file: submission.driveFile!,
                                        isDark: isDark,
                                      )
                                    : null,
                                icon: const Icon(Icons.visibility_rounded),
                                label: Text(l10n.instructorLabDetailPreview),
                              ),
                              TextButton.icon(
                                onPressed: () =>
                                    _openUrl(submission.driveFile!.webViewLink),
                                icon: const Icon(Icons.open_in_new_rounded),
                                label: Text(l10n.assignmentOpenFile),
                              ),
                              TextButton.icon(
                                onPressed: () =>
                                    _openUrl(submission.driveFile!.downloadUrl),
                                icon: const Icon(Icons.download_rounded),
                                label: Text(l10n.download),
                              ),
                            ],
                          ),
                        ),
                      ] else if (submission.submissionText?.trim().isNotEmpty !=
                          true) ...<Widget>[
                        const SizedBox(height: 16),
                        _buildInlineEmptyMessage(
                          isDark,
                          l10n.instructorLabDetailNoSubmissionContent,
                        ),
                      ],
                      if (_canManage) ...<Widget>[
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () {
                            Navigator.of(sheetContext).pop();
                            _openGradingPanel(lab, submission);
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: TAColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          icon: Icon(
                            _isGradedSubmission(submission)
                                ? Icons.edit_rounded
                                : Icons.grading_rounded,
                          ),
                          label: Text(
                            _isGradedSubmission(submission)
                                ? l10n.taLabRegrade
                                : l10n.grade,
                          ),
                        ),
                      ],
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
                  color: TAColors.cardColor(
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

  Future<void> _uploadInstructionFile() async {
    final result = await FilePicker.platform.pickFiles(withData: false);
    final filePath = result == null || result.files.isEmpty
        ? null
        : result.files.first.path;
    if (filePath == null || !mounted) {
      return;
    }

    final cubit = context.read<LabDetailCubit>();
    final currentState = cubit.state;
    final loaded = currentState is LabDetailLoaded ? currentState : null;
    final nextOrder = loaded?.instructions?.length ?? 0;

    setState(() => _uploadingInstructionFile = true);
    await cubit.uploadInstructionFile(widget.labId, File(filePath), nextOrder);
    if (!mounted) {
      return;
    }
    setState(() => _uploadingInstructionFile = false);
  }

  Future<void> _addInstruction() async {
    final text = _newInstructionController.text.trim();
    if (text.isEmpty) {
      return;
    }
    final cubit = context.read<LabDetailCubit>();
    final currentState = cubit.state;
    final loaded = currentState is LabDetailLoaded ? currentState : null;
    await cubit.addTextInstruction(
      widget.labId,
      text,
      loaded?.instructions?.length ?? 0,
    );
    if (!mounted) {
      return;
    }
    _newInstructionController.clear();
  }

  TextEditingController _controllerForInstruction(
    LabInstructionModel instruction,
  ) {
    return _editControllers.putIfAbsent(
      instruction.id,
      () => TextEditingController(text: instruction.instructionText ?? ''),
    );
  }

  Future<void> _saveInstructionEdit(LabInstructionModel instruction) async {
    final text = _controllerForInstruction(instruction).text.trim();
    if (text.isEmpty) {
      return;
    }
    await context.read<LabDetailCubit>().updateInstruction(
      widget.labId,
      instruction.id.toString(),
      text,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _editingInstructionIds.remove(instruction.id);
    });
  }

  Future<void> _deleteInstruction(LabInstructionModel instruction) async {
    await context.read<LabDetailCubit>().deleteInstruction(
      widget.labId,
      instruction.id.toString(),
    );
  }

  Future<void> _moveInstruction(int index, int delta) async {
    final currentState = context.read<LabDetailCubit>().state;
    final loaded = currentState is LabDetailLoaded ? currentState : null;
    final instructions = loaded?.instructions;
    if (instructions == null) {
      return;
    }
    final nextIndex = index + delta;
    if (nextIndex < 0 || nextIndex >= instructions.length) {
      return;
    }

    final reordered = List<LabInstructionModel>.from(instructions);
    final item = reordered.removeAt(index);
    reordered.insert(nextIndex, item);

    await context.read<LabDetailCubit>().reorderInstructions(
      widget.labId,
      reordered.map((item) => item.id.toString()).toList(growable: false),
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
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: TAColors.error),
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
    _restoreTaLabsListIfAvailable();
    context.go('/ta/labs');
  }

  Future<void> _openEditLabForm(LabModel lab) async {
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
        role: 'ta',
      ),
    ];
    final messenger = ScaffoldMessenger.of(context);

    final result = await Navigator.of(context).push<LabModel>(
      MaterialPageRoute<LabModel>(
        builder: (_) => LabEditorScreen(
          role: LabComposerRole.ta,
          courses: courseOptions,
          labService: widget.labService,
          existingLab: lab,
          onSave: (payload) async {
            final result = await widget.labService.update(
              lab.id.isNotEmpty ? lab.id : lab.labId,
              payload,
            );
            return LabEditorSaveResult(
              lab: result.data,
              errorMessage: result.isSuccess
                  ? null
                  : (result.error?.message ?? l10n.taLabPermissionEditDenied),
            );
          },
        ),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(_labSavedMessage(l10n, result.status.value)),
        behavior: SnackBarBehavior.floating,
      ),
    );

    await context.read<LabDetailCubit>().initialize(widget.labId);
  }

  String _labSavedMessage(AppLocalizations l10n, Object? rawStatus) {
    final status = rawStatus?.toString().trim().toLowerCase();
    return switch (status) {
      'published' => l10n.taLabsCreatedPublished,
      'draft' => l10n.taLabsCreatedDraft,
      _ => l10n.taLabsCreatedDraft,
    };
  }
}

class _LabDetailTabsHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _LabDetailTabsHeaderDelegate({
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
  bool shouldRebuild(covariant _LabDetailTabsHeaderDelegate oldDelegate) {
    return height != oldDelegate.height || child != oldDelegate.child;
  }
}

class _LabDetailLoadingView extends StatelessWidget {
  const _LabDetailLoadingView({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: <Widget>[
        _buildTopBarSkeleton(),
        const SizedBox(height: 16),
        _buildHeaderSkeleton(context),
        const SizedBox(height: 16),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: TAColors.cardColor(isDark),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: TAColors.borderColor(isDark).withValues(alpha: 0.68),
            ),
          ),
        ),
        const SizedBox(height: 16),
        AcademicListSkeleton(
          isDark: isDark,
          itemCount: 3,
          topPadding: 0,
          bottomPadding: 0,
          sliverFriendly: true,
        ),
      ],
    );
  }

  Widget _buildTopBarSkeleton() {
    return Row(
      children: <Widget>[
        _block(height: 48, width: 48),
        const SizedBox(width: 12),
        Expanded(child: _block(height: 24)),
        const SizedBox(width: 12),
        _block(height: 48, width: 48),
        const SizedBox(width: 10),
        _block(height: 48, width: 48),
      ],
    );
  }

  Widget _buildHeaderSkeleton(BuildContext context) {
    final r = context.responsive;

    return Container(
      decoration: BoxDecoration(
        gradient: TAColors.headerGradient,
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              _block(
                height: 48,
                width: 48,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _block(
                  height: 24,
                  width: 220,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _block(
            height: 16,
            width: double.infinity,
            color: Colors.white.withValues(alpha: 0.86),
          ),
          const SizedBox(height: 6),
          _block(
            height: 16,
            width: r.screenWidth * 0.46,
            color: Colors.white.withValues(alpha: 0.86),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _block(
                height: 32,
                width: 92,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              _block(
                height: 32,
                width: 90,
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List<Widget>.generate(
              4,
              (_) => _statPlaceholder((r.screenWidth - 32 - 24) / 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statPlaceholder(double width) {
    return Container(
      width: width,
      height: 62,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _block({
    required double height,
    double? width,
    Color color = const Color(0xFFE5E7EB),
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}
