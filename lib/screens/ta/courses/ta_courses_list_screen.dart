import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/ta/ta_courses_cubit.dart';
import '../../../bloc/ta/ta_courses_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../common/utils/ta_courses_theme.dart';
import '../../../features/walkthrough/ta_walkthrough_registry.dart';
import '../../../features/walkthrough/walkthrough_target.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/instructor/extended_course_model.dart';
import '../../../models/instructor/teaching_course_model.dart';
import '../../../widgets/ta/courses/ta_course_search_bar.dart';
import '../../../widgets/ta/courses/ta_courses_header.dart';
import '../../../widgets/ta/courses/ta_courses_list_view.dart';
import '../../../widgets/ta/courses/ta_level_filter_button.dart';
import '../../../widgets/ta/courses/ta_sort_button.dart';
import '../../../widgets/ta/dashboard/ta_drawer.dart';

class TACoursesListScreen extends StatefulWidget {
  const TACoursesListScreen({super.key});

  @override
  State<TACoursesListScreen> createState() => _TACoursesListScreenState();
}

class _TACoursesListScreenState extends State<TACoursesListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedStatus = 'all';
  String _selectedCategory = 'all';
  CourseSortOption _sortOption = CourseSortOption.newest;
  CourseViewType _viewType = CourseViewType.grid;

  final List<String> _categories = <String>[
    'all',
    'FRESHMAN',
    'SOPHOMORE',
    'JUNIOR',
    'SENIOR',
    'GRADUATE',
  ];

  static const Map<String, String> _levelLabels = <String, String>{
    'all': 'All Levels',
    'FRESHMAN': 'Freshman',
    'SOPHOMORE': 'Sophomore',
    'JUNIOR': 'Junior',
    'SENIOR': 'Senior',
    'GRADUATE': 'Graduate',
  };

  @override
  void initState() {
    super.initState();
    context.read<TACoursesCubit>().fetchTACourses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TeachingCourseModel> _coursesFromState(TACoursesState state) {
    final status = state.coursesStatus;
    if (status is TASubTabLoaded<List<TeachingCourseModel>>) {
      return status.data;
    }
    return <TeachingCourseModel>[];
  }

  int _studentCountFor(TACoursesState state, TeachingCourseModel course) {
    return state.sectionStudentCounts[course.sectionId] ?? course.enrolledCount;
  }

  int _totalStudents(TACoursesState state, List<TeachingCourseModel> courses) {
    return courses.fold<int>(
      0,
      (sum, course) => sum + _studentCountFor(state, course),
    );
  }

  String _normalizeStatus(String? value) {
    switch ((value ?? '').trim().toLowerCase()) {
      case 'draft':
        return 'draft';
      case 'archived':
      case 'inactive':
        return 'archived';
      case 'published':
      case 'active':
      default:
        return 'active';
    }
  }

  String _normalizeLevel(String? value) {
    final normalized = (value ?? '').trim().toUpperCase();
    if (normalized.isEmpty || normalized == 'UNKNOWN') {
      return 'UNKNOWN';
    }
    return normalized;
  }

  String _levelLabel(String level) {
    return _levelLabels[level] ?? level;
  }

  List<TeachingCourseModel> _filteredCourses(
    TACoursesState state,
    List<TeachingCourseModel> courses,
  ) {
    final filtered = courses.where((course) {
      final query = _searchQuery.toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          course.course.courseName.toLowerCase().contains(query) ||
          course.course.courseCode.toLowerCase().contains(query) ||
          (course.course.departmentName ?? '').toLowerCase().contains(query) ||
          course.semester.name.toLowerCase().contains(query);

      final matchesStatus =
          _selectedStatus == 'all' ||
          _normalizeStatus(course.course.status) == _selectedStatus;
      final matchesCategory =
          _selectedCategory == 'all' ||
          _normalizeLevel(course.course.level) == _selectedCategory;

      return matchesSearch && matchesStatus && matchesCategory;
    }).toList();

    switch (_sortOption) {
      case CourseSortOption.newest:
        filtered.sort((a, b) {
          final aDate =
              a.course.createdAt ?? a.semester.startDate ?? DateTime.now();
          final bDate =
              b.course.createdAt ?? b.semester.startDate ?? DateTime.now();
          return bDate.compareTo(aDate);
        });
        break;
      case CourseSortOption.oldest:
        filtered.sort((a, b) {
          final aDate =
              a.course.createdAt ?? a.semester.startDate ?? DateTime.now();
          final bDate =
              b.course.createdAt ?? b.semester.startDate ?? DateTime.now();
          return aDate.compareTo(bDate);
        });
        break;
      case CourseSortOption.mostStudents:
        filtered.sort(
          (a, b) =>
              _studentCountFor(state, b).compareTo(_studentCountFor(state, a)),
        );
        break;
      case CourseSortOption.leastStudents:
        filtered.sort(
          (a, b) =>
              _studentCountFor(state, a).compareTo(_studentCountFor(state, b)),
        );
        break;
      case CourseSortOption.alphabetical:
        filtered.sort(
          (a, b) => a.course.courseName.compareTo(b.course.courseName),
        );
        break;
      case CourseSortOption.reverseAlphabetical:
        filtered.sort(
          (a, b) => b.course.courseName.compareTo(a.course.courseName),
        );
        break;
      case CourseSortOption.mostEngagement:
        filtered.sort((a, b) {
          final aScore =
              (a.attendanceRate ??
                  (_studentCountFor(state, a) /
                      (a.capacity <= 0 ? 1 : a.capacity))) *
              100;
          final bScore =
              (b.attendanceRate ??
                  (_studentCountFor(state, b) /
                      (b.capacity <= 0 ? 1 : b.capacity))) *
              100;
          return bScore.compareTo(aScore);
        });
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return TAWalkthroughRouteMarker(
          segmentId: TAWalkthroughIds.courses,
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: TACoursesTheme.scaffoldBackground(isDark),
            drawer: TADrawer(currentRoute: '/ta/courses', isDark: isDark),
            body: DecoratedBox(
              decoration: TACoursesTheme.scaffoldDecoration(isDark),
              child: SafeArea(
                child: BlocBuilder<TACoursesCubit, TACoursesState>(
                  builder: (context, taState) {
                    final courses = _coursesFromState(taState);
                    final filteredCourses = _filteredCourses(taState, courses);

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final maxWidth = TACoursesTheme.maxContentWidth(
                          constraints.maxWidth,
                        );
                        final screenPadding = TACoursesTheme.screenPadding(
                          constraints.maxWidth,
                        );

                        return RefreshIndicator(
                          onRefresh: () async {
                            await context
                                .read<TACoursesCubit>()
                                .fetchTACourses();
                          },
                          color: TACoursesTheme.brandPrimary,
                          backgroundColor: TACoursesTheme.cardBackground(
                            isDark,
                          ),
                          child: CustomScrollView(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: ClampingScrollPhysics(),
                            ),
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
                                          WalkthroughTarget(
                                            id: TAWalkthroughIds.coursesHeader,
                                            child: TACoursesHeader(
                                              title: l10n.taCourses,
                                              subtitle:
                                                  l10n.taCoursesShellSubtitle,
                                              onMenuTap: () {
                                                _scaffoldKey.currentState
                                                    ?.openDrawer();
                                              },
                                              searchBar: TACourseSearchBar(
                                                controller: _searchController,
                                                onSearchChanged: (query) {
                                                  setState(() {
                                                    _searchQuery = query;
                                                  });
                                                },
                                                hintText: l10n.searchCourses,
                                                clearTooltip: l10n.clearFilters,
                                              ),
                                              trailingAction:
                                                  _buildHeaderActions(isDark),
                                              stats: _buildHeroStats(
                                                isDark: isDark,
                                                l10n: l10n,
                                                courses: courses,
                                                state: taState,
                                                maxWidth: maxWidth,
                                              ),
                                              tabBar: _buildStatusTabs(l10n),
                                            ),
                                          ),
                                          const SizedBox(height: 18),
                                          WalkthroughTarget(
                                            id: TAWalkthroughIds.coursesFilters,
                                            child: _buildToolbar(
                                              isDark: isDark,
                                              l10n: l10n,
                                              filteredCount:
                                                  filteredCourses.length,
                                              maxWidth: maxWidth,
                                            ),
                                          ),
                                          const SizedBox(height: 22),
                                          WalkthroughTarget(
                                            id: TAWalkthroughIds.coursesList,
                                            child: _buildContent(
                                              state: taState,
                                              isDark: isDark,
                                              l10n: l10n,
                                              courses: courses,
                                              filteredCourses: filteredCourses,
                                              maxWidth: maxWidth,
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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

  Widget _buildHeaderActions(bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isDark
                ? TACoursesTheme.darkSurfaceRaised
                : Colors.white.withValues(alpha: 0.96),
            borderRadius: TACoursesTheme.pillRadius,
            border: Border.all(color: TACoursesTheme.borderColor(isDark)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.08),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildViewToggle(
                icon: Icons.grid_view_rounded,
                type: CourseViewType.grid,
                isDark: isDark,
              ),
              const SizedBox(width: 2),
              _buildViewToggle(
                icon: Icons.view_list_rounded,
                type: CourseViewType.list,
                isDark: isDark,
              ),
              const SizedBox(width: 2),
              _buildViewToggle(
                icon: Icons.view_headline_rounded,
                type: CourseViewType.compact,
                isDark: isDark,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 52,
          height: 52,
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              context.read<ThemeBloc>().add(const ToggleThemeEvent());
            },
            icon: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isDark
                    ? TACoursesTheme.darkSurfaceRaised
                    : Colors.white.withValues(alpha: 0.96),
                borderRadius: TACoursesTheme.pillRadius,
                border: Border.all(color: TACoursesTheme.borderColor(isDark)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: TACoursesTheme.primaryText(isDark),
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildViewToggle({
    required IconData icon,
    required CourseViewType type,
    required bool isDark,
  }) {
    final isSelected = _viewType == type;
    return SizedBox(
      width: 48,
      height: 48,
      child: GestureDetector(
        onTap: () => setState(() => _viewType = type),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: isSelected ? TACoursesTheme.primaryGradient : null,
              color: isSelected ? null : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: TACoursesTheme.brandPrimary.withValues(
                          alpha: 0.28,
                        ),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              size: 18,
              color: isSelected
                  ? Colors.white
                  : TACoursesTheme.secondaryText(isDark),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTabs(AppLocalizations l10n) {
    Widget buildTab({required String label, required String value}) {
      final selected = _selectedStatus == value;
      return GestureDetector(
        onTap: () {
          setState(() {
            _selectedStatus = value;
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
          buildTab(label: l10n.activeLabel, value: 'active'),
          const SizedBox(width: 20),
          buildTab(label: l10n.draft, value: 'draft'),
          const SizedBox(width: 20),
          buildTab(label: l10n.archived, value: 'archived'),
        ],
      ),
    );
  }

  Widget _buildHeroStats({
    required bool isDark,
    required AppLocalizations l10n,
    required List<TeachingCourseModel> courses,
    required TACoursesState state,
    required double maxWidth,
  }) {
    final activeCourses = courses
        .where((course) => _normalizeStatus(course.course.status) == 'active')
        .length;
    final averageFill = courses.isEmpty
        ? 0
        : (courses.fold<double>(0, (sum, course) {
                    final count = _studentCountFor(state, course);
                    final fill = course.capacity <= 0
                        ? 0
                        : count / course.capacity;
                    return sum + fill.clamp(0.0, 1.0);
                  }) /
                  courses.length *
                  100)
              .round();

    final stats = <({IconData icon, String value, String label, Color color})>[
      (
        icon: Icons.library_books_outlined,
        value: '${courses.length}',
        label: l10n.totalCourses,
        color: const Color(0xFF34D399),
      ),
      (
        icon: Icons.groups_rounded,
        value: '${_totalStudents(state, courses)}',
        label: l10n.totalStudentsLabel,
        color: const Color(0xFF60A5FA),
      ),
      (
        icon: Icons.check_circle_outline_rounded,
        value: '$activeCourses',
        label: l10n.activeLabel,
        color: const Color(0xFFF472B6),
      ),
      (
        icon: Icons.pie_chart_outline_rounded,
        value: '$averageFill%',
        label: l10n.taCoursesAvgFill,
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
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 76),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(stat.icon, color: stat.color, size: 14),
                        const SizedBox(height: 8),
                        Text(
                          stat.value,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          stat.label,
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
                  ),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }

  Widget _buildToolbar({
    required bool isDark,
    required AppLocalizations l10n,
    required int filteredCount,
    required double maxWidth,
  }) {
    final description = _toolbarDescription(l10n);

    final menus = Row(
      children: [
        Expanded(
          child: TASortButton(
            selectedSort: _sortOption,
            onSortChanged: (sort) {
              setState(() {
                _sortOption = sort;
              });
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TALevelFilterButton(
            selectedCategory: _selectedCategory,
            categories: _categories,
            labelBuilder: _levelLabel,
            onCategoryChanged: (category) {
              setState(() {
                _selectedCategory = category;
              });
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

  String _toolbarDescription(AppLocalizations l10n) {
    final statusLabel = switch (_selectedStatus) {
      'active' => l10n.activeLabel,
      'draft' => l10n.draft,
      'archived' => l10n.archived,
      _ => l10n.all,
    };
    final levelLabel = _levelLabel(_selectedCategory);

    if (_selectedStatus == 'all' && _selectedCategory == 'all') {
      return l10n.taCoursesAllSpaces;
    }
    if (_selectedStatus != 'all' && _selectedCategory != 'all') {
      return '$statusLabel • $levelLabel';
    }
    return _selectedStatus != 'all' ? statusLabel : levelLabel;
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
          '$filteredCount ${l10n.courses}',
          style: TextStyle(
            color: TACoursesTheme.primaryText(isDark),
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            color: TACoursesTheme.secondaryText(isDark),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildContent({
    required TACoursesState state,
    required bool isDark,
    required AppLocalizations l10n,
    required List<TeachingCourseModel> courses,
    required List<TeachingCourseModel> filteredCourses,
    required double maxWidth,
  }) {
    final status = state.coursesStatus;

    if (status is TASubTabLoading<List<TeachingCourseModel>> &&
        courses.isEmpty) {
      return _buildSkeletonLoader(isDark, maxWidth);
    }

    if (status is TASubTabError<List<TeachingCourseModel>> && courses.isEmpty) {
      return _buildErrorState(isDark, l10n, status.message);
    }

    if (courses.isEmpty) {
      return _buildEmptyState(isDark, l10n);
    }

    if (filteredCourses.isEmpty) {
      return _buildNoFilterResults(isDark, l10n);
    }

    return TACoursesListView(
      courses: filteredCourses,
      studentCounts: state.sectionStudentCounts,
      viewType: _viewType,
      onTap: (course) => context.push('/ta/course/${course.sectionId}'),
      onLabsTap: (_) => context.push('/ta/labs'),
      onGradingTap: (course) =>
          context.push('/ta/grading?courseId=${course.courseId}'),
      onDiscussionsTap: (course) =>
          context.push('/ta/course/${course.courseId}/discussions'),
    );
  }

  Widget _buildSkeletonLoader(bool isDark, double maxWidth) {
    final count = maxWidth >= 960 ? 2 : 3;
    return Column(
      children: List<Widget>.generate(
        count,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Container(
            height: 260,
            decoration: BoxDecoration(
              color: TACoursesTheme.cardBackground(isDark),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: TACoursesTheme.borderColor(isDark)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 110,
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : TACoursesTheme.brandPrimary)
                        .withValues(alpha: 0.12),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(27),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _skeletonBox(isDark, width: 170, height: 16),
                      const SizedBox(height: 8),
                      _skeletonBox(isDark, width: 120, height: 12),
                      const SizedBox(height: 18),
                      Row(
                        children: List.generate(
                          3,
                          (index) => Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: index == 2 ? 0 : 10,
                              ),
                              child: _skeletonBox(
                                isDark,
                                height: 42,
                                radius: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    return _buildEmptyMessage(
      isDark: isDark,
      title: l10n.taCoursesNoAssignedTitle,
      subtitle: l10n.taCoursesNoAssignedSubtitle,
      buttonLabel: l10n.refresh,
      icon: Icons.school_rounded,
      onPressed: () {
        context.read<TACoursesCubit>().fetchTACourses();
      },
    );
  }

  Widget _buildNoFilterResults(bool isDark, AppLocalizations l10n) {
    return _buildEmptyMessage(
      isDark: isDark,
      title: l10n.taCoursesNoMatchingTitle,
      subtitle: l10n.taCoursesNoMatchingSubtitle,
      buttonLabel: l10n.clearFilters,
      icon: Icons.filter_alt_off_rounded,
      onPressed: _clearAllFilters,
    );
  }

  Widget _buildErrorState(bool isDark, AppLocalizations l10n, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TACoursesTheme.errorRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 40,
                color: TACoursesTheme.errorRed,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Unable to load courses',
              style: TextStyle(
                color: TACoursesTheme.primaryText(isDark),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TACoursesTheme.secondaryText(isDark),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () {
                context.read<TACoursesCubit>().fetchTACourses();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TACoursesTheme.brandPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.refresh),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyMessage({
    required bool isDark,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  TACoursesTheme.brandPrimary.withValues(alpha: 0.1),
                  TACoursesTheme.accentBlue.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 64, color: TACoursesTheme.brandPrimary),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white : TACoursesTheme.primaryText(isDark),
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark
                  ? Colors.white60
                  : TACoursesTheme.secondaryText(isDark),
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(
              icon == Icons.filter_alt_off_rounded
                  ? Icons.filter_alt_off_rounded
                  : Icons.refresh_rounded,
            ),
            label: Text(buttonLabel),
            style: ElevatedButton.styleFrom(
              backgroundColor: TACoursesTheme.brandPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  void _clearAllFilters() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _selectedStatus = 'all';
      _selectedCategory = 'all';
      _sortOption = CourseSortOption.newest;
    });
  }
}
