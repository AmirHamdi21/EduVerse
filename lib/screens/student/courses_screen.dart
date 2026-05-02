import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/courses/courses_bloc.dart';
import '../../bloc/courses/courses_event.dart';
import '../../bloc/courses/courses_state.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../common/utils/student_course_filters.dart';
import '../../common/utils/student_courses_theme.dart';
import '../../generated_l10n/app_localizations.dart';
import '../../models/core/enrollment_model.dart';
import '../../widgets/student/courses/course_search_bar.dart';
import '../../widgets/student/courses/courses_header.dart';
import '../../widgets/student/courses/courses_list_view.dart';
import '../../widgets/student/courses/filter_button.dart';
import '../../widgets/student/courses/join_course_button.dart';
import '../../widgets/student/courses/semester_filter_menu_button.dart';
import '../../widgets/student/courses/sort_button.dart';

/// Student courses screen consuming live data from [CoursesBloc].
class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  String _selectedFilter = 'all';
  String _selectedSort = 'title_asc';
  String _searchQuery = '';
  int? _selectedSemesterId;

  @override
  void initState() {
    super.initState();
    context.read<CoursesBloc>().add(
      StudentCoursesFetched(semester: _selectedSemesterId),
    );
  }

  List<CourseEnrollmentModel> _applyFiltersAndSort(
    List<CourseEnrollmentModel> enrollments,
  ) {
    return StudentCourseFilters.applyCourseFiltersAndSort(
      enrollments: enrollments,
      query: _searchQuery,
      selectedStatus: _selectedFilter,
      sortKey: _selectedSort,
      selectedSemesterId: _selectedSemesterId,
    );
  }

  List<CourseEnrollmentModel> _enrollmentsFromState(CoursesState state) {
    if (state is CoursesLoaded) {
      return state.enrollments;
    }
    if (state is CoursesLoading) {
      return state.cachedData.whereType<CourseEnrollmentModel>().toList();
    }
    return <CourseEnrollmentModel>[];
  }

  void _ensureSemesterSelectionIsValid(List<SemesterFilterOption> options) {
    if (_selectedSemesterId == null) {
      return;
    }

    final stillExists = options.any(
      (option) => option.id == _selectedSemesterId,
    );
    if (!stillExists && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _selectedSemesterId = null;
        });
      });
    }
  }

  void _retryStudentFetch() {
    context.read<CoursesBloc>().add(
      StudentCoursesFetched(semester: _selectedSemesterId),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _selectedFilter = 'all';
      _selectedSort = 'title_asc';
      _searchQuery = '';
      _selectedSemesterId = null;
    });
    _retryStudentFetch();
  }

  bool _isAccessRestricted(CoursesState state) {
    return state is CoursesAuthSessionRequired && state.statusCode == 403;
  }

  bool _showInteractiveControls(CoursesState state) {
    return !_isAccessRestricted(state);
  }

  String _filterLabel(AppLocalizations l10n) {
    switch (_selectedFilter) {
      case 'active':
        return l10n.active;
      case 'completed':
        return l10n.completed;
      case 'dropped':
        return l10n.studentCourseDropped;
      case 'all':
      default:
        return l10n.all;
    }
  }

  double _resolveEnrollmentProgress(CourseEnrollmentModel enrollment) {
    final backendProgress = enrollment.progressPercentage;
    if (backendProgress != null) {
      return (backendProgress / 100).clamp(0.0, 1.0);
    }

    final viewed = enrollment.materialsViewed ?? 0;
    final total = enrollment.totalMaterials ?? 0;
    if (total > 0) {
      return (viewed / total).clamp(0.0, 1.0);
    }

    final normalized = StudentCourseFilters.normalizeEnrollmentStatus(
      enrollment.status,
    );
    if (normalized == 'completed') {
      return 1;
    }
    return 0;
  }

  _CourseOverviewMetrics _overviewMetrics(
    List<CourseEnrollmentModel> enrollments,
  ) {
    if (enrollments.isEmpty) {
      return const _CourseOverviewMetrics(
        totalCount: 0,
        activeCount: 0,
        completedCount: 0,
        averageProgressPercent: 0,
      );
    }

    int activeCount = 0;
    int completedCount = 0;
    double progressTotal = 0;

    for (final enrollment in enrollments) {
      final normalized = StudentCourseFilters.normalizeEnrollmentStatus(
        enrollment.status,
      );
      if (normalized == 'active') {
        activeCount++;
      }
      if (normalized == 'completed') {
        completedCount++;
      }
      progressTotal += _resolveEnrollmentProgress(enrollment);
    }

    return _CourseOverviewMetrics(
      totalCount: enrollments.length,
      activeCount: activeCount,
      completedCount: completedCount,
      averageProgressPercent: (progressTotal / enrollments.length * 100)
          .round(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          backgroundColor: StudentCoursesTheme.scaffoldBackground(isDark),
          floatingActionButton: BlocBuilder<CoursesBloc, CoursesState>(
            builder: (context, state) {
              if (!_showInteractiveControls(state)) {
                return const SizedBox.shrink();
              }

              return const JoinCourseButton(
                showPulse: false,
                useHeroGradient: true,
              );
            },
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          body: DecoratedBox(
            decoration: StudentCoursesTheme.scaffoldDecoration(isDark),
            child: BlocListener<CoursesBloc, CoursesState>(
              listener: (context, state) {
                if (state is CoursesError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(
                            Icons.wifi_off_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              state.message.isNotEmpty
                                  ? state.message
                                  : l10n.noInternetConnection,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: StudentCoursesTheme.errorRed,
                      behavior: SnackBarBehavior.floating,
                      shape: const RoundedRectangleBorder(
                        borderRadius: StudentCoursesTheme.controlRadius,
                      ),
                      action: SnackBarAction(
                        label: l10n.refresh,
                        textColor: Colors.white,
                        onPressed: _retryStudentFetch,
                      ),
                    ),
                  );
                }

                if (state is CoursesAuthSessionRequired) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state.message,
                        style: const TextStyle(fontSize: 13),
                      ),
                      backgroundColor: const Color(0xFFB45309),
                      behavior: SnackBarBehavior.floating,
                      shape: const RoundedRectangleBorder(
                        borderRadius: StudentCoursesTheme.controlRadius,
                      ),
                    ),
                  );
                }

                if (state is CoursesLoaded && state.isCachedFallback) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(
                            Icons.cloud_off_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.studentCourseOfflineCached,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: StudentCoursesTheme.warningAmber,
                      behavior: SnackBarBehavior.floating,
                      shape: const RoundedRectangleBorder(
                        borderRadius: StudentCoursesTheme.controlRadius,
                      ),
                    ),
                  );
                }
              },
              child: BlocBuilder<CoursesBloc, CoursesState>(
                builder: (context, state) {
                  final rawEnrollments = _enrollmentsFromState(state);
                  final semesterOptions =
                      StudentCourseFilters.deriveSemesterOptions(
                        rawEnrollments,
                      );
                  final showInteractiveControls = _showInteractiveControls(
                    state,
                  );
                  final filteredEnrollments = _applyFiltersAndSort(
                    rawEnrollments,
                  );
                  final overviewMetrics = _overviewMetrics(rawEnrollments);
                  _ensureSemesterSelectionIsValid(semesterOptions);

                  return SafeArea(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final maxWidth = StudentCoursesTheme.maxContentWidth(
                          constraints.maxWidth,
                        );
                        final screenPadding = StudentCoursesTheme.screenPadding(
                          constraints.maxWidth,
                        );

                        return CustomScrollView(
                          slivers: [
                            SliverToBoxAdapter(
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: maxWidth,
                                  ),
                                  child: Padding(
                                    padding: screenPadding,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CoursesHeader(
                                          title: l10n.myCoursesHeader,
                                          subtitle:
                                              l10n.studentCourseHeroSubtitle,
                                          stats: showInteractiveControls
                                              ? _buildHeroStats(
                                                  isDark: isDark,
                                                  metrics: overviewMetrics,
                                                  maxWidth: maxWidth,
                                                  l10n: l10n,
                                                )
                                              : null,
                                          showSearch: showInteractiveControls,
                                          searchBar: showInteractiveControls
                                              ? CourseSearchBar(
                                                  onSearchChanged: (query) {
                                                    setState(() {
                                                      _searchQuery = query;
                                                    });
                                                  },
                                                )
                                              : null,
                                          trailingAction:
                                              showInteractiveControls
                                              ? FilterButton(
                                                  iconOnly: true,
                                                  selectedFilter:
                                                      _selectedFilter,
                                                  selectedSemesterId:
                                                      _selectedSemesterId,
                                                  semesterOptions:
                                                      semesterOptions,
                                                  onFilterChanged: (filter) {
                                                    setState(() {
                                                      _selectedFilter = filter;
                                                    });
                                                  },
                                                  onSemesterChanged: (_) {},
                                                )
                                              : null,
                                          tabBar: showInteractiveControls
                                              ? _buildStatusTabs(l10n)
                                              : _buildRestrictedTab(
                                                  isDark,
                                                  l10n,
                                                ),
                                        ),
                                        const SizedBox(height: 18),
                                        if (!showInteractiveControls)
                                          _buildRestrictedControlsNotice(
                                            isDark,
                                            l10n,
                                          ),
                                        if (showInteractiveControls) ...[
                                          const SizedBox(height: 18),
                                          _buildToolbar(
                                            isDark: isDark,
                                            l10n: l10n,
                                            filteredCount:
                                                filteredEnrollments.length,
                                            maxWidth: maxWidth,
                                            semesterOptions: semesterOptions,
                                          ),
                                        ],
                                        const SizedBox(height: 22),
                                        _buildContent(
                                          state: state,
                                          isDark: isDark,
                                          l10n: l10n,
                                          filteredEnrollments:
                                              filteredEnrollments,
                                          maxWidth: maxWidth,
                                        ),
                                        const SizedBox(height: 28),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusTabs(AppLocalizations l10n) {
    Widget buildTab({required String label, required String value}) {
      final selected = _selectedFilter == value;
      return GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? Colors.white : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.68),
              fontSize: 14,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          buildTab(label: l10n.all, value: 'all'),
          const SizedBox(width: 20),
          buildTab(label: l10n.active, value: 'active'),
          const SizedBox(width: 20),
          buildTab(label: l10n.completed, value: 'completed'),
          const SizedBox(width: 20),
          buildTab(label: l10n.studentCourseDropped, value: 'dropped'),
        ],
      ),
    );
  }

  Widget _buildRestrictedTab(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.12),
        borderRadius: StudentCoursesTheme.pillRadius,
      ),
      child: Text(
        l10n.coursesShellSessionRequiredTitle,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildHeroStats({
    required bool isDark,
    required AppLocalizations l10n,
    required _CourseOverviewMetrics metrics,
    required double maxWidth,
  }) {
    final stats = <({IconData icon, String value, String label, Color color})>[
      (
        icon: Icons.library_books_outlined,
        value: '${metrics.totalCount}',
        label: l10n.studentCourseTotalCourses,
        color: const Color(0xFF34D399),
      ),
      (
        icon: Icons.play_circle_outline_rounded,
        value: '${metrics.activeCount}',
        label: l10n.studentCourseActiveCourses,
        color: const Color(0xFF60A5FA),
      ),
      (
        icon: Icons.task_alt_rounded,
        value: '${metrics.completedCount}',
        label: l10n.studentCourseCompletedCourses,
        color: const Color(0xFFF472B6),
      ),
      (
        icon: Icons.trending_up_rounded,
        value: '${metrics.averageProgressPercent}%',
        label: l10n.studentCourseAverageProgress,
        color: const Color(0xFFFBBF24),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth > 0
            ? constraints.maxWidth
            : maxWidth;
        final crossAxisCount = availableWidth < 360
            ? 2
            : (availableWidth >= 720 ? 4 : 2);
        const spacing = 8.0;
        final itemWidth =
            (availableWidth - (spacing * (crossAxisCount - 1))) /
            crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: stats
              .map(
                (stat) => SizedBox(
                  width: itemWidth,
                  child: _buildHeroStatCard(
                    icon: stat.icon,
                    value: stat.value,
                    label: stat.label,
                    color: stat.color,
                  ),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }

  Widget _buildHeroStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 76),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar({
    required bool isDark,
    required AppLocalizations l10n,
    required int filteredCount,
    required double maxWidth,
    required List<SemesterFilterOption> semesterOptions,
  }) {
    final description = _selectedSemesterId == null
        ? _filterLabel(l10n)
        : semesterOptions
              .firstWhere(
                (option) => option.id == _selectedSemesterId,
                orElse: () =>
                    SemesterFilterOption(id: -1, label: l10n.allSemesters),
              )
              .label;

    final menus = Row(
      children: [
        Expanded(
          child: SortButton(
            selectedSort: _selectedSort,
            onSortChanged: (sort) {
              setState(() {
                _selectedSort = sort;
              });
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SemesterFilterMenuButton(
            selectedSemesterId: _selectedSemesterId,
            semesterOptions: semesterOptions,
            onSemesterChanged: (semesterId) {
              setState(() {
                _selectedSemesterId = semesterId;
              });
              _retryStudentFetch();
            },
          ),
        ),
      ],
    );

    if (maxWidth < 760) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildToolbarHeading(isDark, l10n, filteredCount, description),
          const SizedBox(height: 12),
          menus,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildToolbarHeading(isDark, l10n, filteredCount, description),
        ),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: menus),
      ],
    );
  }

  Widget _buildToolbarHeading(
    bool isDark,
    AppLocalizations l10n,
    int filteredCount,
    String description,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$filteredCount ${l10n.studentCourseResultsLabel}',
          style: TextStyle(
            color: StudentCoursesTheme.primaryText(isDark),
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            color: StudentCoursesTheme.secondaryText(isDark),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRestrictedControlsNotice(bool isDark, AppLocalizations l10n) {
    return Container(
      key: const Key('courses_shell_restricted_controls_notice'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF20304E) : const Color(0xFFF1F5FF),
        borderRadius: StudentCoursesTheme.controlRadius,
        border: Border.all(
          color: isDark ? Colors.white24 : const Color(0xFFBFDBFE),
        ),
      ),
      child: Text(
        l10n.coursesShellSessionRequiredMessage,
        style: TextStyle(
          color: isDark ? Colors.white70 : const Color(0xFF1D4ED8),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildContent({
    required CoursesState state,
    required bool isDark,
    required AppLocalizations l10n,
    required List<CourseEnrollmentModel> filteredEnrollments,
    required double maxWidth,
  }) {
    if (state is CoursesInitial ||
        (state is CoursesLoading && state.cachedData.isEmpty)) {
      return _buildSkeletonLoader(isDark, maxWidth);
    }

    if (state is CoursesLoading && state.cachedData.isNotEmpty) {
      return CoursesListView(enrollments: filteredEnrollments);
    }

    if (state is CoursesLoaded) {
      if (filteredEnrollments.isEmpty && state.enrollments.isEmpty) {
        return _buildEmptyState(isDark, l10n);
      }
      if (filteredEnrollments.isEmpty && state.enrollments.isNotEmpty) {
        return _buildNoFilterResults(isDark, l10n);
      }
      return CoursesListView(enrollments: filteredEnrollments);
    }

    if (state is CoursesAuthSessionRequired) {
      return _buildAuthSessionRequiredState(isDark, state, l10n);
    }

    if (state is CoursesError) {
      return _buildErrorState(isDark, l10n);
    }

    return _buildEmptyState(isDark, l10n);
  }

  Widget _buildSkeletonLoader(bool isDark, double maxWidth) {
    final cardCount = maxWidth >= 960 ? 2 : 3;

    return Column(
      key: const Key('courses_shell_loading_state'),
      children: List.generate(
        cardCount,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Container(
            height: 220,
            decoration: BoxDecoration(
              color: StudentCoursesTheme.cardBackground(isDark),
              borderRadius: StudentCoursesTheme.cardRadius,
              border: Border.all(
                color: StudentCoursesTheme.borderColor(isDark),
              ),
            ),
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(double.infinity, 96, isDark, radius: 24),
                    const SizedBox(height: 14),
                    _shimmerBox(double.infinity, 14, isDark, radius: 8),
                    const SizedBox(height: 8),
                    _shimmerBox(150, 12, isDark, radius: 8),
                    const SizedBox(height: 12),
                    _shimmerBox(double.infinity, 28, isDark, radius: 14),
                    const SizedBox(height: 10),
                    _shimmerBox(double.infinity, 38, isDark, radius: 18),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _shimmerBox(
    double width,
    double height,
    bool isDark, {
    double radius = 8,
  }) {
    return Container(
      width: width == 0 ? null : width,
      height: height,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    return Center(
      key: const Key('courses_shell_empty_state'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF22355B)
                    : const Color(0xFFEAF2FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.school_outlined,
                size: 42,
                color: isDark
                    ? Colors.white54
                    : StudentCoursesTheme.brandBlue.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.noCoursesFound,
              style: TextStyle(
                color: StudentCoursesTheme.primaryText(isDark),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.studentCourseEmptyDescription,
              style: TextStyle(
                color: StudentCoursesTheme.secondaryText(isDark),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoFilterResults(bool isDark, AppLocalizations l10n) {
    final semesterOnly =
        _selectedSemesterId != null &&
        _searchQuery.trim().isEmpty &&
        _selectedFilter == 'all';

    return Center(
      key: const Key('courses_shell_no_results_state'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_list_off_rounded,
              size: 48,
              color: isDark ? Colors.white30 : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              semesterOnly
                  ? l10n.coursesShellNoSemesterMatches
                  : l10n.noCoursesFoundDescription,
              style: TextStyle(
                color: StudentCoursesTheme.secondaryText(isDark),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _clearAllFilters,
              child: Text(
                l10n.clearFilters,
                style: const TextStyle(
                  color: StudentCoursesTheme.brandBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isDark, AppLocalizations l10n) {
    return Center(
      key: const Key('courses_shell_error_state'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF3D2020)
                    : const Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_outlined,
                size: 42,
                color: isDark
                    ? const Color(0xFFFCA5A5)
                    : StudentCoursesTheme.errorRed,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.studentCourseConnectionErrorTitle,
              style: TextStyle(
                color: StudentCoursesTheme.primaryText(isDark),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.studentCourseConnectionErrorDescription,
              style: TextStyle(
                color: StudentCoursesTheme.secondaryText(isDark),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _retryStudentFetch,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(l10n.tryAgain),
              style: ElevatedButton.styleFrom(
                backgroundColor: StudentCoursesTheme.brandBlue,
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: StudentCoursesTheme.controlRadius,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthSessionRequiredState(
    bool isDark,
    CoursesAuthSessionRequired state,
    AppLocalizations l10n,
  ) {
    final isForbidden = state.statusCode == 403;

    return Center(
      key: const Key('courses_shell_auth_state'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF3A2A16)
                    : const Color(0xFFFFF3E0),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_clock_outlined,
                size: 42,
                color: isDark
                    ? const Color(0xFFFCD34D)
                    : const Color(0xFFB45309),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isForbidden
                  ? l10n.studentCourseAccessRestrictedTitle
                  : l10n.coursesShellSessionRequiredTitle,
              style: TextStyle(
                color: StudentCoursesTheme.primaryText(isDark),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isForbidden
                  ? l10n.coursesShellSessionRequiredMessage
                  : (state.message.isNotEmpty
                        ? state.message
                        : l10n.coursesShellSessionRequiredMessage),
              style: TextStyle(
                color: StudentCoursesTheme.secondaryText(isDark),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _retryStudentFetch,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                isForbidden ? l10n.refresh : l10n.coursesShellReauthenticate,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: StudentCoursesTheme.brandBlue,
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: StudentCoursesTheme.controlRadius,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseOverviewMetrics {
  final int totalCount;
  final int activeCount;
  final int completedCount;
  final int averageProgressPercent;

  const _CourseOverviewMetrics({
    required this.totalCount,
    required this.activeCount,
    required this.completedCount,
    required this.averageProgressPercent,
  });
}
