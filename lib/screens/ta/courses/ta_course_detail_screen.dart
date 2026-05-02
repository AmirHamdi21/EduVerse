import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/ta/ta_courses_cubit.dart';
import '../../../bloc/ta/ta_courses_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../common/utils/ta_courses_theme.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/assignments/assignment_model.dart';
import '../../../models/instructor/instructor_course_model.dart'
    show MaterialModel, SectionStudentModel;
import '../../../models/instructor/teaching_course_model.dart';
import '../../../models/labs/lab_model.dart';
import '../../../models/materials/announcement_model.dart' as course_announcement;
import '../../../models/materials/course_material_model.dart';
import '../../../services/api/assignment_service.dart';
import '../../../services/api/communication_service.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/lab_service.dart';
import '../../../services/api/material_service.dart';
import '../../../screens/instructor/materials/material_preview_screen.dart';
import '../../../widgets/shared/course_details/course_detail_search_tab.dart';
import '../../../widgets/student/course_details/video_player_widget.dart';
import '../../../widgets/ta/courses/ta_students_tab.dart';
import '../../../widgets/ta/shared/ta_colors.dart';
import '../announcements/ta_announcement_manager_screen.dart';
import '../assignments/ta_assignments_screen.dart';
import '../attendance/ta_attendance_screen.dart';
import '../discussions/ta_course_discussions_screen.dart';
import '../grading/ta_grading_center_screen.dart';
import '../labs/ta_labs_list_screen.dart';

class TACourseDetailScreen extends StatefulWidget {
  final String courseId;

  const TACourseDetailScreen({super.key, required this.courseId});

  @override
  State<TACourseDetailScreen> createState() => _TACourseDetailScreenState();
}

