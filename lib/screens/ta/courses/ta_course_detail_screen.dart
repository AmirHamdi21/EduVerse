import 'package:edu_verse/common/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../bloc/courses/courses_bloc.dart';
import '../../../bloc/courses/courses_state.dart';
import '../../../bloc/courses/courses_event.dart';
import '../../../models/instructor/teaching_course_model.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../screens/shared/discussion_screen.dart';
import '../../../widgets/ta/shared/ta_colors.dart';
import '../../../widgets/ta/courses/ta_courses_barrel.dart';

class TACourseDetailScreen extends StatefulWidget {
  final String courseId;

  const TACourseDetailScreen({super.key, required this.courseId});

  @override
  State<TACourseDetailScreen> createState() => _TACourseDetailScreenState();
}

class _TACourseDetailScreenState extends State<TACourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Ensure TA courses are fetched if not already
    final state = context.read<CoursesBloc>().state;
    if (state is! TACoursesLoaded) {
      context.read<CoursesBloc>().add(const TACoursesFetched());
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// T009: Extract the matching TeachingCourseModel from BLoC state.
  TeachingCourseModel? _findCourse(CoursesState state) {
    if (state is TACoursesLoaded) {
      final id = int.tryParse(widget.courseId);
      if (id == null) return null;
      try {
        return state.teachingCourses.firstWhere(
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
            // T009: Wrap with BlocBuilder for CoursesBloc
            child: BlocBuilder<CoursesBloc, CoursesState>(
              builder: (context, coursesState) {
                return _buildBody(isDark, l10n, coursesState);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(bool isDark, AppLocalizations l10n, CoursesState state) {
    // T009: Loading skeleton while data resolves
    if (state is CoursesLoading) {
      return _buildLoadingState(isDark);
    }

    if (state is CoursesError) {
      return _buildErrorState(isDark, l10n, state.message);
    }

    final course = _findCourse(state);
    if (course == null) {
      return _buildEmptyState(isDark, l10n);
    }

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        _buildAppBar(isDark, l10n, course),
        SliverToBoxAdapter(child: _buildCourseContent(isDark, l10n, course)),
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
          _buildOverviewTab(isDark, l10n, course),
          _buildLabsTab(isDark, l10n),
          _buildGradingTab(isDark, l10n),
          _buildDiscussionsTab(isDark, l10n),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    // T009: Skeleton loading per Constitution Principle IV
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button skeleton
          _skeletonBox(isDark, width: 40, height: 40, radius: 10),
          const SizedBox(height: 24),
          // Header skeleton
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
          // Stats skeleton
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
          // Tab bar skeleton
          _skeletonBox(isDark, width: double.infinity, height: 48, radius: 12),
          const SizedBox(height: 24),
          // Content skeleton
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
                context.read<CoursesBloc>().add(const TACoursesFetched());
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

  /// T009/T014: App bar uses dynamic TeachingCourseModel data.
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
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            gradient: TAColors.aiGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            onPressed: () => _showAIInsightsSheet(),
            icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            tooltip: l10n.taCourseAIInsights,
          ),
        ),
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

  /// T014: Stats cards use dynamic model data instead of hardcoded numbers.
  Widget _buildCourseContent(
    bool isDark,
    AppLocalizations l10n,
    TeachingCourseModel tc,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TACourseStatsCards(
            isDark: isDark,
            studentsCount: tc.section.currentEnrollment,
            labsCount: 0, // Will be populated from future lab endpoints
            assignmentsCount:
                0, // Will be populated from future assignment endpoints
            discussionsCount:
                0, // Will be populated from future discussion endpoints
          ),
          const SizedBox(height: 16),
          // T015/T018: Quick actions — TA-safe actions only (no destructive ops)
          TACourseQuickActions(
            isDark: isDark,
            onViewLabs: () => _tabController.animateTo(1),
            onViewSubmissions: () => _tabController.animateTo(2),
            onViewDiscussions: () => _tabController.animateTo(3),
            onAIInsights: () => _showAIInsightsSheet(),
          ),
          const SizedBox(height: 16),
          TACourseInsightsCard(
            isDark: isDark,
            insights: [
              'Section ${tc.section.sectionNumber} has ${tc.section.currentEnrollment}/${tc.section.maxCapacity} students enrolled',
              'Course level: ${tc.course.level} • ${tc.course.credits} credits',
              if (tc.section.location != null)
                'Location: ${tc.section.location}',
            ],
            onOpenFullInsights: () => _showAIInsightsSheet(),
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
            fontSize: ResponsiveUtil(context).isMobile ? 10 : 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: ResponsiveUtil(context).isMobile ? 10 : 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: [
            Tab(text: l10n.taCourseOverview),
            Tab(text: l10n.taCourseLabsTab),
            Tab(text: l10n.taCourseGradingTab),
            Tab(text: l10n.taCourseDiscussionsTab),
          ],
        ),
      ),
    );
  }

  /// T010: Overview tab populated with dynamic model data.
  Widget _buildOverviewTab(
    bool isDark,
    AppLocalizations l10n,
    TeachingCourseModel tc,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: TACourseOverviewTab(
        isDark: isDark,
        upcomingTasks: [
          TAUpcomingTask(
            id: '1',
            title: 'Review ${tc.course.courseName} materials',
            subtitle: '${tc.section.currentEnrollment} students enrolled',
          ),
        ],
        recentActivities: [
          TARecentActivity(
            id: '1',
            title:
                'Course ${tc.course.courseCode} assigned for ${tc.semester.name}',
            timeAgo: 'Recent',
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
      ),
    );
  }

  /// T012: Labs tab — currently empty lists, ready for future lab endpoints.
  Widget _buildLabsTab(bool isDark, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: TACourseLabsTab(
        isDark: isDark,
        labs: const [], // Will be populated from future lab endpoints
        onOpenLab: (lab) {},
        onReview: (lab) {},
        onAttendance: (lab) {},
        onUpload: (lab) {},
      ),
    );
  }

  /// T011/T015: Grading tab — no destructive actions, TA view-only.
  Widget _buildGradingTab(bool isDark, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: TACourseGradingTab(
        isDark: isDark,
        gradingTasks:
            const [], // Will be populated from future grading endpoints
        onStartReview: (task) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Reviewing: ${task.studentName}\'s submission'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        // T015 FR-006: No onApplyAIScore for TA — this is a view-only action
        onApplyAIScore: null,
      ),
    );
  }

  /// T013: Discussions tab — dynamically ready for future discussion endpoints.
  Widget _buildDiscussionsTab(bool isDark, AppLocalizations l10n) {
    final courseId = int.tryParse(widget.courseId);
    if (courseId == null) {
      return Center(
        child: Text(
          'Invalid course context for discussions',
          style: TextStyle(color: TAColors.textSecondaryColor(isDark)),
        ),
      );
    }

    return DiscussionScreen(
      courseId: courseId,
      accentColor: const Color(0xFF4F46E5),
      title: 'Course Discussions',
      embedMode: true,
    );
  }

  void _showAIInsightsSheet() {
    final isDark = context.read<ThemeBloc>().state.isDark;
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TAFullInsightsSheet(
        isDark: isDark,
        priorityTasks: const [
          'Review assigned section submissions',
          'Check discussion activity',
        ],
        quickActions: [
          TAQuickAction(
            icon: Icons.grading_rounded,
            label: l10n.taExamGrading,
            onTap: () => _tabController.animateTo(2),
          ),
          TAQuickAction(
            icon: Icons.science_rounded,
            label: l10n.taReviewLabs,
            onTap: () => _tabController.animateTo(1),
          ),
          TAQuickAction(
            icon: Icons.forum_rounded,
            label: l10n.taOpenDiscussions,
            onTap: () => _tabController.animateTo(3),
          ),
        ],
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
