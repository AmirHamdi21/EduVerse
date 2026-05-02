import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/course_structure/course_structure_bloc.dart';
import '../../../bloc/course_structure/course_structure_event.dart';
import '../../../bloc/instructor/instructor_courses_bloc.dart';
import '../../../bloc/instructor/instructor_courses_event.dart';
import '../../../bloc/instructor/instructor_courses_state.dart';
import '../../../bloc/materials/materials_bloc.dart';
import '../../../bloc/materials/materials_event.dart';
import '../../../bloc/materials/materials_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../common/utils/instructor_courses_theme.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/core/schedule_model.dart';
import '../../../models/assignments/assignment_model.dart' as api_assignment;
import '../../../models/instructor/instructor_course_model.dart';
import '../../../models/instructor/teaching_course_model.dart';
import '../../../models/labs/lab_model.dart';
import '../../../models/materials/announcement_model.dart' as course_announcement;
import '../../../models/materials/course_material_model.dart';
import '../../../models/materials/material_bundle_model.dart';
import '../../../services/api/assignment_service.dart';
import '../../../services/api/communication_service.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/lab_service.dart';
import '../../../services/api/material_service.dart';
import '../../../services/storage_service.dart';
import '../../../widgets/shared/course_details/course_detail_search_tab.dart';
import '../materials/material_preview_screen.dart';
import '../../../widgets/instructor/course_management/course_management_barrel.dart';
import '../../../widgets/student/course_details/video_player_widget.dart';

class CourseManagementScreen extends StatefulWidget {
  final InstructorCourseModel? course;
  final int? courseId;
  final StorageService? storageService;

  const CourseManagementScreen({
    super.key,
    this.course,
    this.courseId,
    this.storageService,
  });

  @override
  State<CourseManagementScreen> createState() => _CourseManagementScreenState();
}

