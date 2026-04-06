import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../bloc/courses/courses_bloc.dart';
import '../../../bloc/courses/courses_event.dart';
import '../../../bloc/courses/courses_state.dart';
import '../../../models/instructor/teaching_course_model.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/ta/shared/ta_colors.dart';
import '../../../widgets/ta/dashboard/ta_drawer.dart';

class TACoursesListScreen extends StatefulWidget {
  const TACoursesListScreen({super.key});

  @override
  State<TACoursesListScreen> createState() => _TACoursesListScreenState();
}

class _TACoursesListScreenState extends State<TACoursesListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    // T005/T006: Dispatch TA-specific BLoC event instead of loading mock data
    context.read<CoursesBloc>().add(const TACoursesFetched());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: TAColors.scaffoldColor(isDark),
          drawer: TADrawer(
            currentRoute: '/ta/courses',
            isDark: isDark,
          ),
          body: SafeArea(
            // T006: Wrap with BlocBuilder for CoursesBloc state management
            child: BlocBuilder<CoursesBloc, CoursesState>(
              builder: (context, coursesState) {
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<CoursesBloc>().add(const TACoursesFetched());
                  },
                  color: TAColors.primary,
                  child: CustomScrollView(
                    slivers: [
                      _buildAppBar(isDark, l10n),
                      SliverToBoxAdapter(
                        child: _buildSummaryStats(isDark, l10n, coursesState),
                      ),
                      SliverToBoxAdapter(
                        child: _buildFilterChips(isDark, l10n, coursesState),
                      ),
                      _buildContent(isDark, l10n, coursesState),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// Extract the list of teaching courses from the current BLoC state.
  List<TeachingCourseModel> _getCoursesFromState(CoursesState state) {
    if (state is TACoursesLoaded) {
      return state.teachingCourses;
    }
    if (state is CoursesLoading && state.cachedData.isNotEmpty) {
      return state.cachedData
          .whereType<TeachingCourseModel>()
          .toList();
    }
    return [];
  }

  List<TeachingCourseModel> _getFilteredCourses(CoursesState state) {
    final courses = _getCoursesFromState(state);
    if (_selectedFilter == 'all') return courses;
    // For 'pending' filter, keep all courses (pending grading is not available
    // from this endpoint; the filter will be expanded in future phases).
    return courses;
  }

  int _getTotalStudents(CoursesState state) {
    return _getCoursesFromState(state).fold<int>(
      0,
      (sum, tc) => sum + tc.section.currentEnrollment,
    );
  }

  SliverAppBar _buildAppBar(bool isDark, AppLocalizations l10n) {
    return SliverAppBar(
      backgroundColor: TAColors.scaffoldColor(isDark),
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        icon: Icon(
          Icons.menu_rounded,
          color: TAColors.textPrimaryColor(isDark),
        ),
      ),
      title: Text(
        l10n.taCourses,
        style: TextStyle(
          color: TAColors.textPrimaryColor(isDark),
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
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

  Widget _buildSummaryStats(
    bool isDark,
    AppLocalizations l10n,
    CoursesState state,
  ) {
    final courses = _getCoursesFromState(state);
    final totalStudents = _getTotalStudents(state);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TAColors.primary.withValues(alpha: isDark ? 0.25 : 0.15),
            TAColors.primary.withValues(alpha: isDark ? 0.1 : 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TAColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryStatItem(
              icon: Icons.school_rounded,
              value: '${courses.length}',
              label: l10n.courses,
              color: TAColors.primary,
              isDark: isDark,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: TAColors.borderColor(isDark),
          ),
          Expanded(
            child: _buildSummaryStatItem(
              icon: Icons.people_rounded,
              value: '$totalStudents',
              label: l10n.taCourseStudents,
              color: TAColors.teal,
              isDark: isDark,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: TAColors.borderColor(isDark),
          ),
          Expanded(
            child: _buildSummaryStatItem(
              icon: Icons.assignment_late_rounded,
              value: '0',
              label: l10n.pending,
              color: TAColors.warning,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: TAColors.textPrimaryColor(isDark),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: TAColors.textSecondaryColor(isDark),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(
    bool isDark,
    AppLocalizations l10n,
    CoursesState state,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip(
            label: l10n.taCourseFilterAll,
            value: 'all',
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: l10n.taCourseGradingPending,
            value: 'pending',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required bool isDark,
    String? badge,
  }) {
    final isSelected = _selectedFilter == value;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _selectedFilter = value),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? TAColors.primary : TAColors.cardColor(isDark),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? TAColors.primary
                  : TAColors.borderColor(isDark),
            ),
          ),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : TAColors.textPrimaryColor(isDark),
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.2)
                        : TAColors.warning.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: isSelected ? Colors.white : TAColors.warning,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // T006: Loading skeleton per Constitution Principle IV
  Widget _buildContent(
    bool isDark,
    AppLocalizations l10n,
    CoursesState state,
  ) {
    // Loading state — show skeleton loaders
    if (state is CoursesLoading) {
      return SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildSkeletonCard(isDark),
            childCount: 3,
          ),
        ),
      );
    }

    // Error state — show retry
    if (state is CoursesError) {
      return SliverFillRemaining(
        child: Center(
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
                'Failed to load courses',
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.message,
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

    final filteredCourses = _getFilteredCourses(state);

    // T008: Empty state
    if (filteredCourses.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: TAColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.school_rounded,
                  size: 48,
                  color: TAColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No Courses Assigned',
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You are not assigned to any courses yet.',
                style: TextStyle(
                  color: TAColors.textSecondaryColor(isDark),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // T007: Render TeachingCourseModel instances into list UI elements
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final course = filteredCourses[index];
            return _buildCourseCard(course, isDark, l10n);
          },
          childCount: filteredCourses.length,
        ),
      ),
    );
  }

  /// Skeleton loading card for Constitution Principle IV compliance.
  Widget _buildSkeletonCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _skeletonBox(isDark, width: 52, height: 52, radius: 14),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _skeletonBox(isDark, width: 80, height: 12, radius: 4),
                    const SizedBox(height: 6),
                    _skeletonBox(isDark, width: 160, height: 16, radius: 4),
                    const SizedBox(height: 4),
                    _skeletonBox(isDark, width: 120, height: 12, radius: 4),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _skeletonBox(isDark, width: double.infinity, height: 3, radius: 2),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _skeletonBox(isDark, height: 60, radius: 10),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _skeletonBox(isDark, height: 60, radius: 10),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _skeletonBox(isDark, height: 60, radius: 10),
              ),
            ],
          ),
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

  /// T007: Build a course card from a live TeachingCourseModel instance.
  Widget _buildCourseCard(
    TeachingCourseModel tc,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final courseColor = _getCourseColor(tc.courseId);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/ta/course/${tc.sectionId}'),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with gradient
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      courseColor.withValues(alpha: isDark ? 0.25 : 0.15),
                      courseColor.withValues(alpha: isDark ? 0.1 : 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            courseColor,
                            courseColor.withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: courseColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          tc.course.courseCode.replaceAll(RegExp(r'[^A-Z]'), ''),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                tc.course.courseCode,
                                style: TextStyle(
                                  color: courseColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: TAColors.teal.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Sec ${tc.section.sectionNumber}',
                                  style: TextStyle(
                                    color: TAColors.teal,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tc.course.courseName,
                            style: TextStyle(
                              color: TAColors.textPrimaryColor(isDark),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${tc.semester.name} • ${tc.course.credits} credits',
                            style: TextStyle(
                              color: TAColors.textSecondaryColor(isDark),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: TAColors.textTertiaryColor(isDark),
                    ),
                  ],
                ),
              ),
              // Stats Grid
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.people_rounded,
                        value: '${tc.section.currentEnrollment}',
                        label: l10n.taCourseStudents,
                        color: TAColors.primary,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.event_seat_rounded,
                        value: '${tc.section.maxCapacity}',
                        label: 'Capacity',
                        color: TAColors.teal,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.location_on_rounded,
                        value: tc.section.location ?? 'TBA',
                        label: 'Location',
                        color: TAColors.info,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ),
              // Quick Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    _buildQuickAction(
                      icon: Icons.science_rounded,
                      label: l10n.taCourseViewLabs,
                      color: TAColors.primary,
                      isDark: isDark,
                      onTap: () => context.push('/ta/labs'),
                    ),
                    const SizedBox(width: 8),
                    _buildQuickAction(
                      icon: Icons.grading_rounded,
                      label: l10n.taGrading,
                      color: TAColors.warning,
                      isDark: isDark,
                      onTap: () {},
                    ),
                    const SizedBox(width: 8),
                    _buildQuickAction(
                      icon: Icons.forum_rounded,
                      label: l10n.taCourseDiscussionBtn,
                      color: TAColors.teal,
                      isDark: isDark,
                      onTap: () {},
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

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool isDark,
    bool highlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: highlighted
            ? color.withValues(alpha: 0.1)
            : TAColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: highlighted
              ? color.withValues(alpha: 0.3)
              : TAColors.borderColor(isDark).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: TAColors.textPrimaryColor(isDark),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontSize: 10,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Deterministic color assignment based on courseId.
  Color _getCourseColor(int courseId) {
    final colors = [
      TAColors.primary,
      TAColors.teal,
      TAColors.warning,
      TAColors.info,
      TAColors.success,
    ];
    return colors[courseId % colors.length];
  }
}
