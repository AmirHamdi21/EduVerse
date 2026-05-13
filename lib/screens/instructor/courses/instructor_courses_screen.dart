import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/instructor/instructor_courses_bloc.dart';
import '../../../bloc/instructor/instructor_courses_event.dart';
import '../../../bloc/instructor/instructor_courses_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../common/utils/instructor_courses_theme.dart';
import '../../../features/walkthrough/instructor_walkthrough_registry.dart';
import '../../../features/walkthrough/walkthrough_target.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/instructor/extended_course_model.dart';
import '../../../models/instructor/instructor_course_model.dart';
import '../../../models/instructor/teaching_course_model.dart';
import '../../../services/storage_service.dart';
import '../../../widgets/instructor/courses/course_preview_modal.dart';
import '../../../widgets/instructor/courses/course_skeleton_card.dart';
import '../../../widgets/instructor/courses/empty_courses_message.dart';
import '../../../widgets/instructor/courses/instructor_course_search_bar.dart';
import '../../../widgets/instructor/courses/instructor_courses_header.dart';
import '../../../widgets/instructor/courses/instructor_courses_list_view.dart';
import '../../../widgets/instructor/courses/instructor_level_filter_button.dart';
import '../../../widgets/instructor/courses/instructor_sort_button.dart';
import '../../../widgets/instructor/courses/instructor_theme_colors.dart';

class InstructorCoursesScreen extends StatefulWidget {
  final StorageService? storageService;

  const InstructorCoursesScreen({super.key, this.storageService});

  @override
  State<InstructorCoursesScreen> createState() =>
      _InstructorCoursesScreenState();
}