class _CourseManagementScreenState extends State<CourseManagementScreen>
    with SingleTickerProviderStateMixin {
  static const int _courseContentTabIndex = 1;
  static const int _assignmentsTabIndex = 3;
  static const int _labsTabIndex = 4;
  static const int _announcementsTabIndex = 5;
  static const int _studentsTabIndex = 8;

  late final StorageService _storageService;
  final ScrollController _outerScrollController = ScrollController();

  late TabController _tabController;
  late InstructorCourseModel _course;
  int? _resolvedCourseId;
  int? _requestedStudentsCourseId;
  int? _requestedMetricsCourseId;
  bool _skipNextStudentsTabAutoRefresh = false;
  String? _materialsFailureMessage;
  List<String> _failedMaterialIds = const <String>[];
  bool _retryingFailedMaterials = false;
  bool _hasCourseAccess = true;
  bool _canDeleteCourse = true;
  List<SectionStudentModel> _persistedStudents = const <SectionStudentModel>[];
  bool _isPreparingExit = false;
  String? _selectedHeroMaterialId;

  @override
  void initState() {
    super.initState();
    _storageService = widget.storageService ?? StorageService();
    _tabController = TabController(
      length: 9,
      vsync: this,
      initialIndex: _courseContentTabIndex,
    );
    _tabController.addListener(_handleTabControllerChanged);
    _resolveRoleAccess();
    _course =
        widget.course ??
        InstructorCourseModel(
          id: (widget.courseId ?? 0).toString(),
          code: 'COURSE',
          name: 'Course',
          totalStudents: 0,
          colorValue: 0xFF155CFB,
        );
    _resolvedCourseId = widget.courseId ?? int.tryParse(_course.id);

    if (_resolvedCourseId != null && _resolvedCourseId! > 0) {
      context.read<InstructorCoursesBloc>().add(
        SelectCourse(_resolvedCourseId!),
      );
      context.read<MaterialsBloc>().add(LoadMaterials(_resolvedCourseId!));
      context.read<CourseStructureBloc>().add(
        LoadStructure(_resolvedCourseId!),
      );
      context.read<InstructorCoursesBloc>().add(
        LoadDeadlines(_resolvedCourseId!),
      );
    }

    final current = context.read<InstructorCoursesBloc>().state;
    if (current is InstructorCoursesLoaded) {
      _requestCourseDetailLoads(current);
      return;
    }

    context.read<InstructorCoursesBloc>().add(const LoadTeachingCourses());
  }

  @override
  void didUpdateWidget(covariant CourseManagementScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.course != null && widget.course!.id != _course.id) {
      _course = widget.course!;
    }

    final incomingCourseId =
        widget.courseId ?? int.tryParse(widget.course?.id ?? '');
    if (incomingCourseId == _resolvedCourseId) {
      return;
    }

    _resolvedCourseId = incomingCourseId;
    _requestedStudentsCourseId = null;
    _requestedMetricsCourseId = null;
    _persistedStudents = const <SectionStudentModel>[];

    if (_resolvedCourseId == null || _resolvedCourseId! <= 0) {
      return;
    }

    context.read<InstructorCoursesBloc>().add(SelectCourse(_resolvedCourseId!));
    context.read<MaterialsBloc>().add(LoadMaterials(_resolvedCourseId!));
    context.read<CourseStructureBloc>().add(LoadStructure(_resolvedCourseId!));
    context.read<InstructorCoursesBloc>().add(
      LoadDeadlines(_resolvedCourseId!),
    );

    final current = context.read<InstructorCoursesBloc>().state;
    if (current is InstructorCoursesLoaded) {
      _requestCourseDetailLoads(current);
    }
  }

  Future<void> _resolveRoleAccess() async {
    try {
      final user = await _storageService.getUserData();
      final roleNames =
          user?.roles
              .map((role) => role.roleName.toLowerCase().trim())
              .toSet() ??
          <String>{};

      if (roleNames.isEmpty) {
        if (!mounted) {
          return;
        }
        setState(() {
          _hasCourseAccess = true;
          _canDeleteCourse = true;
        });
        return;
      }

      final hasInstructorAccess = roleNames.any(
        (role) =>
            role == 'instructor' ||
            role == 'ta' ||
            role == 'teaching_assistant' ||
            role == 'admin' ||
            role == 'it_admin' ||
            role == 'it admin',
      );

      final canDeleteCourse = roleNames.any(
        (role) =>
            role == 'instructor' ||
            role == 'admin' ||
            role == 'it_admin' ||
            role == 'it admin',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _hasCourseAccess = hasInstructorAccess;
        _canDeleteCourse = canDeleteCourse;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _hasCourseAccess = true;
        _canDeleteCourse = true;
      });
    }
  }

  Widget _buildAccessDeniedState(bool isDark, AppLocalizations l10n) {
    return Scaffold(
      backgroundColor: CMColors.bg(isDark),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 44,
                color: CMColors.error,
              ),
              const SizedBox(height: 12),
              Text(
                'Access Denied',
                style: TextStyle(
                  color: CMColors.text(isDark),
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'You do not have permission to access course management.',
                textAlign: TextAlign.center,
                style: TextStyle(color: CMColors.textSub(isDark)),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: Text(l10n.back),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _outerScrollController.dispose();
    _tabController.removeListener(_handleTabControllerChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        if (!_hasCourseAccess) {
          return _buildAccessDeniedState(isDark, l10n);
        }

        final instructorState = context.watch<InstructorCoursesBloc>().state;
        final materialsState = context.watch<MaterialsBloc>().state;

        final teachingCourse = _resolveTeachingCourse(instructorState);
        final deadlines = _resolveDeadlines(instructorState);
        final students = _resolveVisibleStudents(instructorState);
        final engagementMetrics = _resolveEngagementMetrics(instructorState);
        final materials = _resolveMaterials(materialsState);
        final bundles = _resolveBundles(materialsState);
        final materialCountsByWeek = _buildMaterialCountsByWeek(materials);
        final studentsCount = _resolveStudentsCount(teachingCourse, students);
        final overviewStudentsCount = (teachingCourse?.enrolledCount ?? 0) > 0
            ? teachingCourse!.enrolledCount
            : studentsCount;
        final hasValidSection = _hasValidSection(teachingCourse);
        final displayCourse = _buildDisplayCourse(
          teachingCourse,
          materials,
          deadlines,
          students,
        );

        final heroVideo = _resolveHeroVideo(materials);
        final showHeroSkeleton = _shouldShowHeroSkeleton(
          materialsState,
          heroVideo,
        );
        final tabs = _buildTabs(l10n);

        return MultiBlocListener(
          listeners: [
            BlocListener<InstructorCoursesBloc, InstructorCoursesState>(
              listener: (context, state) {
                if (state is InstructorCoursesLoaded) {
                  final teachingCourse = _resolveTeachingCourse(state);
                  if (teachingCourse != null &&
                      state.selectedSectionId == teachingCourse.sectionId &&
                      state.studentsStatus == CourseStudentsStatus.loaded) {
                    _persistedStudents = List<SectionStudentModel>.from(
                      state.sectionStudents,
                    );
                  }
                  _requestCourseDetailLoads(state);
                }
              },
            ),
            BlocListener<MaterialsBloc, MaterialsState>(
              listener: _onMaterialsStateChanged,
            ),
          ],
          child: PopScope<Object?>(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop) {
                _handleBackPressed();
              }
            },
            child: Scaffold(
              backgroundColor: InstructorCoursesTheme.scaffoldBackground(
                isDark,
              ),
              floatingActionButton: _isPreparingExit
                  ? null
                  : _buildFAB(isDark, l10n),
              body: Container(
                decoration: InstructorCoursesTheme.scaffoldDecoration(isDark),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final maxWidth = InstructorCoursesTheme.maxContentWidth(
                      constraints.maxWidth,
                    );
                    final screenPadding = InstructorCoursesTheme.screenPadding(
                      constraints.maxWidth,
                    );

                    return IgnorePointer(
                      ignoring: _isPreparingExit,
                      child: NestedScrollView(
                        controller: _outerScrollController,
                        physics: _isPreparingExit
                            ? const NeverScrollableScrollPhysics()
                            : null,
                        headerSliverBuilder: (context, innerBoxIsScrolled) => [
                      SliverToBoxAdapter(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: maxWidth),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                screenPadding.left,
                                10,
                                screenPadding.right,
                                0,
                              ),
                              child: _buildTopChrome(
                                context: context,
                                isDark: isDark,
                                l10n: l10n,
                                displayCourse: displayCourse,
                                showHeroSkeleton: showHeroSkeleton,
                                heroVideo: heroVideo,
                                materials: materials,
                                studentsCount: overviewStudentsCount,
                                assignmentsCount: deadlines
                                    .where(
                                      (item) =>
                                          item.type == DeadlineType.assignment,
                                    )
                                    .length,
                                averageGrade: teachingCourse?.averageGrade,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _CourseManagementTabsHeaderDelegate(
                          height: 86,
                          child: Container(
                            color: InstructorCoursesTheme.scaffoldBackground(
                              isDark,
                            ),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: maxWidth),
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    screenPadding.left,
                                    12,
                                    screenPadding.right,
                                    12,
                                  ),
                                  child: _buildTabBar(
                                    isDark: isDark,
                                    tabs: tabs,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                        body: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: maxWidth),
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                            _InstructorCourseSearchTab(
                              isDark: isDark,
                              l10n: l10n,
                              courseId: _resolvedCourseId,
                              onOpenContent: () =>
                                  _switchTab(_courseContentTabIndex),
                              onOpenAssignments: () =>
                                  _switchTab(_assignmentsTabIndex),
                              onOpenLabs: () => _switchTab(_labsTabIndex),
                              onOpenAnnouncements: () =>
                                  _switchTab(_announcementsTabIndex),
                            ),
                            _buildMaterialsTabContent(
                              materialsState: materialsState,
                              materials: materials,
                              displayCourse: displayCourse,
                              bundles: bundles,
                              materialCountsByWeek: materialCountsByWeek,
                              isDark: isDark,
                              l10n: l10n,
                            ),
                            _buildOverviewTabContent(
                              instructorState: instructorState,
                              materialsState: materialsState,
                              course: displayCourse,
                              deadlines: deadlines,
                              studentsCount: overviewStudentsCount,
                              averageGrade: teachingCourse?.averageGrade,
                              engagementMetrics: engagementMetrics,
                              schedules:
                                  teachingCourse?.section.schedules ??
                                  const <ScheduleModel>[],
                              isDark: isDark,
                              l10n: l10n,
                            ),
                            AssignmentsTab(
                              isDark: isDark,
                              l10n: l10n,
                              courseId: _resolvedCourseId,
                            ),
                            LabsTab(
                              isDark: isDark,
                              l10n: l10n,
                              courseId: _resolvedCourseId,
                            ),
                            AnnouncementsTab(
                              isDark: isDark,
                              l10n: l10n,
                              courseId: _resolvedCourseId,
                            ),
                            DiscussionsTab(
                              isDark: isDark,
                              l10n: l10n,
                              courseId: _resolvedCourseId,
                              initialCourse: teachingCourse,
                            ),
                            GradingTab(
                              isDark: isDark,
                              l10n: l10n,
                              courseId: _resolvedCourseId,
                            ),
                            _buildStudentsTabContent(
                              instructorState: instructorState,
                              students: students,
                              hasValidSection: hasValidSection,
                              isDark: isDark,
                              l10n: l10n,
                            ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<_CourseManagementTabSpec> _buildTabs(AppLocalizations l10n) {
    return <_CourseManagementTabSpec>[
      _CourseManagementTabSpec(
        icon: Icons.search_rounded,
        label: l10n.search,
        compact: true,
      ),
      _CourseManagementTabSpec(
        icon: Icons.video_library_outlined,
        label: l10n.studentCourseDetailCourseContent,
      ),
      _CourseManagementTabSpec(
        icon: Icons.grid_view_rounded,
        label: l10n.overview,
      ),
      _CourseManagementTabSpec(
        icon: Icons.assignment_outlined,
        label: l10n.assignments,
      ),
      _CourseManagementTabSpec(icon: Icons.science_outlined, label: l10n.labs),
      _CourseManagementTabSpec(
        icon: Icons.campaign_outlined,
        label: l10n.announcements,
      ),
      _CourseManagementTabSpec(
        icon: Icons.forum_outlined,
        label: l10n.discussions,
      ),
      _CourseManagementTabSpec(
        icon: Icons.grading_outlined,
        label: l10n.gradingCenter,
      ),
      _CourseManagementTabSpec(
        icon: Icons.people_outline_rounded,
        label: l10n.students,
      ),
    ];
  }

  Widget _buildTabBar({
    required bool isDark,
    required List<_CourseManagementTabSpec> tabs,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: InstructorCoursesTheme.cardBackground(isDark),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: InstructorCoursesTheme.borderColor(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: TabBar(
        controller: _tabController,
        onTap: _handleTabSelected,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          gradient: InstructorCoursesTheme.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: InstructorCoursesTheme.brandBlue.withValues(alpha: 0.22),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: InstructorCoursesTheme.primaryText(isDark),
        labelPadding: const EdgeInsets.symmetric(horizontal: 6),
        padding: EdgeInsets.zero,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        tabs: tabs
            .map((tab) {
              return Tab(
                height: 52,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: tab.compact ? 10 : 12,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(tab.icon, size: 18),
                      if (!tab.compact) ...[
                        const SizedBox(width: 8),
                        Text(
                          tab.label,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }

  Widget _buildTopChrome({
    required BuildContext context,
    required bool isDark,
    required AppLocalizations l10n,
    required InstructorCourseModel displayCourse,
    required bool showHeroSkeleton,
    required CourseMaterialModel? heroVideo,
    required List<CourseMaterialModel> materials,
    required int studentsCount,
    required int assignmentsCount,
    required double? averageGrade,
  }) {
    final actionButtonColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SafeArea(
          bottom: false,
          child: Row(
            children: [
              _buildTopIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                isDark: isDark,
                backgroundColor: actionButtonColor,
                onTap: _handleBackPressed,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  displayCourse.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: InstructorCoursesTheme.primaryText(isDark),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildTopIconButton(
                icon: Icons.settings_rounded,
                isDark: isDark,
                backgroundColor: actionButtonColor,
                onTap: () => _showCourseSettings(context, isDark),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (showHeroSkeleton)
          _buildHeroSkeleton(isDark)
        else if (heroVideo != null)
          _buildVideoHero(
            isDark: isDark,
            displayCourse: displayCourse,
            heroVideo: heroVideo,
            materials: materials,
            l10n: l10n,
          )
        else
          _buildFallbackHero(
            isDark: isDark,
            displayCourse: displayCourse,
            studentsCount: studentsCount,
            assignmentsCount: assignmentsCount,
            materialsCount: materials.length,
            averageGrade: averageGrade,
            l10n: l10n,
          ),
      ],
    );
  }

  Widget _buildTopIconButton({
    required IconData icon,
    required bool isDark,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFD8E1EF),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(
          icon,
          size: 18,
          color: isDark ? Colors.white : const Color(0xFF111827),
        ),
      ),
    );
  }

  List<CourseMaterialModel> _orderedCourseMaterials(
    List<CourseMaterialModel> materials,
  ) {
    final ordered = List<CourseMaterialModel>.from(materials);
    ordered.sort((a, b) {
      final weekCompare = (a.weekNumber ?? 0).compareTo(b.weekNumber ?? 0);
      if (weekCompare != 0) {
        return weekCompare;
      }

      final orderCompare = (a.orderIndex ?? 0).compareTo(b.orderIndex ?? 0);
      if (orderCompare != 0) {
        return orderCompare;
      }

      return a.createdAt.compareTo(b.createdAt);
    });
    return ordered;
  }

  List<CourseMaterialModel> _videoMaterials(
    List<CourseMaterialModel> materials,
  ) {
    return _orderedCourseMaterials(
      materials,
    ).where(_isVideoMaterial).toList(growable: false);
  }

  bool _isVideoMaterial(CourseMaterialModel material) {
    final type = material.materialType.trim().toLowerCase();
    final hasPlayableSource =
        (material.youtubeVideoId?.trim().isNotEmpty ?? false) ||
        (material.externalUrl?.trim().isNotEmpty ?? false) ||
        (material.url?.trim().isNotEmpty ?? false);

    return (type == 'video' || type == 'lecture') && hasPlayableSource;
  }

  CourseMaterialModel? _resolveHeroVideo(List<CourseMaterialModel> materials) {
    final videos = _videoMaterials(materials);
    if (videos.isEmpty) {
      return null;
    }

    if (_selectedHeroMaterialId != null) {
      for (final material in videos) {
        if (material.materialId == _selectedHeroMaterialId) {
          return material;
        }
      }
    }

    return videos.first;
  }

  bool _isMaterialsLoading(MaterialsState state) {
    return state is MaterialsInitial || state is MaterialsLoading;
  }

  bool _shouldShowHeroSkeleton(
    MaterialsState materialsState,
    CourseMaterialModel? heroVideo,
  ) {
    if (_isPreparingExit) {
      return true;
    }

    if (heroVideo != null) {
      return false;
    }

    return _isMaterialsLoading(materialsState) &&
        _resolveMaterials(materialsState).isEmpty;
  }

  void _selectHeroVideo(CourseMaterialModel material) {
    if (_isPreparingExit || !_isVideoMaterial(material)) {
      return;
    }

    setState(() => _selectedHeroMaterialId = material.materialId);
    if (_outerScrollController.hasClients) {
      _outerScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _playNextVideo(List<CourseMaterialModel> materials) {
    final videos = _videoMaterials(materials);
    if (videos.isEmpty) {
      return;
    }

    final current = _resolveHeroVideo(materials);
    final currentIndex = current == null
        ? -1
        : videos.indexWhere((item) => item.materialId == current.materialId);

    final nextIndex = currentIndex >= 0 && currentIndex < videos.length - 1
        ? currentIndex + 1
        : 0;
    _selectHeroVideo(videos[nextIndex]);
  }

  Widget _buildHeroSkeleton(bool isDark) {
    final surfaceColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFE5E7EB);

    Widget skeletonBox({
      double? width,
      required double height,
      double radius = 16,
    }) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        skeletonBox(height: 220, radius: 30),
        const SizedBox(height: 14),
        skeletonBox(width: 180, height: 14, radius: 999),
        const SizedBox(height: 10),
        skeletonBox(width: double.infinity, height: 28, radius: 12),
        const SizedBox(height: 8),
        skeletonBox(width: 240, height: 28, radius: 12),
      ],
    );
  }

  Widget _buildVideoHero({
    required bool isDark,
    required InstructorCourseModel displayCourse,
    required CourseMaterialModel heroVideo,
    required List<CourseMaterialModel> materials,
    required AppLocalizations l10n,
  }) {
    final weekLabel = heroVideo.weekNumber != null && heroVideo.weekNumber! > 0
        ? '${l10n.week} ${heroVideo.weekNumber}'
        : displayCourse.code;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Stack(
              children: [
                VideoPlayerWidget(
                  courseId: _resolvedCourseId,
                  material: heroVideo,
                ),
                Positioned(
                  top: 14,
                  right: 14,
                  child: _buildVideoHeroSquareButton(
                    icon: Icons.arrow_forward_ios_rounded,
                    onTap: () => _playNextVideo(materials),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                heroVideo.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: InstructorCoursesTheme.primaryText(isDark),
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              if (weekLabel.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  weekLabel,
                  style: TextStyle(
                    color: InstructorCoursesTheme.secondaryText(isDark),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVideoHeroSquareButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            gradient: InstructorCoursesTheme.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }

  Widget _buildFallbackHero({
    required bool isDark,
    required InstructorCourseModel displayCourse,
    required int studentsCount,
    required int assignmentsCount,
    required int materialsCount,
    required double? averageGrade,
    required AppLocalizations l10n,
  }) {
    final description = displayCourse.description.trim().isNotEmpty
        ? displayCourse.description.trim()
        : l10n.instructorCourseDetailHeroSubtitle;

    final metrics = <_HeroMetric>[
      _HeroMetric(
        icon: Icons.people_alt_outlined,
        value: '$studentsCount',
        label: l10n.students,
      ),
      _HeroMetric(
        icon: Icons.assignment_outlined,
        value: '$assignmentsCount',
        label: l10n.assignments,
      ),
      _HeroMetric(
        icon: Icons.video_library_outlined,
        value: '$materialsCount',
        label: l10n.courseMaterials,
      ),
      _HeroMetric(
        icon: Icons.insights_outlined,
        value: averageGrade == null
            ? '--'
            : '${averageGrade.toStringAsFixed(1)}%',
        label: l10n.averageGrade,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: isDark
            ? InstructorCoursesTheme.headerGradientDark
            : InstructorCoursesTheme.heroGradientLight,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: InstructorCoursesTheme.brandBlue.withValues(alpha: 0.20),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildHeroChip(
                label: displayCourse.code,
                icon: Icons.sell_outlined,
              ),
              _buildHeroChip(
                label: displayCourse.isActive
                    ? l10n.activeLabel
                    : l10n.archived,
                icon: displayCourse.isActive
                    ? Icons.verified_outlined
                    : Icons.archive_outlined,
              ),
              if (displayCourse.semester.trim().isNotEmpty)
                _buildHeroChip(
                  label: displayCourse.semester.trim(),
                  icon: Icons.calendar_today_outlined,
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            displayCourse.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFE5EEFF),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 940
                  ? 4
                  : constraints.maxWidth >= 620
                  ? 2
                  : 2;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: metrics.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: constraints.maxWidth >= 900
                      ? 2.1
                      : constraints.maxWidth >= 620
                      ? 1.75
                      : 1.35,
                ),
                itemBuilder: (context, index) {
                  return _buildHeroMetricCard(metrics[index]);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeroChip({required String label, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroMetricCard(_HeroMetric metric) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(metric.icon, size: 17, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  metric.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  metric.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFDCE9FF),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsTabContent({
    required MaterialsState materialsState,
    required List<CourseMaterialModel> materials,
    required InstructorCourseModel displayCourse,
    required List<MaterialBundleModel> bundles,
    required Map<int, int> materialCountsByWeek,
    required bool isDark,
    required AppLocalizations l10n,
  }) {
    if (_isMaterialsLoading(materialsState) && materials.isEmpty) {
      return _buildDetailTabSkeleton(
        isDark,
        itemHeights: const <double>[72, 140, 140],
      );
    }

    return MaterialsTab(
      materials: materials.isNotEmpty
          ? materials.map(_mapCourseMaterialToLegacy).toList()
          : displayCourse.materials,
      courseMaterials: materials,
      bundles: bundles,
      materialCountsByWeek: materialCountsByWeek,
      partialFailureMessage: _materialsFailureMessage,
      failedMaterialIds: _failedMaterialIds,
      onRetryFailedMaterials: _retryFailedMaterials,
      onToggleMaterialVisibility: _toggleMaterialVisibility,
      onEditMaterial: _editMaterial,
      onDeleteMaterial: _deleteMaterial,
      onToggleBundleVisibility: _toggleBundleVisibility,
      onEditBundle: _editBundle,
      onDeleteBundle: _deleteBundle,
      onViewMaterial: (material) => _handleViewMaterial(material, materials),
      isDark: isDark,
      l10n: l10n,
    );
  }

  Widget _buildOverviewTabContent({
    required InstructorCoursesState instructorState,
    required MaterialsState materialsState,
    required InstructorCourseModel course,
    required List<DeadlineCardModel> deadlines,
    required int studentsCount,
    required double? averageGrade,
    required EngagementMetricsModel? engagementMetrics,
    required List<ScheduleModel> schedules,
    required bool isDark,
    required AppLocalizations l10n,
  }) {
    final isInitialLoad =
        instructorState is! InstructorCoursesLoaded &&
        _isMaterialsLoading(materialsState) &&
        deadlines.isEmpty &&
        engagementMetrics == null &&
        schedules.isEmpty;

    if (isInitialLoad) {
      return _buildDetailTabSkeleton(
        isDark,
        itemHeights: const <double>[180, 180, 120, 160],
      );
    }

    return OverviewTab(
      course: course,
      isDark: isDark,
      l10n: l10n,
      courseId: _resolvedCourseId,
      deadlines: deadlines,
      studentsCount: studentsCount,
      averageGrade: averageGrade,
      engagementMetrics: engagementMetrics,
      schedules: schedules,
      onCreateAssignment: () => context.push('/instructor/assignments/create'),
      onUploadMaterial: () => context.push('/instructor/upload-materials'),
      onPostAnnouncement: () => context.push('/instructor/announcements'),
    );
  }

  Widget _buildStudentsTabContent({
    required InstructorCoursesState instructorState,
    required List<SectionStudentModel> students,
    required bool hasValidSection,
    required bool isDark,
    required AppLocalizations l10n,
  }) {
    final isStudentsLoading =
        instructorState is InstructorCoursesLoaded &&
        instructorState.studentsStatus == CourseStudentsStatus.loading &&
        students.isEmpty;

    if (isStudentsLoading) {
      return _buildDetailTabSkeleton(
        isDark,
        itemHeights: const <double>[56, 120, 120, 120],
      );
    }

    return StudentsTab(
      students: students,
      isDark: isDark,
      l10n: l10n,
      onRefreshRequested: _refreshStudents,
      emptyStateTitleOverride: hasValidSection ? null : 'No section assigned',
      emptyStateSubtitleOverride: hasValidSection
          ? null
          : 'Assign a valid section to load enrolled students.',
    );
  }

  Widget _buildDetailTabSkeleton(
    bool isDark, {
    required List<double> itemHeights,
  }) {
    final surfaceColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFE5E7EB);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: itemHeights.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        return Container(
          height: itemHeights[index],
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(24),
          ),
        );
      },
    );
  }

  TeachingCourseModel? _resolveTeachingCourse(InstructorCoursesState state) {
    final courseId = _resolvedCourseId;
    if (courseId == null ||
        courseId <= 0 ||
        state is! InstructorCoursesLoaded) {
      return null;
    }

    for (final course in state.courses) {
      if (course.courseId == courseId) {
        return course;
      }
    }

    return null;
  }

  List<DeadlineCardModel> _resolveDeadlines(InstructorCoursesState state) {
    if (state is InstructorCoursesLoaded) {
      return state.deadlines;
    }
    if (state is DeadlinesLoaded) {
      return state.deadlines;
    }
    return const <DeadlineCardModel>[];
  }

  List<SectionStudentModel> _resolveVisibleStudents(
    InstructorCoursesState state,
  ) {
    if (state is InstructorCoursesLoaded) {
      final teachingCourse = _resolveTeachingCourse(state);
      if (teachingCourse != null &&
          state.selectedSectionId == teachingCourse.sectionId) {
        if (state.studentsStatus == CourseStudentsStatus.loaded) {
          return state.sectionStudents;
        }

        if (_persistedStudents.isNotEmpty) {
          return _persistedStudents;
        }

        return state.sectionStudents;
      }
    }

    return _persistedStudents;
  }

  EngagementMetricsModel? _resolveEngagementMetrics(
    InstructorCoursesState state,
  ) {
    if (state is InstructorCoursesLoaded) {
      return state.engagementMetrics;
    }
    return null;
  }

  List<CourseMaterialModel> _resolveMaterials(MaterialsState state) {
    if (state is MaterialsLoaded && state.courseId == _resolvedCourseId) {
      return state.materials;
    }
    return const <CourseMaterialModel>[];
  }

  List<MaterialBundleModel> _resolveBundles(MaterialsState state) {
    if (state is MaterialsLoaded && state.courseId == _resolvedCourseId) {
      return state.bundles;
    }
    return const <MaterialBundleModel>[];
  }

  Map<int, int> _buildMaterialCountsByWeek(
    List<CourseMaterialModel> materials,
  ) {
    final counts = <int, int>{};
    for (final material in materials) {
      final week = material.weekNumber;
      if (week == null || week <= 0) {
        continue;
      }

      counts[week] = (counts[week] ?? 0) + 1;
    }

    return counts;
  }

  bool _hasValidSection(TeachingCourseModel? teachingCourse) {
    return teachingCourse != null && teachingCourse.sectionId > 0;
  }

  int _resolveStudentsCount(
    TeachingCourseModel? teachingCourse,
    List<SectionStudentModel> students,
  ) {
    if (students.isNotEmpty) {
      return students.length;
    }

    if (teachingCourse == null) {
      return _course.totalStudents;
    }

    return teachingCourse.enrolledCount > 0
        ? teachingCourse.enrolledCount
        : teachingCourse.section.currentEnrollment;
  }

  void _onMaterialsStateChanged(BuildContext context, MaterialsState state) {
    if (!mounted) {
      return;
    }

    if (state is MaterialsLoaded && _retryingFailedMaterials) {
      setState(() {
        _retryingFailedMaterials = false;
        _materialsFailureMessage = null;
        _failedMaterialIds = const <String>[];
      });
      return;
    }

    if (state is! MaterialsError) {
      return;
    }

    if (_retryingFailedMaterials) {
      setState(() {
        _retryingFailedMaterials = false;
      });
    }

    final messenger = ScaffoldMessenger.of(context);
    final canRetryDelete =
        state.failedMaterialIds.isNotEmpty &&
        state.message.toLowerCase().contains('materials deleted');

    if (canRetryDelete) {
      setState(() {
        _materialsFailureMessage = state.message;
        _failedMaterialIds = List<String>.from(state.failedMaterialIds);
      });

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(state.message),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _retryFailedMaterials,
            ),
          ),
        );
      return;
    }

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(state.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _handleViewMaterial(
    MaterialModel material,
    List<CourseMaterialModel> materials,
  ) {
    if (material.type.toLowerCase() != 'video' &&
        material.type.toLowerCase() != 'lecture') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MaterialPreviewScreen(material: material),
        ),
      );
      return;
    }

    final rawUrl = material.fileUrl.trim();
    if (rawUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No video URL available for this material.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    CourseMaterialModel? resolvedMaterial;
    for (final item in materials) {
      if (item.materialId == material.id) {
        resolvedMaterial = item;
        break;
      }
    }

    resolvedMaterial ??= CourseMaterialModel(
      materialId: material.id.isNotEmpty
          ? material.id
          : 'material-${material.title.hashCode}',
      courseId: (_resolvedCourseId ?? 0).toString(),
      materialType: material.type,
      title: material.title,
      url: rawUrl,
      externalUrl: rawUrl,
      isPublished: material.isPublished,
      createdAt: material.uploadedAt ?? DateTime.now(),
    );

    if (!_isVideoMaterial(resolvedMaterial)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not prepare this video for inline playback.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    _selectHeroVideo(resolvedMaterial);
  }

  void _toggleMaterialVisibility(MaterialModel material) {
    final courseId = _resolvedCourseId;
    if (courseId == null || courseId <= 0 || material.id.isEmpty) {
      return;
    }

    context.read<MaterialsBloc>().add(
      ToggleMaterialVisibility(
        courseId: courseId,
        materialId: material.id,
        isPublished: !material.isPublished,
      ),
    );
  }

  void _editMaterial(MaterialModel material) {
    final courseId = _resolvedCourseId;
    if (courseId == null || courseId <= 0 || material.id.isEmpty) {
      return;
    }

    final controller = TextEditingController(text: material.title);

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit material title'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final title = controller.text.trim();
                if (title.isEmpty) {
                  return;
                }

                context.read<MaterialsBloc>().add(
                  UpdateMaterial(
                    courseId: courseId,
                    materialId: material.id,
                    payload: <String, dynamic>{'title': title},
                  ),
                );
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteMaterial(MaterialModel material) {
    if (material.id.isEmpty) {
      return;
    }

    _confirmDeleteMaterials(
      materialIds: <String>[material.id],
      title: 'Delete material?',
      body: 'This action cannot be undone.',
    );
  }

  void _toggleBundleVisibility(MaterialBundleModel bundle) {
    final courseId = _resolvedCourseId;
    if (courseId == null || courseId <= 0 || bundle.materials.isEmpty) {
      return;
    }

    final publishAll = bundle.materials.any(
      (material) => !material.isPublished,
    );
    for (final material in bundle.materials) {
      context.read<MaterialsBloc>().add(
        ToggleMaterialVisibility(
          courseId: courseId,
          materialId: material.materialId,
          isPublished: publishAll,
        ),
      );
    }
  }

  void _editBundle(MaterialBundleModel bundle) {
    final courseId = _resolvedCourseId;
    final ids = bundle.materials
        .map((material) => material.materialId)
        .where((id) => id.isNotEmpty)
        .toList(growable: false);

    if (courseId == null || courseId <= 0 || ids.isEmpty) {
      return;
    }

    final controller = TextEditingController(text: bundle.baseTitle);

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit bundle title'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Bundle title'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final title = controller.text.trim();
                if (title.isEmpty) {
                  return;
                }

                context.read<MaterialsBloc>().add(
                  UpdateMaterial(
                    courseId: courseId,
                    materialId: ids.first,
                    materialIds: ids,
                    payload: <String, dynamic>{'title': title},
                  ),
                );
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteBundle(MaterialBundleModel bundle) {
    final ids = bundle.materials
        .map((material) => material.materialId)
        .where((id) => id.isNotEmpty)
        .toList(growable: false);

    if (ids.isEmpty) {
      return;
    }

    _confirmDeleteMaterials(
      materialIds: ids,
      title: 'Delete bundle?',
      body:
          'This will delete all ${ids.length} materials in the bundle. This action cannot be undone.',
    );
  }

  void _confirmDeleteMaterials({
    required List<String> materialIds,
    required String title,
    required String body,
  }) {
    final courseId = _resolvedCourseId;
    if (courseId == null || courseId <= 0 || materialIds.isEmpty) {
      return;
    }

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.read<MaterialsBloc>().add(
                  DeleteMaterial(courseId: courseId, materialIds: materialIds),
                );
              },
              style: FilledButton.styleFrom(backgroundColor: CMColors.error),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _retryFailedMaterials() {
    final courseId = _resolvedCourseId;
    if (courseId == null || courseId <= 0 || _failedMaterialIds.isEmpty) {
      return;
    }

    final retryIds = List<String>.from(_failedMaterialIds);
    setState(() {
      _retryingFailedMaterials = true;
      _materialsFailureMessage = null;
      _failedMaterialIds = const <String>[];
    });

    context.read<MaterialsBloc>().add(
      DeleteMaterial(courseId: courseId, materialIds: retryIds),
    );
  }

  InstructorCourseModel _buildDisplayCourse(
    TeachingCourseModel? teachingCourse,
    List<CourseMaterialModel> materials,
    List<DeadlineCardModel> deadlines,
    List<SectionStudentModel> students,
  ) {
    if (teachingCourse == null) {
      return _course;
    }

    return _course.copyWith(
      id: teachingCourse.courseId.toString(),
      code: teachingCourse.course.courseCode,
      name: teachingCourse.course.courseName,
      description: teachingCourse.course.description ?? '',
      totalStudents: _resolveStudentsCount(teachingCourse, students),
      semester: teachingCourse.semester.name,
      materials: materials.map(_mapCourseMaterialToLegacy).toList(),
      assignments: List<AssignmentModel>.generate(
        deadlines.where((item) => item.type == DeadlineType.assignment).length,
        (index) => AssignmentModel(
          id: 'assignment-$index',
          title: 'Assignment',
          dueDate: DateTime.now(),
          totalPoints: 100,
          submissionsCount: 0,
          gradedCount: 0,
        ),
      ),
    );
  }

  void _requestCourseDetailLoads(InstructorCoursesLoaded state) {
    final courseId = _resolvedCourseId;
    if (courseId == null || courseId <= 0) {
      return;
    }

    final teachingCourse = _resolveTeachingCourse(state);
    if (teachingCourse == null) {
      return;
    }

    if (_requestedStudentsCourseId != courseId) {
      _requestedStudentsCourseId = courseId;
      _refreshStudents();
    }

    if (_requestedMetricsCourseId != courseId) {
      _requestedMetricsCourseId = courseId;
      final enrolledCount = _resolveStudentsCount(
        teachingCourse,
        const <SectionStudentModel>[],
      );

      context.read<InstructorCoursesBloc>().add(
        LoadEngagementMetrics(
          courseId: courseId,
          totalEnrolledStudents: enrolledCount,
        ),
      );
    }
  }

  void _handleTabSelected(int index) {
    if (index != _studentsTabIndex) {
      return;
    }

    _skipNextStudentsTabAutoRefresh = true;
    _refreshStudents();
  }

  void _handleTabControllerChanged() {
    if (_tabController.indexIsChanging ||
        _tabController.index != _studentsTabIndex) {
      return;
    }

    if (_skipNextStudentsTabAutoRefresh) {
      _skipNextStudentsTabAutoRefresh = false;
      return;
    }

    _refreshStudents();
  }

  void _switchTab(int index) {
    if (_tabController.index == index) {
      return;
    }
    _tabController.animateTo(index);
  }

  void _refreshStudents() {
    final courseId = _resolvedCourseId;
    if (courseId == null || courseId <= 0) {
      return;
    }

    context.read<InstructorCoursesBloc>().add(LoadCourseStudents(courseId));
  }

  void _handleBackPressed() {
    if (_isPreparingExit) {
      return;
    }

    setState(() => _isPreparingExit = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/instructor/courses');
      }
    });
  }

  Widget _buildFAB(bool isDark, AppLocalizations l10n) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddOptions(context, isDark, l10n),
      backgroundColor: CMColors.primary,
      elevation: 4,
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: Text(
        l10n.add,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showCourseSettings(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: CMColors.cardColor(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: CMColors.borderColor(isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _buildSheetItem(
              ctx,
              Icons.edit_outlined,
              l10n.editCourse,
              CMColors.primary,
              isDark,
            ),
            if (_canDeleteCourse)
              _buildSheetItem(
                ctx,
                Icons.archive_outlined,
                l10n.archiveCourse,
                CMColors.warning,
                isDark,
              ),
            if (_canDeleteCourse)
              _buildSheetItem(
                ctx,
                Icons.delete_outline,
                l10n.delete,
                CMColors.error,
                isDark,
              ),
          ],
        ),
      ),
    );
  }

  void _showAddOptions(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: CMColors.cardColor(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: CMColors.borderColor(isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _buildSheetItem(
              ctx,
              Icons.assignment_add,
              l10n.createAssignment,
              CMColors.primary,
              isDark,
              onTap: () {
                Navigator.pop(ctx);
                context.push('/instructor/assignments/create');
              },
            ),
            _buildSheetItem(
              ctx,
              Icons.upload_file_rounded,
              l10n.uploadMaterial,
              CMColors.success,
              isDark,
              onTap: () {
                Navigator.pop(ctx);
                context.push('/instructor/upload-materials');
              },
            ),
            _buildSheetItem(
              ctx,
              Icons.campaign_rounded,
              l10n.postAnnouncement,
              CMColors.warning,
              isDark,
              onTap: () {
                Navigator.pop(ctx);
                context.push('/instructor/announcements');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetItem(
    BuildContext ctx,
    IconData icon,
    String label,
    Color color,
    bool isDark, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: CMColors.text(isDark),
          fontWeight: FontWeight.w500,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap ?? () => Navigator.pop(ctx),
    );
  }

  MaterialModel _mapCourseMaterialToLegacy(CourseMaterialModel material) {
    return MaterialModel(
      id: material.materialId,
      title: material.title,
      type: material.materialType,
      fileSize: _formatBytes(material.file?.fileSize),
      fileUrl: material.url ?? material.externalUrl ?? '',
      isPublished: material.isPublished,
      uploadedAt: material.createdAt,
    );
  }

  String _formatBytes(int? bytes) {
    if (bytes == null || bytes <= 0) {
      return '';
    }
    if (bytes < 1024) {
      return '$bytes B';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _InstructorCourseSearchTab extends StatefulWidget {
  const _InstructorCourseSearchTab({
    required this.isDark,
    required this.l10n,
    required this.courseId,
    required this.onOpenContent,
    required this.onOpenAssignments,
    required this.onOpenLabs,
    required this.onOpenAnnouncements,
  });

  final bool isDark;
  final AppLocalizations l10n;
  final int? courseId;
  final VoidCallback onOpenContent;
  final VoidCallback onOpenAssignments;
  final VoidCallback onOpenLabs;
  final VoidCallback onOpenAnnouncements;

  @override
  State<_InstructorCourseSearchTab> createState() =>
      _InstructorCourseSearchTabState();
}

class _InstructorCourseSearchTabState extends State<_InstructorCourseSearchTab> {
  late final MaterialService _materialService;
  late final AssignmentService _assignmentService;
  late final LabService _labService;
  late final CommunicationService _communicationService;
  CancelToken? _cancelToken;
  List<CourseDetailSearchEntry> _entries = const <CourseDetailSearchEntry>[];

  @override
  void initState() {
    super.initState();
    final coreApiClient = CoreApiClient();
    _materialService = MaterialService(coreApiClient: coreApiClient);
    _assignmentService = AssignmentService(coreApiClient: coreApiClient);
    _labService = LabService(coreApiClient: coreApiClient);
    _communicationService = CommunicationService(coreApiClient: coreApiClient);
    _loadEntries();
  }

  @override
  void didUpdateWidget(covariant _InstructorCourseSearchTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.courseId != widget.courseId) {
      _loadEntries();
    }
  }

  @override
  void dispose() {
    _cancelToken?.cancel();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    final courseId = widget.courseId;
    _cancelToken?.cancel();

    if (courseId == null || courseId <= 0) {
      if (!mounted) {
        return;
      }
      setState(() => _entries = const <CourseDetailSearchEntry>[]);
      return;
    }

    final cancelToken = CancelToken();
    _cancelToken = cancelToken;

    try {
      final results = await Future.wait<Object>([
        _materialService.getMaterials(courseId, cancelToken: cancelToken),
        _assignmentService.getAll(
          courseId: courseId,
          limit: 100,
          cancelToken: cancelToken,
        ),
        _labService.getAll(
          courseId: courseId,
          limit: 100,
          cancelToken: cancelToken,
        ),
        _communicationService.getAnnouncementsByCourseId(
          courseId,
          cancelToken: cancelToken,
        ),
      ]);

      if (!mounted || cancelToken.isCancelled) {
        return;
      }

      final materials = results[0] as List<CourseMaterialModel>;
      final dynamic assignmentsResult = results[1];
      final dynamic labsResult = results[2];
      final announcements =
          results[3] as List<course_announcement.AnnouncementModel>;

      final List<api_assignment.AssignmentModel> assignmentItems =
          assignmentsResult.isSuccess && assignmentsResult.data != null
          ? assignmentsResult.data!.data
          : const <api_assignment.AssignmentModel>[];
      final List<LabModel> labItems =
          labsResult.isSuccess && labsResult.data != null
          ? labsResult.data!
          : const <LabModel>[];
      final List<course_announcement.AnnouncementModel> announcementItems =
          announcements;

      setState(() {
        _entries = [
          ...materials.map(
            (item) => CourseDetailSearchEntry(
              title: item.title,
              subtitle: widget.l10n.studentCourseDetailSearchMaterialsLabel,
              description: item.description,
              icon: Icons.video_library_outlined,
              onTap: widget.onOpenContent,
            ),
          ),
          ...assignmentItems.map(
            (item) => CourseDetailSearchEntry(
              title: item.title,
              subtitle: widget.l10n.assignments,
              description: item.description,
              icon: Icons.assignment_outlined,
              onTap: widget.onOpenAssignments,
            ),
          ),
          ...labItems.map(
            (item) => CourseDetailSearchEntry(
              title: item.title,
              subtitle: widget.l10n.labs,
              description: item.description,
              icon: Icons.science_outlined,
              onTap: widget.onOpenLabs,
            ),
          ),
          ...announcementItems.map(
            (item) => CourseDetailSearchEntry(
              title: item.title,
              subtitle: widget.l10n.announcements,
              description: item.content,
              icon: Icons.campaign_outlined,
              onTap: widget.onOpenAnnouncements,
            ),
          ),
        ];
      });
    } catch (_) {
      if (!mounted || cancelToken.isCancelled) {
        return;
      }
      setState(() => _entries = const <CourseDetailSearchEntry>[]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: CourseDetailSearchTab(
        isDark: widget.isDark,
        accentColor: CMColors.primary,
        hintText: widget.l10n.studentCourseDetailSearchHint,
        promptTitle: widget.l10n.studentCourseDetailSearchPromptTitle,
        promptSubtitle: widget.l10n.studentCourseDetailSearchPromptSubtitle,
        noResultsTitle: widget.l10n.studentCourseDetailSearchNoResultsTitle,
        noResultsSubtitle: widget.l10n.studentCourseDetailSearchNoResultsSubtitle,
        entries: _entries,
      ),
    );
  }
}

class _CourseManagementTabSpec {
  final IconData icon;
  final String label;
  final bool compact;

  const _CourseManagementTabSpec({
    required this.icon,
    required this.label,
    this.compact = false,
  });
}

class _HeroMetric {
  final IconData icon;
  final String value;
  final String label;

  const _HeroMetric({
    required this.icon,
    required this.value,
    required this.label,
  });
}

class _CourseManagementTabsHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  const _CourseManagementTabsHeaderDelegate({
    required this.height,
    required this.child,
  });

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
    covariant _CourseManagementTabsHeaderDelegate oldDelegate,
  ) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
