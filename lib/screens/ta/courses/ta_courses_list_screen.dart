import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../bloc/theme/theme_event.dart';
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
  bool _isLoading = true;
  List<TACourseItem> _courses = [];
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 600));

    _courses = [
      TACourseItem(
        id: '1',
        code: 'CS101',
        name: 'Operating Systems',
        instructor: 'Dr. Ahmed Mohamed',
        studentsCount: 120,
        labsCount: 4,
        assignmentsCount: 6,
        pendingGrading: 12,
        pendingDiscussions: 3,
        color: TAColors.primary,
        progress: 0.65,
        nextDeadline: 'Lab 3 due in 2 days',
      ),
      TACourseItem(
        id: '2',
        code: 'CS201',
        name: 'Data Structures',
        instructor: 'Dr. Sara Ali',
        studentsCount: 95,
        labsCount: 5,
        assignmentsCount: 4,
        pendingGrading: 8,
        pendingDiscussions: 5,
        color: TAColors.teal,
        progress: 0.45,
        nextDeadline: 'Assignment 2 due in 5 days',
      ),
      TACourseItem(
        id: '3',
        code: 'CS301',
        name: 'Database Systems',
        instructor: 'Dr. Mohamed Hassan',
        studentsCount: 80,
        labsCount: 3,
        assignmentsCount: 5,
        pendingGrading: 5,
        pendingDiscussions: 2,
        color: TAColors.warning,
        progress: 0.30,
        nextDeadline: 'Lab 1 due in 1 week',
      ),
    ];

    setState(() => _isLoading = false);
  }

  List<TACourseItem> get _filteredCourses {
    if (_selectedFilter == 'all') return _courses;
    if (_selectedFilter == 'pending') {
      return _courses.where((c) => c.pendingGrading > 0).toList();
    }
    return _courses;
  }

  int get _totalPendingGrading {
    return _courses.fold(0, (sum, c) => sum + c.pendingGrading);
  }

  int get _totalStudents {
    return _courses.fold(0, (sum, c) => sum + c.studentsCount);
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
            child: RefreshIndicator(
              onRefresh: _loadCourses,
              color: TAColors.primary,
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(isDark, l10n),
                  SliverToBoxAdapter(
                    child: _buildSummaryStats(isDark, l10n),
                  ),
                  SliverToBoxAdapter(
                    child: _buildFilterChips(isDark, l10n),
                  ),
                  _buildContent(isDark, l10n),
                ],
              ),
            ),
          ),
        );
      },
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

  Widget _buildSummaryStats(bool isDark, AppLocalizations l10n) {
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
              value: '${_courses.length}',
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
              value: '$_totalStudents',
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
              value: '$_totalPendingGrading',
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

  Widget _buildFilterChips(bool isDark, AppLocalizations l10n) {
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
            badge: _totalPendingGrading > 0 ? '$_totalPendingGrading' : null,
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
              color: isSelected ? TAColors.primary : TAColors.borderColor(isDark),
            ),
          ),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : TAColors.textPrimaryColor(isDark),
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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

  Widget _buildContent(bool isDark, AppLocalizations l10n) {
    if (_isLoading) {
      return SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(color: TAColors.primary),
        ),
      );
    }

    if (_filteredCourses.isEmpty) {
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
                'No Courses Found',
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No courses match your filter',
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

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final course = _filteredCourses[index];
            return _buildCourseCard(course, isDark, l10n);
          },
          childCount: _filteredCourses.length,
        ),
      ),
    );
  }

  Widget _buildCourseCard(TACourseItem course, bool isDark, AppLocalizations l10n) {
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
          onTap: () => context.push('/ta/course/${course.id}'),
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
                      course.color.withValues(alpha: isDark ? 0.25 : 0.15),
                      course.color.withValues(alpha: isDark ? 0.1 : 0.05),
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
                            course.color,
                            course.color.withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: course.color.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          course.code.replaceAll(RegExp(r'[^A-Z]'), ''),
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
                                course.code,
                                style: TextStyle(
                                  color: course.color,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color:
                                      TAColors.success.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${(course.progress * 100).toInt()}%',
                                  style: TextStyle(
                                    color: TAColors.success,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            course.name,
                            style: TextStyle(
                              color: TAColors.textPrimaryColor(isDark),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            course.instructor,
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
              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: course.progress,
                    backgroundColor: TAColors.borderColor(isDark),
                    valueColor: AlwaysStoppedAnimation<Color>(course.color),
                    minHeight: 3,
                  ),
                ),
              ),
              // Stats Grid
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.people_rounded,
                            value: '${course.studentsCount}',
                            label: l10n.taCourseStudents,
                            color: TAColors.primary,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.science_rounded,
                            value: '${course.labsCount}',
                            label: l10n.taCourseLabs,
                            color: TAColors.teal,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.assignment_rounded,
                            value: '${course.assignmentsCount}',
                            label: l10n.taCourseAssignments,
                            color: TAColors.info,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.grading_rounded,
                            value: '${course.pendingGrading}',
                            label: l10n.pending,
                            color: course.pendingGrading > 0
                                ? TAColors.warning
                                : TAColors.success,
                            isDark: isDark,
                            highlighted: course.pendingGrading > 0,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.forum_rounded,
                            value: '${course.pendingDiscussions}',
                            label: l10n.taDiscussions,
                            color: course.pendingDiscussions > 0
                                ? TAColors.info
                                : TAColors.textSecondary,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                    if (course.nextDeadline != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: TAColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: TAColors.warning.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 16,
                              color: TAColors.warning,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                course.nextDeadline!,
                                style: TextStyle(
                                  color: TAColors.warning,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
}

class TACourseItem {
  final String id;
  final String code;
  final String name;
  final String instructor;
  final int studentsCount;
  final int labsCount;
  final int assignmentsCount;
  final int pendingGrading;
  final int pendingDiscussions;
  final Color color;
  final double progress;
  final String? nextDeadline;

  TACourseItem({
    required this.id,
    required this.code,
    required this.name,
    required this.instructor,
    required this.studentsCount,
    required this.labsCount,
    required this.assignmentsCount,
    required this.pendingGrading,
    required this.pendingDiscussions,
    required this.color,
    required this.progress,
    this.nextDeadline,
  });
}