class _InstructorCoursesScreenState extends State<InstructorCoursesScreen>
    with TickerProviderStateMixin {
  String _searchQuery = '';
  String _selectedStatus = 'all';
  String _selectedCategory = 'all';
  CourseSortOption _sortOption = CourseSortOption.newest;
  CourseViewType _viewType = CourseViewType.grid;
  bool _isSelectionMode = false;
  final Set<String> _selectedCourses = <String>{};
  final TextEditingController _searchController = TextEditingController();
  late final StorageService _storageService;

  bool _hasScreenAccess = true;
  bool _canDeleteCourses = true;

  late AnimationController _statsAnimController;
  late AnimationController _cardAnimController;
  late Animation<double> _statsAnimation;

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

  int _totalStudents = 0;
  List<ExtendedCourse> _courses = <ExtendedCourse>[];

  @override
  void initState() {
    super.initState();
    _storageService = widget.storageService ?? StorageService();
    _statsAnimController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _cardAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _statsAnimation = CurvedAnimation(
      parent: _statsAnimController,
      curve: Curves.easeOutCubic,
    );
    _resolveRoleAccess();
    context.read<InstructorCoursesBloc>().add(const LoadTeachingCourses());
  }

  @override
  void dispose() {
    _statsAnimController.dispose();
    _cardAnimController.dispose();
    _searchController.dispose();
    super.dispose();
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
          _hasScreenAccess = true;
          _canDeleteCourses = true;
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

      final canDelete = roleNames.any(
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
        _hasScreenAccess = hasInstructorAccess;
        _canDeleteCourses = canDelete;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _hasScreenAccess = true;
        _canDeleteCourses = true;
      });
    }
  }

  void _refreshCourses() {
    context.read<InstructorCoursesBloc>().add(const LoadTeachingCourses());
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

  void _showDeletePermissionDenied() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Access denied: TAs cannot delete courses.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<ExtendedCourse> _mapToExtendedCourses(List<TeachingCourseModel> models) {
    const colorPalette = <int>[
      0xFF0D47A1,
      0xFF7C4DFF,
      0xFF00BFA5,
      0xFFFF6D00,
      0xFFE91E63,
      0xFF536DFE,
      0xFFFFAB00,
      0xFF00C853,
    ];

    return models
        .asMap()
        .entries
        .map((entry) {
          final idx = entry.key;
          final tc = entry.value;
          final colorValue = colorPalette[idx % colorPalette.length];
          final fillRatio = tc.capacity > 0
              ? tc.enrolledCount / tc.capacity
              : 0.0;
          final sectionLabel = tc.section.sectionNumber.trim().isEmpty
              ? ''
              : 'Section ${tc.section.sectionNumber.trim()}';
          final description = (tc.course.description ?? '').trim().isNotEmpty
              ? tc.course.description!.trim()
              : sectionLabel;

          return ExtendedCourse(
            course: InstructorCourseModel(
              id: tc.courseId.toString(),
              code: tc.course.courseCode,
              name: tc.course.courseName,
              description: description,
              totalStudents: tc.enrolledCount,
              capacity: tc.capacity,
              colorValue: colorValue,
              isActive: tc.course.status != 'archived',
              semester: tc.semester.name,
              assignments: const <AssignmentModel>[],
              materials: const <MaterialModel>[],
              announcements: const <AnnouncementModel>[],
            ),
            completionRate: fillRatio.clamp(0.0, 1.0),
            engagementScore: ((tc.attendanceRate ?? fillRatio) * 100)
                .round()
                .clamp(0, 100),
            status: _normalizeCourseStatus(tc.course.status),
            category: _normalizeCourseLevel(tc.course.level),
            createdAt:
                tc.course.createdAt ?? tc.semester.startDate ?? DateTime.now(),
            enrollmentTrend: List<double>.filled(7, fillRatio.clamp(0.0, 1.0)),
            hasMilestone: (tc.averageGrade ?? 0) >= 85,
            milestoneText: (tc.averageGrade ?? 0) >= 85 ? 'High average' : null,
          );
        })
        .toList(growable: false);
  }

  String _normalizeCourseStatus(String? value) {
    switch ((value ?? '').trim().toLowerCase()) {
      case 'draft':
        return 'draft';
      case 'archived':
      case 'inactive':
        return 'archived';
      case 'published':
      case 'active':
      default:
        return 'published';
    }
  }

  String _normalizeCourseLevel(String? value) {
    final normalized = (value ?? '').trim().toUpperCase();
    if (normalized.isEmpty || normalized == 'UNKNOWN') {
      return 'UNKNOWN';
    }
    return normalized;
  }

  String _levelLabel(String level) {
    return _levelLabels[level] ?? level;
  }

  List<ExtendedCourse> get _filteredCourses {
    final result = _courses.where((course) {
      final query = _searchQuery.toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          course.course.name.toLowerCase().contains(query) ||
          course.course.code.toLowerCase().contains(query) ||
          course.course.description.toLowerCase().contains(query) ||
          course.course.semester.toLowerCase().contains(query);

      final matchesStatus =
          _selectedStatus == 'all' || course.status == _selectedStatus;
      final matchesCategory =
          _selectedCategory == 'all' || course.category == _selectedCategory;

      return matchesSearch && matchesStatus && matchesCategory;
    }).toList();

    switch (_sortOption) {
      case CourseSortOption.newest:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case CourseSortOption.oldest:
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case CourseSortOption.mostStudents:
        result.sort(
          (a, b) => b.course.totalStudents.compareTo(a.course.totalStudents),
        );
        break;
      case CourseSortOption.leastStudents:
        result.sort(
          (a, b) => a.course.totalStudents.compareTo(b.course.totalStudents),
        );
        break;
      case CourseSortOption.alphabetical:
        result.sort((a, b) => a.course.name.compareTo(b.course.name));
        break;
      case CourseSortOption.reverseAlphabetical:
        result.sort((a, b) => b.course.name.compareTo(a.course.name));
        break;
      case CourseSortOption.mostEngagement:
        result.sort((a, b) => b.engagementScore.compareTo(a.engagementScore));
        break;
    }

    return result;
  }

  _InstructorOverviewMetrics _overviewMetrics() {
    if (_courses.isEmpty) {
      return const _InstructorOverviewMetrics(
        totalCourses: 0,
        totalStudents: 0,
        publishedCourses: 0,
        averageFillPercent: 0,
      );
    }

    final published = _courses
        .where((course) => course.status == 'published')
        .length;
    final totalFill = _courses.fold<double>(
      0,
      (sum, course) => sum + course.completionRate.clamp(0.0, 1.0),
    );

    return _InstructorOverviewMetrics(
      totalCourses: _courses.length,
      totalStudents: _totalStudents,
      publishedCourses: published,
      averageFillPercent: ((totalFill / _courses.length) * 100).round(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        if (!_hasScreenAccess) {
          return _buildAccessDeniedState(isDark, l10n);
        }

        return BlocConsumer<InstructorCoursesBloc, InstructorCoursesState>(
          listener: (context, state) {
            if (state is InstructorCoursesLoaded) {
              setState(() {
                _courses = _mapToExtendedCourses(state.courses);
                _totalStudents = state.courses.fold<int>(
                  0,
                  (sum, item) => sum + item.enrolledCount,
                );
              });
              _statsAnimController
                ..reset()
                ..forward();
              _cardAnimController
                ..reset()
                ..forward();
            }
          },
          builder: (context, state) {
            final metrics = _overviewMetrics();
            final filteredCourses = _filteredCourses;

            return InstructorWalkthroughRouteMarker(
              segmentId: InstructorWalkthroughIds.courses,
              child: Scaffold(
                backgroundColor: InstructorCoursesTheme.scaffoldBackground(
                  isDark,
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.endFloat,
                floatingActionButton: WalkthroughTarget(
                  id: InstructorWalkthroughIds.coursesCreate,
                  shape: WalkthroughTargetShape.circle,
                  child: _buildFAB(l10n),
                ),
                body: DecoratedBox(
                  decoration: InstructorCoursesTheme.scaffoldDecoration(isDark),
                  child: SafeArea(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final maxWidth = InstructorCoursesTheme.maxContentWidth(
                          constraints.maxWidth,
                        );
                        final screenPadding =
                            InstructorCoursesTheme.screenPadding(
                              constraints.maxWidth,
                            );

                        return RefreshIndicator(
                          onRefresh: () async => _refreshCourses(),
                          color: InstructorColors.primary,
                          backgroundColor:
                              InstructorCoursesTheme.cardBackground(isDark),
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
                                            id: InstructorWalkthroughIds
                                                .coursesHeader,
                                            child: InstructorCoursesHeader(
                                              title: l10n.myCoursesHeader,
                                              subtitle:
                                                  'Manage every teaching section, update course spaces, and keep student activity on track.',
                                              searchBar:
                                                  InstructorCourseSearchBar(
                                                    controller:
                                                        _searchController,
                                                    onSearchChanged: (query) {
                                                      setState(() {
                                                        _searchQuery = query;
                                                      });
                                                    },
                                                    hintText:
                                                        l10n.searchCourses,
                                                    clearTooltip:
                                                        l10n.clearSearch,
                                                  ),
                                              trailingAction:
                                                  _buildHeaderActions(isDark),
                                              stats: AnimatedBuilder(
                                                animation: _statsAnimation,
                                                builder: (context, _) =>
                                                    _buildHeroStats(
                                                      isDark: isDark,
                                                      l10n: l10n,
                                                      metrics: metrics,
                                                      maxWidth: maxWidth,
                                                    ),
                                              ),
                                              tabBar: _buildStatusTabs(l10n),
                                            ),
                                          ),
                                          const SizedBox(height: 18),
                                          if (_isSelectionMode) ...[
                                            _buildBulkActionsBar(isDark, l10n),
                                            const SizedBox(height: 18),
                                          ],
                                          WalkthroughTarget(
                                            id: InstructorWalkthroughIds
                                                .coursesToolbar,
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
                                            id: InstructorWalkthroughIds
                                                .coursesList,
                                            child: _buildContent(
                                              state: state,
                                              isDark: isDark,
                                              l10n: l10n,
                                              filteredCourses: filteredCourses,
                                              maxWidth: maxWidth,
                                            ),
                                          ),
                                          const SizedBox(height: 28),
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
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAccessDeniedState(bool isDark, AppLocalizations l10n) {
    return Scaffold(
      backgroundColor: isDark
          ? InstructorColors.darkBackground
          : InstructorColors.primaryBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 44,
                color: InstructorColors.error,
              ),
              const SizedBox(height: 12),
              Text(
                'Access Denied',
                style: TextStyle(
                  color: isDark ? Colors.white : InstructorColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'You do not have permission to access instructor courses.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark
                      ? Colors.white70
                      : InstructorColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _safeBackToDashboard,
                child: Text(l10n.back),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _safeBackToDashboard() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/instructor/dashboard');
    }
  }

  Widget _buildHeaderActions(bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isDark
                ? InstructorCoursesTheme.darkSurfaceRaised
                : Colors.white.withValues(alpha: 0.96),
            borderRadius: InstructorCoursesTheme.pillRadius,
            border: Border.all(
              color: InstructorCoursesTheme.borderColor(isDark),
            ),
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
              _buildEnhancedViewToggle(
                Icons.grid_view_rounded,
                CourseViewType.grid,
                isDark,
                'view-toggle-grid',
              ),
              const SizedBox(width: 2),
              _buildEnhancedViewToggle(
                Icons.view_list_rounded,
                CourseViewType.list,
                isDark,
                'view-toggle-list',
              ),
              const SizedBox(width: 2),
              _buildEnhancedViewToggle(
                Icons.view_headline_rounded,
                CourseViewType.compact,
                isDark,
                'view-toggle-compact',
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
              setState(() {
                _isSelectionMode = !_isSelectionMode;
                if (!_isSelectionMode) {
                  _selectedCourses.clear();
                }
              });
            },
            icon: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _isSelectionMode
                    ? InstructorCoursesTheme.brandBlue
                    : (isDark
                          ? InstructorCoursesTheme.darkSurfaceRaised
                          : Colors.white.withValues(alpha: 0.96)),
                borderRadius: InstructorCoursesTheme.pillRadius,
                border: Border.all(
                  color: _isSelectionMode
                      ? InstructorCoursesTheme.brandBlue
                      : InstructorCoursesTheme.borderColor(isDark),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                _isSelectionMode
                    ? Icons.checklist_rtl_rounded
                    : Icons.checklist_rounded,
                color: _isSelectionMode
                    ? Colors.white
                    : InstructorCoursesTheme.primaryText(isDark),
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedViewToggle(
    IconData icon,
    CourseViewType type,
    bool isDark,
    String keyName,
  ) {
    final isSelected = _viewType == type;
    return SizedBox(
      key: ValueKey<String>(keyName),
      width: 48,
      height: 48,
      child: GestureDetector(
        onTap: () => setState(() => _viewType = type),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? InstructorCoursesTheme.primaryGradient
                  : null,
              color: isSelected ? null : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: InstructorCoursesTheme.brandBlue.withValues(
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
                  : InstructorCoursesTheme.secondaryText(isDark),
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
          buildTab(label: l10n.publishedAnnouncements, value: 'published'),
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
    required _InstructorOverviewMetrics metrics,
    required double maxWidth,
  }) {
    final animationValue = _statsAnimation.value;
    final stats = <({IconData icon, String value, String label, Color color})>[
      (
        icon: Icons.library_books_outlined,
        value: '${(metrics.totalCourses * animationValue).round()}',
        label: l10n.totalCourses,
        color: const Color(0xFF34D399),
      ),
      (
        icon: Icons.groups_rounded,
        value: '${(metrics.totalStudents * animationValue).round()}',
        label: l10n.totalStudentsLabel,
        color: const Color(0xFF60A5FA),
      ),
      (
        icon: Icons.check_circle_outline_rounded,
        value: '${(metrics.publishedCourses * animationValue).round()}',
        label: l10n.publishedAnnouncements,
        color: const Color(0xFFF472B6),
      ),
      (
        icon: Icons.pie_chart_outline_rounded,
        value: '${(metrics.averageFillPercent * animationValue).round()}%',
        label: 'Avg fill',
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
  }) {
    final description = _toolbarDescription(l10n);

    final menus = Row(
      children: [
        Expanded(
          child: InstructorSortButton(
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
          child: InstructorLevelFilterButton(
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
      'published' => l10n.publishedAnnouncements,
      'draft' => l10n.draft,
      'archived' => l10n.archived,
      _ => l10n.all,
    };
    final levelLabel = _levelLabel(_selectedCategory);

    if (_selectedStatus == 'all' && _selectedCategory == 'all') {
      return 'All teaching spaces';
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
            color: InstructorCoursesTheme.primaryText(isDark),
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            color: InstructorCoursesTheme.secondaryText(isDark),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildContent({
    required InstructorCoursesState state,
    required bool isDark,
    required AppLocalizations l10n,
    required List<ExtendedCourse> filteredCourses,
    required double maxWidth,
  }) {
    if (state is InstructorCoursesInitial ||
        (state is InstructorCoursesLoading && _courses.isEmpty)) {
      return _buildSkeletonLoader(isDark, maxWidth);
    }

    if (state is InstructorCoursesError && _courses.isEmpty) {
      return _buildErrorState(isDark, l10n, state.message);
    }

    if (_courses.isEmpty) {
      return _buildEmptyState(isDark, l10n);
    }

    if (filteredCourses.isEmpty) {
      return _buildNoFilterResults(isDark, l10n);
    }

    return InstructorCoursesListView(
      courses: filteredCourses,
      viewType: _viewType,
      canDelete: _canDeleteCourses,
      isSelectionMode: _isSelectionMode,
      selectedCourseIds: _selectedCourses,
      onTap: _handleCourseTap,
      onLongPress: _handleCourseLongPress,
      onQuickAction: _handleQuickAction,
    );
  }

  Widget _buildSkeletonLoader(bool isDark, double maxWidth) {
    final count = maxWidth >= 960 ? 2 : 3;
    return Column(
      children: List<Widget>.generate(
        count,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: SizedBox(
            height: 240,
            child: CourseSkeletonCard(isDark: isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    return EmptyCoursesMessage(
      isDark: isDark,
      title: 'No courses assigned yet',
      subtitle:
          'Your teaching schedule is still empty. Create a new course space or wait for department assignments to appear here.',
      buttonLabel: l10n.createCourse,
      buttonIcon: Icons.add_rounded,
      onPressed: _showCreateCourseDialog,
    );
  }

  Widget _buildNoFilterResults(bool isDark, AppLocalizations l10n) {
    return EmptyCoursesMessage(
      isDark: isDark,
      title: 'No matching courses',
      subtitle:
          'Try adjusting your search, status tab, or level filter to bring more teaching spaces back into view.',
      buttonLabel: l10n.clearFilters,
      buttonIcon: Icons.filter_alt_off_rounded,
      outlinedButton: true,
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
                color: InstructorColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 40,
                color: InstructorColors.error,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Unable to load courses',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white : InstructorColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message.isEmpty
                  ? 'Please check your connection and try again.'
                  : message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white70 : InstructorColors.textSecondary,
                fontSize: 13,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: _refreshCourses,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(l10n.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: InstructorColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulkActionsBar(bool isDark, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: InstructorCoursesTheme.primaryGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: InstructorColors.primary.withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            '${_selectedCourses.length} selected',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(
              Icons.archive_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: _selectedCourses.isEmpty
                ? null
                : () => _handleBulkAction('archive'),
            tooltip: l10n.archived,
          ),
          IconButton(
            icon: const Icon(
              Icons.publish_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: _selectedCourses.isEmpty
                ? null
                : () => _handleBulkAction('publish'),
            tooltip: l10n.publishedAnnouncements,
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: _selectedCourses.isEmpty || !_canDeleteCourses
                ? null
                : () => _handleBulkAction('delete'),
            tooltip: l10n.delete,
          ),
        ],
      ),
    );
  }

  void _handleBulkAction(String action) {
    if (action == 'delete' && !_canDeleteCourses) {
      _showDeletePermissionDenied();
      return;
    }

    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action ${_selectedCourses.length} courses'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: InstructorColors.primary,
      ),
    );
    setState(() {
      _selectedCourses.clear();
      _isSelectionMode = false;
    });
  }

  void _handleCourseTap(ExtendedCourse course) {
    if (_isSelectionMode) {
      setState(() {
        if (_selectedCourses.contains(course.course.id)) {
          _selectedCourses.remove(course.course.id);
        } else {
          _selectedCourses.add(course.course.id);
        }
      });
      HapticFeedback.selectionClick();
      return;
    }

    final courseId = int.tryParse(course.course.id) ?? 0;
    context.push('/instructor/courses/$courseId', extra: course.course);
  }

  void _handleCourseLongPress(ExtendedCourse course) {
    if (_isSelectionMode) {
      return;
    }
    HapticFeedback.mediumImpact();
    _showCoursePreviewModal(course);
  }

  void _handleQuickAction(ExtendedCourse course, String action) {
    HapticFeedback.lightImpact();
    switch (action) {
      case 'edit':
        _showEditCourseDialog(course);
        break;
      case 'analytics':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening analytics for ${course.course.name}'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        break;
      case 'duplicate':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Course "${course.course.name}" duplicated'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: InstructorColors.success,
          ),
        );
        break;
      case 'share':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Share link copied to clipboard'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: InstructorColors.primary,
          ),
        );
        break;
      case 'delete':
        if (!_canDeleteCourses) {
          _showDeletePermissionDenied();
          return;
        }
        _showDeleteConfirmation(course);
        break;
    }
  }

  void _showCoursePreviewModal(ExtendedCourse course) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CoursePreviewModal(course: course),
    );
  }

  Widget _buildFAB(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        gradient: InstructorCoursesTheme.primaryGradient,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: InstructorColors.primary.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: _showCreateCourseDialog,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          l10n.createCourse,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  void _showEditCourseDialog(ExtendedCourse course) {
    final isDark = context.read<ThemeBloc>().state.isDark;
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController(text: course.course.name);
    final codeController = TextEditingController(text: course.course.code);
    final descController = TextEditingController(
      text: course.course.description,
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        decoration: BoxDecoration(
          color: isDark ? InstructorColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: InstructorColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.edit_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    l10n.editCourse,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? Colors.white
                          : InstructorColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildModernTextField(
                isDark,
                nameController,
                l10n.courseName,
                Icons.school_rounded,
              ),
              const SizedBox(height: 16),
              _buildModernTextField(
                isDark,
                codeController,
                l10n.courseCode,
                Icons.tag_rounded,
              ),
              const SizedBox(height: 16),
              _buildModernTextField(
                isDark,
                descController,
                l10n.description,
                Icons.description_rounded,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark
                            ? Colors.white70
                            : InstructorColors.textSecondary,
                        side: BorderSide(
                          color: isDark
                              ? InstructorColors.darkBorder
                              : InstructorColors.border,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Course updated successfully'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: InstructorColors.success,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: InstructorColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(l10n.save),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField(
    bool isDark,
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(
        color: isDark ? Colors.white : InstructorColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark
                ? InstructorColors.darkBorder
                : InstructorColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark
                ? InstructorColors.darkBorder
                : InstructorColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: InstructorColors.primary,
            width: 2,
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(ExtendedCourse course) {
    if (!_canDeleteCourses) {
      _showDeletePermissionDenied();
      return;
    }

    final isDark = context.read<ThemeBloc>().state.isDark;
    final l10n = AppLocalizations.of(context);

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? InstructorColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: InstructorColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: InstructorColors.error,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.delete,
              style: TextStyle(
                color: isDark ? Colors.white : InstructorColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${course.course.name}"? This action cannot be undone.',
          style: TextStyle(
            color: isDark ? Colors.white70 : InstructorColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Course "${course.course.name}" deleted'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: InstructorColors.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: InstructorColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _showCreateCourseDialog() {
    final isDark = context.read<ThemeBloc>().state.isDark;
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final descController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        decoration: BoxDecoration(
          color: isDark ? InstructorColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: InstructorColors.successGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.add_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    l10n.createCourse,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? Colors.white
                          : InstructorColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildModernTextField(
                isDark,
                nameController,
                l10n.courseName,
                Icons.school_rounded,
              ),
              const SizedBox(height: 16),
              _buildModernTextField(
                isDark,
                codeController,
                l10n.courseCode,
                Icons.tag_rounded,
              ),
              const SizedBox(height: 16),
              _buildModernTextField(
                isDark,
                descController,
                l10n.description,
                Icons.description_rounded,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.courseCreated),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: InstructorColors.success,
                      ),
                    );
                    _refreshCourses();
                  },
                  icon: const Icon(Icons.rocket_launch_rounded),
                  label: Text(l10n.createCourse),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: InstructorColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InstructorOverviewMetrics {
  final int totalCourses;
  final int totalStudents;
  final int publishedCourses;
  final int averageFillPercent;

  const _InstructorOverviewMetrics({
    required this.totalCourses,
    required this.totalStudents,
    required this.publishedCourses,
    required this.averageFillPercent,
  });
}
