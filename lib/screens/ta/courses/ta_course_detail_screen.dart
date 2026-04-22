import 'package:edu_verse/common/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../bloc/ta/ta_courses_cubit.dart';
import '../../../bloc/ta/ta_courses_state.dart';
import '../../../models/assignments/assignment_model.dart';
import '../../../models/assignments/assignment_form_data.dart';
import '../../../models/instructor/teaching_course_model.dart';
import '../../../models/instructor/instructor_course_model.dart'
    show SectionStudentModel;
import '../../../services/api/assignment_service.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/storage_service.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/ta/shared/ta_colors.dart';
import '../../../widgets/ta/courses/ta_courses_barrel.dart';
import '../../../widgets/instructor/assignments/assignment_create_form.dart';
import '../../../models/materials/course_material_model.dart';
import '../../../models/instructor/instructor_course_model.dart'
    show MaterialModel, SectionStudentModel;
import '../../../screens/instructor/materials/material_preview_screen.dart';
import '../../../screens/instructor/video/instructor_video_player_screen.dart';
import '../assignments/ta_assignment_submissions_screen.dart';

class TACourseDetailScreen extends StatefulWidget {
  final String courseId;

  const TACourseDetailScreen({super.key, required this.courseId});

  @override
  State<TACourseDetailScreen> createState() => _TACourseDetailScreenState();
}