class _TACourseDetailScreenState extends State<TACourseDetailScreen>
    with SingleTickerProviderStateMixin {
  static const int _searchTabIndex = 0;
  static const int _courseContentTabIndex = 1;
  static const int _overviewTabIndex = 2;
  static const int _assignmentsTabIndex = 3;
  static const int _labsTabIndex = 4;
  static const int _announcementsTabIndex = 5;
  static const int _discussionsTabIndex = 6;
  static const int _gradingTabIndex = 7;
  static const int _attendanceTabIndex = 8;
  static const int _studentsTabIndex = 9;

  late final TabController _tabController;
  final ScrollController _outerScrollController = ScrollController();
  final Set<int> _loadedTabs = <int>{};
  String? _selectedHeroMaterialId;
  bool _isPreparingExit = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 10,
      vsync: this,
      initialIndex: _courseContentTabIndex,
    );
    _tabController.addListener(_handleTabChanged);

    final cubit = context.read<TACoursesCubit>();
    if (cubit.state.coursesStatus
        is! TASubTabLoaded<List<TeachingCourseModel>>) {
      cubit.fetchTACourses();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final course = _findCourse(cubit.state);
      if (course != null) {
        _loadTabData(_courseContentTabIndex, course);
      }
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChanged);
    _tabController.dispose();
    _outerScrollController.dispose();
    super.dispose();
  }

  void _handleTabChanged() {
    if (_tabController.indexIsChanging) {
      return;
    }

    final course = _findCourse(context.read<TACoursesCubit>().state);
    if (course != null) {
      _loadTabData(_tabController.index, course);
    }
  }

  void _switchTab(int index) {
    if (_tabController.index == index) {
      return;
    }
    _tabController.animateTo(index);
  }

  void _loadTabData(int tabIndex, TeachingCourseModel course) {
    if (_isPreparingExit) {
      return;
    }

    if (_loadedTabs.contains(tabIndex)) {
      return;
    }
    _loadedTabs.add(tabIndex);

    final cubit = context.read<TACoursesCubit>();
    switch (tabIndex) {
      case _searchTabIndex:
        break;
      case _courseContentTabIndex:
        cubit.fetchCourseMaterials(course.courseId);
        break;
      case _overviewTabIndex:
        cubit.fetchCourseOverview(course.courseId);
        break;
      case _assignmentsTabIndex:
        cubit.fetchCourseAssignments(course.courseId);
        break;
      case _labsTabIndex:
        cubit.fetchCourseSectionsAndLabs(course.courseId);
        break;
      case _announcementsTabIndex:
        break;
      case _discussionsTabIndex:
        break;
      case _gradingTabIndex:
        cubit.fetchPendingGrading(course.courseId);
        break;
      case _attendanceTabIndex:
        cubit.fetchAttendanceSummary(course.courseId);
        break;
      case _studentsTabIndex:
        cubit.fetchSectionStudents(course.sectionId);
        break;
    }
  }

  TeachingCourseModel? _findCourse(TACoursesState state) {
    final status = state.coursesStatus;
    if (status is TASubTabLoaded<List<TeachingCourseModel>>) {
      final id = int.tryParse(widget.courseId);
      if (id == null) {
        return null;
      }
      try {
        return status.data.firstWhere(
          (tc) => tc.sectionId == id || tc.courseId == id,
        );
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  int _studentCountFor(TACoursesState state, TeachingCourseModel course) {
    return state.sectionStudentCounts[course.sectionId] ?? course.enrolledCount;
  }

  List<CourseMaterialModel> _materialsForCourse(
    TACoursesState state,
    TeachingCourseModel course,
  ) {
    final materialsState = state.materialsData;
    if (materialsState is! TASubTabLoaded<List<CourseMaterialModel>>) {
      return const <CourseMaterialModel>[];
    }

    final filtered = materialsState.data
        .where((item) => item.courseId.toString() == course.courseId.toString())
        .toList(growable: false);

    if (filtered.isNotEmpty) {
      return filtered;
    }

    return materialsState.data;
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

  bool _isVideoMaterial(CourseMaterialModel material) {
    final type = material.materialType.trim().toLowerCase();
    final hasPlayableSource =
        (material.youtubeVideoId?.trim().isNotEmpty ?? false) ||
        (material.externalUrl?.trim().isNotEmpty ?? false) ||
        (material.url?.trim().isNotEmpty ?? false);

    return (type == 'video' || type == 'lecture') && hasPlayableSource;
  }

  List<CourseMaterialModel> _videoMaterials(
    List<CourseMaterialModel> materials,
  ) {
    return _orderedCourseMaterials(
      materials,
    ).where(_isVideoMaterial).toList(growable: false);
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

  bool _isMaterialsPending(TACoursesState state) {
    return state.materialsData is TASubTabInitial<List<CourseMaterialModel>> ||
        state.materialsData is TASubTabLoading<List<CourseMaterialModel>>;
  }

  bool _shouldShowHeroSkeleton(
    TACoursesState state,
    List<CourseMaterialModel> materials,
    CourseMaterialModel? heroVideo,
  ) {
    if (_isPreparingExit) {
      return true;
    }

    if (heroVideo != null) {
      return false;
    }

    return _isMaterialsPending(state) && materials.isEmpty;
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          backgroundColor: TACoursesTheme.scaffoldBackground(isDark),
          body: DecoratedBox(
            decoration: TACoursesTheme.scaffoldDecoration(isDark),
            child: SafeArea(
              child: BlocBuilder<TACoursesCubit, TACoursesState>(
                builder: (context, taState) {
                  return _buildBody(isDark, l10n, taState);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(bool isDark, AppLocalizations l10n, TACoursesState state) {
    final status = state.coursesStatus;

    if (status is TASubTabLoading<List<TeachingCourseModel>>) {
      return _buildLoadingState(isDark);
    }

    if (status is TASubTabError<List<TeachingCourseModel>>) {
      return _buildErrorState(isDark, l10n, status.message);
    }

    final course = _findCourse(state);
    if (course == null) {
      return _buildEmptyState(isDark, l10n);
    }

    if (!_loadedTabs.contains(_tabController.index)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadTabData(_tabController.index, course);
        }
      });
    }

    final materials = _materialsForCourse(state, course);
    final heroVideo = _resolveHeroVideo(materials);
    final showHeroSkeleton = _shouldShowHeroSkeleton(
      state,
      materials,
      heroVideo,
    );
    final assignmentsCount =
        state.assignmentsData is TASubTabLoaded<List<AssignmentModel>>
        ? (state.assignmentsData as TASubTabLoaded<List<AssignmentModel>>)
              .data
              .length
        : (state.overviewData is TASubTabLoaded<TACourseOverview>
              ? (state.overviewData as TASubTabLoaded<TACourseOverview>)
                    .data
                    .totalAssignments
              : 0);
    final labsCount =
        state.sectionsLabsData is TASubTabLoaded<TACourseSectionsLabs>
        ? (state.sectionsLabsData as TASubTabLoaded<TACourseSectionsLabs>)
              .data
              .labs
              .length
        : (state.overviewData is TASubTabLoaded<TACourseOverview>
              ? (state.overviewData as TASubTabLoaded<TACourseOverview>)
                    .data
                    .totalLabs
              : 0);
    final tabs = _buildTabs(l10n);

    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBackPressed();
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = TACoursesTheme.maxContentWidth(constraints.maxWidth);
          final screenPadding = TACoursesTheme.screenPadding(
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
                          isDark: isDark,
                          l10n: l10n,
                          course: course,
                          showHeroSkeleton: showHeroSkeleton,
                          heroVideo: heroVideo,
                          materials: materials,
                          studentsCount: _studentCountFor(state, course),
                          assignmentsCount: assignmentsCount,
                          labsCount: labsCount,
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TACourseTabsHeaderDelegate(
                    height: 86,
                    child: Container(
                      color: TACoursesTheme.scaffoldBackground(isDark),
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
                            child: _buildTabBar(isDark: isDark, tabs: tabs),
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
                      _TACourseSearchTab(
                        isDark: isDark,
                        l10n: l10n,
                        courseId: course.courseId,
                        onOpenContent: () => _switchTab(_courseContentTabIndex),
                        onOpenAssignments: () =>
                            _switchTab(_assignmentsTabIndex),
                        onOpenLabs: () => _switchTab(_labsTabIndex),
                        onOpenAnnouncements: () =>
                            _switchTab(_announcementsTabIndex),
                      ),
                      _buildCourseContentTab(
                        isDark,
                        l10n,
                        course,
                        state,
                        materials,
                      ),
                      _buildOverviewTab(isDark, l10n, course, state, materials),
                      _buildAssignmentsTab(isDark, l10n, state, course),
                      _buildLabsTab(isDark, l10n, state, course),
                      _buildAnnouncementsTab(isDark, l10n, course),
                      _buildDiscussionsTab(isDark, l10n, course),
                      TAGradingCenterScreen(
                        courseId: course.courseId,
                        embedded: true,
                      ),
                      _buildAttendanceTab(isDark, l10n, state),
                      _buildStudentsTab(isDark, l10n, state, course),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<_TACourseDetailTabSpec> _buildTabs(AppLocalizations l10n) {
    return <_TACourseDetailTabSpec>[
      _TACourseDetailTabSpec(
        icon: Icons.search_rounded,
        label: l10n.search,
        compact: true,
      ),
      _TACourseDetailTabSpec(
        icon: Icons.video_library_outlined,
        label: l10n.studentCourseDetailCourseContent,
      ),
      _TACourseDetailTabSpec(
        icon: Icons.grid_view_rounded,
        label: l10n.overview,
      ),
      _TACourseDetailTabSpec(
        icon: Icons.assignment_outlined,
        label: l10n.assignments,
      ),
      _TACourseDetailTabSpec(icon: Icons.science_outlined, label: l10n.labs),
      _TACourseDetailTabSpec(
        icon: Icons.campaign_outlined,
        label: l10n.announcements,
      ),
      _TACourseDetailTabSpec(
        icon: Icons.forum_outlined,
        label: l10n.discussions,
      ),
      _TACourseDetailTabSpec(
        icon: Icons.grading_outlined,
        label: l10n.gradingCenter,
      ),
      _TACourseDetailTabSpec(
        icon: Icons.fact_check_outlined,
        label: l10n.attendance,
      ),
      _TACourseDetailTabSpec(
        icon: Icons.people_outline_rounded,
        label: l10n.students,
      ),
    ];
  }

  Widget _buildTopChrome({
    required bool isDark,
    required AppLocalizations l10n,
    required TeachingCourseModel course,
    required bool showHeroSkeleton,
    required CourseMaterialModel? heroVideo,
    required List<CourseMaterialModel> materials,
    required int studentsCount,
    required int assignmentsCount,
    required int labsCount,
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
                  course.course.courseName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: TACoursesTheme.primaryText(isDark),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildTopIconButton(
                icon: isDark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                isDark: isDark,
                backgroundColor: actionButtonColor,
                onTap: () {
                  context.read<ThemeBloc>().add(const ToggleThemeEvent());
                },
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
            course: course,
            heroVideo: heroVideo,
            materials: materials,
            l10n: l10n,
          )
        else
          _buildFallbackHero(
            isDark: isDark,
            course: course,
            studentsCount: studentsCount,
            assignmentsCount: assignmentsCount,
            materialsCount: materials.length,
            labsCount: labsCount,
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

  Widget _buildVideoHero({
    required bool isDark,
    required TeachingCourseModel course,
    required CourseMaterialModel heroVideo,
    required List<CourseMaterialModel> materials,
    required AppLocalizations l10n,
  }) {
    final weekLabel = heroVideo.weekNumber != null && heroVideo.weekNumber! > 0
        ? '${l10n.week} ${heroVideo.weekNumber}'
        : course.course.courseCode;

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
                  courseId: course.courseId,
                  material: heroVideo,
                  enableEmbeddedPlayer: !_isPreparingExit,
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
                  color: TACoursesTheme.primaryText(isDark),
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
                    color: TACoursesTheme.secondaryText(isDark),
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
            gradient: TACoursesTheme.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }

  Widget _buildFallbackHero({
    required bool isDark,
    required TeachingCourseModel course,
    required int studentsCount,
    required int assignmentsCount,
    required int materialsCount,
    required int labsCount,
    required AppLocalizations l10n,
  }) {
    final description = (course.course.description ?? '').trim().isNotEmpty
        ? course.course.description!.trim()
        : l10n.taCourseDetailHeroSubtitle;

    final metrics = <_TADetailHeroMetric>[
      _TADetailHeroMetric(
        icon: Icons.people_alt_outlined,
        value: '$studentsCount',
        label: l10n.students,
      ),
      _TADetailHeroMetric(
        icon: Icons.assignment_outlined,
        value: '$assignmentsCount',
        label: l10n.assignments,
      ),
      _TADetailHeroMetric(
        icon: Icons.video_library_outlined,
        value: '$materialsCount',
        label: l10n.courseMaterials,
      ),
      _TADetailHeroMetric(
        icon: Icons.science_outlined,
        value: '$labsCount',
        label: l10n.labs,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: isDark
            ? TACoursesTheme.headerGradientDark
            : TACoursesTheme.heroGradientLight,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: TACoursesTheme.brandPrimary.withValues(alpha: 0.20),
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
                label: course.course.courseCode,
                icon: Icons.sell_outlined,
              ),
              _buildHeroChip(
                label: course.course.status == 'archived'
                    ? l10n.archived
                    : l10n.activeLabel,
                icon: course.course.status == 'archived'
                    ? Icons.archive_outlined
                    : Icons.verified_outlined,
              ),
              _buildHeroChip(
                label: course.semester.name,
                icon: Icons.calendar_today_outlined,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            course.course.courseName,
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
              color: Color(0xFFEDE9FE),
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
                  childAspectRatio: constraints.maxWidth >= 620 ? 2.35 : 2.1,
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

  Widget _buildHeroMetricCard(_TADetailHeroMetric metric) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(metric.icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  metric.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  metric.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFEDE9FE),
                    fontSize: 12,
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

  Widget _buildTabBar({
    required bool isDark,
    required List<_TACourseDetailTabSpec> tabs,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: TACoursesTheme.cardBackground(isDark),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: TACoursesTheme.borderColor(isDark)),
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
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          gradient: TACoursesTheme.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: TACoursesTheme.brandPrimary.withValues(alpha: 0.22),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: TACoursesTheme.primaryText(isDark),
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

  Widget _buildCourseContentTab(
    bool isDark,
    AppLocalizations l10n,
    TeachingCourseModel course,
    TACoursesState state,
    List<CourseMaterialModel> materials,
  ) {
    return switch (state.materialsData) {
      TASubTabInitial<List<CourseMaterialModel>>() ||
      TASubTabLoading<List<CourseMaterialModel>>() => _buildDetailTabSkeleton(
        isDark,
        itemHeights: const <double>[72, 150, 150],
      ),
      TASubTabError<List<CourseMaterialModel>>(message: final message) =>
        _buildInlineErrorState(isDark, message),
      TASubTabLoaded<List<CourseMaterialModel>>() =>
        materials.isEmpty
            ? _buildCenteredEmptyState(
                isDark: isDark,
                icon: Icons.video_library_outlined,
                title: l10n.courseMaterials,
                message: l10n.taCourseDetailContentEmpty,
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: _buildMaterialWeekCards(
                  isDark: isDark,
                  l10n: l10n,
                  course: course,
                  materials: materials,
                ),
              ),
    };
  }

  List<Widget> _buildMaterialWeekCards({
    required bool isDark,
    required AppLocalizations l10n,
    required TeachingCourseModel course,
    required List<CourseMaterialModel> materials,
  }) {
    final grouped = <int, List<CourseMaterialModel>>{};
    for (final material in _orderedCourseMaterials(materials)) {
      final weekNumber = material.weekNumber ?? 0;
      grouped
          .putIfAbsent(weekNumber, () => <CourseMaterialModel>[])
          .add(material);
    }

    final weeks = grouped.keys.toList()
      ..sort((a, b) {
        if (a == 0 && b != 0) {
          return 1;
        }
        if (b == 0 && a != 0) {
          return -1;
        }
        return a.compareTo(b);
      });

    return List<Widget>.generate(weeks.length, (index) {
      final weekNumber = weeks[index];
      final weekMaterials =
          grouped[weekNumber] ?? const <CourseMaterialModel>[];
      return Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF101828) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: TACoursesTheme.borderColor(isDark)),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,
          ),
          child: ExpansionTile(
            initiallyExpanded: index == 0,
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            shape: const Border(),
            collapsedShape: const Border(),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.calendar_view_week_rounded,
                color: Color(0xFF2563EB),
                size: 18,
              ),
            ),
            title: Text(
              weekNumber > 0
                  ? '${l10n.week} $weekNumber'
                  : l10n.taCourseDetailOtherMaterials,
              style: TextStyle(
                color: TACoursesTheme.primaryText(isDark),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              '${weekMaterials.length} ${weekMaterials.length == 1 ? 'material' : 'materials'}',
              style: TextStyle(
                color: TACoursesTheme.secondaryText(isDark),
                fontSize: 12,
              ),
            ),
            children: weekMaterials
                .map(
                  (material) => _buildMaterialListTile(
                    isDark: isDark,
                    l10n: l10n,
                    material: material,
                    course: course,
                  ),
                )
                .toList(growable: false),
          ),
        ),
      );
    });
  }

  Widget _buildMaterialListTile({
    required bool isDark,
    required AppLocalizations l10n,
    required CourseMaterialModel material,
    required TeachingCourseModel course,
  }) {
    final isVideo = _isVideoMaterial(material);
    final accent = _materialColor(material.materialType);

    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131E31) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accent.withValues(alpha: isDark ? 0.26 : 0.18),
        ),
      ),
      child: ListTile(
        onTap: () => _openMaterial(material, course),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: isDark ? 0.22 : 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            _materialIcon(material.materialType),
            color: accent,
            size: 22,
          ),
        ),
        title: Text(
          material.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: TACoursesTheme.primaryText(isDark),
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildInlineChip(
                isDark: isDark,
                label: material.materialType.toUpperCase(),
              ),
              _buildInlineChip(
                isDark: isDark,
                label: '${material.viewCount ?? 0} views',
              ),
              if (!isVideo)
                _buildInlineChip(
                  isDark: isDark,
                  label: '${material.downloadCount ?? 0} downloads',
                ),
            ],
          ),
        ),
        trailing: Icon(
          isVideo
              ? Icons.play_circle_outline_rounded
              : Icons.open_in_new_rounded,
          color: accent,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildInlineChip({required bool isDark, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: TACoursesTheme.secondaryText(isDark),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildOverviewTab(
    bool isDark,
    AppLocalizations l10n,
    TeachingCourseModel course,
    TACoursesState state,
    List<CourseMaterialModel> materials,
  ) {
    if (state.overviewData is TASubTabInitial<TACourseOverview> ||
        state.overviewData is TASubTabLoading<TACourseOverview>) {
      return _buildDetailTabSkeleton(
        isDark,
        itemHeights: const <double>[180, 180, 140],
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCourseOverviewCard(isDark, l10n, course, state),
          const SizedBox(height: 16),
          _buildCourseProgressCard(isDark, l10n, course, state, materials),
          const SizedBox(height: 16),
          if (state.overviewData is TASubTabLoaded<TACourseOverview>)
            _buildOverviewMetricsCard(isDark, l10n, course, state),
          if (state.overviewData is TASubTabLoaded<TACourseOverview>)
            const SizedBox(height: 16),
          _buildOverviewActionsCard(isDark, l10n),
        ],
      ),
    );
  }

  Widget _buildCourseOverviewCard(
    bool isDark,
    AppLocalizations l10n,
    TeachingCourseModel course,
    TACoursesState state,
  ) {
    final items = <({IconData icon, String label, String value, Color color})>[
      (
        icon: Icons.sell_outlined,
        label: l10n.course,
        value: course.course.courseCode,
        color: TACoursesTheme.brandPrimary,
      ),
      (
        icon: Icons.credit_score_outlined,
        label: 'Credits',
        value: '${course.course.credits}',
        color: TACoursesTheme.accentBlue,
      ),
      (
        icon: Icons.stairs_outlined,
        label: l10n.level,
        value: (course.course.level ?? 'General').toUpperCase(),
        color: TACoursesTheme.warningAmber,
      ),
      (
        icon: Icons.calendar_today_outlined,
        label: l10n.coursesShellSemesterLabel,
        value: course.semester.name,
        color: TACoursesTheme.accentTeal,
      ),
      (
        icon: Icons.groups_rounded,
        label: l10n.students,
        value: '${_studentCountFor(state, course)}/${course.capacity}',
        color: TACoursesTheme.brandPrimary,
      ),
      (
        icon: Icons.location_on_outlined,
        label: l10n.location,
        value: (course.section.location ?? 'TBA').trim().isEmpty
            ? 'TBA'
            : course.section.location!,
        color: TACoursesTheme.accentBlue,
      ),
    ];

    return _buildSectionCard(
      isDark: isDark,
      title: l10n.studentCourseDetailOverviewHeading,
      subtitle: '${course.course.courseName} (${course.course.courseCode})',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 980
              ? 3
              : constraints.maxWidth >= 380
              ? 2
              : 1;
          final ratio = columns == 1
              ? 3.2
              : constraints.maxWidth >= 980
              ? 2.4
              : 2.5;

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: ratio,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildOverviewInfoTile(
                isDark: isDark,
                icon: item.icon,
                label: item.label,
                value: item.value,
                color: item.color,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOverviewInfoTile({
    required bool isDark,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131E31) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.22 : 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: TACoursesTheme.primaryText(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: TACoursesTheme.secondaryText(isDark),
                    fontSize: 12,
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

  Widget _buildCourseProgressCard(
    bool isDark,
    AppLocalizations l10n,
    TeachingCourseModel course,
    TACoursesState state,
    List<CourseMaterialModel> materials,
  ) {
    final studentCount = _studentCountFor(state, course);
    final fillRatio = course.capacity <= 0
        ? 0.0
        : (studentCount / course.capacity).clamp(0.0, 1.0);
    final fillPercent = (fillRatio * 100).round();

    return _buildSectionCard(
      isDark: isDark,
      title: l10n.courseProgress,
      subtitle: l10n.studentCourseDetailProgressSubtitle,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: TACoursesTheme.brandPrimary.withValues(
            alpha: isDark ? 0.18 : 0.10,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          course.course.status == 'archived' ? l10n.archived : l10n.activeLabel,
          style: TextStyle(
            color: course.course.status == 'archived'
                ? TACoursesTheme.errorRed
                : TACoursesTheme.brandPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: fillRatio,
              minHeight: 10,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.10)
                  : const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation<Color>(
                TACoursesTheme.brandPrimary,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$fillPercent% ${l10n.complete}',
                  style: TextStyle(
                    color: TACoursesTheme.primaryText(isDark),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  '${materials.length} ${l10n.courseMaterials.toLowerCase()}',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: TACoursesTheme.secondaryText(isDark),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewMetricsCard(
    bool isDark,
    AppLocalizations l10n,
    TeachingCourseModel course,
    TACoursesState state,
  ) {
    final overview =
        (state.overviewData as TASubTabLoaded<TACourseOverview>).data;
    final metrics =
        <({IconData icon, String value, String label, Color color})>[
          (
            icon: Icons.assignment_outlined,
            value: '${overview.totalAssignments}',
            label: l10n.assignments,
            color: TACoursesTheme.brandPrimary,
          ),
          (
            icon: Icons.science_outlined,
            value: '${overview.totalLabs}',
            label: l10n.labs,
            color: TACoursesTheme.accentTeal,
          ),
          (
            icon: Icons.grading_outlined,
            value: '${overview.pendingGrading}',
            label: l10n.pending,
            color: TACoursesTheme.warningAmber,
          ),
          (
            icon: Icons.people_outline_rounded,
            value: '${_studentCountFor(state, course)}',
            label: l10n.students,
            color: TACoursesTheme.accentBlue,
          ),
        ];

    return _buildSectionCard(
      isDark: isDark,
      title: l10n.taCourseInsightsTitle,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 980
              ? 4
              : constraints.maxWidth >= 380
              ? 2
              : 1;
          final ratio = columns == 1
              ? 3.2
              : constraints.maxWidth >= 980
              ? 2.1
              : 2.5;

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: metrics.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: ratio,
            ),
            itemBuilder: (context, index) {
              final metric = metrics[index];
              return _buildOverviewMetricTile(
                isDark: isDark,
                icon: metric.icon,
                value: metric.value,
                label: metric.label,
                color: metric.color,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOverviewMetricTile({
    required bool isDark,
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131E31) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.22 : 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: TACoursesTheme.primaryText(isDark),
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: TACoursesTheme.secondaryText(isDark),
                    fontSize: 12,
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

  Widget _buildOverviewActionsCard(bool isDark, AppLocalizations l10n) {
    final actions =
        <({IconData icon, String label, VoidCallback onTap, Color color})>[
          (
            icon: Icons.science_rounded,
            label: l10n.labs,
            color: TACoursesTheme.brandPrimary,
            onTap: () => _tabController.animateTo(3),
          ),
          (
            icon: Icons.forum_rounded,
            label: l10n.discussions,
            color: TACoursesTheme.accentTeal,
            onTap: () => _tabController.animateTo(5),
          ),
          (
            icon: Icons.grading_rounded,
            label: l10n.gradingCenter,
            color: TACoursesTheme.warningAmber,
            onTap: () => _tabController.animateTo(6),
          ),
          (
            icon: Icons.people_outline_rounded,
            label: l10n.students,
            color: TACoursesTheme.accentBlue,
            onTap: () => _tabController.animateTo(8),
          ),
        ];

    return _buildSectionCard(
      isDark: isDark,
      title: l10n.manage,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 980
              ? 4
              : constraints.maxWidth >= 380
              ? 2
              : 1;
          final ratio = columns == 1 ? 3.1 : 2.3;

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: actions.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: ratio,
            ),
            itemBuilder: (context, index) {
              final action = actions[index];
              return _buildActionButton(
                isDark: isDark,
                icon: action.icon,
                label: action.label,
                color: action.color,
                onTap: action.onTap,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildActionButton({
    required bool isDark,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.18 : 0.10),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: 0.22)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.20 : 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: color, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssignmentsTab(
    bool isDark,
    AppLocalizations l10n,
    TACoursesState state,
    TeachingCourseModel course,
  ) {
    return TAAssignmentsScreen(
      initialCourseId: course.courseId,
      lockCourseSelection: true,
      embedded: true,
    );
  }

  Widget _buildLabsTab(
    bool isDark,
    AppLocalizations l10n,
    TACoursesState state,
    TeachingCourseModel course,
  ) {
    return TALabsListScreen(
      initialCourseId: course.courseId,
      lockCourseSelection: true,
      embedded: true,
    );
  }

  Widget _buildAnnouncementsTab(
    bool isDark,
    AppLocalizations l10n,
    TeachingCourseModel course,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: TAAnnouncementManagerScreen(
        courseId: course.courseId,
        embedded: true,
      ),
    );
  }

  Widget _buildDiscussionsTab(
    bool isDark,
    AppLocalizations l10n,
    TeachingCourseModel course,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: TACourseDiscussionsScreen(
        courseId: course.courseId,
        initialCourse: course,
        embedded: true,
      ),
    );
  }

  Widget _buildAttendanceTab(
    bool isDark,
    AppLocalizations l10n,
    TACoursesState state,
  ) {
    final course = _findCourse(context.read<TACoursesCubit>().state);
    return TAAttendanceScreen(
      embedded: true,
      initialSectionId: course?.sectionId,
    );
  }

  Widget _buildStudentsTab(
    bool isDark,
    AppLocalizations l10n,
    TACoursesState state,
    TeachingCourseModel course,
  ) {
    final students = _resolveSectionStudents(state.studentsData);
    final isStudentsLoading =
        state.studentsData is TASubTabInitial<List<dynamic>> ||
        state.studentsData is TASubTabLoading<List<dynamic>>;

    if (isStudentsLoading && students.isEmpty) {
      return _buildDetailTabSkeleton(
        isDark,
        itemHeights: const <double>[56, 120, 120, 120],
      );
    }

    return _buildSubTabContent<List<dynamic>>(
      isDark: isDark,
      subTabState: state.studentsData,
      emptyBuilder: () => _buildCenteredEmptyState(
        isDark: isDark,
        icon: Icons.people_outline_rounded,
        title: l10n.students,
        message: l10n.taCourseDetailNoStudents,
      ),
      builder: (_) {
        if (students.isEmpty) {
          return _buildCenteredEmptyState(
            isDark: isDark,
            icon: Icons.people_outline_rounded,
            title: l10n.students,
            message: l10n.taCourseDetailNoStudents,
          );
        }
        return TAStudentsTab(
          students: students,
          isDark: isDark,
          l10n: l10n,
          onRefreshRequested: () => context
              .read<TACoursesCubit>()
              .fetchSectionStudents(course.sectionId),
          emptyStateSubtitleOverride: l10n.taCourseDetailNoStudents,
        );
      },
    );
  }

  List<SectionStudentModel> _resolveSectionStudents(
    TASubTabState<List<dynamic>> subTabState,
  ) {
    if (subTabState is! TASubTabLoaded<List<dynamic>>) {
      return const <SectionStudentModel>[];
    }

    return subTabState.data
        .map((student) {
          if (student is SectionStudentModel) {
            return student;
          }
          if (student is Map<String, dynamic>) {
            return SectionStudentModel.fromJson(student);
          }
          if (student is Map) {
            return SectionStudentModel.fromJson(
              Map<String, dynamic>.from(student),
            );
          }
          return null;
        })
        .whereType<SectionStudentModel>()
        .toList(growable: false);
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
        context.go('/ta/courses');
      }
    });
  }

  Widget _buildSubTabContent<T>({
    required bool isDark,
    required TASubTabState<T> subTabState,
    required Widget Function() emptyBuilder,
    required Widget Function(T data) builder,
  }) {
    return switch (subTabState) {
      TASubTabInitial<T>() || TASubTabLoading<T>() => _buildDetailTabSkeleton(
        isDark,
        itemHeights: const <double>[72, 120, 120],
      ),
      TASubTabError<T>(message: final message) => _buildInlineErrorState(
        isDark,
        message,
      ),
      TASubTabLoaded<T>(data: final data) => builder(data),
    };
  }

  Widget _buildLoadingState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _skeletonBox(isDark, width: 46, height: 46, radius: 16),
          const SizedBox(height: 24),
          _skeletonBox(isDark, width: double.infinity, height: 220, radius: 28),
          const SizedBox(height: 20),
          _skeletonBox(isDark, width: double.infinity, height: 72, radius: 26),
          const SizedBox(height: 20),
          _skeletonBox(isDark, width: double.infinity, height: 140, radius: 22),
          const SizedBox(height: 16),
          _skeletonBox(isDark, width: double.infinity, height: 140, radius: 22),
        ],
      ),
    );
  }

  Widget _skeletonBox(
    bool isDark, {
    double? width,
    double height = 16,
    double radius = 8,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: TACoursesTheme.borderColor(isDark).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _buildDetailTabSkeleton(
    bool isDark, {
    required List<double> itemHeights,
  }) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: itemHeights.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        return _skeletonBox(
          isDark,
          width: double.infinity,
          height: itemHeights[index],
          radius: 22,
        );
      },
    );
  }

  Widget _buildErrorState(bool isDark, AppLocalizations l10n, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: TACoursesTheme.errorRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: TACoursesTheme.errorRed,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Failed to load course',
              style: TextStyle(
                color: TACoursesTheme.primaryText(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: TACoursesTheme.secondaryText(isDark),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<TACoursesCubit>().fetchTACourses(),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: TACoursesTheme.brandPrimary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    return _buildCenteredEmptyState(
      isDark: isDark,
      icon: Icons.school_outlined,
      title: l10n.taCourses,
      message: l10n.taCoursesNoAssignedSubtitle,
    );
  }

  Widget _buildInlineErrorState(bool isDark, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: TACoursesTheme.errorRed,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                color: TACoursesTheme.secondaryText(isDark),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenteredEmptyState({
    required bool isDark,
    required IconData icon,
    required String title,
    required String message,
    bool padded = true,
  }) {
    final child = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: TACoursesTheme.brandPrimary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 42, color: TACoursesTheme.brandPrimary),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: TextStyle(
            color: TACoursesTheme.primaryText(isDark),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: TextStyle(
            color: TACoursesTheme.secondaryText(isDark),
            fontSize: 13.5,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );

    if (!padded) {
      return child;
    }

    return Padding(padding: const EdgeInsets.all(24), child: child);
  }

  Widget _buildSectionCard({
    required bool isDark,
    required String title,
    String? subtitle,
    Widget? trailing,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TACoursesTheme.cardBackground(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: TACoursesTheme.borderColor(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: TACoursesTheme.primaryText(isDark),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: TACoursesTheme.secondaryText(isDark),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 12), trailing],
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Future<void> _openMaterial(
    CourseMaterialModel material,
    TeachingCourseModel course,
  ) async {
    if (_isVideoMaterial(material)) {
      _selectHeroVideo(material);
      return;
    }

    final materialModel = _toMaterialModel(material);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MaterialPreviewScreen(material: materialModel),
      ),
    );
  }

  MaterialModel _toMaterialModel(CourseMaterialModel courseMaterial) {
    String fileUrl = '';

    final driveFile = courseMaterial.file;
    if (driveFile != null) {
      fileUrl =
          driveFile.webViewLink ??
          driveFile.iframeUrl ??
          driveFile.downloadUrl ??
          '';
    }

    if (fileUrl.isEmpty && courseMaterial.externalUrl?.isNotEmpty == true) {
      fileUrl = courseMaterial.externalUrl!;
    }
    if (fileUrl.isEmpty && courseMaterial.url?.isNotEmpty == true) {
      fileUrl = courseMaterial.url!;
    }

    return MaterialModel(
      id: courseMaterial.materialId,
      title: courseMaterial.title,
      type: courseMaterial.materialType,
      fileSize: _formatBytes(courseMaterial.file?.fileSize),
      fileUrl: fileUrl,
      isPublished: courseMaterial.isPublished,
      uploadedAt: courseMaterial.createdAt,
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

  Color _materialColor(String materialType) {
    switch (materialType.trim().toLowerCase()) {
      case 'video':
      case 'lecture':
        return TACoursesTheme.brandPrimary;
      case 'pdf':
      case 'document':
      case 'doc':
        return TACoursesTheme.accentBlue;
      case 'link':
      case 'url':
        return TACoursesTheme.accentTeal;
      case 'image':
        return TACoursesTheme.warningAmber;
      default:
        return TAColors.textSecondary;
    }
  }

  IconData _materialIcon(String materialType) {
    switch (materialType.trim().toLowerCase()) {
      case 'video':
      case 'lecture':
        return Icons.play_circle_outline_rounded;
      case 'pdf':
      case 'document':
      case 'doc':
        return Icons.description_outlined;
      case 'link':
      case 'url':
        return Icons.link_rounded;
      case 'image':
        return Icons.image_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }
}

class _TACourseSearchTab extends StatefulWidget {
  const _TACourseSearchTab({
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
  final int courseId;
  final VoidCallback onOpenContent;
  final VoidCallback onOpenAssignments;
  final VoidCallback onOpenLabs;
  final VoidCallback onOpenAnnouncements;

  @override
  State<_TACourseSearchTab> createState() => _TACourseSearchTabState();
}

class _TACourseSearchTabState extends State<_TACourseSearchTab> {
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
  void didUpdateWidget(covariant _TACourseSearchTab oldWidget) {
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
    _cancelToken?.cancel();
    final cancelToken = CancelToken();
    _cancelToken = cancelToken;

    try {
      final results = await Future.wait<Object>([
        _materialService.getMaterials(widget.courseId, cancelToken: cancelToken),
        _assignmentService.getAll(
          courseId: widget.courseId,
          limit: 100,
          cancelToken: cancelToken,
        ),
        _labService.getAll(
          courseId: widget.courseId,
          limit: 100,
          cancelToken: cancelToken,
        ),
        _communicationService.getAnnouncementsByCourseId(
          widget.courseId,
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

      final List<AssignmentModel> assignmentItems =
          assignmentsResult.isSuccess && assignmentsResult.data != null
          ? assignmentsResult.data!.data
          : const <AssignmentModel>[];
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
        accentColor: TAColors.primary,
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

class _TACourseDetailTabSpec {
  final IconData icon;
  final String label;
  final bool compact;

  const _TACourseDetailTabSpec({
    required this.icon,
    required this.label,
    this.compact = false,
  });
}

class _TADetailHeroMetric {
  final IconData icon;
  final String value;
  final String label;

  const _TADetailHeroMetric({
    required this.icon,
    required this.value,
    required this.label,
  });
}

class _TACourseTabsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  const _TACourseTabsHeaderDelegate({
    required this.height,
    required this.child,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant _TACourseTabsHeaderDelegate oldDelegate) {
    return height != oldDelegate.height || child != oldDelegate.child;
  }
}