class _TACourseDetailScreenState extends State<TACourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<int> _loadedTabs = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this);
    _tabController.addListener(_onTabChanged);

    // Ensure TA courses are fetched if not already (this also fetches student counts)
    final cubit = context.read<TACoursesCubit>();
    final status = cubit.state.coursesStatus;
    if (status is! TASubTabLoaded<List<TeachingCourseModel>>) {
      cubit.fetchTACourses();
    }

    // Load first tab on init
    _loadTabData(0);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;
    _loadTabData(_tabController.index);
  }

  /// Fires the named cubit method for the tab on first activation only.
  void _loadTabData(int tabIndex) {
    if (_loadedTabs.contains(tabIndex)) return;
    _loadedTabs.add(tabIndex);

    final cubit = context.read<TACoursesCubit>();
    final courseId = int.tryParse(widget.courseId);

    // Resolve the TeachingCourseModel for section access
    TeachingCourseModel? tc;
    final status = cubit.state.coursesStatus;
    if (status is TASubTabLoaded<List<TeachingCourseModel>>) {
      final id = int.tryParse(widget.courseId);
      if (id != null) {
        tc = status.data.cast<TeachingCourseModel?>().firstWhere(
          (c) => c!.sectionId == id || c.courseId == id,
          orElse: () => null,
        );
      }
    }

    final cId = tc?.courseId ?? courseId;
    if (cId == null) return;

    switch (tabIndex) {
      case 0:
        cubit.fetchCourseOverview(cId);
      case 1:
        cubit.fetchCourseSectionsAndLabs(cId);
      case 2:
        cubit.fetchCourseStructure(cId);
      case 3:
        cubit.fetchCourseMaterials(cId);
      case 4:
        cubit.fetchCourseAssignments(cId);
      case 5:
        cubit.fetchPendingGrading(cId);
      case 6:
        cubit.fetchAttendanceSummary(cId);
      case 7:
        // Students: auto-load sections[0].id
        if (tc != null) {
          cubit.fetchSectionStudents(tc.sectionId);
        }
      case 8:
        // Announcements: no network call — static empty state
        break;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  /// Extract the matching TeachingCourseModel from cubit state.
  TeachingCourseModel? _findCourse(TACoursesState state) {
    final status = state.coursesStatus;
    if (status is TASubTabLoaded<List<TeachingCourseModel>>) {
      final id = int.tryParse(widget.courseId);
      if (id == null) return null;
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          backgroundColor: TAColors.scaffoldColor(isDark),
          body: SafeArea(
            child: BlocBuilder<TACoursesCubit, TACoursesState>(
              builder: (context, taState) {
                return _buildBody(isDark, l10n, taState);
              },
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

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        _buildAppBar(isDark, l10n, course),
        SliverToBoxAdapter(
          child: _buildCourseContent(isDark, l10n, course, state),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _TabBarDelegate(
            child: _buildTabBar(isDark, l10n),
            isDark: isDark,
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(isDark, l10n, course, state),
          _buildSectionsLabsTab(isDark, l10n, state),
          _buildLecturesTab(isDark, l10n, state),
          _buildMaterialsTab(isDark, l10n, state),
          _buildAssignmentsTab(isDark, l10n, state, course),
          _buildGradingTab(isDark, l10n, state),
          _buildAttendanceTab(isDark, l10n, state),
          _buildStudentsTab(isDark, l10n, state, course),
          _buildAnnouncementsTab(isDark, l10n),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _skeletonBox(isDark, width: 40, height: 40, radius: 10),
          const SizedBox(height: 24),
          Row(
            children: [
              _skeletonBox(isDark, width: 52, height: 52, radius: 14),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _skeletonBox(isDark, width: 200, height: 18, radius: 4),
                    const SizedBox(height: 8),
                    _skeletonBox(isDark, width: 140, height: 14, radius: 4),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _skeletonBox(isDark, height: 80, radius: 16)),
              const SizedBox(width: 12),
              Expanded(child: _skeletonBox(isDark, height: 80, radius: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _skeletonBox(isDark, height: 80, radius: 16)),
              const SizedBox(width: 12),
              Expanded(child: _skeletonBox(isDark, height: 80, radius: 16)),
            ],
          ),
          const SizedBox(height: 24),
          _skeletonBox(isDark, width: double.infinity, height: 48, radius: 12),
          const SizedBox(height: 24),
          _skeletonBox(isDark, width: double.infinity, height: 120, radius: 16),
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
        color: TAColors.borderColor(isDark).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(radius),
      ),
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
                color: TAColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: TAColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Failed to load course',
              style: TextStyle(
                color: TAColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: TAColors.textSecondaryColor(isDark),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<TACoursesCubit>().fetchTACourses();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: TAColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Text(
        'Course not found',
        style: TextStyle(color: TAColors.textSecondaryColor(isDark)),
      ),
    );
  }

  SliverAppBar _buildAppBar(
    bool isDark,
    AppLocalizations l10n,
    TeachingCourseModel tc,
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
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${tc.course.courseCode} — ${tc.course.courseName}',
            style: TextStyle(
              color: TAColors.textPrimaryColor(isDark),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            '${tc.semester.name} • Section ${tc.section.sectionNumber}',
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontSize: 12,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            context.read<ThemeBloc>().add(const ToggleThemeEvent());
          },
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: TAColors.textSecondaryColor(isDark),
          ),
        ),
        const SizedBox(width: 8),
      ],
      floating: true,
      snap: true,
    );
  }

  Widget _buildCourseContent(
    bool isDark,
    AppLocalizations l10n,
    TeachingCourseModel tc,
    TACoursesState state,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TACourseStatsCards(
            isDark: isDark,
            studentsCount: _getLiveStudentCount(state, tc),
            labsCount: 0,
            assignmentsCount: 0,
            discussionsCount: 0,
          ),
          const SizedBox(height: 16),
          TACourseQuickActions(
            isDark: isDark,
            onViewLabs: () => _tabController.animateTo(1),
            onViewSubmissions: () => _tabController.animateTo(5),
            onViewDiscussions: () => _tabController.animateTo(8),
            onAIInsights: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark, AppLocalizations l10n) {
    return Container(
      color: TAColors.scaffoldColor(isDark),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: TAColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
          ),
        ),
        padding: const EdgeInsets.all(4),
        child: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicator: BoxDecoration(
            color: TAColors.primary,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: TAColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: TAColors.textSecondaryColor(isDark),
          labelStyle: TextStyle(
            fontSize: ResponsiveUtil(context).isMobile ? 10 : 13,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: ResponsiveUtil(context).isMobile ? 10 : 13,
            fontWeight: FontWeight.w500,
          ),
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Sections & Labs'),
            Tab(text: 'Lectures'),
            Tab(text: 'Materials'),
            Tab(text: 'Assignments'),
            Tab(text: 'Grading'),
            Tab(text: 'Attendance'),
            Tab(text: 'Students'),
            Tab(text: 'Announcements'),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────

  /// Get live student count from backend count endpoint, fallback to section counter.
  int _getLiveStudentCount(TACoursesState state, TeachingCourseModel tc) {
    final count = state.sectionStudentCounts[tc.sectionId];
    if (count != null) {
      return count;
    }
    // Fallback to section counter while loading
    return tc.section.currentEnrollment;
  }

  // ── Sub-tab builders ─────────────────────────────────────────

  Widget _buildOverviewTab(
    bool isDark,
    AppLocalizations l10n,
    TeachingCourseModel tc,
    TACoursesState state,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildSubTabContent<TACourseOverview>(
        isDark: isDark,
        subTabState: state.overviewData,
        emptyMessage: 'No overview data available',
        emptyIcon: Icons.dashboard_rounded,
        builder: (overview) {
          return TACourseOverviewTab(
            isDark: isDark,
            upcomingTasks: [
              TAUpcomingTask(
                id: '1',
                title: 'Review ${tc.course.courseName} materials',
                subtitle:
                    '${_getLiveStudentCount(state, tc)} students enrolled',
              ),
            ],
            recentActivities: [
              TARecentActivity(
                id: '1',
                title:
                    'Course ${tc.course.courseCode} — ${overview.totalAssignments} assignments, ${overview.totalLabs} labs',
                timeAgo: '${overview.pendingGrading} pending grading',
                icon: Icons.school_rounded,
                color: TAColors.primary,
              ),
            ],
            onStartTask: (task) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Starting: ${task.title}'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionsLabsTab(
    bool isDark,
    AppLocalizations l10n,
    TACoursesState state,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildSubTabContent<TACourseSectionsLabs>(
        isDark: isDark,
        subTabState: state.sectionsLabsData,
        emptyMessage: 'No sections or labs found',
        emptyIcon: Icons.science_rounded,
        builder: (data) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (data.sections.isNotEmpty) ...[
                _buildSectionHeader(isDark, 'Sections', Icons.class_rounded),
                ...data.sections.map(
                  (section) => _buildInfoCard(
                    isDark: isDark,
                    title: 'Section ${section.sectionNumber}',
                    subtitle:
                        '${section.currentEnrollment}/${section.maxCapacity} students',
                    trailing: section.location ?? 'TBA',
                    icon: Icons.group_rounded,
                    color: TAColors.primary,
                    onTap: () => context.push(
                      '/ta/section-materials',
                      extra: {
                        'sectionId': section.id
                            .toString(), // Convert to String for router
                        'sectionName': 'Section ${section.sectionNumber}',
                        'courseId': widget.courseId.toString(),
                      },
                    ),
                  ),
                ),
              ],
              if (data.labs.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildSectionHeader(isDark, 'Labs', Icons.science_rounded),
                ...data.labs.map(
                  (lab) => _buildInfoCard(
                    isDark: isDark,
                    title: lab.title,
                    subtitle: lab.status.value.toUpperCase(),
                    trailing: lab.dueDate != null
                        ? '${lab.dueDate!.day}/${lab.dueDate!.month}'
                        : '',
                    icon: Icons.science_rounded,
                    color: TAColors.teal,
                    onTap: () => context.push('/ta/lab/${lab.labId ?? lab.id}'),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildLecturesTab(
    bool isDark,
    AppLocalizations l10n,
    TACoursesState state,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildSubTabContent<dynamic>(
        isDark: isDark,
        subTabState: state.structureData,
        emptyMessage: 'No lectures available',
        emptyIcon: Icons.play_lesson_rounded,
        builder: (data) {
          if (data is List && data.isEmpty) {
            return _buildEmptyTabState(
              isDark: isDark,
              message: 'No lectures available',
              icon: Icons.play_lesson_rounded,
            );
          }
          // TODO: render CourseStructureModel list when T010 widget is available
          return _buildEmptyTabState(
            isDark: isDark,
            message: 'Lectures loaded — UI pending',
            icon: Icons.play_lesson_rounded,
          );
        },
      ),
    );
  }

  Widget _buildMaterialsTab(
    bool isDark,
    AppLocalizations l10n,
    TACoursesState state,
  ) {
    return _buildSubTabContent<List<CourseMaterialModel>>(
      isDark: isDark,
      subTabState: state.materialsData,
      emptyMessage: 'No materials available',
      emptyIcon: Icons.folder_rounded,
      builder: (materials) {
        if (materials.isEmpty) {
          return _buildEmptyTabState(
            isDark: isDark,
            message: 'No materials available',
            icon: Icons.folder_rounded,
          );
        }

        // Extract course name from state
        String courseName = 'Course';
        if (state.coursesStatus is TASubTabLoaded<List<TeachingCourseModel>>) {
          final courses =
              (state.coursesStatus as TASubTabLoaded<List<TeachingCourseModel>>)
                  .data;
          final targetCourseId = int.tryParse(widget.courseId);
          if (targetCourseId != null) {
            for (final course in courses) {
              if (course.courseId == targetCourseId) {
                courseName = course.course.courseName;
                break;
              }
            }
          }
        }

        // Group materials by week number
        final weekMap = <int, List<CourseMaterialModel>>{};
        final noWeekMaterials = <CourseMaterialModel>[];

        for (final material in materials) {
          final week = material.weekNumber;
          if (week != null && week > 0) {
            weekMap.putIfAbsent(week, () => []).add(material);
          } else {
            noWeekMaterials.add(material);
          }
        }

        // Sort weeks
        final weeks = weekMap.keys.toList()..sort();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Week sections
              for (final week in weeks) ...[
                _buildWeekHeader(isDark, week, weekMap[week]!.length),
                const SizedBox(height: 8),
                ...weekMap[week]!.map(
                  (material) =>
                      _buildMaterialCard(isDark, material, courseName),
                ),
                const SizedBox(height: 16),
              ],

              // Materials without week
              if (noWeekMaterials.isNotEmpty) ...[
                _buildWeekHeader(isDark, 0, noWeekMaterials.length),
                const SizedBox(height: 8),
                ...noWeekMaterials.map(
                  (material) =>
                      _buildMaterialCard(isDark, material, courseName),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeekHeader(bool isDark, int weekNumber, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: TAColors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TAColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today_rounded, size: 18, color: TAColors.primary),
          const SizedBox(width: 10),
          Text(
            weekNumber == 0 ? 'Other Materials' : 'Week $weekNumber',
            style: TextStyle(
              color: TAColors.primary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: TAColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count ${count == 1 ? 'material' : 'materials'}',
              style: TextStyle(
                color: TAColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialCard(
    bool isDark,
    CourseMaterialModel material,
    String courseName,
  ) {
    return InkWell(
      onTap: () => _viewMaterial(material, courseName),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TAColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: TAColors.borderColor(isDark), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _getMaterialColor(
                  material.materialType,
                ).withValues(alpha: isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getMaterialIcon(material.materialType),
                color: _getMaterialColor(material.materialType),
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    material.title,
                    style: TextStyle(
                      color: TAColors.textPrimaryColor(isDark),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (material.description != null &&
                      material.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        material.description!,
                        style: TextStyle(
                          color: TAColors.textSecondaryColor(isDark),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.visibility_outlined,
                        size: 14,
                        color: TAColors.textTertiaryColor(isDark),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${material.viewCount ?? 0} views',
                        style: TextStyle(
                          color: TAColors.textTertiaryColor(isDark),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.download_outlined,
                        size: 14,
                        color: TAColors.textTertiaryColor(isDark),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${material.downloadCount ?? 0} downloads',
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
            const SizedBox(width: 8),
            Icon(Icons.play_circle_outline, size: 24, color: TAColors.primary),
          ],
        ),
      ),
    );
  }

  void _viewMaterial(CourseMaterialModel material, String courseName) {
    // For videos, use YouTube player screen like instructor does
    if (material.materialType.toLowerCase() == 'video') {
      final videoId = material.youtubeVideoId;
      if (videoId == null || videoId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No video ID available'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // Navigate to video player screen (reuse instructor's screen)
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => InstructorVideoPlayerScreen(
            videoId: videoId,
            courseName: courseName, // Use passed course name
            videoTitle: material.title,
          ),
        ),
      );
      return;
    }

    // For non-videos, use material preview screen
    final materialModel = _toMaterialModel(material);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MaterialPreviewScreen(material: materialModel),
      ),
    );
  }

  /// Converts CourseMaterialModel to MaterialModel for preview screen reuse.
  MaterialModel _toMaterialModel(CourseMaterialModel courseMaterial) {
    String fileUrl = '';

    // For videos, use YouTube embed URL if available
    if (courseMaterial.materialType.toLowerCase() == 'video') {
      final videoId = courseMaterial.youtubeVideoId;
      if (videoId != null && videoId.isNotEmpty) {
        // Construct YouTube embed URL
        fileUrl = 'https://www.youtube.com/embed/$videoId';
      } else {
        // Fallback to external URL or URL
        fileUrl = courseMaterial.externalUrl ?? courseMaterial.url ?? '';
      }
    } else {
      // For non-videos, use Drive file or URLs
      final driveFile = courseMaterial.file;
      if (driveFile != null) {
        fileUrl = driveFile.webViewLink.toString();
      } else if (courseMaterial.externalUrl?.isNotEmpty == true) {
        fileUrl = courseMaterial.externalUrl!;
      } else if (courseMaterial.url?.isNotEmpty == true) {
        fileUrl = courseMaterial.url!;
      }
    }

    return MaterialModel(
      id: courseMaterial.materialId.toString(),
      title: courseMaterial.title.toString(),
      type: courseMaterial.materialType.toString(),
      fileSize: '', // CourseMaterialModel doesn't have fileSize
      fileUrl: fileUrl,
      isPublished: courseMaterial.isPublished,
      uploadedAt: courseMaterial.createdAt,
    );
  }

  IconData _getMaterialIcon(String type) {
    final normalizedType = type.toLowerCase().trim();

    switch (normalizedType) {
      case 'video':
        return Icons.play_circle_outline;
      case 'lecture':
        return Icons.school_outlined;
      case 'slide':
      case 'ppt':
      case 'pptx':
        return Icons.slideshow_outlined;
      case 'document':
      case 'pdf':
      case 'doc':
      case 'docx':
        return Icons.picture_as_pdf_outlined;
      case 'reading':
        return Icons.menu_book_outlined;
      case 'link':
        return Icons.link_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  Color _getMaterialColor(String type) {
    final normalizedType = type.toLowerCase().trim();

    switch (normalizedType) {
      case 'video':
        return Colors.red;
      case 'lecture':
        return Colors.blue;
      case 'slide':
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      case 'document':
      case 'pdf':
      case 'doc':
      case 'docx':
        return Colors.red;
      case 'reading':
        return Colors.green;
      case 'link':
        return Colors.purple;
      default:
        return TAColors.info;
    }
  }

  Widget _buildAssignmentsTab(
    bool isDark,
    AppLocalizations l10n,
    TACoursesState state,
    TeachingCourseModel tc,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // T017: Create Assignment button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openAssignmentForm(tc),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Assignment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: TAColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSubTabContent(
            isDark: isDark,
            subTabState: state.assignmentsData,
            emptyMessage: 'No assignments yet',
            emptyIcon: Icons.assignment_rounded,
            builder: (assignments) {
              if (assignments.isEmpty) {
                return _buildEmptyTabState(
                  isDark: isDark,
                  message: 'No assignments yet',
                  icon: Icons.assignment_rounded,
                );
              }
              return Column(
                children: assignments.map((a) {
                  return _buildAssignmentCard(isDark, a, tc);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // T017: Open assignment creation form
  void _openAssignmentForm(
    TeachingCourseModel tc, {
    AssignmentModel? existing,
  }) async {
    final cubit = context.read<TACoursesCubit>();
    final status = cubit.state.coursesStatus;
    final courses = status is TASubTabLoaded<List<TeachingCourseModel>>
        ? status.data
        : <TeachingCourseModel>[tc];

    // T017: Resolve AssignmentService — try provider tree, fallback to local instance
    AssignmentService assignmentService;
    try {
      assignmentService = context.read<AssignmentService>();
    } catch (_) {
      final coreApiClient = CoreApiClient(storageService: StorageService());
      assignmentService = AssignmentService(coreApiClient: coreApiClient);
    }

    // If editing, fetch fresh assignment from API to get instructionFiles (matches instructor pattern)
    AssignmentModel? assignmentToEdit = existing;
    if (existing != null) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) =>
            Center(child: CircularProgressIndicator(color: TAColors.primary)),
      );

      final result = await assignmentService.getById(existing.assignmentId);
      if (mounted) {
        Navigator.of(context).pop(); // Dismiss loading
      }

      if (result.isSuccess && result.data != null) {
        assignmentToEdit = result.data;
      }
    }

    AssignmentFormData? initialData;
    if (assignmentToEdit != null) {
      // Fix: Convert UTC dueDate to local time for display (matches instructor pattern)
      DateTime localDueDate;
      if (assignmentToEdit.dueDate.isUtc) {
        localDueDate = assignmentToEdit.dueDate.toLocal();
      } else {
        localDueDate = assignmentToEdit.dueDate;
      }

      initialData = AssignmentFormData(
        title: assignmentToEdit.title,
        description: assignmentToEdit.description,
        instructions: assignmentToEdit.instructionsText,
        dueDate: localDueDate,
        maxScore: assignmentToEdit.maxGrade,
        weight: assignmentToEdit.weight,
        submissionType: assignmentToEdit.submissionType,
        maxFileSizeMb: assignmentToEdit.maxFileSizeMb,
        allowedFileTypes: assignmentToEdit.allowedFileTypes ?? const [],
        latePenaltyPercent: assignmentToEdit.latePenaltyPercent,
        status: assignmentToEdit.apiStatus,
        courseId: assignmentToEdit.courseId,
        instructionFiles: assignmentToEdit.instructionFiles ?? const [],
      );
    }

    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Text(
              assignmentToEdit != null
                  ? 'Edit Assignment'
                  : 'Create Assignment',
            ),
          ),
          body: AssignmentCreateForm(
            courses: courses,
            assignmentService: assignmentService,
            initialData: initialData,
            assignmentId: assignmentToEdit?.assignmentId,
            onSubmit: (formData) async {
              try {
                if (assignmentToEdit != null) {
                  await assignmentService.update(
                    assignmentToEdit.assignmentId,
                    formData.toJson(),
                  );
                } else {
                  await assignmentService.create(formData.toJson());
                }
                if (mounted) {
                  Navigator.of(context).pop();
                  cubit.fetchCourseAssignments(tc.courseId);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
          ),
        ),
      ),
    );
  }

  // T019: Delete assignment with confirmation dialog
  void _confirmDeleteAssignment(TeachingCourseModel tc, AssignmentModel a) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Assignment'),
        content: const Text(
          'This action cannot be undone. Delete this assignment?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<TACoursesCubit>().deleteAssignment(
                tc.courseId,
                a.assignmentId,
              );
            },
            style: TextButton.styleFrom(foregroundColor: TAColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // T017-T019: Assignment card with Edit/Delete actions
  Widget _buildAssignmentCard(
    bool isDark,
    AssignmentModel a,
    TeachingCourseModel tc,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TAAssignmentSubmissionsScreen(assignment: a),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: TAColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.assignment_rounded,
                    size: 20,
                    color: TAColors.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.title,
                        style: TextStyle(
                          color: TAColors.textPrimaryColor(isDark),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${a.apiStatus.toJson().toUpperCase()} • ${a.maxGrade} pts',
                        style: TextStyle(
                          color: TAColors.textSecondaryColor(isDark),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // T018: Edit button
                IconButton(
                  onPressed: () => _openAssignmentForm(tc, existing: a),
                  icon: Icon(
                    Icons.edit_rounded,
                    size: 18,
                    color: TAColors.info,
                  ),
                  tooltip: 'Edit',
                ),
                // T019: Delete button
                IconButton(
                  onPressed: () => _confirmDeleteAssignment(tc, a),
                  icon: Icon(
                    Icons.delete_rounded,
                    size: 18,
                    color: TAColors.error,
                  ),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradingTab(
    bool isDark,
    AppLocalizations l10n,
    TACoursesState state,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildSubTabContent(
        isDark: isDark,
        subTabState: state.pendingGradingData,
        emptyMessage: 'No pending grading — all caught up!',
        emptyIcon: Icons.check_circle_rounded,
        builder: (pending) {
          if (pending.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildEmptyTabState(
                  isDark: isDark,
                  message: 'No pending grading — all caught up!',
                  icon: Icons.check_circle_rounded,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () =>
                      context.push('/ta/grading?courseId=${widget.courseId}'),
                  icon: const Icon(Icons.grading_rounded),
                  label: const Text('Open Grading Center'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TAColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            );
          }

          // Show submissions with navigation
          return Column(
            children: [
              // Open grading center button at top
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      context.push('/ta/grading?courseId=${widget.courseId}'),
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Open Full Grading Center'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: TAColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(
                      color: TAColors.primary.withValues(alpha: 0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Submission cards
              ...pending.map((sub) {
                return InkWell(
                  onTap: () =>
                      context.push('/ta/grading?courseId=${widget.courseId}'),
                  borderRadius: BorderRadius.circular(12),
                  child: _buildInfoCard(
                    isDark: isDark,
                    title:
                        '${sub.user?.firstName ?? ''} ${sub.user?.lastName ?? ''}'
                            .trim()
                            .isEmpty
                        ? 'Student #${sub.userId}'
                        : '${sub.user!.firstName} ${sub.user!.lastName}'.trim(),
                    subtitle: 'Assignment #${sub.assignmentId}',
                    trailing: sub.submissionStatus.value,
                    icon: Icons.grading_rounded,
                    color: TAColors.warning,
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAttendanceTab(
    bool isDark,
    AppLocalizations l10n,
    TACoursesState state,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildSubTabContent(
        isDark: isDark,
        subTabState: state.attendanceSummaryData,
        emptyMessage: 'No attendance data yet',
        emptyIcon: Icons.event_available_rounded,
        builder: (summaries) {
          if (summaries.isEmpty) {
            return _buildEmptyTabState(
              isDark: isDark,
              message: 'No attendance data yet',
              icon: Icons.event_available_rounded,
            );
          }
          return Column(
            children: summaries.map((s) {
              return _buildInfoCard(
                isDark: isDark,
                title: s.labTitle,
                subtitle:
                    'P:${s.presentCount} A:${s.absentCount} E:${s.excusedCount} L:${s.lateCount}',
                trailing: '${s.totalCount} total',
                icon: Icons.how_to_reg_rounded,
                color: TAColors.success,
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildStudentsTab(
    bool isDark,
    AppLocalizations l10n,
    TACoursesState state,
    TeachingCourseModel tc,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildSubTabContent(
        isDark: isDark,
        subTabState: state.studentsData,
        emptyMessage: 'No students enrolled in this section',
        emptyIcon: Icons.people_rounded,
        builder: (students) {
          if (students.isEmpty) {
            return _buildEmptyTabState(
              isDark: isDark,
              message: 'No students enrolled in this section',
              icon: Icons.people_rounded,
            );
          }
          return Column(
            children: students.map((s) {
              String displayName;
              String subtitle;
              String trailing;

              if (s is SectionStudentModel) {
                displayName = s.displayName;
                subtitle = s.courseCode != null
                    ? '${s.courseCode} - Section ${s.sectionId}'
                    : 'Enrolled';
                trailing = s.status.toUpperCase();
              } else if (s is Map) {
                // Fallback for raw map data
                final courseData = s['course'] as Map<String, dynamic>?;
                final userId = s['userId'] as int? ?? 0;
                final firstName = s['firstName'] as String?;
                final lastName = s['lastName'] as String?;

                displayName = (firstName != null || lastName != null)
                    ? '$firstName $lastName'.trim()
                    : 'Student #$userId';
                subtitle = courseData != null
                    ? '${courseData['code']} - Section ${s['sectionId']}'
                    : 'Enrolled';
                trailing = (s['status'] as String? ?? 'enrolled').toUpperCase();
              } else {
                displayName = 'Student';
                subtitle = '';
                trailing = '';
              }

              return _buildInfoCard(
                isDark: isDark,
                title: displayName,
                subtitle: subtitle,
                trailing: trailing,
                icon: Icons.person_rounded,
                color: TAColors.primary,
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildAnnouncementsTab(bool isDark, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildEmptyTabState(
        isDark: isDark,
        message: 'Announcements are not available for this course',
        icon: Icons.campaign_rounded,
      ),
    );
  }

  // ── Shared Helpers ───────────────────────────────────────────

  /// Generic sub-tab content builder with loading/error/empty/loaded states.
  Widget _buildSubTabContent<T>({
    required bool isDark,
    required TASubTabState<T> subTabState,
    required String emptyMessage,
    required IconData emptyIcon,
    required Widget Function(T data) builder,
  }) {
    return switch (subTabState) {
      TASubTabInitial<T>() || TASubTabLoading<T>() => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: CircularProgressIndicator(
            color: TAColors.primary,
            strokeWidth: 3,
          ),
        ),
      ),
      TASubTabError<T>(message: final msg) => _buildErrorWidget(isDark, msg),
      TASubTabLoaded<T>(data: final data) => builder(data),
    };
  }

  Widget _buildErrorWidget(bool isDark, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.error_outline_rounded, size: 40, color: TAColors.error),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                color: TAColors.textSecondaryColor(isDark),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTabState({
    required bool isDark,
    required String message,
    required IconData icon,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
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
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(bool isDark, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: TAColors.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: TAColors.textPrimaryColor(isDark),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required bool isDark,
    required String title,
    required String subtitle,
    required String trailing,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: TAColors.textPrimaryColor(isDark),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: TAColors.textSecondaryColor(isDark),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                if (trailing.isNotEmpty)
                  Text(
                    trailing,
                    style: TextStyle(
                      color: TAColors.textTertiaryColor(isDark),
                      fontSize: 12,
                    ),
                  ),
                if (onTap != null)
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: TAColors.textTertiaryColor(isDark),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final bool isDark;

  _TabBarDelegate({required this.child, required this.isDark});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  double get maxExtent => 64;

  @override
  double get minExtent => 64;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) {
    return isDark != oldDelegate.isDark;
  }
}
